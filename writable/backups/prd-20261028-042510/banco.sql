SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS `advertisers`;
CREATE TABLE `advertisers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `advertisers` (`id`,`name`) VALUES ('1','João · Reparos & Soluções');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('2','Ateliê da Ana');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('3','Sabores da Dona Lúcia');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('4','Casa Leve com Maria');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('5','Carlos · Hidráulica Local');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('6','Barbearia do Rafa');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('7','Verde Perto · Jardinagem');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('8','Pedro · Construção e Reforma');
INSERT INTO `advertisers` (`id`,`name`) VALUES ('9','Doces da Bia');
DROP TABLE IF EXISTS `anunciantes`;
CREATE TABLE `anunciantes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('1','João · Reparos & Soluções');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('2','Ateliê da Ana');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('3','Sabores da Dona Lúcia');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('4','Casa Leve com Maria');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('5','Carlos · Hidráulica Local');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('6','Barbearia do Rafa');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('7','Verde Perto · Jardinagem');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('8','Pedro · Construção e Reforma');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('9','Doces da Bia');
DROP TABLE IF EXISTS `anuncios`;
CREATE TABLE `anuncios` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_portal` int(10) unsigned NOT NULL,
  `id_anunciante` int(10) unsigned NOT NULL,
  `nome` varchar(120) NOT NULL,
  `categoria` varchar(30) NOT NULL,
  `servico_principal` varchar(100) NOT NULL,
  `descricao` text NOT NULL,
  `palavras_chave` varchar(200) NOT NULL DEFAULT '',
  `cor` varchar(10) NOT NULL DEFAULT '#d6dfce',
  `cor_destaque` varchar(10) NOT NULL DEFAULT '#64846c',
  `tipo` varchar(20) NOT NULL DEFAULT 'home',
  `modalidade_atendimento` varchar(50) NOT NULL,
  `horario` varchar(120) NOT NULL,
  `endereco` varchar(200) NOT NULL DEFAULT '',
  `area_atendimento` varchar(200) NOT NULL DEFAULT '',
  `whatsapp` varchar(15) NOT NULL DEFAULT '',
  `instagram` varchar(40) NOT NULL DEFAULT '',
  `servicos` text NOT NULL,
  `situacao` varchar(20) NOT NULL DEFAULT 'pending',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `portal_id` (`id_portal`,`id_anunciante`),
  KEY `portal_status` (`id_portal`,`situacao`),
  KEY `anuncios_ibfk_2` (`id_anunciante`),
  CONSTRAINT `anuncios_ibfk_1` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`),
  CONSTRAINT `anuncios_ibfk_2` FOREIGN KEY (`id_anunciante`) REFERENCES `anunciantes` (`id`),
  CONSTRAINT `chk_anuncios_1` CHECK (`situacao` in ('pending','published','suspended','archived'))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('1','1','1','João · Reparos & Soluções','reformas','Elétrica e pequenos reparos','Uma mão experiente para os reparos e cuidados da sua casa.','eletricista tomada manutenção lâmpada eletrica','#d6dfce','#64846c','home','A domicílio','Segunda a sexta, das 8h às 18h','rua Antonil, 46 ponta grossa','Vila Esperança e arredores','42999999999','sdasdadsadsdsadsa','[\"Instalação de luminárias\",\"Troca de tomadas e interruptores\",\"Pequenos reparos residenciais\"]','published','2026-10-25 23:11:13','2026-10-26 00:38:06');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('2','1','2','Ateliê da Ana','beleza','Manicure e pedicure','Cuidado, delicadeza e um momento só seu, pertinho de casa.','unha esmalte manicure pedicure beleza','#ead4ca','#b37a69','beauty','Em estabelecimento','Terça a sábado, das 9h às 18h','','Vila Esperança e arredores','','','[\"Manicure e pedicure\",\"Esmaltação\",\"Cuidados com as unhas\"]','published','2026-10-25 23:11:13','2026-10-25 23:20:21');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('3','1','3','Sabores da Dona Lúcia','alimentacao','Comida caseira e encomendas','Receitas com carinho para o almoço e os encontros em família.','cozinheira comida marmita bolo almoço cozinha','#eeddb9','#bb8c45','food','Encomendas e retirada','Segunda a sábado, das 8h às 16h','','Vila Esperança e arredores','','','[\"Marmitas por encomenda\",\"Bolos caseiros\",\"Refeições para pequenos encontros\"]','published','2026-10-25 23:11:13','2026-10-25 23:11:13');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('4','1','4','Casa Leve com Maria','limpeza','Limpeza e organização','Mais tranquilidade e cuidado com cada cantinho do seu lar.','faxineira faxina diarista limpeza organização','#d0e1df','#558c88','clean','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Limpeza residencial\",\"Organização de ambientes\",\"Limpeza de manutenção\"]','published','2026-10-25 23:11:13','2026-10-25 23:20:19');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('5','1','5','Carlos · Hidráulica Local','reformas','Encanador residencial','Atendimento para vazamentos e manutenção hidráulica residencial.','encanador vazamento torneira cano hidráulica','#d6dfe6','#6a859d','home','A domicílio','Segunda a sábado, das 8h às 18h','','Vila Esperança e arredores','','','[\"Reparo de vazamentos\",\"Troca de torneiras\",\"Manutenção hidráulica\"]','published','2026-10-25 23:11:13','2026-10-25 23:11:13');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('6','1','6','Barbearia do Rafa','beleza','Cabelo e barba','Seu corte em dia, com conversa boa e atendimento no bairro.','barbeiro cabelo corte barba cabeleireiro','#d9d7cb','#7c7e60','beauty','Em estabelecimento','Terça a sábado, das 9h às 19h','','Vila Esperança e arredores','','','[\"Corte masculino\",\"Barba\",\"Acabamento\"]','published','2026-10-25 23:11:13','2026-10-25 23:20:15');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('7','1','7','Verde Perto · Jardinagem','jardim','Cuidados com jardins','Um olhar cuidadoso para deixar seu espaço mais verde.','jardineiro jardim poda grama plantas','#dbe4c7','#7e9854','plant','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Manutenção de jardins\",\"Corte de grama\",\"Cuidados com plantas\"]','published','2026-10-25 23:11:13','2026-10-25 23:11:13');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('8','1','8','Pedro · Construção e Reforma','reformas','Pedreiro e acabamentos','Do pequeno ajuste à reforma, atenção aos detalhes da sua casa.','pedreiro alvenaria piso parede reforma pintura','#e7d4bf','#a77b55','home','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Pequenas reformas\",\"Assentamento de pisos\",\"Reparos em alvenaria\"]','published','2026-10-25 23:11:13','2026-10-26 19:32:00');
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`criado_em`,`atualizado_em`) VALUES ('9','1','9','Doces da Bia','alimentacao','Doces e bolos para festas','Encomendas artesanais para celebrar os momentos especiais.','doce festa bolo brigadeiro','#eddcd7','#b7847a','food','Encomendas e retirada','Terça a sábado, das 9h às 17h','','Vila Esperança e arredores','','','[\"Bolos\",\"Doces para festas\"]','published','2026-10-25 23:11:13','2026-10-25 23:38:09');
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `portal_id` int(10) unsigned DEFAULT NULL,
  `action` varchar(80) NOT NULL,
  `publication_id` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `portal_audit` (`portal_id`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('1','4','1','catalog.submitted','9','2026-10-26 00:24:58');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('2','1','1','catalog.submitted','9','2026-10-26 00:26:50');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('3','1','1','catalog.approved','9','2026-10-26 00:27:18');
DROP TABLE IF EXISTS `charges`;
CREATE TABLE `charges` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `portal_id` int(10) unsigned NOT NULL,
  `publication_id` int(10) unsigned DEFAULT NULL,
  `description` varchar(150) NOT NULL,
  `amount_cents` int(10) unsigned NOT NULL,
  `due_date` date NOT NULL,
  `paid_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `publication_id` (`publication_id`),
  KEY `charge_portal` (`portal_id`,`due_date`),
  CONSTRAINT `charges_ibfk_1` FOREIGN KEY (`portal_id`) REFERENCES `portals` (`id`),
  CONSTRAINT `charges_ibfk_2` FOREIGN KEY (`publication_id`) REFERENCES `publications` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TABLE IF EXISTS `cobrancas`;
CREATE TABLE `cobrancas` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_portal` int(10) unsigned NOT NULL,
  `id_anuncio` int(10) unsigned DEFAULT NULL,
  `descricao` varchar(150) NOT NULL,
  `valor_centavos` int(10) unsigned NOT NULL,
  `vencimento` date NOT NULL,
  `pago_em` datetime DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `charge_portal` (`id_portal`,`vencimento`),
  KEY `cobrancas_ibfk_2` (`id_anuncio`),
  CONSTRAINT `cobrancas_ibfk_1` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`),
  CONSTRAINT `cobrancas_ibfk_2` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('1','1',NULL,'dssdsdsd','51200','2026-11-03','2026-10-25 23:32:07','2026-10-25 23:28:17');
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('2','1','1','32323232','30000','2026-11-11',NULL,'2026-10-26 23:22:14');
DROP TABLE IF EXISTS `imagens_anuncios`;
CREATE TABLE `imagens_anuncios` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_anuncio` int(10) unsigned NOT NULL,
  `nome_arquivo` varchar(70) NOT NULL,
  `tipo_mime` varchar(30) NOT NULL,
  `posicao` tinyint(4) NOT NULL,
  `legenda` varchar(100) NOT NULL DEFAULT '',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `filename` (`nome_arquivo`),
  UNIQUE KEY `publication_id` (`id_anuncio`,`posicao`),
  CONSTRAINT `imagens_anuncios_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`),
  CONSTRAINT `chk_imagens_anuncios_2` CHECK (`posicao` between 1 and 3)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('4','1','96db1b92b94e09d0e0d8e4f8d78948bf6a546b27ad3f13de.png','image/png','1','Fachada','2026-10-26 00:38:06');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('5','1','214cda6634ec74b2615d6dbb8cafeeb8d18da1f0716d9944.jpg','image/jpeg','2','Loja ou apresentação','2026-10-26 00:38:06');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('6','8','9fdf1b3ad67cf488c710b9dc62e8d246ceec573404275147.jpg','image/jpeg','1','Loja ou apresentação','2026-10-26 19:32:00');
