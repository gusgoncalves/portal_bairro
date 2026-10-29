"""Conclui somente o repositório privado solicitado após autenticação oficial."""
from pathlib import Path
import subprocess,os,time,json
ROOT=Path(__file__).resolve().parents[1];GH=ROOT/'storage/tools/gh/gh.exe';GITDIR=ROOT/'storage/versionamento.git';STATUS=ROOT/'writable/test-runs/github-versionamento.json'
ENV={**os.environ,'GH_CONFIG_DIR':str(ROOT/'storage/github-auth'),'GH_HOST':'github.com','GIT_TERMINAL_PROMPT':'0','GCM_INTERACTIVE':'Never'}
FLAGS=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0
REPO='gusgoncalves/portal_bairro';URL='https://github.com/'+REPO+'.git'
def run(args,check=True):
 r=subprocess.run(args,cwd=ROOT,env=ENV,capture_output=True,text=True,timeout=60,creationflags=FLAGS)
 if check and r.returncode:raise RuntimeError('Falha no comando '+args[0]+' '+(' '.join(args[1:3])))
 return r
def gh(*args,check=True):return run([str(GH),*args],check)
def git(*args):return run(['git','--git-dir='+str(GITDIR),'--work-tree='+str(ROOT),'-c','credential.helper=','-c','credential.helper=!"'+str(GH).replace('\\','/')+'" auth git-credential',*args])
def record(state,**extra):STATUS.write_text(json.dumps({'status':state,**extra},ensure_ascii=False,indent=2),encoding='utf-8')
record('aguardando_autenticacao')
try:
 deadline=time.monotonic()+600
 while time.monotonic()<deadline:
  state=gh('auth','status','--hostname','github.com',check=False)
  if state.returncode==0:
   login=gh('api','user','--jq','.login',check=False)
   if login.returncode==0:break
  time.sleep(3)
 else:record('autenticacao_pendente');print('GitHub permanece pendente de autenticação.');raise SystemExit(0)
 if login.stdout.strip()!='gusgoncalves':raise RuntimeError('A conta autenticada difere de gusgoncalves; nada foi criado.')
 if git('status','--porcelain').stdout.strip():raise RuntimeError('Existem alterações sem commit; envio interrompido.')
 head=git('rev-parse','HEAD').stdout.strip()
 found=gh('api','repos/'+REPO,check=False)
 if found.returncode==0:
  repo=json.loads(found.stdout)
  if not repo['private']:raise RuntimeError('Já existe um repositório público com esse nome; nada foi enviado.')
  heads=git('ls-remote','--heads',URL).stdout.strip()
  if heads and not all(line.split()[0]==head for line in heads.splitlines()):raise RuntimeError('O repositório existente contém outro histórico; nada foi sobrescrito.')
 else:
  if '404' not in found.stderr:raise RuntimeError('Não foi possível conferir se o repositório existe.')
  gh('repo','create',REPO,'--private','--description','Portal do Bairro — vitrines de empresas, gestão local e aprovação de anúncios')
 repo=json.loads(gh('api','repos/'+REPO).stdout)
 if not repo['private']:raise RuntimeError('A privacidade do repositório não foi confirmada; envio interrompido.')
 remotes=git('remote').stdout.splitlines()
 if 'origin' not in remotes:git('remote','add','origin',URL)
 elif git('remote','get-url','origin').stdout.strip()!=URL:raise RuntimeError('Origin diferente do repositório solicitado; nada foi sobrescrito.')
 git('push','--set-upstream','origin','main')
 sha=json.loads(gh('api','repos/'+REPO+'/commits/main').stdout)['sha']
 if sha!=head:raise RuntimeError('Commit remoto não corresponde ao commit local.')
 record('concluido',url=repo['html_url'],privado=True,commit=head);print('Repositório privado verificado: '+repo['html_url'])
except Exception as error:record('pendente',motivo=str(error));print('GitHub pendente:',str(error));raise SystemExit(1)
