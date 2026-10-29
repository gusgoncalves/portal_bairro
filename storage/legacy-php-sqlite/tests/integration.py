"""Integração HTTP com banco temporário: não modifica o banco de trabalho."""
from contextlib import closing
import re
import shutil
import urllib.parse
import json
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

    def request(self, path, method='GET', data=None, csrf=True):
        parsed = urllib.parse.urlsplit(path)
        payload = json.dumps(data).encode() if data is not None else b''
        script = 'backend/api.php' if parsed.path.startswith('/api/') else 'router.php'
        request_env = {**env, 'REDIRECT_STATUS':'1', 'REQUEST_METHOD':method,
            'SCRIPT_FILENAME':str(ROOT / script), 'SCRIPT_NAME':'/' + script,
            'REQUEST_URI':path, 'QUERY_STRING':parsed.query, 'CONTENT_TYPE':'application/json',
            'CONTENT_LENGTH':str(len(payload)), 'SERVER_NAME':'localhost', 'HTTP_HOST':'localhost',
            'SERVER_PROTOCOL':'HTTP/1.1', 'REMOTE_ADDR':'127.0.0.1', 'HTTP_COOKIE':self.cookie,
            'HTTP_X_CSRF_TOKEN':self.csrf if csrf else ''}
        response = subprocess.run([shutil.which('php-cgi'), '-d', 'session.save_path='+str(temp), '-d', 'cgi.force_redirect=0'], input=payload, env=request_env, cwd=ROOT, capture_output=True, check=True, creationflags=hidden)
        raw = response.stdout.decode()
        headers, content = raw.split('\r\n\r\n',1)
        status = re.search(r'^Status: (\d+)', headers, re.M)
        code = int(status.group(1)) if status else 200
        cookie = re.search(r'^Set-Cookie: (portal_session=[^;\r\n]+)', headers, re.M)
        if cookie:
            self.cookie = cookie.group(1)
        result = json.loads(content) if 'application/json' in headers else content
        if isinstance(result, dict) and 'csrf' in result:
            self.csrf = result['csrf']
        return code, result

    def login(self, email, password):
        self.request('/api/session')
        return self.request('/api/login', 'POST', {'email': email, 'password': password})


test_root = (ROOT / 'storage' / 'test-runs').resolve()
assert test_root.is_relative_to(ROOT.resolve())
test_root.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='portal-tests-', dir=test_root) as temporary:
    temp = Path(temporary)
    env = {**os.environ, 'PORTAL_DB_PATH': str(temp / 'test.sqlite')}
    hidden = subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
    subprocess.run(['php', 'bin/setup.php'], cwd=ROOT, env=env, check=True, stdout=subprocess.DEVNULL, creationflags=hidden)
    credentials = {}
    lines = (temp / 'ACESSOS_LOCAIS.txt').read_text(encoding='utf-8').splitlines()
    for index, line in enumerate(lines):
        if line.startswith('E-mail: '):
            credentials[line[8:]] = lines[index + 1][7:]
    with closing(sqlite3.connect(temp / 'test.sqlite')) as conn:
        conn.execute("INSERT INTO organizations VALUES(2,'Outra organização')")
        conn.execute("INSERT INTO portals VALUES(2,2,'outro-bairro','Outro Bairro',10)")
        conn.execute("INSERT INTO publications(portal_id,advertiser_id,name,category,service,description,mode,hours,services,status) VALUES(2,1,'Privado em outro portal','reformas','Reparos','Teste','A domicílio','8h','[\"Reparos\"]','pending')")
        conn.commit()
    guest = Client('cgi')
    check(guest.request('/api/publications?scope=manage')[0] == 401, 'Guest management must be blocked')
    code, data = guest.request('/api/publications')
    check(code == 200 and len(data['publications']) == 8, 'Only published profiles public')
    check(all(b['status'] == 'published' for b in data['publications']), 'No pending data leak')
    for path in ['/storage/portal.sqlite', '/storage/ACESSOS_LOCAIS.txt', '/backend/api.php', '/database/seed.json', '/README.md', '/bin/setup.php', '/storage/extract-seed.cjs']:
        check(guest.request(path)[0] == 404, 'Private file leaked: ' + path)
    check(guest.request('/api/login', 'POST', {'email': 'gestor@portal.local', 'password': 'invalid'}, csrf=False)[0] == 419, 'CSRF required for login')
    check(guest.login('gestor@portal.local', 'incorrect')[0] == 401, 'Wrong credentials rejected')
    manager = Client('cgi')
    check(manager.login('gestor@portal.local', credentials['gestor@portal.local'])[0] == 200, 'Manager login')
    check(manager.request('/api/publications?scope=manage')[0] == 200, 'Manager access')
    check(manager.request('/api/admin/portals')[0] == 403, 'Manager cannot access master')
    check(manager.request('/api/publications?scope=manage&portal=outro-bairro')[0] == 403, 'Cross portal read denied')
    check(manager.request('/api/publications/10/status?portal=outro-bairro', 'POST', {'status': 'published'})[0] == 403, 'Cross portal write denied')
    check(manager.request('/api/publications/10/status', 'POST', {'status': 'published'})[0] == 404, 'Foreign publication ID denied')
    check(manager.request('/api/publications/1/status', 'POST', {'status': 'suspended'}, csrf=False)[0] == 419, 'CSRF required for writes')
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
    check(manager.request(f'/api/publications/{first}', 'PUT', payload)[0] == 422, 'Unsafe art rejected')
    advertiser = Client('cgi')
    check(advertiser.login('anunciante@portal.local', credentials['anunciante@portal.local'])[0] == 200, 'Advertiser login')
    mine = advertiser.request('/api/publications?scope=mine')[1]['publications']
    check(len(mine) == 1 and mine[0]['id'] == 1, 'Advertiser sees own publication only')
    check(advertiser.request('/api/publications?scope=manage')[0] == 403, 'Advertiser cannot manage')
    check(advertiser.request('/api/publications/1/status', 'POST', {'status':'suspended'})[0] == 403, 'Advertiser cannot approve')
    master = Client('cgi')
    check(master.login('master@portal.local', credentials['master@portal.local'])[0] == 200, 'Master login')
    check(len(master.request('/api/admin/portals')[1]['portals']) == 2, 'Master sees portals')
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
