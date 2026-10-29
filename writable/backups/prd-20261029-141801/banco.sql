SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS `anunciantes`;
CREATE TABLE `anunciantes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('2','Gustavo Lacoste Maia');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('3','Timelo-rego');
INSERT INTO `anunciantes` (`id`,`nome`) VALUES ('4','fdfdsfsfsdfsdfs');
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
  `acesso_liberado_em` datetime DEFAULT NULL,
  `primeira_publicacao_em` datetime DEFAULT NULL,
  `mensalidade_centavos` int(10) unsigned NOT NULL DEFAULT 0,
  `dias_periodo` int(11) NOT NULL DEFAULT 30,
  `motivo_despublicacao` text DEFAULT NULL,
  `despublicado_em` datetime DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_horario` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_portal` (`id_portal`,`id_anunciante`),
  KEY `id_anunciante` (`id_anunciante`),
  KEY `idx_anuncios_situacao` (`id_portal`,`situacao`),
  CONSTRAINT `anuncios_ibfk_1` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`),
  CONSTRAINT `anuncios_ibfk_2` FOREIGN KEY (`id_anunciante`) REFERENCES `anunciantes` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`situacao` in ('pending','published','suspended','archived'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`acesso_liberado_em`,`primeira_publicacao_em`,`mensalidade_centavos`,`dias_periodo`,`motivo_despublicacao`,`despublicado_em`,`criado_em`,`atualizado_em`,`id_horario`) VALUES ('2','1','2','Gustavo Lacoste Maia','limpeza','Troca de Óleo','Somos a empresa de desenvolvimento','pedreiro alvenaria piso parede reforma pintura','#d6dfce','#64846c','home','A domicílio','Segunda a sexta, das 8h às 18h','rua Antonil, 46 ponta grossa','Vitrine Annecont','42984295615','gusgoncalves81','[\"Atendimento\",\"Programação\",\"teste\",\"mais um teste\"]','published','2026-10-28 11:36:07','2026-10-28 11:40:16','5000','30',NULL,NULL,'2026-10-28 08:36:07','2026-10-28 08:47:12',NULL);
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`acesso_liberado_em`,`primeira_publicacao_em`,`mensalidade_centavos`,`dias_periodo`,`motivo_despublicacao`,`despublicado_em`,`criado_em`,`atualizado_em`,`id_horario`) VALUES ('3','2','3','Timelo-rego','jardim','Regos macios','asd asdasdasdasdsdasdsadasdsadasdsadasdadasdadadadasdad','Serviços feitos com qualidade de segurança de jardinagem','#d6dfce','#64846c','home','Em estabelecimento','das 08:00 as 18:00','Rua nsaksaskasnasnasnasnasmnasmansmanmsas','Residencial Bellas','5542988717304','teste','[\"jardim\",\"casa\",\"bairro\",\"lar\"]','published','2026-10-28 12:06:26','2026-10-28 12:20:30','2500','30',NULL,NULL,'2026-10-28 09:06:26','2026-10-28 09:20:30',NULL);
INSERT INTO `anuncios` (`id`,`id_portal`,`id_anunciante`,`nome`,`categoria`,`servico_principal`,`descricao`,`palavras_chave`,`cor`,`cor_destaque`,`tipo`,`modalidade_atendimento`,`horario`,`endereco`,`area_atendimento`,`whatsapp`,`instagram`,`servicos`,`situacao`,`acesso_liberado_em`,`primeira_publicacao_em`,`mensalidade_centavos`,`dias_periodo`,`motivo_despublicacao`,`despublicado_em`,`criado_em`,`atualizado_em`,`id_horario`) VALUES ('4','2','4','fdfdsfsfsdfsdfs','reformas','wrwerrwerwerwerwerwe','werwerwerwerwerewrwerwerwer','werwerwerewrwerwr','#d6dfce','#64846c','home','Em estabelecimento','das 08:00 as 18:00','eewerrwrwerwerwer','Residencial Bellas','23232323232','wewewewe','[\"ewrerer\",\"werewrwer\",\"wrwer\",\"erwerew\",\"rewr\",\"ewr\",\"wr\",\"wr\",\"erw\",\"er\",\"we\"]','archived','2026-10-28 13:02:06','2026-10-28 14:56:27','5000','30','Só para testar','2026-10-29 03:52:24','2026-10-28 10:02:06','2026-10-29 00:52:24','6');
DROP TABLE IF EXISTS `assinaturas`;
CREATE TABLE `assinaturas` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_portal` int(10) unsigned NOT NULL,
  `valor_centavos` int(10) unsigned NOT NULL DEFAULT 0,
  `inicio_em` datetime NOT NULL,
  `situacao` varchar(20) NOT NULL DEFAULT 'ativa',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_portal` (`id_portal`),
  CONSTRAINT `assinaturas_ibfk_1` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `assinaturas` (`id`,`id_portal`,`valor_centavos`,`inicio_em`,`situacao`) VALUES ('2','1','20000','2026-10-28 11:50:57','ativa');
