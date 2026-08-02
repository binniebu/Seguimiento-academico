-- =========================================================================
-- SCRIPT DE BASE DE DATOS UNIFICADO - SISTEMA DE SEGUIMIENTO ACADÉMICO
-- =========================================================================
-- Instrucciones: Importar este archivo completo directamente en phpMyAdmin.
-- Eliminará bases de datos previas de prueba para garantizar consistencia.

DROP DATABASE IF EXISTS seguimiento_academico;
CREATE DATABASE seguimiento_academico CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE seguimiento_academico;

-- 1. Tabla de Roles
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabla de Usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo', -- 'activo', 'pendiente', 'inactivo', 'graduado'
    titulo VARCHAR(150) NULL, -- Título profesional/académico libre para maestros y coordinadores
    documento_dni VARCHAR(255) NULL, -- Ruta archivo DNI (Aspirantes)
    documento_titulo VARCHAR(255) NULL, -- Ruta archivo Título (Aspirantes)
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabla intermedia para usuarios con múltiples roles
CREATE TABLE usuarios_roles (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabla de Facultades
CREATE TABLE facultades (
    id_facultad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_facultad VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4b. Tabla de Campus (Sedes)
CREATE TABLE campus (
    id_campus INT AUTO_INCREMENT PRIMARY KEY,
    nombre_campus VARCHAR(100) NOT NULL UNIQUE,
    departamento VARCHAR(100) NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabla de Carreras
CREATE TABLE carreras (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL UNIQUE,
    id_facultad INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo',
    FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tabla de Estudiantes
CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    cuenta VARCHAR(20) NOT NULL UNIQUE, -- Se almacena el DNI como número de cuenta
    carrera VARCHAR(100) NOT NULL, -- Se guarda el nombre de la carrera a la que pertenece
    telefono VARCHAR(20) NULL,
    estado VARCHAR(20) DEFAULT 'Admitido', -- 'Admitido', 'activo', 'inactivo', 'graduado'
    id_campus INT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_campus) REFERENCES campus(id_campus) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6b. Tabla asociativa para estudiantes en múltiples carreras (Doble Carrera)
CREATE TABLE estudiante_carreras (
    id_estudiante_carrera INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_carrera INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'activa',
    es_principal TINYINT(1) NOT NULL DEFAULT 0,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON DELETE CASCADE,
    UNIQUE KEY uq_estudiante_carrera (id_estudiante, id_carrera)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Tabla de Maestros
CREATE TABLE maestros (
    id_maestro INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    numero_empleado VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    id_campus INT NULL,
    id_facultad INT NULL,
    id_carrera INT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_campus) REFERENCES campus(id_campus) ON DELETE SET NULL,
    FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad) ON DELETE SET NULL,
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Tabla de Coordinadores de Facultad
CREATE TABLE coordinadores (
    id_coordinador INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_facultad INT NOT NULL,
    id_campus INT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad) ON DELETE CASCADE,
    FOREIGN KEY (id_campus) REFERENCES campus(id_campus) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Tabla de Periodos Académicos
CREATE TABLE periodos_academicos (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_periodo VARCHAR(50) NOT NULL UNIQUE, -- Ej. '2026-I'
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo', -- 'activo', 'inactivo'
    matricula_activa TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Tabla de Materias (Asignaturas)
CREATE TABLE materias (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NULL,
    creditos INT DEFAULT 3,
    periodo INT DEFAULT 1, -- Cuatrimestre/Periodo recomendado en el flujograma (1, 2, 3...)
    tipo_materia VARCHAR(30) DEFAULT 'institucional', -- 'institucional', 'facultad', 'carrera'
    id_facultad INT NULL,
    id_carrera INT NULL,
    id_requisito INT NULL,
    estado VARCHAR(20) DEFAULT 'activa',
    FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad) ON DELETE SET NULL,
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON DELETE SET NULL,
    FOREIGN KEY (id_requisito) REFERENCES materias(id_materia) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Tabla de Secciones de Clases
CREATE TABLE secciones (
    id_seccion INT AUTO_INCREMENT PRIMARY KEY,
    codigo_seccion VARCHAR(20) NOT NULL UNIQUE, -- Ej. '0700-ING-2026'
    id_materia INT NOT NULL,
    id_maestro INT NOT NULL,
    id_periodo INT NOT NULL,
    aula VARCHAR(50) NOT NULL,
    dias VARCHAR(50) NOT NULL, -- Ej. 'Lu-Mi', 'Ma-Ju', 'Vi'
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    cupo_maximo INT DEFAULT 30,
    estado VARCHAR(20) DEFAULT 'Borrador', -- 'Borrador', 'Activa', 'Cerrada'
    FOREIGN KEY (id_materia) REFERENCES materias(id_materia) ON DELETE CASCADE,
    FOREIGN KEY (id_maestro) REFERENCES maestros(id_maestro) ON DELETE CASCADE,
    FOREIGN KEY (id_periodo) REFERENCES periodos_academicos(id_periodo) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Tabla de Matrículas (Estudiantes inscritos en secciones)
CREATE TABLE matriculas (
    id_matricula INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_seccion INT NOT NULL,
    id_periodo INT NOT NULL,
    fecha_matricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY estudiante_seccion (id_estudiante, id_seccion),
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_seccion) REFERENCES secciones(id_seccion) ON DELETE CASCADE,
    FOREIGN KEY (id_periodo) REFERENCES periodos_academicos(id_periodo) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Tabla de Calificaciones
CREATE TABLE calificaciones (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_matricula INT NOT NULL UNIQUE,
    nota DECIMAL(5,2) NOT NULL, -- Nota final / Promedio acumulado de la asignatura
    observacion VARCHAR(150) NULL, -- (Opcional) Observaciones adicionales
    nota_parcial1 DECIMAL(5,2) NULL, -- Calificación del primer parcial
    nota_parcial2 DECIMAL(5,2) NULL, -- Calificación del segundo parcial
    nota_parcial3 DECIMAL(5,2) NULL, -- Calificación del tercer parcial
    corregida TINYINT(1) NOT NULL DEFAULT 0,
    ultima_correccion TIMESTAMP NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Tabla de Solicitudes de Corrección de Notas
CREATE TABLE solicitudes_correccion_notas (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_calificacion INT NOT NULL,
    id_matricula INT NOT NULL,
    id_maestro INT NULL,
    id_solicitante INT NOT NULL,
    nota_anterior DECIMAL(5,2) NULL,
    nota_nueva DECIMAL(5,2) NULL,
    parcial1_anterior DECIMAL(5,2) NULL,
    parcial1_nueva DECIMAL(5,2) NULL,
    parcial2_anterior DECIMAL(5,2) NULL,
    parcial2_nueva DECIMAL(5,2) NULL,
    parcial3_anterior DECIMAL(5,2) NULL,
    parcial3_nueva DECIMAL(5,2) NULL,
    motivo TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL,
    aprobado_por INT NULL,
    comentario_resolucion TEXT NULL,
    FOREIGN KEY (id_calificacion) REFERENCES calificaciones(id_calificacion) ON DELETE CASCADE,
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    FOREIGN KEY (id_solicitante) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (aprobado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================================================
-- SEEDS E INFORMACIÓN DE PRUEBA INICIAL
-- =========================================================================

-- Inserción de Roles
INSERT INTO roles (id_rol, nombre_rol) VALUES
(1, 'director'),
(2, 'maestro'),
(3, 'estudiante'),
(4, 'coordinador');

-- Inserción de Facultades
INSERT INTO facultades (id_facultad, nombre_facultad) VALUES
(1, 'Facultad de Ingeniería'),
(2, 'Facultad de Ciencias de la Salud'),
(3, 'Facultad de Ciencias Económicas'),
(4, 'Facultad de Ciencias Juridicas');

-- Inserción de Campus (Sedes)
INSERT INTO campus (id_campus, nombre_campus, departamento, estado) VALUES
(1, 'Campus Central - Tegucigalpa', 'Francisco Morazán', 'activo'),
(2, 'Campus Valle de Sula - San Pedro Sula', 'Cortés', 'activo'),
(3, 'Campus La Ceiba - La Ceiba', 'Atlántida', 'activo');

-- Inserción de Carreras
INSERT INTO carreras (id_carrera, nombre_carrera, id_facultad, estado) VALUES
(1, 'Ingeniería en Sistemas', 1, 'activa'),
(2, 'Ingeniería Industrial', 1, 'activa'),
(3, 'Licenciatura en Enfermería', 2, 'activa'),
(4, 'Licenciatura en Administración de Empresas', 3, 'activa'),
(5, 'Derecho', 4, 'activa'),
(6, 'Ingeniería en Ciencias de la Computación', 1, 'activa');

-- Inserción de Periodos Académicos
INSERT INTO periodos_academicos (id_periodo, nombre_periodo, fecha_inicio, fecha_fin, estado, matricula_activa) VALUES
(1, 'Periodo 2026-I', '2026-01-15', '2026-05-15', 'activo', 1);

-- Inserción de Materias de Prueba
INSERT INTO materias (id_materia, codigo, nombre, descripcion, creditos, periodo, tipo_materia, id_facultad, id_carrera, id_requisito, estado) VALUES
(1, 'MAT101', 'Álgebra Lineal', 'Estudio de matrices, vectores y espacios vectoriales.', 4, 1, 'institucional', NULL, NULL, NULL, 'activa'),
(2, 'FIS101', 'Física General', 'Estudio de la mecánica y cinemática clásica.', 4, 2, 'facultad', 1, NULL, 1, 'activa'),
(3, 'SIS201', 'Programación Orientada a Objetos', 'Programación avanzada en Java e implementación de patrones de diseño.', 4, 2, 'carrera', 1, 1, NULL, 'activa'),
(4, 'SIS301', 'Estructuras de Datos', 'Implementación de listas, árboles y grafos.', 4, 3, 'carrera', 1, 1, 3, 'activa'),
(5, 'DER-101', 'Introduccion al Derecho', 'Fundamentos generales del derecho.', 4, 1, 'carrera', 4, 5, NULL, 'activa'),
(6, 'DER-102', 'Teoria del Estado', 'Bases juridicas del Estado moderno.', 4, 1, 'carrera', 4, 5, NULL, 'activa'),
(7, 'SIS-DEMO', 'Taller de Sistemas Demo', 'Materia demo para pruebas.', 3, 1, 'carrera', 1, 1, NULL, 'activa'),
(8, 'ICC-101', 'Introducción a la Computación', 'Conceptos básicos de ciencias de la computación.', 4, 1, 'carrera', 1, 6, NULL, 'activa'),
(9, 'ICC-201', 'Programación I', 'Fundamentos de programación y algoritmos.', 4, 1, 'carrera', 1, 6, NULL, 'activa'),
(10, 'ICC-202', 'Arquitectura de Computadoras', 'Estructura y diseño de hardware de computación.', 4, 2, 'carrera', 1, 6, 8, 'activa');

-- Inserción de Usuarios Administrativos, Maestros y Estudiantes Demo

SET @pwd_123456 = '$2y$10$GWAc6HK.BZkAezb3rt3ACOzSkdQlp1cUhqIUgKKz23lSt90Q3EVs2';

-- 1. Director Ramos
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado) VALUES
(15, 'Director Ramos', 'ramos11@gmail.com', @pwd_123456, 1, 'activo');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(15, 1);

-- 2. Juan Delarca (Coordinador)
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado, titulo) VALUES
(13, 'Juan Delarca', 'delarca@gmail.com', @pwd_123456, 4, 'activo', 'Ingeniero de Software y Doctor en Computación');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(13, 4);

INSERT INTO coordinadores (id_usuario, id_facultad, id_campus) VALUES
(13, 1, 1);

-- 3. Carlos Fuentes (Maestro)
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado, titulo) VALUES
(14, 'Carlos Fuentes', 'cfuentes@gmail.com', @pwd_123456, 2, 'activo', 'Licenciado en Matemáticas Puras');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(14, 2);

INSERT INTO maestros (id_usuario, numero_empleado, telefono, id_campus, id_facultad, id_carrera) VALUES
(14, 'EMP-1400', '9933-2211', 1, 1, 1);

-- 4. Docentes Demo Adicionales
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado, titulo) VALUES
(16, 'Dra. Marta Espinoza', 'marta.espinoza@uni.edu', @pwd_123456, 2, 'activo', 'Doctora en Educacion'),
(17, 'Dr. Roberto Mejia', 'roberto.mejia@uni.edu', @pwd_123456, 2, 'activo', 'Doctor en Ciencias Sociales');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(16, 2),
(17, 2);

INSERT INTO maestros (id_usuario, numero_empleado, telefono, id_campus, id_facultad, id_carrera) VALUES
(16, 'EMP-DEMO-001', '9988-1100', 1, 1, 1),
(17, 'EMP-DEMO-002', '9988-2200', 1, 4, 5);

-- 5. Estudiantes Demo (Luis, Ana, Mariana y Roberto que también estudia)
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado) VALUES
(18, 'Ana Gabriela Lopez', 'ana.lopez@alumno.edu', @pwd_123456, 3, 'activo'),
(19, 'Luis Fernando Perez', 'luis.perez@alumno.edu', @pwd_123456, 3, 'activo'),
(20, 'Mariana Castro', 'mariana.castro@alumno.edu', @pwd_123456, 3, 'activo'),
(21, 'Yessenia Nicolle Baquedano Cruz', 'nicollebaquedano11@gmail.com', @pwd_123456, 3, 'activo');

-- Dr. Roberto Mejia también es estudiante (estudia Derecho)
INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(18, 3),
(19, 3),
(20, 3),
(21, 3),
(17, 3); -- Rol de estudiante asignado a Roberto Mejia

INSERT INTO estudiantes (id_usuario, cuenta, carrera, telefono, estado, id_campus) VALUES
(18, '2026-0001', 'Ingeniería en Sistemas', '9876-0001', 'activo', 1),
(19, '2026-0002', 'Derecho', '9876-0002', 'activo', 1),
(20, '2026-0003', 'Ingeniería Industrial', '9876-0003', 'activo', 2),
(17, '2026-DR01', 'Derecho', '9876-2200', 'activo', 1),
(21, '0601200502457', 'Ingeniería en Ciencias de la Computación', '89905804', 'activo', 1);

-- Inscripción en múltiples carreras (Doble Carrera)
INSERT INTO estudiante_carreras (id_estudiante, id_carrera, estado, es_principal) VALUES
(1, 1, 'activa', 1),  -- Ana en Sistemas (Principal)
(1, 2, 'activa', 0),  -- Ana en Industrial (Secundaria)
(2, 5, 'activa', 1),  -- Luis en Derecho (Principal)
(3, 2, 'activa', 1),  -- Mariana en Industrial (Principal)
(4, 5, 'activa', 1),  -- Roberto en Derecho (Principal)
(5, 6, 'activa', 1),  -- Yessenia en Ciencias de la Computación (Principal)
(5, 2, 'activa', 0);  -- Yessenia en Industrial (Secundaria)

-- Inserción de Secciones
INSERT INTO secciones (id_seccion, codigo_seccion, id_materia, id_maestro, id_periodo, aula, dias, hora_inicio, hora_fin, cupo_maximo, estado) VALUES
(1, 'DER-101-A', 5, 3, 1, 'D-101', 'Lunes y Miercoles', '18:00:00', '19:30:00', 30, 'Activa'), -- Asignada a Roberto (id_maestro = 3)
(2, 'SIS-DEMO-A', 7, 2, 1, 'LAB-2', 'Martes y Jueves', '08:00:00', '09:30:00', 25, 'Activa'), -- Asignada a Marta (id_maestro = 2)
(3, 'ICC-101-A', 8, 2, 1, 'CC-102', 'Lunes y Miercoles', '07:00:00', '08:30:00', 30, 'Activa'),
(4, 'ICC-201-A', 9, 2, 1, 'LAB-1', 'Martes y Jueves', '10:00:00', '11:30:00', 30, 'Activa'); -- Asignada a Marta (id_maestro = 2)

-- Inserción de Matrículas
INSERT INTO matriculas (id_matricula, id_estudiante, id_seccion, id_periodo) VALUES
(1, 2, 1, 1), -- Luis en DER-101-A
(2, 4, 1, 1), -- Roberto (estudiante) en DER-101-A
(3, 1, 2, 1), -- Ana en SIS-DEMO-A
(4, 5, 3, 1), -- Yessenia en ICC-101-A
(5, 5, 4, 1); -- Ana en SIS-DEMO-A

-- Inserción de Calificaciones de Prueba
INSERT INTO calificaciones (id_matricula, nota, observacion, nota_parcial1, nota_parcial2, nota_parcial3) VALUES
(1, 88.00, 'Calificacion demo', 88.00, 88.00, 88.00),
(2, 92.00, 'Profesor cursando Derecho', 92.00, 92.00, 92.00),
(3, 85.00, 'Estudiante con doble carrera', 85.00, 85.00, 85.00),
(4, 85.00, 'Aprobada', 85.00, 85.00, 85.00),
(5, 90.00, 'Aprobada', 90.00, 90.00, 90.00);
