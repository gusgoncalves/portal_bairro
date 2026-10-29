"""Integração CGI do CodeIgniter. SQLite apenas como fixture, sem substituir o MySQL da aplicação."""
from contextlib import closing
import re
import shutil
import urllib.parse
import json
import base64
import os
from pathlib import Path
import socket
import sqlite3
import subprocess
import tempfile
import time
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
checks = 0


def check(condition, message):
    global checks
    assert condition, message
    checks += 1


class Client:
    def __init__(self, base):
        self.csrf = ''
        self.cookie = ''

    def request(self, path, method='GET', data=None, csrf=True, files=None):
        parsed = urllib.parse.urlsplit(path)
        payload = json.dumps(data).encode() if data is not None else b''
        content_type='application/json'
        if files is not None:
            boundary='----PortalTestBoundary42'
            content_type='multipart/form-data; boundary='+boundary
            payload=b''
            for name,content,mime in files:
                payload+=f'--{boundary}\r\nContent-Disposition: form-data; name="images[]"; filename="{name}"\r\nContent-Type: {mime}\r\n\r\n'.encode()+content+b'\r\n'
            payload+=f'--{boundary}--\r\n'.encode()
        script = 'public/index.php'
        request_env = {**env, 'REDIRECT_STATUS':'1', 'REQUEST_METHOD':method,
            'SCRIPT_FILENAME':str(ROOT / script), 'SCRIPT_NAME':'/index.php', 'DOCUMENT_ROOT':str(ROOT/'public'),
            'REQUEST_URI':path, 'QUERY_STRING':parsed.query, 'CONTENT_TYPE':content_type,
            'CONTENT_LENGTH':str(len(payload)), 'SERVER_NAME':'localhost', 'HTTP_HOST':'localhost',
            'SERVER_PROTOCOL':'HTTP/1.1', 'REMOTE_ADDR':'127.0.0.1', 'HTTP_COOKIE':self.cookie,
            'HTTP_X_CSRF_TOKEN':self.csrf if csrf else ''}
        response = subprocess.run([shutil.which('php-cgi'), '-d', 'auto_prepend_file='+str(ROOT/'tests/support/sandbox_fs.php'), '-d', 'cgi.force_redirect=0', '-d', 'upload_tmp_dir='+str(temp), '-d', 'upload_max_filesize=5M', '-d', 'post_max_size=20M'], input=payload, env=request_env, cwd=ROOT, capture_output=True, check=False, creationflags=hidden)
        if response.returncode and b'\r\n\r\n' not in response.stdout: raise RuntimeError(response.stderr.decode(errors='replace')+response.stdout.decode(errors='replace')[:4000])
        raw = response.stdout.decode(errors='replace')
        headers, content = raw.split('\r\n\r\n',1)
        status = re.search(r'^Status: (\d+)', headers, re.M)
        code = int(status.group(1)) if status else 200
        cookie = re.search(r'^Set-Cookie: (portal_ci_session=[^;\r\n]+)', headers, re.M)
        if cookie:
            self.cookie = cookie.group(1)
        result = json.loads(content) if 'application/json' in headers else content
        if isinstance(result, dict) and 'csrf' in result:
            self.csrf = result['csrf']
        return code, result

    def login(self, email, password):
        self.request('/api/session')
        return self.request('/api/login', 'POST', {'email': email, 'password': password})


DB_NAMES=json.loads((ROOT/'database/nomes_banco.json').read_text(encoding='utf-8'))
DB_MAP={key:value for group in DB_NAMES.values() for key,value in group.items()}
def sql_pt(sql):
    pattern=r"'(?:''|\\.|[^'\\])*'|\"(?:\"\"|\\.|[^\"\\])*\"|`(?:``|[^`])*`|[A-Za-z_][A-Za-z0-9_]*"
    def replace(match):
        token=match[0]
        if token[0] in "'\"":return token
        if token[0]=='`':return '`'+DB_MAP.get(token[1:-1].lower(),token[1:-1])+'`'
        return DB_MAP.get(token.lower(),token)
    return re.sub(pattern,replace,sql,flags=re.S)
class ConexaoPortugues(sqlite3.Connection):
    def execute(self,sql,parameters=()):return super().execute(sql_pt(sql),parameters)

