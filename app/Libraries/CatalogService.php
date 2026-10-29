<?php
namespace App\Libraries;
use App\Models\PortalRepository;

class CatalogService
{
    public function __construct(public PortalRepository $repo) {}
    public static function uploadDirectory(): string
    {
        if ((ENVIRONMENT==='testing'||(defined('PORTAL_CGI_TEST')&&PORTAL_CGI_TEST===true)) && env('PORTAL_TEST_UPLOAD_PATH')) return env('PORTAL_TEST_UPLOAD_PATH');
        return WRITEPATH.'uploads';
    }
    public function validate(array $data,bool $consultarHorario=true,?int $portal=null): array
    {
        $out=[];$errors=[];
        $labels=['name'=>'Nome da empresa','service'=>'Serviço principal','description'=>'Apresentação','tags'=>'Palavras-chave','hours'=>'Horário','address'=>'Endereço','area'=>'Área atendida','whatsapp'=>'WhatsApp','instagram'=>'Instagram'];
        foreach(['name'=>120,'service'=>100,'description'=>1500,'tags'=>200,'hours'=>120,'address'=>200,'area'=>200,'whatsapp'=>30,'instagram'=>200] as $key=>$max){
            if(isset($data[$key])&&!is_string($data[$key])){$errors[$key]='Informe um texto válido.';$out[$key]='';continue;}
            $out[$key]=trim($data[$key]??'');
            if(mb_strlen($out[$key])>$max)$errors[$key]=$labels[$key].': use até '.$max.' caracteres.';
            if(in_array($key,['name','service','description','hours'],true)&&$out[$key]==='')$errors[$key]='Preencha '.$labels[$key].'.';
        }
        if(!in_array($data['category']??null,['reformas','beleza','limpeza','alimentacao','jardim'],true))$errors['category']='Selecione uma categoria válida.';
        if(!in_array($data['mode']??null,['A domicílio','Em estabelecimento','Encomendas e retirada'],true))$errors['mode']='Selecione a modalidade de atendimento.';
        $out['category']=$data['category']??'';$out['mode']=$data['mode']??'';
        $phone=preg_replace('/[\s()+.-]/','',$out['whatsapp']);
        if($phone!==''&&!preg_match('/^[1-9][0-9]{9,14}$/D',$phone))$errors['whatsapp']='Informe código do país, DDD e número. Exemplo: 5542999999999.';
        $out['whatsapp']=$phone;
        $instagram=$out['instagram'];
        if(preg_match('~^https://(?:www\.)?instagram\.com/([A-Za-z0-9._]{1,30})/?(?:\?.*)?$~D',$instagram,$m))$instagram=$m[1];
        $instagram=ltrim($instagram,'@');
        if($instagram!==''&&!preg_match('/^[A-Za-z0-9._]{1,30}$/D',$instagram))$errors['instagram']='Use @usuario ou o link https://www.instagram.com/usuario/.';
        $out['instagram']=$instagram;
        $services=$data['services']??[];
        if(!is_array($services)||!array_is_list($services)||count($services)<1||count($services)>20)$errors['services']='Informe de 1 a 20 serviços, um por linha.';
        else foreach($services as $service)if(!is_string($service)||trim($service)===''||mb_strlen($service)>150){$errors['services']='Cada serviço deve conter de 1 a 150 caracteres.';break;}
        $out['id_horario']=$data['id_horario']??null;
        if($consultarHorario&&$portal!==null){
            $horario=$this->repo->one('SELECT id,descricao FROM horarios_atendimento WHERE id_portal=? AND descricao=? AND ativo=1',[$portal,$out['hours']]);
            if(!$horario)$errors['hours']='Selecione um horário cadastrado pelo gestor.';
            else {$out['hours']=$horario['description'];$out['id_horario']=(int)$horario['id'];}
        }
        if($errors)throw new BusinessException('Revise os campos indicados.',422,$errors);
        $out['services']=json_encode(array_map('trim',$services),JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
        return $out;
    }
    private function draft(array $row,array $user,?array $proposta=null): array
    {
        $latest=$this->repo->latestRevision((int)$row['id']);
        if($latest&&$latest['status']==='pending')return $latest;
        $row['services']=is_array($row['services'])?$row['services']:json_decode($row['services'],true,32,JSON_THROW_ON_ERROR);
        $payload=$latest&&$latest['status']==='rejected'?$latest['payload']:json_encode($proposta??$this->validate($row,false),JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
        $rid=$this->repo->insert('publication_revisions',['publication_id'=>$row['id'],'author_id'=>$user['id'],'payload'=>$payload,'status'=>'pending','version'=>1]);
        $images=$latest&&$latest['status']==='rejected'?$this->repo->all('SELECT filename,mime,slot,caption FROM revision_images WHERE revision_id=?',[$latest['id']]):$this->repo->all('SELECT filename,mime,slot,caption FROM publication_images WHERE publication_id=?',[$row['id']]);
        foreach($images as $image)$this->repo->insert('revision_images',['revision_id'=>$rid]+$image);
        return $this->repo->one('SELECT * FROM publication_revisions WHERE id=?',[$rid]);
    }
    private function touchRevision(int $id,array $user,?array $payload=null): void
    {
        $sets='author_id=?,version=version+1,submitted_at=CURRENT_TIMESTAMP';$params=[$user['id']];
        if($payload!==null){$sets.=',payload=?';$params[]=json_encode($payload,JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);}
        $this->repo->run('UPDATE publication_revisions SET '.$sets.' WHERE id=?',[...$params,$id]);
    }
    public function save(array $user,array $portal,array $input,?int $id): int
    {
        $this->repo->authorize($user,(int)$portal['id'],!$id);$data=$this->validate($input,true,(int)$portal['id']);
        return $this->repo->transaction(function()use($user,$portal,$data,$id){
            $this->repo->lockPortal((int)$portal['id']);
            if(!$id){
                $advertiser=$this->repo->insert('advertisers',['name'=>$data['name']]);
                $id=$this->repo->insert('publications',$data+['portal_id'=>$portal['id'],'advertiser_id'=>$advertiser,'status'=>'pending']);
            }
            $row=$this->repo->publication($id,(int)$portal['id'],$user);$draft=$this->draft($row,$user,$data);
            $this->touchRevision((int)$draft['id'],$user,$data);
            $this->repo->audit($user,(int)$portal['id'],'catalog.submitted',$id);return $id;
        });
    }
    public function review(array $user,array $portal,int $id,array $input): void
    {
        $this->repo->authorize($user,(int)$portal['id'],true);
        $decision=$input['decision']??'';if(!in_array($decision,['approve','reject'],true))throw new BusinessException('Decisão inválida.');
        $note=$input['note']??'';if(!is_string($note)||mb_strlen($note)>1000)throw new BusinessException('Motivo inválido.');
        if($decision==='reject'&&trim($note)==='')throw new BusinessException('Informe o motivo da devolução.');
        $this->repo->transaction(function()use($user,$portal,$id,$input,$decision,$note){
            $locked=$this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);
            $revision=$this->repo->latestRevision($id);
            if(!$revision||$revision['status']!=='pending'||(int)$revision['id']!==(int)($input['revision_id']??0)||(int)$revision['version']!==(int)($input['version']??0))throw new BusinessException('Esta proposta foi alterada ou já foi analisada. Atualize a revisão antes de decidir.',409);
            if($decision==='approve'){
                (new ComercialService($this->repo))->publicarPrimeiraVez($row,$user);
                $candidate=json_decode($revision['payload'],true,32,JSON_THROW_ON_ERROR);
                if(is_string($candidate['services']??null))$candidate['services']=json_decode($candidate['services'],true,32,JSON_THROW_ON_ERROR);
                $data=$this->validate($candidate,false);
                $sets=array_map(fn($key)=>$key.'=?',array_keys($data));
                $this->repo->run("UPDATE publications SET ".implode(',',$sets).",status='published',updated_at=CURRENT_TIMESTAMP WHERE id=?",[...array_values($data),$id]);
                $this->repo->run('DELETE FROM publication_images WHERE publication_id=?',[$id]);
                foreach($this->repo->all('SELECT filename,mime,slot,caption FROM revision_images WHERE revision_id=? ORDER BY slot',[$revision['id']]) as $image)$this->repo->insert('publication_images',['publication_id'=>$id]+$image);
            }
            $this->repo->run('UPDATE publication_revisions SET status=?,reviewer_id=?,review_note=?,reviewed_at=CURRENT_TIMESTAMP WHERE id=?',[$decision==='approve'?'approved':'rejected',$user['id'],trim($note),$revision['id']]);
            $this->repo->audit($user,(int)$portal['id'],'catalog.'.($decision==='approve'?'approved':'rejected'),$id);
        });
    }
    public function status(array $user,array $portal,int $id,string $status,string $motivo=''): void
    {
        $this->repo->authorize($user,(int)$portal['id'],true);
        if(!in_array($status,['published','suspended','archived'],true))throw new BusinessException('Situação inválida.');
        if(in_array($status,['suspended','archived'],true)&&(trim($motivo)===''||mb_strlen($motivo)>1000))throw new BusinessException('Informe o motivo da despublicação.',422,['motivo'=>'Informe o motivo (até 1000 caracteres).']);
        $this->repo->transaction(function()use($user,$portal,$id,$status,$motivo){
            $locked=$this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);
            if($status==='published'){
                if(!$row['primeira_publicacao_em'])throw new BusinessException('A primeira publicação exige aprovação explícita.',409);
                $revision=$this->repo->latestRevision($id);
                if(($revision&&$revision['status']==='pending')||$row['status']==='pending')throw new BusinessException('Analise e aprove a proposta antes de publicar.',409);
            }
            if($status!=='published')$this->repo->run('UPDATE publications SET motivo_despublicacao=?,despublicado_em=CURRENT_TIMESTAMP WHERE id=?',[trim($motivo),$id]);
            $this->repo->run('UPDATE publications SET status=?,updated_at=CURRENT_TIMESTAMP WHERE id=?',[$status,$id]);$this->repo->audit($user,(int)$portal['id'],'catalog.'.$status,$id);
        });
    }
    public function upload(array $user,array $portal,int $id,array $files): array
    {
        $this->repo->publication($id,(int)$portal['id'],$user);
        if(count($files)<1||count($files)>3)throw new BusinessException('Envie de 1 a 3 imagens.',422,['images'=>'Envie de 1 a 3 imagens.']);
        $validated=[];
        foreach($files as $file){
            if(!$file->isValid()||$file->getSize()>5*1024*1024)throw new BusinessException('Cada imagem deve ter até 5 MB e ser enviada corretamente.',422,['images'=>'Cada imagem deve ter até 5 MB e ser enviada corretamente.']);
            $info=@getimagesize($file->getTempName());$mime=(new \finfo(FILEINFO_MIME_TYPE))->file($file->getTempName());
            if(!$info||!in_array($mime,['image/jpeg','image/png','image/webp'],true)||($info['mime']??'')!==$mime||$info[0]>6000||$info[1]>6000)throw new BusinessException('Use JPG, PNG ou WebP de até 6000 × 6000 pixels.',422,['images'=>'Use JPG, PNG ou WebP de até 6000 × 6000 pixels.']);
            $validated[]=[$file,$mime];
        }
        $written=[];
        try{return $this->repo->transaction(function()use($user,$portal,$id,$validated,&$written){
            $this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);$draft=$this->draft($row,$user);
            $used=array_map('intval',array_column($this->repo->all('SELECT slot FROM revision_images WHERE revision_id=?',[$draft['id']]),'slot'));
            if(count($used)+count($validated)>3)throw new BusinessException('A empresa pode ter no máximo 3 imagens por versão. Remova uma antes de substituir.',409,['images'=>'A empresa pode ter no máximo 3 imagens por versão. Remova uma antes de substituir.']);
            foreach($validated as [$file,$mime]){
                $free=array_values(array_diff([1,2,3],$used));$slot=$free[0];$used[]=$slot;
                $ext=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$mime];$name=bin2hex(random_bytes(24)).'.'.$ext;
                $directory=self::uploadDirectory();if(!is_dir($directory))mkdir($directory,0700,true);
                $file->move($directory,$name);$written[]=$directory.DIRECTORY_SEPARATOR.$name;
                $this->repo->insert('revision_images',['revision_id'=>$draft['id'],'filename'=>$name,'mime'=>$mime,'slot'=>$slot,'caption'=>['','Loja ou apresentação','Fachada','Operação de trabalho'][$slot]]);
            }
            $this->touchRevision((int)$draft['id'],$user);$this->repo->audit($user,(int)$portal['id'],'catalog.images.submitted',$id);
            return $this->repo->shape($row,true);
        });}catch(\Throwable $e){foreach($written as $file)if(is_file($file))unlink($file);throw $e;}
    }
    public function deleteImage(array $user,array $portal,int $id,int $imageId,string $source='draft'): void
    {
        $this->repo->transaction(function()use($user,$portal,$id,$imageId,$source){
            $this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);
            $latest=$this->repo->latestRevision($id);$image=null;
            if($source==='draft'&&$latest&&in_array($latest['status'],['pending','rejected'],true))$image=$this->repo->one('SELECT * FROM revision_images WHERE id=? AND revision_id=?',[$imageId,$latest['id']]);
            elseif($source==='public')$image=$this->repo->one('SELECT * FROM publication_images WHERE id=? AND publication_id=?',[$imageId,$id]);
            if(!$image)throw new BusinessException('Imagem não encontrada nesta versão.',404);
            $draft=$this->draft($row,$user);
            $this->repo->run('DELETE FROM revision_images WHERE revision_id=? AND slot=? AND filename=?',[$draft['id'],$image['slot'],$image['filename']]);
            $this->touchRevision((int)$draft['id'],$user);$this->repo->audit($user,(int)$portal['id'],'catalog.image.removal.submitted',$id);
            // O arquivo aprovado permanece intacto. Histórico e versão pública podem referenciá-lo.
        });
    }
    public function setCover(array $user,array $portal,int $id,int $imageId,string $source): void
    {
        $this->repo->transaction(function()use($user,$portal,$id,$imageId,$source){
            $this->repo->lockPortal((int)$portal['id']);$row=$this->repo->publication($id,(int)$portal['id'],$user);$latest=$this->repo->latestRevision($id);
            $image=$source==='draft'&&$latest?$this->repo->one('SELECT filename FROM revision_images WHERE id=? AND revision_id=?',[$imageId,$latest['id']]):($source==='public'?$this->repo->one('SELECT filename FROM publication_images WHERE id=? AND publication_id=?',[$imageId,$id]):null);
            if(!$image)throw new BusinessException('Imagem não encontrada nesta versão.',404);
            $draft=$this->draft($row,$user);$images=$this->repo->all('SELECT filename,mime,caption FROM revision_images WHERE revision_id=? ORDER BY slot',[$draft['id']]);
            $position=array_search($image['filename'],array_column($images,'filename'),true);
            if($position===false)throw new BusinessException('Imagem não está mais na proposta. Atualize o catálogo.',409);
            $cover=array_splice($images,$position,1)[0];array_unshift($images,$cover);
            $this->repo->run('DELETE FROM revision_images WHERE revision_id=?',[$draft['id']]);
            foreach($images as $i=>$item)$this->repo->insert('revision_images',['revision_id'=>$draft['id'],'slot'=>$i+1]+$item);
            $this->touchRevision((int)$draft['id'],$user);$this->repo->audit($user,(int)$portal['id'],'catalog.cover.submitted',$id);
        });
    }
}
