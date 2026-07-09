<?php
require_once __DIR__ . "/../../../controllers/MateriasController.php";
require_once __DIR__ . "/../../../dao/SeccionDao.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$periodoActivo = \Controllers\MateriasController::obtenerPeriodoActivo();
$seccion = null;

if (isset($_GET["id"])) {
    $seccion = \Controllers\MateriasController::obtenerSeccion($_GET["id"]);
    if (!$seccion) {
        echo "<script>alert('No tiene permiso para editar esta seccion o no existe.'); window.location='index.php?page=secciones';</script>";
        exit();
    }
}

$isEdit = !empty($seccion);
$materias = \Controllers\MateriasController::obtenerMateriasProgramables();
$maestros = \Controllers\MateriasController::obtenerMaestrosSeleccionables();
$diasSeleccionados = array_filter(explode(",", \Dao\SeccionDao::normalizarDias($seccion["dias"] ?? "")));
$diasSemana = [
    "Lu" => "Lunes",
    "Ma" => "Martes",
    "Mi" => "Miercoles",
    "Ju" => "Jueves",
    "Vi" => "Viernes",
    "Sa" => "Sabado"
];

if (!function_exists("periodoFormularioSeccionLabel")) {
    function periodoFormularioSeccionLabel($periodo) {
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
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $isEdit ? "Editar Seccion" : "Nueva Seccion"; ?></title>
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
                            <h1 class="h2 page-title mb-1">
                                <i class="bi bi-calendar-plus"></i>
                                <?php echo $isEdit ? "Editar Seccion" : "Nueva Seccion"; ?>
                            </h1>
                            <div class="text-muted small"><?php echo htmlspecialchars(periodoFormularioSeccionLabel($periodoActivo)); ?></div>
                        </div>
                    </div>
                    <a href="index.php?page=secciones" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <?php if (!$periodoActivo): ?>
                    <div class="alert alert-warning">
                        No hay periodo academico activo. No se pueden crear secciones hasta activar un periodo.
                    </div>
                <?php elseif (empty($materias)): ?>
                    <div class="alert alert-warning">
                        No hay asignaturas disponibles para su alcance academico.
                    </div>
                <?php elseif (empty($maestros) && !$isEdit): ?>
                    <div class="alert alert-warning">
                        No hay docentes disponibles. Los docentes con rol de coordinador no pueden impartir clases en el periodo activo.
                    </div>
                <?php else: ?>
                    <form method="POST" action="index.php?page=seccion_guardar" class="row g-3">
                        <?php if ($isEdit): ?>
                            <input type="hidden" name="id_seccion" value="<?php echo htmlspecialchars($seccion["id_seccion"]); ?>">
                        <?php endif; ?>

                        <div class="col-md-4">
                            <label class="form-label">Codigo de Seccion</label>
                            <input type="text"
                                   name="codigo_seccion"
                                   class="form-control"
                                   maxlength="20"
                                   value="<?php echo htmlspecialchars($seccion["codigo_seccion"] ?? ""); ?>"
                                   placeholder="Automatico si queda vacio">
                        </div>

                        <div class="col-md-8">
                            <label class="form-label">Asignatura <span class="text-danger">*</span></label>
                            <select name="id_materia" id="select_materia" class="form-select" onchange="filterMaestros()" required>
                                <option value="">-- Seleccione una asignatura --</option>
                                <?php foreach ($materias as $materia): ?>
                                    <?php
                                        $contexto = $materia["nombre_carrera"] ?? $materia["nombre_facultad"] ?? "Institucional";
                                        $selected = ($seccion["id_materia"] ?? "") == $materia["id_materia"] ? "selected" : "";
                                    ?>
                                    <option value="<?php echo htmlspecialchars($materia["id_materia"]); ?>" 
                                            data-facultad="<?php echo htmlspecialchars($materia["id_facultad"] ?? ""); ?>"
                                            data-carrera="<?php echo htmlspecialchars($materia["id_carrera"] ?? ""); ?>"
                                            <?php echo $selected; ?>>
                                        <?php echo htmlspecialchars($materia["codigo"] . " - " . $materia["nombre"] . " (" . $contexto . ")"); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Docente asignado <span class="text-danger">*</span></label>
                            <select name="id_maestro" id="select_maestro" class="form-select" required>
                                <option value="">-- Seleccione un docente --</option>
                                <?php foreach ($maestros as $maestro): ?>
                                    <?php $selected = ($seccion["id_maestro"] ?? "") == $maestro["id_maestro"] ? "selected" : ""; ?>
                                    <option value="<?php echo htmlspecialchars($maestro["id_maestro"]); ?>" 
                                            data-facultad="<?php echo htmlspecialchars($maestro["id_facultad"] ?? ""); ?>"
                                            data-carrera="<?php echo htmlspecialchars($maestro["id_carrera"] ?? ""); ?>"
                                            <?php echo $selected; ?>>
                                        <?php echo htmlspecialchars($maestro["nombre"] . " - " . $maestro["codigo"]); ?>
                                    </option>
                                <?php endforeach; ?>

                                <?php if ($isEdit && !empty($seccion["id_maestro"])): ?>
                                    <?php
                                        $maestroEnLista = false;
                                        foreach ($maestros as $maestro) {
                                            if (intval($maestro["id_maestro"]) === intval($seccion["id_maestro"])) {
                                                $maestroEnLista = true;
                                                break;
                                            }
                                        }
                                    ?>
                                    <?php if (!$maestroEnLista): ?>
                                        <option value="<?php echo htmlspecialchars($seccion["id_maestro"]); ?>" selected disabled>
                                            <?php echo htmlspecialchars(($seccion["nombre_maestro"] ?? "Docente no disponible") . " (no disponible)"); ?>
                                        </option>
                                    <?php endif; ?>
                                <?php endif; ?>
                            </select>
                            <div class="form-text">Los maestros que tambien son coordinadores quedan excluidos. Se segmentan según la carrera y facultad de la asignatura.</div>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Aula <span class="text-danger">*</span></label>
                            <input type="text"
                                   name="aula"
                                   class="form-control"
                                   value="<?php echo htmlspecialchars($seccion["aula"] ?? ""); ?>"
                                   placeholder="Ej: B-203"
                                   required>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Cupo Maximo <span class="text-danger">*</span></label>
                            <input type="number"
                                   name="cupo_maximo"
                                   class="form-control"
                                   value="<?php echo htmlspecialchars($seccion["cupo_maximo"] ?? 30); ?>"
                                   min="1"
                                   max="200"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Dias <span class="text-danger">*</span></label>
                            <div class="d-flex flex-wrap gap-3 p-2 border rounded bg-light">
                                <?php foreach ($diasSemana as $diaKey => $diaLabel): ?>
                                    <?php $checked = in_array($diaKey, $diasSeleccionados) ? "checked" : ""; ?>
                                    <div class="form-check">
                                        <input class="form-check-input"
                                               type="checkbox"
                                               name="dias[]"
                                               value="<?php echo $diaKey; ?>"
                                               id="dia_<?php echo $diaKey; ?>"
                                               <?php echo $checked; ?>>
                                        <label class="form-check-label" for="dia_<?php echo $diaKey; ?>">
                                            <?php echo $diaLabel; ?>
                                        </label>
                                    </div>
                                <?php endforeach; ?>
                            </div>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Hora Inicio <span class="text-danger">*</span></label>
                            <input type="time"
                                   name="hora_inicio"
                                   class="form-control"
                                   value="<?php echo htmlspecialchars(substr($seccion["hora_inicio"] ?? "", 0, 5)); ?>"
                                   required>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Hora Fin <span class="text-danger">*</span></label>
                            <input type="time"
                                   name="hora_fin"
                                   class="form-control"
                                   value="<?php echo htmlspecialchars(substr($seccion["hora_fin"] ?? "", 0, 5)); ?>"
                                   required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Estado</label>
                            <select name="estado" class="form-select">
                                <?php foreach (["Borrador", "Activa", "Cerrada"] as $estado): ?>
                                    <option value="<?php echo $estado; ?>" <?php echo ($seccion["estado"] ?? "Borrador") === $estado ? "selected" : ""; ?>>
                                        <?php echo $estado; ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="col-12">
                            <div class="alert alert-light border">
                                <i class="bi bi-info-circle text-primary"></i>
                                El sistema rechazara choques de aula o docente cuando compartan dia y rango de horas en el periodo activo.
                            </div>
                        </div>

                        <div class="col-12 d-flex gap-2">
                            <button type="submit" class="btn btn-success">
                                <i class="bi bi-save"></i> Guardar Seccion
                            </button>
                            <a href="index.php?page=secciones" class="btn btn-secondary">
                                <i class="bi bi-x-circle"></i> Cancelar
                            </a>
                        </div>
                    </form>
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

function filterMaestros() {
    const matSelect = document.getElementById('select_materia');
    if (!matSelect) return;
    const selectedOpt = matSelect.options[matSelect.selectedIndex];
    if (!selectedOpt) return;
    
    const matFacId = selectedOpt.getAttribute('data-facultad');
    const matCarId = selectedOpt.getAttribute('data-carrera');
    
    const maestroSelect = document.getElementById('select_maestro');
    const options = maestroSelect.options;
    
    let hasSelectedVisible = false;
    
    for (let i = 0; i < options.length; i++) {
        const opt = options[i];
        if (opt.value === "") continue;
        
        const maeFacId = opt.getAttribute('data-facultad');
        const maeCarId = opt.getAttribute('data-carrera');
        
        const esInstitucional = (!matFacId && !matCarId);
        const coincideFacultad = (matFacId && maeFacId == matFacId);
        const coincideCarrera = (matCarId && maeCarId == matCarId);
        
        if (esInstitucional || coincideCarrera || coincideFacultad) {
            opt.style.display = 'block';
            if (coincideCarrera) {
                opt.text = opt.getAttribute('data-original-text') + ' ⭐ (Especialista)';
            } else {
                opt.text = opt.getAttribute('data-original-text');
            }
            if (opt.selected) {
                hasSelectedVisible = true;
            }
        } else {
            opt.style.display = 'none';
            if (opt.selected) {
                opt.selected = false;
            }
        }
    }
    
    if (!hasSelectedVisible) {
        maestroSelect.value = "";
    }
}

window.addEventListener('load', function() {
    const maestroSelect = document.getElementById('select_maestro');
    if (maestroSelect) {
        for (let i = 0; i < maestroSelect.options.length; i++) {
            const opt = maestroSelect.options[i];
            opt.setAttribute('data-original-text', opt.text);
        }
        filterMaestros();
    }
});
</script>
</body>
</html>
