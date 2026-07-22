
<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . "/../../../dao/SolicitudDao.php";

$rolActivo = $_SESSION["rol"] ?? "";
if (!isset($solicitudes)) {
    if ($rolActivo === "coordinador" && isset($_SESSION["id_facultad"])) {
        $solicitudes = \Dao\SolicitudDao::obtenerSolicitudesPendientesPorFacultad($_SESSION["id_facultad"], $_SESSION["id_campus"] ?? null);
    } else {
        $solicitudes = \Dao\SolicitudDao::obtenerSolicitudesPendientes();
    }
}

function solicitudDocumentoLink(?string $ruta, string $texto, string $icono): string
{
    if (empty($ruta)) {
        return '<span class="btn btn-sm btn-outline-secondary disabled"><i class="bi bi-file-earmark-x"></i> No disponible</span>';
    }

    return sprintf(
        '<a href="%s" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-primary"><i class="bi %s"></i> %s</a>',
        htmlspecialchars($ruta, ENT_QUOTES, "UTF-8"),
        htmlspecialchars($icono, ENT_QUOTES, "UTF-8"),
        htmlspecialchars($texto, ENT_QUOTES, "UTF-8")
    );
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Bandeja de Solicitudes de Admision</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <main class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card bg-white rounded shadow-sm p-4">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-1">Bandeja de Solicitudes de Admision</h1>
                        <p class="text-muted mb-0">
                            <?php if ($rolActivo === "coordinador"): ?>
                                Mostrando aspirantes pendientes de las carreras de tu facultad.
                            <?php else: ?>
                                Mostrando todas las solicitudes pendientes del sistema.
                            <?php endif; ?>
                        </p>
                    </div>
                    <span class="badge bg-primary fs-6">
                        <?php echo count($solicitudes); ?> pendiente<?php echo count($solicitudes) === 1 ? "" : "s"; ?>
                    </span>
                </div>

                <?php if (!empty($solicitudes)): ?>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Aspirante</th>
                                    <th>DNI / Identidad</th>
                                    <th>Carrera</th>
                                    <th>Campus / Sede</th>
                                    <th>Telefono</th>
                                    <th>Documentos</th>
                                    <th>Fecha</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($solicitudes as $solicitud): ?>
                                    <tr>
                                        <td>
                                            <div class="fw-semibold"><?php echo htmlspecialchars($solicitud["nombre"] ?? ""); ?></div>
                                            <div class="text-muted small"><?php echo htmlspecialchars($solicitud["correo"] ?? ""); ?></div>
                                        </td>
                                        <td><?php echo htmlspecialchars($solicitud["dni"] ?? ""); ?></td>
                                        <td><?php echo htmlspecialchars($solicitud["carrera"] ?? ""); ?></td>
                                        <td><span class="badge bg-light text-secondary border"><?php echo htmlspecialchars($solicitud["campus"] ?? "Sin asignar"); ?></span></td>
                                        <td><?php echo htmlspecialchars($solicitud["telefono"] ?? ""); ?></td>
                                        <td>
                                            <div class="d-flex flex-wrap gap-2">
                                                <?php echo solicitudDocumentoLink($solicitud["documento_dni"] ?? "", "Ver DNI / Identidad", "bi-person-vcard"); ?>
                                                <?php echo solicitudDocumentoLink($solicitud["documento_titulo"] ?? "", "Ver Titulo de Respaldo", "bi-file-earmark-medical"); ?>
                                            </div>
                                        </td>
                                        <td><?php echo htmlspecialchars($solicitud["fecha_creacion"] ?? ""); ?></td>
                                        <td class="text-end">
                                            <div class="d-inline-flex flex-wrap gap-2 justify-content-end">
                                                 <a href="index.php?page=solicitud_procesar&accion=aprobar&id=<?php echo urlencode($solicitud["id_usuario"] ?? ""); ?>"
                                                    class="btn btn-sm btn-success"
                                                    data-confirmar="¿Desea aprobar esta solicitud de admisión? Se generará la cuenta oficial del estudiante y se le notificará." 
                                                    data-titulo="Aprobar Admisión" 
                                                    data-confirm-text="Sí, admitir estudiante" 
                                                    data-icono="question">
                                                    <i class="bi bi-check-circle"></i> Aprobar
                                                </a>
                                                 <a href="index.php?page=solicitud_procesar&accion=rechazar&id=<?php echo urlencode($solicitud["id_usuario"] ?? ""); ?>"
                                                    class="btn btn-sm btn-danger"
                                                    data-confirmar="¿Está seguro de rechazar esta solicitud? Se eliminará la cuenta temporal del aspirante y los archivos adjuntos cargados en el sistema de forma permanente." 
                                                    data-titulo="Rechazar Admisión" 
                                                    data-confirm-text="Sí, rechazar" 
                                                    data-icono="warning">
                                                    <i class="bi bi-x-circle"></i> Rechazar
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php else: ?>
                    <div class="text-center py-5">
                        <i class="bi bi-inbox text-primary" style="font-size: 4rem;"></i>
                        <h2 class="h4 mt-3">No hay solicitudes pendientes</h2>
                        <p class="text-muted mb-0">
                            Cuando un aspirante complete el pre-registro, aparecera aqui para revisar sus documentos y tomar una decision.
                        </p>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
