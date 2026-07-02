<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

use PDOException;

class MaestroDao extends Table
{
    public static function obtenerMaestros($buscar = "")
    {
        $sqlstr = "SELECT 
                        m.id_maestro,
                        m.id_usuario,
                        m.codigo,
                        m.especialidad,
                        m.telefono,
                        u.nombre,
                        u.correo,
                        u.estado
                   FROM maestros m
                   INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
                   WHERE u.nombre LIKE :buscar
                      OR u.correo LIKE :buscar
                      OR m.codigo LIKE :buscar
                   ORDER BY m.id_maestro DESC";

        return self::obtenerRegistros($sqlstr, array(
            "buscar" => "%" . $buscar . "%"
        ));
    }

    public static function obtenerMaestroPorId($id_maestro)
    {
        $sqlstr = "SELECT 
                        m.id_maestro,
                        m.id_usuario,
                        m.codigo,
                        m.especialidad,
                        m.telefono,
                        u.nombre,
                        u.correo,
                        u.estado
                   FROM maestros m
                   INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
                   WHERE m.id_maestro = :id_maestro";

        return self::obtenerUnRegistro($sqlstr, array(
            "id_maestro" => $id_maestro
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

    public static function insertarMaestro($nombre, $correo, $password, $codigo, $especialidad, $telefono)
    {
        $conn = self::getConn();

        try {
            $sqlUsuario = "INSERT INTO usuarios 
                            (nombre, correo, password, id_rol, estado)
                           VALUES 
                            (:nombre, :correo, :password, 2, 'activo')";

            self::executeNonQuery($sqlUsuario, array(
                "nombre" => $nombre,
                "correo" => $correo,
                "password" => password_hash($password, PASSWORD_DEFAULT)
            ), $conn);

            $idUsuario = $conn->lastInsertId();

            $sqlMaestro = "INSERT INTO maestros 
                            (id_usuario, codigo, especialidad, telefono)
                           VALUES 
                            (:id_usuario, :codigo, :especialidad, :telefono)";

            return self::executeNonQuery($sqlMaestro, array(
                "id_usuario" => $idUsuario,
                "codigo" => $codigo,
                "especialidad" => $especialidad,
                "telefono" => $telefono
            ), $conn);

        } catch (PDOException $ex) {
            return false;
        }
    }

    public static function actualizarMaestro($id_maestro, $id_usuario, $nombre, $correo, $codigo, $especialidad, $telefono)
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

        $sqlMaestro = "UPDATE maestros
                       SET codigo = :codigo,
                           especialidad = :especialidad,
                           telefono = :telefono
                       WHERE id_maestro = :id_maestro";

        return self::executeNonQuery($sqlMaestro, array(
            "codigo" => $codigo,
            "especialidad" => $especialidad,
            "telefono" => $telefono,
            "id_maestro" => $id_maestro
        ), $conn);
    }

    public static function eliminarMaestro($id_maestro, $id_usuario)
    {
        $conn = self::getConn();

        $sqlUsuario = "UPDATE usuarios 
                       SET estado = 'inactivo' 
                       WHERE id_usuario = :id_usuario";

        return self::executeNonQuery($sqlUsuario, array(
            "id_usuario" => $id_usuario
        ), $conn);
    }
}
?>