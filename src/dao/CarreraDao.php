<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class CarreraDao extends Table
{
    public static function obtenerCarreras($incluirInactivas = false, $id_facultad = null)
    {
        $sqlstr = "SELECT c.id_carrera, c.nombre_carrera, c.estado, c.id_facultad,
                          (SELECT COUNT(*) FROM materias m
                           WHERE m.tipo_materia = 'institucional'
                              OR (m.tipo_materia = 'facultad'    AND m.id_facultad = c.id_facultad)
                              OR (m.tipo_materia = 'carrera'     AND m.id_carrera  = c.id_carrera)
                          ) as total_materias
                   FROM carreras c";
        if ($incluirInactivas) {
            $sqlstr .= " WHERE c.estado = 'inactiva'";
        } else {
            $sqlstr .= " WHERE c.estado = 'activa'";
        }
        
        $params = [];
        if ($id_facultad !== null) {
            $sqlstr .= " AND c.id_facultad = :id_facultad";
            $params['id_facultad'] = $id_facultad;
        }
        
        $sqlstr .= " ORDER BY c.nombre_carrera ASC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerCarrerasParaRegistro()
    {
        $sqlstr = "SELECT c.id_carrera, c.nombre_carrera 
                   FROM carreras c
                   WHERE c.estado = 'activa'
                     AND (SELECT COUNT(*) FROM materias m WHERE m.id_carrera = c.id_carrera AND m.tipo_materia = 'carrera' AND m.estado = 'activa') > 0
                   ORDER BY c.nombre_carrera ASC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerCarreraPorId($idCarrera)
    {
        $sqlstr = "SELECT id_carrera, nombre_carrera, estado, id_facultad FROM carreras WHERE id_carrera = :id_carrera";
        return self::obtenerUnRegistro($sqlstr, ["id_carrera" => $idCarrera]);
    }

    public static function registrarCarrera($nombreCarrera, $id_facultad = null)
    {
        $sqlstr = "INSERT INTO carreras (nombre_carrera, estado, id_facultad) VALUES (:nombre_carrera, 'activa', :id_facultad)";
        return self::executeNonQuery($sqlstr, [
            "nombre_carrera" => $nombreCarrera,
            "id_facultad" => $id_facultad
        ]);
    }

    public static function actualizarCarrera($idCarrera, $nombreCarrera, $estado, $id_facultad = null)
    {
        $sqlstr = "UPDATE carreras SET nombre_carrera = :nombre_carrera, estado = :estado, id_facultad = :id_facultad WHERE id_carrera = :id_carrera";
        return self::executeNonQuery($sqlstr, [
            "id_carrera" => $idCarrera,
            "nombre_carrera" => $nombreCarrera,
            "estado" => $estado,
            "id_facultad" => $id_facultad
        ]);
    }

    public static function inactivarCarrera($idCarrera)
    {
        $sqlstr = "UPDATE carreras SET estado = 'inactiva' WHERE id_carrera = :id_carrera";
        return self::executeNonQuery($sqlstr, ["id_carrera" => $idCarrera]);
    }

    public static function activarCarrera($idCarrera)
    {
        $sqlstr = "UPDATE carreras SET estado = 'activa' WHERE id_carrera = :id_carrera";
        return self::executeNonQuery($sqlstr, ["id_carrera" => $idCarrera]);
    }

    public static function existeNombreCarrera($nombreCarrera, $excluirId = null)
    {
        $sqlstr = "SELECT COUNT(*) as count FROM carreras WHERE nombre_carrera = :nombre_carrera";
        $params = ["nombre_carrera" => $nombreCarrera];
        
        if ($excluirId !== null) {
            $sqlstr .= " AND id_carrera <> :id_carrera";
            $params["id_carrera"] = $excluirId;
        }
        
        $registro = self::obtenerUnRegistro($sqlstr, $params);
        return intval($registro["count"] ?? 0) > 0;
    }
}
