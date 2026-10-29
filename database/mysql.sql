-- Portal do Bairro / MySQL 8+ ou MariaDB 10.4+ (XAMPP).
-- Não remove bases ou registros existentes. Executar antes do instalador de contas.
CREATE DATABASE IF NOT EXISTS portal_bairro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE portal_bairro;
CREATE TABLE IF NOT EXISTS organizacoes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(120) NOT NULL,
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS portais (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_organizacao INT UNSIGNED NOT NULL,
 identificador VARCHAR(100) NOT NULL UNIQUE, nome VARCHAR(120) NOT NULL,
 limite_anuncios INT NOT NULL DEFAULT 10, cor_principal VARCHAR(7) NOT NULL DEFAULT '#6250EC', logotipo VARCHAR(200) NULL, endereco_local VARCHAR(250) NOT NULL DEFAULT '', cor_texto VARCHAR(7) NOT NULL DEFAULT '#FFFFFF', fonte VARCHAR(30) NOT NULL DEFAULT 'Inter', ativo TINYINT NOT NULL DEFAULT 1,
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_organizacao) REFERENCES organizacoes(id),
 CHECK (limite_anuncios BETWEEN 1 AND 10000)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS anunciantes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(120) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS usuarios (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(120) NOT NULL,
 email VARCHAR(190) NOT NULL UNIQUE, senha_hash VARCHAR(255) NOT NULL,
 perfil VARCHAR(20) NOT NULL, id_anunciante INT UNSIGNED NULL,
 ativo TINYINT NOT NULL DEFAULT 1,
 FOREIGN KEY (id_anunciante) REFERENCES anunciantes(id),
 CHECK(perfil IN ('master','manager','advertiser'))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS usuarios_portais (
 id_usuario INT UNSIGNED NOT NULL, id_portal INT UNSIGNED NOT NULL, ativo TINYINT NOT NULL DEFAULT 1,
 PRIMARY KEY(id_usuario,id_portal),
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id), FOREIGN KEY(id_portal) REFERENCES portais(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS horarios_atendimento (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_portal INT UNSIGNED NOT NULL,
 descricao VARCHAR(120) NOT NULL, dias_semana VARCHAR(20) NULL, hora_inicio VARCHAR(5) NULL, hora_fim VARCHAR(5) NULL, ativo TINYINT NOT NULL DEFAULT 1,
 UNIQUE(id_portal,descricao), FOREIGN KEY(id_portal) REFERENCES portais(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS anuncios (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_portal INT UNSIGNED NOT NULL,
 id_anunciante INT UNSIGNED NOT NULL, nome VARCHAR(120) NOT NULL,
 categoria VARCHAR(30) NOT NULL, servico_principal VARCHAR(100) NOT NULL,
 descricao TEXT NOT NULL, palavras_chave VARCHAR(200) NOT NULL DEFAULT '',
 cor VARCHAR(10) NOT NULL DEFAULT '#d6dfce', cor_destaque VARCHAR(10) NOT NULL DEFAULT '#64846c',
 tipo VARCHAR(20) NOT NULL DEFAULT 'home', modalidade_atendimento VARCHAR(50) NOT NULL,
 horario VARCHAR(120) NOT NULL, id_horario INT UNSIGNED NULL, endereco VARCHAR(200) NOT NULL DEFAULT '',
 area_atendimento VARCHAR(200) NOT NULL DEFAULT '', whatsapp VARCHAR(15) NOT NULL DEFAULT '',
 instagram VARCHAR(40) NOT NULL DEFAULT '', servicos TEXT NOT NULL,
 situacao VARCHAR(20) NOT NULL DEFAULT 'pending',
 acesso_liberado_em DATETIME NULL, primeira_publicacao_em DATETIME NULL,
 mensalidade_centavos INT UNSIGNED NOT NULL DEFAULT 0, dias_periodo INT NOT NULL DEFAULT 30,
 motivo_despublicacao TEXT NULL, despublicado_em DATETIME NULL,
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(id_portal) REFERENCES portais(id), FOREIGN KEY(id_anunciante) REFERENCES anunciantes(id),
 UNIQUE(id_portal,id_anunciante), INDEX idx_anuncios_situacao(id_portal,situacao),
 CHECK(situacao IN ('pending','published','suspended','archived'))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS imagens_anuncios (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_anuncio INT UNSIGNED NOT NULL,
 nome_arquivo VARCHAR(70) NOT NULL UNIQUE, tipo_mime VARCHAR(30) NOT NULL,
 posicao TINYINT NOT NULL, legenda VARCHAR(100) NOT NULL DEFAULT '',
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(id_anuncio) REFERENCES anuncios(id),
 UNIQUE(id_anuncio,posicao), CHECK(posicao BETWEEN 1 AND 3)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS registros_auditoria (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_usuario INT UNSIGNED NULL,
 id_portal INT UNSIGNED NULL, acao VARCHAR(80) NOT NULL,
 id_anuncio INT UNSIGNED NULL, criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_auditoria_portal(id_portal,id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tentativas_login (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, identificador_origem CHAR(64) NOT NULL,
 tentado_em BIGINT NOT NULL, INDEX idx_tentativas_origem(identificador_origem,tentado_em)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS cobrancas (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_portal INT UNSIGNED NOT NULL,
 id_anuncio INT UNSIGNED NULL, id_assinatura INT UNSIGNED NULL,
 tipo_cobranca VARCHAR(30) NOT NULL DEFAULT 'anunciante', inicio_referencia DATE NULL, fim_referencia DATE NULL,
 descricao VARCHAR(150) NOT NULL,
 valor_centavos INT UNSIGNED NOT NULL, vencimento DATE NOT NULL, pago_em DATETIME NULL,
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(id_portal) REFERENCES portais(id), FOREIGN KEY(id_anuncio) REFERENCES anuncios(id),
 INDEX idx_cobrancas_portal(id_portal,vencimento)
) ENGINE=InnoDB;

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

CREATE TABLE IF NOT EXISTS assinaturas (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_portal INT UNSIGNED NOT NULL UNIQUE,
 valor_centavos INT UNSIGNED NOT NULL DEFAULT 0, inicio_em DATETIME NOT NULL,
 situacao VARCHAR(20) NOT NULL DEFAULT 'ativa', FOREIGN KEY(id_portal) REFERENCES portais(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS periodos_publicacao (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_anuncio INT UNSIGNED NOT NULL,
 id_cobranca INT UNSIGNED NOT NULL UNIQUE, inicio_em DATE NOT NULL, fim_em DATE NOT NULL,
 registrado_por INT UNSIGNED NOT NULL, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(id_anuncio) REFERENCES anuncios(id), FOREIGN KEY(id_cobranca) REFERENCES cobrancas(id), CHECK(fim_em>=inicio_em)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS pagamentos (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_cobranca INT UNSIGNED NOT NULL UNIQUE,
 valor_centavos INT UNSIGNED NOT NULL, recebido_em DATETIME NOT NULL,
 registrado_por INT UNSIGNED NOT NULL, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(id_cobranca) REFERENCES cobrancas(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS convites_avaliacao (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_anuncio INT UNSIGNED NOT NULL,
 id_solicitante INT UNSIGNED NOT NULL, email_destinatario VARCHAR(254) NOT NULL,
 identificador_email CHAR(64) NOT NULL, token_hash CHAR(64) NOT NULL UNIQUE,
 expira_em DATETIME NOT NULL, utilizado_em DATETIME NULL, enviado_em DATETIME NULL,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(id_anuncio) REFERENCES anuncios(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS avaliacoes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_anuncio INT UNSIGNED NOT NULL,
 id_convite INT UNSIGNED NOT NULL UNIQUE, identificador_email CHAR(64) NOT NULL,
 estrelas INT NOT NULL, criado_em DATETIME NOT NULL,
 FOREIGN KEY(id_anuncio) REFERENCES anuncios(id), FOREIGN KEY(id_convite) REFERENCES convites_avaliacao(id),
 CHECK(estrelas BETWEEN 1 AND 5), INDEX idx_avaliacoes_email(id_anuncio,identificador_email,criado_em)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS eventos_clique (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_anuncio INT UNSIGNED NOT NULL,
 canal VARCHAR(20) NOT NULL, identificador_sessao CHAR(64) NOT NULL, criado_em DATETIME NOT NULL,
 FOREIGN KEY(id_anuncio) REFERENCES anuncios(id), INDEX idx_cliques_anuncio(id_anuncio,criado_em)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tokens_acesso (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, id_usuario INT UNSIGNED NOT NULL,
 token_hash CHAR(64) NOT NULL UNIQUE, expira_em DATETIME NOT NULL, utilizado_em DATETIME NULL,
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS fila_emails (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, destinatario VARCHAR(254) NOT NULL,
 assunto VARCHAR(200) NOT NULL, mensagem TEXT NULL, situacao VARCHAR(20) NOT NULL DEFAULT 'pendente',
 tentativas INT NOT NULL DEFAULT 0, proxima_tentativa_em DATETIME NULL,
 bloqueado_em DATETIME NULL, enviado_em DATETIME NULL, ultimo_erro VARCHAR(200) NULL,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS configuracoes_email (
 id INT UNSIGNED PRIMARY KEY, servidor VARCHAR(250) NOT NULL, porta INT UNSIGNED NOT NULL,
 seguranca VARCHAR(10) NOT NULL, usuario VARCHAR(190) NOT NULL DEFAULT '', senha_cifrada TEXT NULL,
 remetente_email VARCHAR(190) NOT NULL, remetente_nome VARCHAR(120) NOT NULL,
 ativo TINYINT NOT NULL DEFAULT 1, atualizado_por INT UNSIGNED NULL,
 atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
