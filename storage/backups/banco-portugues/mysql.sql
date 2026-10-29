-- Portal do Bairro / MySQL 8+ ou MariaDB 10.4+ (XAMPP).
-- Não remove bases ou registros existentes. Executar antes do instalador de contas.
CREATE DATABASE IF NOT EXISTS portal_bairro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE portal_bairro;
CREATE TABLE IF NOT EXISTS organizations (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS portals (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, organization_id INT UNSIGNED NOT NULL,
 slug VARCHAR(100) NOT NULL UNIQUE, name VARCHAR(120) NOT NULL,
 capacity INT NOT NULL DEFAULT 10, active TINYINT NOT NULL DEFAULT 1,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (organization_id) REFERENCES organizations(id),
 CHECK (capacity IN (10,50,100,200))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS advertisers (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL,
 email VARCHAR(190) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL,
 role VARCHAR(20) NOT NULL, advertiser_id INT UNSIGNED NULL,
 active TINYINT NOT NULL DEFAULT 1,
 FOREIGN KEY (advertiser_id) REFERENCES advertisers(id),
 CHECK(role IN ('master','manager','advertiser'))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS memberships (
 user_id INT UNSIGNED NOT NULL, portal_id INT UNSIGNED NOT NULL,
 PRIMARY KEY(user_id,portal_id),
 FOREIGN KEY(user_id) REFERENCES users(id), FOREIGN KEY(portal_id) REFERENCES portals(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS publications (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, portal_id INT UNSIGNED NOT NULL,
 advertiser_id INT UNSIGNED NOT NULL, name VARCHAR(120) NOT NULL,
 category VARCHAR(30) NOT NULL, service VARCHAR(100) NOT NULL,
 description TEXT NOT NULL, tags VARCHAR(200) NOT NULL DEFAULT '',
 color VARCHAR(10) NOT NULL DEFAULT '#d6dfce', accent VARCHAR(10) NOT NULL DEFAULT '#64846c',
 type VARCHAR(20) NOT NULL DEFAULT 'home', mode VARCHAR(50) NOT NULL,
 hours VARCHAR(120) NOT NULL, address VARCHAR(200) NOT NULL DEFAULT '',
 area VARCHAR(200) NOT NULL DEFAULT '', whatsapp VARCHAR(15) NOT NULL DEFAULT '',
 instagram VARCHAR(40) NOT NULL DEFAULT '', services TEXT NOT NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'pending',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(portal_id) REFERENCES portals(id), FOREIGN KEY(advertiser_id) REFERENCES advertisers(id),
 UNIQUE(portal_id,advertiser_id), INDEX portal_status(portal_id,status),
 CHECK(status IN ('pending','published','suspended','archived'))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS publication_images (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, publication_id INT UNSIGNED NOT NULL,
 filename VARCHAR(70) NOT NULL UNIQUE, mime VARCHAR(30) NOT NULL,
 slot TINYINT NOT NULL, caption VARCHAR(100) NOT NULL DEFAULT '',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(publication_id) REFERENCES publications(id),
 UNIQUE(publication_id,slot), CHECK(slot BETWEEN 1 AND 3)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id INT UNSIGNED NULL,
 portal_id INT UNSIGNED NULL, action VARCHAR(80) NOT NULL,
 publication_id INT UNSIGNED NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX portal_audit(portal_id,id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS login_attempts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, fingerprint CHAR(64) NOT NULL,
 attempted_at BIGINT NOT NULL, INDEX attempt_lookup(fingerprint,attempted_at)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS charges (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, portal_id INT UNSIGNED NOT NULL,
 publication_id INT UNSIGNED NULL, description VARCHAR(150) NOT NULL,
 amount_cents INT UNSIGNED NOT NULL, due_date DATE NOT NULL, paid_at DATETIME NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(portal_id) REFERENCES portals(id), FOREIGN KEY(publication_id) REFERENCES publications(id),
 INDEX charge_portal(portal_id,due_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS publication_revisions (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, publication_id INT UNSIGNED NOT NULL,
 author_id INT UNSIGNED NOT NULL, payload LONGTEXT NOT NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'pending', version INT NOT NULL DEFAULT 1,
 reviewer_id INT UNSIGNED NULL, review_note TEXT NULL,
 submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, reviewed_at DATETIME NULL,
 FOREIGN KEY(publication_id) REFERENCES publications(id),
 FOREIGN KEY(author_id) REFERENCES users(id), FOREIGN KEY(reviewer_id) REFERENCES users(id),
 INDEX revision_publication(publication_id,id), CHECK(status IN ('pending','approved','rejected'))
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS revision_images (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, revision_id INT UNSIGNED NOT NULL,
 filename VARCHAR(70) NOT NULL, mime VARCHAR(30) NOT NULL, slot TINYINT NOT NULL,
 caption VARCHAR(100) NOT NULL DEFAULT '', FOREIGN KEY(revision_id) REFERENCES publication_revisions(id),
 UNIQUE(revision_id,slot), INDEX revision_filename(filename), CHECK(slot BETWEEN 1 AND 3)
) ENGINE=InnoDB;
