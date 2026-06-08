<?php
require_once __DIR__ . "/../../../dao/UsuarioDao.php";

$resumen = \Dao\UsuarioDao::getResumenMatriculasGlobal();
$reporteMaterias = \Dao\UsuarioDao::getReporteMateriasYPromedios();
$reporteEstudiantes = \Dao\UsuarioDao::getReporteEstudiantes();
$reporteMaestros = \Dao\UsuarioDao::getReporteMaestros();

$totalEstudiantes = intval($resumen["total_estudiantes_sistema"] ?? 0);
$estudiantesActivos = intval($resumen["estudiantes_con_matricula_activa"] ?? 0);
$totalCupos = intval($resumen["total_cupos_matriculados"] ?? 0);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <nav class="col-md-2 d-md-block bg-light sidebar">
                <div class="sidebar-sticky pt-3">
                    <h6 class="sidebar-heading px-3 mt-4 mb-2 text-muted">Menu</h6>
                    <ul class="nav flex-column">
                        <li class="nav-item"><a class="nav-link" href="index.php?page=home"><i class="bi bi-house-door"></i> home</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=estudiantes"><i class="bi bi-people"></i> Estudiantes</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=maestros"><i class="bi bi-person-badge"></i> Maestros</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=materias"><i class="bi bi-book"></i> Materias</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=calificaciones"><i class="bi bi-graph-up"></i> Calificaciones</a></li>
                        <li class="nav-item"><a class="nav-link active" href="index.php?page=reportes"><i class="bi bi-file-text"></i> Reportes</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=usuarios"><i class="bi bi-person-gear"></i> Usuarios</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=logout"><i class="bi bi-box-arrow-right"></i> Cerrar sesion</a></li>
                    </ul>
                </div>
            </nav>

            <main role="main" class="col-md-10 ml-sm-auto px-md-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <div>
                        <h1 class="h2 mb-1">Reportes</h1>
                        <p class="text-muted mb-0">Indicadores de rendimiento academico global</p>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <p class="text-muted mb-1">Estudiantes Totales</p>
                                        <h2 class="mb-0"><?php echo htmlspecialchars($totalEstudiantes); ?></h2>
                                    </div>
                                    <span class="badge bg-success-subtle text-success rounded-pill">
                                        <i class="bi bi-people"></i>
                                    </span>
                                </div>
                                <small class="text-muted">Registrados en la plataforma</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <p class="text-muted mb-1">Estudiantes Activos</p>
                                        <h2 class="mb-0"><?php echo htmlspecialchars($estudiantesActivos); ?></h2>
                                    </div>
                                    <span class="badge bg-primary-subtle text-primary rounded-pill">
                                        <i class="bi bi-person-check"></i>
                                    </span>
                                </div>
                                <small class="text-muted">Con clases inscritas en este periodo</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <p class="text-muted mb-1">Cupos Ocupados</p>
                                        <h2 class="mb-0"><?php echo htmlspecialchars($totalCupos); ?></h2>
                                    </div>
                                    <span class="badge bg-warning-subtle text-warning rounded-pill">
                                        <i class="bi bi-journal-check"></i>
                                    </span>
                                </div>
                                <small class="text-muted">Total de asignaciones en materias</small>
                            </div>
                        </div>
                    </div>
                </div>

                <section class="mb-4">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <h2 class="h5 mb-0"><i class="bi bi-bar-chart"></i> Rendimiento por Materia</h2>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Codigo</th>
                                    <th>Asignatura</th>
                                    <th class="text-center">Notas Evaluadas</th>
                                    <th class="text-center">Promedio</th>
                                    <th class="text-center">Nota mas Alta</th>
                                    <th class="text-center">Nota mas Baja</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php if (!empty($reporteMaterias)): ?>
                                    <?php foreach ($reporteMaterias as $materia): ?>
                                        <tr>
                                            <td><?php echo htmlspecialchars($materia["codigo"]); ?></td>
                                            <td><strong><?php echo htmlspecialchars($materia["materia"]); ?></strong></td>
                                            <td class="text-center"><?php echo htmlspecialchars($materia["evaluaciones_registradas"]); ?></td>
                                            <td class="text-center">
                                                <span class="badge bg-success">
                                                    <?php echo $materia["promedio_nota"] !== null ? htmlspecialchars($materia["promedio_nota"]) . "%" : "N/A"; ?>
                                                </span>
                                            </td>
                                            <td class="text-center"><?php echo $materia["nota_mas_alta"] !== null ? htmlspecialchars($materia["nota_mas_alta"]) . "%" : "-"; ?></td>
                                            <td class="text-center"><?php echo $materia["nota_mas_baja"] !== null ? htmlspecialchars($materia["nota_mas_baja"]) . "%" : "-"; ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                <?php else: ?>
                                    <tr>
                                        <td colspan="6" class="text-center text-muted">No hay datos de materias para mostrar.</td>
                                    </tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </section>

                <div class="row g-4">
                    <div class="col-lg-6">
                        <section>
                            <h2 class="h5 mb-2"><i class="bi bi-person-lines-fill"></i> Reporte por Estudiante</h2>
                            <div class="table-responsive" style="max-height: 420px;">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Estudiante</th>
                                            <th>Materia</th>
                                            <th class="text-center">Nota</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php if (!empty($reporteEstudiantes)): ?>
                                            <?php foreach ($reporteEstudiantes as $estudiante): ?>
                                                <tr>
                                                    <td>
                                                        <?php echo htmlspecialchars($estudiante["estudiante"]); ?><br>
                                                        <small class="text-muted"><?php echo htmlspecialchars($estudiante["cuenta"]); ?></small>
                                                    </td>
                                                    <td><?php echo htmlspecialchars($estudiante["materia"]); ?></td>
                                                    <td class="text-center"><span class="badge bg-primary"><?php echo htmlspecialchars($estudiante["nota"]); ?>%</span></td>
                                                </tr>
                                            <?php endforeach; ?>
                                        <?php else: ?>
                                            <tr>
                                                <td colspan="3" class="text-center text-muted">No hay calificaciones de estudiantes.</td>
                                            </tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </div>

                    <div class="col-lg-6">
                        <section>
                            <h2 class="h5 mb-2"><i class="bi bi-person-workspace"></i> Carga por Maestro</h2>
                            <div class="table-responsive" style="max-height: 420px;">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Catedratico</th>
                                            <th>Clase Impartida</th>
                                            <th class="text-center">Alumnos</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php if (!empty($reporteMaestros)): ?>
                                            <?php foreach ($reporteMaestros as $maestro): ?>
                                                <tr>
                                                    <td>
                                                        <?php echo htmlspecialchars($maestro["maestro"]); ?><br>
                                                        <small class="text-muted"><?php echo htmlspecialchars($maestro["codigo_maestro"]); ?></small>
                                                    </td>
                                                    <td><?php echo htmlspecialchars($maestro["materia"]); ?></td>
                                                    <td class="text-center"><span class="badge bg-secondary"><?php echo htmlspecialchars($maestro["total_alumnos"]); ?></span></td>
                                                </tr>
                                            <?php endforeach; ?>
                                        <?php else: ?>
                                            <tr>
                                                <td colspan="3" class="text-center text-muted">No hay carga academica registrada.</td>
                                            </tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
