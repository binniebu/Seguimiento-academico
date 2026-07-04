<?php
// =========================================================================
// ESPACIO ASIGNADO PARA EL INTEGRANTE DE ADMISIONES (Fullstack)
// =========================================================================
// 
// Indicaciones para el desarrollo del Módulo de Solicitudes:
// 
// 1. Lógica de Carga Segmentada por Rol (Ya implementada aquí abajo):
//    - Si el usuario activo es 'coordinador', solo ve aspirantes de su facultad.
//    - Si es 'director', ve todos los aspirantes del sistema de forma global.
// 
// 2. Acciones del Controlador:
//    - El botón de 'Aprobar' debe apuntar a: index.php?page=solicitud_procesar&accion=aprobar&id={id_usuario}
//    - El botón de 'Rechazar' debe apuntar a: index.php?page=solicitud_procesar&accion=rechazar&id={id_usuario}
// 
// 3. Lectura de Documentos:
//    - Los campos de archivos en la DB son `documento_dni` y `documento_titulo`.
//    - Enlazar a ellos directamente usando sus rutas relativas almacenadas en la DB.
// 
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . "/../../../dao/SolicitudDao.php";

$rolActivo = $_SESSION["rol"] ?? "";
if ($rolActivo === "coordinador" && isset($_SESSION["id_facultad"])) {
    $solicitudes = \Dao\SolicitudDao::obtenerSolicitudesPendientesPorFacultad($_SESSION["id_facultad"]);
} else {
    $solicitudes = \Dao\SolicitudDao::obtenerSolicitudesPendientes();
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Bandeja de Solicitudes de Admisión</title>
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
                    <i class="bi bi-file-earmark-text text-primary" style="font-size: 4rem;"></i>
                    <h2 class="mt-3">Bandeja de Solicitudes de Admisión</h2>
                    <p class="text-muted mx-auto" style="max-width: 500px;">
                        Este es el espacio asignado para que el Integrante del equipo maquete la bandeja de aprobación y rechazo de solicitudes de pre-registro (Fullstack).
                    </p>
                    
                    <div class="alert alert-info d-inline-block mt-3 text-start shadow-sm" style="max-width: 600px;">
                        <h6 class="fw-bold"><i class="bi bi-info-circle-fill"></i> Datos Listos en Backend:</h6>
                        <small>
                            La variable <code>$solicitudes</code> ya contiene todos los registros pendientes filtrados automáticamente según el rol del usuario logueado. Puedes recorrerla mediante un <code>foreach</code> para pintar la tabla y enlazar los documentos subidos.
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
