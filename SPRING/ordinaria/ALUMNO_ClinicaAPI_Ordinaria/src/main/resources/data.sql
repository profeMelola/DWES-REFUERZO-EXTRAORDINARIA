-- Roles
INSERT INTO roles (name) VALUES
                             ('ROLE_ADMIN'),
                             ('ROLE_STAFF'),
                             ('ROLE_BILLING');

-- Usuarios (BCrypt)
-- admin -> admin
INSERT INTO app_users (username, password, enabled)
VALUES ('admin', '$2b$10$0rmFjxwapwDGRPzYn6l.cODL.VTsvQWiiPQNt.Tur56tLeGKtYqyC', true);

-- staff -> staff
INSERT INTO app_users (username, password, enabled)
VALUES ('staff', '$2b$10$iyWyRBiPQ8VU4cAez9xgBO4NV55fNSr7QCureJXEW34cYmrpVD7gi', true);

-- billing -> billing
INSERT INTO app_users (username, password, enabled)
VALUES ('billing', '$2b$10$sCj.GyW0T.VARoUscDSnMuqa/4XqW9YB/62JrcNQ5SkVrzYWeggc6', true);

-- Asignación de roles (tabla intermedia) SIN asumir IDs
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM app_users u, roles r
WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN';

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM app_users u, roles r
WHERE u.username = 'staff' AND r.name = 'ROLE_STAFF';

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM app_users u, roles r
WHERE u.username = 'billing' AND r.name = 'ROLE_BILLING';


-- =========================================
-- DATASET
-- Enfoque: Patients + Appointments + Reports
-- =========================================

-- -------------------------
-- PATIENTS (30)
-- -------------------------
INSERT INTO patients (dni, full_name, email, phone, date_of_birth, active) VALUES
                                                                               ('111A','Ana García','ana@demo.com','600111111','1990-01-10', true),
                                                                               ('222B','Luis Pérez','luis@demo.com','600222222','1985-07-21', true),
                                                                               ('333C','María Sánchez','maria@demo.com','600333333','1992-03-05', true),
                                                                               ('444D','Carlos Gómez','carlos@demo.com','600444444','1980-11-12', true),
                                                                               ('555E','Lucía Fernández','lucia@demo.com','600555555','1995-06-18', true),
                                                                               ('666F','Javier Martín','javier@demo.com','600666666','1978-09-30', true),
                                                                               ('777G','Paula Romero','paula@demo.com','600777777','1989-12-02', true),
                                                                               ('888H','Sergio Navarro','sergio@demo.com','600888888','1991-04-27', true),
                                                                               ('999I','Elena Ortega','elena@demo.com','600999999','1987-08-14', true),
                                                                               ('101J','David Torres','david@demo.com','601010101','1993-02-09', true),
                                                                               ('102K','Carmen Molina','carmen@demo.com','601020202','1975-05-23', true),
                                                                               ('103L','Alberto Ruiz','alberto@demo.com','601030303','1982-10-07', true),
                                                                               ('104M','Irene Delgado','irene@demo.com','601040404','1997-01-19', true),
                                                                               ('105N','Raúl Castillo','raul@demo.com','601050505','1984-07-28', true),
                                                                               ('106O','Sara Iglesias','sara@demo.com','601060606','1990-09-11', true),
                                                                               ('107P','Hugo Vidal','hugo@demo.com','601070707','1988-12-25', true),
                                                                               ('108Q','Nerea Campos','nerea@demo.com','601080808','1994-04-03', true),
                                                                               ('109R','Óscar Herrera','oscar@demo.com','601090909','1979-06-16', true),
                                                                               ('110S','Marta León','marta.leon@demo.com','602000001','1996-08-08', true),
                                                                               ('111T','Iván Flores','ivan@demo.com','602000002','1983-03-31', true),
                                                                               ('112U','Andrea Reyes','andrea@demo.com','602000003','1991-11-05', true),
                                                                               ('113V','Pedro Ramos','pedro@demo.com','602000004','1977-02-20', true),
                                                                               ('114W','Noelia Gil','noelia@demo.com','602000005','1986-09-09', true),
                                                                               ('115X','Daniel Suárez','daniel@demo.com','602000006','1998-05-14', true),
                                                                               ('116Y','Patricia Núñez','patri@demo.com','602000007','1992-07-01', true),
                                                                               ('117Z','Adrián Cabrera','adrian@demo.com','602000008','1981-01-26', true),
                                                                               ('118AA','Claudia Peña','claudia@demo.com','602000009','1990-10-10', true),
                                                                               ('119AB','Fernando Mora','fernando@demo.com','602000010','1976-12-12', true),
                                                                               ('120AC','Beatriz Soto','bea@demo.com','602000011','1989-02-02', true),
                                                                               ('121AD','Álvaro Prieto','alvaro@demo.com','602000012','1993-06-06', false); -- inactivo para filtros

