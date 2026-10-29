<?php
namespace App\Libraries;

use PDO;
use RuntimeException;

/** Migração retomável de identificadores: não exclui tabelas nem registros. */
final class MigradorNomesBanco
{
    public function __construct(private PDO $db,private string $directory) {}
    private function quote(string $name): string { return '`'.str_replace('`','``',$name).'`'; }
    private function rows(string $sql,array $args=[]): array { $q=$this->db->prepare($sql);$q->execute($args);return $q->fetchAll(PDO::FETCH_ASSOC); }
    private function tables(): array { return array_column($this->rows('SHOW TABLES'),array_key_first($this->rows('SHOW TABLES')[0]??['tabela'=>null])); }
    private function columns(string $table): array { return $this->rows('SHOW FULL COLUMNS FROM '.$this->quote($table)); }
    private function definition(array $c): string
    {
        $definition=$c['Type'];
        if($c['Collation']){
            $charset=strtok($c['Collation'],'_');
            if(!preg_match('/^[a-zA-Z0-9_]+$/D',$c['Collation'])||!preg_match('/^[a-zA-Z0-9]+$/D',$charset))throw new RuntimeException('Collation inesperada.');
            $definition.=' CHARACTER SET '.$charset.' COLLATE '.$c['Collation'];
        }
        $definition.=$c['Null']==='YES'?' NULL':' NOT NULL';
        if($c['Default']!==null){
            $default=(string)$c['Default'];
            $definition.=' DEFAULT '.(preg_match('/^current_timestamp(?:\(\d*\))?$/iD',$default)?$default:$this->db->quote($default));
        }elseif($c['Null']==='YES')$definition.=' DEFAULT NULL';
        $extra=trim(str_ireplace('DEFAULT_GENERATED','',$c['Extra']));
        if(preg_match('/generated/i',$extra))throw new RuntimeException('Coluna gerada requer migração específica: '.$c['Field']);
        if($extra!=='')$definition.=' '.$extra;
        if($c['Comment']!=='')$definition.=' COMMENT '.$this->db->quote($c['Comment']);
        return $definition;
    }
    private function backup(array $tables): string
    {
        $path=$this->directory.'/backup-'.date('Ymd-His').'-'.bin2hex(random_bytes(3)).'.sql';
        $file=fopen($path,'xb');if(!$file)throw new RuntimeException('Não foi possível criar backup.');
        try{
            fwrite($file,"-- Backup antes da tradução. Restaurar em base vazia.\nSET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS=0;\n");
            foreach($tables as $table){
                $create=$this->rows('SHOW CREATE TABLE '.$this->quote($table))[0]['Create Table'];
                fwrite($file,$create.";\n");
                $q=$this->db->query('SELECT * FROM '.$this->quote($table),PDO::FETCH_ASSOC);
                while($row=$q->fetch()){
                    $values=array_map(fn($v)=>$v===null?'NULL':$this->db->quote((string)$v),array_values($row));
                    fwrite($file,'INSERT INTO '.$this->quote($table).' ('.implode(',',array_map([$this,'quote'],array_keys($row))).') VALUES ('.implode(',',$values).");\n");
                }
            }
            fwrite($file,"SET FOREIGN_KEY_CHECKS=1;\n");
        }finally{fclose($file);}
        return $path;
    }
    private function constraints(string $database): array
    {
        return $this->rows("SELECT k.TABLE_NAME AS tabela,k.CONSTRAINT_NAME AS restricao,k.COLUMN_NAME AS coluna,k.REFERENCED_TABLE_NAME AS referencia,k.REFERENCED_COLUMN_NAME AS coluna_referenciada,k.ORDINAL_POSITION AS ordem,r.UPDATE_RULE AS atualizacao,r.DELETE_RULE AS exclusao FROM information_schema.KEY_COLUMN_USAGE k JOIN information_schema.REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND r.CONSTRAINT_NAME=k.CONSTRAINT_NAME AND r.TABLE_NAME=k.TABLE_NAME WHERE k.CONSTRAINT_SCHEMA=? AND k.REFERENCED_TABLE_NAME IS NOT NULL ORDER BY k.TABLE_NAME,k.CONSTRAINT_NAME,k.ORDINAL_POSITION",[$database]);
    }
    private function checks(string $database): array
    {
        $join=str_contains(strtolower((string)$this->db->getAttribute(PDO::ATTR_SERVER_VERSION)),'mariadb')?' AND c.TABLE_NAME=t.TABLE_NAME':'';
        return $this->rows("SELECT t.TABLE_NAME AS tabela,t.CONSTRAINT_NAME AS restricao,c.CHECK_CLAUSE AS expressao FROM information_schema.TABLE_CONSTRAINTS t JOIN information_schema.CHECK_CONSTRAINTS c ON c.CONSTRAINT_SCHEMA=t.CONSTRAINT_SCHEMA AND c.CONSTRAINT_NAME=t.CONSTRAINT_NAME".$join." WHERE t.CONSTRAINT_SCHEMA=? AND t.CONSTRAINT_TYPE='CHECK' ORDER BY t.TABLE_NAME,t.CONSTRAINT_NAME",[$database]);
    }
    public function run(): array
    {
        $map=NomesBanco::mapa();$tables=$this->tables();$database=(string)$this->db->query('SELECT DATABASE()')->fetchColumn();
        if(!is_dir($this->directory)&&!mkdir($this->directory,0700,true))throw new RuntimeException('Diretório de migração indisponível.');
        $stateFile=$this->directory.'/estado.json';$state=is_file($stateFile)?json_decode(file_get_contents($stateFile),true,512,JSON_THROW_ON_ERROR):null;
        if($state&&$state['situacao']==='pendente'&&$state['banco']!==$database)throw new RuntimeException('A migração pendente pertence a outra base.');
        if(!$state||$state['situacao']!=='pendente'){
            $managed=[];$change=false;
            foreach($map['tabelas'] as $old=>$new){
                if(in_array($old,$tables,true)&&in_array($new,$tables,true))throw new RuntimeException("Existem tabelas $old e $new. A migração foi interrompida para não misturar registros.");
                $current=in_array($old,$tables,true)?$old:(in_array($new,$tables,true)?$new:null);
                if(!$current)continue;$managed[]=$current;
                if($current===$old)$change=true;
                foreach($this->columns($current) as $c)if(isset($map['colunas'][$c['Field']]))$change=true;
            }
            if(!$change)return ['alterado'=>false,'banco'=>$database];
            $foreign=$this->constraints($database);
            foreach($foreign as $fk)if(in_array($fk['referencia'],$managed,true)&&!in_array($fk['tabela'],$managed,true))throw new RuntimeException('Uma tabela externa referencia o catálogo; revise essa dependência antes da migração.');
            $foreign=array_values(array_filter($foreign,fn($fk)=>in_array($fk['tabela'],$managed,true)));
            $checks=array_values(array_filter($this->checks($database),fn($check)=>in_array($check['tabela'],$managed,true)));
            $counts=[];foreach($managed as $table)$counts[$table]=(int)$this->db->query('SELECT COUNT(*) FROM '.$this->quote($table))->fetchColumn();
            $state=['situacao'=>'pendente','banco'=>$database,'backup'=>$this->backup($managed),'contagens'=>$counts,'chaves'=>$foreign,'verificacoes'=>$checks];
            file_put_contents($stateFile,json_encode($state,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE),LOCK_EX);
        }
        $currentForeign=$this->constraints($database);
        $managedNames=array_merge(array_keys($state['contagens']),array_map(fn($t)=>$map['tabelas'][$t]??$t,array_keys($state['contagens'])));
        $dropped=[];
        foreach($currentForeign as $fk){
            if(!in_array($fk['tabela'],$managedNames,true))continue;
            $key=$fk['tabela'].'/'.$fk['restricao'];if(isset($dropped[$key]))continue;
            $this->db->exec('ALTER TABLE '.$this->quote($fk['tabela']).' DROP FOREIGN KEY '.$this->quote($fk['restricao']));$dropped[$key]=true;
        }
        $maria=str_contains(strtolower((string)$this->db->getAttribute(PDO::ATTR_SERVER_VERSION)),'mariadb');
        foreach($this->checks($database) as $check)if(in_array($check['tabela'],$managedNames,true))$this->db->exec('ALTER TABLE '.$this->quote($check['tabela']).($maria?' DROP CONSTRAINT ':' DROP CHECK ').$this->quote($check['restricao']));
        $tables=$this->tables();$renames=[];
        foreach($map['tabelas'] as $old=>$new)if(in_array($old,$tables,true)){
            if(in_array($new,$tables,true))throw new RuntimeException('Destino já existe: '.$new);
            $renames[]=$this->quote($old).' TO '.$this->quote($new);
        }
        if($renames)$this->db->exec('RENAME TABLE '.implode(',',$renames));
        foreach(array_keys($state['contagens']) as $old){
            $table=$map['tabelas'][$old]??$old;$columns=$this->columns($table);$names=array_column($columns,'Field');
            foreach($columns as $c){
                $name=$c['Field'];if(!isset($map['colunas'][$name]))continue;$new=$map['colunas'][$name];
                if(in_array($new,$names,true))throw new RuntimeException("Colunas duplicadas em $table: $name / $new");
                $this->db->exec('ALTER TABLE '.$this->quote($table).' CHANGE COLUMN '.$this->quote($name).' '.$this->quote($new).' '.$this->definition($c));
            }
            // Os nomes internos de índices existentes são preservados (compatibilidade MariaDB 10.4).
        }
        $grouped=[];
        foreach($state['chaves'] as $fk)$grouped[$fk['tabela'].'/'.$fk['restricao']][]=$fk;
        foreach($grouped as $list){
            $f=$list[0];$table=$map['tabelas'][$f['tabela']]??$f['tabela'];$reference=$map['tabelas'][$f['referencia']]??$f['referencia'];
            $columns=array_map(fn($v)=>$this->quote($map['colunas'][$v['coluna']]??$v['coluna']),$list);
            $refs=array_map(fn($v)=>$this->quote($map['colunas'][$v['coluna_referenciada']]??$v['coluna_referenciada']),$list);
            foreach(['atualizacao','exclusao'] as $rule)if(!in_array($f[$rule],['RESTRICT','CASCADE','SET NULL','NO ACTION'],true))throw new RuntimeException('Regra referencial inesperada.');
            $constraint=strtr($f['restricao'],$map['tabelas']);
            $this->db->exec('ALTER TABLE '.$this->quote($table).' ADD CONSTRAINT '.$this->quote($constraint).' FOREIGN KEY ('.implode(',',$columns).') REFERENCES '.$this->quote($reference).' ('.implode(',',$refs).') ON UPDATE '.$f['atualizacao'].' ON DELETE '.$f['exclusao']);
        }
        foreach($state['verificacoes'] as $i=>$check){
            $table=$map['tabelas'][$check['tabela']]??$check['tabela'];
            $this->db->exec('ALTER TABLE '.$this->quote($table).' ADD CONSTRAINT '.$this->quote('chk_'.$table.'_'.$i).' CHECK ('.NomesBanco::sql($check['expressao']).')');
        }
        foreach($state['contagens'] as $old=>$count){$table=$map['tabelas'][$old]??$old;$after=(int)$this->db->query('SELECT COUNT(*) FROM '.$this->quote($table))->fetchColumn();if($after!==$count)throw new RuntimeException('Contagem divergente em '.$table);}
        $state['situacao']='concluida';file_put_contents($stateFile,json_encode($state,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE),LOCK_EX);
        return ['alterado'=>true,'banco'=>$database,'backup'=>$state['backup'],'tabelas'=>count($state['contagens'])];
    }
}
