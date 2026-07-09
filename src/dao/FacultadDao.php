<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class FacultadDao extends Table
{
    /**
     * Obtener todas las facultades junto con el conteo de sus carreras adscritas
     */
    public static function obtenerTodas()
    {
        $sqlstr = "SELECT f.id_facultad, f.nombre_facultad,
                          (SELECT COUNT(*) FROM carreras c WHERE c.id_facultad = f.id_facultad AND LOWER(c.estado) IN ('activa', 'activo')) as total_carreras
                   FROM facultades f
                   ORDER BY f.nombre_facultad ASC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerPorId($idFacultad)
    {
        $sqlstr = "SELECT id_facultad, nombre_facultad FROM facultades WHERE id_facultad = :id";
        return self::obtenerUnRegistro($sqlstr, ["id" => $idFacultad]);
    }

    public static function crear($nombreFacultad)
    {
        $sqlstr = "INSERT INTO facultades (nombre_facultad) VALUES (:nombre)";
        return self::executeNonQuery($sqlstr, ["nombre" => $nombreFacultad]);
    }

    public static function actualizar($idFacultad, $nombreFacultad)
    {
        $sqlstr = "UPDATE facultades SET nombre_facultad = :nombre WHERE id_facultad = :id";
        return self::executeNonQuery($sqlstr, [
            "id" => $idFacultad,
            "nombre" => $nombreFacultad
        ]);
    }

    /**
     * Verifica si una facultad con el mismo nombre ya existe.
     * $excluirId se usa al momento de editar para no marcar la facultad actual como duplicada.
     */
    public static function existeNombre($nombreFacultad, $excluirId = null)
    {
        $sqlstr = "SELECT COUNT(*) as count FROM facultades WHERE nombre_facultad = :nombre";
        $params = ["nombre" => $nombreFacultad];
        
        if ($excluirId !== null) {
            $sqlstr .= " AND id_facultad <> :id";
            $params["id"] = $excluirId;
        }
        
        $registro = self::obtenerUnRegistro($sqlstr, $params);
        return intval($registro["count"] ?? 0) > 0;
    }
}
?>
