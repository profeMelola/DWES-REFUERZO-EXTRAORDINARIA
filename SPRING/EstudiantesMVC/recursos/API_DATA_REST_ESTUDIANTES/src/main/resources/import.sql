INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1001', 'Juan', 'Pérez', 'Gómez', 'juan.perez@example.com', '600123456', 'Calle Mayor 10, Madrid', '2000-05-15');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1002', 'Juan', 'Pérez', 'López', 'juan.perez2@example.com', '601123456', 'Avenida Gran Vía 23, Madrid', '1999-08-22');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1003', 'Ana', 'García', 'Fernández', 'ana.garcia@example.com', '602123456', 'Calle Serrano 45, Madrid', '2001-11-30');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1004', 'Pedro', 'Martínez', 'Sánchez', 'pedro.martinez@example.com', '603123456', 'Calle Goya 12, Barcelona', '1998-07-10');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1005', 'Laura', 'Fernández', 'Gómez', 'laura.fernandez@example.com', '604123456', 'Avenida Diagonal 50, Barcelona', '2002-04-25');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1006', 'Carlos', 'Rodríguez', 'Martínez', 'carlos.rodriguez@example.com', '605123456', 'Calle Princesa 5, Madrid', '2000-02-18');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1007', 'Elena', 'Sánchez', 'García', 'elena.sanchez@example.com', '606123456', 'Paseo de la Castellana 120, Madrid', '1997-09-05');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1008', 'David', 'López', 'Fernández', 'david.lopez@example.com', '607123456', 'Calle Alcalá 67, Madrid', '1996-12-14');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1009', 'María', 'Díaz', 'Ruiz', 'maria.diaz@example.com', '608123456', 'Avenida América 15, Madrid', '2001-06-21');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1010', 'Sergio', 'Hernández', 'Gómez', 'sergio.hernandez@example.com', '609123456', 'Calle Toledo 89, Madrid', '1999-04-03');
INSERT INTO estudiantes (nia, nombre, primer_apellido, segundo_apellido, email, movil, direccion, fecha_nacimiento) VALUES ('NIA_1011', 'Isabel', 'Gutiérrez', 'Santos', 'isabel.gutierrez@example.com', '610123456', 'Calle Hermandad 3, Cuenca', '1995-07-17');


INSERT INTO roles (name) VALUES ('ROLE_USER');
INSERT INTO roles (name) VALUES ('ROLE_ADMIN');

INSERT INTO users (username, password) VALUES ('admin', '$2a$10$Ey/H5tNIopwhtVYXQ76Ms.oeiol3A4NiG3/HJekFyKkmgLVbR1n1C');
INSERT INTO users (username, password) VALUES ('user', '$2a$10$XVgKh.17he10CTo6Av57xOlSpnQWYxVJyshfkxjPKFLGTfth7FQZy');

INSERT INTO users_roles (role_id,user_id) VALUES(2,1);
INSERT INTO users_roles (role_id,user_id) VALUES(1,2);