-- Migracion: reportes PDF, multiples carreras por estudiante y correcciones de notas

CREATE TABLE IF NOT EXISTS estudiante_carreras (
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

INSERT IGNORE INTO estudiante_carreras (id_estudiante, id_carrera, estado, es_principal)
SELECT e.id_estudiante, c.id_carrera, 'activa', 1
FROM estudiantes e
INNER JOIN carreras c
    ON c.nombre_carrera = e.carrera OR CAST(c.id_carrera AS CHAR) = CAST(e.carrera AS CHAR);

CREATE TABLE IF NOT EXISTS solicitudes_correccion_notas (
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

ALTER TABLE calificaciones ADD COLUMN IF NOT EXISTS corregida TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE calificaciones ADD COLUMN IF NOT EXISTS ultima_correccion TIMESTAMP NULL;

ALTER TABLE maestros ADD COLUMN IF NOT EXISTS id_facultad INT NULL;
ALTER TABLE maestros ADD COLUMN IF NOT EXISTS id_carrera INT NULL;
