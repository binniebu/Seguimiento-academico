<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

use PDOException;

class EstudianteDao extends Table
{
    public static function obtenerEstudiantes($buscar = "")
    {
        $sqlstr = "SELECT 
                        e.id_estudiante,
                        e.id_usuario,
                        e.cuenta,
                        e.carrera,
                        e.telefono,
                        u.nombre,
                        u.correo,
                        u.estado
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   WHERE u.nombre LIKE :buscar
                      OR u.correo LIKE :buscar
                      OR e.cuenta LIKE :buscar
                   ORDER BY e.id_estudiante DESC";

        return self::obtenerRegistros($sqlstr, array(
            "buscar" => "%" . $buscar . "%"
        ));
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
                        u.estado
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
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

        $sqlEstudiante = "DELETE FROM estudiantes 
                       WHERE id_estudiante = :id_estudiante";

        self::executeNonQuery($sqlEstudiante, array(
            "id_estudiante" => $id_estudiante
        ), $conn);

        $sqlUsuario = "DELETE FROM usuarios 
                       WHERE id_usuario = :id_usuario";

        return self::executeNonQuery($sqlUsuario, array(
            "id_usuario" => $id_usuario
        ), $conn);
    }
}
?>