-- -------------------------
-- DOCTORS (6)
-- -------------------------
INSERT INTO doctors (license_number, full_name, email, active) VALUES
                                                                   ('LIC-100','Dra. Marta López','marta@demo.com', true),
                                                                   ('LIC-200','Dr. Juan Ruiz','juan@demo.com', true),
                                                                   ('LIC-300','Dra. Sofía Vega','sofia@demo.com', true),
                                                                   ('LIC-400','Dr. Pablo Santos','pablo@demo.com', true),
                                                                   ('LIC-500','Dra. Irene Cano','irene.cano@demo.com', true),
                                                                   ('LIC-600','Dr. Marcos Díaz','marcos@demo.com', false); -- inactivo

-- -------------------------
-- MEDICAL SERVICES (6)
-- -------------------------
INSERT INTO medical_services (code, name, base_price, active) VALUES
                                                                  ('CONS-GEN','Consulta general', 50.00, true),
                                                                  ('DERM-REV','Revisión dermatológica', 80.00, true),
                                                                  ('CARD-ECG','ECG / Cardiología', 120.00, true),
                                                                  ('PED-CONT','Control pediatría', 45.00, true),
                                                                  ('VAC-FLU','Vacuna gripe', 25.00, true),
                                                                  ('NUTRI-PLAN','Plan nutrición', 60.00, true);

-- -------------------------
-- DOCTOR SPECIALTIES (1-2 por doctor para dataset rico)
-- Asumimos doctor_id en orden: 1..6
-- -------------------------
INSERT INTO doctor_specialties (doctor_id, specialty, level, active, since_date, consultation_fee_override) VALUES
                                                                                                                (1,'DERMATOLOGY','SENIOR', true, '2020-01-01', null),
                                                                                                                (1,'GENERAL_MED','CONSULTANT', true, '2017-05-01', 55.00),
                                                                                                                (2,'GENERAL_MED','CONSULTANT', true, '2018-01-01', null),
                                                                                                                (3,'CARDIOLOGY','SENIOR', true, '2016-09-15', 130.00),
                                                                                                                (3,'GENERAL_MED','JUNIOR', true, '2022-02-01', null),
                                                                                                                (4,'PEDIATRICS','CONSULTANT', true, '2019-03-10', null),
                                                                                                                (5,'NUTRITION','SENIOR', true, '2015-06-20', 70.00),
                                                                                                                (6,'GENERAL_MED','JUNIOR', false, '2023-01-01', null);

-- -------------------------
-- APPOINTMENTS (80 aprox.)
-- Enfoque: enero 2026, varios estados y horarios
-- Asumimos patient_id: 1..30, doctor_id: 1..6
-- -------------------------
INSERT INTO appointments (patient_id, doctor_id, start_at, end_at, minutes, status, reason, cancellation_reason) VALUES
-- Semana 1
(1,2,'2026-01-05T09:00:00','2026-01-05T09:30:00',30,'COMPLETED','Revisión general', null),
(2,1,'2026-01-05T10:00:00','2026-01-05T10:30:00',30,'CANCELLED','Dermatitis','Paciente no puede asistir'),
(3,2,'2026-01-05T11:00:00','2026-01-05T11:30:00',30,'SCHEDULED','Chequeo', null),
(4,3,'2026-01-06T09:00:00','2026-01-06T09:45:00',45,'COMPLETED','Palpitaciones', null),
(5,4,'2026-01-06T10:00:00','2026-01-06T10:30:00',30,'NO_SHOW','Control pediatría', null),
(6,5,'2026-01-06T11:00:00','2026-01-06T11:30:00',30,'COMPLETED','Nutrición', null),

