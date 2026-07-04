-- ==========================================
-- ESTRUCTURA SQL PARA ACTUALIZAR LA BASE DE DATOS
-- ==========================================

-- 1. Tabla de Carreras
CREATE TABLE IF NOT EXISTS `carreras` (
    `id_carrera` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre_carrera` VARCHAR(100) NOT NULL UNIQUE,
    `estado` VARCHAR(20) DEFAULT 'activa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insertar carreras base por defecto
INSERT IGNORE INTO `carreras` (`nombre_carrera`, `estado`) VALUES
('Ingeniería en Sistemas', 'activa'),
('Administración de Empresas', 'activa'),
('Derecho', 'activa'),
('Enfermería', 'activa'),
('Psicología', 'activa'),
('Contaduría', 'activa');

-- 2. Tabla de Periodos Académicos
CREATE TABLE IF NOT EXISTS `periodos_academicos` (
    `id_periodo` INT AUTO_INCREMENT PRIMARY KEY,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE NOT NULL,
    `periodo_num` INT NOT NULL, -- 1, 2 o 3
    `anio` INT NOT NULL,
    `matricula_inicio` DATE NOT NULL,
    `matricula_fin` DATE NOT NULL,
    `estado` VARCHAR(20) DEFAULT 'activo' -- activo, cerrado
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3. Modificaciones a la Tabla de Materias (Créditos)
ALTER TABLE `materias` ADD COLUMN `creditos` INT DEFAULT 3;

-- 4. Tabla de Secciones de Clases
CREATE TABLE IF NOT EXISTS `secciones` (
    `id_seccion` INT AUTO_INCREMENT PRIMARY KEY,
    `id_materia` INT NOT NULL,
    `codigo_seccion` VARCHAR(20) NOT NULL,
    `horario` VARCHAR(50) NOT NULL, -- Ej: '08:00 - 09:00'
    `dias_clase` VARCHAR(50) NOT NULL, -- Ej: 'Lu-Ju', 'Lu-Vi', 'Sábado'
    `aula` VARCHAR(50) NOT NULL,
    `cupo_maximo` INT NOT NULL,
    `cupo_actual` INT DEFAULT 0,
    FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id_materia`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 5. Tabla Intermedia para Soporte Multirrol (Usuario - Roles)
CREATE TABLE IF NOT EXISTS `usuarios_roles` (
    `id_usuario` INT NOT NULL,
    `id_rol` INT NOT NULL,
    PRIMARY KEY (`id_usuario`, `id_rol`),
    FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE,
    FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Migrar los roles existentes de los usuarios para no romper la compatibilidad
INSERT IGNORE INTO `usuarios_roles` (`id_usuario`, `id_rol`)
SELECT `id_usuario`, `id_rol` FROM `usuarios`;

-- 6. Modificaciones a la Tabla de Usuarios
-- Modificar el estado por defecto a 'pendiente' para pre-registro
ALTER TABLE `usuarios` MODIFY COLUMN `estado` VARCHAR(20) DEFAULT 'pendiente';
-- Agregar la columna para almacenar la ruta del expediente PDF cargado
ALTER TABLE `usuarios` ADD COLUMN `documento_pdf` VARCHAR(255) DEFAULT NULL;

-- 7. Modificaciones a la Tabla de Estudiantes (Fases de Estado)
ALTER TABLE `estudiantes` ADD COLUMN `estado` VARCHAR(30) DEFAULT 'Admitido';
