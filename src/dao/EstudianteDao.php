<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

use PDOException;

class EstudianteDao extends Table
{
    public static function obtenerEstudiantes($buscar = "", $estadoFiltro = "activos", $limit = 10, $offset = 0, $idFacultad = null, $idCarrera = null, $idCampus = null)
    {
        if (is_bool($estadoFiltro)) {
            $estadoFiltro = $estadoFiltro ? "inactivos" : "activos";
        }

        if ($estadoFiltro === "inactivos") {
            $estadoCondicion = "LOWER(e.estado) = 'inactivo'";
        } elseif ($estadoFiltro === "graduados") {
            $estadoCondicion = "LOWER(e.estado) = 'graduado'";
        } else {
            $estadoCondicion = "LOWER(e.estado) IN ('activo', 'admitido')";
        }

        $facultadJoin = "";
        $facultadCondicion = "";
        $carreraCondicion = "";
        $campusCondicion = "";
        $params = array(
            "buscar" => "%" . $buscar . "%",
            "buscar_exacto" => $buscar
        );

        if ($idFacultad !== null || $idCarrera !== null) {
            $facultadJoin = " INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR)) ";
        }

        if ($idFacultad !== null) {
            $facultadCondicion = " AND c.id_facultad = :id_facultad ";
            $params["id_facultad"] = $idFacultad;
        }

        if ($idCarrera !== null && $idCarrera !== "") {
            $carreraCondicion = " AND c.id_carrera = :id_carrera ";
            $params["id_carrera"] = intval($idCarrera);
        }

        if ($idCampus !== null) {
            $campusCondicion = " AND e.id_campus = :id_campus ";
            $params["id_campus"] = intval($idCampus);
        }

        $sqlstr = "SELECT 
                        e.id_estudiante,
                        e.id_usuario,
                        e.cuenta,
                        e.carrera,
                        e.telefono,
                        u.nombre,
                        u.correo,
                        e.estado,
                        e.id_campus,
                        cp.nombre_campus AS campus
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   LEFT JOIN campus cp ON e.id_campus = cp.id_campus
                   $facultadJoin
                    WHERE (u.nombre LIKE :buscar
                       OR u.correo LIKE :buscar
                       OR e.cuenta LIKE :buscar
                       OR CAST(e.id_estudiante AS CHAR) = :buscar_exacto)
                       AND $estadoCondicion
                       $facultadCondicion
                       $carreraCondicion
                       $campusCondicion
                    ORDER BY e.id_estudiante DESC
                    LIMIT " . intval($limit) . " OFFSET " . intval($offset);

        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerTotalEstudiantes($buscar = "", $estadoFiltro = "activos", $idFacultad = null, $idCarrera = null, $idCampus = null)
    {
        if (is_bool($estadoFiltro)) {
            $estadoFiltro = $estadoFiltro ? "inactivos" : "activos";
        }

        if ($estadoFiltro === "inactivos") {
            $estadoCondicion = "LOWER(e.estado) = 'inactivo'";
        } elseif ($estadoFiltro === "graduados") {
            $estadoCondicion = "LOWER(e.estado) = 'graduado'";
        } else {
            $estadoCondicion = "LOWER(e.estado) IN ('activo', 'admitido')";
        }

        $facultadJoin = "";
        $facultadCondicion = "";
        $carreraCondicion = "";
        $campusCondicion = "";
        $params = array(
            "buscar" => "%" . $buscar . "%",
            "buscar_exacto" => $buscar
        );

        if ($idFacultad !== null || $idCarrera !== null) {
            $facultadJoin = " INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR)) ";
        }

        if ($idFacultad !== null) {
            $facultadCondicion = " AND c.id_facultad = :id_facultad ";
            $params["id_facultad"] = $idFacultad;
        }

        if ($idCarrera !== null && $idCarrera !== "") {
            $carreraCondicion = " AND c.id_carrera = :id_carrera ";
            $params["id_carrera"] = intval($idCarrera);
        }

        if ($idCampus !== null) {
            $campusCondicion = " AND e.id_campus = :id_campus ";
            $params["id_campus"] = intval($idCampus);
        }

        $sqlstr = "SELECT COUNT(*) as total
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   $facultadJoin
                   WHERE (u.nombre LIKE :buscar
                      OR u.correo LIKE :buscar
                      OR e.cuenta LIKE :buscar
                      OR CAST(e.id_estudiante AS CHAR) = :buscar_exacto)
                      AND $estadoCondicion
                      $facultadCondicion
                      $carreraCondicion
                      $campusCondicion";

        $res = self::obtenerUnRegistro($sqlstr, $params);
        return intval($res['total'] ?? 0);
    }

    public static function obtenerEstudiantePorId($id_estudiante)
    {
        $sqlstr = "SELECT 
                        e.id_estudiante,
                        e.id_usuario,
                        e.cuenta,
                        e.carrera,
                        e.telefono,
                        u.nombre,
                        u.correo,
                        u.estado,
                        e.id_campus,
                        cp.nombre_campus AS campus,
                        c.id_facultad,
                        c.id_carrera,
                        u.fecha_creacion
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   LEFT JOIN campus cp ON e.id_campus = cp.id_campus
                   LEFT JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   WHERE e.id_estudiante = :id_estudiante";

        return self::obtenerUnRegistro($sqlstr, array(
            "id_estudiante" => $id_estudiante
        ));
    }

    public static function existeCorreo($correo)
    {
        $sqlstr = "SELECT id_usuario 
                   FROM usuarios 
                   WHERE correo = :correo";

        return self::obtenerUnRegistro($sqlstr, array(
            "correo" => $correo
        ));
    }

    public static function existeCuenta($cuenta)
    {
        $sqlstr = "SELECT id_estudiante, id_usuario 
                   FROM estudiantes 
                   WHERE cuenta = :cuenta";

        return self::obtenerUnRegistro($sqlstr, array(
            "cuenta" => $cuenta
        ));
    }

    public static function insertarEstudiante($nombre, $correo, $password, $cuenta, $carrera, $telefono)
    {
        $conn = self::getConn();

        try {
            $sqlUsuario = "INSERT INTO usuarios 
                            (nombre, correo, password, id_rol, estado)
                           VALUES 
                            (:nombre, :correo, :password, 3, 'activo')";

            self::executeNonQuery($sqlUsuario, array(
                "nombre" => $nombre,
                "correo" => $correo,
                "password" => password_hash($password, PASSWORD_DEFAULT)
            ), $conn);

            $idUsuario = $conn->lastInsertId();

            $sqlEstudiante = "INSERT INTO estudiantes 
                            (id_usuario, cuenta, carrera, telefono)
                           VALUES 
                            (:id_usuario, :cuenta, :carrera, :telefono)";

            return self::executeNonQuery($sqlEstudiante, array(
                "id_usuario" => $idUsuario,
                "cuenta" => $cuenta,
                "carrera" => $carrera,
                "telefono" => $telefono
            ), $conn);

        } catch (PDOException $ex) {
            return false;
        }
    }

    public static function actualizarEstudiante($id_estudiante, $id_usuario, $nombre, $correo, $cuenta, $carrera, $telefono)
    {
        $conn = self::getConn();

        $sqlUsuario = "UPDATE usuarios
                       SET nombre = :nombre,
                           correo = :correo
                       WHERE id_usuario = :id_usuario";

        self::executeNonQuery($sqlUsuario, array(
            "nombre" => $nombre,
            "correo" => $correo,
            "id_usuario" => $id_usuario
        ), $conn);

        $sqlEstudiante = "UPDATE estudiantes
                       SET cuenta = :cuenta,
                           carrera = :carrera,
                           telefono = :telefono
                       WHERE id_estudiante = :id_estudiante";

        return self::executeNonQuery($sqlEstudiante, array(
            "cuenta" => $cuenta,
            "carrera" => $carrera,
            "telefono" => $telefono,
            "id_estudiante" => $id_estudiante
        ), $conn);
    }

    public static function eliminarEstudiante($id_estudiante, $id_usuario)
    {
        $conn = self::getConn();

        $sqlEstudiante = "UPDATE estudiantes 
                          SET estado = 'inactivo' 
                          WHERE id_estudiante = :id_estudiante";

        self::executeNonQuery($sqlEstudiante, array(
            "id_estudiante" => $id_estudiante
        ), $conn);

        $sqlUsuario = "UPDATE usuarios 
                       SET estado = 'inactivo' 
                       WHERE id_usuario = :id_usuario";

        return self::executeNonQuery($sqlUsuario, array(
            "id_usuario" => $id_usuario
        ), $conn);
    }
    public static function activarEstudiante($id_estudiante, $id_usuario)
    {
        $conn = self::getConn();

        $sqlEstudiante = "UPDATE estudiantes 
                          SET estado = 'activo' 
                          WHERE id_estudiante = :id_estudiante";

        self::executeNonQuery($sqlEstudiante, array(
            "id_estudiante" => $id_estudiante
        ), $conn);

        $sqlUsuario = "UPDATE usuarios 
                       SET estado = 'activo' 
                       WHERE id_usuario = :id_usuario";

        return self::executeNonQuery($sqlUsuario, array(
            "id_usuario" => $id_usuario
        ), $conn);
    }
    public static function actualizarCarreraPorCorreo($correo, $carrera)
{
    $sqlstr = "
        UPDATE estudiantes e
        INNER JOIN usuarios u
            ON e.id_usuario = u.id_usuario
        SET e.carrera = :carrera
        WHERE u.correo = :correo
    ";

    $params = array(
        "correo" => $correo,
        "carrera" => $carrera
    );

    return self::executeNonQuery($sqlstr, $params);
}

    public static function obtenerCarreraIdPorUsuario($id_usuario)
    {
        // Intenta resolver el id_carrera tanto si 'carrera' guarda el nombre como si guarda el id
        $sqlstr = "SELECT c.id_carrera, c.id_facultad
                   FROM estudiantes e
                   INNER JOIN carreras c
                          ON (c.nombre_carrera = e.carrera OR CAST(c.id_carrera AS CHAR) = CAST(e.carrera AS CHAR))
                   WHERE e.id_usuario = :id_usuario
                   LIMIT 1";
        return self::obtenerUnRegistro($sqlstr, ["id_usuario" => $id_usuario]);
    }
}
?>
