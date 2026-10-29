"""Concorrência real entre processos PHP contra MySQL descartável."""
from pathlib import Path
import subprocess,os,secrets,json
ROOT=Path(__file__).resolve().parents[1];hidden=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0
name='portal_prd_teste_'+secrets.token_hex(5)
def helper(action):return subprocess.run(['php','tests/support/mysql_test_database.php',action,name],cwd=ROOT,check=True,capture_output=True,text=True,creationflags=hidden).stdout
helper('create')
try:
 env={**os.environ,'database.default.database':name}
 subprocess.run(['php','-d','auto_prepend_file=tests/support/sandbox_fs.php','spark','portal:install'],cwd=ROOT,env=env,check=True,capture_output=True,creationflags=hidden)
 assert json.loads(helper('inspect'))=={'usuarios':1,'anuncios':0}
 helper('fixture')
 def parallel(action,ids):
  workers=[subprocess.Popen(['php','tests/support/concorrencia_worker.php',name,action,str(i)],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,creationflags=hidden) for i in ids]
  out=[]
  for worker in workers:
   data,error=worker.communicate(timeout=15);assert worker.returncode==0,error.decode(errors='replace');out.append(json.loads(data)['status'])
  return sorted(out)
 assert parallel('ocupar',[1,2])==[200,409]
 assert parallel('avaliar',[1,1])==[200,410]
 assert parallel('avaliar',[2,2])==[409,409]
 assert parallel('pagar',[1,1])==[200,200]
 assert json.loads(helper('concurrency-check'))=={'ocupados':1,'pagamentos':1,'avaliacoes':1}
 print('PASS: concorrência MySQL real: última vaga única, convite único, intervalo por e-mail e pagamento idempotente.')
finally:helper('drop')
