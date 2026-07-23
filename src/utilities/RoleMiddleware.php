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

        // -----------------------------------------------------------------
        // Bloquear estudiante Inactivo / Bloqueado en cada request
        // -----------------------------------------------------------------
        if ($rol === "estudiante" && isset($_SESSION["correo"])) {
            require_once __DIR__ . "/../dao/MisMateriasDao.php";
            $estud = \Dao\MisMateriasDao::obtenerEstudiantePorCorreo($_SESSION["correo"]);
            if ($estud && in_array($estud["estado"] ?? "Admitido", ["Bloqueado", "Inactivo", "Suspendido"])) {
                session_destroy();
                echo "<script>
                        Swal ? Swal.fire({icon:'warning',title:'Cuenta inactiva',text:'Su cuenta se encuentra inactiva. Comuníquese con la administración académica.',confirmButtonColor:'#0057d8'}).then(()=>window.location='index.php?page=login') : (alert('Su cuenta se encuentra inactiva. Comuníquese con la administración.'), window.location='index.php?page=login');
                      </script>
                      <script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>";
                exit();
            }
        }

        $permisos = array(

            // ---------------------------------------------------------------
            // DIRECTOR — supervisión global + CRUD institucional + estudiantes
            // ---------------------------------------------------------------
            "director" => array(
                "home",
                "dashboard",

                // Personal docente
                "maestros",
                "maestro_nuevo",
                "maestro_guardar",
                "maestro_actualizar",
                "maestro_editar",
                "maestro_eliminar",

                // Gestión académica
                "materias",
                "materia_nueva",
                "materia_guardar",
                "materia_editar",
                "materia_inactivar",

                // Secciones
                "secciones",
                "seccion_nueva",
                "seccion_guardar",

                // Estructura institucional
                "facultades",
                "facultad_nueva",
                "facultad_guardar",
                "periodos",
                "carreras",
                "carrera_nueva",
                "carrera_guardar",
                "carrera_flujograma",

                // Campus / Sedes
                "campuses",
                "campus_nuevo",
                "campus_guardar",

                // Estudiantes: CRUD completo
                "estudiantes",
                "estudiante_nuevo",
                "estudiante_editar",
                "estudiante_guardar",
                "historial_alumno",

                // Admisiones
                "solicitudes_registro",
                "solicitud_detalle",
                "solicitud_procesar",

                "logout",
                "switch_role",
                "perfil",
                "perfil_actualizar"
            ),

            // ---------------------------------------------------------------
            // MAESTRO — solo sus secciones y notas (sin Materias, Matrículas, Calificaciones antiguas)
            // ---------------------------------------------------------------
            "maestro" => array(
                "home",
                "dashboard",

                // Sus secciones del periodo activo
                "secciones",

                // Módulo de notas por parciales
                "notas_maestro",
                "notas_alumnos_ajax",
                "guardar_nota_parciales",
                "historial_maestro",

                "logout",
                "switch_role",
                "perfil",
                "perfil_actualizar"
            ),

            // ---------------------------------------------------------------
            // ESTUDIANTE
            // ---------------------------------------------------------------
            "estudiante" => array(
                "home",
                "dashboard",
                "materias",
                "mis_materias",
                "mi_flujograma",
                "calificaciones",
                "matriculas_nueva",
                "matricula_estudiante",
                "actualizar_carrera",
                "logout",
                "historial_academico",
                "switch_role",
                "perfil",
                "perfil_actualizar"
            ),

            // ---------------------------------------------------------------
            // COORDINADOR — gestión operativa de su facultad
            //   Estudiantes: lectura + dar de baja / reactivar (NO editar datos)
            // ---------------------------------------------------------------
            "coordinador" => array(
                "home",
                "dashboard",

                // Estudiantes de su facultad (solo lectura + baja/reactivar)
                "estudiantes",
                "historial_alumno",

                // Carreras y materias de su facultad
                "carreras",
                "materias",
                "materia_nueva",
                "materia_guardar",
                "materia_editar",
                "carrera_flujograma",

                // Secciones: responsabilidad operativa
                "secciones",
                "seccion_nueva",
                "seccion_guardar",

                // Admisiones
                "solicitudes_registro",
                "solicitud_detalle",
                "solicitud_procesar",

                // Matrículas: puede ver
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

        if ($page === "matricula_estudiante" && $rol === "estudiante") {
            require_once __DIR__ . "/../controllers/MatriculasController.php";
            if (!\Controllers\MatriculasController::esPeriodoMatriculaActivo()) {
                echo "<script>
                        alert('La matrícula no está habilitada o el período académico ha expirado.');
                        window.location='index.php?page=home';
                      </script>";
                exit();
            }
        }

        return true;
    }
}
?>