<?php
require_once __DIR__ . "/../../../controllers/MateriasController.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!function_exists("periodoSeccionesLabel")) {
    function periodoSeccionesLabel($periodo) {
        if (!$periodo) {
            return "Sin periodo activo";
        }

        if (!empty($periodo["nombre_periodo"])) {
            return $periodo["nombre_periodo"];
        }

        if (isset($periodo["periodo_num"], $periodo["anio"])) {
            return $periodo["anio"] . " - Periodo " . $periodo["periodo_num"];
        }

        return "Periodo #" . ($periodo["id_periodo"] ?? "");
    }
}

if (!function_exists("diasSeccionLabel")) {
    function diasSeccionLabel($dias) {
        return str_replace(",", "-", (string) $dias);
    }
}

if (isset($_GET["accion"])) {
    $accion = $_GET["accion"];
    $resultado = ["exito" => false, "mensaje" => "Accion no valida."];

    if ($accion === "eliminar" && isset($_GET["id"])) {
        $resultado = \Controllers\MateriasController::eliminarSeccion($_GET["id"]);
    } elseif ($accion === "clonar") {
        $resultado = \Controllers\MateriasController::clonarSeccionesPeriodoAnterior();
    } elseif ($accion === "activar_borradores") {
        $resultado = \Controllers\MateriasController::activarBorradores();
    } elseif ($accion === "extender_cupo" && isset($_GET["id"])) {
        $resultado = \Controllers\MateriasController::extenderCupoSeccion($_GET["id"], 5);
    }

    echo "<script>alert('" . htmlspecialchars($resultado["mensaje"], ENT_QUOTES) . "'); window.location='index.php?page=secciones';</script>";
    exit();
}

require_once __DIR__ . "/../../../dao/CarreraDao.php";

$buscar = trim($_GET["buscar"] ?? "");
$naturaleza = $_GET["naturaleza"] ?? "todas";
$filtroCarrera = $_GET["carrera"] ?? "todas";

$periodoActivo    = \Controllers\MateriasController::obtenerPeriodoActivo();
$periodoAnterior  = $periodoActivo ? \Controllers\MateriasController::obtenerPeriodoAnterior($periodoActivo["id_periodo"]) : false;
$rolActual        = $_SESSION["rol"] ?? "";
$esCoordinador    = ($rolActual === "coordinador");
$esMaestro        = ($rolActual === "maestro");
$idFacultadActual = $esCoordinador ? ($_SESSION["id_facultad"] ?? null) : null;
$carrerasFiltro   = \Dao\CarreraDao::obtenerCarreras(false, $idFacultadActual);

