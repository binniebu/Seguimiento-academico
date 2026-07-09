<?php

namespace Controllers;

require_once __DIR__ . "/../dao/MaestroDao.php";

use Dao\MaestroDao;

class MaestrosController
{
    //=================================
    // LISTAR MAESTROS
    //=================================

    public static function listarMaestros($estado = 'todos')
    {
        return MaestroDao::obtenerTodos($estado);
    }

    //=================================
    // LISTAR COORDINADORES
    //=================================

    public static function listarCoordinadores($estado = 'todos')
    {
        return MaestroDao::obtenerCoordinadores($estado);
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

    public static function buscarMaestros($buscar, $estado = 'todos')
    {
        return MaestroDao::buscar($buscar, $estado);
    }

    //=================================
    // BUSCAR COORDINADORES
    //=================================

    public static function buscarCoordinadores($buscar, $estado = 'todos')
    {
        return MaestroDao::buscarCoordinadores($buscar, $estado);
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

        $data = [
            "nombre" => $_POST["nombre"],
            "correo" => $_POST["correo"],
            "id_rol" => $_POST["rol"],
            "telefono" => $_POST["telefono"] ?? null,
            "titulo" => $_POST["titulo"],
            "id_facultad" => (!empty($_POST["id_facultad"]) ? intval($_POST["id_facultad"]) : null),
            "id_carrera" => (!empty($_POST["id_carrera"]) ? intval($_POST["id_carrera"]) : null),
            "documento_dni" => $_POST["dni"] ?? null
        ];

        if ($isEdit) {
            $idUsuario = $_POST["id_usuario"];
            $data["id_usuario"] = $idUsuario;
            if ($idMaestro !== null) {
                $data["id_maestro"] = $idMaestro;
            }
            if ($idCoordinador !== null) {
                $data["id_coordinador"] = $idCoordinador;
            }

            if (MaestroDao::existeCorreoExcluyendo($data["correo"], $idUsuario)) {
                echo "<script>
                        alert('El correo ya está registrado por otro usuario');
                        history.back();
                      </script>";
                exit();
            }

            if (MaestroDao::actualizarPersonal($data)) {
                header("Location:index.php?page=maestros");
                exit();
            }
        } else {
            $data["password"] = $_POST["password"];
            $data["numero_empleado"] = $_POST["numero_empleado"] ?? ("EMP-" . time() . rand(1000, 9999));

            if (MaestroDao::existeCorreo($data["correo"])) {
                echo "<script>
                        alert('El correo ya existe');
                        history.back();
                      </script>";
                exit();
            }

            if (MaestroDao::insertarPersonal($data)) {
                header("Location:index.php?page=maestros");
                exit();
            }
        }

        echo "<script>
                alert('Error al guardar');
                history.back();
              </script>";
    }
}