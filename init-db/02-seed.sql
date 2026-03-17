-- Seed data for Passhub Local Development

-- 1. Create a test agency
INSERT INTO tbe_agencia (nome, cnpj, cor, chave_pix, banco, nome_recebedor_pix)
VALUES ('Agência Teste Local', '00000000000191', '#3b82f6', 'teste@passhub.com.br', 'Banco Inter', 'Passhub Dev');

INSERT INTO tbe_agencia (nome, cnpj, cor, chave_pix, banco, nome_recebedor_pix)
VALUES ('Agência Teste Local 2', '00000000000191', '#3b82f6', 'teste2@passhub.com.br', 'Banco Inter', 'Passhub Dev');

INSERT INTO tbe_agencia (nome, cnpj, cor, chave_pix, banco, nome_recebedor_pix)
VALUES ('Agência Teste Local 3', '00000000000191', '#3b82f6', 'teste3@passhub.com.br', 'Banco Inter', 'Passhub Dev');

-- 2. Create test users
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase) VALUES (1, 'Esdras', 'esdras.carvalho@passabot.com', 'local-dev-esdras') ON CONFLICT DO NOTHING;
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase) VALUES (2, 'Fernadin', 'fernandin@passabot.teste.com', 'local-dev-fernadin') ON CONFLICT DO NOTHING;
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase) VALUES (3, 'firebase', 'wesleyalvescav@gmail.com', 'local-dev-wesley') ON CONFLICT DO NOTHING;
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase) VALUES (4, 'Mateus Moreira', 'mateusmoreirammp052@gmail.com', 'local-dev-mateus') ON CONFLICT DO NOTHING;
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase) VALUES (5, 'Teste Passhub', 'teste@passhub.com.br', 'local-dev-teste') ON CONFLICT DO NOTHING;
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase) VALUES (6, 'João Barreto', 'joao.barreto@passabot.com', 'local-dev-joao') ON CONFLICT DO NOTHING;

-- Fill gap until ID 29
DO $$
BEGIN
    FOR i IN 7..29 LOOP
        INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase)
        VALUES (i, 'Dummy User ' || i, 'dummy' || i || '@test.com', 'dummy-firebase-' || i)
        ON CONFLICT (id_usuario) DO NOTHING;
    END LOOP;
END $$;

-- User 30: Passabot
INSERT INTO tbe_usuario (id_usuario, nome, email, id_firebase, first_login)
VALUES (30, 'Passabot', 'fernando.santos@passabot.com', 'eKie0XDMi2Sg1egIiWOV97lXnoe2', '2025-12-12 13:32:29.712')
ON CONFLICT (id_usuario) DO NOTHING;

-- Reset sequence to ensure future inserts work correctly
SELECT setval('tbe_usuario_id_usuario_seq', GREATEST((SELECT MAX(id_usuario) FROM tbe_usuario), 30));


-- 3. Link users to agencies (all linked to Agência Teste Local)
INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT u.id_usuario, a.id_agencia, TRUE
FROM tbe_usuario u, tbe_agencia a
WHERE u.email = 'esdras.carvalho@passabot.com' AND a.nome = 'Agência Teste Local';

INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT u.id_usuario, a.id_agencia, TRUE
FROM tbe_usuario u, tbe_agencia a
WHERE u.email = 'fernandin@passabot.teste.com' AND a.nome = 'Agência Teste Local';

INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT u.id_usuario, a.id_agencia, TRUE
FROM tbe_usuario u, tbe_agencia a
WHERE u.email = 'wesleyalvescav@gmail.com' AND a.nome = 'Agência Teste Local';

INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT u.id_usuario, a.id_agencia, TRUE
FROM tbe_usuario u, tbe_agencia a
WHERE u.email = 'mateusmoreirammp052@gmail.com' AND a.nome = 'Agência Teste Local';

INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT u.id_usuario, a.id_agencia, TRUE
FROM tbe_usuario u, tbe_agencia a
WHERE u.email = 'teste@passhub.com.br' AND a.nome = 'Agência Teste Local';

INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT u.id_usuario, a.id_agencia, TRUE
FROM tbe_usuario u, tbe_agencia a
WHERE u.email = 'joao.barreto@passabot.com' AND a.nome = 'Agência Teste Local';

-- 4. Add common permissions
INSERT INTO tbe_permissao (nome_permissao) VALUES ('ADMIN'), ('EMISSOR'), ('FINANCEIRO'), ('AGENCIA_ADMIN') ON CONFLICT DO NOTHING;

-- 5. Link users to permissions
-- Admins
INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.email = 'esdras.carvalho@passabot.com' AND p.nome_permissao = 'ADMIN';

INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.email = 'fernandin@passabot.teste.com' AND p.nome_permissao = 'ADMIN';

INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.email = 'wesleyalvescav@gmail.com' AND p.nome_permissao = 'ADMIN';

INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.email = 'mateusmoreirammp052@gmail.com' AND p.nome_permissao = 'ADMIN';

-- Teste Passhub is Agente (EMISSOR), not Admin
INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.email = 'teste@passhub.com.br' AND p.nome_permissao = 'EMISSOR';

INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.email = 'joao.barreto@passabot.com' AND p.nome_permissao = 'ADMIN'
ON CONFLICT DO NOTHING;

-- Passabot (AGENCIA_ADMIN)
INSERT INTO tbe_usuario_permissao (id_usuario, id_permissao)
SELECT u.id_usuario, p.id_permissao
FROM tbe_usuario u, tbe_permissao p
WHERE u.id_usuario = 30 AND p.nome_permissao = 'AGENCIA_ADMIN'
ON CONFLICT DO NOTHING;

-- Link Passabot to Agência Teste Local
INSERT INTO tbe_usuario_agencia (id_usuario, id_agencia, is_default)
SELECT 30, a.id_agencia, TRUE
FROM tbe_agencia a
WHERE a.nome = 'Agência Teste Local'
ON CONFLICT DO NOTHING;
