PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS organizations (
 id INTEGER PRIMARY KEY, name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS portals (
 id INTEGER PRIMARY KEY, organization_id INTEGER NOT NULL REFERENCES organizations(id),
 slug TEXT NOT NULL UNIQUE, name TEXT NOT NULL, capacity INTEGER NOT NULL CHECK(capacity IN (10,50,100,200))
);
CREATE TABLE IF NOT EXISTS advertisers (
 id INTEGER PRIMARY KEY, name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS users (
 id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE COLLATE NOCASE,
 password_hash TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('master','manager','advertiser')),
 advertiser_id INTEGER REFERENCES advertisers(id)
);
CREATE TABLE IF NOT EXISTS memberships (
 user_id INTEGER NOT NULL REFERENCES users(id), portal_id INTEGER NOT NULL REFERENCES portals(id),
 PRIMARY KEY(user_id,portal_id)
);
CREATE TABLE IF NOT EXISTS publications (
 id INTEGER PRIMARY KEY, portal_id INTEGER NOT NULL REFERENCES portals(id),
 advertiser_id INTEGER NOT NULL REFERENCES advertisers(id), name TEXT NOT NULL,
 category TEXT NOT NULL, service TEXT NOT NULL, description TEXT NOT NULL,
 tags TEXT NOT NULL DEFAULT '', color TEXT NOT NULL DEFAULT '#d6dfce',
 accent TEXT NOT NULL DEFAULT '#64846c', type TEXT NOT NULL DEFAULT 'home',
 mode TEXT NOT NULL, hours TEXT NOT NULL, art TEXT NOT NULL DEFAULT '',
 services TEXT NOT NULL, status TEXT NOT NULL CHECK(status IN ('pending','published','suspended')),
 updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE(portal_id,advertiser_id)
);
CREATE INDEX IF NOT EXISTS publication_visibility ON publications(portal_id,status);
CREATE TABLE IF NOT EXISTS audit_logs (
 id INTEGER PRIMARY KEY, user_id INTEGER REFERENCES users(id), portal_id INTEGER REFERENCES portals(id),
 action TEXT NOT NULL, publication_id INTEGER, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS login_attempts (
 id INTEGER PRIMARY KEY, fingerprint TEXT NOT NULL, attempted_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS attempts_lookup ON login_attempts(fingerprint,attempted_at);
