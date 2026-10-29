-- Atualizacao incremental: nao remove dados. Importar no banco do Portal.
CREATE TABLE IF NOT EXISTS configuracoes_email (
 id INT UNSIGNED PRIMARY KEY, servidor VARCHAR(250) NOT NULL, porta INT UNSIGNED NOT NULL,
 seguranca VARCHAR(10) NOT NULL, usuario VARCHAR(190) NOT NULL DEFAULT '', senha_cifrada TEXT NULL,
 remetente_email VARCHAR(190) NOT NULL, remetente_nome VARCHAR(120) NOT NULL,
 ativo TINYINT NOT NULL DEFAULT 1, atualizado_por INT UNSIGNED NULL,
 atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
