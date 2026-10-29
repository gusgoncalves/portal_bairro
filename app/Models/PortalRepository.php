<?php
namespace App\Models;

use PDO;
use App\Libraries\NomesBanco;
use App\Libraries\BusinessException;

/** Repositório PDO: consultas preparadas e transações compartilhadas pelos serviços. */
class PortalRepository
{
    public PDO $db;
    public function __construct(?PDO $connection = null)
    {
        if ($connection) {
            $this->db = $connection;
            $this->db->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
            $this->db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE,PDO::FETCH_ASSOC);
            if($this->mysql()){$this->db->setAttribute(PDO::ATTR_EMULATE_PREPARES,false);$this->db->exec("SET time_zone='+00:00'");}
            return;
        }
        // Banco de teste somente no ambiente testing. A aplicação real usa MySQL.
        $test = (ENVIRONMENT === 'testing' || (defined('PORTAL_CGI_TEST') && PORTAL_CGI_TEST === true)) ? env('PORTAL_TEST_DB') : null;
        if ($test) $this->db = new PDO('sqlite:' . $test);
        else $this->db = new PDO('mysql:host='.env('database.default.hostname','127.0.0.1').';port='.env('database.default.port',3306).';dbname='.env('database.default.database','portal_bairro').';charset=utf8mb4', env('database.default.username','root'), env('database.default.password',''));
        $this->db->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
        $this->db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE,PDO::FETCH_ASSOC);
        if ($this->mysql()) {$this->db->setAttribute(PDO::ATTR_EMULATE_PREPARES,false);$this->db->exec("SET time_zone='+00:00'");}
        else $this->db->exec('PRAGMA foreign_keys=ON; PRAGMA busy_timeout=5000;');
    }
    public function mysql(): bool { return $this->db->getAttribute(PDO::ATTR_DRIVER_NAME)==='mysql'; }
    public function run(string $sql,array $params=[]): \PDOStatement { $q=$this->db->prepare(NomesBanco::sql($sql));$q->execute($params);return $q; }
    public function one(string $sql,array $params=[]): ?array { $row=$this->run($sql,$params)->fetch();return $row?NomesBanco::registro($row):null; }
    public function all(string $sql,array $params=[]): array { return array_map([NomesBanco::class,'registro'],$this->run($sql,$params)->fetchAll()); }
    public function insert(string $table,array $values): int
    {
        // Nomes de tabelas/colunas vêm somente do código, nunca da requisição.
        $keys=array_keys($values);
        $this->run('INSERT INTO '.$table.' ('.implode(',',$keys).') VALUES ('.implode(',',array_fill(0,count($keys),'?')).')',array_values($values));
        return (int)$this->db->lastInsertId();
    }
    public function transaction(callable $action): mixed
    {
        $this->db->beginTransaction();
        try { $result=$action();$this->db->commit();return $result; }
        catch(\Throwable $e) { if($this->db->inTransaction())$this->db->rollBack();throw $e; }
    }
    public function portal(string $slug): array
    {
        $portal=$this->one('SELECT * FROM portals WHERE slug=? AND active=1',[$slug]);
        if(!$portal)throw new BusinessException('Portal não encontrado.',404);
        return $portal;
    }
    public function lockPortal(int $id): array
    {
        $portal=$this->one('SELECT * FROM portals WHERE id=?'.($this->mysql()?' FOR UPDATE':''),[$id]);
        if(!$portal || !$portal['active'])throw new BusinessException('Portal não disponível.',404);
        return $portal;
    }
    public function audit(array $user,int $portal,string $action,?int $publication=null): void
    {
        $this->insert('audit_logs',['user_id'=>$user['id'],'portal_id'=>$portal,'action'=>$action,'publication_id'=>$publication]);
    }
    public function authorize(?array $user,int $portal,bool $manager=false): void
    {
        if(!$user)throw new BusinessException('Entre na sua conta.',401);
        if($user['role']==='master')return;
        if($manager && $user['role']!=='manager')throw new BusinessException('Acesso não permitido.',403);
        if(!$this->one('SELECT 1 FROM memberships WHERE user_id=? AND portal_id=? AND active=1',[$user['id'],$portal]))throw new BusinessException('Portal não autorizado.',403);
    }
    public function publication(int $id,int $portal,?array $user): array
    {
        $this->authorize($user,$portal);
        $row=$this->one('SELECT * FROM publications WHERE id=? AND portal_id=?',[$id,$portal]);
        if(!$row)throw new BusinessException('Empresa não encontrada.',404);
        if($user['role']==='advertiser' && (int)$row['advertiser_id']!==(int)$user['advertiser_id'])throw new BusinessException('Este catálogo não pertence à sua conta.',403);
        return $row;
    }
    public function latestRevision(int $publication): ?array
    {
        return $this->one('SELECT r.*,u.name AS author_name,v.name AS reviewer_name FROM publication_revisions r JOIN users u ON u.id=r.author_id LEFT JOIN users v ON v.id=r.reviewer_id WHERE r.publication_id=? ORDER BY r.id DESC LIMIT 1',[$publication]);
    }
    public function shape(array $row,bool $draft=false): array
    {
        $revision=$draft?$this->latestRevision((int)$row['id']):null;
        $overlay=$revision&&in_array($revision['status'],['pending','rejected'],true);
        if($overlay)$row=array_replace($row,json_decode($revision['payload'],true,32,JSON_THROW_ON_ERROR));
        $out=array_intersect_key($row,array_flip(['id','name','category','service','description','tags','color','accent','type','mode','hours','address','area','whatsapp','instagram','status']));
        $out['id']=(int)$out['id'];
        $out['services']=is_array($row['services'])?$row['services']:json_decode($row['services'],true,32,JSON_THROW_ON_ERROR);
        if($overlay){
            $images=$this->all('SELECT id,caption,slot FROM revision_images WHERE revision_id=? ORDER BY slot',[$revision['id']]);$media='revision-media/';
        }else{
            $images=$this->all('SELECT id,caption,slot FROM publication_images WHERE publication_id=? ORDER BY slot',[$row['id']]);$media='media/';
        }
        $out['images']=array_map(fn($i)=>['id'=>(int)$i['id'],'url'=>$media.$i['id'],'caption'=>$i['caption'],'slot'=>(int)$i['slot'],'source'=>$overlay?'draft':'public'],$images);
        $out['art']=$out['images'][0]['url']??'';
        $rating=$this->one('SELECT COUNT(*) AS quantidade,AVG(estrelas) AS media FROM avaliacoes WHERE id_anuncio=?',[$row['id']]);$n=(int)$rating['quantidade'];$avg=(float)($rating['media']??0);$peso=max(1,min(100,(int)env('portal.pesoAvaliacao',5)));$base=max(1,min(5,(float)env('portal.notaBase',3)));$out['avaliacao']=['quantidade'=>$n,'media'=>round($avg,2),'pontuacao'=>($n*$avg+$peso*$base)/($n+$peso)];
        if($draft){
            foreach(['acesso_liberado_em','primeira_publicacao_em','mensalidade_centavos','dias_periodo','motivo_despublicacao'] as $key)$out[$key]=$row[$key];
            $out['periodo']=$this->one('SELECT inicio_em,fim_em FROM periodos_publicacao WHERE id_anuncio=? ORDER BY fim_em DESC LIMIT 1',[$row['id']]);
            $out['revision']=$revision?['id'=>(int)$revision['id'],'version'=>(int)$revision['version'],'status'=>$revision['status'],'note'=>$revision['review_note'],'submitted_at'=>$revision['submitted_at'],'author'=>$revision['author_name'],'reviewer'=>$revision['reviewer_name']]:null;
            $out['has_pending']=$revision&&$revision['status']==='pending';
        }
        return $out;
    }
}
