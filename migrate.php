<?php
require_once __DIR__ . '/src/dao/Dao.php';
require_once __DIR__ . '/src/dao/Table.php';

use Dao\Table;

class Migrador extends Table {
    public static function run() {
        echo "Iniciando migraciones de base de datos...\n";

        // 1. Materias: Quitar maestro (Drop FK dinámico)
        try {
            $sqlFk = "SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_NAME = 'materias' AND COLUMN_NAME = 'id_maestro' AND CONSTRAINT_SCHEMA = 'seguimiento_academico' AND CONSTRAINT_NAME != 'PRIMARY';";
            $fks = self::obtenerRegistros($sqlFk, []);
            foreach ($fks as $fk) {
                $fkName = $fk['CONSTRAINT_NAME'];
                self::executeNonQuery("ALTER TABLE materias DROP FOREIGN KEY {$fkName};", []);
                echo "1. FK {$fkName} removida\n";
            }
            $sql1 = "ALTER TABLE materias DROP COLUMN id_maestro;";
            self::executeNonQuery($sql1, []);
            echo "1. id_maestro removido de materias\n";
        } catch (Exception $e) {
            echo "1. id_maestro en materias ya no existe o error: " . $e->getMessage() . "\n";
        }

    // 2. Secciones: Agregar maestro y periodo
    try {
        $sql2 = "ALTER TABLE secciones ADD COLUMN id_maestro INT NULL;";
        self::executeNonQuery($sql2, []);
        echo "2. id_maestro agregado a secciones\n";
    } catch (Exception $e) {
        echo "2. id_maestro en secciones ya existia o error: " . $e->getMessage() . "\n";
    }

    try {
        $sql3 = "ALTER TABLE secciones ADD COLUMN id_periodo INT NULL;";
        self::executeNonQuery($sql3, []);
        echo "3. id_periodo agregado a secciones\n";
    } catch (Exception $e) {
        echo "3. id_periodo en secciones ya existia o error: " . $e->getMessage() . "\n";
    }
    
    try {
        $sql4 = "ALTER TABLE secciones ADD CONSTRAINT fk_seccion_maestro FOREIGN KEY (id_maestro) REFERENCES maestros(id_maestro) ON DELETE SET NULL;";
        self::executeNonQuery($sql4, []);
        echo "4. FK id_maestro en secciones agregada\n";
    } catch (Exception $e) {
         echo "4. FK id_maestro en secciones ya existia o fallo: " . $e->getMessage() . "\n";
    }

    try {
        $sql5 = "ALTER TABLE secciones ADD CONSTRAINT fk_seccion_periodo FOREIGN KEY (id_periodo) REFERENCES periodos_academicos(id_periodo) ON DELETE CASCADE;";
        self::executeNonQuery($sql5, []);
        echo "5. FK id_periodo en secciones agregada\n";
    } catch (Exception $e) {
         echo "5. FK id_periodo en secciones ya existia o fallo: " . $e->getMessage() . "\n";
    }

    // 3. Crear tabla Coordinadores
    $sql6 = "CREATE TABLE IF NOT EXISTS coordinadores (
        id_coordinador INT AUTO_INCREMENT PRIMARY KEY,
        id_usuario INT NOT NULL,
        id_carrera INT NOT NULL,
        fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
        FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON DELETE CASCADE,
        UNIQUE KEY uq_usuario_carrera (id_usuario, id_carrera)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;";
    self::executeNonQuery($sql6, []);
    echo "6. Tabla coordinadores verificada/creada\n";

    // 4. Asegurar que `materias` tenga `tipo_materia` y `id_facultad`
    try {
        $sql7 = "ALTER TABLE materias ADD COLUMN tipo_materia ENUM('institucional', 'facultad', 'carrera') DEFAULT 'institucional';";
        self::executeNonQuery($sql7, []);
        echo "7. Columna tipo_materia en materias agregada\n";
    } catch (Exception $e) {
        echo "7. Columna tipo_materia en materias ya existia o error: " . $e->getMessage() . "\n";
    }

    try {
        $sql8 = "ALTER TABLE materias ADD COLUMN id_facultad INT NULL;";
        self::executeNonQuery($sql8, []);
        echo "8. Columna id_facultad en materias agregada\n";
    } catch (Exception $e) {
        echo "8. Columna id_facultad en materias ya existia o error: " . $e->getMessage() . "\n";
    }

    try {
        $sql9 = "ALTER TABLE materias ADD CONSTRAINT fk_materia_facultad FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad) ON DELETE SET NULL;";
        self::executeNonQuery($sql9, []);
        echo "9. FK id_facultad en materias agregada\n";
    } catch (Exception $e) {
         echo "9. FK id_facultad ya existia o fallo: " . $e->getMessage() . "\n";
    }

    echo "Migraciones completadas con éxito.\n";
    }
}

try {
    Migrador::run();
} catch (Exception $e) {
    echo "Error general: " . $e->getMessage() . "\n";
}
