<?php
namespace App\Libraries;
use App\Models\PortalRepository;
final class ComercialService
{
 public function __construct(public PortalRepository $repo){}
 public function ocupados(int $portal):int {
  return (int)$this->repo->run('SELECT COUNT(*) FROM publications WHERE portal_id=? AND acesso_liberado_em IS NOT NULL',[$portal])->fetchColumn();
 }
 // Dentro de transação e após lockPortal.
 public function ocupar(array $row,array $portal):void {
  if($row['acesso_liberado_em'])return;
  if($this->ocupados((int)$portal['id'])>=(int)$portal['capacity'])throw new BusinessException('Limite de espaços contratados atingido.',409);
  $this->repo->run('UPDATE publications SET acesso_liberado_em=CURRENT_TIMESTAMP WHERE id=?',[$row['id']]);
 }
 public function publicarPrimeiraVez(array $row,array $user):void {
  if($row['primeira_publicacao_em'])return;
  if((int)$row['mensalidade_centavos']<1)throw new BusinessException('Defina a mensalidade antes da primeira publicação.',422,['mensalidade_centavos'=>'Informe um valor maior que zero.']);
  if(!$row['acesso_liberado_em'])throw new BusinessException('Libere o acesso do anunciante antes da publicação.',409);
  $inicio=new \DateTimeImmutable('today',new \DateTimeZone('America/Sao_Paulo'));
  $fim=$inicio->modify('+'.((int)$row['dias_periodo']-1).' days');
  $this->periodo($row,$user,$inicio->format('Y-m-d'),$fim->format('Y-m-d'));
  $this->repo->run('UPDATE publications SET primeira_publicacao_em=CURRENT_TIMESTAMP WHERE id=?',[$row['id']]);
 }
 private function periodo(array $row,array $user,string $inicio,string $fim):int {
  $id=$this->repo->insert('charges',['portal_id'=>$row['portal_id'],'publication_id'=>$row['id'],'description'=>'Mensalidade de divulgação','amount_cents'=>$row['mensalidade_centavos'],'due_date'=>$inicio,'inicio_referencia'=>$inicio,'fim_referencia'=>$fim,'tipo_cobranca'=>'anunciante']);
  $this->repo->insert('periodos_publicacao',['id_anuncio'=>$row['id'],'id_cobranca'=>$id,'inicio_em'=>$inicio,'fim_em'=>$fim,'registrado_por'=>$user['id']]);return $id;
 }
 public function configurar(array $user,array $portal,int $id,array $data):void {
  if($user['role']!=='manager')throw new BusinessException('Esta operação financeira pertence ao gestor da vitrine.',403);
  $this->repo->authorize($user,(int)$portal['id'],true);$valor=$data['mensalidade_centavos']??null;$dias=$data['dias_periodo']??30;
  if(!is_int($valor)||$valor<1||$valor>100000000)throw new BusinessException('Mensalidade inválida.',422,['mensalidade_centavos'=>'Informe um valor válido.']);
  if(!is_int($dias)||$dias<1||$dias>366)throw new BusinessException('Período inválido.',422,['dias_periodo'=>'Use entre 1 e 366 dias.']);
  $this->repo->transaction(function()use($user,$portal,$id,$valor,$dias){
   $this->repo->lockPortal((int)$portal['id']);$this->repo->publication($id,(int)$portal['id'],$user);
   $this->repo->run('UPDATE publications SET mensalidade_centavos=?,dias_periodo=? WHERE id=?',[$valor,$dias,$id]);$this->repo->audit($user,(int)$portal['id'],'commercial.changed',$id);
  });
 }
 public function renovar(array $user,array $portal,int $id,array $data):void {
  if($user['role']!=='manager')throw new BusinessException('Esta operação financeira pertence ao gestor da vitrine.',403);
  $this->repo->authorize($user,(int)$portal['id'],true);
  foreach(['inicio_em','fim_em'] as $key){$v=$data[$key]??'';$d=is_string($v)?\DateTimeImmutable::createFromFormat('!Y-m-d',$v):false;if(!$d||$d->format('Y-m-d')!==$v)throw new BusinessException('Data inválida.',422,[$key=>'Informe uma data válida.']);}
  if($data['fim_em']<$data['inicio_em'])throw new BusinessException('O fim deve ser posterior ou igual ao início.');
  $this->repo->transaction(function()use($user,$portal,$id,$data){
   $this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);
   if(!$row['primeira_publicacao_em'])throw new BusinessException('A primeira publicação inicia o primeiro período.',409);
   if($this->repo->one('SELECT id FROM periodos_publicacao WHERE id_anuncio=? AND inicio_em<=? AND fim_em>=?',[$id,$data['fim_em'],$data['inicio_em']]))throw new BusinessException('Já existe período nessas datas.',409);
   $this->periodo($row,$user,$data['inicio_em'],$data['fim_em']);$this->repo->audit($user,(int)$portal['id'],'period.renewed',$id);
  });
 }
 public function pagar(array $user,array $portal,int $id):void {
  $this->repo->authorize($user,(int)$portal['id'],true);
  $this->repo->transaction(function()use($user,$portal,$id){
   $this->repo->lockPortal((int)$portal['id']);$c=$this->repo->one('SELECT * FROM charges WHERE id=? AND portal_id=?',[$id,$portal['id']]);if(!$c)throw new BusinessException('Cobrança não encontrada.',404);
   if($c['tipo_cobranca']==='plataforma'&&$user['role']!=='master')throw new BusinessException('Somente o master registra este recebimento.',403);
   if($c['tipo_cobranca']!=='plataforma'&&$user['role']==='master')throw new BusinessException('O pagamento do anunciante deve ser registrado pelo gestor.',403);
   if($c['paid_at'])return;
   $this->repo->insert('pagamentos',['id_cobranca'=>$id,'valor_centavos'=>$c['amount_cents'],'recebido_em'=>gmdate('Y-m-d H:i:s'),'registrado_por'=>$user['id']]);
   $this->repo->run('UPDATE charges SET paid_at=CURRENT_TIMESTAMP WHERE id=?',[$id]);$this->repo->audit($user,(int)$portal['id'],'charge.paid');
  });
 }
}
