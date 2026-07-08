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
                    u.documento_dni,
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
                    c.id_facultad,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.documento_dni,
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
    // OBTENER UN MAESTRO (para editar)
    //====================================

    public static function obtenerMaestroPorId($id)
    {
        $sql = "SELECT
                    m.id_maestro,
                    m.numero_empleado,
                    m.telefono,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.documento_dni,
                    u.titulo,
                    u.estado
                FROM maestros m
                INNER JOIN usuarios u
                    ON m.id_usuario = u.id_usuario
                WHERE m.id_maestro = :id";

        return self::obtenerUnRegistro($sql, ["id" => $id]);
    }

    //====================================
    // OBTENER UN COORDINADOR (para editar)
    //====================================

    public static function obtenerCoordinadorPorId($id)
    {
        $sql = "SELECT
                    c.id_coordinador,
                    c.id_facultad,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.documento_dni,
                    u.titulo,
                    u.estado
                FROM coordinadores c
                INNER JOIN usuarios u
                    ON c.id_usuario = u.id_usuario
                WHERE c.id_coordinador = :id";

        return self::obtenerUnRegistro($sql, ["id" => $id]);
    }

    //====================================
    // LISTAR FACULTADES (para el select)
    //====================================

    public static function obtenerFacultades()
    {
        $sql = "SELECT id_facultad, nombre_facultad
                FROM facultades
                ORDER BY nombre_facultad";

        return self::obtenerRegistros($sql);
    }

    //====================================
    // VERIFICAR SI EL MAESTRO TIENE CLASES
    // EN EL PERIODO ACTIVO
    //====================================

    public static function tieneClasesActivas($idMaestro)
    {
        $sql = "SELECT COUNT(*) AS total
                FROM secciones s
                INNER JOIN periodos_academicos p
                    ON s.id_periodo = p.id_periodo
                WHERE s.id_maestro = :id_maestro
                  AND p.estado = 'activo'";

        $resultado = self::obtenerUnRegistro($sql, ["id_maestro" => $idMaestro]);

        return $resultado && (int)$resultado["total"] > 0;
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
                    u.documento_dni,
                    u.titulo,
                    u.estado
                FROM maestros m
                INNER JOIN usuarios u
                    ON u.id_usuario = m.id_usuario
                WHERE
                    u.nombre LIKE :buscar
                    OR u.correo LIKE :buscar
                    OR m.numero_empleado LIKE :buscar
                    OR u.documento_dni LIKE :buscar
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
                    c.id_facultad,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.documento_dni,
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
                    OR u.documento_dni LIKE :buscar
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
                documento_dni,
                password,
                id_rol,
                estado,
                titulo
            )
            VALUES
            (
                :nombre,
                :correo,
                :dni,
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
                    "dni" => $data["dni"],
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
    // ACTUALIZAR PERSONAL (EDITAR)
    //====================================

    public static function actualizarPersonal($data)
    {
        $conn = self::getConn();

        try {

            $conn->beginTransaction();

            // -----------------------------------
            // 1. Actualizar tabla usuarios
            // -----------------------------------

            if (!empty($data["password"])) {

                $sql = "UPDATE usuarios SET
                            nombre = :nombre,
                            correo = :correo,
                            documento_dni = :dni,
                            titulo = :titulo,
                            password = :password
                        WHERE id_usuario = :id_usuario";

                $params = [
                    "nombre" => $data["nombre"],
                    "correo" => $data["correo"],
                    "dni" => $data["dni"],
                    "titulo" => $data["titulo"],
                    "password" => password_hash($data["password"], PASSWORD_DEFAULT),
                    "id_usuario" => $data["id_usuario"]
                ];

            } else {

                $sql = "UPDATE usuarios SET
                            nombre = :nombre,
                            correo = :correo,
                            documento_dni = :dni,
                            titulo = :titulo
                        WHERE id_usuario = :id_usuario";

                $params = [
                    "nombre" => $data["nombre"],
                    "correo" => $data["correo"],
                    "dni" => $data["dni"],
                    "titulo" => $data["titulo"],
                    "id_usuario" => $data["id_usuario"]
                ];
            }

            self::executeNonQuery($sql, $params, $conn);

            // -----------------------------------
            // 2. Actualizar tabla específica
            // -----------------------------------

            if ($data["tipo"] === "maestro") {

                $sql = "UPDATE maestros SET
                            numero_empleado = :numero_empleado,
                            telefono = :telefono
                        WHERE id_maestro = :id";

                self::executeNonQuery(
                    $sql,
                    [
                        "numero_empleado" => $data["numero_empleado"],
                        "telefono" => $data["telefono"],
                        "id" => $data["id"]
                    ],
                    $conn
                );

            } elseif ($data["tipo"] === "coordinador") {

                $sql = "UPDATE coordinadores SET
                            id_facultad = :id_facultad
                        WHERE id_coordinador = :id";

                self::executeNonQuery(
                    $sql,
                    [
                        "id_facultad" => $data["id_facultad"],
                        "id" => $data["id"]
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

    public static function existeCorreoExcluyendo($correo, $idUsuario)
    {
        return self::obtenerUnRegistro(
            "SELECT id_usuario
             FROM usuarios
             WHERE correo=:correo
               AND id_usuario != :id_usuario",
            [
                "correo" => $correo,
                "id_usuario" => $idUsuario
            ]
        );
    }

    public static function existeDni($dni)
    {
        return self::obtenerUnRegistro(
            "SELECT id_usuario FROM usuarios WHERE documento_dni=:dni",
            ["dni" => $dni]
        );
    }

    public static function existeDniExcluyendo($dni, $idUsuario)
    {
        return self::obtenerUnRegistro(
            "SELECT id_usuario
             FROM usuarios
             WHERE documento_dni=:dni
               AND id_usuario != :id_usuario",
            ["dni" => $dni, "id_usuario" => $idUsuario]
        );
    }

}