-- Backup antes da tradução. Restaurar em base vazia.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE `organizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `organizations` (`id`,`name`,`created_at`) VALUES ('1','Gestão Vila Esperança','2026-10-25 23:11:13');
INSERT INTO `organizations` (`id`,`name`,`created_at`) VALUES ('2','sadadadasdas','2026-10-25 23:31:09');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `portals` (`id`,`organization_id`,`slug`,`name`,`capacity`,`active`,`created_at`) VALUES ('1','1','vila-esperanca','Vila Esperança','10','1','2026-10-25 23:11:13');
INSERT INTO `portals` (`id`,`organization_id`,`slug`,`name`,`capacity`,`active`,`created_at`) VALUES ('2','2','asdadsadsadadsad','dadsdd','10','1','2026-10-25 23:31:09');
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
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('1','Master','master@portal.local','$2y$10$XXr5saEhis2rZhihVn/2ceeOTcixfTV.weOkC8ssQbkORarSXOZ3G','master',NULL,'1');
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('2','Gestor','gestor@portal.local','$2y$10$Uu.FBk5p0Fu4ZtZOtRJnj.1AstMywzGTiOUxNEN4NYNe2rjK64rxm','manager',NULL,'1');
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('3','Anunciante','anunciante@portal.local','$2y$10$TRUrbOdBcy72bNGh..b5buqsXOsYQT5nJVvEF9eGVDPh7tmdsNo4.','advertiser','1','1');
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('4','Administrador','admin@portal.local','$2y$10$ykeOyEiHYu3OCbUQuCBYIeIhVjq5EO1b4GO950XUPV3w8qfnpxWJO','master',NULL,'1');
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
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('1','1','1','João · Reparos & Soluçõessddsdd','reformas','Elétrica e pequenos reparos','Uma mão experiente para os reparos e cuidados da sua casa.','eletricista tomada manutenção lâmpada eletrica','#d6dfce','#64846c','home','A domicílio','Segunda a sexta, das 8h às 18h','','Vila Esperança e arredores','42999999999','sdasdadsadsdsadsa','[\"Instalação de luminárias\",\"Troca de tomadas e interruptores\",\"Pequenos reparos residenciais\"]','published','2026-10-25 23:11:13','2026-10-25 23:37:59');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('2','1','2','Ateliê da Ana','beleza','Manicure e pedicure','Cuidado, delicadeza e um momento só seu, pertinho de casa.','unha esmalte manicure pedicure beleza','#ead4ca','#b37a69','beauty','Em estabelecimento','Terça a sábado, das 9h às 18h','','Vila Esperança e arredores','','','[\"Manicure e pedicure\",\"Esmaltação\",\"Cuidados com as unhas\"]','published','2026-10-25 23:11:13','2026-10-25 23:20:21');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('3','1','3','Sabores da Dona Lúcia','alimentacao','Comida caseira e encomendas','Receitas com carinho para o almoço e os encontros em família.','cozinheira comida marmita bolo almoço cozinha','#eeddb9','#bb8c45','food','Encomendas e retirada','Segunda a sábado, das 8h às 16h','','Vila Esperança e arredores','','','[\"Marmitas por encomenda\",\"Bolos caseiros\",\"Refeições para pequenos encontros\"]','published','2026-10-25 23:11:13','2026-10-25 23:11:13');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('4','1','4','Casa Leve com Maria','limpeza','Limpeza e organização','Mais tranquilidade e cuidado com cada cantinho do seu lar.','faxineira faxina diarista limpeza organização','#d0e1df','#558c88','clean','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Limpeza residencial\",\"Organização de ambientes\",\"Limpeza de manutenção\"]','published','2026-10-25 23:11:13','2026-10-25 23:20:19');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('5','1','5','Carlos · Hidráulica Local','reformas','Encanador residencial','Atendimento para vazamentos e manutenção hidráulica residencial.','encanador vazamento torneira cano hidráulica','#d6dfe6','#6a859d','home','A domicílio','Segunda a sábado, das 8h às 18h','','Vila Esperança e arredores','','','[\"Reparo de vazamentos\",\"Troca de torneiras\",\"Manutenção hidráulica\"]','published','2026-10-25 23:11:13','2026-10-25 23:11:13');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('6','1','6','Barbearia do Rafa','beleza','Cabelo e barba','Seu corte em dia, com conversa boa e atendimento no bairro.','barbeiro cabelo corte barba cabeleireiro','#d9d7cb','#7c7e60','beauty','Em estabelecimento','Terça a sábado, das 9h às 19h','','Vila Esperança e arredores','','','[\"Corte masculino\",\"Barba\",\"Acabamento\"]','published','2026-10-25 23:11:13','2026-10-25 23:20:15');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('7','1','7','Verde Perto · Jardinagem','jardim','Cuidados com jardins','Um olhar cuidadoso para deixar seu espaço mais verde.','jardineiro jardim poda grama plantas','#dbe4c7','#7e9854','plant','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Manutenção de jardins\",\"Corte de grama\",\"Cuidados com plantas\"]','published','2026-10-25 23:11:13','2026-10-25 23:11:13');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('8','1','8','Pedro · Construção e Reforma','reformas','Pedreiro e acabamentos','Do pequeno ajuste à reforma, atenção aos detalhes da sua casa.','pedreiro alvenaria piso parede reforma pintura','#e7d4bf','#a77b55','home','A domicílio','Segunda a sexta, das 8h às 17h','','Vila Esperança e arredores','','','[\"Pequenas reformas\",\"Assentamento de pisos\",\"Reparos em alvenaria\"]','published','2026-10-25 23:11:13','2026-10-25 23:22:14');
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('9','1','9','Doces da Bia','alimentacao','Doces e bolos para festas','Encomendas artesanais para celebrar os momentos especiais.','doce festa bolo brigadeiro','#eddcd7','#b7847a','food','Encomendas e retirada','Terça a sábado, das 9h às 17h','','Vila Esperança e arredores','','','[\"Bolos\",\"Doces para festas\"]','published','2026-10-25 23:11:13','2026-10-25 23:38:09');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `publication_images` (`id`,`publication_id`,`filename`,`mime`,`slot`,`caption`,`created_at`) VALUES ('1','8','09f8fdc9d8b5702d5b37a6cf3bdb685b60146bc03538f87e.png','image/png','1','Loja ou apresentação','2026-10-25 23:22:14');
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `portal_id` int(10) unsigned DEFAULT NULL,
  `action` varchar(80) NOT NULL,
  `publication_id` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `portal_audit` (`portal_id`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('1','4','1','catalog.submitted','9','2026-10-25 23:11:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('2','4','1','catalog.suspended','8','2026-10-25 23:13:54');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('3','4','1','catalog.suspended','6','2026-10-25 23:15:35');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('4','4','1','catalog.suspended','4','2026-10-25 23:15:36');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('5','4','1','catalog.suspended','2','2026-10-25 23:15:38');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('6','4','1','catalog.suspended','1','2026-10-25 23:15:41');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('7','4','1','catalog.published','6','2026-10-25 23:20:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('8','4','1','catalog.published','4','2026-10-25 23:20:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('9','4','1','catalog.published','2','2026-10-25 23:20:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('10','4','1','catalog.published','1','2026-10-25 23:20:22');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('11','4','1','catalog.published','8','2026-10-25 23:20:25');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('12','4','1','catalog.submitted','8','2026-10-25 23:21:47');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('13','4','1','catalog.images.submitted','8','2026-10-25 23:21:47');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('14','4','1','catalog.approved','8','2026-10-25 23:22:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('15','4','1','charge.created',NULL,'2026-10-25 23:28:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('16','1','2','portal.created',NULL,'2026-10-25 23:31:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('17','1','1','charge.paid',NULL,'2026-10-25 23:32:07');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('18','3','1','catalog.submitted','1','2026-10-25 23:34:08');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('19','1','1','catalog.rejected','1','2026-10-25 23:36:23');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('20','1','1','catalog.submitted','1','2026-10-25 23:37:42');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('21','1','1','catalog.approved','1','2026-10-25 23:37:59');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('22','1','1','catalog.approved','9','2026-10-25 23:38:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('23','3','1','catalog.submitted','1','2026-10-25 23:42:41');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('24','1','1','catalog.rejected','1','2026-10-25 23:44:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`portal_id`,`action`,`publication_id`,`created_at`) VALUES ('25','3','1','catalog.submitted','1','2026-10-25 23:45:49');
CREATE TABLE `login_attempts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fingerprint` char(64) NOT NULL,
  `attempted_at` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `attempt_lookup` (`fingerprint`,`attempted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `login_attempts` (`id`,`fingerprint`,`attempted_at`) VALUES ('4','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1792981809');
