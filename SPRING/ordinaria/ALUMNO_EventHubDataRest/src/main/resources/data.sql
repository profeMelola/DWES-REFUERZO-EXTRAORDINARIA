-- LOCATIONS
INSERT INTO locations (id, code, name, city, capacity, active) VALUES
                                                                   (1, 'MAD_AUDITORIUM', 'Auditorio Central Madrid', 'Madrid', 1800, TRUE),
                                                                   (2, 'MAD_TECH_HALL', 'Tech Hall Gran Via', 'Madrid', 600, TRUE),
                                                                   (3, 'BCN_FORUM', 'Forum Barcelona', 'Barcelona', 2500, TRUE),
                                                                   (4, 'BCN_STAGE', 'Stage Poblenou', 'Barcelona', 900, TRUE),
                                                                   (5, 'VAL_CONGRESS', 'Palacio Congresos Valencia', 'Valencia', 1400, TRUE),
                                                                   (6, 'SEV_ARENA', 'Arena Sevilla', 'Sevilla', 12000, TRUE),
                                                                   (7, 'BIL_ARTS', 'Bilbao Arts Center', 'Bilbao', 700, FALSE);

-- EVENTS (mezcla pasado/futuro y activos/inactivos)
INSERT INTO events (id, code, title, description, category, start_date_time, active, location_id) VALUES
                                                                                                      (1, 'EVT_MAD_TECH_2026', 'Spring & APIs Conference', 'Conferencia técnica sobre APIs y buenas prácticas.', 'TECH', '2026-02-14T10:00:00', TRUE, 2),
                                                                                                      (2, 'EVT_MAD_MUSIC_JAZZ', 'Madrid Jazz Night', 'Noche de jazz con artistas invitados.', 'MUSIC', '2026-03-07T21:00:00', TRUE, 1),
                                                                                                      (3, 'EVT_BCN_SPORTS_RUN', 'Barcelona Urban Run', 'Carrera popular urbana de 10K.', 'SPORTS', '2026-04-12T09:00:00', TRUE, 3),
                                                                                                      (4, 'EVT_VAL_EDU_LECT', 'Learning Strategies Workshop', 'Taller de técnicas de estudio y aprendizaje.', 'EDUCATION', '2026-02-22T17:30:00', TRUE, 5),
                                                                                                      (5, 'EVT_SEV_SPORTS_FINAL', 'Sevilla Cup Final', 'Final regional con aforo ampliado.', 'SPORTS', '2026-05-30T19:00:00', TRUE, 6),
                                                                                                      (6, 'EVT_BCN_THEATRE_CLASSIC', 'Classic Theatre Evening', 'Obra clásica en versión moderna.', 'THEATRE', '2026-01-25T20:00:00', TRUE, 4),
                                                                                                      (7, 'EVT_MAD_TECH_2025', 'DevOps Meetup 2025', 'Evento pasado para probar filtros por fecha.', 'TECH', '2025-10-10T18:00:00', FALSE, 2),
                                                                                                      (8, 'EVT_BIL_MUSIC_INDIE', 'Indie Sessions Bilbao', 'Evento inactivo en sede inactiva.', 'MUSIC', '2026-06-05T22:00:00', FALSE, 7),
                                                                                                      (9, 'EVT_BCN_TECH_AI', 'AI for Developers', 'IA aplicada a desarrollo, casos prácticos.', 'TECH', '2026-03-20T10:30:00', TRUE, 3),
                                                                                                      (10, 'EVT_VAL_MUSIC_POP', 'Valencia Pop Live', 'Concierto pop con invitados.', 'MUSIC', '2026-04-05T21:30:00', TRUE, 5),
                                                                                                      (11, 'EVT_MAD_EDU_BOOTCAMP', 'Study Bootcamp', 'Jornada intensiva de técnicas de examen.', 'EDUCATION', '2026-02-01T09:30:00', TRUE, 1),
                                                                                                      (12, 'EVT_BCN_THEATRE_IMPRO', 'Impro Night BCN', 'Teatro de improvisación.', 'THEATRE', '2026-02-08T20:30:00', TRUE, 4);

-- TICKET TYPES (3 por evento; quotas distintas; ventanas de venta variadas)

-- Evento 1
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (1, 'TT_EVT_MAD_TECH_2026_GEN', 'GENERAL', 49.00, 400, '2025-12-01T00:00:00', '2026-02-14T10:00:00', 1),
                                                                                                 (2, 'TT_EVT_MAD_TECH_2026_VIP', 'VIP', 129.00, 50, '2025-12-01T00:00:00', '2026-02-14T10:00:00', 1),
                                                                                                 (3, 'TT_EVT_MAD_TECH_2026_STU', 'STUDENT', 25.00, 150, '2025-12-15T00:00:00', '2026-02-13T23:59:00', 1);

