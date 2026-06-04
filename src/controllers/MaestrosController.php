<?php

namespace Controllers;

require_once __DIR__ . "/../dao/MaestroDao.php";

use Dao\MaestroDao;

class MaestrosController
{
    public static function listar()
    {
        $buscar = $_GET["buscar"] ?? "";
        return MaestroDao::obtenerMaestros($buscar);
    }

    public static function buscar($buscar)
    {
        return MaestroDao::obtenerMaestros($buscar);
    }

    public static function guardar()
    {
        $nombre = $_POST["nombre"] ?? "";
        $correo = $_POST["correo"] ?? "";
        $password = $_POST["password"] ?? "";
        $codigo = $_POST["codigo"] ?? "";
        $especialidad = $_POST["especialidad"] ?? "";
        $telefono = $_POST["telefono"] ?? "";

        if ($nombre == "" || $correo == "" || $password == "" || $codigo == "" || $especialidad == "" || $telefono == "") {
            echo "<script>
                    alert('Debe completar todos los campos');
                    window.location='index.php?page=maestro_nuevo';
                  </script>";
            exit();
        }

        if (MaestroDao::existeCorreo($correo)) {
            echo "<script>
                    alert('El correo ya está registrado');
                    window.location='index.php?page=maestro_nuevo';
                  </script>";
            exit();
        }

        $resultado = MaestroDao::insertarMaestro(
            $nombre,
            $correo,
            $password,
            $codigo,
            $especialidad,
            $telefono
        );

        if ($resultado) {
            echo "<script>
                    alert('Maestro registrado correctamente');
                    window.location='index.php?page=maestros';
                  </script>";
            exit();
        }

        echo "<script>
                alert('No se pudo registrar el maestro');
                window.location='index.php?page=maestro_nuevo';
              </script>";
        exit();
    }

    public static function eliminar($id = null)
    {
        if ($id == null) {
            $id = $_GET["id"] ?? 0;
        }

        $maestro = MaestroDao::obtenerMaestroPorId($id);

        if ($maestro) {
            MaestroDao::eliminarMaestro($maestro["id_maestro"], $maestro["id_usuario"]);

            return array(
                "exito" => true,
                "mensaje" => "Maestro eliminado correctamente"
            );
        }

        return array(
            "exito" => false,
            "mensaje" => "No se encontró el maestro"
        );
    }
}
?>