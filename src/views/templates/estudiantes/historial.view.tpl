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
$idCarrera = $_SESSION["id_carrera"] ?? null;
$historial = HistorialDao::obtenerHistorialAcademico($idEstudiante, $idCarrera);
$indices = HistorialDao::obtenerIndicesAcademicos($idEstudiante, $idCarrera);

// Helper para calcular período de ingreso
if (!function_exists('calcularPeriodoIngreso')) {
    function calcularPeriodoIngreso($fechaCreacion) {
        $timestamp = strtotime($fechaCreacion);
        if (!$timestamp) return "Desconocido";
        $mes = intval(date('m', $timestamp));
        $anio = date('Y', $timestamp);
        if ($mes >= 1 && $mes <= 4) {
            $periodo = "Primer Período";
        } elseif ($mes >= 5 && $mes <= 8) {
            $periodo = "Segundo Período";
        } else {
            $periodo = "Tercer Período";
        }
        return "$anio $periodo";
    }
}

// Agrupar clases por año y luego por período
$aniosAgrupados = [];
foreach ($historial as $h) {
    $anio = $h["anio"] ?? "Otros";
    $periodo = $h["periodo"];
    $aniosAgrupados[$anio][$periodo][] = $h;
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
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center pb-3 mb-4 border-bottom gap-3">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">Historial Académico</h1>
                    </div>
                    <div class="d-flex gap-2 flex-wrap align-items-center w-100 w-md-auto">
                        <?php
                        require_once __DIR__ . "/../../../dao/EstudianteDao.php";
                        $estData = \Dao\EstudianteDao::obtenerEstudiantePorCorreo($_SESSION["correo"]);
                        if ($estData) {
                            $carrEst = \Dao\EstudianteDao::obtenerCarrerasEstudiante(intval($estData["id_estudiante"]));
                            if (count($carrEst) > 1):
                        ?>
                            <div class="d-flex align-items-center gap-2 w-100 w-md-auto mb-1 mb-md-0">
                                <label class="form-label mb-0 text-muted small" style="white-space: nowrap;"><i class="bi bi-arrow-left-right me-1"></i> Carrera:</label>
                                <select onchange="window.location='index.php?page=cambiar_carrera_activa&id_carrera=' + this.value" class="form-select form-select-sm flex-grow-1 w-md-auto header-carrera-select">
                                    <?php foreach ($carrEst as $car): ?>
                                        <option value="<?php echo intval($car['id_carrera']); ?>" <?php echo intval($_SESSION["id_carrera"]) === intval($car['id_carrera']) ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($car['nombre_carrera']); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        <?php 
                            endif;
                        }
                        ?>
                        
                        <a href="index.php?page=reporte_pdf&tipo=historial" class="btn btn-sm btn-outline-danger flex-grow-1 w-md-auto text-nowrap" target="_blank">
                            <i class="bi bi-file-earmark-pdf me-1"></i>Historial PDF
                        </a>
                        <a href="index.php?page=reporte_pdf&tipo=boleta_ultimo_periodo" class="btn btn-sm btn-danger flex-grow-1 w-md-auto text-nowrap" target="_blank">
                            <i class="bi bi-file-earmark-text me-1"></i>Boleta ultimo periodo
                        </a>
                    </div>
                </div>

                <!-- Resumen de Índices -->
                <div class="row g-4 mb-4">
                    <div class="col-md-4">
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
                    <div class="col-md-8">
                        <div class="card border-0 shadow-sm rounded-3 bg-light p-4 border">
                            <h6 class="text-muted text-uppercase fw-bold mb-2">Detalles del Estudiante</h6>
                            <div class="row">
                                <div class="col-12 col-md-6 mb-2">
                                    <span class="text-muted small">Nombre:</span>
                                    <div class="fw-bold text-dark text-truncate" title="<?php echo htmlspecialchars($estudiante["nombre"]); ?>"><?php echo htmlspecialchars($estudiante["nombre"]); ?></div>
                                </div>
                                <div class="col-12 col-md-6 mb-2">
                                    <span class="text-muted small">Cuenta/DNI:</span>
                                    <div class="fw-bold text-dark"><?php echo htmlspecialchars($estudiante["cuenta"]); ?></div>
                                </div>
                                <div class="col-12 col-md-6 mb-2 text-truncate">
                                    <?php
                                    $nombreCarreraMostrar = $estudiante["nombre_carrera"] ?? "General";
                                    if (isset($_SESSION["id_carrera"]) && $_SESSION["id_carrera"]) {
                                        require_once __DIR__ . "/../../../dao/CarreraDao.php";
                                        $carreraActivaInfo = \Dao\CarreraDao::obtenerCarreraPorId(intval($_SESSION["id_carrera"]));
                                        if ($carreraActivaInfo) {
                                            $nombreCarreraMostrar = $carreraActivaInfo["nombre_carrera"];
                                        }
                                    }
                                    ?>
                                    <span class="text-muted small">Carrera:</span>
                                    <div class="fw-bold text-primary text-truncate" title="<?php echo htmlspecialchars($nombreCarreraMostrar); ?>"><?php echo htmlspecialchars($nombreCarreraMostrar); ?></div>
                                </div>
                                <div class="col-12 col-md-6 mb-2">
                                    <span class="text-muted small">Campus / Sede:</span>
                                    <div class="fw-bold text-secondary"><?php echo htmlspecialchars($estudiante["campus"] ?? "Sin asignar"); ?></div>
                                </div>
                                <div class="col-12">
                                    <span class="text-muted small">Período de Ingreso:</span>
                                    <div class="fw-bold text-success"><?php echo htmlspecialchars(calcularPeriodoIngreso($estudiante["fecha_creacion"] ?? "")); ?></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filtros -->
                <div class="card border-0 shadow-sm rounded-3 p-3 mb-4 bg-light border">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="searchHistorial" class="form-label fw-bold text-secondary">Buscar Asignatura</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" id="searchHistorial" class="form-control border-start-0 ps-0" placeholder="Escriba nombre o código de materia...">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label for="statusFilter" class="form-label fw-bold text-secondary">Resultado</label>
                            <select id="statusFilter" class="form-select">
                                <option value="all">Todos</option>
                                <option value="aprobado">Aprobados</option>
                                <option value="reprobado">Reprobados</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label for="yearFilter" class="form-label fw-bold text-secondary">Año Académico</label>
                            <select id="yearFilter" class="form-select">
                                <option value="all">Todos los años</option>
                                <?php foreach (array_keys($aniosAgrupados) as $a): ?>
                                    <option value="<?php echo htmlspecialchars($a); ?>"><?php echo htmlspecialchars($a); ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Historial agrupado por año y periodo (Acordeones Collapsible) -->
                <?php if (!empty($aniosAgrupados)): ?>
                    <div class="accordion" id="accordionHistorial">
                        <?php
                        $idx = 0;
                        foreach ($aniosAgrupados as $anio => $periodos):
                            foreach ($periodos as $nombrePeriodo => $clases):
                                $idx++;
                                $accordionId = "collapse_" . $idx;
                                $headerId = "heading_" . $idx;
                                
                                // Buscar promedio de periodo
                                $promedioPeriodo = "0.00";
                                foreach ($indices["periodos"] as $ip) {
                                    if ($ip["periodo"] === $nombrePeriodo) {
                                        $promedioPeriodo = $ip["promedio_periodo"];
                                        break;
                                    }
                                }
                                ?>
                                <div class="accordion-item mb-3 border rounded shadow-sm overflow-hidden" data-year="<?php echo htmlspecialchars($anio); ?>">
                                    <h2 class="accordion-header" id="<?php echo $headerId; ?>">
                                        <button class="accordion-button collapsed fw-bold text-secondary bg-light d-flex justify-content-between align-items-center" type="button" data-bs-toggle="collapse" data-bs-target="#<?php echo $accordionId; ?>" aria-expanded="false" aria-controls="<?php echo $accordionId; ?>">
                                            <div class="d-flex align-items-center gap-2 flex-grow-1">
                                                <i class="bi bi-calendar3 text-primary fs-5"></i>
                                                <span><?php echo htmlspecialchars($nombrePeriodo); ?></span>
                                            </div>
                                            <span class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle px-3 py-2 fw-bold me-3" style="font-size: 12px; z-index: 5;">
                                                Promedio: <?php echo $promedioPeriodo; ?>%
                                            </span>
                                        </button>
                                    </h2>
                                    <div id="<?php echo $accordionId; ?>" class="accordion-collapse collapse" aria-labelledby="<?php echo $headerId; ?>" data-bs-parent="#accordionHistorial">
                                        <div class="accordion-body p-0">
                                            <ul class="list-group list-group-flush">
                                                <?php foreach ($clases as $c): 
                                                    $nota = floatval($c["nota"]);
                                                    $aprobada = $nota >= 70;
                                                    $badgeClass = $aprobada ? "border-success-subtle text-success bg-success-subtle" : "border-danger-subtle text-danger bg-danger-subtle";
                                                    $resultadoLabel = $aprobada ? "Aprobado" : "Reprobado";
                                                ?>
                                                    <li class="list-group-item d-flex flex-column flex-sm-row align-items-start align-items-sm-center justify-content-between p-3 gap-3 class-item" data-name="<?php echo htmlspecialchars(strtolower($c["nombre_materia"] . ' ' . $c["codigo_materia"])); ?>" data-status="<?php echo $aprobada ? 'aprobado' : 'reprobado'; ?>">
                                                        <div class="d-flex align-items-center gap-3">
                                                            <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center flex-shrink-0" style="width: 48px; height: 48px;">
                                                                <i class="bi bi-journal-bookmark-fill text-primary fs-4"></i>
                                                            </div>
                                                            <div>
                                                                <h6 class="mb-1 fw-bold text-dark text-uppercase" style="font-size: 15px;"><?php echo htmlspecialchars($c["nombre_materia"]); ?></h6>
                                                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                                                    <span class="badge bg-light text-secondary border px-2 py-1" style="font-size: 11px;"><?php echo htmlspecialchars($c["codigo_materia"]); ?></span>
                                                                    <span class="badge bg-light text-primary border px-2 py-1" style="font-size: 11px;"><?php echo number_format($nota, 2); ?>%</span>
                                                                    <span class="badge bg-light text-muted border px-2 py-1" style="font-size: 11px;"><?php echo htmlspecialchars($c["creditos"]); ?> UV</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <span class="badge border <?php echo $badgeClass; ?> rounded-pill px-3 py-2 fw-semibold" style="font-size: 12px;">
                                                                <?php echo $resultadoLabel; ?>
                                                            </span>
                                                        </div>
                                                    </li>
                                                <?php endforeach; ?>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                                <?php
                            endforeach;
                        endforeach;
                        ?>
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
<script>
document.addEventListener("DOMContentLoaded", function() {
    const searchInput = document.getElementById("searchHistorial");
    const statusSelect = document.getElementById("statusFilter");
    const yearSelect = document.getElementById("yearFilter");
    const accordionItems = document.querySelectorAll(".accordion-item");

    function filterHistorial() {
        const query = searchInput ? searchInput.value.toLowerCase().trim() : "";
        const status = statusSelect ? statusSelect.value : "all";
        const year = yearSelect ? yearSelect.value : "all";

        accordionItems.forEach(item => {
            const itemYear = item.getAttribute("data-year");
            const classes = item.querySelectorAll(".class-item");
            let visibleClassesCount = 0;

            classes.forEach(c => {
                const name = c.getAttribute("data-name");
                const cStatus = c.getAttribute("data-status");

                const matchesSearch = !query || name.includes(query);
                const matchesStatus = (status === "all") || (cStatus === status);

                if (matchesSearch && matchesStatus) {
                    c.style.setProperty("display", "flex", "important");
                    visibleClassesCount++;
                } else {
                    c.style.setProperty("display", "none", "important");
                }
            });

            const matchesYear = (year === "all") || (itemYear === year);

            if (visibleClassesCount > 0 && matchesYear) {
                item.style.setProperty("display", "block", "important");
            } else {
                item.style.setProperty("display", "none", "important");
            }
        });
    }

    if (searchInput) searchInput.addEventListener("input", filterHistorial);
    if (statusSelect) statusSelect.addEventListener("change", filterHistorial);
    if (yearSelect) yearSelect.addEventListener("change", filterHistorial);
});
</script>
</body>
</html>