-- Semana 2
(7,2,'2026-01-12T09:00:00','2026-01-12T09:30:00',30,'COMPLETED','Revisión', null),
(8,1,'2026-01-12T10:00:00','2026-01-12T10:30:00',30,'COMPLETED','Revisión piel', null),
(9,3,'2026-01-12T11:00:00','2026-01-12T11:30:00',30,'SCHEDULED','ECG', null),
(10,4,'2026-01-13T09:00:00','2026-01-13T09:30:00',30,'CANCELLED','Fiebre niño','Reprograma'),
(11,5,'2026-01-13T10:00:00','2026-01-13T10:30:00',30,'COMPLETED','Dieta', null),
(12,2,'2026-01-13T11:00:00','2026-01-13T11:30:00',30,'NO_SHOW','Chequeo', null),

-- Semana 3 (más densidad para paginar)
(13,2,'2026-01-19T09:00:00','2026-01-19T09:30:00',30,'COMPLETED','Consulta general', null),
(14,2,'2026-01-19T09:30:00','2026-01-19T10:00:00',30,'COMPLETED','Consulta general', null),
(15,2,'2026-01-19T10:00:00','2026-01-19T10:30:00',30,'SCHEDULED','Chequeo', null),
(16,1,'2026-01-19T11:00:00','2026-01-19T11:30:00',30,'COMPLETED','Acné', null),
(17,1,'2026-01-20T09:00:00','2026-01-20T09:30:00',30,'CANCELLED','Lunar','No puede asistir'),
(18,3,'2026-01-20T10:00:00','2026-01-20T10:45:00',45,'COMPLETED','Dolor torácico', null),
(19,3,'2026-01-20T11:00:00','2026-01-20T11:30:00',30,'SCHEDULED','ECG', null),
(20,4,'2026-01-21T09:00:00','2026-01-21T09:30:00',30,'COMPLETED','Control pediatría', null),
(21,4,'2026-01-21T10:00:00','2026-01-21T10:30:00',30,'NO_SHOW','Vacuna', null),
(22,5,'2026-01-21T11:00:00','2026-01-21T11:30:00',30,'COMPLETED','Nutrición', null),

-- Semana 4 (más variedad + pacientes recurrentes)
(1,2,'2026-01-26T09:00:00','2026-01-26T09:30:00',30,'COMPLETED','Seguimiento', null),
(1,2,'2026-01-27T09:00:00','2026-01-27T09:30:00',30,'COMPLETED','Revisión general', null),
(1,2,'2026-01-28T09:00:00','2026-01-28T09:30:00',30,'CANCELLED','Revisión','Trabajo'),
(2,1,'2026-01-26T10:00:00','2026-01-26T10:30:00',30,'COMPLETED','Dermatitis', null),
(2,1,'2026-01-28T10:00:00','2026-01-28T10:30:00',30,'SCHEDULED','Control piel', null),
(3,3,'2026-01-26T11:00:00','2026-01-26T11:45:00',45,'COMPLETED','ECG', null),
(4,4,'2026-01-27T10:00:00','2026-01-27T10:30:00',30,'COMPLETED','Pediatría', null),
(5,5,'2026-01-28T11:00:00','2026-01-28T11:30:00',30,'COMPLETED','Dieta', null),
(6,2,'2026-01-29T09:00:00','2026-01-29T09:30:00',30,'SCHEDULED','Chequeo', null),
(7,2,'2026-01-29T10:00:00','2026-01-29T10:30:00',30,'NO_SHOW','Chequeo', null),

