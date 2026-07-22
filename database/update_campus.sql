-- =========================================================================
-- ACTUALIZACIÓN DE BASE DE DATOS - GESTIÓN DE CAMPUS / SEDES
-- =========================================================================

-- 1. Crear tabla campus
CREATE TABLE IF NOT EXISTS campus (
    id_campus INT AUTO_INCREMENT PRIMARY KEY,
    nombre_campus VARCHAR(100) NOT NULL UNIQUE,
    departamento VARCHAR(100) NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Insertar campus semilla
INSERT INTO campus (id_campus, nombre_campus, departamento, estado) VALUES
(1, 'Campus Central - Tegucigalpa', 'Francisco Morazán', 'activo'),
(2, 'Campus Valle de Sula - San Pedro Sula', 'Cortés', 'activo'),
(3, 'Campus La Ceiba - La Ceiba', 'Atlántida', 'activo')
ON DUPLICATE KEY UPDATE nombre_campus=VALUES(nombre_campus), departamento=VALUES(departamento), estado=VALUES(estado);

-- 3. Modificar estudiantes para agregar id_campus
ALTER TABLE estudiantes ADD COLUMN id_campus INT NULL;
ALTER TABLE estudiantes ADD CONSTRAINT fk_estudiantes_campus FOREIGN KEY (id_campus) REFERENCES campus(id_campus) ON DELETE SET NULL;

-- 4. Modificar maestros para agregar id_campus
ALTER TABLE maestros ADD COLUMN id_campus INT NULL;
ALTER TABLE maestros ADD CONSTRAINT fk_maestros_campus FOREIGN KEY (id_campus) REFERENCES campus(id_campus) ON DELETE SET NULL;

-- 5. Modificar coordinadores para agregar id_campus
ALTER TABLE coordinadores ADD COLUMN id_campus INT NULL;
ALTER TABLE coordinadores ADD CONSTRAINT fk_coordinadores_campus FOREIGN KEY (id_campus) REFERENCES campus(id_campus) ON DELETE SET NULL;

-- 6. Asignar campus predeterminado (id_campus = 1) a los registros existentes para mantener la consistencia
UPDATE estudiantes SET id_campus = 1 WHERE id_campus IS NULL;
UPDATE maestros SET id_campus = 1 WHERE id_campus IS NULL;
UPDATE coordinadores SET id_campus = 1 WHERE id_campus IS NULL;