DROP TABLE IF EXISTS `imagens_revisoes`;
CREATE TABLE `imagens_revisoes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_revisao` int(10) unsigned NOT NULL,
  `nome_arquivo` varchar(70) NOT NULL,
  `tipo_mime` varchar(30) NOT NULL,
  `posicao` tinyint(4) NOT NULL,
  `legenda` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `revision_id` (`id_revisao`,`posicao`),
  KEY `revision_filename` (`nome_arquivo`),
  CONSTRAINT `imagens_revisoes_ibfk_1` FOREIGN KEY (`id_revisao`) REFERENCES `revisoes_anuncios` (`id`),
  CONSTRAINT `chk_imagens_revisoes_4` CHECK (`posicao` between 1 and 3)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('1','2','09f8fdc9d8b5702d5b37a6cf3bdb685b60146bc03538f87e.png','image/png','1','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('2','6','214cda6634ec74b2615d6dbb8cafeeb8d18da1f0716d9944.jpg','image/jpeg','1','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('3','6','96db1b92b94e09d0e0d8e4f8d78948bf6a546b27ad3f13de.png','image/png','2','Fachada');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('6','7','96db1b92b94e09d0e0d8e4f8d78948bf6a546b27ad3f13de.png','image/png','1','Fachada');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('7','7','214cda6634ec74b2615d6dbb8cafeeb8d18da1f0716d9944.jpg','image/jpeg','2','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('9','8','9fdf1b3ad67cf488c710b9dc62e8d246ceec573404275147.jpg','image/jpeg','1','Loja ou apresentação');
DROP TABLE IF EXISTS `login_attempts`;
CREATE TABLE `login_attempts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fingerprint` char(64) NOT NULL,
  `attempted_at` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `attempt_lookup` (`fingerprint`,`attempted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `login_attempts` (`id`,`fingerprint`,`attempted_at`) VALUES ('2','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1792985175');
DROP TABLE IF EXISTS `memberships`;
CREATE TABLE `memberships` (
  `user_id` int(10) unsigned NOT NULL,
  `portal_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`portal_id`),
  KEY `portal_id` (`portal_id`),
  CONSTRAINT `memberships_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `memberships_ibfk_2` FOREIGN KEY (`portal_id`) REFERENCES `portals` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `memberships` (`user_id`,`portal_id`) VALUES ('1','1');
INSERT INTO `memberships` (`user_id`,`portal_id`) VALUES ('2','1');
INSERT INTO `memberships` (`user_id`,`portal_id`) VALUES ('3','1');
DROP TABLE IF EXISTS `organizacoes`;
CREATE TABLE `organizacoes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `organizacoes` (`id`,`nome`,`criado_em`) VALUES ('1','Gestão Vila Esperança','2026-10-25 23:11:13');
INSERT INTO `organizacoes` (`id`,`nome`,`criado_em`) VALUES ('2','sadadadasdas','2026-10-25 23:31:09');
DROP TABLE IF EXISTS `organizations`;
CREATE TABLE `organizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `organizations` (`id`,`name`,`created_at`) VALUES ('1','Gestão Vila Esperança','2026-10-26 00:24:57');
DROP TABLE IF EXISTS `portais`;
CREATE TABLE `portais` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_organizacao` int(10) unsigned NOT NULL,
  `identificador` varchar(100) NOT NULL,
  `nome` varchar(120) NOT NULL,
  `limite_anuncios` int(11) NOT NULL DEFAULT 10,
  `ativo` tinyint(4) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`identificador`),
  KEY `portais_ibfk_1` (`id_organizacao`),
  CONSTRAINT `portais_ibfk_1` FOREIGN KEY (`id_organizacao`) REFERENCES `organizacoes` (`id`),
  CONSTRAINT `chk_portais_0` CHECK (`limite_anuncios` in (10,50,100,200))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `portais` (`id`,`id_organizacao`,`identificador`,`nome`,`limite_anuncios`,`ativo`,`criado_em`) VALUES ('1','1','vila-esperanca','Vila Esperança','10','1','2026-10-25 23:11:13');
INSERT INTO `portais` (`id`,`id_organizacao`,`identificador`,`nome`,`limite_anuncios`,`ativo`,`criado_em`) VALUES ('2','2','asdadsadsadadsad','dadsdd','10','1','2026-10-25 23:31:09');
DROP TABLE IF EXISTS `portals`;
CREATE TABLE `portals` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int(10) unsigned NOT NULL,
  `slug` varchar(100) NOT NULL,
  `name` varchar(120) NOT NULL,
  `capacity` int(11) NOT NULL DEFAULT 10,
  `active` tinyint(4) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `organization_id` (`organization_id`),
  CONSTRAINT `portals_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`capacity` in (10,50,100,200))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `portals` (`id`,`organization_id`,`slug`,`name`,`capacity`,`active`,`created_at`) VALUES ('1','1','vila-esperanca','Vila Esperança','10','1','2026-10-26 00:24:57');
DROP TABLE IF EXISTS `publication_images`;
CREATE TABLE `publication_images` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `publication_id` int(10) unsigned NOT NULL,
  `filename` varchar(70) NOT NULL,
  `mime` varchar(30) NOT NULL,
  `slot` tinyint(4) NOT NULL,
  `caption` varchar(100) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `filename` (`filename`),
  UNIQUE KEY `publication_id` (`publication_id`,`slot`),
  CONSTRAINT `publication_images_ibfk_1` FOREIGN KEY (`publication_id`) REFERENCES `publications` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`slot` between 1 and 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TABLE IF EXISTS `publication_revisions`;
CREATE TABLE `publication_revisions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `publication_id` int(10) unsigned NOT NULL,
  `author_id` int(10) unsigned NOT NULL,
  `payload` longtext NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `version` int(11) NOT NULL DEFAULT 1,
  `reviewer_id` int(10) unsigned DEFAULT NULL,
  `review_note` text DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `author_id` (`author_id`),
  KEY `reviewer_id` (`reviewer_id`),
  KEY `revision_publication` (`publication_id`,`id`),
  CONSTRAINT `publication_revisions_ibfk_1` FOREIGN KEY (`publication_id`) REFERENCES `publications` (`id`),
  CONSTRAINT `publication_revisions_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`),
  CONSTRAINT `publication_revisions_ibfk_3` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`status` in ('pending','approved','rejected'))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('1','9','1','{\"name\":\"Doces da Bia\",\"service\":\"Doces e bolos para festas\",\"description\":\"Encomendas artesanais para celebrar os momentos especiais.\",\"tags\":\"doce festa bolo brigadeiro\",\"hours\":\"Terça a sábado, das 9h às 17h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"5542984295615\",\"instagram\":\"gusgoncalves81\",\"category\":\"alimentacao\",\"mode\":\"Encomendas e retirada\",\"services\":\"[\\\"Bolos\\\",\\\"Doces para festas\\\"]\"}','approved','3','1','','2026-10-26 00:26:50','2026-10-26 00:27:18');
