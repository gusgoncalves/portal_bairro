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


test_root = (ROOT / 'writable' / 'test-runs').resolve()
assert test_root.is_relative_to(ROOT.resolve())
test_root.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='portal-tests-', dir=test_root) as temporary:
    temp = Path(temporary)
    env = {**os.environ, 'CI_ENVIRONMENT':'development', 'PORTAL_TEST_DB':str(temp/'test.sqlite'), 'PORTAL_TEST_UPLOAD_PATH':str(temp/'uploads'), 'session.savePath':str(temp), 'app.baseURL':'http://localhost/', 'session.cookieName':'portal_ci_session'}
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
    with closing(sqlite3.connect(temp/'test.sqlite')) as conn:
        conn.executescript(schema)
        conn.execute("INSERT INTO organizations(id,name) VALUES(1,'Gestão Vila Esperança')")
        conn.execute("INSERT INTO portals(id,organization_id,slug,name,capacity) VALUES(1,1,'vila-esperanca','Vila Esperança',10)")
        for b in json.loads((ROOT/'database/seed.json').read_text(encoding='utf-8')):
            conn.execute('INSERT INTO advertisers(id,name) VALUES(?,?)',(b['id'],b['name']))
            conn.execute('INSERT INTO publications(id,portal_id,advertiser_id,name,category,service,description,tags,color,accent,type,mode,hours,services,status) VALUES(?,1,?,?,?,?,?,?,?,?,?,?,?,?,?)',(b['id'],b['id'],b['name'],b['category'],b['service'],b['description'],b['tags'],b['color'],b['accent'],b['type'],b['mode'],b['hours'],json.dumps(b['services']),b['status']))
        for i,(name,email,role,advertiser) in enumerate([('Master','master@portal.local','master',None),('Gestor','gestor@portal.local','manager',None),('Anunciante','anunciante@portal.local','advertiser',1)],1):
            conn.execute('INSERT INTO users(id,name,email,password_hash,role,advertiser_id) VALUES(?,?,?,?,?,?)',(i,name,email,hashed,role,advertiser))
            conn.execute('INSERT INTO memberships VALUES(?,1)',(i,))
        conn.execute("INSERT INTO organizations(id,name) VALUES(2,'Outra organização')")
        conn.execute("INSERT INTO portals(id,organization_id,slug,name,capacity) VALUES(2,2,'outro-bairro','Outro Bairro',10)")
        conn.execute("INSERT INTO publications(portal_id,advertiser_id,name,category,service,description,mode,hours,services,status) VALUES(2,1,'Outro portal','reformas','Reparos','Teste','A domicílio','8h','[\"Reparos\"]','pending')")
        conn.commit()
    guest = Client('cgi')
    check(guest.request('/api/publications?scope=manage')[0] == 401, 'Guest management must be blocked')
    code, data = guest.request('/api/publications')
    check(code == 200 and len(data['publications']) == 8, 'Only published profiles public')
    check(all(b['status'] == 'published' for b in data['publications']), 'No pending data leak')
    for path in ['/storage/portal.sqlite', '/storage/ACESSOS_LOCAIS.txt', '/backend/api.php', '/database/seed.json', '/README.md', '/bin/setup.php', '/storage/extract-seed.cjs']:
        check(guest.request(path)[0] == 404, 'Private file leaked: ' + path)
    check(guest.request('/api/login', 'POST', {'email': 'gestor@portal.local', 'password': 'invalid'}, csrf=False)[0] == 403, 'CSRF required for login')
    check(guest.login('gestor@portal.local','incorrect')[0]==401,'Wrong credentials rejected')
    manager = Client('cgi')
    check(manager.login('gestor@portal.local', credentials['gestor@portal.local'])[0] == 200, 'Manager login')
    check(manager.request('/api/publications?scope=manage')[0] == 200, 'Manager access')
    check(manager.request('/api/admin/portals')[0] == 403, 'Manager cannot access master')
    check(manager.request('/api/publications?scope=manage&portal=outro-bairro')[0] == 403, 'Cross portal read denied')
    check(manager.request('/api/publications/10/status?portal=outro-bairro', 'POST', {'status': 'published'})[0] == 403, 'Cross portal write denied')
    check(manager.request('/api/publications/10/status', 'POST', {'status': 'published'})[0] == 404, 'Foreign publication ID denied')
    check(manager.request('/api/publications/1/status', 'POST', {'status': 'suspended'}, csrf=False)[0] == 403, 'CSRF required for writes')
    check(manager.request('/api/publications/1/status', 'POST', {'status': 'suspended'})[0] == 200, 'Suspension persisted')
    check(len(guest.request('/api/publications')[1]['publications']) == 7, 'Suspended publication hidden')
    check(manager.request('/api/publications/1/status', 'POST', {'status': 'published'})[0] == 200, 'Reactivation')
    check(manager.request('/api/publications/9/status', 'POST', {'status': 'published'})[0] == 200, 'Approval')
    payload = {'name':'Teste de persistência','service':'Reparos','category':'reformas','description':'Descrição autorizada','hours':'8h às 18h','mode':'A domicílio','tags':'teste','art':'','services':['Reparo']}
    code, created = manager.request('/api/publications', 'POST', payload)
    check(code == 201, 'Create pending profile')
    first = created['id']
    check(manager.request(f'/api/publications/{first}/status', 'POST', {'status':'published'})[0] == 200, 'Tenth slot')
    second = manager.request('/api/publications', 'POST', payload)[1]['id']
    check(manager.request(f'/api/publications/{second}/status', 'POST', {'status':'published'})[0] == 409, 'Eleventh slot blocked')
    check(len(guest.request('/api/publications')[1]['publications']) == 10, 'Capacity maintained')
    payload['name'] = 'Nome atualizado'
    check(manager.request(f'/api/publications/{first}', 'PUT', payload)[0] == 200, 'Edit persisted')
    payload['art'] = 'artes/../../storage/secret.svg'
    payload['instagram']='https://malicioso.example/test';check(manager.request(f'/api/publications/{first}', 'PUT', payload)[0] == 422, 'Unsafe social URL rejected');payload['instagram']=''
    advertiser = Client('cgi')
    check(advertiser.login('anunciante@portal.local', credentials['anunciante@portal.local'])[0] == 200, 'Advertiser login')
    mine = advertiser.request('/api/publications?scope=mine')[1]['publications']
    check(len(mine) == 1 and mine[0]['id'] == 1, 'Advertiser sees own publication only')
    check(advertiser.request('/api/publications?scope=manage')[0] == 403, 'Advertiser cannot manage')
    check(advertiser.request('/api/publications/1/status', 'POST', {'status':'suspended'})[0] == 403, 'Advertiser cannot approve')
    master = Client('cgi')
    check(master.login('master@portal.local', credentials['master@portal.local'])[0] == 200, 'Master login')
    check(len(master.request('/api/admin/portals')[1]['portals']) == 2, 'Master sees portals')
    # Contatos normalizados e edição do anunciante restrita ao próprio catálogo.
    own={'name':'Empresa do anunciante','service':'Manutenção','category':'reformas','description':'Divulgação de serviços','hours':'8h às 18h','mode':'A domicílio','tags':'local','services':['Reparos'],'area':'Vila Esperança','address':'','whatsapp':'+55 (42) 99999-9999','instagram':'https://www.instagram.com/empresa.local/'}
    check(advertiser.request('/api/publications/1','PUT',own)[0]==200,'Advertiser edits own catalog')
    check(advertiser.request('/api/publications/2','PUT',own)[0]==403,'Advertiser cannot edit another catalog')
    actual=next(b for b in guest.request('/api/publications')[1]['publications'] if b['id']==1)
    check(actual['whatsapp']=='5542999999999' and actual['instagram']=='empresa.local','Contact normalization')
    png=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jWRkAAAAASUVORK5CYII=')
    image=('fachada.png',png,'image/png')
    code,result=advertiser.request('/api/publications/1/images','POST',files=[image,image,image])
    check(code==201,'Three real multipart uploads: '+str(result))
    check(len(result['publication']['images'])==3,'Three image records')
    image_id=result['publication']['images'][0]['id']
    check(guest.request('/media/'+str(image_id))[0]==200,'Published media public')
    check(advertiser.request('/api/publications/1/images','POST',files=[image])[0]==409,'Fourth image rejected')
    check(advertiser.request('/api/publications/2/images','POST',files=[image])[0]==403,'Upload to another advertiser denied')
    check(advertiser.request('/api/publications/1/images/'+str(image_id),'DELETE')[0]==200,'Owner removes image')
    check(guest.request('/media/'+str(image_id))[0]==404,'Deleted media gone')
    check(advertiser.request('/api/publications/1/images','POST',files=[('fake.png',b'not an image','image/png')])[0]==422,'Spoofed image rejected')
    check(advertiser.request('/api/publications/1/images','POST',files=[('script.svg',b'<svg/>','image/svg+xml')])[0]==422,'SVG rejected')
    check(advertiser.request('/api/publications/1/images','POST',files=[image])[0]==201,'Vacant slot reusable')
    image_id=advertiser.request('/api/publications?scope=mine')[1]['publications'][0]['images'][0]['id']
    check(manager.request('/api/publications/1/status','POST',{'status':'suspended'})[0]==200,'Suspend image owner')
    check(guest.request('/media/'+str(image_id))[0]==404,'Unpublished media private')
    check(advertiser.request('/media/'+str(image_id))[0]==200,'Owner may preview private media')
    check(manager.request('/api/publications/1/status','POST',{'status':'published'})[0]==200,'Re-publish')
    # Administração e redução de capacidade.
    check(master.request('/api/admin/portals','POST',{'name':'Novo Bairro','organization':'Nova gestão','slug':'novo-bairro','capacity':50})[0]==201,'Master creates portal')
    check(manager.request('/api/admin/portals','POST',{'name':'Negado'})[0]==403,'Manager cannot create portal')
    check(master.request('/api/admin/portals/1/capacity','POST',{'capacity':50})[0]==200,'Upgrade capacity')
    check(manager.request(f'/api/publications/{second}/status','POST',{'status':'published'})[0]==200,'Capacity upgrade used')
    check(master.request('/api/admin/portals/1/capacity','POST',{'capacity':10})[0]==409,'Unsafe downgrade blocked')
    check(manager.request('/api/access','POST',{'publicationId':first,'name':'Novo anunciante','email':'novo@portal.local','password':'AcessoSeguro123!'})[0]==201,'Manager creates advertiser access')
    newcomer=Client('cgi')
    check(newcomer.login('novo@portal.local','AcessoSeguro123!')[0]==200,'Created advertiser can log in')
    check(newcomer.request('/api/publications?scope=mine')[1]['publications'][0]['id']==first,'Created access scoped')
    check(master.request('/api/admin/users','POST',{'name':'Outro gestor','email':'gestor2@portal.local','password':'AcessoSeguro123!','role':'manager','portal_id':2})[0]==201,'Master creates manager')
    other=Client('cgi');check(other.login('gestor2@portal.local','AcessoSeguro123!')[0]==200,'New manager login')
    check(other.request('/api/publications?scope=manage')[0]==403,'New manager isolated')
    charge=manager.request('/api/charges','POST',{'description':'Mensalidade','amount_cents':2500,'due_date':'2026-11-10','publication_id':first})
    check(charge[0]==201,'Manual charge created')
    check(advertiser.request('/api/charges')[0]==403,'Advertiser cannot see all charges')
    check(manager.request('/api/charges/'+str(charge[1]['id'])+'/paid','POST',{})[0]==200,'Manual payment recorded')
    check(manager.request('/api/charges')[1]['charges'][0]['paid_at'] is not None,'Payment persistence')
    check(manager.request('/api/audit')[0]==200,'Audit readable by manager')
    check(advertiser.request('/api/password','POST',{'current':password,'new':'SenhaNovaSegura123!'})[0]==200,'Own password change')
    check(manager.request('/api/logout', 'POST')[0] == 200, 'Logout')
    check(manager.request('/api/publications?scope=manage')[0] == 401, 'Session ended')
    throttled = Client('cgi')
    throttled.request('/api/session')
    for _ in range(5):
        throttled.request('/api/login','POST',{'email':'missing@portal.local','password':'incorrect'})
    check(throttled.request('/api/login','POST',{'email':'missing@portal.local','password':'incorrect'})[0] == 429, 'Login rate limit')
    with closing(sqlite3.connect(temp / 'test.sqlite')) as conn:
        check(conn.execute('SELECT COUNT(*) FROM audit_logs').fetchone()[0] >= 7, 'Audit writes')
        check(conn.execute('SELECT name FROM publications WHERE id=?',(first,)).fetchone()[0] == 'Nome atualizado', 'Database persistence')
    for path in ['/', '/gestor', '/gestor/editar/1', '/anunciantes', '/admin']:
        check(guest.request(path)[0] == 200, 'Clean route: ' + path)
    print(f'PASS: {checks} verificações CGI/banco, incluindo autorização, isolamento, CSRF, capacidade e persistência.')
