<?php
namespace App\Controllers;

use App\Libraries\BusinessException;
use App\Libraries\CatalogService;
use App\Models\PortalRepository;

class Api extends BaseController
{
    private PortalRepository $repo;
    private ?array $user=null;
    private $session;

    public function handle(string ...$segments)
    {
        $endpoint=implode('/', $segments);
        try{
            $this->repo=new PortalRepository();$this->session=session();
            if($this->session->get('last_seen') && time()-(int)$this->session->get('last_seen')>3600){$this->session->remove(['user_id','csrf']);$this->session->regenerate(true);}
            $this->session->set('last_seen',time());
            if(!$this->session->get('csrf'))$this->session->set('csrf',bin2hex(random_bytes(32)));
            if($this->session->get('user_id')){
                $record=$this->repo->one('SELECT id,name,email,role,advertiser_id,password_hash FROM users WHERE id=? AND active=1',[$this->session->get('user_id')]);
                if($record&&hash_equals((string)$this->session->get('auth_stamp'),hash('sha256',$record['password_hash']))){unset($record['password_hash']);$this->user=$record;}
                else $this->session->remove(['user_id','auth_stamp']);
            }
            $method=strtoupper($this->request->getMethod());
            if($method!=='GET'&&!hash_equals($this->session->get('csrf'),$this->request->getHeaderLine('X-CSRF-Token')))throw new BusinessException('Sessão inválida. Recarregue a página.',403);
            if($endpoint==='session'&&$method==='GET')return $this->json(['user'=>$this->user,'csrf'=>$this->session->get('csrf')]);
            if($endpoint==='login'&&$method==='POST')return $this->login();
            if($endpoint==='logout'&&$method==='POST'){
                $this->session->remove('user_id');$this->session->regenerate(true);$this->session->set('csrf',bin2hex(random_bytes(32)));
                return $this->json(['user'=>null,'csrf'=>$this->session->get('csrf')]);
            }
            $relacionamento=new \App\Libraries\RelacionamentoService($this->repo);
            if($endpoint==='recover'&&$method==='POST'){
                $fingerprint=hash('sha256','recover|'.$this->request->getIPAddress());
                if((int)$this->repo->run('SELECT COUNT(*) FROM login_attempts WHERE fingerprint=? AND attempted_at>?',[$fingerprint,time()-900])->fetchColumn()>=5)throw new BusinessException('Aguarde 15 minutos para tentar novamente.',429);
                $this->repo->insert('login_attempts',['fingerprint'=>$fingerprint,'attempted_at'=>time()]);$relacionamento->recuperar($this->body());return $this->json(['ok'=>true]);
            }
            if($endpoint==='reset'&&$method==='POST'){$relacionamento->senha($this->body());return $this->json(['ok'=>true]);}
            if(preg_match('~^rating/([a-f0-9]{64})$~',$endpoint,$m)){
                if($method==='GET'){$c=$relacionamento->convite($m[1]);return $this->json(['nome'=>$c['nome']]);}
                if($method==='POST'){$relacionamento->avaliar($m[1],$this->body());return $this->json(['ok'=>true]);}
            }
            if($endpoint==='account'&&$method==='PUT'){if(!$this->user)throw new BusinessException('Entre na sua conta.',401);$email=(new \App\Libraries\OperacaoService($this->repo))->accountEmail($this->user,$this->body());$account=$this->repo->one('SELECT password_hash FROM users WHERE id=?',[$this->user['id']]);$this->session->set('auth_stamp',hash('sha256',$account['password_hash']));$this->session->regenerate(true);return $this->json(['ok'=>true,'email'=>$email]);}
            if($endpoint==='password'&&$method==='POST')return $this->password();
            if(str_starts_with($endpoint,'admin/'))return $this->admin(substr($endpoint,6),$method);
            if($endpoint==='my-portals'&&$method==='GET'){if(!$this->user)throw new BusinessException('Entre na sua conta.',401);return $this->json(['portals'=>$this->repo->all('SELECT p.id,p.name,p.slug FROM portals p JOIN memberships m ON m.portal_id=p.id WHERE m.user_id=? AND m.active=1 AND p.active=1',[$this->user['id']])]);}
        if($endpoint==='portals'&&$method==='GET')return $this->json(['portals'=>$this->repo->all('SELECT id,name,slug FROM portals WHERE active=1 ORDER BY name')]);
            $slug=$this->request->getGet('portal')??env('portal.defaultSlug','annecont');
            if(!is_string($slug)||strlen($slug)>100)throw new BusinessException('Portal inválido.',400);
            $portal=$this->repo->portal($slug);$pid=(int)$portal['id'];$catalog=new CatalogService($this->repo);
            if($endpoint==='publications'&&$method==='GET'){
                $scope=$this->request->getGet('scope')??'public';$sql='SELECT * FROM publications WHERE portal_id=?';$params=[$pid];
                if($scope==='manage')$this->repo->authorize($this->user,$pid,true);
                elseif($scope==='mine'){$this->repo->authorize($this->user,$pid);if($this->user['role']!=='advertiser')throw new BusinessException('Área exclusiva do anunciante.',403);$sql.=' AND advertiser_id=?';$params[]=$this->user['advertiser_id'];}
                elseif($scope==='public')$sql.=" AND status='published'";
                else throw new BusinessException('Consulta inválida.',400);
                return $this->json(['portal'=>$portal,'publications'=>array_map(fn($row)=>$this->shape($row,$scope!=='public'),$this->repo->all($sql.' ORDER BY id',$params))]);
            }
            if(preg_match('~^publications/(\d+)/preview$~',$endpoint,$m)&&$method==='GET'){
                $row=$this->repo->publication((int)$m[1],$pid,$this->user);
                $version=$this->request->getGet('version')??'proposed';if(!in_array($version,['public','proposed'],true))throw new BusinessException('Versão inválida.');
                return $this->json(['publication'=>$this->shape($row,$version==='proposed'),'version'=>$version,'published'=>$row['status']==='published']);
            }
            if(preg_match('~^publications/(\d+)/images/(\d+)/cover$~',$endpoint,$m)&&$method==='POST'){
                $this->repo->authorize($this->user,$pid);$source=$this->request->getGet('source')??'draft';
                if(!in_array($source,['draft','public'],true))throw new BusinessException('Origem inválida.');
                $catalog->setCover($this->user,$portal,(int)$m[1],(int)$m[2],$source);return $this->json(['ok'=>true]);
            }
            if(preg_match('~^publications/(\d+)/review$~',$endpoint,$m)){
                $this->repo->authorize($this->user,$pid,true);$id=(int)$m[1];
                if($method==='GET'){
                    $row=$this->repo->publication($id,$pid,$this->user);
                    return $this->json(['approved'=>$this->shape($row),'proposed'=>$this->shape($row,true)]);
                }
                if($method==='POST'){$catalog->review($this->user,$portal,$id,$this->body());return $this->json(['ok'=>true]);}
            }
            if($endpoint==='publications'&&$method==='POST'){
                $this->repo->authorize($this->user,$pid,true);
                return $this->json(['id'=>$catalog->save($this->user,$portal,$this->body(),null)],201);
            }
            if(preg_match('~^publications/(\d+)$~',$endpoint,$m)&&$method==='PUT'){
                $this->repo->authorize($this->user,$pid);
                return $this->json(['id'=>$catalog->save($this->user,$portal,$this->body(),(int)$m[1])]);
            }
            if(preg_match('~^publications/(\d+)/status$~',$endpoint,$m)&&$method==='POST'){
                $this->repo->authorize($this->user,$pid,true);$status=$this->body()['status']??'';
                if(!is_string($status))throw new BusinessException('Situação inválida.');
                $motivo=$this->body()['motivo']??'';if(!is_string($motivo))throw new BusinessException('Motivo inválido.');$catalog->status($this->user,$portal,(int)$m[1],$status,$motivo);return $this->json(['ok'=>true]);
            }
            if(preg_match('~^publications/(\d+)/images$~',$endpoint,$m)&&$method==='POST'){
                $this->repo->authorize($this->user,$pid);
                $files=$this->request->getFileMultiple('images')??[];
                $publication=$catalog->upload($this->user,$portal,(int)$m[1],$files);if($this->user['role']==='master')unset($publication['mensalidade_centavos']);return $this->json(['publication'=>$publication],201);
            }
            if(preg_match('~^publications/(\d+)/images/(\d+)$~',$endpoint,$m)&&$method==='DELETE'){
                $this->repo->authorize($this->user,$pid);$source=$this->request->getGet('source')??'draft';if(!in_array($source,['draft','public'],true))throw new BusinessException('Origem da imagem inválida.');$catalog->deleteImage($this->user,$portal,(int)$m[1],(int)$m[2],$source);return $this->json(['ok'=>true]);
            }
            if(preg_match('~^publications/(\d+)/(commercial|renew)$~',$endpoint,$m)&&$method==='POST'){
                $this->repo->authorize($this->user,$pid,true);$service=new \App\Libraries\ComercialService($this->repo);
                if($m[2]==='commercial')$service->configurar($this->user,$portal,(int)$m[1],$this->body());else $service->renovar($this->user,$portal,(int)$m[1],$this->body());return $this->json(['ok'=>true]);
            }
            if(preg_match('~^publications/(\d+)/invites$~',$endpoint,$m)&&$method==='GET'){
                $this->repo->publication((int)$m[1],$pid,$this->user);
                return $this->json(['invites'=>$this->repo->all('SELECT id,email_destinatario,expira_em,utilizado_em FROM convites_avaliacao WHERE id_anuncio=? ORDER BY id DESC LIMIT 50',[(int)$m[1]])]);
            }
            if(preg_match('~^publications/(\d+)/(invite|click)$~',$endpoint,$m)&&$method==='POST'){
                if($m[2]==='invite'){$this->repo->authorize($this->user,$pid);$relacionamento->convidar($this->user,$portal,(int)$m[1],$this->body());}
                else {$canal=$this->body()['canal']??'';if(!is_string($canal))throw new BusinessException('Canal inválido.');$relacionamento->clique($portal,(int)$m[1],$canal,session_id());}
                return $this->json(['ok'=>true]);
            }
            if($endpoint==='reports'&&$method==='GET'){
                $this->repo->authorize($this->user,$pid);$tz=new \DateTimeZone('America/Sao_Paulo');$hoje=new \DateTimeImmutable('today',$tz);
                $inicio=$this->request->getGet('inicio')??$hoje->format('Y-m-01');$fim=$this->request->getGet('fim')??$hoje->format('Y-m-d');
                foreach([$inicio,$fim] as $value){$d=is_string($value)?\DateTimeImmutable::createFromFormat('!Y-m-d',$value,$tz):false;if(!$d||$d->format('Y-m-d')!==$value)throw new BusinessException('Período inválido.');}
                if($fim<$inicio)throw new BusinessException('Período inválido.');
                $a=(new \DateTimeImmutable($inicio.' 00:00:00',$tz))->setTimezone(new \DateTimeZone('UTC'))->format('Y-m-d H:i:s');$z=(new \DateTimeImmutable($fim.' 00:00:00',$tz))->modify('+1 day')->setTimezone(new \DateTimeZone('UTC'))->format('Y-m-d H:i:s');
                $sql="SELECT p.id,p.name,(SELECT COUNT(*) FROM eventos_clique e WHERE e.id_anuncio=p.id AND e.canal='whatsapp' AND e.criado_em>=? AND e.criado_em<?) AS whatsapp,(SELECT COUNT(*) FROM eventos_clique e WHERE e.id_anuncio=p.id AND e.canal='instagram' AND e.criado_em>=? AND e.criado_em<?) AS instagram FROM publications p WHERE p.portal_id=?";$params=[$a,$z,$a,$z,$pid];
                if($this->user['role']==='advertiser'){$sql.=' AND p.advertiser_id=?';$params[]=$this->user['advertiser_id'];}
                return $this->json(['reports'=>$this->repo->all($sql,$params),'inicio'=>$inicio,'fim'=>$fim]);
            }
            if($endpoint==='identity'&&$method==='POST'){
                $this->repo->authorize($this->user,$pid,true);(new \App\Libraries\OperacaoService($this->repo))->identity($this->user,$pid,$this->body());return $this->json(['ok'=>true]);
            }
            if($endpoint==='schedules'&&$method==='GET'){
                $this->repo->authorize($this->user,$pid);return $this->json(['schedules'=>(new \App\Libraries\OperacaoService($this->repo))->schedules($this->user,$pid,$this->request->getGet('scope')==='manage')]);
            }
            if(preg_match('~^schedules(?:/(\d+))?$~',$endpoint,$m)&&in_array($method,['POST','PUT'],true)){
                $this->repo->authorize($this->user,$pid,true);(new \App\Libraries\OperacaoService($this->repo))->scheduleSave($this->user,$pid,$this->body(),isset($m[1])?(int)$m[1]:null);return $this->json(['ok'=>true]);
            }
            if($endpoint==='users'&&$method==='GET'){
                $this->repo->authorize($this->user,$pid,true);return $this->json(['users'=>(new \App\Libraries\OperacaoService($this->repo))->users($this->user,$pid)]);
            }
            if(preg_match('~^users/(\d+)$~',$endpoint,$m)&&$method==='PUT'){
                $this->repo->authorize($this->user,$pid,true);(new \App\Libraries\OperacaoService($this->repo))->userAction($this->user,$pid,(int)$m[1],$this->body());return $this->json(['ok'=>true]);
            }
            if($endpoint==='companies'&&$method==='POST'){
                if(!$this->user||$this->user['role']!=='manager')throw new BusinessException('O cadastro comercial de anunciantes é responsabilidade do gestor.',403);
                $this->repo->authorize($this->user,$pid,true);$data=$this->body();$name=$this->text($data,'name',120);$responsavel=$this->text($data,'responsavel',120);$email=$this->email($data);$hash=$this->newPassword($data);$valor=$data['mensalidade_centavos']??0;
                if(!is_int($valor)||$valor<1||$valor>100000000)throw new BusinessException('Informe uma mensalidade válida.');
                $id=$this->repo->transaction(function()use($pid,$portal,$name,$responsavel,$email,$hash,$valor,$relacionamento){
                    $locked=$this->repo->lockPortal($pid);$commercial=new \App\Libraries\ComercialService($this->repo);
                    if($commercial->ocupados($pid)>=(int)$locked['capacity'])throw new BusinessException('Limite de espaços atingido.',409);
                    $aid=$this->repo->insert('advertisers',['name'=>$name]);
                    $id=$this->repo->insert('publications',['portal_id'=>$pid,'advertiser_id'=>$aid,'name'=>$name,'category'=>'reformas','service'=>'','description'=>'','mode'=>'Em estabelecimento','hours'=>'','services'=>'[]','status'=>'pending','mensalidade_centavos'=>$valor,'acesso_liberado_em'=>gmdate('Y-m-d H:i:s')]);
                    $uid=$this->repo->insert('users',['name'=>$responsavel,'email'=>$email,'password_hash'=>$hash,'role'=>'advertiser','advertiser_id'=>$aid]);$this->repo->insert('memberships',['user_id'=>$uid,'portal_id'=>$pid]);
                    $relacionamento->acesso($uid,$email);$this->repo->audit($this->user,$pid,'advertiser.access.created',$id);return $id;
                });return $this->json(['id'=>$id],201);
            }
            if($endpoint==='access'&&$method==='POST')return $this->access($portal);
            if($endpoint==='charges')return $this->charges($portal,$method);
            if(preg_match('~^charges/(\d+)/paid$~',$endpoint,$m)&&$method==='POST'){
                $this->repo->authorize($this->user,$pid,true);
                (new \App\Libraries\ComercialService($this->repo))->pagar($this->user,$portal,(int)$m[1]);return $this->json(['ok'=>true]);
            }
            if($endpoint==='audit'&&$method==='GET'){
                if(!$this->user||$this->user['role']!=='master')throw new BusinessException('Auditoria disponível somente ao administrador master.',403);
                $this->repo->authorize($this->user,$pid,true);
                return $this->json(['events'=>$this->repo->all('SELECT a.id,a.action,a.publication_id,a.created_at,u.name AS actor FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id WHERE a.portal_id=? ORDER BY a.id DESC LIMIT 100',[$pid])]);
            }
            throw new BusinessException('Endpoint não encontrado.',404);
        }catch(BusinessException $e){return $this->json(['error'=>$e->getMessage(),'fields'=>$e->fields],$e->status);}
        catch(\PDOException $e){log_message('error',(string)$e);$duplicate=in_array((string)$e->getCode(),['23000','23505'],true);return $this->json(['error'=>$duplicate?'Já existe um registro com estes dados.':'Não foi possível acessar o banco. Verifique a instalação e a configuração MySQL.'],$duplicate?409:503);}
        catch(\Throwable $e){log_message('error',(string)$e);return $this->json(['error'=>'Não foi possível concluir a operação. Consulte o registro do servidor.'],500);}
    }
    private function shape(array $row,bool $draft=false):array {
        $out=$this->repo->shape($row,$draft);if($draft)$out['responsaveis']=$this->repo->all("SELECT u.name,u.email,u.active,m.active AS vinculo_ativo FROM users u JOIN memberships m ON m.user_id=u.id WHERE u.advertiser_id=? AND m.portal_id=? AND u.role='advertiser' ORDER BY u.id",[$row['advertiser_id'],$row['portal_id']]);if(($this->user['role']??'')==='master')unset($out['mensalidade_centavos']);return $out;
    }
    private function json(array $data,int $status=200){
        if($status<400&&isset($this->repo)&&\App\Libraries\EmailService::$novos){$ids=\App\Libraries\EmailService::$novos;\App\Libraries\EmailService::$novos=[];$data['email_delivery']=str_ends_with($this->request->getUri()->getPath(),'/recover')?['status'=>'pendente','message'=>'Solicitação recebida. Se o e-mail estiver cadastrado, as instruções serão enviadas. Confira sua caixa de entrada e spam.']:(new \App\Libraries\EmailService($this->repo))->process($ids,3);}
        if($status<400&&str_ends_with($this->request->getUri()->getPath(),'/recover'))$data['email_delivery']=['status'=>'pendente','message'=>'Solicitação recebida. Se o e-mail estiver cadastrado, as instruções serão enviadas. Confira sua caixa de entrada e spam.'];
        return $this->response->setStatusCode($status)->setHeader('Cache-Control','no-store')->setJSON($data);}
    private function body(): array
    {
        if(strlen($this->request->getBody())>20000)throw new BusinessException('Requisição muito grande.',413);
        try{$data=json_decode($this->request->getBody(),true,32,JSON_THROW_ON_ERROR);}catch(\JsonException){throw new BusinessException('JSON inválido.',400);}
        if(!is_array($data)||array_is_list($data))throw new BusinessException('Dados inválidos.',400);return $data;
    }
    private function text(array $data,string $key,int $max,bool $required=true): string
    {
        if(isset($data[$key])&&!is_string($data[$key]))throw new BusinessException('Campo inválido: '.$key,422,[$key=>'Informe um valor válido.']);
        $value=trim($data[$key]??'');if(($required&&$value==='')||mb_strlen($value)>$max)throw new BusinessException('Preencha corretamente: '.$key,422,[$key=>'Preencha este campo corretamente.']);return $value;
    }
    private function email(array $data): string
    {
        $value=mb_strtolower($this->text($data,'email',190));if(!filter_var($value,FILTER_VALIDATE_EMAIL))throw new BusinessException('E-mail inválido.',422,['email'=>'Informe um e-mail válido.']);return $value;
    }
    private function newPassword(array $data,string $key='password'): string
    {
        $password=$this->text($data,$key,200);if(strlen($password)<12)throw new BusinessException('A senha deve ter pelo menos 12 caracteres.',422,[$key=>'Use pelo menos 12 caracteres.']);return password_hash($password,PASSWORD_DEFAULT);
    }
    private function login()
    {
        $data=$this->body();$email=mb_strtolower($this->text($data,'email',190));$password=$this->text($data,'password',200);
        $ip=$this->request->getIPAddress();$key=hash('sha256',$ip.'|'.$email);$ipKey=hash('sha256',$ip);
        $this->repo->run('DELETE FROM login_attempts WHERE attempted_at<?',[time()-900]);
        foreach([[$key,5],[$ipKey,30]] as [$fingerprint,$limit])if((int)$this->repo->run('SELECT COUNT(*) FROM login_attempts WHERE fingerprint=?',[$fingerprint])->fetchColumn()>=$limit)throw new BusinessException('Muitas tentativas. Aguarde 15 minutos.',429);
        foreach([$key,$ipKey] as $fingerprint)$this->repo->insert('login_attempts',['fingerprint'=>$fingerprint,'attempted_at'=>time()]);
        $lookup=$email==='admin'?'admin@portal.local':$email;
        $account=$this->repo->one('SELECT * FROM users WHERE email=? AND active=1',[$lookup]);
        $valid=password_verify($password,$account['password_hash']??'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi');
        if(!$account||!$valid)throw new BusinessException('E-mail ou senha incorretos.',401);
        if($account['role']!=='master'&&!$this->repo->one('SELECT m.user_id FROM memberships m JOIN portals p ON p.id=m.portal_id WHERE m.user_id=? AND m.active=1 AND p.active=1',[$account['id']]))throw new BusinessException('Seu acesso está inativo. Procure o responsável pela vitrine.',403);
        $this->session->regenerate(true);$this->session->set(['user_id'=>$account['id'],'auth_stamp'=>hash('sha256',$account['password_hash']),'csrf'=>bin2hex(random_bytes(32))]);
        $this->repo->run('DELETE FROM login_attempts WHERE fingerprint=?',[$key]);
        return $this->json(['user'=>array_intersect_key($account,array_flip(['id','name','email','role','advertiser_id'])),'csrf'=>$this->session->get('csrf')]);
    }
    private function password()
    {
        if(!$this->user)throw new BusinessException('Entre na sua conta.',401);$data=$this->body();
        $old=$this->text($data,'current',200);$hash=$this->newPassword($data,'new');
        $account=$this->repo->one('SELECT password_hash FROM users WHERE id=?',[$this->user['id']]);
        if(!password_verify($old,$account['password_hash']))throw new BusinessException('Senha atual incorreta.',403);
        $this->repo->run('UPDATE users SET password_hash=? WHERE id=?',[$hash,$this->user['id']]);$this->session->set('auth_stamp',hash('sha256',$hash));$this->session->regenerate(true);return $this->json(['ok'=>true]);
    }
    private function access(array $portal)
    {
        $pid=(int)$portal['id'];$this->repo->authorize($this->user,$pid,true);$data=$this->body();
        $row=$this->repo->publication((int)($data['publicationId']??0),$pid,$this->user);
        $name=$this->text($data,'name',120);$email=$this->email($data);$hash=$this->newPassword($data);
        $id=$this->repo->transaction(function()use($row,$name,$email,$hash,$pid){
            $locked=$this->repo->lockPortal($pid);$fresh=$this->repo->publication((int)$row['id'],$pid,$this->user);
            if((int)$fresh['mensalidade_centavos']<1)throw new BusinessException('Defina a mensalidade antes de liberar o acesso.',409);
            (new \App\Libraries\ComercialService($this->repo))->ocupar($fresh,$locked);
            if($this->repo->one('SELECT id FROM users WHERE email=?',[$email]))throw new BusinessException('E-mail já cadastrado. Use a gestão de usuários para alterar um acesso existente.',409,['email'=>'Este e-mail já está cadastrado.']);
            $id=$this->repo->insert('users',['name'=>$name,'email'=>$email,'password_hash'=>$hash,'role'=>'advertiser','advertiser_id'=>$row['advertiser_id'],'active'=>1]);
            $this->repo->insert('memberships',['user_id'=>$id,'portal_id'=>$pid]);$this->repo->audit($this->user,$pid,'advertiser.access.created',(int)$row['id']);return $id;
        });return $this->json(['id'=>$id],201);
    }
    private function charges(array $portal,string $method)
    {
        $pid=(int)$portal['id'];$this->repo->authorize($this->user,$pid);
        if($method==='GET'&&$this->user['role']==='advertiser')return $this->json(['charges'=>$this->repo->all('SELECT c.*,p.name AS business FROM charges c JOIN publications p ON p.id=c.publication_id WHERE c.portal_id=? AND p.advertiser_id=? ORDER BY c.due_date,c.id',[$pid,$this->user['advertiser_id']])]);
        $this->repo->authorize($this->user,$pid,true);
        if($method==='GET'){
            $tipo=$this->user['role']==='master'?'plataforma':'anunciante';
            return $this->json(['charges'=>$this->repo->all('SELECT c.*,p.name AS business FROM charges c LEFT JOIN publications p ON p.id=c.publication_id WHERE c.portal_id=? AND c.tipo_cobranca=? ORDER BY c.due_date,c.id',[$pid,$tipo])]);
        }
        if($method!=='POST')throw new BusinessException('Método inválido.',405);
        if($this->user['role']!=='manager')throw new BusinessException('Mensalidades dos anunciantes são administradas pelo gestor.',403);
        $data=$this->body();$description=$this->text($data,'description',150);$date=$this->text($data,'due_date',10);
        $parsed=\DateTimeImmutable::createFromFormat('!Y-m-d',$date);if(!$parsed||$parsed->format('Y-m-d')!==$date)throw new BusinessException('Data inválida.');
        $amount=$data['amount_cents']??0;if(!is_int($amount)||$amount<1||$amount>100000000)throw new BusinessException('Valor inválido.');
        if(empty($data['publication_id']))throw new BusinessException('Selecione o anúncio. A assinatura da plataforma é administrada pelo master.');
        $publication=isset($data['publication_id'])?(int)$data['publication_id']:null;
        if($publication)$this->repo->publication($publication,$pid,$this->user);
        $id=$this->repo->transaction(function()use($pid,$description,$date,$amount,$publication){$id=$this->repo->insert('charges',['portal_id'=>$pid,'publication_id'=>$publication?:null,'description'=>$description,'amount_cents'=>$amount,'due_date'=>$date]);$this->repo->audit($this->user,$pid,'charge.created',$publication);return $id;});
        return $this->json(['id'=>$id],201);
    }
    private function admin(string $endpoint,string $method)
    {
        if(!$this->user)throw new BusinessException('Entre na sua conta.',401);
        if($this->user['role']!=='master')throw new BusinessException('Acesso não permitido.',403);
        if($endpoint==='email-settings'&&$method==='GET')return $this->json(['settings'=>(new \App\Libraries\EmailService($this->repo))->get($this->user)]);
        if($endpoint==='email-settings'&&$method==='PUT'){(new \App\Libraries\EmailService($this->repo))->save($this->user,$this->body());return $this->json(['ok'=>true]);}
        if($endpoint==='email-test'&&$method==='POST'){$email=$this->email($this->body());(new \App\Libraries\RelacionamentoService($this->repo))->email($email,'Teste SMTP - Portal do Bairro','Esta é uma mensagem de teste do envio configurado no Portal do Bairro.');return $this->json(['ok'=>true]);}
        if($endpoint==='charges'&&$method==='GET')return $this->json(['charges'=>$this->repo->all("SELECT c.*,p.name AS business FROM charges c JOIN portals p ON p.id=c.portal_id WHERE c.tipo_cobranca='plataforma' ORDER BY c.due_date,c.id")]);
        if($endpoint==='audit'&&$method==='GET')return $this->json(['events'=>$this->repo->all('SELECT a.id,a.action,a.publication_id,a.created_at,u.name AS actor,p.name AS portal FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id LEFT JOIN portals p ON p.id=a.portal_id ORDER BY a.id DESC LIMIT 200')]);
        if($endpoint==='portals'&&$method==='GET'){$items=$this->repo->all("SELECT p.*,o.name AS organization,(SELECT COUNT(*) FROM publications a WHERE a.portal_id=p.id AND a.acesso_liberado_em IS NOT NULL) AS active_count FROM portals p JOIN organizations o ON o.id=p.organization_id");foreach($items as &$p)$p['responsaveis']=$this->repo->all("SELECT u.id,u.name,u.email,u.active,m.active AS vinculo_ativo FROM users u JOIN memberships m ON m.user_id=u.id WHERE m.portal_id=? AND u.role='manager' ORDER BY u.id",[$p['id']]);unset($p);return $this->json(['portals'=>$items]);}
        if(preg_match('~^portals/(\d+)$~',$endpoint,$m)&&$method==='PUT'){(new \App\Libraries\OperacaoService($this->repo))->updatePortal($this->user,(int)$m[1],$this->body());return $this->json(['ok'=>true]);}
        if($endpoint==='portals'&&$method==='POST')return $this->json(['id'=>(new \App\Libraries\OperacaoService($this->repo))->createPortal($this->user,$this->body())],201);
        if(preg_match('~^portals/(\d+)/subscription$~',$endpoint,$m)&&$method==='POST'){
            $data=$this->body();$valor=$data['valor_centavos']??null;$date=$this->text($data,'vencimento',10);$d=\DateTimeImmutable::createFromFormat('!Y-m-d',$date);
            if(!$d||$d->format('Y-m-d')!==$date||!is_int($valor)||$valor<1||$valor>100000000)throw new BusinessException('Valor ou vencimento inválido.');
            $this->repo->transaction(function()use($m,$valor,$date){
                $pid=(int)$m[1];$this->repo->lockPortal($pid);$a=$this->repo->one('SELECT id FROM assinaturas WHERE id_portal=?',[$pid]);if(!$a)throw new BusinessException('Libere o acesso do gestor para iniciar a assinatura.',409);
                if($this->repo->one("SELECT id FROM charges WHERE portal_id=? AND tipo_cobranca='plataforma' AND due_date=?",[$pid,$date]))throw new BusinessException('Já existe cobrança da plataforma nesse vencimento.',409);
                $this->repo->run('UPDATE assinaturas SET valor_centavos=? WHERE id=?',[$valor,$a['id']]);
                $this->repo->insert('charges',['portal_id'=>$pid,'id_assinatura'=>$a['id'],'tipo_cobranca'=>'plataforma','description'=>'Renovação da assinatura da plataforma','amount_cents'=>$valor,'due_date'=>$date]);$this->repo->audit($this->user,$pid,'subscription.renewed');
            });return $this->json(['ok'=>true]);
        }
        if(preg_match('~^portals/(\d+)/capacity$~',$endpoint,$m)&&$method==='POST'){
            $capacity=(int)($this->body()['capacity']??0);if(($capacity<1||$capacity>10000))throw new BusinessException('Capacidade inválida.');
            $this->repo->transaction(function()use($m,$capacity){$this->repo->lockPortal((int)$m[1]);$count=(int)$this->repo->run("SELECT COUNT(*) FROM publications WHERE portal_id=? AND acesso_liberado_em IS NOT NULL",[(int)$m[1]])->fetchColumn();if($count>$capacity)throw new BusinessException('O limite não pode ser inferior aos espaços com acesso liberado.',409);$this->repo->run('UPDATE portals SET capacity=? WHERE id=?',[$capacity,(int)$m[1]]);$this->repo->audit($this->user,(int)$m[1],'portal.capacity.changed');});return $this->json(['ok'=>true]);
        }
        if($endpoint==='users'&&$method==='GET')return $this->json(['users'=>$this->repo->all("SELECT id,name,email,role,active FROM users WHERE role IN ('manager','master') ORDER BY id")]);
        if($endpoint==='users'&&$method==='POST'){
            $data=$this->body();$email=$this->email($data);$name=$this->text($data,'name',120);$hash=$this->newPassword($data);$role=$data['role']??'';$pid=(int)($data['portal_id']??0);
            if(!in_array($role,['manager','master'],true))throw new BusinessException('Crie anunciantes pelo catálogo da empresa.');
            if($role==='manager'&&!$this->repo->one('SELECT id FROM portals WHERE id=?',[$pid]))throw new BusinessException('Selecione um portal.');
            $valor=$data['valor_assinatura_centavos']??0;if($role==='manager'&&(!is_int($valor)||$valor<1||$valor>100000000))throw new BusinessException('Informe o valor contratado da assinatura.');
            $id=$this->repo->transaction(function()use($email,$name,$hash,$role,$pid,$valor){$id=$this->repo->insert('users',['name'=>$name,'email'=>$email,'password_hash'=>$hash,'role'=>$role,'active'=>1]);if($role==='manager'){
                $this->repo->lockPortal($pid);$this->repo->insert('memberships',['user_id'=>$id,'portal_id'=>$pid]);
                if(!$this->repo->one('SELECT id FROM assinaturas WHERE id_portal=?',[$pid])){
                 $sid=$this->repo->insert('assinaturas',['id_portal'=>$pid,'valor_centavos'=>$valor,'inicio_em'=>gmdate('Y-m-d H:i:s')]);
                 $this->repo->insert('charges',['portal_id'=>$pid,'id_assinatura'=>$sid,'tipo_cobranca'=>'plataforma','description'=>'Assinatura da plataforma','amount_cents'=>$valor,'due_date'=>date('Y-m-d')]);
                }
            }(new \App\Libraries\RelacionamentoService($this->repo))->acesso($id,$email);return $id;});return $this->json(['id'=>$id],201);
        }
        if(preg_match('~^users/(\d+)$~',$endpoint,$m)&&$method==='PUT'){
            $id=(int)$m[1];$data=$this->body();if($id===(int)$this->user['id'])throw new BusinessException('Altere sua própria senha pelo menu Conta.');
            $target=$this->repo->one("SELECT id,name,email,active FROM users WHERE id=? AND role IN ('manager','master')",[$id]);if(!$target)throw new BusinessException('Gestor ou administrador não encontrado.',404);
            $active=$data['active']??(int)$target['active'];if(!is_int($active)||!in_array($active,[0,1],true))throw new BusinessException('Situação inválida.');
            $hash=isset($data['password'])&&$data['password']!==''?$this->newPassword($data):null;
            $this->repo->transaction(function()use($id,$target,$data,$active,$hash){
             $service=new \App\Libraries\OperacaoService($this->repo);$email=$service->emailValido($data['email']??$target['email'],$id);$name=array_key_exists('name',$data)?$this->text($data,'name',120):$target['name'];
             $this->repo->run('UPDATE users SET name=?,email=?,active=?'.($hash?',password_hash=?':'').' WHERE id=?',$hash?[$name,$email,$active,$hash,$id]:[$name,$email,$active,$id]);
             if($email!==$target['email']||$hash)$service->invalidateTokens($id);
             $this->repo->insert('audit_logs',['user_id'=>$this->user['id'],'action'=>'manager.updated']);
            });return $this->json(['ok'=>true]);
        }
        throw new BusinessException('Endpoint não encontrado.',404);
    }
}