DROP TABLE IF EXISTS `publications`;
CREATE TABLE `publications` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `portal_id` int(10) unsigned NOT NULL,
  `advertiser_id` int(10) unsigned NOT NULL,
  `name` varchar(120) NOT NULL,
  `category` varchar(30) NOT NULL,
  `service` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `tags` varchar(200) NOT NULL DEFAULT '',
  `color` varchar(10) NOT NULL DEFAULT '#d6dfce',
  `accent` varchar(10) NOT NULL DEFAULT '#64846c',
  `type` varchar(20) NOT NULL DEFAULT 'home',
  `mode` varchar(50) NOT NULL,
  `hours` varchar(120) NOT NULL,
  `address` varchar(200) NOT NULL DEFAULT '',
  `area` varchar(200) NOT NULL DEFAULT '',
  `whatsapp` varchar(15) NOT NULL DEFAULT '',
  `instagram` varchar(40) NOT NULL DEFAULT '',
  `services` text NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `portal_id` (`portal_id`,`advertiser_id`),
  KEY `advertiser_id` (`advertiser_id`),
  KEY `portal_status` (`portal_id`,`status`),
  CONSTRAINT `publications_ibfk_1` FOREIGN KEY (`portal_id`) REFERENCES `portals` (`id`),
  CONSTRAINT `publications_ibfk_2` FOREIGN KEY (`advertiser_id`) REFERENCES `advertisers` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`status` in ('pending','published','suspended','archived'))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('1','1','1','João · Reparos & Soluções','reformas','Elétrica e pequenos reparos','Uma mão experiente para os reparos e cuidados da sua casa.','eletricista tomada manutenção lâmpada eletrica','#d6dfce','#64846c','home','A domicílio','Segunda a sexta, das 8h às 18h','','Vila Esperança e arredores','','','[\"Instalação de luminárias\",\"Troca de tomadas e interruptores\",\"Pequenos reparos residenciais\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('2','1','2','Ateliê da Ana','beleza','Manicure e pedicure','Cuidado, delicadeza e um momento só seu, pertinho de casa.','unha esmalte manicure pedicure beleza','#ead4ca','#b37a69','beauty','Em estabelecimento','Terça a sábado, das 9h às 18h','','Vila Esperança e arredores','','','[\"Manicure e pedicure\",\"Esmaltação\",\"Cuidados com as unhas\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('3','1','3','Sabores da Dona Lúcia','alimentacao','Comida caseira e encomendas','Receitas com carinho para o almoço e os encontros em família.','cozinheira comida marmita bolo almoço cozinha','#eeddb9','#bb8c45','food','Encomendas e retirada','Segunda a sábado, das 8h às 16h','','Vila Esperança e arredores','','','[\"Marmitas por encomenda\",\"Bolos caseiros\",\"Refeições para pequenos encontros\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('4','1','4','Casa Leve com Maria','limpeza','Limpeza e organização','Mais tranquilidade e cuidado com cada cantinho do seu lar.','faxineira faxina diarista limpeza organização','#d0e1df','#558c88','clean','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Limpeza residencial\",\"Organização de ambientes\",\"Limpeza de manutenção\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('5','1','5','Carlos · Hidráulica Local','reformas','Encanador residencial','Atendimento para vazamentos e manutenção hidráulica residencial.','encanador vazamento torneira cano hidráulica','#d6dfe6','#6a859d','home','A domicílio','Segunda a sábado, das 8h às 18h','','Vila Esperança e arredores','','','[\"Reparo de vazamentos\",\"Troca de torneiras\",\"Manutenção hidráulica\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('6','1','6','Barbearia do Rafa','beleza','Cabelo e barba','Seu corte em dia, com conversa boa e atendimento no bairro.','barbeiro cabelo corte barba cabeleireiro','#d9d7cb','#7c7e60','beauty','Em estabelecimento','Terça a sábado, das 9h às 19h','','Vila Esperança e arredores','','','[\"Corte masculino\",\"Barba\",\"Acabamento\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('7','1','7','Verde Perto · Jardinagem','jardim','Cuidados com jardins','Um olhar cuidadoso para deixar seu espaço mais verde.','jardineiro jardim poda grama plantas','#dbe4c7','#7e9854','plant','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Manutenção de jardins\",\"Corte de grama\",\"Cuidados com plantas\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('8','1','8','Pedro · Construção e Reforma','reformas','Pedreiro e acabamentos','Do pequeno ajuste à reforma, atenção aos detalhes da sua casa.','pedreiro alvenaria piso parede reforma pintura','#e7d4bf','#a77b55','home','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Pequenas reformas\",\"Assentamento de pisos\",\"Reparos em alvenaria\"]','published','2026-10-26 00:24:57','2026-10-26 00:24:57');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('9','1','9','Doces da Bia','alimentacao','Doces e bolos para festas','Encomendas artesanais para celebrar os momentos especiais.','doce festa bolo brigadeiro','#eddcd7','#b7847a','food','Encomendas e retirada','Terça a sábado, das 9h às 17h','','Vila Esperança e arredores','5542984295615','gusgoncalves81','[\"Bolos\",\"Doces para festas\"]','published','2026-10-26 00:24:57','2026-10-26 00:27:18');
DROP TABLE IF EXISTS `registros_auditoria`;
CREATE TABLE `registros_auditoria` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int(10) unsigned DEFAULT NULL,
  `id_portal` int(10) unsigned DEFAULT NULL,
  `acao` varchar(80) NOT NULL,
  `id_anuncio` int(10) unsigned DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `portal_audit` (`id_portal`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('1','4','1','catalog.submitted','9','2026-10-25 23:11:14');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('2','4','1','catalog.suspended','8','2026-10-25 23:13:54');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('3','4','1','catalog.suspended','6','2026-10-25 23:15:35');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('4','4','1','catalog.suspended','4','2026-10-25 23:15:36');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('5','4','1','catalog.suspended','2','2026-10-25 23:15:38');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('6','4','1','catalog.suspended','1','2026-10-25 23:15:41');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('7','4','1','catalog.published','6','2026-10-25 23:20:15');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('8','4','1','catalog.published','4','2026-10-25 23:20:19');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('9','4','1','catalog.published','2','2026-10-25 23:20:21');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('10','4','1','catalog.published','1','2026-10-25 23:20:22');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('11','4','1','catalog.published','8','2026-10-25 23:20:25');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('12','4','1','catalog.submitted','8','2026-10-25 23:21:47');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('13','4','1','catalog.images.submitted','8','2026-10-25 23:21:47');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('14','4','1','catalog.approved','8','2026-10-25 23:22:14');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('15','4','1','charge.created',NULL,'2026-10-25 23:28:17');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('16','1','2','portal.created',NULL,'2026-10-25 23:31:09');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('17','1','1','charge.paid',NULL,'2026-10-25 23:32:07');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('18','3','1','catalog.submitted','1','2026-10-25 23:34:08');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('19','1','1','catalog.rejected','1','2026-10-25 23:36:23');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('20','1','1','catalog.submitted','1','2026-10-25 23:37:42');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('21','1','1','catalog.approved','1','2026-10-25 23:37:59');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('22','1','1','catalog.approved','9','2026-10-25 23:38:09');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('23','3','1','catalog.submitted','1','2026-10-25 23:42:41');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('24','1','1','catalog.rejected','1','2026-10-25 23:44:10');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('25','3','1','catalog.submitted','1','2026-10-25 23:45:49');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('26','4','1','catalog.submitted','1','2026-10-26 00:32:50');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('27','4','1','catalog.images.submitted','1','2026-10-26 00:32:51');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('28','4','1','advertiser.access.created','1','2026-10-26 00:34:09');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('29','4','1','catalog.approved','1','2026-10-26 00:34:26');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('30','5','1','catalog.cover.submitted','1','2026-10-26 00:36:18');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('31','5','1','catalog.submitted','1','2026-10-26 00:36:56');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('32','4','1','catalog.approved','1','2026-10-26 00:38:06');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('33','4','1','catalog.image.removal.submitted','8','2026-10-26 19:30:58');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('34','4','1','catalog.submitted','8','2026-10-26 19:31:47');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('35','4','1','catalog.images.submitted','8','2026-10-26 19:31:47');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('36','4','1','catalog.approved','8','2026-10-26 19:32:00');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('37','4','1','charge.created','1','2026-10-26 23:22:14');
DROP TABLE IF EXISTS `revision_images`;
CREATE TABLE `revision_images` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `revision_id` int(10) unsigned NOT NULL,
  `filename` varchar(70) NOT NULL,
  `mime` varchar(30) NOT NULL,
  `slot` tinyint(4) NOT NULL,
  `caption` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `revision_id` (`revision_id`,`slot`),
  KEY `revision_filename` (`filename`),
  CONSTRAINT `revision_images_ibfk_1` FOREIGN KEY (`revision_id`) REFERENCES `publication_revisions` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`slot` between 1 and 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TABLE IF EXISTS `revisoes_anuncios`;
CREATE TABLE `revisoes_anuncios` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_anuncio` int(10) unsigned NOT NULL,
  `id_autor` int(10) unsigned NOT NULL,
  `conteudo` longtext NOT NULL,
  `situacao` varchar(20) NOT NULL DEFAULT 'pending',
  `versao` int(11) NOT NULL DEFAULT 1,
  `id_revisor` int(10) unsigned DEFAULT NULL,
  `parecer` text DEFAULT NULL,
  `enviado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `analisado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `revision_publication` (`id_anuncio`,`id`),
  KEY `revisoes_anuncios_ibfk_2` (`id_autor`),
  KEY `revisoes_anuncios_ibfk_3` (`id_revisor`),
  CONSTRAINT `revisoes_anuncios_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`),
  CONSTRAINT `revisoes_anuncios_ibfk_2` FOREIGN KEY (`id_autor`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `revisoes_anuncios_ibfk_3` FOREIGN KEY (`id_revisor`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `chk_revisoes_anuncios_3` CHECK (`situacao` in ('pending','approved','rejected'))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('1','9','4','{\"name\":\"Doces da Bia\",\"service\":\"Doces e bolos para festas\",\"description\":\"Encomendas artesanais para celebrar os momentos especiais.\",\"tags\":\"doce festa bolo brigadeiro\",\"hours\":\"Terça a sábado, das 9h às 17h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"\",\"instagram\":\"\",\"category\":\"alimentacao\",\"mode\":\"Encomendas e retirada\",\"services\":\"[\\\"Bolos\\\",\\\"Doces para festas\\\"]\"}','approved','2','1','','2026-10-25 23:11:14','2026-10-25 23:38:09');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('2','8','4','{\"name\":\"Pedro · Construção e Reforma\",\"service\":\"Pedreiro e acabamentos\",\"description\":\"Do pequeno ajuste à reforma, atenção aos detalhes da sua casa.\",\"tags\":\"pedreiro alvenaria piso parede reforma pintura\",\"hours\":\"Segunda a sexta, das 8h às 17h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"\",\"instagram\":\"\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Pequenas reformas\\\",\\\"Assentamento de pisos\\\",\\\"Reparos em alvenaria\\\"]\"}','approved','3','4','','2026-10-25 23:21:47','2026-10-25 23:22:14');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('3','1','3','{\"name\":\"João · Reparos & Soluções\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','rejected','2','1','Não está correto','2026-10-25 23:34:08','2026-10-25 23:36:23');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('4','1','1','{\"name\":\"João · Reparos & Soluçõessddsdd\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','approved','2','1','','2026-10-25 23:37:42','2026-10-25 23:37:59');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('5','1','3','{\"name\":\"João · Reparos & Soluçõessddsdd\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rerwererwerrwer\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','rejected','2','1','errwerwer weewwe wer wer we wewe','2026-10-25 23:42:41','2026-10-25 23:44:10');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('6','1','4','{\"name\":\"João · Reparos & Soluçõessddsdd\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rerqe32322323233\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','approved','4','4','','2026-10-26 00:32:51','2026-10-26 00:34:26');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('7','1','5','{\"name\":\"João · Reparos & Soluções\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rua Antonil, 46 ponta grossa\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','approved','3','4','','2026-10-26 00:36:56','2026-10-26 00:38:06');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('8','8','4','{\"name\":\"Pedro · Construção e Reforma\",\"service\":\"Pedreiro e acabamentos\",\"description\":\"Do pequeno ajuste à reforma, atenção aos detalhes da sua casa.\",\"tags\":\"pedreiro alvenaria piso parede reforma pintura\",\"hours\":\"Segunda a sexta, das 8h às 17h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"\",\"instagram\":\"\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Pequenas reformas\\\",\\\"Assentamento de pisos\\\",\\\"Reparos em alvenaria\\\"]\"}','approved','4','4','','2026-10-26 19:31:47','2026-10-26 19:32:00');
DROP TABLE IF EXISTS `tentativas_login`;
CREATE TABLE `tentativas_login` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `identificador_origem` char(64) NOT NULL,
  `tentado_em` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `attempt_lookup` (`identificador_origem`,`tentado_em`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `tentativas_login` (`id`,`identificador_origem`,`tentado_em`) VALUES ('34','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1793153515');
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL,
  `advertiser_id` int(10) unsigned DEFAULT NULL,
  `active` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `advertiser_id` (`advertiser_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`advertiser_id`) REFERENCES `advertisers` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`role` in ('master','manager','advertiser'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('1','Master','master@portal.local','$2y$10$VbzMe8BeXXiMF5xWBLfL5ude.XM9D69OXTGUMmAoX6r9XaABIlADO','master',NULL,'1');
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('2','Gestor','gestor@portal.local','$2y$10$cj1nAxcJ7HZ83kYKGnzH8uMAJ2RDfi2s5v4w41dWHeBHvHr2epa5C','manager',NULL,'1');
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('3','Anunciante','anunciante@portal.local','$2y$10$8Ls2qablWtsNvCvSvsCtXeo3oO7SgMU4UPJcGgd1Yol7v.a234rv6','advertiser','1','1');
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('4','Administrador','admin@portal.local','$2y$10$V9qzu7pZhw7kqUxIZtbS8.YbPz3.MVPb9DytdT21LHrg2H4LfCytO','master',NULL,'1');
DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `perfil` varchar(20) NOT NULL,
  `id_anunciante` int(10) unsigned DEFAULT NULL,
  `ativo` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `usuarios_ibfk_1` (`id_anunciante`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_anunciante`) REFERENCES `anunciantes` (`id`),
  CONSTRAINT `chk_usuarios_5` CHECK (`perfil` in ('master','manager','advertiser'))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('1','Master','master@portal.local','$2y$10$/r40TTjFW9hdktq85bUM8.uFvGQehdv8oBScyWleHhGB5oICcHyA.','master',NULL,'1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('2','Gestor','gestor@portal.local','$2y$10$Uu.FBk5p0Fu4ZtZOtRJnj.1AstMywzGTiOUxNEN4NYNe2rjK64rxm','manager',NULL,'1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('3','Anunciante','anunciante@portal.local','$2y$10$TRUrbOdBcy72bNGh..b5buqsXOsYQT5nJVvEF9eGVDPh7tmdsNo4.','advertiser','1','1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('4','Administrador','admin@portal.local','$2y$10$ykeOyEiHYu3OCbUQuCBYIeIhVjq5EO1b4GO950XUPV3w8qfnpxWJO','master',NULL,'1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('5','gustavo','gustavo@gmail.com','$2y$10$pE95a9FRFf8vhF0lUwkGAOqSSgAUgezWDfEsG41ogRSnmWYuV6vgu','advertiser','1','1');
DROP TABLE IF EXISTS `usuarios_portais`;
CREATE TABLE `usuarios_portais` (
  `id_usuario` int(10) unsigned NOT NULL,
  `id_portal` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_usuario`,`id_portal`),
  KEY `usuarios_portais_ibfk_2` (`id_portal`),
  CONSTRAINT `usuarios_portais_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `usuarios_portais_ibfk_2` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`) VALUES ('1','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`) VALUES ('2','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`) VALUES ('3','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`) VALUES ('5','1');
SET FOREIGN_KEY_CHECKS=1;
