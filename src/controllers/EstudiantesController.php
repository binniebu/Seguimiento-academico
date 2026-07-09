<?php

namespace Controllers;

require_once __DIR__ . "/../dao/EstudianteDao.php";

use Dao\EstudianteDao;

class EstudiantesController
{
    private static function mostrarSweetAlert($mensaje, $tipo, $url, $titulo = "Aviso")
    {
        echo "<!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8'>
            <script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>
            <style>
                body { font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; }
            </style>
        </head>
        <body>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    Swal.fire({
                        icon: '{$tipo}',
                        title: '{$titulo}',
                        text: '{$mensaje}',
                        confirmButtonColor: '#0057d8'
                    }).then(function() {
                        window.location = '{$url}';
                    });
                });
            </script>
        </body>
        </html>";
        exit();
    }

    public static function listar()
    {
        $buscar = $_GET["buscar"] ?? "";
        $ver = $_GET["ver"] ?? "";
        $soloInactivos = ($ver === "inactivos");
        return EstudianteDao::obtenerEstudiantes($buscar, $soloInactivos);
    }

    public static function buscar($buscar)
    {
        $ver = $_GET["ver"] ?? "";
        $soloInactivos = ($ver === "inactivos");
        return EstudianteDao::obtenerEstudiantes($buscar, $soloInactivos);
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
                self::mostrarSweetAlert("Debe completar todos los campos obligatorios.", "warning", "index.php?page=estudiante_nuevo&id=" . intval($id_estudiante), "Campos Incompletos");
            }

            $est = EstudianteDao::obtenerEstudiantePorId($id_estudiante);
            if (!$est) {
                self::mostrarSweetAlert("Estudiante no encontrado en el sistema.", "error", "index.php?page=estudiantes", "Error");
            }

            $id_usuario = $est['id_usuario'];

            $correoExistente = EstudianteDao::existeCorreo($correo);
            if ($correoExistente && $correoExistente['id_usuario'] != $id_usuario) {
                self::mostrarSweetAlert("El correo electrónico ya está registrado por otro usuario.", "warning", "index.php?page=estudiante_nuevo&id=" . intval($id_estudiante), "Correo Duplicado");
            }

            $cuentaExistente = EstudianteDao::existeCuenta($cuenta);
            if ($cuentaExistente && $cuentaExistente['id_estudiante'] != $id_estudiante) {
                self::mostrarSweetAlert("El DNI o Número de cuenta ya está registrado por otro estudiante.", "warning", "index.php?page=estudiante_nuevo&id=" . intval($id_estudiante), "Identificación Duplicada");
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
                self::mostrarSweetAlert("Estudiante actualizado correctamente en el sistema.", "success", "index.php?page=estudiantes", "Actualización Exitosa");
            }

            self::mostrarSweetAlert("No se pudo actualizar la información del estudiante.", "error", "index.php?page=estudiante_nuevo&id=" . intval($id_estudiante), "Error de Base de Datos");
        }

        // Inserción nueva
        if ($nombre == "" || $correo == "" || $password == "" || $cuenta == "" || $carrera == "") {
            self::mostrarSweetAlert("Debe completar todos los campos obligatorios para registrar al estudiante.", "warning", "index.php?page=estudiante_nuevo", "Campos Incompletos");
        }

        if (EstudianteDao::existeCorreo($correo)) {
            self::mostrarSweetAlert("El correo electrónico ya está registrado en el sistema.", "warning", "index.php?page=estudiante_nuevo", "Correo Duplicado");
        }

        if (EstudianteDao::existeCuenta($cuenta)) {
            self::mostrarSweetAlert("El DNI o Número de cuenta ya está registrado en el sistema.", "warning", "index.php?page=estudiante_nuevo", "Identificación Duplicada");
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
            self::mostrarSweetAlert("Estudiante registrado y admitido correctamente.", "success", "index.php?page=estudiantes", "Registro Exitoso");
        }

        self::mostrarSweetAlert("No se pudo registrar al estudiante en la base de datos.", "error", "index.php?page=estudiante_nuevo", "Error de Base de Datos");
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
                "mensaje" => "Estudiante dado de baja correctamente"
            );
        }

        return array(
            "exito" => false,
            "mensaje" => "No se encontró el estudiante"
        );
    }

    public static function activar($id = null)
    {
        if ($id == null) {
            $id = $_GET["id"] ?? 0;
        }

        $estudiante = EstudianteDao::obtenerEstudiantePorId($id);

        if ($estudiante) {
            EstudianteDao::activarEstudiante($estudiante["id_estudiante"], $estudiante["id_usuario"]);

            return array(
                "exito" => true,
                "mensaje" => "Estudiante reactivado correctamente"
            );
        }

        return array(
            "exito" => false,
            "mensaje" => "No se encontró el estudiante"
        );
    }
}
?>
