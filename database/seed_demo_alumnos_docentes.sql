-- Datos demo: alumnos, docentes, carreras multiples y profesor que tambien estudia Derecho.

SET @pwd_123456 = '$2y$10$GWAc6HK.BZkAezb3rt3ACOzSkdQlp1cUhqIUgKKz23lSt90Q3EVs2';

INSERT INTO facultades (nombre_facultad)
SELECT 'Facultad de Ciencias Juridicas'
WHERE NOT EXISTS (
    SELECT 1 FROM facultades WHERE nombre_facultad = 'Facultad de Ciencias Juridicas'
);

SET @fac_juridicas = (SELECT id_facultad FROM facultades WHERE nombre_facultad = 'Facultad de Ciencias Juridicas' LIMIT 1);

INSERT INTO carreras (nombre_carrera, id_facultad, estado)
SELECT 'Derecho', @fac_juridicas, 'activo'
WHERE NOT EXISTS (
    SELECT 1 FROM carreras WHERE nombre_carrera = 'Derecho'
);

SET @carrera_sistemas = (
    SELECT id_carrera FROM carreras
    WHERE nombre_carrera IN ('Ingenieria en sistemas', 'Ingenier??a en Sistemas', 'Ingeniería en Sistemas')
    ORDER BY id_carrera DESC LIMIT 1
);
SET @carrera_industrial = (
    SELECT id_carrera FROM carreras
    WHERE nombre_carrera IN ('Ingenier??a Industrial', 'Ingeniería Industrial')
    ORDER BY id_carrera DESC LIMIT 1
);
SET @carrera_sistemas = COALESCE(@carrera_sistemas, (
    SELECT id_carrera FROM carreras
    WHERE nombre_carrera LIKE '%sistemas%'
    ORDER BY id_carrera DESC LIMIT 1
));
SET @carrera_industrial = COALESCE(@carrera_industrial, (
    SELECT id_carrera FROM carreras
    WHERE nombre_carrera LIKE '%Industrial%'
    ORDER BY id_carrera DESC LIMIT 1
));
SET @carrera_derecho = (SELECT id_carrera FROM carreras WHERE nombre_carrera = 'Derecho' LIMIT 1);
SET @fac_ingenieria = (SELECT id_facultad FROM carreras WHERE id_carrera = @carrera_sistemas LIMIT 1);

-- Docentes demo
INSERT IGNORE INTO usuarios (nombre, correo, password, id_rol, estado, titulo)
VALUES
('Dra. Marta Espinoza', 'marta.espinoza@uni.edu', @pwd_123456, 2, 'activo', 'Doctora en Educacion'),
('Dr. Roberto Mejia', 'roberto.mejia@uni.edu', @pwd_123456, 2, 'activo', 'Doctor en Ciencias Sociales');

SET @u_marta = (SELECT id_usuario FROM usuarios WHERE correo = 'marta.espinoza@uni.edu' LIMIT 1);
SET @u_roberto = (SELECT id_usuario FROM usuarios WHERE correo = 'roberto.mejia@uni.edu' LIMIT 1);

INSERT IGNORE INTO usuarios_roles (id_usuario, id_rol)
VALUES
(@u_marta, 2),
(@u_roberto, 2);

INSERT IGNORE INTO maestros (id_usuario, numero_empleado, telefono, id_campus, id_facultad, id_carrera)
VALUES
(@u_marta, 'EMP-DEMO-001', '9988-1100', 1, @fac_ingenieria, @carrera_sistemas),
(@u_roberto, 'EMP-DEMO-002', '9988-2200', 1, @fac_juridicas, @carrera_derecho);

-- Alumnos demo
INSERT IGNORE INTO usuarios (nombre, correo, password, id_rol, estado)
VALUES
('Ana Gabriela Lopez', 'ana.lopez@alumno.edu', @pwd_123456, 3, 'activo'),
('Luis Fernando Perez', 'luis.perez@alumno.edu', @pwd_123456, 3, 'activo'),
('Mariana Castro', 'mariana.castro@alumno.edu', @pwd_123456, 3, 'activo');

SET @u_ana = (SELECT id_usuario FROM usuarios WHERE correo = 'ana.lopez@alumno.edu' LIMIT 1);
SET @u_luis = (SELECT id_usuario FROM usuarios WHERE correo = 'luis.perez@alumno.edu' LIMIT 1);
SET @u_mariana = (SELECT id_usuario FROM usuarios WHERE correo = 'mariana.castro@alumno.edu' LIMIT 1);

INSERT IGNORE INTO usuarios_roles (id_usuario, id_rol)
VALUES
(@u_ana, 3),
(@u_luis, 3),
(@u_mariana, 3),
(@u_roberto, 3);

INSERT IGNORE INTO estudiantes (id_usuario, cuenta, carrera, telefono, estado, id_campus)
VALUES
(@u_ana, '2026-0001', 'Ingenieria en sistemas', '9876-0001', 'activo', 1),
(@u_luis, '2026-0002', 'Derecho', '9876-0002', 'activo', 1),
(@u_mariana, '2026-0003', 'Ingenieria Industrial', '9876-0003', 'activo', 2),
(@u_roberto, '2026-DR01', 'Derecho', '9876-2200', 'activo', 1);

SET @e_ana = (SELECT id_estudiante FROM estudiantes WHERE cuenta = '2026-0001' LIMIT 1);
SET @e_luis = (SELECT id_estudiante FROM estudiantes WHERE cuenta = '2026-0002' LIMIT 1);
SET @e_mariana = (SELECT id_estudiante FROM estudiantes WHERE cuenta = '2026-0003' LIMIT 1);
SET @e_roberto = (SELECT id_estudiante FROM estudiantes WHERE cuenta = '2026-DR01' LIMIT 1);

