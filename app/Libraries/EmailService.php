<?php
namespace App\Libraries;
use App\Models\PortalRepository;
use PDO;
final class EmailService
{
 public static array $novos=[];
 public function __construct(private PortalRepository $repo){}
 private function row():?array {try{return $this->repo->db->query('SELECT * FROM configuracoes_email WHERE id=1')->fetch(PDO::FETCH_ASSOC)?:null;}catch(\PDOException){throw new BusinessException('Atualize o banco com o script de configurações de e-mail antes de configurar o SMTP.',503);}}
 private function master(array $u):void {if(($u['role']??'')!=='master')throw new BusinessException('Somente o administrador master pode configurar os e-mails.',403);}
 private function key():string {
  $path=WRITEPATH.'segredos';if(!is_dir($path)&&!@mkdir($path,0700,true)&&!is_dir($path))throw new \RuntimeException('Armazenamento privado indisponível.');
  $file=$path.'/smtp.key';$h=@fopen($file,'x+b');if($h){$key=random_bytes(32);if(fwrite($h,$key)!==32){fclose($h);throw new \RuntimeException('Chave privada não gravada.');}fclose($h);@chmod($file,0600);return $key;}
  $key=@file_get_contents($file);if(!is_string($key)||strlen($key)!==32)throw new \RuntimeException('Chave privada indisponível.');return $key;
 }
 private function encrypt(string $value):string {$iv=random_bytes(12);$tag='';$cipher=openssl_encrypt($value,'aes-256-gcm',$this->key(),OPENSSL_RAW_DATA,$iv,$tag);if($cipher===false)throw new \RuntimeException('Não foi possível proteger a senha.');return base64_encode($iv.$tag.$cipher);}
 private function decrypt(?string $value):string {if(!$value)return '';$raw=base64_decode($value,true);if($raw===false||strlen($raw)<28)throw new \RuntimeException('Credencial inválida.');$plain=openssl_decrypt(substr($raw,28),'aes-256-gcm',$this->key(),OPENSSL_RAW_DATA,substr($raw,0,12),substr($raw,12,16));if($plain===false)throw new \RuntimeException('Credencial indisponível.');return $plain;}
 public function get(array $u):array {$this->master($u);$r=$this->row();return $r?['servidor'=>$r['servidor'],'porta'=>(int)$r['porta'],'seguranca'=>$r['seguranca'],'usuario'=>$r['usuario'],'remetente_email'=>$r['remetente_email'],'remetente_nome'=>$r['remetente_nome'],'ativo'=>(int)$r['ativo'],'senha_definida'=>!empty($r['senha_cifrada'])]:['servidor'=>'','porta'=>465,'seguranca'=>'ssl','usuario'=>'','remetente_email'=>'','remetente_nome'=>'Portal do Bairro','ativo'=>1,'senha_definida'=>false];}
 public function save(array $u,array $d):void {
  $this->master($u);if(!function_exists('openssl_encrypt'))throw new BusinessException('Ative a extensão OpenSSL do PHP para proteger as credenciais SMTP.',503);$old=$this->row();$host=$d['servidor']??'';$port=$d['porta']??null;$security=$d['seguranca']??'';$login=$d['usuario']??'';$sender=$d['remetente_email']??'';$name=$d['remetente_nome']??'';$active=$d['ativo']??null;$password=$d['senha']??'';
  if(!is_string($host)||strlen($host)>250||!preg_match('/^[a-zA-Z0-9][a-zA-Z0-9.-]*$/D',$host))throw new BusinessException('Informe somente o nome do servidor SMTP.',422,['servidor'=>'Exemplo: mail.seudominio.com.br']);
  if(!is_int($port)||$port<1||$port>65535)throw new BusinessException('Porta inválida.',422,['porta'=>'Use de 1 a 65535.']);
  if(!in_array($security,['ssl','tls','nenhuma'],true))throw new BusinessException('Selecione a segurança da conexão.');
  if(!is_string($login)||strlen($login)>190||preg_match('/[\r\n]/',$login))throw new BusinessException('Usuário SMTP inválido.');
  if(!is_string($sender)||strlen($sender)>190||!filter_var($sender,FILTER_VALIDATE_EMAIL))throw new BusinessException('Remetente inválido.',422,['remetente_email'=>'Informe um e-mail válido.']);
  if(!is_string($name)||trim($name)===''||mb_strlen($name)>120||preg_match('/[\r\n]/',$name))throw new BusinessException('Nome do remetente inválido.');
  if(!is_int($active)||!in_array($active,[0,1],true))throw new BusinessException('Situação inválida.');
  if(!is_string($password)||strlen($password)>1000)throw new BusinessException('Senha inválida.');
  $cipher=$password!==''?$this->encrypt($password):($old['senha_cifrada']??null);
  if($login!==''&&!$cipher)throw new BusinessException('Informe a senha da caixa de e-mail.',422,['senha'=>'Preencha a senha SMTP.']);
  $this->repo->transaction(function()use($u,$old,$host,$port,$security,$login,$sender,$name,$active,$cipher){
   $values=[$host,$port,$security,$login,$cipher,mb_strtolower(trim($sender)),trim($name),$active,$u['id'],gmdate('Y-m-d H:i:s')];
   $sql=$old?'UPDATE configuracoes_email SET servidor=?,porta=?,seguranca=?,usuario=?,senha_cifrada=?,remetente_email=?,remetente_nome=?,ativo=?,atualizado_por=?,atualizado_em=? WHERE id=1':'INSERT INTO configuracoes_email(servidor,porta,seguranca,usuario,senha_cifrada,remetente_email,remetente_nome,ativo,atualizado_por,atualizado_em,id) VALUES(?,?,?,?,?,?,?,?,?,?,1)';
   $this->repo->db->prepare($sql)->execute($values);$this->repo->insert('audit_logs',['user_id'=>$u['id'],'action'=>'email.settings.changed']);
  });
 }
 public function process(?array $ids=null,int $limit=20):array {
  if($this->repo->db->inTransaction())throw new \LogicException('Envio somente após concluir a gravação.');
  try{$config=$this->row();}catch(BusinessException){$config=null;}
  if(!$config||!$config['ativo'])return ['status'=>'pendente','enviados'=>0,'falhas'=>0,'message'=>'Mensagem na fila. O master precisa configurar e ativar o envio de e-mails.'];
  $sent=0;$failed=0;
  for($i=0;$i<$limit;$i++){
   $m=$this->repo->transaction(function()use($ids){
    $sql="SELECT * FROM fila_emails WHERE situacao='pendente' AND tentativas<5 AND (proxima_tentativa_em IS NULL OR proxima_tentativa_em<=?) AND (bloqueado_em IS NULL OR bloqueado_em<?)";$params=[gmdate('Y-m-d H:i:s'),gmdate('Y-m-d H:i:s',time()-600)];
    if($ids!==null){if(!$ids)return null;$sql.=' AND id IN ('.implode(',',array_fill(0,count($ids),'?')).')';$params=[...$params,...$ids];}
    $m=$this->repo->run($sql.' ORDER BY id LIMIT 1'.($this->repo->mysql()?' FOR UPDATE':''),$params)->fetch(PDO::FETCH_ASSOC);if(!$m)return null;
    $this->repo->run('UPDATE fila_emails SET bloqueado_em=?,tentativas=tentativas+1 WHERE id=?',[gmdate('Y-m-d H:i:s'),$m['id']]);return $m;
   });if(!$m)break;
   try{
    $mail=\Config\Services::email(null,false);$mail->initialize(['protocol'=>'smtp','SMTPHost'=>$config['servidor'],'SMTPPort'=>(int)$config['porta'],'SMTPCrypto'=>$config['seguranca']==='nenhuma'?'':$config['seguranca'],'SMTPUser'=>$config['usuario'],'SMTPPass'=>$this->decrypt($config['senha_cifrada']),'SMTPTimeout'=>8,'mailType'=>'text','charset'=>'UTF-8','newline'=>"\r\n",'CRLF'=>"\r\n"]);
    $mail->setFrom($config['remetente_email'],$config['remetente_nome']);$mail->setTo($m['destinatario']);$mail->setSubject($m['assunto']);$mail->setMessage($m['mensagem']);
    if(!$mail->send(false))throw new \RuntimeException('SMTP recusou o envio.');
    $this->repo->run("UPDATE fila_emails SET situacao='enviado',enviado_em=?,mensagem=NULL,bloqueado_em=NULL,ultimo_erro=NULL WHERE id=?",[gmdate('Y-m-d H:i:s'),$m['id']]);$sent++;
   }catch(\Throwable){$failed++;$this->repo->run('UPDATE fila_emails SET bloqueado_em=NULL,proxima_tentativa_em=?,ultimo_erro=? WHERE id=?',[gmdate('Y-m-d H:i:s',time()+300),'Falha SMTP. Confira servidor, porta, segurança e credenciais no painel master.',$m['id']]);}
  }
  return ['status'=>$failed?'falha':($sent?'enviado':'pendente'),'enviados'=>$sent,'falhas'=>$failed,'message'=>$failed?'Não foi possível enviar o e-mail. A operação foi gravada e a mensagem permanece na fila para nova tentativa.':($sent?'E-mail enviado com sucesso ao servidor de saída.':'Mensagem aguardando processamento da fila.')];
 }
}
