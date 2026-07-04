<?php
require_once __DIR__ . '/src/dao/Dao.php';
require_once __DIR__ . '/src/dao/Table.php';

class MigrarRequisitos extends \Dao\Table {
    public static function ejecutar() {
        try {
            // 1. Agregar columna id_requisito
            $sql1 = "ALTER TABLE materias ADD COLUMN id_requisito INT(11) NULL DEFAULT NULL AFTER id_facultad";
            self::executeNonQuery($sql1, []);
            echo "Columna id_requisito agregada.\n";
            
            // 2. Agregar foreign key
            $sql2 = "ALTER TABLE materias ADD CONSTRAINT fk_materia_requisito FOREIGN KEY (id_requisito) REFERENCES materias(id_materia) ON DELETE SET NULL";
            self::executeNonQuery($sql2, []);
            echo "Llave foranea agregada.\n";
            
        } catch (Exception $e) {
            echo "Error: " . $e->getMessage() . "\n";
            // Ignore duplicate column errors
            if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
                echo "La columna ya existe. Continuando...\n";
            }
        }
    }
}

MigrarRequisitos::ejecutar();
