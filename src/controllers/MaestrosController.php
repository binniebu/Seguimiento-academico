<?php

namespace Controllers;

require_once __DIR__ . "/../dao/MaestroDao.php";

use Dao\MaestroDao;

class MaestrosController
{
    //=================================
    // LISTAR MAESTROS
    //=================================

    public static function listarMaestros()
    {
        return MaestroDao::obtenerTodos();
    }

    //=================================
    // LISTAR COORDINADORES
    //=================================

    public static function listarCoordinadores()
    {
        return MaestroDao::obtenerCoordinadores();
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

    public static function buscarMaestros($buscar)
    {
        return MaestroDao::buscar($buscar);
    }

    //=================================
    // BUSCAR COORDINADORES
    //=================================

    public static function buscarCoordinadores($buscar)
    {
        return MaestroDao::buscarCoordinadores($buscar);
    }

    //=================================
    // ELIMINAR MAESTRO
    //=================================

    public static function eliminar($id)
    {
        return MaestroDao::eliminar($id);
    }

    //=================================
    // ELIMINAR COORDINADOR
    //=================================

    public static function eliminarCoordinador($id)
    {
        return MaestroDao::eliminarCoordinador($id);
    }

    //=================================
    // GUARDAR (CREAR)
    //=================================

    public static function guardar()
    {
        $data = [
            "nombre" => $_POST["nombre"],
            "correo" => $_POST["correo"],
            "dni" => $_POST["dni"],
            "password" => $_POST["password"],
            "id_rol" => $_POST["rol"],
            "telefono" => $_POST["telefono"],
            "titulo" => $_POST["titulo"],
            "numero_empleado" => $_POST["numero_empleado"] ?? null,
            "id_facultad" => $_POST["id_facultad"] ?? null
        ];

        if (MaestroDao::existeCorreo($data["correo"])) {
            echo "<script>
                    alert('El correo ya existe');
                    history.back();
                  </script>";
            exit();
        }

        if (MaestroDao::existeDni($data["dni"])) {
            echo "<script>
                    alert('El DNI ya está registrado');
                    history.back();
                  </script>";
            exit();
        }

        if (MaestroDao::insertarPersonal($data)) {
            header("Location:index.php?page=maestros");
            exit();
        }

        echo "<script>
                alert('Error al guardar');
                history.back();
              </script>";
    }

    //=================================
    // ACTUALIZAR (EDITAR)
    //=================================

    public static function actualizar()
    {
        $tipo = $_POST["tipo"];
        $id = $_POST["id"];
        $idUsuario = $_POST["id_usuario"];
        $correo = $_POST["correo"];
        $dni = $_POST["dni"];

        $data = [
            "tipo" => $tipo,
            "id" => $id,
            "id_usuario" => $idUsuario,
            "nombre" => $_POST["nombre"],
            "correo" => $correo,
            "dni" => $dni,
            "titulo" => $_POST["titulo"],
            "password" => $_POST["password"] ?? "",
            "telefono" => $_POST["telefono"] ?? null,
            "numero_empleado" => $_POST["numero_empleado"] ?? null,
            "id_facultad" => $_POST["id_facultad"] ?? null
        ];

        if (MaestroDao::existeCorreoExcluyendo($correo, $idUsuario)) {
            echo "<script>
                    alert('El correo ya está en uso por otro usuario');
                    history.back();
                  </script>";
            exit();
        }

        if (MaestroDao::existeDniExcluyendo($dni, $idUsuario)) {
            echo "<script>
                    alert('El DNI ya está en uso por otro usuario');
                    history.back();
                  </script>";
            exit();
        }

        if (MaestroDao::actualizarPersonal($data)) {
            header("Location:index.php?page=maestros");
            exit();
        }

        echo "<script>
                alert('Error al actualizar');
                history.back();
              </script>";
    }
}