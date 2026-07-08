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
    // GUARDAR
    //=================================

    public static function guardar()
    {
        $data = [
            "nombre" => $_POST["nombre"],
            "correo" => $_POST["correo"],
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

        if (MaestroDao::insertarPersonal($data)) {
            header("Location:index.php?page=maestros");
            exit();
        }

        echo "<script>
                alert('Error al guardar');
                history.back();
              </script>";
    }
}