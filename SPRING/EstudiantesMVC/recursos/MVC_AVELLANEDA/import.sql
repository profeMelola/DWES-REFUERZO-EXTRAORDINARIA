INSERT INTO roles (name) VALUES ('ROLE_TEACHER');
INSERT INTO roles (name) VALUES ('ROLE_STUDENT');

INSERT INTO users(email,password,username) VALUES('profe@avellaneda.es','$2a$10$sTdQgzZPWUfHhyR5Q1aGP.f1smPH6z05JBuEHedX7wBw92umcwhqm','profe');
INSERT INTO users(email,password,username) VALUES('alumno@avellaneda.es','$2a$10$DKpwOn88Oax3e/qnxVtmcOdNoNAwSloyXWWd4KXRYU0012eB.JL1W','alumno');

INSERT INTO user_roles(role_id,user_id) VALUES(1,1);
INSERT INTO user_roles(role_id,user_id) VALUES(2,2);