INSERT INTO `assinaturas` (`id`,`id_portal`,`valor_centavos`,`inicio_em`,`situacao`) VALUES ('3','2','20000','2026-10-28 12:03:14','ativa');
DROP TABLE IF EXISTS `avaliacoes`;
CREATE TABLE `avaliacoes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_anuncio` int(10) unsigned NOT NULL,
  `id_convite` int(10) unsigned NOT NULL,
  `identificador_email` char(64) NOT NULL,
  `estrelas` int(11) NOT NULL,
  `criado_em` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_convite` (`id_convite`),
  KEY `idx_avaliacoes_email` (`id_anuncio`,`identificador_email`,`criado_em`),
  CONSTRAINT `avaliacoes_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`),
  CONSTRAINT `avaliacoes_ibfk_2` FOREIGN KEY (`id_convite`) REFERENCES `convites_avaliacao` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`estrelas` between 1 and 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TABLE IF EXISTS `cobrancas`;
CREATE TABLE `cobrancas` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_portal` int(10) unsigned NOT NULL,
  `id_anuncio` int(10) unsigned DEFAULT NULL,
  `id_assinatura` int(10) unsigned DEFAULT NULL,
  `tipo_cobranca` varchar(30) NOT NULL DEFAULT 'anunciante',
  `inicio_referencia` date DEFAULT NULL,
  `fim_referencia` date DEFAULT NULL,
  `descricao` varchar(150) NOT NULL,
  `valor_centavos` int(10) unsigned NOT NULL,
  `vencimento` date NOT NULL,
  `pago_em` datetime DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `id_anuncio` (`id_anuncio`),
  KEY `idx_cobrancas_portal` (`id_portal`,`vencimento`),
  CONSTRAINT `cobrancas_ibfk_1` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`),
  CONSTRAINT `cobrancas_ibfk_2` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`id_assinatura`,`tipo_cobranca`,`inicio_referencia`,`fim_referencia`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('2','1','2',NULL,'anunciante','2026-10-28','2026-11-26','Mensalidade de divulgação','5000','2026-10-28','2026-10-28 11:47:28','2026-10-28 08:40:16');
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`id_assinatura`,`tipo_cobranca`,`inicio_referencia`,`fim_referencia`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('3','1',NULL,'2','plataforma',NULL,NULL,'Assinatura da plataforma','20000','2026-10-28','2026-10-29 10:41:59','2026-10-28 08:50:57');
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`id_assinatura`,`tipo_cobranca`,`inicio_referencia`,`fim_referencia`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('4','2',NULL,'3','plataforma',NULL,NULL,'Assinatura da plataforma','20000','2026-10-28','2026-10-29 10:41:00','2026-10-28 09:03:14');
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`id_assinatura`,`tipo_cobranca`,`inicio_referencia`,`fim_referencia`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('5','2','3',NULL,'anunciante','2026-10-28','2026-11-26','Mensalidade de divulgação','2497','2026-10-28','2026-10-29 10:44:16','2026-10-28 09:20:30');
INSERT INTO `cobrancas` (`id`,`id_portal`,`id_anuncio`,`id_assinatura`,`tipo_cobranca`,`inicio_referencia`,`fim_referencia`,`descricao`,`valor_centavos`,`vencimento`,`pago_em`,`criado_em`) VALUES ('6','2','4',NULL,'anunciante','2026-10-28','2026-11-26','Mensalidade de divulgação','5000','2026-10-28','2026-10-29 10:44:19','2026-10-28 11:56:27');
DROP TABLE IF EXISTS `convites_avaliacao`;
CREATE TABLE `convites_avaliacao` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_anuncio` int(10) unsigned NOT NULL,
  `id_solicitante` int(10) unsigned NOT NULL,
  `email_destinatario` varchar(254) NOT NULL,
  `identificador_email` char(64) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expira_em` datetime NOT NULL,
  `utilizado_em` datetime DEFAULT NULL,
  `enviado_em` datetime DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `id_anuncio` (`id_anuncio`),
  CONSTRAINT `convites_avaliacao_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `convites_avaliacao` (`id`,`id_anuncio`,`id_solicitante`,`email_destinatario`,`identificador_email`,`token_hash`,`expira_em`,`utilizado_em`,`enviado_em`,`criado_em`) VALUES ('1','3','8','gustavo.pascoal@gmail.com','6742ca45fa27fca809b27548219c7f0fe3fa97942f62112244927801a82f6f14','6e4f5367f021f54743bfaf66bdcf773a097a01388bb1ae6152e20c6d4801291d','2026-11-04 14:50:07',NULL,NULL,'2026-10-28 11:50:07');
