<?php
namespace App\Libraries;
use App\Models\PortalRepository;
use PDO;
final class OperacaoService
{
 public function __construct(public PortalRepository $repo){}
 private function all(string $sql,array $p=[]):array{$q=$this->repo->db->prepare($sql);$q->execute($p);return $q->fetchAll(PDO::FETCH_ASSOC);}
 private function run(string $sql,array $p=[]):void{$q=$this->repo->db->prepare($sql);$q->execute($p);}
 private function gestor(array $user,int $portal):void{$this->repo->authorize($user,$portal,true);if($user['role']!=='manager')throw new BusinessException('Esta área é exclusiva do gestor da vitrine.',403);}
 public static function automaticText(string $color):string {
  $rgb=array_map(static function($v){$v=hexdec($v)/255;return $v<=0.04045?$v/12.92:(($v+0.055)/1.055)**2.4;},str_split(substr($color,1),2));$l=0.2126*$rgb[0]+0.7152*$rgb[1]+0.0722*$rgb[2];return 1.05/($l+0.05)>=($l+0.05)/0.05?'#FFFFFF':'#000000';
 }
 public function identity(array $user,int $portal,array $data):void {
  $this->repo->authorize($user,$portal,true);$name=$data['name']??'';$color=$data['cor_principal']??'';$ink=$data['cor_texto']??null;$font=$data['fonte']??'Inter';$logo=$data['logotipo']??'';
  if(!is_string($name)||trim($name)===''||mb_strlen($name)>120)throw new BusinessException('Informe o nome da vitrine.',422,['name'=>'Informe o nome.']);
  if(!is_string($color)||!preg_match('/^#[a-f0-9]{6}$/iD',$color))throw new BusinessException('Escolha uma cor válida.',422,['cor_principal'=>'Escolha a cor principal.']);
  if($ink===null)$ink=self::automaticText($color);
  if(!is_string($ink)||!preg_match('/^#[a-f0-9]{6}$/iD',$ink))throw new BusinessException('Escolha uma cor de texto válida.',422,['cor_texto'=>'Escolha a cor do texto.']);
  if(!in_array($font,['Inter','Arial','Verdana','Georgia','Sistema'],true))throw new BusinessException('Selecione uma fonte disponível.',422,['fonte'=>'Selecione uma fonte da lista.']);
  if(!is_string($logo)||strlen($logo)>200||($logo!==''&&!preg_match('~^https://[^\s<>"\x27]+$~D',$logo)))throw new BusinessException('Informe um link HTTPS para o logotipo.',422,['logotipo'=>'Use um endereço iniciado por https://.']);
  $this->repo->transaction(function()use($user,$portal,$name,$color,$ink,$font,$logo){$this->repo->lockPortal($portal);$this->run('UPDATE portais SET nome=?,cor_principal=?,cor_texto=?,fonte=?,logotipo=? WHERE id=?',[trim($name),$color,$ink,$font,$logo,$portal]);$this->repo->audit($user,$portal,'portal.identity.changed');});
 }
 public function schedules(array $user,int $portal,bool $manage=false):array {
  $this->repo->authorize($user,$portal,$manage);return $this->all('SELECT * FROM horarios_atendimento WHERE id_portal=?'.($manage?'':' AND ativo=1').' ORDER BY id',[$portal]);
 }
 public function scheduleSave(array $user,int $portal,array $data,?int $id=null):void {
  $this->repo->authorize($user,$portal,true);
  $this->repo->transaction(function()use($user,$portal,$data,$id){
   $this->repo->lockPortal($portal);$row=$id?($this->all('SELECT * FROM horarios_atendimento WHERE id=? AND id_portal=?',[$id,$portal])[0]??null):null;
   if($id&&!$row)throw new BusinessException('Horário não encontrado.',404);
   if(array_keys($data)===['ativo']){if(!is_int($data['ativo'])||!in_array($data['ativo'],[0,1],true))throw new BusinessException('Situação inválida.');$this->run('UPDATE horarios_atendimento SET ativo=? WHERE id=?',[$data['ativo'],$id]);}
   else{
    $days=$data['dias_semana']??[];$start=$data['hora_inicio']??'';$end=$data['hora_fim']??'';
    if(!is_array($days)||!array_is_list($days)||!count($days)||count($days)>7||count(array_unique($days))!==count($days))throw new BusinessException('Selecione os dias de atendimento.');
    foreach($days as $d)if(!is_int($d)||$d<1||$d>7)throw new BusinessException('Dia de atendimento inválido.');sort($days);
    foreach(['hora_inicio'=>$start,'hora_fim'=>$end] as $key=>$value)if(!is_string($value)||!preg_match('/^(?:[01][0-9]|2[0-3]):[0-5][0-9]$/D',$value))throw new BusinessException('Informe um horário válido.',422,[$key=>'Informe hora e minutos.']);
    if($end<=$start)throw new BusinessException('O término deve ser depois do início.',422,['hora_fim'=>'Escolha um horário posterior ao início.']);
    $names=[1=>'Segunda',2=>'Terça',3=>'Quarta',4=>'Quinta',5=>'Sexta',6=>'Sábado',7=>'Domingo'];
    $label=$days===[1,2,3,4,5]?'Segunda a sexta':($days===[6,7]?'Sábado e domingo':implode(', ',array_map(fn($d)=>$names[$d],$days)));
    $label.=', das '.$start.' às '.$end;
    if(mb_strlen($label)>120)throw new BusinessException('Selecione um conjunto menor de dias.');
    if($id)$this->run('UPDATE horarios_atendimento SET descricao=?,dias_semana=?,hora_inicio=?,hora_fim=? WHERE id=?',[$label,implode(',',$days),$start,$end,$id]);
    else $this->run('INSERT INTO horarios_atendimento(id_portal,descricao,dias_semana,hora_inicio,hora_fim) VALUES(?,?,?,?,?)',[$portal,$label,implode(',',$days),$start,$end]);
   }
   $this->repo->audit($user,$portal,'schedule.changed');
  });
 }
 public function users(array $user,int $portal):array {
  $this->gestor($user,$portal);
  return $this->all("SELECT DISTINCT u.id,u.nome,u.email,m.ativo,a.nome AS empresa FROM usuarios u JOIN usuarios_portais m ON m.id_usuario=u.id JOIN anuncios p ON p.id_anunciante=u.id_anunciante AND p.id_portal=m.id_portal JOIN anunciantes a ON a.id=u.id_anunciante WHERE m.id_portal=? AND u.perfil='advertiser' ORDER BY u.nome",[$portal]);
 }
 public function userAction(array $user,int $portal,int $id,array $data):void {
  $this->gestor($user,$portal);
  $this->repo->transaction(function()use($user,$portal,$id,$data){
   $this->repo->lockPortal($portal);$target=null;foreach($this->users($user,$portal) as $candidate)if((int)$candidate['id']===$id)$target=$candidate;
   if(!$target)throw new BusinessException('Usuário não encontrado nesta vitrine.',404);
   $action=$data['acao']??'';
   if($action==='situacao'){$active=$data['ativo']??null;if(!is_int($active)||!in_array($active,[0,1],true))throw new BusinessException('Situação inválida.');$this->run('UPDATE usuarios_portais SET ativo=? WHERE id_usuario=? AND id_portal=?',[$active,$id,$portal]);}
   elseif($action==='email'){$email=$this->emailValido($data['email']??null,$id);$this->run('UPDATE usuarios SET email=? WHERE id=?',[$email,$id]);$this->invalidateTokens($id);}
   elseif($action==='redefinir')(new RelacionamentoService($this->repo))->acesso($id,$target['email']);
   elseif($action==='senha_provisoria'){$password=$data['password']??'';if(!is_string($password)||strlen($password)<12||strlen($password)>200)throw new BusinessException('Use pelo menos 12 caracteres.',422,['password'=>'Use de 12 a 200 caracteres.']);$this->run('UPDATE usuarios SET senha_hash=? WHERE id=?',[password_hash($password,PASSWORD_DEFAULT),$id]);$this->run('UPDATE tokens_acesso SET utilizado_em=CURRENT_TIMESTAMP WHERE id_usuario=? AND utilizado_em IS NULL',[$id]);}
   else throw new BusinessException('Ação inválida.');
   $this->repo->audit($user,$portal,'advertiser.access.'.$action);
  });
 }
 public function emailValido(mixed $email,int $id):string {
  if(!is_string($email)||strlen($email)>190||!filter_var(trim($email),FILTER_VALIDATE_EMAIL))throw new BusinessException('Informe um e-mail válido.',422,['email'=>'Informe um e-mail válido.']);
  $email=mb_strtolower(trim($email));
  if($this->all('SELECT id FROM usuarios WHERE email=? AND id<>?',[$email,$id]))throw new BusinessException('Este e-mail já está cadastrado.',409,['email'=>'Escolha outro e-mail.']);return $email;
 }
 public function updatePortal(array $user,int $id,array $data):void {
  if($user['role']!=='master')throw new BusinessException('Acesso não permitido.',403);
  $this->repo->transaction(function()use($user,$id,$data){
   $p=$this->all('SELECT * FROM portais WHERE id=?'.($this->repo->mysql()?' FOR UPDATE':''),[$id])[0]??null;if(!$p)throw new BusinessException('Portal não encontrado.',404);
   foreach(['name','organization'] as $key)if(!is_string($data[$key]??null)||trim($data[$key])===''||mb_strlen($data[$key])>120)throw new BusinessException('Preencha o nome e a organização.',422,[$key=>'Use até 120 caracteres.']);
   $address=$data['endereco_local']??'';$capacity=$data['capacity']??null;$active=$data['active']??null;
   if(!is_string($address)||mb_strlen($address)>250)throw new BusinessException('Endereço inválido.',422,['endereco_local'=>'Use até 250 caracteres.']);
   if(!is_int($capacity)||$capacity<1||$capacity>10000)throw new BusinessException('Capacidade inválida.',422,['capacity'=>'Use de 1 a 10000.']);
   if(!is_int($active)||!in_array($active,[0,1],true))throw new BusinessException('Situação inválida.');
   $count=(int)$this->repo->run('SELECT COUNT(*) FROM publications WHERE portal_id=? AND acesso_liberado_em IS NOT NULL',[$id])->fetchColumn();
   if($capacity<$count)throw new BusinessException('O limite não pode ser inferior aos espaços ocupados.',409,['capacity'=>'Há '.$count.' espaços ocupados.']);
   $this->run('UPDATE portais SET nome=?,endereco_local=?,limite_anuncios=?,ativo=? WHERE id=?',[trim($data['name']),trim($address),$capacity,$active,$id]);
   $this->run('UPDATE organizacoes SET nome=? WHERE id=?',[trim($data['organization']),$p['id_organizacao']]);
   $this->repo->audit($user,$id,'portal.updated');
  });
 }
 public function accountEmail(array $user,array $data):string {
  return $this->repo->transaction(function()use($user,$data){
   $u=$this->all('SELECT senha_hash,email FROM usuarios WHERE id=?'.($this->repo->mysql()?' FOR UPDATE':''),[$user['id']])[0];
   if(!is_string($data['current']??null)||!password_verify($data['current'],$u['senha_hash']))throw new BusinessException('Senha atual incorreta.',403,['current'=>'Confira sua senha atual.']);
   $email=$this->emailValido($data['email']??$u['email'],(int)$user['id']);$password=$data['new']??'';
   if(!is_string($password)||($password!==''&&(strlen($password)<12||strlen($password)>200)))throw new BusinessException('Use de 12 a 200 caracteres na nova senha.',422,['new'=>'Use pelo menos 12 caracteres.']);
   if($password!==''){$this->run('UPDATE usuarios SET senha_hash=? WHERE id=?',[password_hash($password,PASSWORD_DEFAULT),$user['id']]);$this->invalidateTokens((int)$user['id']);$this->repo->insert('audit_logs',['user_id'=>$user['id'],'action'=>'account.password.changed']);}
   if($email!==$u['email']){$this->run('UPDATE usuarios SET email=? WHERE id=?',[$email,$user['id']]);$this->invalidateTokens((int)$user['id']);$this->repo->insert('audit_logs',['user_id'=>$user['id'],'action'=>'account.email.changed']);}return $email;
  });
 }
 public function invalidateTokens(int $id):void {$this->run('UPDATE tokens_acesso SET utilizado_em=CURRENT_TIMESTAMP WHERE id_usuario=? AND utilizado_em IS NULL',[$id]);}
 public function createPortal(array $user,array $data):int {
  if($user['role']!=='master')throw new BusinessException('Acesso não permitido.',403);
  $name=$data['name']??'';$org=$data['organization']??'';$address=$data['endereco_local']??'';$capacity=$data['capacity']??0;
  foreach(['name'=>$name,'organization'=>$org] as $key=>$value)if(!is_string($value)||trim($value)===''||mb_strlen($value)>120)throw new BusinessException('Preencha os dados do portal.',422,[$key=>'Informe até 120 caracteres.']);
  if(!is_string($address)||mb_strlen($address)>250)throw new BusinessException('Endereço inválido.',422,['endereco_local'=>'Use até 250 caracteres.']);
  if(!is_int($capacity)||$capacity<1||$capacity>10000)throw new BusinessException('Informe uma capacidade válida.',422,['capacity'=>'Informe de 1 a 10000 espaços.']);
  $slug=$data['slug']??'';if(!is_string($slug))throw new BusinessException('Nome do link inválido.');
  $source=$slug!==''?$slug:$name;
  if($slug!==''&&!preg_match('/^[a-z0-9]+(?:-[a-z0-9]+)*$/D',$slug)&&$address==='')$address=$slug;
  $ascii=iconv('UTF-8','ASCII//TRANSLIT//IGNORE',$source);$slug=trim(preg_replace('/[^a-z0-9]+/','-',strtolower($ascii?:$source)),'-');$slug=substr($slug?:'vitrine',0,80);
  while($this->all('SELECT id FROM portais WHERE identificador=?',[$slug]))$slug=substr($slug,0,80).'-'.bin2hex(random_bytes(3));
  return $this->repo->transaction(function()use($user,$name,$org,$address,$capacity,$slug){
   $oid=$this->repo->insert('organizations',['name'=>trim($org)]);$id=$this->repo->insert('portals',['organization_id'=>$oid,'slug'=>$slug,'name'=>trim($name),'capacity'=>$capacity,'endereco_local'=>trim($address),'active'=>1]);
   if($this->repo->mysql())AtualizarOperacao::seed($this->repo->db,$id);else foreach([['Segunda a sexta, das 08:00 às 18:00','1,2,3,4,5','08:00','18:00'],['Sábado e domingo, das 08:00 às 12:00','6,7','08:00','12:00']] as $h)$this->run('INSERT INTO horarios_atendimento(id_portal,descricao,dias_semana,hora_inicio,hora_fim) VALUES(?,?,?,?,?)',[$id,...$h]);
   $this->repo->audit($user,$id,'portal.created');return $id;
  });
 }
}
