<?php
namespace App\Commands;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use PDO;
use App\Libraries\NomesBanco;
use App\Libraries\MigradorNomesBanco;

class InstallPortal extends BaseCommand
{
    protected $group='Portal';
    protected $name='portal:install';
    protected $description='Cria a estrutura MySQL e os acessos iniciais sem apagar dados existentes.';
    public function run(array $params)
    {
        try{
            $database=env('database.default.database','portal_bairro');
            if(!preg_match('/^[a-zA-Z0-9_]+$/D',$database))throw new \RuntimeException('Nome de banco inválido.');
            $pdo=new PDO('mysql:host='.env('database.default.hostname','127.0.0.1').';port='.env('database.default.port',3306).';charset=utf8mb4',env('database.default.username','root'),env('database.default.password',''),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
            $exists=$pdo->prepare('SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=?');$exists->execute([$database]);
            $databaseExists=(bool)$exists->fetchColumn();
            if($databaseExists){
                $pdo->exec('USE `'.$database.'`');
                $migration=(new MigradorNomesBanco($pdo,WRITEPATH.'migracoes/'.$database))->run();
                if($migration['alterado'])CLI::write('Banco traduzido; backup em '.$migration['backup'],'green');
            }
            $sql=str_replace('portal_bairro',$database,file_get_contents(ROOTPATH.'database/mysql.sql'));
            $sql=preg_replace('/^--.*$/m','',$sql);
            if($databaseExists)$sql=preg_replace('/CREATE DATABASE IF NOT EXISTS[^;]+;/i','',$sql);
            foreach(explode(';',$sql) as $statement)if(trim($statement)!=='')$pdo->exec($statement);
            \App\Libraries\AtualizarOperacao::run($pdo);
            if((int)$pdo->query(NomesBanco::sql('SELECT COUNT(*) FROM users'))->fetchColumn()>0){$this->prepareReviewDefaults($pdo);CLI::write('Estrutura atualizada. Revisões preparadas e contas existentes preservadas.','green');return;}
            if(in_array('--sem-portal',$params,true)||CLI::getOption('sem-portal')){$this->prepareReviewDefaults($pdo);CLI::write('Administrador preparado sem vitrine. Entre em /admin para criar o primeiro portal.','green');return;}
            $pdo->beginTransaction();
            $pdo->exec(NomesBanco::sql("INSERT INTO organizations(name) VALUES('Annecont Contabilidade')"));
            $oid=(int)$pdo->lastInsertId();
            $pdo->prepare(NomesBanco::sql("INSERT INTO portals(organization_id,slug,name,capacity) VALUES(?,'annecont','Vitrine Annecont',10)"))->execute([$oid]);
            $pdo->commit();\App\Libraries\AtualizarOperacao::run($pdo);$this->prepareReviewDefaults($pdo);
            CLI::write('Instalado sem anunciantes fictícios. Cadastre o gestor e as empresas pelo painel master.','green');
        }catch(\Throwable $e){if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();CLI::error('Instalação não concluída: '.$e->getMessage());return EXIT_ERROR;}
    }
    private function prepareReviewDefaults(PDO $pdo): void
    {
        $account=$pdo->query(NomesBanco::sql("SELECT id,role FROM users WHERE email='admin@portal.local'"))->fetch(PDO::FETCH_ASSOC);
        if(!$account){
            $q=$pdo->prepare(NomesBanco::sql("INSERT INTO users(name,email,password_hash,role,active) VALUES('Administrador','admin@portal.local',?,'master',1)"));$q->execute([password_hash('1234',PASSWORD_DEFAULT)]);
            $account=['id'=>(int)$pdo->lastInsertId(),'role'=>'master'];
            if(!str_starts_with((string)$pdo->query('SELECT DATABASE()')->fetchColumn(),'portal_prd_teste_'))file_put_contents(WRITEPATH.'ACESSOS_LOCAIS.txt',"\nAdministrador local: /admin\nUsuário: admin\nSenha inicial: 1234\n",FILE_APPEND|LOCK_EX);
        }
        $repo=new \App\Models\PortalRepository($pdo);$service=new \App\Libraries\CatalogService($repo);
        $user=$repo->one("SELECT id,role,advertiser_id FROM users WHERE id=?",[$account['id']]);
        foreach($repo->all("SELECT * FROM publications WHERE status='pending'") as $row){
            if(trim($row['service'])===''||$repo->latestRevision((int)$row['id']))continue;
            $row['services']=json_decode($row['services'],true,32,JSON_THROW_ON_ERROR);
            $portal=$repo->one('SELECT * FROM portals WHERE id=?',[$row['portal_id']]);
            $service->save($user,$portal,$row,(int)$row['id']);
        }
    }
}
