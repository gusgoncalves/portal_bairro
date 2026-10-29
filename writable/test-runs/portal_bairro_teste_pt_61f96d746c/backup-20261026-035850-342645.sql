-- Backup antes da tradução. Restaurar em base vazia.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE `organizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `organizations` (`id`,`name`,`created_at`) VALUES ('1','Organização de teste','2026-10-25 23:58:49');
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
INSERT INTO `portals` (`id`,`organization_id`,`slug`,`name`,`capacity`,`active`,`created_at`) VALUES ('1','1','teste','Nome com acentuação','10','1','2026-10-25 23:58:49');
CREATE TABLE `advertisers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `advertisers` (`id`,`name`) VALUES ('1','Empresa de teste');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `users` (`id`,`name`,`email`,`password_hash`,`role`,`advertiser_id`,`active`) VALUES ('1','Empresa','teste@teste.local','hash-teste','advertiser','1','1');
CREATE TABLE `memberships` (
  `user_id` int(10) unsigned NOT NULL,
  `portal_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`portal_id`),
  KEY `portal_id` (`portal_id`),
  CONSTRAINT `memberships_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `memberships_ibfk_2` FOREIGN KEY (`portal_id`) REFERENCES `portals` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `memberships` (`user_id`,`portal_id`) VALUES ('1','1');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `publications` (`id`,`portal_id`,`advertiser_id`,`name`,`category`,`service`,`description`,`tags`,`color`,`accent`,`type`,`mode`,`hours`,`address`,`area`,`whatsapp`,`instagram`,`services`,`status`,`created_at`,`updated_at`) VALUES ('1','1','1','users name preservado','reformas','Serviço','Descrição','','#d6dfce','#64846c','home','A domicílio','8h','','','','','[\"Serviço\"]','published','2026-10-25 23:58:49','2026-10-25 23:58:49');
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
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `portal_id` int(10) unsigned DEFAULT NULL,
  `action` varchar(80) NOT NULL,
  `publication_id` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `portal_audit` (`portal_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `login_attempts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fingerprint` char(64) NOT NULL,
  `attempted_at` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `attempt_lookup` (`fingerprint`,`attempted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
INSERT INTO `publication_revisions` (`id`,`publication_id`,`author_id`,`payload`,`status`,`version`,`reviewer_id`,`review_note`,`submitted_at`,`reviewed_at`) VALUES ('1','1','1','{}','pending','1',NULL,NULL,'2026-10-25 23:58:49',NULL);
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
INSERT INTO `revision_images` (`id`,`revision_id`,`filename`,`mime`,`slot`,`caption`) VALUES ('1','1','teste.jpg','image/jpeg','1','Fachada');
SET FOREIGN_KEY_CHECKS=1;
