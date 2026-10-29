"""Envio SMTP para servidor local descartável; nenhum destinatário externo."""
import subprocess,os,secrets,socket,threading,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];hidden=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0
name='portal_prd_teste_'+secrets.token_hex(5)
def helper(action,extra=''):return subprocess.run(['php','tests/support/mysql_test_database.php',action,name,extra],cwd=ROOT,check=True,capture_output=True,text=True,creationflags=hidden).stdout
helper('create')
sock=socket.socket();sock.bind(('127.0.0.1',0));sock.listen(1);sock.settimeout(25);port=sock.getsockname()[1]
messages=[];failures=[]
def server():
 try:
  conn,_=sock.accept();f=conn.makefile('rwb',buffering=0);f.write(b'220 localhost test SMTP\r\n');body=False;data=[]
  while line:=f.readline():
   if body:
    if line==b'.\r\n':messages.append(b''.join(data));body=False;f.write(b'250 queued\r\n')
    else:data.append(line)
   elif line.upper().startswith((b'EHLO',b'HELO')):f.write(b'250 localhost\r\n')
   elif line.upper().startswith((b'MAIL',b'RCPT',b'RSET')):f.write(b'250 OK\r\n')
   elif line.upper().startswith(b'DATA'):body=True;f.write(b'354 Send data\r\n')
   elif line.upper().startswith(b'QUIT'):f.write(b'221 bye\r\n');break
   else:f.write(b'250 OK\r\n')
  conn.close()
 except Exception as error:failures.append(str(error))
thread=threading.Thread(target=server,daemon=True);thread.start()
env={**os.environ,'database.default.database':name,'email.SMTPHost':'127.0.0.1','email.SMTPPort':str(port),'email.SMTPUser':'','email.SMTPPass':'','email.SMTPCrypto':'','email.fromEmail':'portal@example.test'}
try:
 result=subprocess.run(['php','-d','auto_prepend_file=tests/support/sandbox_fs.php','spark','portal:install'],cwd=ROOT,env=env,capture_output=True,creationflags=hidden,check=True)
 assert json.loads(helper('inspect'))=={'usuarios':1,'anuncios':0}
 helper('smtp-config',str(port))
 result=subprocess.run(['php','-d','auto_prepend_file=tests/support/sandbox_fs.php','spark','portal:email-teste','cliente@example.test'],cwd=ROOT,env=env,capture_output=True,text=True,creationflags=hidden,timeout=15)
 assert result.returncode==0,(result.stdout,result.stderr)
 result=subprocess.run(['php','-d','auto_prepend_file=tests/support/sandbox_fs.php','spark','portal:emails'],cwd=ROOT,env=env,capture_output=True,text=True,creationflags=hidden,timeout=30)
 assert result.returncode==0 and '1 enviado(s), 0 falha(s)' in result.stdout,(result.stdout,result.stderr)
 thread.join(timeout=2)
 data=json.loads(helper('queue'));assert len(data)==1 and data[0]['situacao']=='enviado' and data[0]['mensagem'] is None,(data,result.stdout,result.stderr,failures)
 assert len(messages)==1
 print('PASS: fila SMTP enviada a servidor local, conteúdo removido após envio e base operacional intacta.')
finally:sock.close();helper('drop')
