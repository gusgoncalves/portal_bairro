"""Smoke HTTP de leitura contra o MySQL real. Não cria nem publica anúncios."""
from pathlib import Path
import subprocess,os,socket,time,urllib.request,urllib.error,json,http.cookiejar
ROOT=Path(__file__).resolve().parents[1]
with socket.socket() as sock:
 sock.bind(('127.0.0.1',0));port=sock.getsockname()[1]
base=f'http://127.0.0.1:{port}'
env={**os.environ,'app.baseURL':base+'/'}
for key in ['PORTAL_TEST_DB','PORTAL_TEST_UPLOAD_PATH']:env.pop(key,None)
logpath=ROOT/'writable/test-runs/mysql-http.log';logpath.parent.mkdir(exist_ok=True)
with logpath.open('w',encoding='utf-8') as log:
 process=subprocess.Popen(['php','-d','auto_prepend_file='+str(ROOT/'tests/support/sandbox_fs.php'),'-S',f'127.0.0.1:{port}','-t','public',str(ROOT/'tests/support/http_router.php')],cwd=ROOT,env=env,stdout=log,stderr=log,creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
 opener=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
 def call(path,method='GET',data=None,token=''):
  request=urllib.request.Request(base+path,data=json.dumps(data).encode() if data is not None else None,method=method,headers={'Content-Type':'application/json','X-CSRF-Token':token})
  try:response=opener.open(request,timeout=10)
  except urllib.error.HTTPError as error:response=error
  payload=response.read();return response.status,json.loads(payload) if 'application/json' in response.headers.get('Content-Type','') else payload
 try:
  for attempt in range(30):
   try:status,session=call('/api/session');break
   except OSError:time.sleep(.1)
  assert status==200,session
  assert call('/')[0]==200
  assert call('/portal.js')[0]==200
  assert call('/portal.css')[0]==200
  assert call('/.env')[0]==404
  status,public=call('/api/publications');assert status==200,public
  status,auth=call('/api/login','POST',{'email':'admin','password':'1234'},session['csrf'])
  if status!=200:raise RuntimeError('A conta admin não aceitou a credencial inicial; nenhuma senha foi alterada.')
  token=auth['csrf'];status,managed=call('/api/publications?scope=manage');assert status==200,managed
  if managed['publications']:
   item=managed['publications'][0]
   before=call(f"/api/publications/{item['id']}/preview")[1]['publication']
   status,preview=call(f"/api/publications/{item['id']}/preview");assert status==200
   for image in preview['publication']['images']:assert call('/'+image['url'])[0]==200
   invalid={**item,'whatsapp':'123'}
   status,error=call(f"/api/publications/{item['id']}",'PUT',invalid,token);assert status==422 and 'whatsapp' in error['fields'],error
   after=call(f"/api/publications/{item['id']}/preview")[1]['publication']
   assert before==after,'A validação alterou uma proposta real.'
  assert call('/api/logout','POST',None,token)[0]==200
  print('PASS: HTTP real + MySQL português; login, vitrine e gestão; prévia/mídia/campos quando há anúncios; nenhum anúncio alterado.')
 finally:
  process.terminate();process.wait(timeout=10)
