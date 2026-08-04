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

        $facultadCondicion = "";
        $carreraCondicion = "";
        $campusCondicion = "";
        $params = array(
            "buscar" => "%" . $buscar . "%",
            "buscar_exacto" => $buscar
        );

        if ($idFacultad !== null) {
            $facultadCondicion = " AND (
                EXISTS (
                    SELECT 1 FROM estudiante_carreras ecf
                    INNER JOIN carreras cf ON ecf.id_carrera = cf.id_carrera
                    WHERE ecf.id_estudiante = e.id_estudiante
                      AND ecf.estado = 'activa'
                      AND cf.id_facultad = :id_facultad
                )
                OR (
                    NOT EXISTS (SELECT 1 FROM estudiante_carreras ecf3 WHERE ecf3.id_estudiante = e.id_estudiante AND ecf3.estado = 'activa')
                    AND EXISTS (
                        SELECT 1 FROM carreras cf2 
                        WHERE (e.carrera = cf2.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(cf2.id_carrera AS CHAR))
                          AND cf2.id_facultad = :id_facultad
                    )
                )
            ) ";
            $params["id_facultad"] = $idFacultad;
        }

        if ($idCarrera !== null && $idCarrera !== "") {
            $carreraCondicion = " AND (
                EXISTS (
                    SELECT 1 FROM estudiante_carreras ec2 
                    WHERE ec2.id_estudiante = e.id_estudiante 
                      AND ec2.id_carrera = :id_carrera 
                      AND ec2.estado = 'activa'
                )
                OR (
                    NOT EXISTS (SELECT 1 FROM estudiante_carreras ec3 WHERE ec3.id_estudiante = e.id_estudiante AND ec3.estado = 'activa')
                    AND (
                        e.carrera = CAST(:id_carrera AS CHAR)
                        OR EXISTS (SELECT 1 FROM carreras c2 WHERE c2.id_carrera = :id_carrera AND c2.nombre_carrera = e.carrera)
                    )
                )
            ) ";
            $params["id_carrera"] = intval($idCarrera);
        }

        if ($idCampus !== null) {
            $campusCondicion = " AND e.id_campus = :id_campus ";
            $params["id_campus"] = intval($idCampus);
        }

        $carreraSelectExpr = "";
        if ($idCarrera !== null && $idCarrera !== "") {
            $carreraSelectExpr = "(SELECT nombre_carrera FROM carreras WHERE id_carrera = :id_carrera_display) AS carrera";
            $params["id_carrera_display"] = intval($idCarrera);
        } else {
            $carreraSelectExpr = "GROUP_CONCAT(DISTINCT COALESCE(cr.nombre_carrera, e.carrera) SEPARATOR ' / ') AS carrera";
        }

        $sqlstr = "SELECT 
                        e.id_estudiante,
                        e.id_usuario,
                        e.cuenta,
                        e.telefono,
                        u.nombre,
                        u.correo,
                        e.estado,
                        e.id_campus,
                        cp.nombre_campus AS campus,
                        $carreraSelectExpr
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   LEFT JOIN campus cp ON e.id_campus = cp.id_campus
                   LEFT JOIN estudiante_carreras ec ON e.id_estudiante = ec.id_estudiante AND ec.estado = 'activa'
                   LEFT JOIN carreras cr ON ec.id_carrera = cr.id_carrera
                   WHERE (u.nombre LIKE :buscar
                      OR u.correo LIKE :buscar
                      OR e.cuenta LIKE :buscar
                      OR CAST(e.id_estudiante AS CHAR) = :buscar_exacto)
                      AND $estadoCondicion
                      $facultadCondicion
                      $carreraCondicion
                      $campusCondicion
                   GROUP BY 
                        e.id_estudiante,
                        e.id_usuario,
                        e.cuenta,
                        e.telefono,
                        u.nombre,
                        u.correo,
                        e.estado,
                        e.id_campus,
                        cp.nombre_campus
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

        $facultadCondicion = "";
        $carreraCondicion = "";
        $campusCondicion = "";
        $params = array(
            "buscar" => "%" . $buscar . "%",
            "buscar_exacto" => $buscar
        );

        if ($idFacultad !== null) {
            $facultadCondicion = " AND (
                EXISTS (
                    SELECT 1 FROM estudiante_carreras ecf
                    INNER JOIN carreras cf ON ecf.id_carrera = cf.id_carrera
                    WHERE ecf.id_estudiante = e.id_estudiante
                      AND ecf.estado = 'activa'
                      AND cf.id_facultad = :id_facultad
                )
                OR (
                    NOT EXISTS (SELECT 1 FROM estudiante_carreras ecf3 WHERE ecf3.id_estudiante = e.id_estudiante AND ecf3.estado = 'activa')
                    AND EXISTS (
                        SELECT 1 FROM carreras cf2 
                        WHERE (e.carrera = cf2.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(cf2.id_carrera AS CHAR))
                          AND cf2.id_facultad = :id_facultad
                    )
                )
            ) ";
            $params["id_facultad"] = $idFacultad;
        }

        if ($idCarrera !== null && $idCarrera !== "") {
            $carreraCondicion = " AND (
                EXISTS (
                    SELECT 1 FROM estudiante_carreras ec2 
                    WHERE ec2.id_estudiante = e.id_estudiante 
                      AND ec2.id_carrera = :id_carrera 
                      AND ec2.estado = 'activa'
                )
                OR (
                    NOT EXISTS (SELECT 1 FROM estudiante_carreras ec3 WHERE ec3.id_estudiante = e.id_estudiante AND ec3.estado = 'activa')
                    AND (
                        e.carrera = CAST(:id_carrera AS CHAR)
                        OR EXISTS (SELECT 1 FROM carreras c2 WHERE c2.id_carrera = :id_carrera AND c2.nombre_carrera = e.carrera)
                    )
                )
            ) ";
            $params["id_carrera"] = intval($idCarrera);
        }

        if ($idCampus !== null) {
            $campusCondicion = " AND e.id_campus = :id_campus ";
            $params["id_campus"] = intval($idCampus);
        }

        $sqlstr = "SELECT COUNT(*) as total
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
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
        $sqlstr = "SELECT 0 AS id_estudiante, id_usuario 
                   FROM usuarios 
                   WHERE documento_dni = :cuenta
                   UNION
                   SELECT id_estudiante, id_usuario 
                   FROM estudiantes 
                   WHERE cuenta = :cuenta";

        return self::obtenerUnRegistro($sqlstr, array(
            "cuenta" => $cuenta
        ));
    }

    public static function obtenerEstudiantePorCorreo($correo)
    {
        $sqlstr = "SELECT e.*, u.nombre, u.correo
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   WHERE u.correo = :correo
                   LIMIT 1";
        return self::obtenerUnRegistro($sqlstr, ["correo" => $correo]);
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

            self::executeNonQuery(
                "INSERT IGNORE INTO usuarios_roles (id_usuario, id_rol) VALUES (:id_usuario, 3)",
                ["id_usuario" => $idUsuario],
                $conn
            );

            $sqlEstudiante = "INSERT INTO estudiantes
                            (id_usuario, cuenta, carrera, telefono)
                           VALUES 
                            (:id_usuario, :cuenta, :carrera, :telefono)";

            $insertado = self::executeNonQuery($sqlEstudiante, array(
                "id_usuario" => $idUsuario,
                "cuenta" => $cuenta,
                "carrera" => $carrera,
                "telefono" => $telefono
            ), $conn);

            if ($insertado) {
                self::sincronizarCarrerasEstudiante((int)$conn->lastInsertId(), [$carrera], $conn);
            }

            return $insertado;

        } catch (PDOException $ex) {
            return false;
        }
    }

    public static function insertarEstudianteParaUsuarioExistente($idUsuario, $cuenta, $carrera, $telefono)
    {
        $conn = self::getConn();

        try {
            $sqlEstudiante = "INSERT INTO estudiantes
                            (id_usuario, cuenta, carrera, telefono, estado)
                           VALUES
                            (:id_usuario, :cuenta, :carrera, :telefono, 'activo')";

            $insertado = self::executeNonQuery($sqlEstudiante, array(
                "id_usuario" => intval($idUsuario),
                "cuenta" => $cuenta,
                "carrera" => $carrera,
                "telefono" => $telefono
            ), $conn);

            if ($insertado) {
                $idEstudiante = (int)$conn->lastInsertId();
                self::executeNonQuery(
                    "INSERT IGNORE INTO usuarios_roles (id_usuario, id_rol) VALUES (:id_usuario, 3)",
                    ["id_usuario" => intval($idUsuario)],
                    $conn
                );
                self::executeNonQuery(
                    "UPDATE usuarios SET id_rol = 3 WHERE id_usuario = :id_usuario AND id_rol NOT IN (1, 2, 4)",
                    ["id_usuario" => intval($idUsuario)],
                    $conn
                );
                self::sincronizarCarrerasEstudiante($idEstudiante, [$carrera], $conn);
            }

            return $insertado;
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

    public static function obtenerCarrerasEstudiante($idEstudiante)
    {
        $sqlstr = "SELECT ec.id_estudiante_carrera, ec.id_estudiante, ec.id_carrera,
                          ec.estado, ec.es_principal, c.nombre_carrera, c.id_facultad
                   FROM estudiante_carreras ec
                   INNER JOIN carreras c ON ec.id_carrera = c.id_carrera
                   WHERE ec.id_estudiante = :id_estudiante
                   ORDER BY ec.es_principal DESC, c.nombre_carrera ASC";
        return self::obtenerRegistros($sqlstr, ["id_estudiante" => intval($idEstudiante)]);
    }

    public static function sincronizarCarrerasEstudiante($idEstudiante, array $carreras, $conn = null)
    {
        $conn = $conn ?: self::getConn();
        $ids = [];

        foreach ($carreras as $carrera) {
            if ($carrera === "" || $carrera === null) {
                continue;
            }

            if (is_numeric($carrera)) {
                $row = self::obtenerUnRegistro(
                    "SELECT id_carrera, nombre_carrera FROM carreras WHERE id_carrera = :id LIMIT 1",
                    ["id" => intval($carrera)],
                    $conn
                );
            } else {
                $row = self::obtenerUnRegistro(
                    "SELECT id_carrera, nombre_carrera FROM carreras WHERE nombre_carrera = :nombre LIMIT 1",
                    ["nombre" => $carrera],
                    $conn
                );
            }

            if ($row) {
                $ids[(int)$row["id_carrera"]] = $row["nombre_carrera"];
            }
        }

        if (empty($ids)) {
            return false;
        }

        self::executeNonQuery(
            "UPDATE estudiante_carreras SET estado = 'inactiva', es_principal = 0 WHERE id_estudiante = :id_estudiante",
            ["id_estudiante" => intval($idEstudiante)],
            $conn
        );

        $principal = true;
        foreach ($ids as $idCarrera => $nombreCarrera) {
            self::executeNonQuery(
                "INSERT INTO estudiante_carreras (id_estudiante, id_carrera, estado, es_principal)
                 VALUES (:id_estudiante, :id_carrera, 'activa', :principal)
                 ON DUPLICATE KEY UPDATE estado = 'activa', es_principal = VALUES(es_principal)",
                [
                    "id_estudiante" => intval($idEstudiante),
                    "id_carrera" => intval($idCarrera),
                    "principal" => $principal ? 1 : 0
                ],
                $conn
            );
            $principal = false;
        }

        $primeraCarrera = reset($ids);
        self::executeNonQuery(
            "UPDATE estudiantes SET carrera = :carrera WHERE id_estudiante = :id_estudiante",
            ["carrera" => $primeraCarrera, "id_estudiante" => intval($idEstudiante)],
            $conn
        );

        return true;
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
        $sqlstr = "SELECT c.id_carrera, c.id_facultad
                   FROM estudiantes e
                   INNER JOIN estudiante_carreras ec ON e.id_estudiante = ec.id_estudiante AND ec.estado = 'activa'
                   INNER JOIN carreras c ON ec.id_carrera = c.id_carrera
                   WHERE e.id_usuario = :id_usuario
                   ORDER BY ec.es_principal DESC, c.nombre_carrera ASC
                   LIMIT 1";
        $row = self::obtenerUnRegistro($sqlstr, ["id_usuario" => $id_usuario]);
        if ($row) {
            return $row;
        }

        // Fallback: esquema anterior donde estudiantes.carrera guarda nombre o id.
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
