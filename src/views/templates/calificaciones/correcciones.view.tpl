<?php
require_once __DIR__ . "/../../../dao/CalificacionDao.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$solicitudes = \Dao\CalificacionDao::listarSolicitudesCorreccion();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Correcciones de Notas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-1">Correcciones de Notas</h1>
                            <div class="text-muted small">Aprobacion auditada de cambios posteriores en calificaciones.</div>
                        </div>
                    </div>
                    <a href="index.php?page=calificaciones" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Volver
                    </a>
                </div>

                <?php if (empty($solicitudes)): ?>
                    <div class="text-center py-5">
                        <i class="bi bi-clipboard-check text-muted fs-1 d-block mb-3"></i>
                        <h5 class="text-secondary">Sin solicitudes</h5>
                        <p class="text-muted mb-0">No hay correcciones de nota registradas.</p>
                    </div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Alumno</th>
                                    <th>Clase</th>
                                    <th>Periodo</th>
                                    <th>Cambio</th>
                                    <th>Motivo</th>
                                    <th>Estado</th>
                                    <th class="text-end">Accion</th>
                                </tr>
                            </thead>
                            <tbody>
                            <?php foreach ($solicitudes as $s): ?>
                                <?php
                                $estado = $s["estado"];
                                $badge = $estado === "pendiente" ? "bg-warning text-dark" : ($estado === "aprobada" ? "bg-success" : "bg-danger");
                                ?>
                                <tr>
                                    <td>
                                        <div class="fw-semibold"><?php echo htmlspecialchars($s["nombre_estudiante"]); ?></div>
                                        <div class="text-muted small"><?php echo htmlspecialchars($s["cuenta"]); ?></div>
                                    </td>
                                    <td>
                                        <div><?php echo htmlspecialchars($s["codigo_materia"] . " - " . $s["nombre_materia"]); ?></div>
                                        <div class="text-muted small">Solicita: <?php echo htmlspecialchars($s["solicitante"]); ?></div>
                                    </td>
                                    <td><?php echo htmlspecialchars($s["nombre_periodo"]); ?></td>
                                    <td>
                                        <div class="small">Promedio: <strong><?php echo htmlspecialchars($s["nota_anterior"]); ?></strong> -> <strong><?php echo htmlspecialchars($s["nota_nueva"]); ?></strong></div>
                                        <div class="small text-muted">
                                            P1 <?php echo htmlspecialchars($s["parcial1_anterior"] ?? "-"); ?> -> <?php echo htmlspecialchars($s["parcial1_nueva"] ?? "-"); ?>,
                                            P2 <?php echo htmlspecialchars($s["parcial2_anterior"] ?? "-"); ?> -> <?php echo htmlspecialchars($s["parcial2_nueva"] ?? "-"); ?>,
                                            P3 <?php echo htmlspecialchars($s["parcial3_anterior"] ?? "-"); ?> -> <?php echo htmlspecialchars($s["parcial3_nueva"] ?? "-"); ?>
                                        </div>
                                    </td>
                                    <td style="max-width: 260px;"><?php echo htmlspecialchars($s["motivo"]); ?></td>
                                    <td><span class="badge <?php echo $badge; ?>"><?php echo htmlspecialchars(ucfirst($estado)); ?></span></td>
                                    <td class="text-end">
                                        <?php if ($estado === "pendiente"): ?>
                                            <form method="POST" action="index.php?page=resolver_correccion_nota" class="d-inline">
                                                <input type="hidden" name="id_solicitud" value="<?php echo intval($s["id_solicitud"]); ?>">
                                                <input type="hidden" name="accion_resolucion" value="aprobar">
                                                <button class="btn btn-sm btn-success" type="submit">
                                                    <i class="bi bi-check-circle me-1"></i>Aprobar
                                                </button>
                                            </form>
                                            <form method="POST" action="index.php?page=resolver_correccion_nota" class="d-inline">
                                                <input type="hidden" name="id_solicitud" value="<?php echo intval($s["id_solicitud"]); ?>">
                                                <input type="hidden" name="accion_resolucion" value="rechazar">
                                                <button class="btn btn-sm btn-outline-danger" type="submit">
                                                    <i class="bi bi-x-circle me-1"></i>Rechazar
                                                </button>
                                            </form>
                                        <?php else: ?>
                                            <span class="text-muted small">
                                                <?php echo htmlspecialchars($s["aprobador"] ?? "Resuelto"); ?>
                                            </span>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
