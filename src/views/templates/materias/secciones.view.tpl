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
    }

    echo "<script>alert('" . htmlspecialchars($resultado["mensaje"], ENT_QUOTES) . "'); window.location='index.php?page=secciones';</script>";
    exit();
}

$buscar = trim($_GET["buscar"] ?? "");
$periodoActivo = \Controllers\MateriasController::obtenerPeriodoActivo();
$periodoAnterior = $periodoActivo ? \Controllers\MateriasController::obtenerPeriodoAnterior($periodoActivo["id_periodo"]) : false;
$secciones = \Controllers\MateriasController::listarSecciones($buscar);
$esCoordinador = ($_SESSION["rol"] ?? "") === "coordinador";
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
                            <h1 class="h2 page-title mb-1">Programacion de Secciones</h1>
                            <div class="text-muted small">
                                <?php echo htmlspecialchars(periodoSeccionesLabel($periodoActivo)); ?>
                                <?php if ($esCoordinador): ?>
                                    <span class="badge text-bg-info ms-2">Vista filtrada por facultad</span>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>

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
                </div>

                <?php if (!$periodoActivo): ?>
                    <div class="alert alert-warning">
                        No hay un periodo academico activo. Active un periodo antes de programar secciones.
                    </div>
                <?php else: ?>
                    <div class="row g-3 mb-4">
                        <div class="col-lg-5">
                            <form method="GET" action="index.php">
                                <input type="hidden" name="page" value="secciones">
                                <div class="input-group shadow-sm">
                                    <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                                    <input type="text" name="buscar" class="form-control border-start-0" placeholder="Buscar por asignatura, docente, aula o codigo" value="<?php echo htmlspecialchars($buscar); ?>">
                                    <button class="btn btn-outline-secondary" type="submit">Buscar</button>
                                </div>
                            </form>
                        </div>
                        <div class="col-lg-7">
                            <div class="alert alert-light border mb-0">
                                <i class="bi bi-shield-check text-success"></i>
                                El guardado valida choques de aula, choques de docente y exclusion de coordinadores.
                            </div>
                        </div>
                    </div>

                    <?php if (!empty($secciones)): ?>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Codigo</th>
                                        <th>Asignatura</th>
                                        <th>Docente</th>
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
                                            <td><?php echo htmlspecialchars($seccion["nombre_maestro"]); ?></td>
                                            <td><?php echo htmlspecialchars($seccion["aula"]); ?></td>
                                            <td><?php echo htmlspecialchars(diasSeccionLabel($seccion["dias"])); ?></td>
                                            <td><?php echo htmlspecialchars(substr($seccion["hora_inicio"], 0, 5) . " - " . substr($seccion["hora_fin"], 0, 5)); ?></td>
                                            <td class="text-center">
                                                <span class="badge bg-light text-dark border"><?php echo $cupoActual . "/" . $cupoMaximo; ?></span>
                                            </td>
                                            <td><span class="badge <?php echo $badge; ?>"><?php echo htmlspecialchars($estado); ?></span></td>
                                            <td class="text-end">
                                                <div class="d-flex gap-2 justify-content-end">
                                                    <a href="index.php?page=seccion_nueva&id=<?php echo urlencode($seccion["id_seccion"]); ?>" class="btn btn-sm btn-warning">
                                                        <i class="bi bi-pencil"></i> Editar
                                                    </a>
                                                    <a href="index.php?page=secciones&accion=eliminar&id=<?php echo urlencode($seccion["id_seccion"]); ?>"
                                                       class="btn btn-sm btn-danger"
                                                       onclick="return confirm('Desea eliminar esta seccion?');">
                                                        <i class="bi bi-trash"></i> Eliminar
                                                    </a>
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
                            <a href="index.php?page=seccion_nueva" class="alert-link">Crear la primera seccion</a>
                        </div>
                    <?php endif; ?>
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
