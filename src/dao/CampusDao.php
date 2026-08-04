<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class CampusDao extends Table
{
    public static function obtenerCampuses($incluirInactivos = false, $limit = null, $offset = null)
    {
        $sqlstr = "SELECT id_campus, nombre_campus, departamento, estado 
                   FROM campus";
        if (!$incluirInactivos) {
            $sqlstr .= " WHERE estado = 'activo'";
        }
        $sqlstr .= " ORDER BY nombre_campus ASC";
        if ($limit !== null && $offset !== null) {
            $sqlstr .= " LIMIT " . intval($limit) . " OFFSET " . intval($offset);
        }
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerTotalCampuses($incluirInactivos = false)
    {
        $sqlstr = "SELECT COUNT(*) AS total FROM campus";
        if (!$incluirInactivos) {
            $sqlstr .= " WHERE estado = 'activo'";
        }
        $res = self::obtenerUnRegistro($sqlstr);
        return intval($res["total"] ?? 0);
    }

    public static function obtenerCampusPorId($idCampus)
    {
        $sqlstr = "SELECT id_campus, nombre_campus, departamento, estado 
                   FROM campus 
                   WHERE id_campus = :id_campus";
        return self::obtenerUnRegistro($sqlstr, ["id_campus" => intval($idCampus)]);
    }

    public static function registrarCampus($nombreCampus, $departamento)
    {
        $sqlstr = "INSERT INTO campus (nombre_campus, departamento, estado) 
                   VALUES (:nombre_campus, :departamento, 'activo')";
        return self::executeNonQuery($sqlstr, [
            "nombre_campus" => $nombreCampus,
            "departamento" => $departamento
        ]);
    }

    public static function actualizarCampus($idCampus, $nombreCampus, $departamento, $estado)
    {
        $sqlstr = "UPDATE campus 
                   SET nombre_campus = :nombre_campus, departamento = :departamento, estado = :estado 
                   WHERE id_campus = :id_campus";
        return self::executeNonQuery($sqlstr, [
            "id_campus" => intval($idCampus),
            "nombre_campus" => $nombreCampus,
            "departamento" => $departamento,
            "estado" => $estado
        ]);
    }
}
