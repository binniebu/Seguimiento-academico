<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$rolActual = $_SESSION["rol"] ?? "";
if (!in_array($rolActual, ["director", "coordinador", "maestro"], true)) {
    header("Location: index.php?page=home");
    exit();
}

require_once __DIR__ . "/../../../controllers/EstadisticasController.php";
$datos = \Controllers\EstadisticasController::obtenerDatosDashboard();

// Helper para limpiar encodificación si fuese necesario
if (!function_exists('fixDoubleEncoding')) {
    function fixDoubleEncoding($str) {
        if (strpos($str, '├') !== false || strpos($str, '┬') !== false) {
            return mb_convert_encoding($str, 'ISO-8859-1', 'UTF-8');
        }
        return $str;
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas Académicas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .card-stats {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            background: #ffffff;
            height: 100%;
        }
        .card-stats:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
        }
        .card-header-stats {
            background: transparent;
            border-bottom: 1px solid #f1f5f9;
            padding: 20px;
        }
        .card-body-stats {
            padding: 24px;
            position: relative;
        }
        .kpi-title {
            font-size: 14px;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .kpi-value {
            font-size: 28px;
            font-weight: 700;
            color: #0f172a;
        }
        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
        }
    </style>
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
                        <h1 class="h2 page-title mb-0">
                            <i class="bi bi-bar-chart-line text-primary me-2"></i>Estadísticas Académicas
                        </h1>
                    </div>
                    <div class="text-muted small">
                        <?php if ($rolActual === 'coordinador'): ?>
                            Facultad: <strong><?= htmlspecialchars($_SESSION["nombre_facultad"] ?? 'Asignada') ?></strong>
                        <?php elseif ($rolActual === 'maestro'): ?>
                            Secciones y Alumnos Propios
                        <?php else: ?>
                            Vista General (Director)
                        <?php endif; ?>
                    </div>
                </div>

                <!-- Tarjetas KPI Resumen -->
                <div class="row g-4 mb-4">
                    <div class="col-md-4">
                        <div class="card card-stats">
                            <div class="card-body-stats d-flex align-items-center justify-content-between">
                                <div>
                                    <div class="kpi-title">Alumnos Activos</div>
                                    <div class="kpi-value" id="kpi-total-alumnos">0</div>
                                </div>
                                <div class="bg-light-primary text-primary rounded-circle p-3 fs-3 d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; background-color: #e0f2fe;">
                                    <i class="bi bi-people"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card card-stats">
                            <div class="card-body-stats d-flex align-items-center justify-content-between">
                                <div>
                                    <div class="kpi-title">Asignaturas Programadas</div>
                                    <div class="kpi-value" id="kpi-total-materias">0</div>
                                </div>
                                <div class="bg-light-success text-success rounded-circle p-3 fs-3 d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; background-color: #d1fae5;">
                                    <i class="bi bi-journal-bookmark"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card card-stats">
                            <div class="card-body-stats d-flex align-items-center justify-content-between">
                                <div>
                                    <div class="kpi-title">Índice de Aprobación</div>
                                    <div class="kpi-value" id="kpi-indice-aprobacion">0%</div>
                                </div>
                                <div class="bg-light-warning text-warning rounded-circle p-3 fs-3 d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; background-color: #fef3c7;">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Gráficos fila 1 -->
                <div class="row g-4 mb-4">
                    <?php if ($rolActual === 'director'): ?>
                        <div class="col-lg-6">
                            <div class="card card-stats">
                                <div class="card-header-stats">
                                    <h5 class="card-title mb-0"><i class="bi bi-geo-alt me-2 text-primary"></i>Alumnos por Campus</h5>
                                </div>
                                <div class="card-body-stats">
                                    <div class="chart-container">
                                        <canvas id="chartCampus"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="card card-stats">
                                <div class="card-header-stats">
                                    <h5 class="card-title mb-0"><i class="bi bi-mortarboard me-2 text-primary"></i>Alumnos por Carrera</h5>
                                </div>
                                <div class="card-body-stats">
                                    <div class="chart-container">
                                        <canvas id="chartCarreras"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php else: ?>
                        <!-- Si es Coordinador o Maestro -->
                        <div class="col-lg-6">
                            <div class="card card-stats">
                                <div class="card-header-stats">
                                    <h5 class="card-title mb-0">
                                        <i class="bi bi-mortarboard me-2 text-primary"></i>
                                        <?php echo $rolActual === 'maestro' ? 'Alumnos por Sección' : 'Alumnos por Carrera'; ?>
                                    </h5>
                                </div>
                                <div class="card-body-stats">
                                    <div class="chart-container">
                                        <canvas id="chartCarreras"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="card card-stats">
                                <div class="card-header-stats">
                                    <h5 class="card-title mb-0"><i class="bi bi-pie-chart me-2 text-success"></i>Tasa de Aprobación vs Reprobación</h5>
                                </div>
                                <div class="card-body-stats">
                                    <div class="chart-container">
                                        <canvas id="chartAprobacion"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>

                <!-- Gráficos fila 2 -->
                <div class="row g-4 mb-4">
                    <div class="<?php echo $rolActual === 'maestro' ? 'col-lg-12' : 'col-lg-7'; ?>">
                        <div class="card card-stats">
                            <div class="card-header-stats">
                                <h5 class="card-title mb-0">
                                    <i class="bi bi-activity me-2 text-primary"></i>
                                    <?php echo $rolActual === 'maestro' ? 'Promedio de Calificaciones por Sección' : 'Rendimiento: Asignaturas con Mayor Promedio'; ?>
                                </h5>
                            </div>
                            <div class="card-body-stats">
                                <div class="chart-container">
                                    <canvas id="chartRendimiento"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    <?php if ($rolActual !== 'maestro'): ?>
                        <div class="col-lg-5">
                            <div class="card card-stats">
                                <div class="card-header-stats">
                                    <h5 class="card-title mb-0"><i class="bi bi-calendar-check me-2 text-primary"></i>Estado de Secciones de Clases</h5>
                                </div>
                                <div class="card-body-stats">
                                    <div class="chart-container">
                                        <canvas id="chartSecciones"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>

                <?php if ($rolActual === 'director'): ?>
                    <!-- Fila adicional de Aprobación para el Director -->
                    <div class="row g-4">
                        <div class="col-lg-6 mx-auto">
                            <div class="card card-stats">
                                <div class="card-header-stats text-center">
                                    <h5 class="card-title mb-0"><i class="bi bi-pie-chart me-2 text-success"></i>Tasa de Aprobación vs Reprobación Global</h5>
                                </div>
                                <div class="card-body-stats">
                                    <div class="chart-container">
                                        <canvas id="chartAprobacion"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <?php endif; ?>

            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Datos PHP codificados a JS
    const rawCampus = <?php echo json_encode($datos["por_campus"] ?? []); ?>;
    const rawCarrera = <?php echo json_encode($datos["por_carrera"] ?? []); ?>;
    const rawRendimiento = <?php echo json_encode($datos["promedios_materias"] ?? []); ?>;
    const rawAprobacion = <?php echo json_encode($datos["aprobados_vs_reprobados"] ?? []); ?>;
    const rawSecciones = <?php echo json_encode($datos["estado_secciones"] ?? []); ?>;

    // Calcular KPIs
    // 1. Total alumnos
    let totalAlumnos = 0;
    if (rawCampus.length > 0) {
        totalAlumnos = rawCampus.reduce((acc, curr) => acc + parseInt(curr.total), 0);
    } else if (rawCarrera.length > 0) {
        totalAlumnos = rawCarrera.reduce((acc, curr) => acc + parseInt(curr.total), 0);
    }
    document.getElementById('kpi-total-alumnos').innerText = totalAlumnos;

    // 2. Asignaturas únicas
    document.getElementById('kpi-total-materias').innerText = rawRendimiento.length;

    // 3. Índice de Aprobación
    const totalNotas = rawAprobacion.aprobados + rawAprobacion.reprobados;
    let porcAprobacion = 0;
    if (totalNotas > 0) {
        porcAprobacion = Math.round((rawAprobacion.aprobados / totalNotas) * 100);
    }
    document.getElementById('kpi-indice-aprobacion').innerText = porcAprobacion + '%';

    // CONFIGURACIÓN DE GRÁFICOS
    const colors = [
        'rgba(0, 87, 216, 0.85)',   // primary blue
        'rgba(16, 185, 129, 0.85)',  // success green
        'rgba(255, 196, 0, 0.85)',   // warning amber
        'rgba(239, 68, 68, 0.85)',   // danger red
        'rgba(139, 92, 246, 0.85)',  // purple
        'rgba(249, 115, 22, 0.85)',  // orange
        'rgba(71, 85, 105, 0.85)'    // slate grey
    ];

    const borderColors = [
        '#0057d8', '#10b981', '#ffc400', '#ef4444', '#8b5cf6', '#f97316', '#475569'
    ];

    // Chart Campus
    if (document.getElementById('chartCampus')) {
        new Chart(document.getElementById('chartCampus'), {
            type: 'doughnut',
            data: {
                labels: rawCampus.map(c => c.campus),
                datasets: [{
                    data: rawCampus.map(c => c.total),
                    backgroundColor: colors,
                    borderColor: '#ffffff',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, padding: 15 }
                    }
                }
            }
        });
    }

    // Chart Carreras
    if (document.getElementById('chartCarreras')) {
        new Chart(document.getElementById('chartCarreras'), {
            type: 'bar',
            data: {
                labels: rawCarrera.map(c => c.carrera.length > 20 ? c.carrera.substring(0, 18) + '...' : c.carrera),
                datasets: [{
                    label: 'Alumnos',
                    data: rawCarrera.map(c => c.total),
                    backgroundColor: 'rgba(0, 87, 216, 0.75)',
                    borderColor: '#0057d8',
                    borderWidth: 1.5,
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#f1f5f9' } },
                    x: { grid: { display: false } }
                }
            }
        });
    }

    // Chart Aprobación
    if (document.getElementById('chartAprobacion')) {
        new Chart(document.getElementById('chartAprobacion'), {
            type: 'pie',
            data: {
                labels: ['Aprobados (>=70)', 'Reprobados (<70)'],
                datasets: [{
                    data: [rawAprobacion.aprobados, rawAprobacion.reprobados],
                    backgroundColor: ['rgba(16, 185, 129, 0.85)', 'rgba(239, 68, 68, 0.85)'],
                    borderColor: '#ffffff',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, padding: 15 }
                    }
                }
            }
        });
    }

    // Chart Rendimiento
    if (document.getElementById('chartRendimiento')) {
        new Chart(document.getElementById('chartRendimiento'), {
            type: 'bar',
            data: {
                labels: rawRendimiento.map(r => r.materia.length > 25 ? r.materia.substring(0, 22) + '...' : r.materia),
                datasets: [{
                    label: 'Promedio',
                    data: rawRendimiento.map(r => r.promedio),
                    backgroundColor: 'rgba(139, 92, 246, 0.75)',
                    borderColor: '#8b5cf6',
                    borderWidth: 1.5,
                    borderRadius: 8
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: { min: 0, max: 100, grid: { color: '#f1f5f9' } },
                    y: { grid: { display: false } }
                }
            }
        });
    }

    // Chart Secciones
    if (document.getElementById('chartSecciones') && rawSecciones.length > 0) {
        new Chart(document.getElementById('chartSecciones'), {
            type: 'doughnut',
            data: {
                labels: rawSecciones.map(s => s.estado),
                datasets: [{
                    data: rawSecciones.map(s => s.total),
                    backgroundColor: [
                        'rgba(0, 87, 216, 0.8)',
                        'rgba(16, 185, 129, 0.8)',
                        'rgba(239, 68, 68, 0.8)'
                    ],
                    borderColor: '#ffffff',
                    borderWidth: 1.5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, padding: 15 }
                    }
                }
            }
        });
    }
</script>
</body>
</html>