-- Ana queda inscrita en dos carreras: Sistemas e Industrial.
INSERT IGNORE INTO estudiante_carreras (id_estudiante, id_carrera, estado, es_principal)
VALUES
(@e_ana, @carrera_sistemas, 'activa', 1),
(@e_ana, @carrera_industrial, 'activa', 0),
(@e_luis, @carrera_derecho, 'activa', 1),
(@e_mariana, @carrera_industrial, 'activa', 1),
(@e_roberto, @carrera_derecho, 'activa', 1);

-- Materias demo para que las carreras aparezcan con carga academica.
INSERT IGNORE INTO materias (codigo, nombre, descripcion, creditos, periodo, tipo_materia, id_facultad, id_carrera, estado)
VALUES
('DER-101', 'Introduccion al Derecho', 'Fundamentos generales del derecho.', 4, 1, 'carrera', @fac_juridicas, @carrera_derecho, 'activa'),
('DER-102', 'Teoria del Estado', 'Bases juridicas del Estado moderno.', 4, 1, 'carrera', @fac_juridicas, @carrera_derecho, 'activa'),
('SIS-DEMO', 'Taller de Sistemas Demo', 'Materia demo para pruebas.', 3, 1, 'carrera', @fac_ingenieria, @carrera_sistemas, 'activa');

UPDATE periodos_academicos
SET matricula_activa = 1
WHERE estado = 'activo';

SET @periodo_activo = (
    SELECT id_periodo FROM periodos_academicos
    WHERE estado = 'activo'
    ORDER BY id_periodo DESC LIMIT 1
);
SET @m_der101 = (SELECT id_materia FROM materias WHERE codigo = 'DER-101' LIMIT 1);
SET @m_sis_demo = (SELECT id_materia FROM materias WHERE codigo = 'SIS-DEMO' LIMIT 1);
SET @maestro_marta = (SELECT id_maestro FROM maestros WHERE numero_empleado = 'EMP-DEMO-001' LIMIT 1);
SET @maestro_roberto = (SELECT id_maestro FROM maestros WHERE numero_empleado = 'EMP-DEMO-002' LIMIT 1);

INSERT IGNORE INTO secciones (codigo_seccion, id_materia, id_maestro, id_periodo, aula, dias, hora_inicio, hora_fin, cupo_maximo, estado)
VALUES
('DER-101-A', @m_der101, @maestro_roberto, @periodo_activo, 'D-101', 'Lunes y Miercoles', '18:00:00', '19:30:00', 30, 'Activa'),
('SIS-DEMO-A', @m_sis_demo, @maestro_marta, @periodo_activo, 'LAB-2', 'Martes y Jueves', '08:00:00', '09:30:00', 25, 'Activa');

SET @sec_der101 = (SELECT id_seccion FROM secciones WHERE codigo_seccion = 'DER-101-A' LIMIT 1);
SET @sec_sis_demo = (SELECT id_seccion FROM secciones WHERE codigo_seccion = 'SIS-DEMO-A' LIMIT 1);

INSERT INTO matriculas (id_estudiante, id_seccion, id_periodo)
SELECT @e_luis, @sec_der101, @periodo_activo
WHERE NOT EXISTS (
    SELECT 1 FROM matriculas WHERE id_estudiante = @e_luis AND id_seccion = @sec_der101 AND id_periodo = @periodo_activo
);
INSERT INTO matriculas (id_estudiante, id_seccion, id_periodo)
SELECT @e_roberto, @sec_der101, @periodo_activo
WHERE NOT EXISTS (
    SELECT 1 FROM matriculas WHERE id_estudiante = @e_roberto AND id_seccion = @sec_der101 AND id_periodo = @periodo_activo
);
INSERT INTO matriculas (id_estudiante, id_seccion, id_periodo)
SELECT @e_ana, @sec_sis_demo, @periodo_activo
WHERE NOT EXISTS (
    SELECT 1 FROM matriculas WHERE id_estudiante = @e_ana AND id_seccion = @sec_sis_demo AND id_periodo = @periodo_activo
);

SET @mat_luis_der = (SELECT id_matricula FROM matriculas WHERE id_estudiante = @e_luis AND id_seccion = @sec_der101 LIMIT 1);
SET @mat_roberto_der = (SELECT id_matricula FROM matriculas WHERE id_estudiante = @e_roberto AND id_seccion = @sec_der101 LIMIT 1);
SET @mat_ana_sis = (SELECT id_matricula FROM matriculas WHERE id_estudiante = @e_ana AND id_seccion = @sec_sis_demo LIMIT 1);

INSERT INTO calificaciones (id_matricula, nota, observacion, nota_parcial1, nota_parcial2, nota_parcial3)
SELECT @mat_luis_der, 88.00, 'Calificacion demo', 28.00, 30.00, 30.00
WHERE NOT EXISTS (SELECT 1 FROM calificaciones WHERE id_matricula = @mat_luis_der);
INSERT INTO calificaciones (id_matricula, nota, observacion, nota_parcial1, nota_parcial2, nota_parcial3)
SELECT @mat_roberto_der, 92.00, 'Profesor cursando Derecho', 30.00, 31.00, 31.00
WHERE NOT EXISTS (SELECT 1 FROM calificaciones WHERE id_matricula = @mat_roberto_der);
INSERT INTO calificaciones (id_matricula, nota, observacion, nota_parcial1, nota_parcial2, nota_parcial3)
SELECT @mat_ana_sis, 85.00, 'Estudiante con doble carrera', 27.00, 29.00, 29.00
WHERE NOT EXISTS (SELECT 1 FROM calificaciones WHERE id_matricula = @mat_ana_sis);
