<?php

namespace Controllers;

require_once __DIR__ . "/../dao/EstudianteDao.php";

use Dao\EstudianteDao;

class EstudiantesController
{
    public static function listar()
    {
        $buscar = $_GET["buscar"] ?? "";
        return EstudianteDao::obtenerEstudiantes($buscar);
    }

    public static function buscar($buscar)
    {
        return EstudianteDao::obtenerEstudiantes($buscar);
    }

    public static function guardar()
    {
        $nombre = $_POST["nombre"] ?? "";
        $correo = $_POST["correo"] ?? "";
        $password = $_POST["password"] ?? "";
        $cuenta = $_POST["cuenta"] ?? "";
        $carrera = $_POST["carrera"] ?? "";
        $telefono = $_POST["telefono"] ?? "";
        // Si se envía id_estudiante, es una edición
        $id_estudiante = $_POST['id_estudiante'] ?? null;

        if (!empty($id_estudiante)) {
            // editar: password no es obligatorio
            if ($nombre == "" || $correo == "" || $cuenta == "" || $carrera == "") {
                echo "<script>
                        alert('Debe completar todos los campos');
                        window.location='index.php?page=estudiante_nuevo&id=" . intval($id_estudiante) . "';
                      </script>";
                exit();
            }

            $est = EstudianteDao::obtenerEstudiantePorId($id_estudiante);
            if (!$est) {
                echo "<script>
                        alert('Estudiante no encontrado');
                        window.location='index.php?page=estudiantes';
                      </script>";
                exit();
            }

            $id_usuario = $est['id_usuario'];

            $correoExistente = EstudianteDao::existeCorreo($correo);
            if ($correoExistente && $correoExistente['id_usuario'] != $id_usuario) {
                echo "<script>
                        alert('El correo ya está registrado por otro usuario');
                        window.location='index.php?page=estudiante_nuevo&id=" . intval($id_estudiante) . "';
                      </script>";
                exit();
            }

            $resultado = EstudianteDao::actualizarEstudiante(
                $id_estudiante,
                $id_usuario,
                $nombre,
                $correo,
                $cuenta,
                $carrera,
                $telefono
            );

            if ($resultado) {
                echo "<script>
                        alert('Estudiante actualizado correctamente');
                        window.location='index.php?page=estudiantes';
                      </script>";
                exit();
            }

            echo "<script>
                    alert('No se pudo actualizar el estudiante');
                    window.location='index.php?page=estudiante_nuevo&id=" . intval($id_estudiante) . "';
                  </script>";
            exit();
        }

        // Inserción nueva
        if ($nombre == "" || $correo == "" || $password == "" || $cuenta == "" || $carrera == "") {
            echo "<script>
                    alert('Debe completar todos los campos');
                    window.location='index.php?page=estudiante_nuevo';
                  </script>";
            exit();
        }

        if (EstudianteDao::existeCorreo($correo)) {
            echo "<script>
                    alert('El correo ya está registrado');
                    window.location='index.php?page=estudiante_nuevo';
                  </script>";
            exit();
        }

        $resultado = EstudianteDao::insertarEstudiante(
            $nombre,
            $correo,
            $password,
            $cuenta,
            $carrera,
            $telefono
        );

        if ($resultado) {
            echo "<script>
                    alert('Estudiante registrado correctamente');
                    window.location='index.php?page=estudiantes';
                  </script>";
            exit();
        }

        echo "<script>
                alert('No se pudo registrar el estudiante');
                window.location='index.php?page=estudiante_nuevo';
              </script>";
        exit();
    }

    public static function obtener($id = null)
    {
        if ($id === null) {
            $id = $_GET['id'] ?? null;
        }

        if ($id === null) return false;

        return EstudianteDao::obtenerEstudiantePorId($id);
    }

    public static function eliminar($id = null)
    {
        if ($id == null) {
            $id = $_GET["id"] ?? 0;
        }

        $estudiante = EstudianteDao::obtenerEstudiantePorId($id);

        if ($estudiante) {
            EstudianteDao::eliminarEstudiante($estudiante["id_estudiante"], $estudiante["id_usuario"]);

            return array(
                "exito" => true,
                "mensaje" => "Estudiante eliminado correctamente"
            );
        }

        return array(
            "exito" => false,
            "mensaje" => "No se encontró el estudiante"
        );
    }
}
?>