INSERT INTO `login_attempts` (`id`,`fingerprint`,`attempted_at`) VALUES ('6','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1792981956');
INSERT INTO `login_attempts` (`id`,`fingerprint`,`attempted_at`) VALUES ('8','eff8e7ca506627fe15dda5e0e512fcaad70b6d520f37cc76597fdb4f2d83a1a3','1792982129');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `charges` (`id`,`portal_id`,`publication_id`,`description`,`amount_cents`,`due_date`,`paid_at`,`created_at`) VALUES ('1','1',NULL,'dssdsdsd','51200','2026-11-03','2026-10-25 23:32:07','2026-10-25 23:28:17');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('1','9','4','{\"name\":\"Doces da Bia\",\"service\":\"Doces e bolos para festas\",\"description\":\"Encomendas artesanais para celebrar os momentos especiais.\",\"tags\":\"doce festa bolo brigadeiro\",\"hours\":\"Terça a sábado, das 9h às 17h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"\",\"instagram\":\"\",\"category\":\"alimentacao\",\"mode\":\"Encomendas e retirada\",\"services\":\"[\\\"Bolos\\\",\\\"Doces para festas\\\"]\"}','approved','2','1','','2026-10-25 23:11:14','2026-10-25 23:38:09');
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('2','8','4','{\"name\":\"Pedro · Construção e Reforma\",\"service\":\"Pedreiro e acabamentos\",\"description\":\"Do pequeno ajuste à reforma, atenção aos detalhes da sua casa.\",\"tags\":\"pedreiro alvenaria piso parede reforma pintura\",\"hours\":\"Segunda a sexta, das 8h às 17h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"\",\"instagram\":\"\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Pequenas reformas\\\",\\\"Assentamento de pisos\\\",\\\"Reparos em alvenaria\\\"]\"}','approved','3','4','','2026-10-25 23:21:47','2026-10-25 23:22:14');
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('3','1','3','{\"name\":\"João · Reparos & Soluções\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','rejected','2','1','Não está correto','2026-10-25 23:34:08','2026-10-25 23:36:23');
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('4','1','1','{\"name\":\"João · Reparos & Soluçõessddsdd\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','approved','2','1','','2026-10-25 23:37:42','2026-10-25 23:37:59');
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('5','1','3','{\"name\":\"João · Reparos & Soluçõessddsdd\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rerwererwerrwer\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','rejected','2','1','errwerwer weewwe wer wer we wewe','2026-10-25 23:42:41','2026-10-25 23:44:10');
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('6','1','3','{\"name\":\"João · Reparos & Soluçõessddsdd\",\"service\":\"Elétrica e pequenos reparos\",\"description\":\"Uma mão experiente para os reparos e cuidados da sua casa.\",\"tags\":\"eletricista tomada manutenção lâmpada eletrica\",\"hours\":\"Segunda a sexta, das 8h às 18h\",\"address\":\"rerqe32322323233\",\"area\":\"Vila Esperança e arredores\",\"whatsapp\":\"42999999999\",\"instagram\":\"sdasdadsadsdsadsa\",\"category\":\"reformas\",\"mode\":\"A domicílio\",\"services\":\"[\\\"Instalação de luminárias\\\",\\\"Troca de tomadas e interruptores\\\",\\\"Pequenos reparos residenciais\\\"]\"}','pending','2',NULL,NULL,'2026-10-25 23:45:49',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `revision_images` (`id`,`revision_id`,`filename`,`mime`,`slot`,`caption`) VALUES ('1','2','09f8fdc9d8b5702d5b37a6cf3bdb685b60146bc03538f87e.png','image/png','1','Loja ou apresentação');
SET FOREIGN_KEY_CHECKS=1;