// Si es maestro, filtrar SOLO sus secciones del periodo activo
if ($esMaestro) {
    require_once __DIR__ . "/../../../dao/MaestroDao.php";
    $maestroRow = \Dao\MaestroDao::obtenerMaestroPorIdUsuario($_SESSION["id_usuario"] ?? 0);
    if ($maestroRow && $periodoActivo) {
        $secciones = \Dao\SeccionDao::obtenerSeccionesPorMaestro(
            intval($maestroRow["id_maestro"]),
            intval($periodoActivo["id_periodo"])
        );
    } else {
        $secciones = [];
    }
} else {
    $secciones = \Controllers\MateriasController::listarSecciones($buscar, $naturaleza, $filtroCarrera);
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Secciones Academicas</title>
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
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-1">
                                <?php if ($esMaestro): ?>Mis Secciones<?php elseif ($esCoordinador): ?>Programación de Secciones<?php else: ?>Gestión de Secciones<?php endif; ?>
                            </h1>
                            <div class="text-muted small">
                                <?php echo htmlspecialchars(periodoSeccionesLabel($periodoActivo)); ?>
                                <?php if ($esCoordinador): ?>
                                    <span class="badge text-bg-info ms-2">Vista filtrada por facultad</span>
                                <?php endif; ?>
                                <?php if ($esMaestro): ?>
                                    <span class="badge text-bg-primary ms-2">Solo tus secciones asignadas</span>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>

                    <?php if ($esCoordinador): ?>
                    <div class="d-flex flex-wrap gap-2">
                        <a href="index.php?page=seccion_nueva" class="btn btn-primary <?php echo !$periodoActivo ? 'disabled' : ''; ?>">
                            <i class="bi bi-plus-circle"></i> Nueva Seccion
                        </a>
                        <a href="index.php?page=secciones&accion=clonar"
                           class="btn btn-outline-primary <?php echo (!$periodoActivo || !$periodoAnterior) ? 'disabled' : ''; ?>"
                           onclick="return confirm('Desea clonar las secciones del periodo anterior como borradores?');">
                            <i class="bi bi-files"></i> Clonar Periodo Anterior
                        </a>
                        <a href="index.php?page=secciones&accion=activar_borradores"
                           class="btn btn-success <?php echo !$periodoActivo ? 'disabled' : ''; ?>"
                           onclick="return confirm('Desea activar masivamente las secciones en borrador?');">
                            <i class="bi bi-check2-circle"></i> Activar Borradores
                        </a>
                    </div>
                    <?php endif; ?>
                </div>

                <?php if (!$periodoActivo): ?>
                    <div class="alert alert-warning">
                        No hay un periodo academico activo. Active un periodo antes de programar secciones.
                    </div>
                <?php else: ?>
                    <?php if (!$esMaestro): ?>
                    <div class="mb-4">
                        <form method="GET" action="index.php" class="row g-3 align-items-center">
                            <input type="hidden" name="page" value="secciones">
                            <div class="col-md-4">
                                <div class="input-group shadow-sm">
                                    <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                                    <input type="text" name="buscar" class="form-control border-start-0" placeholder="Buscar por asignatura, docente, aula..." value="<?php echo htmlspecialchars($buscar); ?>">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <select name="naturaleza" class="form-select shadow-sm" onchange="this.form.submit()">
                                    <option value="todas" <?php echo $naturaleza === 'todas' ? 'selected' : ''; ?>>Cualquier Naturaleza</option>
                                    <option value="institucional" <?php echo $naturaleza === 'institucional' ? 'selected' : ''; ?>>Clases Generales (Institucionales)</option>
                                    <option value="facultad" <?php echo $naturaleza === 'facultad' ? 'selected' : ''; ?>>Clases de Facultad</option>
                                    <option value="carrera" <?php echo $naturaleza === 'carrera' ? 'selected' : ''; ?>>Clases de Carrera</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <select name="carrera" class="form-select shadow-sm" onchange="this.form.submit()" <?php echo ($naturaleza !== 'todas' && $naturaleza !== 'carrera') ? 'disabled' : ''; ?>>
                                    <option value="todas" <?php echo $filtroCarrera === 'todas' ? 'selected' : ''; ?>>Todas las carreras</option>
                                    <?php foreach ($carrerasFiltro as $cf): ?>
                                        <option value="<?php echo $cf['id_carrera']; ?>" <?php echo (string)$filtroCarrera === (string)$cf['id_carrera'] ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($cf['nombre_carrera']); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-outline-secondary w-100 shadow-sm" type="submit">Filtrar</button>
                            </div>
                        </form>
                    </div>
                    <?php endif; ?>

                    <?php if (!empty($secciones)): ?>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Codigo</th>
                                        <th>Asignatura</th>
                                        <?php if (!$esMaestro): ?><th>Docente</th><?php endif; ?>
                                        <th>Aula</th>
                                        <th>Dias</th>
                                        <th>Horario</th>
                                        <th class="text-center">Cupo</th>
                                        <th>Estado</th>
                                        <th class="text-end">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($secciones as $seccion): ?>
                                        <?php
                                            $estado = $seccion["estado"] ?? "Borrador";
                                            $badge = $estado === "Activa" ? "bg-success" : ($estado === "Cerrada" ? "bg-secondary" : "bg-warning text-dark");
                                            $cupoActual = intval($seccion["cupo_actual"] ?? 0);
                                            $cupoMaximo = intval($seccion["cupo_maximo"] ?? 0);
                                        ?>
                                            <tr>
                                                <td class="fw-semibold"><?php echo htmlspecialchars($seccion["codigo_seccion"]); ?></td>
                                                <td>
                                                    <div class="fw-semibold"><?php echo htmlspecialchars($seccion["codigo_materia"] . " - " . $seccion["nombre_materia"]); ?></div>
                                                    <div class="text-muted small">
                                                        <?php echo htmlspecialchars($seccion["nombre_facultad"] ?? $seccion["nombre_carrera"] ?? "Institucional"); ?>
                                                    </div>
                                                </td>
                                                <?php if (!$esMaestro): ?>
                                                    <td><?php echo htmlspecialchars($seccion["nombre_maestro"]); ?></td>
                                                <?php endif; ?>
                                                <td><?php echo htmlspecialchars($seccion["aula"]); ?></td>
                                                <td><?php echo htmlspecialchars(diasSeccionLabel($seccion["dias"])); ?></td>
                                                <td><?php echo htmlspecialchars(substr($seccion["hora_inicio"], 0, 5) . " - " . substr($seccion["hora_fin"], 0, 5)); ?></td>
                                                <td class="text-center">
                                                    <span class="badge bg-light text-dark border"><?php echo $cupoActual . "/" . $cupoMaximo; ?></span>
                                                </td>
                                                <td><span class="badge <?php echo $badge; ?>"><?php echo htmlspecialchars($estado); ?></span></td>
                                                <td class="text-end">
                                                    <div class="d-flex gap-2 justify-content-end">
                                                        <?php if ($esMaestro): ?>
                                                            <!-- Maestro: solo puede registrar notas -->
                                                            <a href="index.php?page=notas_maestro&id_seccion=<?php echo urlencode($seccion["id_seccion"]); ?>"
                                                               class="btn btn-sm btn-primary">
                                                                <i class="bi bi-pencil-square"></i> Registrar Notas
                                                            </a>
                                                        <?php elseif ($esCoordinador): ?>
                                                            <!-- Coordinador: extender cupo, editar, eliminar -->
                                                            <a href="index.php?page=secciones&accion=extender_cupo&id=<?php echo urlencode($seccion["id_seccion"]); ?>"
                                                               class="btn btn-sm btn-outline-success"
                                                               title="Extender Cupo (+5)"
                                                               onclick="return confirm('¿Desea extender el cupo de esta sección en +5 plazas adicionales?');">
                                                                <i class="bi bi-plus-circle"></i> +5 Cupos
                                                            </a>
                                                            <a href="index.php?page=seccion_nueva&id=<?php echo urlencode($seccion["id_seccion"]); ?>" class="btn btn-sm btn-warning">
                                                                <i class="bi bi-pencil"></i> Editar
                                                            </a>
                                                            <a href="index.php?page=secciones&accion=eliminar&id=<?php echo urlencode($seccion["id_seccion"]); ?>"
                                                               class="btn btn-sm btn-danger"
                                                               onclick="return confirm('Desea eliminar esta seccion?');">
                                                                <i class="bi bi-trash"></i> Eliminar
                                                            </a>
                                                        <?php else: ?>
                                                            <!-- Director: solo visualiza -->
                                                            <span class="text-muted small">Lectura</span>
                                                        <?php endif; ?>
                                                    </div>
                                                </td>
                                            </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php else: ?>
                        <div class="alert alert-info">
                            No hay secciones programadas para el periodo activo.
                            <?php if ($esCoordinador): ?>
                                <a href="index.php?page=seccion_nueva" class="alert-link">Crear la primera seccion</a>
                            <?php endif; ?>
                        </div>
                    <?php endif; ?>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- sidebar.js ya fue cargado desde sidebar.view.tpl -->
</body>
</html>
