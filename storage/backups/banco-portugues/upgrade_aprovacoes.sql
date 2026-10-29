-- Atualização não destrutiva. Execute também php spark portal:install para criar o admin local.
USE portal_bairro;
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
