<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class MaestroDao extends Table
{

    //====================================
    // LISTAR MAESTROS
    //====================================

    public static function obtenerTodos($estado = 'todos')
    {
        $sql = "SELECT 
                    m.id_maestro, 
                    m.numero_empleado, 
                    m.telefono, 
                    u.id_usuario, 
                    u.nombre, 
                    u.correo, 
                    u.titulo, 
                    u.estado,
                    u.documento_dni AS dni
                FROM maestros m
                INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
                WHERE 1=1";
        
        $params = [];
        if ($estado === 'activo' || $estado === 'inactivo') {
            $sql .= " AND u.estado = :estado";
            $params["estado"] = $estado;
        }

        $sql .= " ORDER BY u.nombre";

        return self::obtenerRegistros($sql, $params);
    }

    //====================================
    // LISTAR COORDINADORES
    //====================================

    public static function obtenerCoordinadores($estado = 'todos')
    {
        $sql = "SELECT
                    c.id_coordinador,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.titulo,
                    u.estado,
                    u.documento_dni AS dni,
                    f.nombre_facultad
                FROM coordinadores c
                INNER JOIN usuarios u
                    ON c.id_usuario = u.id_usuario
                INNER JOIN facultades f
                    ON f.id_facultad = c.id_facultad
                WHERE 1=1";

        $params = [];
        if ($estado === 'activo' || $estado === 'inactivo') {
            $sql .= " AND u.estado = :estado";
            $params["estado"] = $estado;
        }

        $sql .= " ORDER BY u.nombre";

        return self::obtenerRegistros($sql, $params);
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

    public static function buscar($buscar, $estado = 'todos')
    {
        $sql = "SELECT
                    m.id_maestro,
                    m.numero_empleado,
                    m.telefono,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.titulo,
                    u.estado,
                    u.documento_dni AS dni
                FROM maestros m
                INNER JOIN usuarios u
                    ON u.id_usuario = m.id_usuario
                WHERE (
                    u.nombre LIKE :buscar
                    OR u.correo LIKE :buscar
                    OR m.numero_empleado LIKE :buscar
                    OR u.documento_dni LIKE :buscar
                )";

        $params = ["buscar" => "%" . $buscar . "%"];
        if ($estado === 'activo' || $estado === 'inactivo') {
            $sql .= " AND u.estado = :estado";
            $params["estado"] = $estado;
        }

        $sql .= " ORDER BY u.nombre";

        return self::obtenerRegistros($sql, $params);
    }

    //====================================
    // BUSCAR COORDINADORES
    //====================================

    public static function buscarCoordinadores($buscar, $estado = 'todos')
    {
        $sql = "SELECT
                    c.id_coordinador,
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.titulo,
                    u.estado,
                    u.documento_dni AS dni,
                    f.nombre_facultad
                FROM coordinadores c
                INNER JOIN usuarios u
                    ON c.id_usuario = u.id_usuario
                INNER JOIN facultades f
                    ON f.id_facultad = c.id_facultad
                WHERE (
                    u.nombre LIKE :buscar
                    OR u.correo LIKE :buscar
                    OR f.nombre_facultad LIKE :buscar
                    OR u.documento_dni LIKE :buscar
                )";

        $params = ["buscar" => "%" . $buscar . "%"];
        if ($estado === 'activo' || $estado === 'inactivo') {
            $sql .= " AND u.estado = :estado";
            $params["estado"] = $estado;
        }

        $sql .= " ORDER BY u.nombre";

        return self::obtenerRegistros($sql, $params);
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
                titulo,
                documento_dni
            )
            VALUES
            (
                :nombre,
                :correo,
                :password,
                :id_rol,
                'activo',
                :titulo,
                :documento_dni
            )";

            self::executeNonQuery(
                $sql,
                [
                    "nombre" => $data["nombre"],
                    "correo" => $data["correo"],
                    "password" => password_hash($data["password"], PASSWORD_DEFAULT),
                    "id_rol" => $data["id_rol"],
                    "titulo" => $data["titulo"],
                    "documento_dni" => $data["documento_dni"]
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
                    telefono,
                    id_facultad,
                    id_carrera
                )
                VALUES
                (
                    :id_usuario,
                    :numero_empleado,
                    :telefono,
                    :id_facultad,
                    :id_carrera
                )";

                self::executeNonQuery(
                    $sql,
                    [
                        "id_usuario" => $idUsuario,
                        "numero_empleado" => $data["numero_empleado"],
                        "telefono" => $data["telefono"],
                        "id_facultad" => $data["id_facultad"] ?? null,
                        "id_carrera" => $data["id_carrera"] ?? null
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
        return self::inactivar($id);
    }

    public static function eliminarCoordinador($id)
    {
        return self::inactivarCoordinador($id);
    }

    public static function inactivar($id)
    {
        $maestro = self::obtenerUnRegistro(
            "SELECT id_usuario FROM maestros WHERE id_maestro=:id",
            ["id" => $id]
        );

        if (!$maestro) {
            return ["exito" => false, "mensaje" => "No existe."];
        }

        self::executeNonQuery(
            "UPDATE usuarios SET estado='inactivo' WHERE id_usuario=:id",
            ["id" => $maestro["id_usuario"]]
        );

        return ["exito" => true, "mensaje" => "Maestro inactivado correctamente."];
    }

    public static function activar($id)
    {
        $maestro = self::obtenerUnRegistro(
            "SELECT id_usuario FROM maestros WHERE id_maestro=:id",
            ["id" => $id]
        );

        if (!$maestro) {
            return ["exito" => false, "mensaje" => "No existe."];
        }

        self::executeNonQuery(
            "UPDATE usuarios SET estado='activo' WHERE id_usuario=:id",
            ["id" => $maestro["id_usuario"]]
        );

        return ["exito" => true, "mensaje" => "Maestro activado correctamente."];
    }

    public static function inactivarCoordinador($id)
    {
        $coordinador = self::obtenerUnRegistro(
            "SELECT id_usuario FROM coordinadores WHERE id_coordinador=:id",
            ["id" => $id]
        );

        if (!$coordinador) {
            return ["exito" => false, "mensaje" => "No existe."];
        }

        self::executeNonQuery(
            "UPDATE usuarios SET estado='inactivo' WHERE id_usuario=:id",
            ["id" => $coordinador["id_usuario"]]
        );

        return ["exito" => true, "mensaje" => "Coordinador inactivado correctamente."];
    }

    public static function activarCoordinador($id)
    {
        $coordinador = self::obtenerUnRegistro(
            "SELECT id_usuario FROM coordinadores WHERE id_coordinador=:id",
            ["id" => $id]
        );

        if (!$coordinador) {
            return ["exito" => false, "mensaje" => "No existe."];
        }

        self::executeNonQuery(
            "UPDATE usuarios SET estado='activo' WHERE id_usuario=:id",
            ["id" => $coordinador["id_usuario"]]
        );

        return ["exito" => true, "mensaje" => "Coordinador activado correctamente."];
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

    public static function obtenerMaestroPorId($idMaestro)
    {
        $sql = "SELECT m.id_maestro, m.telefono, m.id_facultad, m.id_carrera, u.id_usuario, u.nombre, u.correo, u.titulo, u.documento_dni AS dni, u.id_rol
                FROM maestros m
                INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
                WHERE m.id_maestro = :id";
        return self::obtenerUnRegistro($sql, ["id" => $idMaestro]);
    }

    public static function obtenerCoordinadorPorId($idCoordinador)
    {
        $sql = "SELECT c.id_coordinador, c.id_facultad, u.id_usuario, u.nombre, u.correo, u.titulo, u.documento_dni AS dni, u.id_rol
                FROM coordinadores c
                INNER JOIN usuarios u ON c.id_usuario = u.id_usuario
                WHERE c.id_coordinador = :id";
        return self::obtenerUnRegistro($sql, ["id" => $idCoordinador]);
    }

    public static function existeCorreoExcluyendo($correo, $idUsuario)
    {
        return self::obtenerUnRegistro(
            "SELECT id_usuario FROM usuarios WHERE correo=:correo AND id_usuario <> :id_usuario",
            ["correo" => $correo, "id_usuario" => $idUsuario]
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
            "SELECT id_usuario FROM usuarios WHERE documento_dni=:dni AND id_usuario != :id_usuario",
            ["dni" => $dni, "id_usuario" => $idUsuario]
        );
    }

    public static function actualizarPersonal($data)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            $sqlUsuario = "UPDATE usuarios 
                           SET nombre = :nombre, 
                               correo = :correo, 
                               titulo = :titulo, 
                               documento_dni = :documento_dni 
                           WHERE id_usuario = :id_usuario";
            self::executeNonQuery($sqlUsuario, [
                "nombre" => $data["nombre"],
                "correo" => $data["correo"],
                "titulo" => $data["titulo"],
                "documento_dni" => $data["documento_dni"],
                "id_usuario" => $data["id_usuario"]
            ], $conn);

            if ($data["id_rol"] == 2 && isset($data["id_maestro"])) {
                $sqlMaestro = "UPDATE maestros 
                               SET telefono = :telefono, 
                                   id_facultad = :id_facultad, 
                                   id_carrera = :id_carrera 
                               WHERE id_maestro = :id_maestro";
                self::executeNonQuery($sqlMaestro, [
                    "telefono" => $data["telefono"],
                    "id_facultad" => $data["id_facultad"],
                    "id_carrera" => $data["id_carrera"],
                    "id_maestro" => $data["id_maestro"]
                ], $conn);
            } elseif ($data["id_rol"] == 4 && isset($data["id_coordinador"])) {
                $sqlCoordinador = "UPDATE coordinadores 
                                   SET id_facultad = :id_facultad 
                                   WHERE id_coordinador = :id_coordinador";
                self::executeNonQuery($sqlCoordinador, [
                    "id_facultad" => $data["id_facultad"],
                    "id_coordinador" => $data["id_coordinador"]
                ], $conn);
            }

            $conn->commit();
            return true;
        } catch (\Exception $e) {
            $conn->rollBack();
            die($e->getMessage());
        }
    }

    /**
     * Busca el registro de maestro por id_usuario de sesión.
     * Necesario para filtrar las secciones del docente logueado.
     */
    public static function obtenerMaestroPorIdUsuario($idUsuario)
    {
        $sql = "SELECT m.id_maestro, m.id_facultad, m.id_carrera, u.id_usuario, u.nombre, u.correo
                FROM maestros m
                INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
                WHERE u.id_usuario = :id_usuario
                LIMIT 1";
        return self::obtenerUnRegistro($sql, ["id_usuario" => intval($idUsuario)]);
    }
}