-- Evento 2
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (4, 'TT_EVT_MAD_MUSIC_JAZZ_GEN', 'GENERAL', 35.00, 1200, '2026-01-01T00:00:00', '2026-03-07T21:00:00', 2),
                                                                                                 (5, 'TT_EVT_MAD_MUSIC_JAZZ_VIP', 'VIP', 75.00, 120, '2026-01-01T00:00:00', '2026-03-07T21:00:00', 2),
                                                                                                 (6, 'TT_EVT_MAD_MUSIC_JAZZ_STU', 'STUDENT', 20.00, 200, '2026-01-10T00:00:00', '2026-03-06T23:59:00', 2);

-- Evento 3
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (7, 'TT_EVT_BCN_SPORTS_RUN_GEN', 'GENERAL', 18.00, 2200, '2026-01-05T00:00:00', '2026-04-11T23:59:00', 3),
                                                                                                 (8, 'TT_EVT_BCN_SPORTS_RUN_VIP', 'VIP', 40.00, 150, '2026-01-05T00:00:00', '2026-04-11T23:59:00', 3),
                                                                                                 (9, 'TT_EVT_BCN_SPORTS_RUN_STU', 'STUDENT', 12.00, 300, '2026-01-20T00:00:00', '2026-04-10T23:59:00', 3);

-- Evento 4
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (10, 'TT_EVT_VAL_EDU_LECT_GEN', 'GENERAL', 15.00, 900, '2026-01-10T00:00:00', '2026-02-22T17:30:00', 4),
                                                                                                 (11, 'TT_EVT_VAL_EDU_LECT_VIP', 'VIP', 30.00, 80, '2026-01-10T00:00:00', '2026-02-22T17:30:00', 4),
                                                                                                 (12, 'TT_EVT_VAL_EDU_LECT_STU', 'STUDENT', 8.00, 200, '2026-01-15T00:00:00', '2026-02-21T23:59:00', 4);

-- Evento 5
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (13, 'TT_EVT_SEV_SPORTS_FINAL_GEN', 'GENERAL', 25.00, 10000, '2026-02-01T00:00:00', '2026-05-30T19:00:00', 5),
                                                                                                 (14, 'TT_EVT_SEV_SPORTS_FINAL_VIP', 'VIP', 120.00, 500, '2026-02-01T00:00:00', '2026-05-30T19:00:00', 5),
                                                                                                 (15, 'TT_EVT_SEV_SPORTS_FINAL_STU', 'STUDENT', 15.00, 800, '2026-02-10T00:00:00', '2026-05-29T23:59:00', 5);

-- Evento 6
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (16, 'TT_EVT_BCN_THEATRE_CLASSIC_GEN', 'GENERAL', 28.00, 700, '2025-12-20T00:00:00', '2026-01-25T20:00:00', 6),
                                                                                                 (17, 'TT_EVT_BCN_THEATRE_CLASSIC_VIP', 'VIP', 55.00, 90, '2025-12-20T00:00:00', '2026-01-25T20:00:00', 6),
                                                                                                 (18, 'TT_EVT_BCN_THEATRE_CLASSIC_STU', 'STUDENT', 16.00, 150, '2026-01-02T00:00:00', '2026-01-24T23:59:00', 6);

-- Evento 9 (AI for Developers)
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (19, 'TT_EVT_BCN_TECH_AI_GEN', 'GENERAL', 59.00, 800, '2026-01-05T00:00:00', '2026-03-20T10:30:00', 9),
                                                                                                 (20, 'TT_EVT_BCN_TECH_AI_VIP', 'VIP', 149.00, 60, '2026-01-05T00:00:00', '2026-03-20T10:30:00', 9),
                                                                                                 (21, 'TT_EVT_BCN_TECH_AI_STU', 'STUDENT', 29.00, 180, '2026-01-20T00:00:00', '2026-03-19T23:59:00', 9);

-- Evento 7 (venta ya cerrada)
INSERT INTO ticket_types (id, code, name, base_price, quota, sale_start, sale_end, event_id) VALUES
                                                                                                 (22, 'TT_EVT_MAD_TECH_2025_GEN', 'GENERAL', 10.00, 300, '2025-08-01T00:00:00', '2025-10-10T18:00:00', 7),
                                                                                                 (23, 'TT_EVT_MAD_TECH_2025_VIP', 'VIP', 25.00, 30, '2025-08-01T00:00:00', '2025-10-10T18:00:00', 7),
                                                                                                 (24, 'TT_EVT_MAD_TECH_2025_STU', 'STUDENT', 5.00, 80, '2025-08-15T00:00:00', '2025-10-09T23:59:00', 7);
