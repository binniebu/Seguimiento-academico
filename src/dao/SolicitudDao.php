<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class SolicitudDao extends Table
{
    public static function obtenerSolicitudesPendientes()
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono, e.estado as estado_estudiante, cp.nombre_campus AS campus
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   LEFT JOIN campus cp ON e.id_campus = cp.id_campus
                   WHERE u.estado = 'pendiente'
                   ORDER BY u.id_usuario DESC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerSolicitudesPendientesPorFacultad($id_facultad, $id_campus = null)
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono, e.estado as estado_estudiante, cp.nombre_campus AS campus
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   LEFT JOIN campus cp ON e.id_campus = cp.id_campus
                   INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   WHERE u.estado = 'pendiente'
                     AND c.id_facultad = :id_facultad";
        $params = ["id_facultad" => $id_facultad];
        if ($id_campus !== null) {
            $sqlstr .= " AND e.id_campus = :id_campus";
            $params["id_campus"] = intval($id_campus);
        }
        $sqlstr .= " ORDER BY u.id_usuario DESC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerSolicitudPorId($idUsuario)
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono, e.estado as estado_estudiante
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   WHERE u.id_usuario = :id_usuario AND u.estado = 'pendiente'";
        return self::obtenerUnRegistro($sqlstr, ["id_usuario" => $idUsuario]);
    }

    public static function obtenerSolicitudPorIdYFacultad($idUsuario, $id_facultad)
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono, e.estado as estado_estudiante
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   WHERE u.id_usuario = :id_usuario
                     AND u.estado = 'pendiente'
                     AND c.id_facultad = :id_facultad";
        return self::obtenerUnRegistro($sqlstr, [
            "id_usuario" => $idUsuario,
            "id_facultad" => $id_facultad
        ]);
    }

    public static function registrarPreRegistro($nombre, $correo, $password, $dni, $carrera, $telefono, $documentoDni, $documentoTitulo, $idCampus = null)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            $sqlUsuario = "INSERT INTO usuarios (nombre, correo, password, id_rol, estado, documento_dni, documento_titulo)
                           VALUES (:nombre, :correo, :password, 3, 'pendiente', :documento_dni, :documento_titulo)";
            $stmtUsuario = $conn->prepare($sqlUsuario);
            $stmtUsuario->execute([
                "nombre" => $nombre,
                "correo" => $correo,
                "password" => password_hash($password, PASSWORD_DEFAULT),
                "documento_dni" => $documentoDni,
                "documento_titulo" => $documentoTitulo
            ]);

            $idUsuario = $conn->lastInsertId();

            $sqlEstudiante = "INSERT INTO estudiantes (id_usuario, cuenta, carrera, telefono, estado, id_campus)
                              VALUES (:id_usuario, :cuenta, :carrera, :telefono, 'pendiente', :id_campus)";
            $stmtEstudiante = $conn->prepare($sqlEstudiante);
            $stmtEstudiante->execute([
                "id_usuario" => $idUsuario,
                "cuenta" => $dni,
                "carrera" => $carrera,
                "telefono" => $telefono,
                "id_campus" => $idCampus !== null ? intval($idCampus) : null
            ]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            return false;
        }
    }

    public static function aprobarSolicitud($idUsuario)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            $sqlstr1 = "UPDATE usuarios SET estado = 'activo' WHERE id_usuario = :id_usuario AND estado = 'pendiente'";
            $stmt1 = $conn->prepare($sqlstr1);
            $stmt1->execute(["id_usuario" => $idUsuario]);

            $sqlstr2 = "INSERT IGNORE INTO usuarios_roles (id_usuario, id_rol) VALUES (:id_usuario, 3)";
            $stmt2 = $conn->prepare($sqlstr2);
            $stmt2->execute(["id_usuario" => $idUsuario]);

            $sqlstr3 = "UPDATE estudiantes SET estado = 'Admitido' WHERE id_usuario = :id_usuario";
            $stmt3 = $conn->prepare($sqlstr3);
            $stmt3->execute(["id_usuario" => $idUsuario]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            return false;
        }
    }

    public static function rechazarSolicitud($idUsuario)
    {
        $conn = self::getConn();
        try {
            $solicitud = self::obtenerSolicitudPorId($idUsuario);
            if (!$solicitud) {
                return false;
            }

            $conn->beginTransaction();

            $sqlEst = "DELETE FROM estudiantes WHERE id_usuario = :id_usuario";
            $stmtEst = $conn->prepare($sqlEst);
            $stmtEst->execute(["id_usuario" => $idUsuario]);

            $sqlRoles = "DELETE FROM usuarios_roles WHERE id_usuario = :id_usuario";
            $stmtRoles = $conn->prepare($sqlRoles);
            $stmtRoles->execute(["id_usuario" => $idUsuario]);

            $sqlUsr = "DELETE FROM usuarios WHERE id_usuario = :id_usuario AND estado = 'pendiente'";
            $stmtUsr = $conn->prepare($sqlUsr);
            $stmtUsr->execute(["id_usuario" => $idUsuario]);

            $conn->commit();

            self::eliminarArchivoSubido($solicitud["documento_dni"] ?? "");
            self::eliminarArchivoSubido($solicitud["documento_titulo"] ?? "");

            return true;
        } catch (\Throwable $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            return false;
        }
    }

    private static function eliminarArchivoSubido(?string $rutaRelativa): bool
    {
        if (empty($rutaRelativa)) {
            return true;
        }

        $rutaRelativa = ltrim(str_replace("\\", "/", $rutaRelativa), "/");
        $raizProyecto = realpath(__DIR__ . "/../..");

        if (!$raizProyecto) {
            return false;
        }

        $directorioUploads = realpath($raizProyecto . "/public/uploads");
        if (!$directorioUploads) {
            return false;
        }

        $rutaArchivo = realpath($raizProyecto . "/" . $rutaRelativa);
        if (!$rutaArchivo) {
            return true;
        }

        $rutaArchivoNormalizada = strtolower(str_replace("\\", "/", $rutaArchivo));
        $uploadsNormalizado = strtolower(str_replace("\\", "/", $directorioUploads));

        if (strpos($rutaArchivoNormalizada, $uploadsNormalizado . "/") !== 0) {
            return false;
        }

        return is_file($rutaArchivo) ? unlink($rutaArchivo) : true;
    }
}

