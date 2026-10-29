<?php
namespace App\Libraries;
use App\Models\PortalRepository;
use PDO;
final class RelacionamentoService
{
 public function __construct(public PortalRepository $repo){}
 private function raw(string $sql,array $p=[]):?array{return $this->repo->run($sql,$p)->fetch(PDO::FETCH_ASSOC)?:null;}
 private function base():string{return rtrim(config('App')->baseURL,'/').'/';}
 private function link(string $pagina,string $token,?string $slug=null):string {return $this->base().($slug?'?portal='.rawurlencode($slug):'').'#'.$pagina.'?token='.$token;}
 private function chave():string{$key=(string)env('portal.chaveEmails','');if(strlen($key)<32)throw new BusinessException('Configure a chave de identificação dos e-mails no servidor.',503);return $key;}
 public function email(string $email,string $assunto,string $mensagem):void {
  EmailService::$novos[]=$this->repo->insert('fila_emails',['destinatario'=>$email,'assunto'=>$assunto,'mensagem'=>$mensagem]);
 }
 public function acesso(int $usuario,string $email):void {
  $token=bin2hex(random_bytes(32));$this->repo->run('UPDATE tokens_acesso SET utilizado_em=CURRENT_TIMESTAMP WHERE id_usuario=? AND utilizado_em IS NULL',[$usuario]);
  $this->repo->insert('tokens_acesso',['id_usuario'=>$usuario,'token_hash'=>hash('sha256',$token),'expira_em'=>gmdate('Y-m-d H:i:s',time()+3600)]);
  $portal=$this->raw('SELECT p.identificador FROM portais p JOIN usuarios_portais v ON v.id_portal=p.id WHERE v.id_usuario=? AND v.ativo=1 AND p.ativo=1 ORDER BY p.id LIMIT 1',[$usuario]);
  $this->email($email,'Defina sua senha - Portal do Bairro','Defina sua senha em até uma hora: '.$this->link('definir-senha',$token,$portal['identificador']??null));
 }
 public function recuperar(array $data):void {
  $email=mb_strtolower(trim(is_string($data['email']??null)?$data['email']:''));
  if(!filter_var($email,FILTER_VALIDATE_EMAIL))throw new BusinessException('Informe um e-mail válido.',422,['email'=>'E-mail inválido.']);
  $u=$this->repo->one('SELECT id,email FROM users WHERE email=? AND active=1',[$email]);
  if($u){$latest=$this->raw('SELECT id FROM tokens_acesso WHERE id_usuario=? AND utilizado_em IS NULL AND expira_em>?',[$u['id'],gmdate('Y-m-d H:i:s',time()+3300)]);if(!$latest)$this->repo->transaction(fn()=>$this->acesso((int)$u['id'],$u['email']));}
 }
 public function senha(array $data):void {
  $token=$data['token']??'';$senha=$data['password']??'';
  if(!is_string($token)||strlen($token)!==64)throw new BusinessException('Link inválido ou expirado.');
  if(!is_string($senha)||strlen($senha)<12||strlen($senha)>200)throw new BusinessException('Use de 12 a 200 caracteres.',422,['password'=>'Use pelo menos 12 caracteres.']);
  $this->repo->transaction(function()use($token,$senha){
   $t=$this->raw('SELECT * FROM tokens_acesso WHERE token_hash=?'.($this->repo->mysql()?' FOR UPDATE':''),[hash('sha256',$token)]);
   if(!$t||$t['utilizado_em']||$t['expira_em']<=gmdate('Y-m-d H:i:s'))throw new BusinessException('Link inválido ou expirado.',410);
   $u=$this->repo->one('SELECT id FROM users WHERE id=? AND active=1',[$t['id_usuario']]);if(!$u)throw new BusinessException('Acesso indisponível.',403);
   $this->repo->run('UPDATE users SET password_hash=? WHERE id=?',[password_hash($senha,PASSWORD_DEFAULT),$t['id_usuario']]);
   $this->repo->run('UPDATE tokens_acesso SET utilizado_em=CURRENT_TIMESTAMP WHERE id_usuario=? AND utilizado_em IS NULL',[$t['id_usuario']]);
  });
 }
 public function convidar(array $user,array $portal,int $id,array $data):void {
  $this->repo->publication($id,(int)$portal['id'],$user);
  $email=mb_strtolower(trim(is_string($data['email']??null)?$data['email']:''));if(!filter_var($email,FILTER_VALIDATE_EMAIL))throw new BusinessException('E-mail inválido.',422,['email'=>'Informe um e-mail válido.']);
  $identificador=hash_hmac('sha256',$email,$this->chave());
  $this->repo->transaction(function()use($user,$portal,$id,$email,$identificador){
   $this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);
   if($row['status']!=='published')throw new BusinessException('O anúncio deve estar publicado para convidar clientes.',409);
   $now=gmdate('Y-m-d H:i:s');$ontem=gmdate('Y-m-d H:i:s',time()-86400);
   if($this->raw('SELECT id FROM avaliacoes WHERE id_anuncio=? AND identificador_email=? AND criado_em>?',[$id,$identificador,$ontem]))throw new BusinessException('Este e-mail já avaliou a empresa nas últimas 24 horas.',409);
   if($this->raw('SELECT id FROM convites_avaliacao WHERE id_anuncio=? AND identificador_email=? AND utilizado_em IS NULL AND expira_em>?',[$id,$identificador,$now]))throw new BusinessException('Já existe convite válido para este e-mail.',409);
   if((int)$this->repo->run('SELECT COUNT(*) FROM convites_avaliacao WHERE id_anuncio=? AND criado_em>?',[$id,$ontem])->fetchColumn()>=50)throw new BusinessException('Limite diário de 50 convites atingido.',429);
   $token=bin2hex(random_bytes(32));$dias=max(1,min(90,(int)env('portal.diasConvite',7)));
   $this->repo->insert('convites_avaliacao',['id_anuncio'=>$id,'id_solicitante'=>$user['id'],'email_destinatario'=>$email,'identificador_email'=>$identificador,'token_hash'=>hash('sha256',$token),'expira_em'=>gmdate('Y-m-d H:i:s',time()+$dias*86400)]);
   $this->email($email,'Avalie '.$row['name'],'Avalie o atendimento com 1 a 5 estrelas: '.$this->link('avaliar',$token,$portal['slug']).' — Link individual e de uso único.');
   $this->repo->audit($user,(int)$portal['id'],'rating.invited',$id);
  });
 }
 public function convite(string $token):array {
  if(!preg_match('/^[a-f0-9]{64}$/D',$token))throw new BusinessException('Convite inválido.',410);
  $c=$this->raw('SELECT c.*,p.nome,p.situacao,p.id_portal FROM convites_avaliacao c JOIN anuncios p ON p.id=c.id_anuncio WHERE c.token_hash=?',[hash('sha256',$token)]);
  if(!$c||$c['utilizado_em']||$c['expira_em']<=gmdate('Y-m-d H:i:s'))throw new BusinessException('Convite utilizado ou expirado.',410);
  if($c['situacao']!=='published')throw new BusinessException('Anúncio indisponível para avaliação.',409);
  return $c;
 }
 public function avaliar(string $token,array $data):void {
  $nota=$data['estrelas']??null;if(!is_int($nota)||$nota<1||$nota>5)throw new BusinessException('Selecione entre 1 e 5 estrelas.');
  $c=$this->convite($token);
  $this->repo->transaction(function()use($token,$nota,$c){
   $this->repo->lockPortal((int)$c['id_portal']);$c=$this->convite($token);
   if($this->raw('SELECT id FROM avaliacoes WHERE id_anuncio=? AND identificador_email=? AND criado_em>?',[$c['id_anuncio'],$c['identificador_email'],gmdate('Y-m-d H:i:s',time()-86400)]))throw new BusinessException('Aguarde 24 horas desde sua última avaliação desta empresa.',409);
   $this->repo->insert('avaliacoes',['id_anuncio'=>$c['id_anuncio'],'id_convite'=>$c['id'],'identificador_email'=>$c['identificador_email'],'estrelas'=>$nota,'criado_em'=>gmdate('Y-m-d H:i:s')]);
   $this->repo->run('UPDATE convites_avaliacao SET utilizado_em=CURRENT_TIMESTAMP WHERE id=?',[$c['id']]);
  });
 }
 public function clique(array $portal,int $id,string $canal,string $session):void {
  if(!in_array($canal,['whatsapp','instagram'],true))throw new BusinessException('Canal inválido.');
  $this->repo->transaction(function()use($portal,$id,$canal,$session){
   $this->repo->lockPortal((int)$portal['id']);$row=$this->repo->one("SELECT * FROM publications WHERE id=? AND portal_id=? AND status='published'",[$id,$portal['id']]);
   if(!$row)throw new BusinessException('Anúncio indisponível.',404);
   if(!$row[$canal])throw new BusinessException('Contato não informado.');
   $key=hash('sha256',$session);
   if(!$this->raw('SELECT id FROM eventos_clique WHERE id_anuncio=? AND canal=? AND identificador_sessao=? AND criado_em>?',[$id,$canal,$key,gmdate('Y-m-d H:i:s',time()-60)]))$this->repo->insert('eventos_clique',['id_anuncio'=>$id,'canal'=>$canal,'identificador_sessao'=>$key,'criado_em'=>gmdate('Y-m-d H:i:s')]);
  });
 }
}
