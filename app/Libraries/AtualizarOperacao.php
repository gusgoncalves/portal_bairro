<?php
namespace App\Libraries;
use PDO;
final class AtualizarOperacao
{
 public static function run(PDO $pdo):void {
  $pdo->exec(file_get_contents(ROOTPATH.'database/atualizacao_configuracoes_email.sql'));
  $fields=['portais'=>['endereco_local'=>"VARCHAR(250) NOT NULL DEFAULT ''",'cor_texto'=>"VARCHAR(7) NOT NULL DEFAULT '#FFFFFF'",'fonte'=>"VARCHAR(30) NOT NULL DEFAULT 'Inter'"],'usuarios_portais'=>['ativo'=>'TINYINT NOT NULL DEFAULT 1'],'anuncios'=>['id_horario'=>'INT UNSIGNED NULL']];
  foreach($fields as $table=>$columns){$existing=$pdo->query("SHOW COLUMNS FROM `$table`")->fetchAll(PDO::FETCH_COLUMN);foreach($columns as $column=>$ddl)if(!in_array($column,$existing,true))$pdo->exec("ALTER TABLE `$table` ADD `$column` $ddl");}
  // Converte bloqueios antigos do usuário anunciante em bloqueios de vínculo, sem liberar acesso.
  $pdo->beginTransaction();try{
   $pdo->exec("UPDATE usuarios_portais m JOIN usuarios u ON u.id=m.id_usuario SET m.ativo=0 WHERE u.perfil='advertiser' AND u.ativo=0");
   $pdo->exec("UPDATE usuarios u SET u.ativo=1 WHERE u.perfil='advertiser' AND u.ativo=0 AND EXISTS(SELECT 1 FROM usuarios_portais m WHERE m.id_usuario=u.id)");
   $pdo->commit();
  }catch(\Throwable $e){$pdo->rollBack();throw $e;}
  $pdo->exec("CREATE TABLE IF NOT EXISTS horarios_atendimento (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,id_portal INT UNSIGNED NOT NULL,descricao VARCHAR(120) NOT NULL,dias_semana VARCHAR(20) NULL,hora_inicio VARCHAR(5) NULL,hora_fim VARCHAR(5) NULL,ativo TINYINT NOT NULL DEFAULT 1,UNIQUE(id_portal,descricao),FOREIGN KEY(id_portal) REFERENCES portais(id)) ENGINE=InnoDB");
  foreach($pdo->query('SELECT id FROM portais')->fetchAll(PDO::FETCH_COLUMN) as $id)self::seed($pdo,(int)$id);
  // Preserva textos antigos e propostas: nenhuma publicação é alterada por esta migração.
  $horarios=$pdo->query("SELECT DISTINCT id_portal,horario FROM anuncios WHERE TRIM(horario)<>''")->fetchAll(PDO::FETCH_ASSOC);
  foreach($pdo->query('SELECT a.id_portal,r.conteudo FROM revisoes_anuncios r JOIN anuncios a ON a.id=r.id_anuncio')->fetchAll(PDO::FETCH_ASSOC) as $r){$payload=json_decode($r['conteudo'],true);if(is_array($payload)&&!empty($payload['hours']))$horarios[]=['id_portal'=>$r['id_portal'],'horario'=>$payload['hours']];}
  $q=$pdo->prepare('INSERT IGNORE INTO horarios_atendimento(id_portal,descricao) VALUES(?,?)');foreach($horarios as $h)$q->execute([$h['id_portal'],$h['horario']]);
 }
 public static function seed(PDO $pdo,int $id):void {
  $q=$pdo->prepare('INSERT IGNORE INTO horarios_atendimento(id_portal,descricao,dias_semana,hora_inicio,hora_fim) VALUES(?,?,?,?,?)');
  $q->execute([$id,'Segunda a sexta, das 08:00 às 18:00','1,2,3,4,5','08:00','18:00']);
  $q->execute([$id,'Sábado e domingo, das 08:00 às 12:00','6,7','08:00','12:00']);
 }
}
