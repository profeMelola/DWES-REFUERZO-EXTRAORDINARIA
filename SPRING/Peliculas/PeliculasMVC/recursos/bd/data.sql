-- ─────────────────────────────────────────────────────────────────────────
-- ROLES
-- El nombre lleva prefijo ROLE_ porque así lo espera Spring Security
-- en AppUser.getAuthorities() → new SimpleGrantedAuthority(role.getName())
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO roles (name, description) VALUES
                                          ('ROLE_ADMIN', 'Administrador con acceso total'),
                                          ('ROLE_USER',  'Usuario estándar con acceso al catálogo');

-- ─────────────────────────────────────────────────────────────────────────
-- USUARIOS
-- role_id 1 = ROLE_ADMIN
-- role_id 2 = ROLE_USER
--
--  username  │ password   │ rol
-- ───────────┼────────────┼───────────
--  admin     │ admin123   │ ROLE_ADMIN
--  pepe      │ pepe123    │ ROLE_USER
--  ana       │ ana123     │ ROLE_USER
--  test      │ test123    │ ROLE_USER
--  user      │ user123    │ ROLE_USER  (desactivado)
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO app_users (username, password, full_name, email, enabled, role_id) VALUES
                                                                                   (
                                                                                       'admin',
                                                                                       '$2b$10$fPp5AOX/fLpOlQ9JBEe3AeyAQgP/bpVwTTR62WzaaoCXyEvlDNvGC',
                                                                                       'Administrador',
                                                                                       'admin@cineapp.es',
                                                                                       true,
                                                                                       1
                                                                                   ),
                                                                                   (
                                                                                       'pepe',
                                                                                       '$2b$10$Rm57my.7oC78IDOUMnm1NOSgQrIq4CVrI/1m/9O78MUwIwE/mqvb6',
                                                                                       'Pepe García',
                                                                                       'pepe@cineapp.es',
                                                                                       true,
                                                                                       2
                                                                                   ),
                                                                                   (
                                                                                       'ana',
                                                                                       '$2b$10$AKS2jPLdMXka5cjRNsEGp.RIQh1SZa6uCtonjbHg4Wo291HI33hle',
                                                                                       'Ana Martínez',
                                                                                       'ana@cineapp.es',
                                                                                       true,
                                                                                       2
                                                                                   ),
                                                                                   (
                                                                                       'test',
                                                                                       '$2b$10$ziEO4TCMV3PBgU83c/Eqt.6apSuzF7uTANyKpTXBKrqe7gDrUd2OG',
                                                                                       'Usuario Test',
                                                                                       'test@cineapp.es',
                                                                                       true,
                                                                                       2
                                                                                   ),
                                                                                   (
                                                                                       'user',
                                                                                       '$2b$10$rI692j/thWUdw0IcZ6mAIeYZtLBE.6NhI.DBw/fsabz77gh0BrkNS',
                                                                                       'Usuario Desactivado',
                                                                                       'user@cineapp.es',
                                                                                       false,
                                                                                       2
                                                                                   );