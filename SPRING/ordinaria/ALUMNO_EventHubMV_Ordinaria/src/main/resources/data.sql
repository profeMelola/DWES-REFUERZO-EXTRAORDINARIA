-- ---------- ROLES ----------
INSERT INTO roles (name, description) VALUES
                                          ('ROLE_USER', 'Usuario estándar'),
                                          ('ROLE_ADMIN', 'Administrador');

-- ---------- USERS ----------
-- Passwords (BCrypt):
-- user / user123
-- admin / admin123

INSERT INTO users (username, password, full_name, email, enabled, role_id)
VALUES
    (
        'user@demo',
        '$2b$10$O68skboX8WHXiDUO8OCxNOhwm6b0HTHEErY3jO1Q/YKFrK9o0pHSG',
        'User Demo',
        'user@demo.local',
        TRUE,
        (SELECT id FROM roles WHERE name = 'ROLE_USER')
    ),
    (
        'admin@local',
        '$2b$10$rugh0GZ46VyAeBOOy8rdjO/FmoPvpAu8SVDDJ2vjcbFsEeokTVNs.',
        'Admin Demo',
        'admin@demo.local',
        TRUE,
        (SELECT id FROM roles WHERE name = 'ROLE_ADMIN')
    );

-- ---------- PURCHASES ----------
INSERT INTO purchases (created_at, username, total_amount)
VALUES
    (
        TIMESTAMP '2026-01-10 18:15:00',
        'user',
        178.00
    ),
    (
        TIMESTAMP '2026-01-11 11:05:00',
        'user',
        49.00
    );

-- ---------- PURCHASE_LINES ----------
-- Compra 1 (178.00)
INSERT INTO purchase_lines (
    purchase_id,
    ticket_type_code,
    ticket_name_snapshot,
    unit_price_snapshot,
    qty,
    line_total
)
VALUES
    (
        (SELECT id FROM purchases WHERE username = 'user' AND total_amount = 178.00),
        'TT_EVT_MAD_TECH_2026_VIP',
        'VIP',
        129.00,
        1,
        129.00
    ),
    (
        (SELECT id FROM purchases WHERE username = 'user' AND total_amount = 178.00),
        'TT_EVT_MAD_TECH_2026_GEN',
        'GENERAL',
        49.00,
        1,
        49.00
    );

-- Compra 2 (49.00)
INSERT INTO purchase_lines (
    purchase_id,
    ticket_type_code,
    ticket_name_snapshot,
    unit_price_snapshot,
    qty,
    line_total
)
VALUES
    (
        (SELECT id FROM purchases WHERE username = 'user' AND total_amount = 49.00),
        'TT_EVT_MAD_TECH_2026_GEN',
        'GENERAL',
        49.00,
        1,
        49.00
    );
