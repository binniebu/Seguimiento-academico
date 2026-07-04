<?php
// =========================================================================
// ESPACIO ASIGNADO PARA EL INTEGRANTE DE SECCIONES (Fullstack)
// =========================================================================
// 
// Indicaciones para el desarrollo del Módulo de Secciones:
// 
// 1. Funcionalidades a Desarrollar:
//    - Apertura de secciones por materia para el periodo académico activo.
//    - CRUD completo de Secciones (Crear, Editar, Listar y Eliminar).
//    - Clonación: Permitir clonar la oferta de secciones de un periodo anterior como "Borrador".
// 
// 2. Reglas de Validación de Negocio Críticas:
//    - Traslape de Aula: No permitir asignar una misma aula a dos secciones a la misma hora en el mismo periodo.
//    - Traslape de Maestro: Un maestro no puede impartir clases concurrentes a la misma hora.
//    - Restricción de Coordinación: Un maestro que es coordinador de facultad NO puede impartir clases en el periodo activo.
// 
// 3. DAOs de Referencia:
//    - Usar y extender \Dao\SeccionDao para las consultas de base de datos.
// 
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Secciones Académicas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar principal -->
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <!-- Panel principal -->
        <main class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card p-5 bg-white rounded shadow-sm text-center">
                
                <div class="py-5">
                    <i class="bi bi-calendar3 text-primary" style="font-size: 4rem;"></i>
                    <h2 class="mt-3">Gestión de Secciones Académicas</h2>
                    <p class="text-muted mx-auto" style="max-width: 500px;">
                        Espacio asignado para que el Integrante del equipo maquete la administración, traslapes y clonación de secciones (Fullstack).
                    </p>

                    <div class="d-flex justify-content-center gap-2 my-4">
                        <a href="index.php?page=seccion_nueva" class="btn btn-primary">
                            <i class="bi bi-plus-circle"></i> Abrir Nueva Sección (Formulario)
                        </a>
                    </div>
                    
                    <div class="alert alert-info d-inline-block text-start shadow-sm" style="max-width: 600px;">
                        <h6 class="fw-bold"><i class="bi bi-info-circle-fill"></i> Tareas y Validaciones Clave:</h6>
                        <small>
                            - <strong>Clonación:</strong> Botón para clonar la oferta de secciones de periodos académicos anteriores.<br>
                            - <strong>Validaciones:</strong> Bloquear registros en caso de colisión de horarios/días para un mismo docente o aula.<br>
                            - <strong>Roles:</strong> Coordinadores de facultad solo gestionan secciones de carreras de su facultad.
                        </small>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
