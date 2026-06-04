<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class UsuarioDao extends Table
{
    public static function registrarUsuario($nombre, $correo, $password, $idRol)
    {
        $sqlstr = "INSERT INTO usuarios (nombre, correo, password, id_rol, estado)
                   VALUES (:nombre, :correo, :password, :id_rol, 'activo')";

        $params = array(
            "nombre" => $nombre,
            "correo" => $correo,
            "password" => password_hash($password, PASSWORD_DEFAULT),
            "id_rol" => intval($idRol)
        );

        return self::executeNonQuery($sqlstr, $params);
    }

    public static function existeCorreo($correo)
    {
        $sqlstr = "SELECT * FROM usuarios WHERE correo = :correo";
        $params = array("correo" => $correo);

        return self::obtenerUnRegistro($sqlstr, $params);
    }
    
    public static function obtenerUsuarioPorCorreo($correo)
    {
    $sqlstr = "SELECT u.*, r.nombre_rol 
               FROM usuarios u
               INNER JOIN roles r ON u.id_rol = r.id_rol
               WHERE u.correo = :correo
               AND u.estado = 'activo';";

    $params = array(
        "correo" => $correo
    );

    return self::obtenerUnRegistro($sqlstr, $params);
    }
}
?>