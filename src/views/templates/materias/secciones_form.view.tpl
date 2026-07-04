<?php
// =========================================================================
// ESPACIO ASIGNADO PARA EL INTEGRANTE DE SECCIONES - FORMULARIO (Fullstack)
// =========================================================================
// 
// Indicaciones para el desarrollo del Formulario de Nueva Sección:
// 
// 1. Inputs Requeridos:
//    - Asignatura (Materia).
//    - Maestro asignado.
//    - Aula y Edificio.
//    - Horario (Hora Inicio / Hora Fin) y Días (Lunes-Viernes).
//    - Cupo Máximo.
// 
// 2. Validaciones a realizar en el Backend al Guardar:
//    - Validar traslapes de aula y docente en base a días y hora de inicio/fin.
// 
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Configuración de Sección Académica</title>
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
                    <i class="bi bi-file-earmark-plus text-primary" style="font-size: 4rem;"></i>
                    <h2 class="mt-3">Formulario de Nueva Sección</h2>
                    <p class="text-muted mx-auto" style="max-width: 500px;">
                        Espacio de maquetado del formulario de creación y edición de secciones con inputs de asignatura, maestro, aula, cupo y horario.
                    </p>

                    <div class="d-flex justify-content-center gap-2 my-4">
                        <a href="index.php?page=secciones" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left"></i> Volver a Secciones
                        </a>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
