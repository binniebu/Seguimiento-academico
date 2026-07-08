<?php

namespace Utilities;

class RoleMiddleware
{
    public static function checkAccess($page)
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $paginasPublicas = array("login", "register", "logout");

        if (in_array($page, $paginasPublicas)) {
            return true;
        }

        if (!isset($_SESSION["usuario"])) {
            header("Location: index.php?page=login");
            exit();
        }

        $rol = $_SESSION["rol"] ?? "";

        // Validar si el estudiante está bloqueado o inactivo
        if ($rol === "estudiante" && isset($_SESSION["correo"])) {
            require_once __DIR__ . "/../dao/MisMateriasDao.php";
            $estud = \Dao\MisMateriasDao::obtenerEstudiantePorCorreo($_SESSION["correo"]);
            if ($estud && in_array($estud["estado"] ?? "Admitido", ["Bloqueado", "Inactivo"])) {
                session_destroy();
                echo "<script>
                        alert('Su cuenta se encuentra bloqueada o inactiva. Comuníquese con la administración.');
                        window.location='index.php?page=login';
                      </script>";
                exit();
            }
        }

        $permisos = array(
            "director" => array(
                "home",
                "dashboard",
                "estudiantes",
                "estudiante_nuevo",
                "estudiante_guardar",
                "estudiante_editar",
                "estudiante_eliminar",
                "maestros",
                "maestro_nuevo",
                "maestro_guardar",
                "maestro_actualizar",
                "maestro_editar",
                "maestro_eliminar",
                "materias",
                "materia_nueva",
                "materia_guardar",
                "materia_editar",
                "materia_eliminar",
                "matriculas",
                "matricula_nueva",
                "matricula_guardar",
                "matricula_editar",
                "matricula_eliminar",

                "mis_materias",
                "logout",
                "facultades",
                "facultad_nueva",
                "facultad_guardar",
                "carreras",
                "carrera_nueva",
                "carrera_guardar",
                "carrera_flujograma",
                "secciones",

                "switch_role",
                "perfil",
                "perfil_actualizar"
            ),
            "maestro" => array(
                "home",
                "dashboard",
                "materias",
                "materia_ver",
                "matriculas",
                "calificaciones",
                "Calificaciones",
                "Calificacion",
                "calificacion_nueva",
                "calificacion_editar",
                "logout",
                "switch_role",
                "perfil",
                "perfil_actualizar"
            ),
            "estudiante" => array(
    "home",
    "dashboard",

    "materias",
    "mis_materias",

    "matriculas_nueva",
    "actualizar_carrera",
    

    "calificaciones",

    "logout",
    "historial_academico",
    "switch_role",
    "perfil",
    "perfil_actualizar"
),
            "coordinador" => array(
                "home",
                "dashboard",
                "estudiantes",
                "estudiante_editar",
                "estudiante_guardar",
                "carreras",
                "materias",
                "materia_nueva",
                "carrera_flujograma",
                "secciones",
                "seccion_nueva",
                "seccion_guardar",
                "solicitudes_registro",
                "solicitud_procesar",
                "matriculas",
                "matricula_nueva",
                "logout",
                "switch_role",
                "perfil",
                "perfil_actualizar"
            ),
        );

        if (!isset($permisos[$rol])) {
            header("Location: index.php?page=login");
            exit();
        }

        if (!in_array($page, $permisos[$rol])) {
            echo "<script>
                    alert('No tiene permiso para acceder a esta sección');
                    window.location='index.php?page=home';
                  </script>";
            exit();
        }

        return true;
    }
}
?>