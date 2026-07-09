<?php
require_once __DIR__ . "/../../../dao/HistorialDao.php";
require_once __DIR__ . "/../../../dao/MatriculaDao.php";
require_once __DIR__ . "/../../../dao/PeriodoDao.php";

use Dao\HistorialDao;
use Dao\MatriculaDao;
use Dao\PeriodoDao;

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
$periodoActivo = PeriodoDao::obtenerPeriodoActivo();

$cursando = [];
$periodoVigente = false;

if ($periodoActivo) {
    $hoy = date('Y-m-d');
    $limiteNotas = date('Y-m-d', strtotime($periodoActivo["fecha_fin"] . ' +7 days'));
    if ($hoy <= $limiteNotas) {
        $periodoVigente = true;
        $cursando = HistorialDao::obtenerClasesActualmenteCursando($idEstudiante);
    }
}

// Funcion auxiliar para renderizar los dias de forma legible
if (!function_exists('diasLabel')) {
    function diasLabel($dias) {
        return str_replace(",", "-", (string) $dias);
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Asignaturas en Curso</title>
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
                
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">Mis Asignaturas en Curso</h1>
                    </div>
                </div>

                <!-- Cabecera Informativa -->
                <div class="card border-0 shadow-sm mb-4 rounded-3 bg-light border">
                    <div class="card-body p-4 d-flex flex-wrap justify-content-between align-items-center gap-3">
                        <div>
                            <span class="text-muted small text-uppercase fw-bold">Estudiante</span>
                            <h4 class="mb-1 text-dark fw-bold"><?php echo htmlspecialchars($estudiante["nombre"]); ?></h4>
                            <p class="text-muted mb-0 small">
                                Cuenta: <span class="fw-semibold text-dark"><?php echo htmlspecialchars($estudiante["cuenta"]); ?></span> | 
                                Carrera: <span class="fw-semibold text-dark"><?php echo htmlspecialchars($estudiante["nombre_carrera"] ?? "General"); ?></span>
                            </p>
                        </div>
                        <?php if ($periodoActivo): ?>
                            <div class="text-md-end">
                                <span class="text-muted small text-uppercase fw-bold">Periodo Académico Activo</span>
                                <div class="fs-5 fw-bold text-primary"><?php echo htmlspecialchars($periodoActivo["nombre_periodo"]); ?></div>
                                <span class="badge bg-info-subtle text-info border border-info-subtle px-2 py-1 mt-1">
                                    Finaliza el: <?php echo htmlspecialchars($periodoActivo["fecha_fin"]); ?>
                                </span>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>

                <!-- Listado de Clases Cursando con Notas -->
                <div class="card border-0 shadow-sm rounded-3">
                    <div class="card-body p-4">
                        <?php if ($periodoVigente): ?>
                            <?php if (!empty($cursando)): ?>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th>Código/Sección</th>
                                                <th>Asignatura</th>
                                                <th>Docente</th>
                                                <th>Horario / Aula</th>
                                                <th class="text-center bg-light border-start">I Parcial</th>
                                                <th class="text-center bg-light">II Parcial</th>
                                                <th class="text-center bg-light border-end">III Parcial</th>
                                                <th class="text-center">Promedio</th>
                                                <th class="text-center">Créditos</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach ($cursando as $c): 
                                                // Leer parciales reales guardados por el maestro.
                                                // Si el maestro aun no ha ingresado el parcial, se muestra '-'.
                                                $p1Real = $c["nota_parcial1"] !== null ? number_format(floatval($c["nota_parcial1"]), 2) : null;
                                                $p2Real = $c["nota_parcial2"] !== null ? number_format(floatval($c["nota_parcial2"]), 2) : null;
                                                $p3Real = $c["nota_parcial3"] !== null ? number_format(floatval($c["nota_parcial3"]), 2) : null;
                                                $p1 = $p1Real ?? '-';
                                                $p2 = $p2Real ?? '-';
                                                $p3 = $p3Real ?? '-';
                                                $tieneParciales = ($p1Real !== null || $p2Real !== null || $p3Real !== null);
 
                                                // Promedio: usar el guardado en BD (calculado por el maestro) si existe
                                                $tieneNota = $c["nota"] !== null;
                                                if ($tieneNota) {
                                                    $promedioVal = number_format(floatval($c["nota"]), 2) . "%";
                                                    
                                                    // Solo se aprueba o reprueba si se tienen las tres notas ingresadas
                                                    if ($p1Real !== null && $p2Real !== null && $p3Real !== null) {
                                                        $aprobado = floatval($c["nota"]) >= 70;
                                                        $badgeClass = $aprobado ? "bg-success-subtle text-success border-success-subtle" : "bg-danger-subtle text-danger border-danger-subtle";
                                                        $promedioText = $aprobado ? "APROBADO" : "REPROBADO";
                                                    } else {
                                                        // Falta ingresar nota de algún parcial, se muestra Cursando
                                                        $badgeClass = "bg-info-subtle text-info border-info-subtle";
                                                        $promedioText = "CURSANDO";
                                                    }
                                                } else {
                                                    $promedioVal = "En Curso";
                                                    $badgeClass = "bg-warning-subtle text-warning border-warning-subtle";
                                                    $promedioText = "PENDIENTE";
                                                }
                                            ?>
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold text-dark mb-1"><?php echo htmlspecialchars($c["codigo_seccion"]); ?></div>
                                                        <span class="badge bg-light text-secondary border small"><?php echo htmlspecialchars($c["codigo_materia"]); ?></span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold text-secondary"><?php echo htmlspecialchars($c["nombre_materia"]); ?></div>
                                                        <?php if (!empty($c["observacion"])): ?>
                                                            <div class="text-muted small mt-1"><i class="bi bi-info-circle me-1"></i><?php echo htmlspecialchars($c["observacion"]); ?></div>
                                                        <?php endif; ?>
                                                    </td>
                                                    <td class="text-muted small"><?php echo htmlspecialchars($c["nombre_maestro"]); ?></td>
                                                    <td>
                                                        <div class="fw-semibold text-dark mb-1"><?php echo htmlspecialchars(diasLabel($c["dias"])); ?></div>
                                                        <span class="text-muted small"><?php echo htmlspecialchars(substr($c["hora_inicio"], 0, 5) . " - " . substr($c["hora_fin"], 0, 5)); ?></span> |
                                                        <span class="badge bg-light text-dark border small"><?php echo htmlspecialchars($c["aula"]); ?></span>
                                                    </td>
                                                    <!-- Notas Parciales: muestra el valor real o '—' si el maestro aun no lo ingresa -->
                                                    <td class="text-center bg-light border-start fw-semibold text-secondary">
                                                        <?php echo $p1; ?><?php echo $p1Real !== null ? '%' : ''; ?>
                                                    </td>
                                                    <td class="text-center bg-light fw-semibold text-secondary">
                                                        <?php echo $p2; ?><?php echo $p2Real !== null ? '%' : ''; ?>
                                                    </td>
                                                    <td class="text-center bg-light border-end fw-semibold text-secondary">
                                                        <?php echo $p3; ?><?php echo $p3Real !== null ? '%' : ''; ?>
                                                    </td>
                                                    <!-- Promedio y Estado -->
                                                    <td class="text-center">
                                                        <div class="fw-bold fs-6 text-dark mb-1"><?php echo $promedioVal; ?></div>
                                                        <span class="badge border <?php echo $badgeClass; ?> px-2 py-1" style="font-size: 11px;"><?php echo $promedioText; ?></span>
                                                    </td>
                                                    <td class="text-center"><?php echo htmlspecialchars($c["creditos"]); ?></td>
                                                </tr>
                                            <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            <?php else: ?>
                                <div class="text-center py-5">
                                    <i class="bi bi-journal-x text-muted fs-1 d-block mb-3"></i>
                                    <h5 class="text-secondary">No tiene materias inscritas</h5>
                                    <p class="text-muted mb-0">No ha matriculado asignaturas para este periodo aún.</p>
                                </div>
                            <?php endif; ?>
                        <?php else: ?>
                            <div class="text-center py-5">
                                <i class="bi bi-calendar-x text-muted fs-1 d-block mb-3"></i>
                                <h5 class="text-danger fw-bold">Periodo Académico Finalizado</h5>
                                <p class="text-muted mb-3">
                                    El período académico vigente ha culminado oficialmente. Las asignaturas cursadas han sido transferidas a su expediente definitivo.
                                </p>
                                <a href="index.php?page=historial_academico" class="btn btn-primary px-4">
                                    <i class="bi bi-file-earmark-text me-1"></i> Ir al Historial Académico
                                </a>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>