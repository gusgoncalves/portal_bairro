"""Navegador Chrome real com MySQL descartável; nunca escreve na base operacional."""
from pathlib import Path
import sys,os,subprocess,socket,time,secrets,base64,json,re
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'storage/pdf-build/deps'))
from playwright.sync_api import sync_playwright
HIDDEN=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0
name='portal_prd_teste_'+secrets.token_hex(5)
subprocess.run(['php','tests/support/mysql_test_database.php','create',name],cwd=ROOT,check=True,creationflags=HIDDEN)
with socket.socket() as sock:sock.bind(('127.0.0.1',0));port=sock.getsockname()[1]
base=f'http://127.0.0.1:{port}/'
env={**os.environ,'database.default.database':name,'app.baseURL':base}
proc=None
folder=ROOT/'writable/test-runs';folder.mkdir(exist_ok=True)
isolated=folder/name;isolated.mkdir();(isolated/'uploads').mkdir();(isolated/'session').mkdir();env['PORTAL_TEST_UPLOAD_PATH']=str(isolated/'uploads');env['session.savePath']=str(isolated/'session')
try:
 result=subprocess.run(['php','-d','auto_prepend_file=tests/support/sandbox_fs.php','spark','portal:install','--sem-portal'],cwd=ROOT,env=env,capture_output=True,creationflags=HIDDEN)
 assert result.returncode==0,result.stdout
 counts=subprocess.run(['php','tests/support/mysql_test_database.php','inspect',name],cwd=ROOT,capture_output=True,text=True,check=True,creationflags=HIDDEN).stdout
 assert json.loads(counts)=={'usuarios':1,'anuncios':0},counts
 log=(folder/'browser-prd.log').open('w')
 proc=subprocess.Popen(['php','-d','upload_tmp_dir='+str(folder),'-d','upload_max_filesize=5M','-d','post_max_size=20M','-S',f'127.0.0.1:{port}','-t','public','tests/support/http_router.php'],cwd=ROOT,env=env,stdout=log,stderr=log,creationflags=HIDDEN)
 with sync_playwright() as p:
  browser=p.chromium.launch(executable_path='C:/Program Files/Google/Chrome/Application/chrome.exe',headless=True,args=['--no-sandbox','--disable-gpu'])
  page=browser.new_page(viewport={'width':1440,'height':1000})
  errors=[];page.on('pageerror',lambda e:errors.append(str(e)))
  for retry in range(3):
   try:page.goto(base);page.wait_for_selector('#empty-access',state='attached',timeout=10000);break
   except Exception:
    if retry==2:raise RuntimeError(str(errors))
    time.sleep(.2)
  assert page.locator('.business-card').count()==0
  assert page.locator('.region-control').is_hidden()
  assert page.request.get(base+'api/portals').json()=={'portals':[]}
  page.goto(base+'admin');page.wait_for_selector('#access-form')
  page.locator('#access-dialog [data-close]').click()
  def login(email,password,route):
   page.locator('#access-button').click()
   if page.locator('#access-switch').count():page.locator('#access-switch').click()
   page.wait_for_selector('#access-form')
   page.locator('#access-form [name=email]').fill(email);page.locator('#access-form [name=password]').fill(password);page.locator('#access-form [type=submit]').click()
   page.wait_for_url('**#'+route);page.wait_for_selector('#access-dialog',state='hidden')
   label={'/admin':'Administração master','/gestor':'Gestão da sua vitrine','/anunciantes':'Meu catálogo'}[route]
   page.wait_for_function('(text)=>document.querySelector("h1")?.textContent.includes(text)',arg=label)
  login('admin','1234','/admin')
  assert 'Administração master' in page.locator('h1').inner_text()
  page.get_by_role('link',name='Portais',exact=True).click();page.wait_for_selector('#create-portal');page.locator('#create-portal').click()
  action=page.locator('.action-dialog[open]')
  for key,value in {'name':'Vitrine Antonil','organization':'Condomínio Antonil','endereco_local':'Rua Antonil, 46','capacity':'20'}.items():action.locator('[name='+key+']').fill(value)
  action.locator('[type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached')
  portals=page.evaluate("async()=> (await api('/admin/portals')).portals")
  added=next(p for p in portals if p['slug']=='vitrine-antonil');assert added['endereco_local']=='Rua Antonil, 46'
  page.wait_for_selector('a:has-text("Abrir vitrine")')
  assert page.get_by_role('link',name='Abrir vitrine',exact=True).get_attribute('href')==base+'?portal=vitrine-antonil#/'
  page.evaluate("""async()=>api('/admin/users',{method:'POST',body:JSON.stringify({name:'Gestor Piloto',email:'gestor@example.test',password:'SenhaGestorSegura123!',role:'manager',portal_id:1,valor_assinatura_centavos:20000})})""")
  if page.locator('#notice[open]').count():page.locator('#notice-ok').click()
  page.evaluate('async()=>refresh()');page.wait_for_selector('[data-portal-edit]');assert 'Gestor Piloto' in page.locator('#app').inner_text()
  page.locator('[data-portal-edit]').click();action=page.locator('.action-dialog[open]');action.locator('[name=name]').fill('Vitrine Antonil Editada');action.locator('[type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached');assert 'Vitrine Antonil Editada' in page.locator('#app').inner_text()
  page.get_by_role('link',name='Gestores e acessos',exact=True).click();page.wait_for_selector('[data-user-access]');page.locator('[data-user-access]').click();action=page.locator('.action-dialog[open]');action.locator('[name=name]').fill('Gestor Piloto Editado');action.locator('[name=email]').fill('gestor-novo@example.test');action.locator('[type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached');assert 'gestor-novo@example.test' in page.locator('#app').inner_text()
  login('gestor-novo@example.test','SenhaGestorSegura123!','/gestor')
  assert 'Gestão da sua vitrine' in page.locator('h1').inner_text()
  assert page.locator('.dashboard-nav a',has_text='Auditoria').count()==0
  page.get_by_role('link',name='Identidade da vitrine',exact=True).click();page.wait_for_selector('#identity-form')
  page.locator('[name=cor_principal]').fill('#ffff00');page.locator('[name=cor_texto]').fill('#112233');page.locator('[name=fonte]').select_option('Georgia')
  assert page.locator('#identity-preview').evaluate("el=>getComputedStyle(el).color")=='rgb(17, 34, 51)'
  page.locator('#identity-form [type=submit]').click();page.wait_for_function("document.body.style.fontFamily==='' && getComputedStyle(document.body).fontFamily.includes('Georgia')")
  # Voltar ao padrão aprovado depois de comprovar a personalização.
  page.locator('[name=cor_principal]').fill('#6250ec');page.locator('[name=cor_texto]').fill('#ffffff');page.locator('[name=fonte]').select_option('Inter');page.locator('#identity-form [type=submit]').click()
  page.wait_for_function("getComputedStyle(document.body).fontFamily.includes('Inter')")
  page.get_by_role('link',name='Horários de atendimento',exact=True).click();page.wait_for_selector('#new-schedule');assert page.locator('.dashboard-nav a.active').inner_text()=='Horários de atendimento'
  page.locator('#new-schedule').click();action=page.locator('.action-dialog[open]')
  for n in range(1,8):action.locator('[name=dia_'+str(n)+']').set_checked(n in [1,3,5])
  action.locator('[name=hora_inicio]').fill('09:00');action.locator('[name=hora_fim]').fill('17:00');action.locator('[type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached')
  horarios=page.evaluate("async()=> (await api('/schedules')).schedules");custom=next(h for h in horarios if h['hora_inicio']=='09:00')
  page.wait_for_selector('[data-schedule-edit="'+str(custom['id'])+'"]')
  page.get_by_role('link',name='Novo anunciante',exact=True).click();page.wait_for_selector('#onboard-form');assert page.locator('.dashboard-nav a.active').inner_text()=='Novo anunciante'
  for key,value in {'name':'Empresa de Teste','responsavel':'Responsável','email':'empresa@example.test','password':'SenhaEmpresaSegura123!','mensalidade':'89.90'}.items():page.locator('#onboard-form [name='+key+']').fill(value)
  assert page.locator('#onboard-form').evaluate('(f)=>f.checkValidity()'),page.locator('#onboard-form').evaluate('(f)=>[...f.elements].map(x=>({name:x.name,valid:x.validity.valid,message:x.validationMessage}))')
  try:
   with page.expect_response(lambda r:'/companies?' in r.url and r.request.method=='POST') as created_response:page.locator('#onboard-form [type=submit]').click()
  except Exception:raise AssertionError((page.locator('#app').inner_text(),errors))
  assert created_response.value.status==201,(created_response.value.status,created_response.value.text())
  page.wait_for_selector('#notice[open]');assert 'notice-warning' in page.locator('#notice').get_attribute('class');page.locator('#notice-ok').click()
  try:page.wait_for_selector('[data-commercial]')
  except Exception:raise AssertionError((page.locator('#app').inner_text(),errors))
  item=page.evaluate("async()=> (await api('/publications?scope=manage')).publications[0]");id=item['id']
  assert item['acesso_liberado_em'] and item['primeira_publicacao_em'] is None
  assert page.evaluate("async()=> (await api('/charges')).charges.length")==0
  page.get_by_role('link',name='Usuários dos anunciantes',exact=True).click();page.wait_for_selector('[data-member-toggle]');assert page.locator('.dashboard-nav a.active').inner_text()=='Usuários dos anunciantes'
  page.locator('[data-member-email]').click();action=page.locator('.action-dialog[open]');action.locator('[name=email]').fill('empresa-nova@example.test');action.locator('[type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached');assert 'empresa-nova@example.test' in page.locator('#app').inner_text()
  assert 'admin@portal.local' not in page.locator('#app').inner_text()
  page.locator('[data-member-toggle]').click();page.locator('.action-dialog[open] [type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached');page.wait_for_function('document.querySelector("[data-member-toggle]").textContent==="Ativar"')
  page.locator('[data-member-toggle]').click();page.locator('.action-dialog[open] [type=submit]').click();page.wait_for_selector('.action-dialog[open]',state='detached');page.wait_for_function('document.querySelector("[data-member-toggle]").textContent==="Inativar"')
  login('empresa-nova@example.test','SenhaEmpresaSegura123!','/anunciantes')
  page.goto(base+f'#/anunciantes/editar/{id}');page.wait_for_selector('#edit-form')
  assert page.locator('select[name=hours]').count()==1
  for key,value in {'service':'Reparos residenciais','description':'Serviços de teste do piloto','whatsapp':'123','instagram':'empresa.teste','services':'Reparos\nManutenção'}.items():page.locator('#edit-form [name='+key+']').fill(value)
  page.locator('[name=hours]').select_option(custom['descricao'])
  page.locator('#edit-form [type=submit]').click();page.wait_for_selector('[name=whatsapp][aria-invalid=true]');page.locator('[name=whatsapp]').fill('5542999999999')
  image=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jWRkAAAAASUVORK5CYII=')
  page.locator('#company-images').set_input_files([{'name':f'foto-{i}.png','mimeType':'image/png','buffer':image} for i in range(3)])
  page.locator('#preview-editor').click();page.wait_for_selector('#company-dialog[open]');assert custom['descricao'] in page.locator('#company-dialog').inner_text();assert page.locator('#company-dialog .extra-photos button').count()==2
  page.locator('#company-dialog .company-close').click();page.locator('#edit-form [type=submit]').click();page.wait_for_selector('[data-invite]')
  assert page.evaluate("async()=> (await api('/publications')).publications.length")==0
  login('gestor-novo@example.test','SenhaGestorSegura123!','/gestor')
  page.goto(base+f'#/gestor/revisar/{id}');page.wait_for_selector('[data-review-decision=approve]');page.locator('[data-review-decision=approve]').click();page.wait_for_selector('.review-badge',state='detached')
  bills=page.evaluate("async()=> (await api('/charges')).charges");assert len(bills)==1 and bills[0]['amount_cents']==8990
  # Registra clique de contato sem abrir serviço externo.
  page.goto(base);page.wait_for_selector('.business-card')
  page.locator('.contact-button').evaluate("el=>el.addEventListener('click',e=>e.preventDefault(),{once:true})")
  with page.expect_response(lambda r:'/click?' in r.url) as event:page.locator('.contact-button').click()
  assert event.value.status==200
  page.goto(base+'#/gestor');page.wait_for_selector('#contact-total');assert page.locator('#contact-total').inner_text()=='1'
  page.locator('#open-contact-chart').click();page.wait_for_selector('#contact-charts-dialog[open]');assert 'Empresa de Teste' in page.locator('#contact-charts-dialog').inner_text();assert re.search(r'WhatsApp:\s*1',page.locator('.contact-legend').inner_text());page.screenshot(path=str(folder/'contatos-por-anunciante.png'));page.locator('#contact-charts-dialog [data-close]').click()
  for label in ['Anúncios','Aprovações','Financeiro','Usuários dos anunciantes']:
   page.get_by_role('link',name=label,exact=True).first.click();page.wait_for_function('(label)=>[...document.querySelectorAll(".dashboard-nav a.active")].some(a=>a.textContent===label)',arg=label)
  login('admin','1234','/admin')
  platform_bills=page.evaluate("async()=> (await api('/admin/charges')).charges");assert len(platform_bills)==1 and all(c['tipo_cobranca']=='plataforma' for c in platform_bills)
  assert '89,90' not in page.locator('#app').inner_text()
  page.get_by_role('link',name='Auditoria',exact=True).click();page.wait_for_function('document.querySelector(".dashboard-nav a.active").textContent==="Auditoria"')
  page.get_by_role('link',name='Envio de e-mails',exact=True).click();page.wait_for_selector('#smtp-settings-form')
  smtp_form=page.locator('#smtp-settings-form')
  for key,value in {'servidor':'127.0.0.1','porta':'1','remetente_email':'portal@example.test','remetente_nome':'Portal teste'}.items():smtp_form.locator('[name='+key+']').fill(value)
  smtp_form.locator('[name=seguranca]').select_option('nenhuma');smtp_form.locator('[name=ativo]').select_option('0');smtp_form.locator('[type=submit]').click();page.wait_for_selector('#notice.notice-success[open]');page.locator('#notice-ok').click()
  page.locator('#smtp-test-form [name=email]').fill('cliente@example.test');page.locator('#smtp-test-form [type=submit]').click();page.wait_for_selector('#notice.notice-warning[open]');page.locator('#notice-ok').click()
  smtp_form=page.locator('#smtp-settings-form');smtp_form.locator('[name=ativo]').select_option('1');smtp_form.locator('[type=submit]').click();page.wait_for_selector('#notice.notice-success[open]');page.locator('#notice-ok').click()
  page.locator('#smtp-test-form [type=submit]').click();page.wait_for_selector('#notice.notice-danger[open]');page.locator('#notice-ok').click()
  page.get_by_role('link',name='Minha conta',exact=True).click();page.wait_for_selector('#account-form');page.locator('#account-form [name=email]').fill('master-real@example.test');page.locator('#account-form [name=current]').fill('1234');page.locator('#account-form [type=submit]').click();page.wait_for_function("document.querySelector('#account-form [role=status]')?.textContent.includes('Dados de acesso atualizados')");assert page.evaluate('auth.user.email')=='master-real@example.test'
  page.wait_for_selector('#notice.notice-success[open]');page.locator('#notice-ok').click()
  # Conferência pública em desktop e celular.
  page.evaluate("async()=>{auth=await api('/logout',{method:'POST'});}");page.goto(base);page.wait_for_selector('.business-card')
  page.locator('[data-company]').click();page.wait_for_selector('#company-dialog[open]');page.locator('.extra-photos button').first.click();page.wait_for_selector('#photo-dialog[open]');page.locator('.photo-close').click();page.locator('.company-close').click()
  page.locator('[data-favorite]').click();assert 'Salvo' in page.locator('[data-favorite]').inner_text()
  page.screenshot(path=str(folder/'vitrine-prd-desktop.png'),full_page=True)
  page.set_viewport_size({'width':390,'height':844});page.screenshot(path=str(folder/'vitrine-prd-mobile.png'),full_page=True)
  assert page.evaluate('document.documentElement.scrollWidth<=window.innerWidth'),'Rolagem horizontal a 390px'
  page.set_viewport_size({'width':320,'height':740});assert page.evaluate('document.documentElement.scrollWidth<=window.innerWidth'),'Rolagem horizontal a 320px'
  assert not errors,errors
  print('PASS: arranque sem vitrines e links próprios; Chrome/MySQL: login em popup por perfil, endereço físico, identidade com texto/fonte, horários, usuários do gestor, navegação ativa, cliques reais e financeiro master separado.')
  browser.close()
finally:
 if proc:proc.terminate();proc.wait(timeout=10)
 subprocess.run(['php','tests/support/mysql_test_database.php','drop',name],cwd=ROOT,check=True,creationflags=HIDDEN)
 import shutil
 assert isolated.resolve().is_relative_to(folder.resolve()) and isolated.name==name
 shutil.rmtree(isolated)