-- Lote extra para paginación (citas rápidas en distintos días/hora)
(8,2,'2026-01-07T09:00:00','2026-01-07T09:30:00',30,'COMPLETED','Consulta general', null),
(9,2,'2026-01-07T10:00:00','2026-01-07T10:30:00',30,'COMPLETED','Consulta general', null),
(10,2,'2026-01-07T11:00:00','2026-01-07T11:30:00',30,'CANCELLED','Consulta general','Reprograma'),
(11,2,'2026-01-08T09:00:00','2026-01-08T09:30:00',30,'COMPLETED','Consulta general', null),
(12,2,'2026-01-08T10:00:00','2026-01-08T10:30:00',30,'SCHEDULED','Consulta general', null),
(13,2,'2026-01-08T11:00:00','2026-01-08T11:30:00',30,'NO_SHOW','Consulta general', null),
(14,2,'2026-01-09T09:00:00','2026-01-09T09:30:00',30,'COMPLETED','Consulta general', null),
(15,2,'2026-01-09T10:00:00','2026-01-09T10:30:00',30,'COMPLETED','Consulta general', null),
(16,2,'2026-01-09T11:00:00','2026-01-09T11:30:00',30,'SCHEDULED','Consulta general', null),

(17,1,'2026-01-14T09:00:00','2026-01-14T09:30:00',30,'COMPLETED','Piel', null),
(18,1,'2026-01-14T10:00:00','2026-01-14T10:30:00',30,'COMPLETED','Piel', null),
(19,1,'2026-01-14T11:00:00','2026-01-14T11:30:00',30,'CANCELLED','Piel','Viaje'),
(20,3,'2026-01-15T09:00:00','2026-01-15T09:45:00',45,'COMPLETED','Cardio', null),
(21,3,'2026-01-15T10:00:00','2026-01-15T10:45:00',45,'SCHEDULED','Cardio', null),
(22,3,'2026-01-15T11:00:00','2026-01-15T11:45:00',45,'NO_SHOW','Cardio', null),

(23,4,'2026-01-16T09:00:00','2026-01-16T09:30:00',30,'COMPLETED','Pediatría', null),
(24,4,'2026-01-16T10:00:00','2026-01-16T10:30:00',30,'COMPLETED','Pediatría', null),
(25,4,'2026-01-16T11:00:00','2026-01-16T11:30:00',30,'CANCELLED','Pediatría','Niño mejoró'),

(26,5,'2026-01-17T09:00:00','2026-01-17T09:30:00',30,'COMPLETED','Nutrición', null),
(27,5,'2026-01-17T10:00:00','2026-01-17T10:30:00',30,'SCHEDULED','Nutrición', null),
(28,5,'2026-01-17T11:00:00','2026-01-17T11:30:00',30,'NO_SHOW','Nutrición', null),

(29,2,'2026-01-30T09:00:00','2026-01-30T09:30:00',30,'COMPLETED','Consulta general', null),
(30,2,'2026-01-30T10:00:00','2026-01-30T10:30:00',30,'SCHEDULED','Consulta general', null);

-- -------------------------
-- INVOICES (ejemplos para reportes y validaciones)
-- Solo para citas COMPLETED (buscando por start_at, así no dependes de ids exactos)
-- -------------------------
INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 50.00, 10.50, 60.50, '2026-01-05T12:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-05T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 120.00, 25.20, 145.20, '2026-01-06T13:00:00', '2026-01-06T13:10:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-06T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 80.00, 16.80, 96.80, '2026-01-12T12:30:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-12T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 60.00, 12.60, 72.60, '2026-01-13T12:00:00', '2026-01-13T12:05:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-13T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 50.00, 10.50, 60.50, '2026-01-19T12:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-19T09:00:00';

-- -------------------------
-- INVOICE LINES (1 linea por factura, usando appointment_id para localizar invoice)
-- Asumimos VAT_21 y descuentos NONE como en tu ejemplo
-- -------------------------
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 50.00, 'VAT_21', 'NONE', null, 60.50
FROM invoices i
         JOIN appointments a ON a.id = i.appointment_id
         JOIN medical_services s ON s.code = 'CONS-GEN'
WHERE a.start_at = '2026-01-05T09:00:00';

INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 120.00, 'VAT_21', 'NONE', null, 145.20
FROM invoices i
         JOIN appointments a ON a.id = i.appointment_id
         JOIN medical_services s ON s.code = 'CARD-ECG'
WHERE a.start_at = '2026-01-06T09:00:00';

INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 80.00, 'VAT_21', 'NONE', null, 96.80
FROM invoices i
         JOIN appointments a ON a.id = i.appointment_id
         JOIN medical_services s ON s.code = 'DERM-REV'
WHERE a.start_at = '2026-01-12T10:00:00';

INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 60.00, 'VAT_21', 'NONE', null, 72.60
FROM invoices i
         JOIN appointments a ON a.id = i.appointment_id
         JOIN medical_services s ON s.code = 'NUTRI-PLAN'
WHERE a.start_at = '2026-01-13T10:00:00';

INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 50.00, 'VAT_21', 'NONE', null, 60.50
FROM invoices i
         JOIN appointments a ON a.id = i.appointment_id
         JOIN medical_services s ON s.code = 'CONS-GEN'
WHERE a.start_at = '2026-01-19T09:00:00';



-- =========================================================
-- EXTRA DATASET para REPORT /top-services (más facturas + líneas)
-- =========================================================

-- ---------------------------------------------------------
-- INVOICES EXTRA (issuedAt siempre NOT NULL)
-- ---------------------------------------------------------

-- CONSULTA GENERAL (CONS-GEN)
INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 50.00, 10.50, 60.50, '2026-01-07T12:00:00', '2026-01-07T12:05:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-07T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 50.00, 10.50, 60.50, '2026-01-07T13:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-07T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 50.00, 10.50, 60.50, '2026-01-08T12:00:00', '2026-01-08T12:10:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-08T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 50.00, 10.50, 60.50, '2026-01-09T12:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-09T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 50.00, 10.50, 60.50, '2026-01-09T13:00:00', '2026-01-09T13:02:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-09T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 50.00, 10.50, 60.50, '2026-01-12T12:00:00', '2026-01-12T12:03:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-12T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 50.00, 10.50, 60.50, '2026-01-19T12:10:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-19T09:30:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 50.00, 10.50, 60.50, '2026-01-26T12:00:00', '2026-01-26T12:05:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-26T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 50.00, 10.50, 60.50, '2026-01-27T12:00:00', '2026-01-27T12:08:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-27T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 50.00, 10.50, 60.50, '2026-01-30T12:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-30T09:00:00';

-- DERMATOLOGÍA (DERM-REV)
INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 80.00, 16.80, 96.80, '2026-01-14T12:00:00', '2026-01-14T12:06:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-14T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 80.00, 16.80, 96.80, '2026-01-14T13:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-14T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 80.00, 16.80, 96.80, '2026-01-19T13:00:00', '2026-01-19T13:04:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-19T11:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 80.00, 16.80, 96.80, '2026-01-26T13:00:00', '2026-01-26T13:07:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-26T10:00:00';

-- CARDIOLOGÍA (CARD-ECG)
INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 120.00, 25.20, 145.20, '2026-01-15T12:00:00', '2026-01-15T12:02:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-15T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 120.00, 25.20, 145.20, '2026-01-20T12:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-20T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 120.00, 25.20, 145.20, '2026-01-26T13:30:00', '2026-01-26T13:35:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-26T11:00:00';

-- NUTRICIÓN (NUTRI-PLAN)
INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 60.00, 12.60, 72.60, '2026-01-06T12:10:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-06T11:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 60.00, 12.60, 72.60, '2026-01-17T12:00:00', '2026-01-17T12:03:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-17T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 60.00, 12.60, 72.60, '2026-01-21T12:00:00', '2026-01-21T12:06:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-21T11:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 60.00, 12.60, 72.60, '2026-01-28T12:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-28T11:00:00';

