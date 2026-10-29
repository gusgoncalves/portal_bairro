-- Atualização não destrutiva. Execute também php spark portal:install para criar o admin local.
USE portal_bairro;
CREATE TABLE IF NOT EXISTS revisoes_anuncios (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_anuncio INT UNSIGNED NOT NULL,
 id_autor INT UNSIGNED NOT NULL, conteudo LONGTEXT NOT NULL,
 situacao VARCHAR(20) NOT NULL DEFAULT 'pending', versao INT NOT NULL DEFAULT 1,
 id_revisor INT UNSIGNED NULL, parecer TEXT NULL,
 enviado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, analisado_em DATETIME NULL,
 FOREIGN KEY(id_anuncio) REFERENCES anuncios(id),
 FOREIGN KEY(id_autor) REFERENCES usuarios(id), FOREIGN KEY(id_revisor) REFERENCES usuarios(id),
 INDEX idx_revisoes_anuncio(id_anuncio,id), CHECK(situacao IN ('pending','approved','rejected'))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS imagens_revisoes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_revisao INT UNSIGNED NOT NULL,
 nome_arquivo VARCHAR(70) NOT NULL, tipo_mime VARCHAR(30) NOT NULL, posicao TINYINT NOT NULL,
 legenda VARCHAR(100) NOT NULL DEFAULT '', FOREIGN KEY(id_revisao) REFERENCES revisoes_anuncios(id),
 UNIQUE(id_revisao,posicao), INDEX idx_revisoes_arquivo(nome_arquivo), CHECK(posicao BETWEEN 1 AND 3)
) ENGINE=InnoDB;
