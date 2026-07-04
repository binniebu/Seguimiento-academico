<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class SolicitudDao extends Table
{
    public static function obtenerSolicitudesPendientes()
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   WHERE u.estado = 'pendiente' 
                   ORDER BY u.id_usuario DESC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerSolicitudesPendientesPorFacultad($id_facultad)
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   WHERE u.estado = 'pendiente' 
                     AND c.id_facultad = :id_facultad
                   ORDER BY u.id_usuario DESC";
        return self::obtenerRegistros($sqlstr, ["id_facultad" => $id_facultad]);
    }

    public static function obtenerSolicitudPorId($idUsuario)
    {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.documento_dni, u.documento_titulo, u.fecha_creacion,
                          e.cuenta as dni, e.carrera, e.telefono
                   FROM usuarios u
                   INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   WHERE u.id_usuario = :id_usuario AND u.estado = 'pendiente'";
        return self::obtenerUnRegistro($sqlstr, ["id_usuario" => $idUsuario]);
    }

    public static function registrarPreRegistro($nombre, $correo, $password, $dni, $carrera, $telefono, $documentoDni, $documentoTitulo)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            // 1. Crear registro en usuarios (estado pendiente)
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

            // 2. Crear registro en estudiantes (estado 'pendiente' y usando el DNI como número de cuenta)
            $sqlEstudiante = "INSERT INTO estudiantes (id_usuario, cuenta, carrera, telefono, estado) 
                              VALUES (:id_usuario, :cuenta, :carrera, :telefono, 'pendiente')";
            $stmtEstudiante = $conn->prepare($sqlEstudiante);
            $stmtEstudiante->execute([
                "id_usuario" => $idUsuario,
                "cuenta" => $dni,
                "carrera" => $carrera,
                "telefono" => $telefono
            ]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            $conn->rollBack();
            return false;
        }
    }

    public static function aprobarSolicitud($idUsuario)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            // 1. Activar el usuario
            $sqlstr1 = "UPDATE usuarios SET estado = 'activo' WHERE id_usuario = :id_usuario";
            $stmt1 = $conn->prepare($sqlstr1);
            $stmt1->execute(["id_usuario" => $idUsuario]);

            // 2. Asociar el rol en usuarios_roles (3 = estudiante)
            $sqlstr2 = "INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES (:id_usuario, 3)";
            $stmt2 = $conn->prepare($sqlstr2);
            $stmt2->execute(["id_usuario" => $idUsuario]);

            // 3. Cambiar estado en la tabla de estudiantes a 'Admitido'
            $sqlstr3 = "UPDATE estudiantes SET estado = 'Admitido' WHERE id_usuario = :id_usuario";
            $stmt3 = $conn->prepare($sqlstr3);
            $stmt3->execute(["id_usuario" => $idUsuario]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            $conn->rollBack();
            return false;
        }
    }

    public static function rechazarSolicitud($idUsuario)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            // 1. Eliminar de estudiantes (si existe)
            $sqlEst = "DELETE FROM estudiantes WHERE id_usuario = :id_usuario";
            $stmtEst = $conn->prepare($sqlEst);
            $stmtEst->execute(["id_usuario" => $idUsuario]);

            // 2. Eliminar de usuarios
            $sqlUsr = "DELETE FROM usuarios WHERE id_usuario = :id_usuario AND estado = 'pendiente'";
            $stmtUsr = $conn->prepare($sqlUsr);
            $stmtUsr->execute(["id_usuario" => $idUsuario]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            $conn->rollBack();
            return false;
        }
    }
}
