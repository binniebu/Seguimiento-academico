<?php

namespace Controllers;

require_once __DIR__ . "/../dao/MaestroDao.php";

use Dao\MaestroDao;

class MaestrosController
{
    //=================================
    // LISTAR MAESTROS
    //=================================

    public static function listarMaestros($estado = 'todos', $idCampus = null, $limit = null, $offset = null)
    {
        return MaestroDao::obtenerTodos($estado, $idCampus, $limit, $offset);
    }

    //=================================
    // LISTAR COORDINADORES
    //=================================

    public static function listarCoordinadores($estado = 'todos', $idCampus = null, $limit = null, $offset = null)
    {
        return MaestroDao::obtenerCoordinadores($estado, $idCampus, $limit, $offset);
    }

    //=================================
    // LISTAR FACULTADES
    //=================================

    public static function listarFacultades()
    {
        return MaestroDao::obtenerFacultades();
    }

    //=================================
    // OBTENER UN MAESTRO / COORDINADOR
    //=================================

    public static function obtenerMaestro($id)
    {
        return MaestroDao::obtenerMaestroPorId($id);
    }

    public static function obtenerCoordinador($id)
    {
        return MaestroDao::obtenerCoordinadorPorId($id);
    }

    //=================================
    // VERIFICAR CLASES ACTIVAS
    //=================================

    public static function tieneClasesActivas($idMaestro)
    {
        return MaestroDao::tieneClasesActivas($idMaestro);
    }

    //=================================
    // BUSCAR MAESTROS
    //=================================

    public static function buscarMaestros($buscar, $estado = 'todos', $idCampus = null, $limit = null, $offset = null)
    {
        return MaestroDao::buscar($buscar, $estado, $idCampus, $limit, $offset);
    }

    //=================================
    // BUSCAR COORDINADORES
    //=================================

    public static function buscarCoordinadores($buscar, $estado = 'todos', $idCampus = null, $limit = null, $offset = null)
    {
        return MaestroDao::buscarCoordinadores($buscar, $estado, $idCampus, $limit, $offset);
    }

    //=================================
    // ELIMINAR MAESTRO
    //=================================

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
        return MaestroDao::inactivar($id);
    }

    public static function activar($id)
    {
        return MaestroDao::activar($id);
    }

    public static function inactivarCoordinador($id)
    {
        return MaestroDao::inactivarCoordinador($id);
    }

    public static function activarCoordinador($id)
    {
        return MaestroDao::activarCoordinador($id);
    }

    //=================================
    // GUARDAR
    //=================================

    public static function guardar()
    {
        $idMaestro = $_POST["id_maestro"] ?? null;
        $idCoordinador = $_POST["id_coordinador"] ?? null;
        $isEdit = ($idMaestro !== null || $idCoordinador !== null);

        $dni = trim($_POST["dni"] ?? "");
        $correo = trim($_POST["correo"] ?? "");

        $data = [
            "nombre" => $_POST["nombre"],
            "correo" => $correo,
            "id_rol" => $_POST["rol"],
            "telefono" => $_POST["telefono"] ?? null,
            "titulo" => $_POST["titulo"],
            "id_facultad" => (!empty($_POST["id_facultad"]) ? intval($_POST["id_facultad"]) : null),
            "id_carrera" => (!empty($_POST["id_carrera"]) ? intval($_POST["id_carrera"]) : null),
            "id_campus" => (!empty($_POST["id_campus"]) ? intval($_POST["id_campus"]) : null),
            "documento_dni" => $dni
        ];

        // Definir la URL de retorno en caso de error
        if ($isEdit) {
            $idUsuario = $_POST["id_usuario"];
            $data["id_usuario"] = $idUsuario;
            if ($idMaestro !== null) {
                $data["id_maestro"] = $idMaestro;
                $backUrl = "index.php?page=maestro_nuevo&id=" . intval($idMaestro);
            } else {
                $data["id_coordinador"] = $idCoordinador;
                $backUrl = "index.php?page=maestro_nuevo&id_coordinador=" . intval($idCoordinador);
            }
        } else {
            $backUrl = "index.php?page=maestro_nuevo";
        }

        // 1. Validar formato de DNI (13 dígitos numéricos)
        if (!preg_match('/^[0-9]{13}$/', $dni)) {
            $msg = urlencode("El DNI debe constar de exactamente 13 dígitos numéricos.");
            header("Location: $backUrl&msg=$msg&tipo_msg=error");
            exit();
        }

        // 2. Validar correo vacío o DNI vacío
        if (empty($correo) || empty($dni)) {
            $msg = urlencode("El correo y el DNI son campos obligatorios.");
            header("Location: $backUrl&msg=$msg&tipo_msg=error");
            exit();
        }

        if ($isEdit) {
            // 3. Validar correo duplicado excluyendo el usuario actual
            if (MaestroDao::existeCorreoExcluyendo($correo, $idUsuario)) {
                $msg = urlencode("El correo ya está registrado por otro usuario.");
                header("Location: $backUrl&msg=$msg&tipo_msg=error");
                exit();
            }

            // 4. Validar DNI duplicado excluyendo el usuario actual
            if (MaestroDao::existeDniExcluyendo($dni, $idUsuario)) {
                $msg = urlencode("El DNI ya está registrado por otro usuario.");
                header("Location: $backUrl&msg=$msg&tipo_msg=error");
                exit();
            }

            if (MaestroDao::actualizarPersonal($data)) {
                $msg = urlencode("Registro de personal actualizado con éxito.");
                $tabParam = ($data["id_rol"] == 4) ? "coordinadores" : "maestros";
                header("Location: index.php?page=maestros&msg=$msg&tipo_msg=success&tab=$tabParam");
                exit();
            }
        } else {
            $data["password"] = $_POST["password"];
            $data["numero_empleado"] = $_POST["numero_empleado"] ?? ("EMP-" . time() . rand(1000, 9999));

            // 3. Validar correo duplicado
            if (MaestroDao::existeCorreo($correo)) {
                $msg = urlencode("El correo ya está registrado en el sistema.");
                header("Location: $backUrl&msg=$msg&tipo_msg=error");
                exit();
            }

            // 4. Validar DNI duplicado
            if (MaestroDao::existeDni($dni)) {
                $msg = urlencode("El DNI ya está registrado en el sistema.");
                header("Location: $backUrl&msg=$msg&tipo_msg=error");
                exit();
            }

            if (MaestroDao::insertarPersonal($data)) {
                $msg = urlencode("Personal registrado con éxito.");
                $tabParam = ($data["id_rol"] == 4) ? "coordinadores" : "maestros";
                header("Location: index.php?page=maestros&msg=$msg&tipo_msg=success&tab=$tabParam");
                exit();
            }
        }

        $msg = urlencode("Ocurrió un error al guardar el registro en la base de datos.");
        header("Location: $backUrl&msg=$msg&tipo_msg=error");
        exit();
    }
}