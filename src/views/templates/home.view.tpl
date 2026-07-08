<?php
require_once __DIR__ . "/../../dao/UsuarioDao.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$rolActual = $_SESSION["rol"] ?? "";
$correoActual = $_SESSION["correo"] ?? "";
$nombreActual = $_SESSION["usuario"] ?? "";
$rolesDisponibles = \Dao\UsuarioDao::obtenerRolesPorCorreo($correoActual);

if (empty($rolesDisponibles) && $rolActual !== "") {
    $rolesDisponibles = array($rolActual);
}

if (!function_exists("dashboardNumero")) {
    function dashboardNumero($valor, $decimales = 0) {
        return number_format(floatval($valor ?? 0), $decimales);
    }
}

if (!function_exists("dashboardDias")) {
    function dashboardDias($dias) {
        return str_replace(",", "-", (string) $dias);
    }
}

if (!function_exists("dashboardHora")) {
    function dashboardHora($hora) {
        return $hora ? substr((string) $hora, 0, 5) : "--:--";
    }
}

$dashboard = array();

switch ($rolActual) {
    case "director":
        $dashboard = \Dao\UsuarioDao::getDashboardDirector();
        break;
    case "coordinador":
        $idFacultad = $_SESSION["id_facultad"] ?? null;
        $dashboard = \Dao\UsuarioDao::getDashboardCoordinador($idFacultad);
        break;
    case "maestro":
        $dashboard = \Dao\UsuarioDao::getDashboardMaestro($correoActual);
        break;
    case "estudiante":
        $dashboard = \Dao\UsuarioDao::getDashboardEstudiante($correoActual);
        break;
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Seguimiento Academico</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
    <style>
        .dashboard-kpi {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            background: #fff;
            padding: 18px;
            height: 100%;
        }

        .dashboard-kpi .icon-box {
            width: 42px;
            height: 42px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        .dashboard-kpi-value {
            font-size: 2rem;
            font-weight: 700;
            line-height: 1;
        }

        .dashboard-section {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            background: #fff;
            padding: 20px;
        }

        .progress {
            height: 12px;
        }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <?php require_once __DIR__ . "/sidebar.view.tpl"; ?>

        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-1">Bienvenido, <?php echo htmlspecialchars($nombreActual); ?></h1>
                            <p class="text-muted mb-0" style="font-size: 14px;">
                                Rol de sesion actual:
                                <strong><?php echo ucfirst(htmlspecialchars($rolActual)); ?></strong>
                            </p>
                        </div>
                    </div>

                    <?php if (count($rolesDisponibles) > 1): ?>
                        <div class="d-flex align-items-center gap-2">
                            <label class="form-label mb-0 text-muted" style="font-size: 13px;">Cambiar de vista:</label>
                            <select onchange="window.location='index.php?page=switch_role&rol=' + this.value" class="form-select form-select-sm w-auto">
                                <?php foreach ($rolesDisponibles as $r): ?>
                                    <option value="<?php echo htmlspecialchars($r); ?>" <?php echo $r === $rolActual ? "selected" : ""; ?>>
                                        <?php echo ucfirst(htmlspecialchars($r)); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    <?php endif; ?>
                </div>

                <?php if ($rolActual === "director"): ?>
                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">Estudiantes activos</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["total_estudiantes_activos"] ?? 0); ?></div>
                                    </div>
                                    <span class="icon-box bg-primary-subtle text-primary"><i class="bi bi-people"></i></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">Docentes activos</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["total_docentes_activos"] ?? 0); ?></div>
                                    </div>
                                    <span class="icon-box bg-success-subtle text-success"><i class="bi bi-person-workspace"></i></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">Solicitudes pendientes</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["solicitudes_pendientes"] ?? 0); ?></div>
                                    </div>
                                    <span class="icon-box bg-warning-subtle text-warning"><i class="bi bi-inbox"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="dashboard-section">
                        <h2 class="h5 mb-3"><i class="bi bi-speedometer2"></i> Vista global institucional</h2>
                        <p class="text-muted mb-0">Estos indicadores resumen la actividad general del sistema y ayudan a detectar carga administrativa pendiente.</p>
                    </div>

                <?php elseif ($rolActual === "coordinador"): ?>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">Estudiantes matriculados en la facultad</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["estudiantes_matriculados"] ?? 0); ?></div>
                                    </div>
                                    <span class="icon-box bg-info-subtle text-info"><i class="bi bi-mortarboard"></i></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">Secciones activas de la facultad</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["secciones_activas"] ?? 0); ?></div>
                                    </div>
                                    <span class="icon-box bg-primary-subtle text-primary"><i class="bi bi-calendar-event"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="dashboard-section">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h2 class="h5 mb-0"><i class="bi bi-exclamation-triangle text-warning"></i> Secciones con cupo bajo</h2>
                            <a href="index.php?page=secciones" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-calendar-week"></i> Gestionar secciones
                            </a>
                        </div>

                        <?php if (!empty($dashboard["secciones_cupo_bajo"])): ?>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Seccion</th>
                                            <th>Asignatura</th>
                                            <th>Horario</th>
                                            <th class="text-center">Inscritos</th>
                                            <th class="text-center">Disponibles</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($dashboard["secciones_cupo_bajo"] as $seccion): ?>
                                            <tr>
                                                <td class="fw-semibold"><?php echo htmlspecialchars($seccion["codigo_seccion"] ?? ""); ?></td>
                                                <td><?php echo htmlspecialchars($seccion["materia"] ?? ""); ?></td>
                                                <td><?php echo htmlspecialchars(dashboardDias($seccion["dias"] ?? "") . " " . dashboardHora($seccion["hora_inicio"] ?? "") . " - " . dashboardHora($seccion["hora_fin"] ?? "")); ?></td>
                                                <td class="text-center"><?php echo dashboardNumero($seccion["inscritos"] ?? 0); ?></td>
                                                <td class="text-center">
                                                    <span class="badge bg-warning text-dark"><?php echo dashboardNumero($seccion["cupos_disponibles"] ?? 0); ?></span>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php else: ?>
                            <div class="alert alert-success mb-0">
                                No hay secciones activas con menos de 5 cupos disponibles.
                            </div>
                        <?php endif; ?>
                    </div>

                <?php elseif ($rolActual === "maestro"): ?>
                    <div class="dashboard-section">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h2 class="h5 mb-0"><i class="bi bi-calendar-check"></i> Mis secciones del periodo actual</h2>
                            <a href="index.php?page=calificaciones" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-pencil-square"></i> Calificaciones
                            </a>
                        </div>

                        <?php if (!empty($dashboard["secciones"])): ?>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Asignatura</th>
                                            <th>Seccion</th>
                                            <th>Aula</th>
                                            <th>Horario</th>
                                            <th class="text-center">Inscritos</th>
                                            <th class="text-end">Notas</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($dashboard["secciones"] as $seccion): ?>
                                            <tr>
                                                <td>
                                                    <div class="fw-semibold"><?php echo htmlspecialchars(($seccion["codigo_materia"] ?? "") . " - " . ($seccion["materia"] ?? "")); ?></div>
                                                    <span class="badge <?php echo ($seccion["estado"] ?? "") === "Activa" ? "bg-success" : "bg-warning text-dark"; ?>">
                                                        <?php echo htmlspecialchars($seccion["estado"] ?? ""); ?>
                                                    </span>
                                                </td>
                                                <td><?php echo htmlspecialchars($seccion["codigo_seccion"] ?? ""); ?></td>
                                                <td><?php echo htmlspecialchars($seccion["aula"] ?? ""); ?></td>
                                                <td><?php echo htmlspecialchars(dashboardDias($seccion["dias"] ?? "") . " " . dashboardHora($seccion["hora_inicio"] ?? "") . " - " . dashboardHora($seccion["hora_fin"] ?? "")); ?></td>
                                                <td class="text-center"><?php echo dashboardNumero($seccion["inscritos"] ?? 0); ?></td>
                                                <td class="text-end">
                                                    <a href="index.php?page=calificaciones&id_seccion=<?php echo urlencode($seccion["id_seccion"] ?? ""); ?>" class="btn btn-sm btn-primary">
                                                        <i class="bi bi-journal-check"></i> Registrar notas
                                                    </a>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php else: ?>
                            <div class="alert alert-info mb-0">
                                No tiene secciones asignadas en el periodo activo.
                            </div>
                        <?php endif; ?>
                    </div>

                <?php elseif ($rolActual === "estudiante"): ?>
                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">Indice academico global</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["promedio_global"] ?? 0, 2); ?></div>
                                    </div>
                                    <span class="icon-box bg-success-subtle text-success"><i class="bi bi-graph-up-arrow"></i></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <div class="text-muted small mb-2">UV matriculadas</div>
                                        <div class="dashboard-kpi-value"><?php echo dashboardNumero($dashboard["uv_matriculadas"] ?? 0); ?></div>
                                    </div>
                                    <span class="icon-box bg-primary-subtle text-primary"><i class="bi bi-journal-bookmark"></i></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="dashboard-kpi shadow-sm">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div>
                                        <div class="text-muted small mb-2">Avance del plan</div>
                                        <div class="dashboard-kpi-value"><?php echo intval($dashboard["avance_plan"] ?? 0); ?>%</div>
                                    </div>
                                    <span class="icon-box bg-info-subtle text-info"><i class="bi bi-bar-chart-steps"></i></span>
                                </div>
                                <div class="progress">
                                    <div class="progress-bar" role="progressbar" style="width: <?php echo intval($dashboard["avance_plan"] ?? 0); ?>%;"></div>
                                </div>
                                <div class="text-muted small mt-2">
                                    <?php echo dashboardNumero($dashboard["materias_aprobadas"] ?? 0); ?> de <?php echo dashboardNumero($dashboard["materias_plan"] ?? 0); ?> materias cursadas
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="dashboard-section">
                        <h2 class="h5 mb-3"><i class="bi bi-clock-history"></i> Horario diario de asignaturas</h2>
                        <?php if (!empty($dashboard["horario"])): ?>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Asignatura</th>
                                            <th>Dias</th>
                                            <th>Hora</th>
                                            <th>Aula</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($dashboard["horario"] as $clase): ?>
                                            <tr>
                                                <td class="fw-semibold"><?php echo htmlspecialchars(($clase["codigo"] ?? "") . " - " . ($clase["materia"] ?? "")); ?></td>
                                                <td><?php echo htmlspecialchars(dashboardDias($clase["dias"] ?? "")); ?></td>
                                                <td><?php echo htmlspecialchars(dashboardHora($clase["hora_inicio"] ?? "") . " - " . dashboardHora($clase["hora_fin"] ?? "")); ?></td>
                                                <td><?php echo htmlspecialchars($clase["aula"] ?? ""); ?></td>
                                            </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php else: ?>
                            <div class="alert alert-info mb-0">
                                No hay asignaturas matriculadas en el periodo activo.
                            </div>
                        <?php endif; ?>
                    </div>

                <?php else: ?>
                    <div class="alert alert-info">
                        No hay un dashboard configurado para el rol actual.
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.querySelectorAll('.toggleSidebarBtn').forEach(btn => {
    btn.addEventListener('click', function() {
        const sidebar = document.querySelector('.sidebar');
        const main = document.querySelector('main');
        if (sidebar.classList.contains('collapsed')) {
            sidebar.classList.remove('collapsed');
            main.classList.replace('col-md-12', 'col-md-10');
        } else {
            sidebar.classList.add('collapsed');
            main.classList.replace('col-md-10', 'col-md-12');
        }
    });
});
</script>
</body>
</html>
