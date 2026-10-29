-- Acesso inicial local: usuário admin, senha 1234. Não altera contas existentes.
USE portal_bairro;
INSERT INTO usuarios(nome,email,senha_hash,perfil,ativo)
SELECT 'Administrador','admin@portal.local','$2y$10$xflGQJlUsDQu4Id5j/2KNe63YZ2N04NEnRNOrPJaAvIkSwKDJNhii','master',1
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE email='admin@portal.local');