DROP TABLE IF EXISTS `eventos_clique`;
CREATE TABLE `eventos_clique` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_anuncio` int(10) unsigned NOT NULL,
  `canal` varchar(20) NOT NULL,
  `identificador_sessao` char(64) NOT NULL,
  `criado_em` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cliques_anuncio` (`id_anuncio`,`criado_em`),
  CONSTRAINT `eventos_clique_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `eventos_clique` (`id`,`id_anuncio`,`canal`,`identificador_sessao`,`criado_em`) VALUES ('1','2','whatsapp','03f2e16bd6719632fd4706d041508f29524fc24625a12e0e96df6180c161568e','2026-10-28 11:40:48');
INSERT INTO `eventos_clique` (`id`,`id_anuncio`,`canal`,`identificador_sessao`,`criado_em`) VALUES ('2','2','instagram','03f2e16bd6719632fd4706d041508f29524fc24625a12e0e96df6180c161568e','2026-10-28 11:40:52');
INSERT INTO `eventos_clique` (`id`,`id_anuncio`,`canal`,`identificador_sessao`,`criado_em`) VALUES ('3','2','whatsapp','f8d16a911bb3198677a6d87db8edf919e3fcb27e4dcd9c4c3735b4f4ab2eccb6','2026-10-28 11:44:34');
INSERT INTO `eventos_clique` (`id`,`id_anuncio`,`canal`,`identificador_sessao`,`criado_em`) VALUES ('4','3','instagram','d41478d8a9d43eb8a567c9c9fcac6066db46b748cfdabe2c57cd405911e9dcb6','2026-10-28 12:21:50');
DROP TABLE IF EXISTS `fila_emails`;
CREATE TABLE `fila_emails` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `destinatario` varchar(254) NOT NULL,
  `assunto` varchar(200) NOT NULL,
  `mensagem` text DEFAULT NULL,
  `situacao` varchar(20) NOT NULL DEFAULT 'pendente',
  `tentativas` int(11) NOT NULL DEFAULT 0,
  `proxima_tentativa_em` datetime DEFAULT NULL,
  `bloqueado_em` datetime DEFAULT NULL,
  `enviado_em` datetime DEFAULT NULL,
  `ultimo_erro` varchar(200) DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `fila_emails` (`id`,`destinatario`,`assunto`,`mensagem`,`situacao`,`tentativas`,`proxima_tentativa_em`,`bloqueado_em`,`enviado_em`,`ultimo_erro`,`criado_em`) VALUES ('2','gustavo.pascoal@gmail.com','Defina sua senha — Portal do Bairro','Defina sua senha em até uma hora: http://localhost:8080/#definir-senha?token=802225fdd26e5b43e96151e54eb99cb6a7fc59c6435c76bf09f92e36bf078c96','pendente','0',NULL,NULL,NULL,NULL,'2026-10-28 08:36:07');
INSERT INTO `fila_emails` (`id`,`destinatario`,`assunto`,`mensagem`,`situacao`,`tentativas`,`proxima_tentativa_em`,`bloqueado_em`,`enviado_em`,`ultimo_erro`,`criado_em`) VALUES ('3','miguel@gmail.com','Defina sua senha — Portal do Bairro','Defina sua senha em até uma hora: http://localhost:8080/#definir-senha?token=9293899904d4705f964943fd084e2683addfabf6fef60fd506f04202c04ad8a1','pendente','0',NULL,NULL,NULL,NULL,'2026-10-28 09:06:26');
INSERT INTO `fila_emails` (`id`,`destinatario`,`assunto`,`mensagem`,`situacao`,`tentativas`,`proxima_tentativa_em`,`bloqueado_em`,`enviado_em`,`ultimo_erro`,`criado_em`) VALUES ('4','joyce@gmail.com','Defina sua senha — Portal do Bairro','Defina sua senha em até uma hora: http://localhost:8080/#definir-senha?token=f11f3efb13378be823e85dc3e7c53248ee4c7521bda15bb664403e0a8211c32d','pendente','0',NULL,NULL,NULL,NULL,'2026-10-28 10:02:06');
INSERT INTO `fila_emails` (`id`,`destinatario`,`assunto`,`mensagem`,`situacao`,`tentativas`,`proxima_tentativa_em`,`bloqueado_em`,`enviado_em`,`ultimo_erro`,`criado_em`) VALUES ('5','gustavo.pascoal@gmail.com','Avalie Timelo-rego','Avalie o atendimento com 1 a 5 estrelas: http://localhost:8080/#avaliar?token=c43583c64b2c036a2f407c13b180f3b7c57c7b145b58efe415fed4d52606849f — Link individual e de uso único.','pendente','0',NULL,NULL,NULL,NULL,'2026-10-28 11:50:07');
INSERT INTO `fila_emails` (`id`,`destinatario`,`assunto`,`mensagem`,`situacao`,`tentativas`,`proxima_tentativa_em`,`bloqueado_em`,`enviado_em`,`ultimo_erro`,`criado_em`) VALUES ('6','miguel@gmail.com','Defina sua senha - Portal do Bairro','Defina sua senha em até uma hora: http://localhost:8080/?portal=uvaranas#definir-senha?token=0cb18cc9bd8d035c9cf3894806b84803689ad3f1e75722a20500a605024f27e4','pendente','0',NULL,NULL,NULL,NULL,'2026-10-29 01:07:55');
DROP TABLE IF EXISTS `horarios_atendimento`;
CREATE TABLE `horarios_atendimento` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_portal` int(10) unsigned NOT NULL,
  `descricao` varchar(120) NOT NULL,
  `dias_semana` varchar(20) DEFAULT NULL,
  `hora_inicio` varchar(5) DEFAULT NULL,
  `hora_fim` varchar(5) DEFAULT NULL,
  `ativo` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_portal` (`id_portal`,`descricao`),
  CONSTRAINT `horarios_atendimento_ibfk_1` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `horarios_atendimento` (`id`,`id_portal`,`descricao`,`dias_semana`,`hora_inicio`,`hora_fim`,`ativo`) VALUES ('1','1','Segunda a sexta, das 08:00 às 18:00','1,2,3,4,5','08:00','18:00','1');
INSERT INTO `horarios_atendimento` (`id`,`id_portal`,`descricao`,`dias_semana`,`hora_inicio`,`hora_fim`,`ativo`) VALUES ('2','1','Sábado e domingo, das 08:00 às 12:00','6,7','08:00','12:00','1');
INSERT INTO `horarios_atendimento` (`id`,`id_portal`,`descricao`,`dias_semana`,`hora_inicio`,`hora_fim`,`ativo`) VALUES ('3','2','Segunda a sexta, das 08:00 às 18:00','1,2,3,4,5','08:00','18:00','1');
INSERT INTO `horarios_atendimento` (`id`,`id_portal`,`descricao`,`dias_semana`,`hora_inicio`,`hora_fim`,`ativo`) VALUES ('4','2','Sábado e domingo, das 08:00 às 12:00','6,7','08:00','12:00','1');
INSERT INTO `horarios_atendimento` (`id`,`id_portal`,`descricao`,`dias_semana`,`hora_inicio`,`hora_fim`,`ativo`) VALUES ('5','1','Segunda a sexta, das 8h às 18h',NULL,NULL,NULL,'1');
INSERT INTO `horarios_atendimento` (`id`,`id_portal`,`descricao`,`dias_semana`,`hora_inicio`,`hora_fim`,`ativo`) VALUES ('6','2','das 08:00 as 18:00',NULL,NULL,NULL,'1');
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
  UNIQUE KEY `nome_arquivo` (`nome_arquivo`),
  UNIQUE KEY `id_anuncio` (`id_anuncio`,`posicao`),
  CONSTRAINT `imagens_anuncios_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`posicao` between 1 and 3)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('4','2','0fd95a5016a7297faa3c884f481c79f3ece46166774f5480.jpg','image/jpeg','1','Operação de trabalho','2026-10-28 08:47:12');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('5','2','11e1e1ccb9d739c27b028b94e7c905196179372e8beffb7d.jpg','image/jpeg','2','Loja ou apresentação','2026-10-28 08:47:12');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('6','2','13f0c1de67b2029b46874a34a134d20bc1abcd4b236100b5.png','image/png','3','Fachada','2026-10-28 08:47:12');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('7','3','701fdbd5344858c4f00e41a0f19c6f6deeafad427073d7e3.jpg','image/jpeg','1','Loja ou apresentação','2026-10-28 09:20:30');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('8','3','298182fa1c2ae486ee85570680628801e417e6ec01d95a87.jpg','image/jpeg','2','Fachada','2026-10-28 09:20:30');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('9','4','97a50ded6b13a133dd503edb6d69000777d282ee6ba73c63.png','image/png','1','Loja ou apresentação','2026-10-28 11:56:27');
