<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class MaestroDao extends Table
{

    //====================================
    // LISTAR MAESTROS
    //====================================

    public static function obtenerTodos()
    {
        $sql = "SELECT 
                    m.id_maestro, 
                    m.numero_empleado, 
                    m.telefono, 
                    u.id_usuario, 
                    u.nombre, 
                    u.correo, 
                    u.titulo, 
                    u.estado
                FROM maestros m
                INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
                ORDER BY u.nombre";

        return self::obtenerRegistros($sql);
    }

    //====================================
    // LISTAR COORDINADORES
    //====================================

    public static function obtenerCoordinadores()
    {
        $sql = "SELECT
                    c.id_coordinador,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.titulo,
                    u.estado,
                    f.nombre_facultad
                FROM coordinadores c
                INNER JOIN usuarios u
                    ON c.id_usuario = u.id_usuario
                INNER JOIN facultades f
                    ON f.id_facultad = c.id_facultad
                ORDER BY u.nombre";

        return self::obtenerRegistros($sql);
    }

    //====================================
    // BUSCAR MAESTROS
    //====================================

    public static function buscar($buscar)
    {
        $sql = "SELECT
                    m.id_maestro,
                    m.numero_empleado,
                    m.telefono,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.titulo,
                    u.estado
                FROM maestros m
                INNER JOIN usuarios u
                    ON u.id_usuario = m.id_usuario
                WHERE
                    u.nombre LIKE :buscar
                    OR u.correo LIKE :buscar
                    OR m.numero_empleado LIKE :buscar
                ORDER BY u.nombre";

        return self::obtenerRegistros(
            $sql,
            [
                "buscar" => "%" . $buscar . "%"
            ]
        );
    }

    //====================================
    // BUSCAR COORDINADORES
    //====================================

    public static function buscarCoordinadores($buscar)
    {
        $sql = "SELECT
                    c.id_coordinador,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.titulo,
                    u.estado,
                    f.nombre_facultad
                FROM coordinadores c
                INNER JOIN usuarios u
                    ON c.id_usuario = u.id_usuario
                INNER JOIN facultades f
                    ON c.id_facultad = f.id_facultad
                WHERE
                    u.nombre LIKE :buscar
                    OR u.correo LIKE :buscar
                    OR f.nombre_facultad LIKE :buscar
                ORDER BY u.nombre";

        return self::obtenerRegistros(
            $sql,
            [
                "buscar" => "%" . $buscar . "%"
            ]
        );
    }

    //====================================
    // INSERTAR PERSONAL
    //====================================

    public static function insertarPersonal($data)
    {
        $conn = self::getConn();

        try {

            $conn->beginTransaction();

            $sql = "INSERT INTO usuarios
            (
                nombre,
                correo,
                password,
                id_rol,
                estado,
                titulo
            )
            VALUES
            (
                :nombre,
                :correo,
                :password,
                :id_rol,
                'activo',
                :titulo
            )";

            self::executeNonQuery(
                $sql,
                [
                    "nombre" => $data["nombre"],
                    "correo" => $data["correo"],
                    "password" => password_hash($data["password"], PASSWORD_DEFAULT),
                    "id_rol" => $data["id_rol"],
                    "titulo" => $data["titulo"]
                ],
                $conn
            );

            $idUsuario = $conn->lastInsertId();

            // MAESTRO

            if ($data["id_rol"] == 2) {

                $sql = "INSERT INTO maestros
                (
                    id_usuario,
                    numero_empleado,
                    telefono
                )
                VALUES
                (
                    :id_usuario,
                    :numero_empleado,
                    :telefono
                )";

                self::executeNonQuery(
                    $sql,
                    [
                        "id_usuario" => $idUsuario,
                        "numero_empleado" => $data["numero_empleado"],
                        "telefono" => $data["telefono"]
                    ],
                    $conn
                );
            }

            // COORDINADOR

            if ($data["id_rol"] == 4) {

                $sql = "INSERT INTO coordinadores
                (
                    id_usuario,
                    id_facultad
                )
                VALUES
                (
                    :id_usuario,
                    :id_facultad
                )";

                self::executeNonQuery(
                    $sql,
                    [
                        "id_usuario" => $idUsuario,
                        "id_facultad" => $data["id_facultad"]
                    ],
                    $conn
                );
            }

            $conn->commit();

            return true;

        } catch (\Exception $e) {

            $conn->rollBack();

            die($e->getMessage());

        }

    }

    //====================================
    // ELIMINAR MAESTRO
    //====================================

    public static function eliminar($id)
    {
        $maestro = self::obtenerUnRegistro(
            "SELECT id_usuario
             FROM maestros
             WHERE id_maestro=:id",
            [
                "id" => $id
            ]
        );

        if (!$maestro) {
            return [
                "exito" => false,
                "mensaje" => "No existe."
            ];
        }

        self::executeNonQuery(
            "DELETE FROM maestros WHERE id_maestro=:id",
            [
                "id" => $id
            ]
        );

        self::executeNonQuery(
            "DELETE FROM usuarios WHERE id_usuario=:id",
            [
                "id" => $maestro["id_usuario"]
            ]
        );

        return [
            "exito" => true,
            "mensaje" => "Registro eliminado correctamente."
        ];
    }

    //====================================
    // ELIMINAR COORDINADOR
    //====================================

    public static function eliminarCoordinador($id)
    {
        $coordinador = self::obtenerUnRegistro(
            "SELECT id_usuario
             FROM coordinadores
             WHERE id_coordinador=:id",
            [
                "id" => $id
            ]
        );

        if (!$coordinador) {
            return [
                "exito" => false,
                "mensaje" => "No existe."
            ];
        }

        self::executeNonQuery(
            "DELETE FROM coordinadores WHERE id_coordinador=:id",
            [
                "id" => $id
            ]
        );

        self::executeNonQuery(
            "DELETE FROM usuarios WHERE id_usuario=:id",
            [
                "id" => $coordinador["id_usuario"]
            ]
        );

        return [
            "exito" => true,
            "mensaje" => "Registro eliminado correctamente."
        ];
    }

    //====================================
    // VALIDACIONES
    //====================================

    public static function existeCorreo($correo)
    {
        return self::obtenerUnRegistro(
            "SELECT id_usuario
             FROM usuarios
             WHERE correo=:correo",
            [
                "correo" => $correo
            ]
        );
    }

}