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
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Tabla de Maestros
CREATE TABLE maestros (
    id_maestro INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    numero_empleado VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Tabla de Coordinadores de Facultad
CREATE TABLE coordinadores (
    id_coordinador INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_facultad INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Tabla de Periodos Académicos
CREATE TABLE periodos_academicos (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_periodo VARCHAR(50) NOT NULL UNIQUE, -- Ej. '2026-I'
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo' -- 'activo', 'inactivo'
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
    nota DECIMAL(5,2) NOT NULL,
    observacion VARCHAR(150) NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE
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
(3, 'Facultad de Ciencias Económicas');

-- Inserción de Carreras
INSERT INTO carreras (id_carrera, nombre_carrera, id_facultad, estado) VALUES
(1, 'Ingeniería en Sistemas', 1, 'activo'),
(2, 'Ingeniería Industrial', 1, 'activo'),
(3, 'Licenciatura en Enfermería', 2, 'activo'),
(4, 'Licenciatura en Administración de Empresas', 3, 'activo');

-- Inserción de Periodos Académicos
INSERT INTO periodos_academicos (id_periodo, nombre_periodo, fecha_inicio, fecha_fin, estado) VALUES
(1, 'Periodo 2026-I', '2026-01-15', '2026-05-15', 'activo');

-- Inserción de Materias de Prueba
INSERT INTO materias (id_materia, codigo, nombre, descripcion, creditos, periodo, tipo_materia, id_facultad, id_carrera, id_requisito, estado) VALUES
(1, 'MAT101', 'Álgebra Lineal', 'Estudio de matrices, vectores y espacios vectoriales.', 4, 1, 'institucional', NULL, NULL, NULL, 'activa'),
(2, 'FIS101', 'Física General', 'Estudio de la mecánica y cinemática clásica.', 4, 2, 'facultad', 1, NULL, 1, 'activa'),
(3, 'SIS201', 'Programación Orientada a Objetos', 'Programación avanzada en Java e implementación de patrones de diseño.', 4, 2, 'carrera', 1, 1, NULL, 'activa'),
(4, 'SIS301', 'Estructuras de Datos', 'Implementación de listas, árboles y grafos.', 4, 3, 'carrera', 1, 1, 3, 'activa');

-- Inserción del Director Ramos (Contraseña: '123456' encriptada)
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado) VALUES
(15, 'Director Ramos', 'ramos11@gmail.com', '$2y$10$w0d1gB4.yXJ4x3mYc40qTOrC.527p0aG27/N3fS3q0nfeE9K9W94G', 1, 'activo');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(15, 1);

-- Inserción de Juan Delarca (Coordinador de Ingeniería, Contraseña: '123456' encriptada)
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado, titulo) VALUES
(13, 'Juan Delarca', 'delarca@gmail.com', '$2y$10$w0d1gB4.yXJ4x3mYc40qTOrC.527p0aG27/N3fS3q0nfeE9K9W94G', 4, 'activo', 'Ingeniero de Software y Doctor en Computación');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(13, 4);

-- Vincular a Juan Delarca como Coordinador de la Facultad de Ingeniería (id_facultad = 1)
INSERT INTO coordinadores (id_usuario, id_facultad) VALUES
(13, 1);

-- Inserción de un Maestro de Prueba (Contraseña: '123456' encriptada)
INSERT INTO usuarios (id_usuario, nombre, correo, password, id_rol, estado, titulo) VALUES
(14, 'Carlos Fuentes', 'cfuentes@gmail.com', '$2y$10$w0d1gB4.yXJ4x3mYc40qTOrC.527p0aG27/N3fS3q0nfeE9K9W94G', 2, 'activo', 'Licenciado en Matemáticas Puras');

INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
(14, 2);

INSERT INTO maestros (id_usuario, numero_empleado, telefono) VALUES
(14, 'EMP-1400', '9933-2211');
