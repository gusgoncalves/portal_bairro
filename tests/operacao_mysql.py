"""Migração e reativação de acesso legado em MySQL descartável."""
from pathlib import Path
import subprocess,os,secrets,json
ROOT=Path(__file__).resolve().parents[1];hidden=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0;name='portal_prd_teste_'+secrets.token_hex(5)
def helper(action):return subprocess.run(['php','tests/support/mysql_test_database.php',action,name],cwd=ROOT,check=True,capture_output=True,text=True,creationflags=hidden).stdout
helper('create');env={**os.environ,'database.default.database':name}
def install():
 result=subprocess.run(['php','-d','auto_prepend_file=tests/support/sandbox_fs.php','spark','portal:install'],cwd=ROOT,env=env,check=True,capture_output=True,text=True,creationflags=hidden)
 assert 'não concluída' not in result.stdout,result.stdout
try:
 install();helper('legacy-access');install()
 assert json.loads(helper('legacy-check'))=={'ativo':1,'vinculos':[0,0]}
 subprocess.run(['php','tests/support/operacao_worker.php',name],cwd=ROOT,check=True,capture_output=True,creationflags=hidden)
 assert json.loads(helper('legacy-check'))=={'ativo':1,'vinculos':[1,0]}
 install();assert json.loads(helper('legacy-check'))=={'ativo':1,'vinculos':[1,0]}
 print('PASS: migração preserva bloqueios antigos; gestor reativa só sua vitrine; reinstalação idempotente.')
finally:helper('drop')
