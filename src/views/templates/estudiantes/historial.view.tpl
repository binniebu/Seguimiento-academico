<?php
require_once __DIR__ . "/../../../dao/HistorialDao.php";
require_once __DIR__ . "/../../../dao/MatriculaDao.php";

use Dao\HistorialDao;
use Dao\MatriculaDao;

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$idUsuario = $_SESSION["id_usuario"] ?? null;
$estudiante = MatriculaDao::obtenerEstudiantePorUsuario($idUsuario);

if (!$estudiante) {
    echo "<h3>No se encontró el estudiante relacionado con este usuario.</h3>";
    exit();
}

$idEstudiante = $estudiante["id_estudiante"];
$historial = HistorialDao::obtenerHistorialAcademico($idEstudiante);
$indices = HistorialDao::obtenerIndicesAcademicos($idEstudiante);

// Agrupar clases por período académico
$periodosAgrupados = [];
foreach ($historial as $h) {
    $periodosAgrupados[$h["periodo"]][] = $h;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial Académico</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <!-- Main content -->
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                
                <!-- Cabecera del Historial -->
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">Historial Académico</h1>
                    </div>
                </div>

                <!-- Resumen de Índices -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="card border-0 shadow-sm rounded-3 bg-primary text-white p-4">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="text-white-50 text-uppercase fw-bold mb-1">Índice Académico Global</h6>
                                    <h1 class="display-5 fw-bold mb-0"><?php echo htmlspecialchars($indices["promedio_global"] ?? "0.00"); ?>%</h1>
                                </div>
                                <i class="bi bi-award fs-1 text-white-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card border-0 shadow-sm rounded-3 bg-light p-4 border">
                            <h6 class="text-muted text-uppercase fw-bold mb-2">Detalles del Estudiante</h6>
                            <div class="row">
                                <div class="col-6 mb-2">
                                    <span class="text-muted small">Nombre:</span>
                                    <div class="fw-bold text-dark"><?php echo htmlspecialchars($estudiante["nombre"]); ?></div>
                                </div>
                                <div class="col-6 mb-2">
                                    <span class="text-muted small">Cuenta/DNI:</span>
                                    <div class="fw-bold text-dark"><?php echo htmlspecialchars($estudiante["cuenta"]); ?></div>
                                </div>
                                <div class="col-12">
                                    <span class="text-muted small">Carrera:</span>
                                    <div class="fw-bold text-primary"><?php echo htmlspecialchars($estudiante["nombre_carrera"] ?? "General"); ?></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Historial agrupado por períodos -->
                <?php if (!empty($periodosAgrupados)): ?>
                    <div class="d-flex flex-column gap-4">
                        <?php foreach ($periodosAgrupados as $nombrePeriodo => $clases): ?>
                            <div class="card border-0 shadow-sm rounded-3">
                                <div class="card-header bg-light py-3 rounded-top-3 d-flex justify-content-between align-items-center">
                                    <h5 class="card-title mb-0 fw-bold text-secondary">
                                        <i class="bi bi-calendar3 me-2"></i><?php echo htmlspecialchars($nombrePeriodo); ?>
                                    </h5>
                                    <?php 
                                    // Buscar índice de este periodo específico
                                    $promedioPeriodo = "0.00";
                                    foreach ($indices["periodos"] as $ip) {
                                        if ($ip["periodo"] === $nombrePeriodo) {
                                            $promedioPeriodo = $ip["promedio_periodo"];
                                            break;
                                        }
                                    }
                                    ?>
                                    <span class="badge bg-primary px-3 py-2 fw-bold" style="font-size: 13px;">
                                        Promedio Periodo: <?php echo $promedioPeriodo; ?>%
                                    </span>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle mb-0">
                                            <thead>
                                                <tr>
                                                    <th class="ps-4">Código</th>
                                                    <th>Asignatura</th>
                                                    <th class="text-center">U.V. (Créditos)</th>
                                                    <th class="text-center">Calificación</th>
                                                    <th class="text-center">Resultado</th>
                                                    <th class="pe-4 text-end">Fecha Registro</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($clases as $c): 
                                                    $nota = floatval($c["nota"]);
                                                    $aprobada = $nota >= 70;
                                                    $badgeStyle = $aprobada ? "bg-success-subtle text-success border-success-subtle" : "bg-danger-subtle text-danger border-danger-subtle";
                                                    $resultadoLabel = $aprobada ? "APROBADO" : "REPROBADO";
                                                ?>
                                                    <tr>
                                                        <td class="ps-4 fw-bold text-dark"><?php echo htmlspecialchars($c["codigo_materia"]); ?></td>
                                                        <td class="fw-semibold text-secondary"><?php echo htmlspecialchars($c["nombre_materia"]); ?></td>
                                                        <td class="text-center"><?php echo htmlspecialchars($c["creditos"]); ?></td>
                                                        <td class="text-center fw-bold fs-5 text-dark"><?php echo number_format($nota, 2); ?>%</td>
                                                        <td class="text-center">
                                                            <span class="badge border <?php echo $badgeStyle; ?> px-3 py-2">
                                                                <?php echo $resultadoLabel; ?>
                                                            </span>
                                                        </td>
                                                        <td class="pe-4 text-end text-muted small">
                                                            <?php echo htmlspecialchars(date('d/m/Y', strtotime($c["fecha_registro"]))); ?>
                                                        </td>
                                                    </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="card border-0 shadow-sm rounded-3 py-5 text-center">
                        <div class="card-body">
                            <i class="bi bi-journal-x text-muted fs-1 d-block mb-3"></i>
                            <h5 class="text-secondary">Historial Vacío</h5>
                            <p class="text-muted mb-0">Aún no posee calificaciones registradas en el sistema para periodos finalizados.</p>
                        </div>
                    </div>
                <?php endif; ?>

            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