-- PEDIATRÍA + VACUNA (PED-CONT + VAC-FLU) en la MISMA factura (2 líneas)
-- subtotal = 45 + 25 = 70 ; IVA 21% = 14.70 ; total = 84.70
INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 70.00, 14.70, 84.70, '2026-01-16T12:00:00', '2026-01-16T12:05:00', 'CARD'
FROM appointments a WHERE a.start_at = '2026-01-16T09:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'ISSUED', 70.00, 14.70, 84.70, '2026-01-16T13:00:00', null, null
FROM appointments a WHERE a.start_at = '2026-01-16T10:00:00';

INSERT INTO invoices (appointment_id, status, subtotal, tax_total, total, issued_at, paid_at, payment_method)
SELECT a.id, 'PAID', 70.00, 14.70, 84.70, '2026-01-21T12:30:00', '2026-01-21T12:35:00', 'CASH'
FROM appointments a WHERE a.start_at = '2026-01-21T09:00:00';


-- ---------------------------------------------------------
-- INVOICE LINES EXTRA
-- ---------------------------------------------------------

-- CONS-GEN lines
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 50.00, 'VAT_21', 'NONE', null, 60.50
FROM invoices i JOIN appointments a ON a.id = i.appointment_id JOIN medical_services s ON s.code='CONS-GEN'
WHERE a.start_at IN (
                     '2026-01-07T09:00:00','2026-01-07T10:00:00','2026-01-08T09:00:00','2026-01-09T09:00:00','2026-01-09T10:00:00',
                     '2026-01-12T09:00:00','2026-01-19T09:30:00','2026-01-26T09:00:00','2026-01-27T09:00:00','2026-01-30T09:00:00'
    );

-- DERM-REV lines
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 80.00, 'VAT_21', 'NONE', null, 96.80
FROM invoices i JOIN appointments a ON a.id = i.appointment_id JOIN medical_services s ON s.code='DERM-REV'
WHERE a.start_at IN (
                     '2026-01-14T09:00:00','2026-01-14T10:00:00','2026-01-19T11:00:00','2026-01-26T10:00:00'
    );

-- CARD-ECG lines
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 120.00, 'VAT_21', 'NONE', null, 145.20
FROM invoices i JOIN appointments a ON a.id = i.appointment_id JOIN medical_services s ON s.code='CARD-ECG'
WHERE a.start_at IN (
                     '2026-01-15T09:00:00','2026-01-20T10:00:00','2026-01-26T11:00:00'
    );

-- NUTRI-PLAN lines
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 60.00, 'VAT_21', 'NONE', null, 72.60
FROM invoices i JOIN appointments a ON a.id = i.appointment_id JOIN medical_services s ON s.code='NUTRI-PLAN'
WHERE a.start_at IN (
                     '2026-01-06T11:00:00','2026-01-17T09:00:00','2026-01-21T11:00:00','2026-01-28T11:00:00'
    );

-- PED-CONT line (en facturas multi-línea)
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 45.00, 'VAT_21', 'NONE', null, 54.45
FROM invoices i JOIN appointments a ON a.id = i.appointment_id JOIN medical_services s ON s.code='PED-CONT'
WHERE a.start_at IN ('2026-01-16T09:00:00','2026-01-16T10:00:00','2026-01-21T09:00:00');

-- VAC-FLU line (en las mismas facturas multi-línea)
INSERT INTO invoice_lines (invoice_id, service_id, quantity, unit_price, vat_rate, discount_type, discount_value, line_total)
SELECT i.id, s.id, 1, 25.00, 'VAT_21', 'NONE', null, 30.25
FROM invoices i JOIN appointments a ON a.id = i.appointment_id JOIN medical_services s ON s.code='VAC-FLU'
WHERE a.start_at IN ('2026-01-16T09:00:00','2026-01-16T10:00:00','2026-01-21T09:00:00');


-- ---------------------------------------------------------
-- APPOINTMENT EXTRA (COMPLETED) SIN FACTURA
-- Para pruebas del endpoint: POST /api/appointments/{id}/invoice
-- ---------------------------------------------------------
INSERT INTO appointments (patient_id, doctor_id, start_at, end_at, minutes, status, reason, cancellation_reason)
VALUES (1, 2, '2026-02-02T09:00:00', '2026-02-02T09:30:00', 30, 'COMPLETED', 'Cita extra para facturación', null);