INSERT INTO `imagens_anuncios` (`id`,`id_anuncio`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`,`criado_em`) VALUES ('10','4','badb4df357cb2d8547e3ddae50cdfa69fc81e5144c47526a.png','image/png','2','Fachada','2026-10-28 11:56:27');
DROP TABLE IF EXISTS `imagens_revisoes`;
CREATE TABLE `imagens_revisoes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_revisao` int(10) unsigned NOT NULL,
  `nome_arquivo` varchar(70) NOT NULL,
  `tipo_mime` varchar(30) NOT NULL,
  `posicao` tinyint(4) NOT NULL,
  `legenda` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_revisao` (`id_revisao`,`posicao`),
  KEY `idx_revisoes_arquivo` (`nome_arquivo`),
  CONSTRAINT `imagens_revisoes_ibfk_1` FOREIGN KEY (`id_revisao`) REFERENCES `revisoes_anuncios` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`posicao` between 1 and 3)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('1','1','11e1e1ccb9d739c27b028b94e7c905196179372e8beffb7d.jpg','image/jpeg','1','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('2','1','13f0c1de67b2029b46874a34a134d20bc1abcd4b236100b5.png','image/png','2','Fachada');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('3','1','0fd95a5016a7297faa3c884f481c79f3ece46166774f5480.jpg','image/jpeg','3','Operação de trabalho');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('7','2','0fd95a5016a7297faa3c884f481c79f3ece46166774f5480.jpg','image/jpeg','1','Operação de trabalho');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('8','2','11e1e1ccb9d739c27b028b94e7c905196179372e8beffb7d.jpg','image/jpeg','2','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('9','2','13f0c1de67b2029b46874a34a134d20bc1abcd4b236100b5.png','image/png','3','Fachada');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('10','3','0fd95a5016a7297faa3c884f481c79f3ece46166774f5480.jpg','image/jpeg','1','Operação de trabalho');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('11','3','11e1e1ccb9d739c27b028b94e7c905196179372e8beffb7d.jpg','image/jpeg','2','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('12','3','13f0c1de67b2029b46874a34a134d20bc1abcd4b236100b5.png','image/png','3','Fachada');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('13','4','701fdbd5344858c4f00e41a0f19c6f6deeafad427073d7e3.jpg','image/jpeg','1','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('14','4','298182fa1c2ae486ee85570680628801e417e6ec01d95a87.jpg','image/jpeg','2','Fachada');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('15','5','97a50ded6b13a133dd503edb6d69000777d282ee6ba73c63.png','image/png','1','Loja ou apresentação');
INSERT INTO `imagens_revisoes` (`id`,`id_revisao`,`nome_arquivo`,`tipo_mime`,`posicao`,`legenda`) VALUES ('16','5','badb4df357cb2d8547e3ddae50cdfa69fc81e5144c47526a.png','image/png','2','Fachada');
DROP TABLE IF EXISTS `organizacoes`;
CREATE TABLE `organizacoes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `organizacoes` (`id`,`nome`,`criado_em`) VALUES ('1','Annecont Contabilidade','2026-10-28 00:28:17');
INSERT INTO `organizacoes` (`id`,`nome`,`criado_em`) VALUES ('2','Alessandra','2026-10-28 08:59:55');
DROP TABLE IF EXISTS `pagamentos`;
CREATE TABLE `pagamentos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_cobranca` int(10) unsigned NOT NULL,
  `valor_centavos` int(10) unsigned NOT NULL,
  `recebido_em` datetime NOT NULL,
  `registrado_por` int(10) unsigned NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_cobranca` (`id_cobranca`),
  CONSTRAINT `pagamentos_ibfk_1` FOREIGN KEY (`id_cobranca`) REFERENCES `cobrancas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `pagamentos` (`id`,`id_cobranca`,`valor_centavos`,`recebido_em`,`registrado_por`,`criado_em`) VALUES ('1','2','5000','2026-10-28 11:47:28','1','2026-10-28 08:47:28');
INSERT INTO `pagamentos` (`id`,`id_cobranca`,`valor_centavos`,`recebido_em`,`registrado_por`,`criado_em`) VALUES ('2','4','20000','2026-10-29 10:41:00','1','2026-10-29 07:41:00');
INSERT INTO `pagamentos` (`id`,`id_cobranca`,`valor_centavos`,`recebido_em`,`registrado_por`,`criado_em`) VALUES ('3','3','20000','2026-10-29 10:41:59','1','2026-10-29 07:41:59');
INSERT INTO `pagamentos` (`id`,`id_cobranca`,`valor_centavos`,`recebido_em`,`registrado_por`,`criado_em`) VALUES ('4','5','2497','2026-10-29 10:44:16','7','2026-10-29 07:44:16');
INSERT INTO `pagamentos` (`id`,`id_cobranca`,`valor_centavos`,`recebido_em`,`registrado_por`,`criado_em`) VALUES ('5','6','5000','2026-10-29 10:44:19','7','2026-10-29 07:44:19');
DROP TABLE IF EXISTS `periodos_publicacao`;
CREATE TABLE `periodos_publicacao` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_anuncio` int(10) unsigned NOT NULL,
  `id_cobranca` int(10) unsigned NOT NULL,
  `inicio_em` date NOT NULL,
  `fim_em` date NOT NULL,
  `registrado_por` int(10) unsigned NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_cobranca` (`id_cobranca`),
  KEY `id_anuncio` (`id_anuncio`),
  CONSTRAINT `periodos_publicacao_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`),
  CONSTRAINT `periodos_publicacao_ibfk_2` FOREIGN KEY (`id_cobranca`) REFERENCES `cobrancas` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`fim_em` >= `inicio_em`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `periodos_publicacao` (`id`,`id_anuncio`,`id_cobranca`,`inicio_em`,`fim_em`,`registrado_por`,`criado_em`) VALUES ('1','2','2','2026-10-28','2026-11-26','1','2026-10-28 08:40:16');
INSERT INTO `periodos_publicacao` (`id`,`id_anuncio`,`id_cobranca`,`inicio_em`,`fim_em`,`registrado_por`,`criado_em`) VALUES ('2','3','5','2026-10-28','2026-11-26','7','2026-10-28 09:20:30');
INSERT INTO `periodos_publicacao` (`id`,`id_anuncio`,`id_cobranca`,`inicio_em`,`fim_em`,`registrado_por`,`criado_em`) VALUES ('3','4','6','2026-10-28','2026-11-26','7','2026-10-28 11:56:27');
DROP TABLE IF EXISTS `portais`;
CREATE TABLE `portais` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_organizacao` int(10) unsigned NOT NULL,
  `identificador` varchar(100) NOT NULL,
  `nome` varchar(120) NOT NULL,
  `limite_anuncios` int(11) NOT NULL DEFAULT 10,
  `cor_principal` varchar(7) NOT NULL DEFAULT '#7C3AED',
  `logotipo` varchar(200) DEFAULT NULL,
  `ativo` tinyint(4) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `endereco_local` varchar(250) NOT NULL DEFAULT '',
  `cor_texto` varchar(7) NOT NULL DEFAULT '#FFFFFF',
  `fonte` varchar(30) NOT NULL DEFAULT 'Inter',
  PRIMARY KEY (`id`),
  UNIQUE KEY `identificador` (`identificador`),
  KEY `id_organizacao` (`id_organizacao`),
  CONSTRAINT `portais_ibfk_1` FOREIGN KEY (`id_organizacao`) REFERENCES `organizacoes` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`limite_anuncios` between 1 and 10000)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `portais` (`id`,`id_organizacao`,`identificador`,`nome`,`limite_anuncios`,`cor_principal`,`logotipo`,`ativo`,`criado_em`,`endereco_local`,`cor_texto`,`fonte`) VALUES ('1','1','annecont','Vitrine Annecont','10','#1f05e6','','1','2026-10-28 00:28:17','','#FFFFFF','Inter');
INSERT INTO `portais` (`id`,`id_organizacao`,`identificador`,`nome`,`limite_anuncios`,`cor_principal`,`logotipo`,`ativo`,`criado_em`,`endereco_local`,`cor_texto`,`fonte`) VALUES ('2','2','uvaranas','Residencial Bellas','20','#3ea037','','1','2026-10-28 08:59:55','','#ffffff','Verdana');
DROP TABLE IF EXISTS `registros_auditoria`;
CREATE TABLE `registros_auditoria` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int(10) unsigned DEFAULT NULL,
  `id_portal` int(10) unsigned DEFAULT NULL,
  `acao` varchar(80) NOT NULL,
  `id_anuncio` int(10) unsigned DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_auditoria_portal` (`id_portal`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('2','1','1','portal.identity.changed',NULL,'2026-10-28 08:34:22');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('3','1','1','advertiser.access.created','2','2026-10-28 08:36:07');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('4','1','1','catalog.submitted','2','2026-10-28 08:39:51');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('5','1','1','catalog.images.submitted','2','2026-10-28 08:39:51');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('6','1','1','catalog.approved','2','2026-10-28 08:40:16');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('7','5','1','catalog.cover.submitted','2','2026-10-28 08:43:59');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('8','5','1','catalog.submitted','2','2026-10-28 08:44:06');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('9','1','1','catalog.rejected','2','2026-10-28 08:46:02');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('10','5','1','catalog.submitted','2','2026-10-28 08:46:39');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('11','1','1','catalog.approved','2','2026-10-28 08:47:12');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('12','1','1','charge.paid',NULL,'2026-10-28 08:47:28');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('13','6','1','commercial.changed','2','2026-10-28 08:53:01');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('14','1','2','portal.created',NULL,'2026-10-28 08:59:55');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('15','7','2','advertiser.access.created','3','2026-10-28 09:06:26');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('16','8','2','catalog.submitted','3','2026-10-28 09:18:03');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('17','8','2','catalog.images.submitted','3','2026-10-28 09:18:04');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('18','7','2','catalog.approved','3','2026-10-28 09:20:30');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('19','7','2','commercial.changed','3','2026-10-28 09:26:01');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('20','7','2','advertiser.access.created','4','2026-10-28 10:02:06');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('21','1','2','portal.capacity.changed',NULL,'2026-10-28 11:48:31');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('22','8','2','rating.invited','3','2026-10-28 11:50:07');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('23','7','2','portal.identity.changed',NULL,'2026-10-28 11:52:43');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('24','9','2','catalog.submitted','4','2026-10-28 11:55:29');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('25','9','2','catalog.images.submitted','4','2026-10-28 11:55:29');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('26','7','2','catalog.approved','4','2026-10-28 11:56:27');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('27','7','2','catalog.archived','4','2026-10-29 00:52:24');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('28','7','2','portal.identity.changed',NULL,'2026-10-29 00:56:09');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('29','7','2','portal.identity.changed',NULL,'2026-10-29 00:56:21');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('30','7','2','advertiser.access.redefinir',NULL,'2026-10-29 01:07:55');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('31','1','2','charge.paid',NULL,'2026-10-29 07:41:00');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('32','1','1','charge.paid',NULL,'2026-10-29 07:41:59');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('33','7','2','charge.paid',NULL,'2026-10-29 07:44:16');
INSERT INTO `registros_auditoria` (`id`,`id_usuario`,`id_portal`,`acao`,`id_anuncio`,`criado_em`) VALUES ('34','7','2','charge.paid',NULL,'2026-10-29 07:44:19');
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
  KEY `id_autor` (`id_autor`),
  KEY `id_revisor` (`id_revisor`),
  KEY `idx_revisoes_anuncio` (`id_anuncio`,`id`),
  CONSTRAINT `revisoes_anuncios_ibfk_1` FOREIGN KEY (`id_anuncio`) REFERENCES `anuncios` (`id`),
  CONSTRAINT `revisoes_anuncios_ibfk_2` FOREIGN KEY (`id_autor`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `revisoes_anuncios_ibfk_3` FOREIGN KEY (`id_revisor`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`situacao` in ('pending','approved','rejected'))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('1','2','1','{\"name\":\"Gustavo Lacoste Maia\",\"service\":\"Troca de Óleo\",\"description\":\"Somos a empresa de desenvolvimento\",\"tags\":\"pedreiro alvenaria piso parede reforma pintura\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rua Antonil, 46 ponta grossa\",\"area\":\"Vitrine Annecont\",\"whatsapp\":\"42984295615\",\"instagram\":\"gusgoncalves81\",\"category\":\"limpeza\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Atendimento\\\",\\\"Programação\\\",\\\"teste\\\",\\\"mais um teste\\\"]\"}','approved','3','1','','2026-10-28 08:39:51','2026-10-28 11:40:16');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('2','2','5','{\"name\":\"Gustavo Lacoste Maia\",\"service\":\"Troca de Óleo\",\"description\":\"Somos a empresa de desenvolvimento\",\"tags\":\"pedreiro alvenaria piso parede reforma pintura\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rua Antonil, 46 ponta grossa\",\"area\":\"Vitrine Annecont\",\"whatsapp\":\"42984295615\",\"instagram\":\"gusgoncalves81\",\"category\":\"limpeza\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Atendimento\\\",\\\"Programação\\\",\\\"teste\\\",\\\"mais um teste\\\"]\"}','rejected','3','1','Precisa ver o nome do campo','2026-10-28 08:44:06','2026-10-28 11:46:02');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('3','2','5','{\"name\":\"Gustavo Lacoste Maia\",\"service\":\"Troca de Óleo\",\"description\":\"Somos a empresa de desenvolvimento\",\"tags\":\"pedreiro alvenaria piso parede reforma pintura\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rua Antonil, 46 ponta grossa\",\"area\":\"Vitrine Annecont\",\"whatsapp\":\"42984295615\",\"instagram\":\"gusgoncalves81\",\"category\":\"limpeza\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Atendimento\\\",\\\"Programação\\\",\\\"teste\\\",\\\"mais um teste\\\"]\"}','approved','2','1','','2026-10-28 08:46:39','2026-10-28 11:47:12');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('4','3','8','{\"name\":\"Timelo-rego\",\"service\":\"Regos macios\",\"description\":\"asd asdasdasdasdsdasdsadasdsadasdsadasdadasdadadadasdad\",\"tags\":\"Serviços feitos com qualidade de segurança de jardinagem\",\"hours\":\"das 08:00 as 18:00\",\"address\":\"Rua nsaksaskasnasnasnasnasmnasmansmanmsas\",\"area\":\"Residencial Bellas\",\"whatsapp\":\"5542988717304\",\"instagram\":\"teste\",\"category\":\"jardim\",\"mode\":\"Em estabelecimento\",\"services\":\"[\\\"jardim\\\",\\\"casa\\\",\\\"bairro\\\",\\\"lar\\\"]\"}','approved','3','7','','2026-10-28 09:18:03','2026-10-28 12:20:30');
INSERT INTO `revisoes_anuncios` (`id`,`id_anuncio`,`id_autor`,`conteudo`,`situacao`,`versao`,`id_revisor`,`parecer`,`enviado_em`,`analisado_em`) VALUES ('5','4','9','{\"name\":\"fdfdsfsfsdfsdfs\",\"service\":\"wrwerrwerwerwerwerwe\",\"description\":\"werwerwerwerwerewrwerwerwer\",\"tags\":\"werwerwerewrwerwr\",\"hours\":\"das 08:00 as 18:00\",\"address\":\"eewerrwrwerwerwer\",\"area\":\"Residencial Bellas\",\"whatsapp\":\"23232323232\",\"instagram\":\"wewewewe\",\"category\":\"reformas\",\"mode\":\"Em estabelecimento\",\"id_horario\":6,\"services\":\"[\\\"ewrerer\\\",\\\"werewrwer\\\",\\\"wrwer\\\",\\\"erwerew\\\",\\\"rewr\\\",\\\"ewr\\\",\\\"wr\\\",\\\"wr\\\",\\\"erw\\\",\\\"er\\\",\\\"we\\\"]\"}','approved','3','7','','2026-10-28 11:55:29','2026-10-28 14:56:27');
DROP TABLE IF EXISTS `tentativas_login`;
CREATE TABLE `tentativas_login` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `identificador_origem` char(64) NOT NULL,
  `tentado_em` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tentativas_origem` (`identificador_origem`,`tentado_em`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `tentativas_login` (`id`,`identificador_origem`,`tentado_em`) VALUES ('68','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1793270287');
INSERT INTO `tentativas_login` (`id`,`identificador_origem`,`tentado_em`) VALUES ('70','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1793270448');
INSERT INTO `tentativas_login` (`id`,`identificador_origem`,`tentado_em`) VALUES ('72','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1793270567');
DROP TABLE IF EXISTS `tokens_acesso`;
CREATE TABLE `tokens_acesso` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int(10) unsigned NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expira_em` datetime NOT NULL,
  `utilizado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `tokens_acesso_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `tokens_acesso` (`id`,`id_usuario`,`token_hash`,`expira_em`,`utilizado_em`) VALUES ('2','5','20ad6e50f8d00ee01b979517041875d25ab137a80eed7e76ee5b9cc34a5bf088','2026-10-28 12:36:07',NULL);
INSERT INTO `tokens_acesso` (`id`,`id_usuario`,`token_hash`,`expira_em`,`utilizado_em`) VALUES ('3','8','56958e7b91d30f4386eabc61ca19c344f38938e8e81eac5bd1d09254ee66b67a','2026-10-28 13:06:26','2026-10-29 04:07:55');
INSERT INTO `tokens_acesso` (`id`,`id_usuario`,`token_hash`,`expira_em`,`utilizado_em`) VALUES ('4','9','8e7ded6113efa1ac7c2d6c3a4d8e295083f36577502d3ae99481a95112e9b76c','2026-10-28 14:02:06',NULL);
INSERT INTO `tokens_acesso` (`id`,`id_usuario`,`token_hash`,`expira_em`,`utilizado_em`) VALUES ('5','8','0218e901a29a13eef05997d99cf420a055399dae330f8f4356bf88b6bc836a9f','2026-10-29 05:07:55',NULL);
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
  KEY `id_anunciante` (`id_anunciante`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_anunciante`) REFERENCES `anunciantes` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`perfil` in ('master','manager','advertiser'))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('1','Administrador','admin@portal.local','$2y$10$OXoJS5/KrpfuxrlLCK52Bek5QyMpTLQdE5.fMR1D9trN.8RfmaIMa','master',NULL,'1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('5','Gustavo','gustavo.pascoal@gmail.com','$2y$10$hIhlRT/z22L/LcuY5xYUR.GOm4tOUvoswA1/kiuYZogNreLv9DwX6','advertiser','2','1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('6','Anne','annecont@gmail.com','$2y$10$gkPzkdBd2kyB7hAGszat9OHH27SZxgHjuRldL4AcHg8LhExOsap4q','manager',NULL,'1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('7','Alessandra','alessandra@gmail.com','$2y$10$4rROVrA0nKdAJ6WqjzvjLujPa6QrNObuLnLorlXiUJJCbEdxWvsnu','manager',NULL,'1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('8','Miguel','miguel@gmail.com','$2y$10$Umm7UvYitUi3lxg8dypd5uG4P4E.vLEeuWUNZghVZmcXTWuWffAs.','advertiser','3','1');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`perfil`,`id_anunciante`,`ativo`) VALUES ('9','Joyce','joyce@gmail.com','$2y$10$x3GXHmlynr2zbeClNSSFnuFP19Q5y2KY9zHVz2EXhtuchAIu5Jsc.','advertiser','4','1');
DROP TABLE IF EXISTS `usuarios_portais`;
CREATE TABLE `usuarios_portais` (
  `id_usuario` int(10) unsigned NOT NULL,
  `id_portal` int(10) unsigned NOT NULL,
  `ativo` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_usuario`,`id_portal`),
  KEY `id_portal` (`id_portal`),
  CONSTRAINT `usuarios_portais_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `usuarios_portais_ibfk_2` FOREIGN KEY (`id_portal`) REFERENCES `portais` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`,`ativo`) VALUES ('5','1','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`,`ativo`) VALUES ('6','1','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`,`ativo`) VALUES ('7','2','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`,`ativo`) VALUES ('8','2','1');
INSERT INTO `usuarios_portais` (`id_usuario`,`id_portal`,`ativo`) VALUES ('9','2','1');
SET FOREIGN_KEY_CHECKS=1;