test_root = (ROOT / 'writable' / 'test-runs').resolve()
assert test_root.is_relative_to(ROOT.resolve())
test_root.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='portal-tests-', dir=test_root) as temporary:
    temp = Path(temporary)
    env = {**os.environ, 'CI_ENVIRONMENT':'development', 'portal.defaultSlug':'vila-esperanca', 'portal.chaveEmails':'test-email-key-1234567890-abcdefghij', 'PORTAL_TEST_DB':str(temp/'test.sqlite'), 'PORTAL_TEST_UPLOAD_PATH':str(temp/'uploads'), 'session.savePath':str(temp), 'app.baseURL':'http://localhost/', 'session.cookieName':'portal_ci_session'}
    hidden = subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
    # Traduz os tipos/índices MySQL para uma fixture SQLite isolada.
    schema=(ROOT/'database/mysql.sql').read_text(encoding='utf-8')
    schema=re.sub(r'^--.*$', '', schema, flags=re.M)
    schema=re.sub(r'CREATE DATABASE[^;]+;|USE portal_bairro;', '', schema)
    schema=schema.replace('ENGINE=InnoDB','')
    schema=re.sub(r'(?:BIGINT|INT) UNSIGNED AUTO_INCREMENT PRIMARY KEY','INTEGER PRIMARY KEY AUTOINCREMENT',schema)
    schema=re.sub(r'(?:BIGINT|INT) UNSIGNED','INTEGER',schema)
    schema=re.sub(r'INDEX \w+\([^)]*\),?', '', schema)
    schema=re.sub(r',\s*\)', ')', schema)
    password='TesteLocal!123456'
    hashed=subprocess.run(['php','-r','echo password_hash($argv[1],PASSWORD_DEFAULT);',password],capture_output=True,text=True,check=True,creationflags=hidden).stdout
    credentials={email:password for email in ['gestor@portal.local','master@portal.local','anunciante@portal.local']}
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        conn.executescript(schema)
        conn.execute("INSERT INTO organizations(id,name) VALUES(1,'Gestão Vila Esperança')")
        conn.execute("INSERT INTO portals(id,organization_id,slug,name,capacity) VALUES(1,1,'vila-esperanca','Vila Esperança',10)")
        for b in json.loads((ROOT/'tests/fixtures/anuncios.json').read_text(encoding='utf-8')):
            conn.execute('INSERT INTO advertisers(id,name) VALUES(?,?)',(b['id'],b['name']))
            conn.execute('INSERT INTO publications(id,portal_id,advertiser_id,name,category,service,description,tags,color,accent,type,mode,hours,services,status) VALUES(?,1,?,?,?,?,?,?,?,?,?,?,?,?,?)',(b['id'],b['id'],b['name'],b['category'],b['service'],b['description'],b['tags'],b['color'],b['accent'],b['type'],b['mode'],b['hours'],json.dumps(b['services']),b['status']))
        for i,(name,email,role,advertiser) in enumerate([('Master','master@portal.local','master',None),('Gestor','gestor@portal.local','manager',None),('Anunciante','anunciante@portal.local','advertiser',1)],1):
            conn.execute('INSERT INTO users(id,name,email,password_hash,role,advertiser_id) VALUES(?,?,?,?,?,?)',(i,name,email,hashed,role,advertiser))
            conn.execute('INSERT INTO memberships(user_id,portal_id) VALUES(?,1)',(i,))
        conn.execute("INSERT INTO organizations(id,name) VALUES(2,'Outra organização')")
        conn.execute("INSERT INTO portals(id,organization_id,slug,name,capacity) VALUES(2,2,'outro-bairro','Outro Bairro',10)")
        conn.execute("INSERT INTO publications(portal_id,advertiser_id,name,category,service,description,mode,hours,services,status) VALUES(2,1,'Outro portal','reformas','Reparos','Teste','A domicílio','8h','[\"Reparos\"]','pending')")
        conn.execute("UPDATE publications SET acesso_liberado_em=CURRENT_TIMESTAMP,mensalidade_centavos=10000,primeira_publicacao_em=CASE WHEN status='published' THEN CURRENT_TIMESTAMP ELSE NULL END WHERE portal_id=1")
        for pid,hours in conn.execute("SELECT DISTINCT portal_id,hours FROM publications WHERE hours<>''").fetchall():
            conn.execute('INSERT OR IGNORE INTO horarios_atendimento(id_portal,descricao) VALUES(?,?)',(pid,hours))
        conn.execute("INSERT OR IGNORE INTO horarios_atendimento(id_portal,descricao,dias_semana,hora_inicio,hora_fim) VALUES(1,'Segunda a sexta, das 08:00 às 18:00','1,2,3,4,5','08:00','18:00')")
        conn.execute("INSERT OR IGNORE INTO horarios_atendimento(id_portal,descricao) VALUES(1,'8h às 18h')")
        conn.commit()
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        admin_hash=subprocess.run(['php','-r','echo password_hash("1234",PASSWORD_DEFAULT);'],capture_output=True,text=True,check=True,creationflags=hidden).stdout
        conn.execute("INSERT INTO users(id,name,email,password_hash,role,active) VALUES(4,'Admin','admin@portal.local',?,'master',1)",(admin_hash,));conn.commit()
    def request_ok(client,path,method='GET',data=None,code=200,**kwargs):
        status,result=client.request(path,method,data,**kwargs)
        check(status==code,f'{method} {path}: expected {code}, got {status}: {result}')
        return result
    def get_public(id):
        return next((b for b in guest.request('/api/publications')[1]['publications'] if b['id']==id),None)
    def proposal(id):return request_ok(manager,f'/api/publications/{id}/review')
    def approve(id,client=None):
        client=client or manager;review=request_ok(client,f'/api/publications/{id}/review');revision=review['proposed']['revision']
        if revision is None:
            request_ok(client,f'/api/publications/{id}','PUT',review['proposed']);review=request_ok(client,f'/api/publications/{id}/review');revision=review['proposed']['revision']
        return client.request(f'/api/publications/{id}/review','POST',{'decision':'approve','revision_id':revision['id'],'version':revision['version']})
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        check('anuncios' in [r[0] for r in sqlite3.Connection.execute(conn,"SELECT name FROM sqlite_master WHERE type='table'")], 'Tabelas físicas em português')
        check('nome' in [r[1] for r in conn.execute('PRAGMA table_info(anuncios)')], 'Colunas físicas em português')
    guest=Client('cgi')
    request_ok(guest,'/api/session')
    request_ok(guest,'/api/charges',code=401)
    request_ok(guest,'/api/audit',code=403)
    request_ok(guest,'/api/publications?scope=manage',code=401)
    request_ok(guest,'/api/publications/1/review',code=401)
    check(len(request_ok(guest,'/api/publications')['publications'])==8,'Only approved profiles public')
    for path in ['/storage/ACESSOS_LOCAIS.txt','/writable/ACESSOS_LOCAIS.txt','/database/mysql.sql','/.env','/backend/api.php']:
        request_ok(guest,path,code=404)
    request_ok(guest,'/api/login','POST',{'email':'admin','password':'1234'},code=403,csrf=False)
    admin=Client('cgi');check(admin.login('admin','1234')[0]==200,'Requested local admin login')
    manager=Client('cgi');check(manager.login('gestor@portal.local',password)[0]==200,'Manager login')
    advertiser=Client('cgi');check(advertiser.login('anunciante@portal.local',password)[0]==200,'Advertiser login')
    check(len(request_ok(advertiser,'/api/publications?scope=mine')['publications'])==1,'Owner sees only own catalogue')
    request_ok(advertiser,'/api/publications?scope=manage',code=403)
    request_ok(manager,'/api/publications?scope=manage&portal=outro-bairro',code=403)
    request_ok(advertiser,'/api/publications/1/review',code=403)
    request_ok(guest,'/api/publications/1/preview',code=401)
    request_ok(advertiser,'/api/publications/2/preview',code=403)
    request_ok(advertiser,'/api/publications/1/preview?version=public')
    original=get_public(1)
    own={**original,'name':'Novo nome sob análise','description':'Apresentação alterada','whatsapp':'+55 (42) 99999-9999','instagram':'https://www.instagram.com/empresa.local/'}
    request_ok(advertiser,'/api/publications/2','PUT',own,code=403)
    request_ok(advertiser,'/api/publications/1','PUT',own)
    check(get_public(1)['name']==original['name'],'Owner edit does not publish')
    invalid={**own,'whatsapp':'123'}
    invalid_response=request_ok(advertiser,'/api/publications/1','PUT',invalid,code=422)
    check('whatsapp' in invalid_response['fields'],'Validação de WhatsApp vinculada ao campo')
    draft=request_ok(advertiser,'/api/publications?scope=mine')['publications'][0]
    check(draft['name']==own['name'] and draft['has_pending'],'Owner sees submitted content')
    check(draft['whatsapp']=='5542999999999' and draft['instagram']=='empresa.local','Contact normalization')
    request_ok(advertiser,'/api/publications/1/review','POST',{'decision':'approve'},code=403)
    request_ok(manager,'/api/publications/1/status','POST',{'status':'published'},code=409)
    stale=proposal(1)['proposed']['revision']
    own['name']='Proposta mais recente';request_ok(advertiser,'/api/publications/1','PUT',own)
    request_ok(manager,'/api/publications/1/review','POST',{'decision':'approve','revision_id':stale['id'],'version':stale['version']},code=409)
    check(approve(1)[0]==200,'Manager approves latest revision')
    check(get_public(1)['name']==own['name'],'Approved snapshot becomes public')
    check(get_public(1)['whatsapp']=='5542999999999','Approved contacts public')
    own['name']='Versão devolvida';request_ok(advertiser,'/api/publications/1','PUT',own)
    revision=proposal(1)['proposed']['revision']
    request_ok(manager,'/api/publications/1/review','POST',{'decision':'reject','revision_id':revision['id'],'version':revision['version'],'note':''},code=422)
    request_ok(manager,'/api/publications/1/review','POST',{'decision':'reject','revision_id':revision['id'],'version':revision['version'],'note':'Revise a apresentação.'})
    check(get_public(1)['name']=='Proposta mais recente','Rejection preserves approved version')
    rejected=request_ok(advertiser,'/api/publications?scope=mine')['publications'][0]
    check(rejected['revision']['status']=='rejected' and rejected['revision']['note']=='Revise a apresentação.','Owner sees rejection reason')
    own['name']='Proposta corrigida';request_ok(advertiser,'/api/publications/1','PUT',own)
    check(approve(1,admin)[0]==200,'Admin approves corrected proposal')
    # Imagens: rascunhos privados e publicação atômica somente após revisão.
    png=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jWRkAAAAASUVORK5CYII=')
    image=('fachada.png',png,'image/png')
    uploaded=request_ok(advertiser,'/api/publications/1/images','POST',files=[image,image,image],code=201)['publication']
    check(len(uploaded['images'])==3,'Three draft images')
    check(len(get_public(1)['images'])==0,'Draft upload invisible on public card')
    pending_image=uploaded['images'][0]
    request_ok(guest,'/'+pending_image['url'],code=404)
    request_ok(advertiser,'/'+pending_image['url'])
    request_ok(advertiser,'/api/publications/1/images','POST',files=[image],code=409)
    request_ok(advertiser,'/api/publications/2/images','POST',files=[image],code=403)
    request_ok(advertiser,'/api/publications/1/images/'+str(uploaded['images'][1]['id'])+'/cover?source=draft','POST',{})
    check(proposal(1)['proposed']['images'][0]['caption']==uploaded['images'][1]['caption'],'Capa alterada apenas na proposta')
    check(approve(1)[0]==200,'Approve three images')
    check(get_public(1)['images'][0]['caption']==uploaded['images'][1]['caption'],'Capa aprovada consistente')
    live=get_public(1)['images'];check(len(live)==3,'Three images published together')
    request_ok(guest,'/'+live[0]['url'])
    # Remover da proposta não remove da versão pública.
    request_ok(advertiser,f"/api/publications/1/images/{live[0]['id']}?source=public",'DELETE')
    check(len(get_public(1)['images'])==3,'Public images preserved during removal review')
    request_ok(guest,'/'+live[0]['url'])
    request_ok(advertiser,'/api/publications/1/images','POST',files=[('fake.png',b'not an image','image/png')],code=422)
    request_ok(advertiser,'/api/publications/1/images','POST',files=[('script.svg',b'<svg/>','image/svg+xml')],code=422)
    request_ok(advertiser,'/api/publications/1/images','POST',files=[image],code=201)
    check(len(get_public(1)['images'])==3,'Replacement still pending')
    check(approve(1)[0]==200,'Approve replacement without changing image limit')
    check(len(get_public(1)['images'])==3,'Replacement published')
    current_live=get_public(1)['images']
    request_ok(manager,'/api/publications/1/status','POST',{'status':'suspended','motivo':'Solicitado pelo gestor no teste.'})
    check(get_public(1) is None,'Suspended card hidden')
    request_ok(guest,'/'+get_public(2)['images'][0]['url'],code=404) if get_public(2)['images'] else None
    request_ok(guest,'/'+current_live[1]['url'],code=404)
    request_ok(manager,'/api/publications/1/status','POST',{'status':'published'})
    # Edições do administrador também aguardam uma ação explícita de aprovação.
    admin_edit={**get_public(1),'name':'Edição administrativa em análise'}
    request_ok(admin,'/api/publications/1','PUT',admin_edit)
    check(get_public(1)['name']=='Proposta corrigida','Admin save does not publish')
    check(approve(1,admin)[0]==200,'Explicit admin approval')
    # Novos cards, capacidade, acessos e isolamento.
    check(approve(9)[0]==200,'Approve initial pending business')
    payload={'name':'Nova oportunidade','service':'Reparos','category':'reformas','description':'Serviços locais','hours':'8h às 18h','mode':'A domicílio','services':['Reparo'],'whatsapp':'','instagram':''}
    created=request_ok(manager,'/api/publications','POST',payload,code=201)['id']
    check(get_public(created) is None,'New business never auto-publishes')
    request_ok(manager,f'/api/publications/{created}/commercial','POST',{'mensalidade_centavos':12345,'dias_periodo':30})
    request_ok(manager,'/api/access','POST',{'publicationId':created,'name':'Empresa nova','email':'nova@portal.local','password':'AcessoSeguro123!'},code=201)
    check(approve(created)[0]==200,'Approve tenth published business')
    extra=request_ok(manager,'/api/publications','POST',payload,code=201)['id']
    check(approve(extra)[0]==422,'Primeira aprovação exige mensalidade')
    request_ok(manager,f'/api/publications/{extra}/commercial','POST',{'mensalidade_centavos':6789,'dias_periodo':30})
    request_ok(manager,'/api/access','POST',{'publicationId':extra,'name':'Extra','email':'extra@portal.local','password':'AcessoSeguro123!'},code=409)
    new_owner=Client('cgi');check(new_owner.login('nova@portal.local','AcessoSeguro123!')[0]==200,'Created owner login')
    mine=request_ok(new_owner,'/api/publications?scope=mine')['publications'];check(len(mine)==1 and mine[0]['id']==created,'New owner restricted to own card')
    request_ok(new_owner,'/api/publications/1','PUT',payload,code=403)
    request_ok(manager,'/api/admin/portals',code=403)
    check(len(request_ok(admin,'/api/admin/portals')['portals'])==2,'Admin accesses all portals')
    request_ok(admin,'/api/admin/portals','POST',{'name':'Novo Bairro','organization':'Nova gestão','slug':'novo-bairro','capacity':50},code=201)
    request_ok(admin,'/api/admin/portals/1/capacity','POST',{'capacity':50})
    request_ok(manager,f'/api/publications/{extra}/commercial','POST',{'mensalidade_centavos':6789,'dias_periodo':30})
    request_ok(manager,'/api/access','POST',{'publicationId':extra,'name':'Extra','email':'extra@portal.local','password':'AcessoSeguro123!'},code=201)
    check(approve(extra)[0]==200,'Approve after upgrade')
    request_ok(admin,'/api/admin/portals/1/capacity','POST',{'capacity':10},code=409)
    request_ok(manager,'/api/publications/10/review?portal=outro-bairro',code=403)
    request_ok(manager,'/api/publications/10/review',code=404)
    request_ok(advertiser,'/api/password','POST',{'current':password,'new':'SenhaNovaSegura123!'})
    request_ok(manager,'/api/audit',code=403)
    request_ok(admin,'/api/admin/audit')

    request_ok(manager,'/api/identity','POST',{'name':'Vitrine','cor_principal':'#FFFFFF','cor_texto':'#000000','fonte':'Arial','logotipo':''})
    request_ok(advertiser,'/api/identity','POST',{'name':'Vitrine','cor_principal':'#7C3AED','logotipo':''},code=403)
    # Aceites PRD: dados comerciais privados, pagamento separado, links únicos.
    check('mensalidade_centavos' not in get_public(1),'Público não recebe dados comerciais')
    request_ok(advertiser,'/api/publications/1/commercial','POST',{'mensalidade_centavos':1,'dias_periodo':30},code=403)
    request_ok(manager,'/api/publications/1/status','POST',{'status':'suspended'},code=422)
    request_ok(manager,'/api/publications/1/status','POST',{'status':'suspended','motivo':'Atraso de pagamento.'})
    request_ok(admin,'/api/admin/portals/1/capacity','POST',{'capacity':10},code=409)
    request_ok(manager,'/api/publications/1/status','POST',{'status':'published'})
    request_ok(manager,f'/api/publications/{created}/renew','POST',{'inicio_em':'2030-01-01','fim_em':'2030-01-30'})
    request_ok(manager,f'/api/publications/{created}/renew','POST',{'inicio_em':'2030-01-01','fim_em':'2030-01-30'},code=409)
    bills=request_ok(new_owner,'/api/charges')['charges']
    check(len(bills)==2 and all(int(c['publication_id'])==created for c in bills),'Empresa só vê suas cobranças')
    charge=bills[0]['id'];request_ok(manager,f'/api/charges/{charge}/paid','POST',{})
    request_ok(manager,f'/api/charges/{charge}/paid','POST',{})
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        check(conn.execute('SELECT COUNT(*) FROM pagamentos WHERE id_cobranca=?',(charge,)).fetchone()[0]==1,'Baixa idempotente')
        check(conn.execute('SELECT COUNT(*) FROM periodos_publicacao WHERE id_anuncio=?',(created,)).fetchone()[0]==2,'Primeiro período e renovação, sem duplicidade')
    request_ok(advertiser,'/api/publications/2/invite','POST',{'email':'cliente@example.test'},code=403)
    request_ok(advertiser,'/api/publications/1/invite','POST',{'email':'cliente@example.test'})
    request_ok(advertiser,'/api/publications/1/invite','POST',{'email':'cliente@example.test'},code=409)
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        message=conn.execute('SELECT mensagem FROM fila_emails ORDER BY id DESC LIMIT 1').fetchone()[0]
    token=re.search(r'token=([a-f0-9]{64})',message)[1]
    request_ok(guest,'/api/rating/'+token)
    request_ok(guest,'/api/rating/'+token,'POST',{'estrelas':6},code=422)
    request_ok(guest,'/api/rating/'+token,'POST',{'estrelas':5})
    request_ok(guest,'/api/rating/'+token,'POST',{'estrelas':1},code=410)
    request_ok(advertiser,'/api/publications/1/invite','POST',{'email':'CLIENTE@example.test'},code=409)
    check(get_public(1)['avaliacao']['quantidade']==1,'Avaliação real publicada sem e-mail')
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        conn.execute("UPDATE avaliacoes SET criado_em=datetime('now','-25 hours')");conn.commit()
    request_ok(advertiser,'/api/publications/1/invite','POST',{'email':'cliente@example.test'})
    request_ok(guest,'/api/publications/1/click','POST',{'canal':'whatsapp'})
    request_ok(guest,'/api/publications/1/click','POST',{'canal':'whatsapp'})
    reports=request_ok(advertiser,'/api/reports')['reports']
    check(len(reports)==1 and int(reports[0]['whatsapp'])==1,'Métricas isoladas e deduplicadas')
    request_ok(guest,'/api/recover','POST',{'email':'anunciante@portal.local'})
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        message=conn.execute('SELECT mensagem FROM fila_emails ORDER BY id DESC LIMIT 1').fetchone()[0]
    token=re.search(r'token=([a-f0-9]{64})',message)[1]
    request_ok(guest,'/api/reset','POST',{'token':token,'password':'NovaSenhaRecuperada!123'})
    request_ok(guest,'/api/reset','POST',{'token':token,'password':'OutraSenhaRecuperada!123'},code=410)
    # Capacidade de 20 e assinatura do gestor separada da mensalidade do anúncio.
    request_ok(admin,'/api/admin/portals/2/capacity','POST',{'capacity':20})
    request_ok(admin,'/api/admin/users','POST',{'name':'Gestor Dois','email':'gestor2@example.test','password':'SenhaSeguraGestor123!','role':'manager','portal_id':2,'valor_assinatura_centavos':20000},code=201)
    manager2=Client('cgi');check(manager2.login('gestor2@example.test','SenhaSeguraGestor123!')[0]==200,'Gestor novo entra')
    request_ok(manager2,'/api/publications?scope=manage',code=403)
    check(request_ok(manager2,'/api/charges?portal=outro-bairro')['charges']==[],'Gestor não recebe cobranças da plataforma no financeiro dos anunciantes')
    b2=request_ok(admin,'/api/admin/charges')['charges'][0]
    request_ok(manager2,f"/api/charges/{b2['id']}/paid?portal=outro-bairro",'POST',{},code=403)


    # Alterações da validação operacional.
    request_ok(admin,f'/api/publications/{created}/commercial','POST',{'mensalidade_centavos':1,'dias_periodo':30},code=403)
    master_view=request_ok(admin,'/api/publications?scope=manage')['publications']
    check(all('mensalidade_centavos' not in row for row in master_view),'Master não recebe mensalidades dos anunciantes')
    check(all(c['tipo_cobranca']=='plataforma' for c in request_ok(admin,'/api/charges')['charges']),'Master só consulta mensalidades da plataforma')
    request_ok(admin,f'/api/charges/{charge}/paid','POST',{},code=403)
    user_rows=request_ok(manager,'/api/users')['users']
    check(all('senha_hash' not in row and 'password' not in row for row in user_rows),'Gestor não visualiza senhas')
    check(all(row['email'] not in ['admin@portal.local','gestor2@example.test'] for row in user_rows),'Gestor não recebe master ou outro gestor')
    request_ok(manager,'/api/users/4','PUT',{'acao':'situacao','ativo':0},code=404)
    request_ok(manager2,'/api/users/3?portal=outro-bairro','PUT',{'acao':'situacao','ativo':0},code=404)
    request_ok(manager,'/api/users/3','PUT',{'acao':'situacao','ativo':0})
    blocked_owner=Client('cgi');check(blocked_owner.login('anunciante@portal.local','NovaSenhaRecuperada!123')[0]==403,'Vínculo inativo impede login')
    request_ok(manager,'/api/users/3','PUT',{'acao':'situacao','ativo':1})
    request_ok(manager,'/api/users/3','PUT',{'acao':'senha_provisoria','password':'ProvisoriaSegura123!'})
    check(blocked_owner.login('anunciante@portal.local','ProvisoriaSegura123!')[0]==200,'Gestor define senha provisória do próprio anunciante')
    request_ok(manager,'/api/users/3','PUT',{'acao':'redefinir'})
    request_ok(blocked_owner,'/api/users',code=403)
    schedules=request_ok(manager,'/api/schedules?scope=manage')['schedules']
    request_ok(manager,'/api/schedules','POST',{'dias_semana':[1,3,5],'hora_inicio':'09:00','hora_fim':'17:00'})
    request_ok(manager,'/api/schedules','POST',{'dias_semana':[1],'hora_inicio':'18:00','hora_fim':'08:00'},code=422)
    added=request_ok(manager,'/api/schedules?scope=manage')['schedules'][-1]
    request_ok(blocked_owner,'/api/schedules','POST',{'dias_semana':[1],'hora_inicio':'09:00','hora_fim':'17:00'},code=403)
    request_ok(manager2,f"/api/schedules/{added['id']}?portal=outro-bairro",'PUT',{'ativo':0},code=404)
    invalid_hours={**get_public(1),'hours':'Qualquer horário aleatório'}
    request_ok(blocked_owner,'/api/publications/1','PUT',invalid_hours,code=422)
    selected_hours={**get_public(1),'hours':added['descricao']}
    request_ok(blocked_owner,'/api/publications/1','PUT',selected_hours)
    snapshot_hours=proposal(1)['proposed']['hours']
    request_ok(manager,f"/api/schedules/{added['id']}",'PUT',{'dias_semana':[1,3,5],'hora_inicio':'10:00','hora_fim':'16:00'})
    check(approve(1)[0]==200 and get_public(1)['hours']==snapshot_hours,'Alterar padrão não muda retrato da proposta aprovada')
    request_ok(admin,'/api/admin/portals','POST',{'name':'Vitrine Antonil','organization':'Condomínio Antonil','endereco_local':'Rua Antonil, 46','capacity':20},code=201)
    added_portal=request_ok(admin,'/api/admin/portals')['portals'][-1]
    check(added_portal['endereco_local']=='Rua Antonil, 46' and added_portal['slug']=='vitrine-antonil','Endereço físico preservado e link gerado automaticamente')

    # Edição administrativa, responsável privado e alteração de e-mail protegida.
    portals=request_ok(admin,'/api/admin/portals')['portals']
    check(any(u['email']=='gestor@portal.local' for u in portals[0]['responsaveis']),'Portal mostra gestor responsável')
    private=request_ok(manager,'/api/publications?scope=manage')['publications']
    check(any(u['email']=='anunciante@portal.local' for b in private for u in b['responsaveis']),'Listagem privada mostra responsáveis')
    check(all('responsaveis' not in b for b in request_ok(guest,'/api/publications')['publications']),'Listagem pública não expõe login dos responsáveis')
    pid=added_portal['id'];edit_portal={'name':'Vitrine Atualizada','organization':'Organização Atualizada','endereco_local':'Rua Antonil, 46','capacity':20,'active':0}
    request_ok(manager,f'/api/admin/portals/{pid}','PUT',edit_portal,code=403)
    request_ok(admin,f'/api/admin/portals/{pid}','PUT',edit_portal)
    updated=next(p for p in request_ok(admin,'/api/admin/portals')['portals'] if p['id']==pid)
    check(updated['name']=='Vitrine Atualizada' and updated['slug']==added_portal['slug'] and updated['active']==0,'Editar preserva link e altera situação do portal')
    request_ok(admin,f'/api/admin/portals/{pid}','PUT',{**edit_portal,'active':1})
    request_ok(admin,'/api/admin/portals/1','PUT',{**edit_portal,'capacity':1},code=409)
    target=next(u for u in request_ok(admin,'/api/admin/users')['users'] if u['email']=='gestor2@example.test')
    request_ok(admin,f"/api/admin/users/{target['id']}",'PUT',{'name':'Gestor Atualizado','email':'gestor2-novo@example.test','active':1})
    changed=Client('cgi');check(changed.login('gestor2-novo@example.test','SenhaSeguraGestor123!')[0]==200,'Gestor entra com e-mail editado pelo master')
    request_ok(manager,'/api/users/3','PUT',{'acao':'email','email':'master@portal.local'},code=409)
    request_ok(manager2,'/api/users/3?portal=outro-bairro','PUT',{'acao':'email','email':'nao@example.test'},code=404)
    request_ok(manager,'/api/users/3','PUT',{'acao':'email','email':'anunciante-novo@example.test'})
    check(blocked_owner.login('anunciante-novo@example.test','ProvisoriaSegura123!')[0]==200,'Anunciante entra com e-mail alterado pelo gestor')
    request_ok(blocked_owner,'/api/account','PUT',{'email':'conta@example.test','current':'incorreta'},code=403)
    request_ok(blocked_owner,'/api/account','PUT',{'email':'master@portal.local','current':'ProvisoriaSegura123!'},code=409)
    request_ok(blocked_owner,'/api/account','PUT',{'email':'conta@example.test','current':'ProvisoriaSegura123!'})
    check(request_ok(blocked_owner,'/api/session')['user']['email']=='conta@example.test','Minha conta atualiza email e preserva sessão autenticada')
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        check(conn.execute('SELECT COUNT(*) FROM tokens_acesso WHERE id_usuario=3 AND utilizado_em IS NULL').fetchone()[0]==0,'Troca de e-mail invalida links antigos de senha')

    # Conta única: preservar senha em branco e alterar somente quando solicitado.
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:before=conn.execute('SELECT password_hash FROM users WHERE id=3').fetchone()[0]
    request_ok(blocked_owner,'/api/account','PUT',{'email':'conta@example.test','current':'ProvisoriaSegura123!','new':''})
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:check(conn.execute('SELECT password_hash FROM users WHERE id=3').fetchone()[0]==before,'Senha vazia preserva hash existente')
    request_ok(blocked_owner,'/api/account','PUT',{'email':'conta2@example.test','current':'ProvisoriaSegura123!','new':'NovaSenhaUnificada123!'})
    check(request_ok(blocked_owner,'/api/session')['user']['email']=='conta2@example.test','Conta única preserva sessão depois da nova senha')
    check(Client('cgi').login('conta2@example.test','NovaSenhaUnificada123!')[0]==200,'Nova senha e email funcionam juntos')
    request_ok(guest,'/api/admin/email-settings',code=401)
    request_ok(manager,'/api/admin/email-settings',code=403)
    smtp={'servidor':'127.0.0.1','porta':465,'seguranca':'ssl','usuario':'conta@example.test','senha':'SenhaSmtpApenasTeste!','remetente_email':'portal@example.test','remetente_nome':'Portal teste','ativo':0}
    request_ok(admin,'/api/admin/email-settings','PUT',{**smtp,'servidor':'https://errado.test'},code=422)
    request_ok(admin,'/api/admin/email-settings','PUT',smtp)
    settings=request_ok(admin,'/api/admin/email-settings')['settings'];check(settings['senha_definida'] and 'senha' not in settings and 'senha_cifrada' not in settings,'SMTP não devolve senha ao navegador')
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:cipher=conn.execute('SELECT senha_cifrada FROM configuracoes_email').fetchone()[0];check('SenhaSmtpApenasTeste!' not in cipher,'Credencial SMTP cifrada no banco')
    request_ok(admin,'/api/admin/email-settings','PUT',{**smtp,'senha':''})
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:check(conn.execute('SELECT senha_cifrada FROM configuracoes_email').fetchone()[0]==cipher,'Senha SMTP vazia preserva credencial')
    result=request_ok(admin,'/api/admin/email-test','POST',{'email':'teste@example.test'});check(result['email_delivery']['status']=='pendente','Envio desativado informa pendência sem falso sucesso')
    with socket.socket() as sock:sock.bind(('127.0.0.1',0));closed_port=sock.getsockname()[1]
    request_ok(admin,'/api/admin/email-settings','PUT',{**smtp,'porta':closed_port,'seguranca':'nenhuma','usuario':'','senha':'','ativo':1})
    result=request_ok(admin,'/api/admin/email-test','POST',{'email':'teste@example.test'});check(result['email_delivery']['status']=='falha','Falha SMTP é apresentada sem desfazer cadastro')
    known=request_ok(guest,'/api/recover','POST',{'email':'conta2@example.test'});unknown=request_ok(guest,'/api/recover','POST',{'email':'ausente@example.test'});check(known==unknown,'Aviso público de recuperação não revela existência da conta')

    request_ok(manager,'/api/logout','POST')
    request_ok(manager,'/api/publications?scope=manage',code=401)
    with closing(sqlite3.connect(temp/'test.sqlite',factory=ConexaoPortugues)) as conn:
        check(conn.execute("SELECT COUNT(*) FROM publication_revisions WHERE status='approved'").fetchone()[0]>=7,'Review history persisted')
        check(conn.execute("SELECT COUNT(*) FROM audit_logs WHERE action='catalog.approved'").fetchone()[0]>=7,'Approval audit persisted')
    for path in ['/','/admin','/gestor','/anunciantes','/p/vila-esperanca']:
        request_ok(guest,path)
    print(f'PASS: {checks} verificações CodeIgniter/CGI: aprovação, isolamento, admin/1234, versão pública, imagens e concorrência otimista.')
