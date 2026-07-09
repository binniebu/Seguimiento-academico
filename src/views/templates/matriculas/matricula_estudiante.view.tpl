<?php
require_once __DIR__ . "/../../../controllers/MatriculasController.php";

use Controllers\MatriculasController;
use Dao\MatriculaDao;
use Dao\PeriodoDao;

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$idUsuario = $_SESSION["id_usuario"] ?? null;
$estudiante = MatriculaDao::obtenerEstudiantePorUsuario($idUsuario);
$periodoActivo = PeriodoDao::obtenerPeriodoActivo();

$adicionesActivas = MatriculasController::esPeriodoAdicionesActivo();
$cancelacionesActivas = MatriculasController::esPeriodoCancelacionesActivo();

$mensajeExito = "";
$mensajeError = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    if (isset($_POST["accion"])) {
        if ($_POST["accion"] === "matricular" && isset($_POST["id_seccion"])) {
            $res = MatriculasController::matricularSeccion($_POST["id_seccion"]);
            if ($res["exito"]) {
                $mensajeExito = $res["mensaje"];
            } else {
                $mensajeError = $res["mensaje"];
            }
        } elseif ($_POST["accion"] === "cancelar" && isset($_POST["id_matricula"])) {
            $res = MatriculasController::cancelarMatriculaEstudiante($_POST["id_matricula"]);
            if ($res["exito"]) {
                $mensajeExito = $res["mensaje"];
            } else {
                $mensajeError = $res["mensaje"];
            }
        }
    }
}

$disponibles = [];
$matriculadas = [];
$totalCreditos = 0;

if ($estudiante && $periodoActivo) {
    $disponibles = MatriculaDao::obtenerSeccionesDisponiblesParaEstudiante(
        $estudiante["id_estudiante"],
        $periodoActivo["id_periodo"],
        $estudiante["id_carrera"],
        $estudiante["id_facultad"]
    );
    $matriculadas = MatriculaDao::obtenerSeccionesMatriculadas(
        $estudiante["id_estudiante"],
        $periodoActivo["id_periodo"]
    );
    foreach ($matriculadas as $m) {
        $totalCreditos += intval($m["creditos"]);
    }
}

// Función auxiliar para renderizar los días de forma legible
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
    <title>Matrícula de Asignaturas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <!-- Main content -->
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                
                <!-- Cabecera del Estudiante -->
                <div class="card border-0 shadow-sm mb-4 rounded-3 bg-light">
                    <div class="card-body p-4 d-flex flex-wrap justify-content-between align-items-center gap-3">
                        <div>
                            <span class="badge bg-primary px-3 py-2 mb-2" style="font-size: 13px;">Estudiante</span>
                            <h2 class="mb-1 text-dark fw-bold"><?php echo htmlspecialchars($estudiante["nombre"] ?? ""); ?></h2>
                            <p class="text-muted mb-0">
                                <i class="bi bi-card-text me-1"></i> Cuenta: <span class="fw-semibold text-dark"><?php echo htmlspecialchars($estudiante["cuenta"] ?? ""); ?></span> | 
                                <i class="bi bi-mortarboard me-1"></i> Carrera: <span class="fw-semibold text-dark"><?php echo htmlspecialchars($estudiante["nombre_carrera"] ?? "General"); ?></span>
                            </p>
                        </div>
                        <div class="text-md-end bg-white p-3 rounded-3 shadow-xs border">
                            <div class="text-muted small text-uppercase fw-bold">Periodo Vigente</div>
                            <div class="fs-5 fw-bold text-primary"><?php echo htmlspecialchars($periodoActivo["nombre_periodo"] ?? "Ninguno"); ?></div>
                            <div class="small text-muted mt-1">Finaliza: <?php echo htmlspecialchars($periodoActivo["fecha_fin"] ?? ""); ?></div>
                        </div>
                    </div>
                </div>

                <div class="row g-4">
                    <!-- Columna Izquierda: Secciones Disponibles -->
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm rounded-3">
                            <div class="card-header bg-primary text-white py-3 rounded-top-3 d-flex justify-content-between align-items-center">
                                <h5 class="card-title mb-0"><i class="bi bi-journal-plus me-2"></i>Asignaturas Disponibles</h5>
                                <span class="badge bg-white text-primary fw-bold"><?php echo count($disponibles); ?> Disponibles</span>
                            </div>
                            <div class="card-body p-4">
                                <?php if (!$adicionesActivas): ?>
                                    <div class="alert alert-warning border border-warning-subtle text-center py-4 my-2">
                                        <i class="bi bi-info-circle fs-3 d-block mb-2 text-warning"></i>
                                        <h6 class="fw-bold">El período de adición de asignaturas ha finalizado</h6>
                                        <p class="text-muted small mb-0">La adición de nuevas clases solo está disponible durante los primeros 7 días desde el inicio del período académico.</p>
                                    </div>
                                <?php elseif (!empty($disponibles)): ?>
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle">
                                            <thead>
                                                <tr>
                                                    <th>Código/Sección</th>
                                                    <th>Materia</th>
                                                    <th>Docente</th>
                                                    <th>Horario / Aula</th>
                                                    <th class="text-center">Cupos</th>
                                                    <th class="text-end">Acción</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($disponibles as $sec): 
                                                    $cupoAct = intval($sec["cupo_actual"]);
                                                    $cupoMax = intval($sec["cupo_maximo"]);
                                                    $porcentaje = $cupoMax > 0 ? round(($cupoAct / $cupoMax) * 100) : 0;
                                                    $colorBarra = "bg-success";
                                                    if ($porcentaje >= 80) $colorBarra = "bg-warning";
                                                    if ($porcentaje >= 100) $colorBarra = "bg-danger";
                                                ?>
                                                    <tr>
                                                        <td>
                                                            <div class="fw-bold text-dark"><?php echo htmlspecialchars($sec["codigo_seccion"]); ?></div>
                                                            <span class="badge bg-light text-secondary border small mt-1"><?php echo htmlspecialchars($sec["codigo_materia"]); ?></span>
                                                        </td>
                                                        <td>
                                                            <div class="fw-semibold text-dark"><?php echo htmlspecialchars($sec["nombre_materia"]); ?></div>
                                                            <?php if (!empty($sec["id_requisito"])): ?>
                                                                <div class="text-muted small">
                                                                    <i class="bi bi-shield-lock me-1"></i> Requisito: <span class="text-primary"><?php echo htmlspecialchars($sec["nombre_requisito"] ?? ""); ?></span>
                                                                </div>
                                                            <?php endif; ?>
                                                        </td>
                                                        <td class="text-muted small"><?php echo htmlspecialchars($sec["nombre_maestro"]); ?></td>
                                                        <td>
                                                            <div class="fw-semibold text-dark"><?php echo htmlspecialchars(diasLabel($sec["dias"])); ?></div>
                                                            <div class="text-muted small">
                                                                <?php echo htmlspecialchars(substr($sec["hora_inicio"], 0, 5) . " - " . substr($sec["hora_fin"], 0, 5)); ?> | Aula: <?php echo htmlspecialchars($sec["aula"]); ?>
                                                            </div>
                                                        </td>
                                                        <td style="width: 110px;">
                                                            <div class="d-flex justify-content-between mb-1 small text-muted">
                                                                <span><?php echo $cupoAct; ?>/<?php echo $cupoMax; ?></span>
                                                                <span><?php echo $porcentaje; ?>%</span>
                                                            </div>
                                                            <div class="progress" style="height: 6px;">
                                                              <div class="progress-bar <?php echo $colorBarra; ?>" role="progressbar" style="width: <?php echo min($porcentaje, 100); ?>%"></div>
                                                            </div>
                                                        </td>
                                                        <td class="text-end">
                                                            <form method="POST" action="index.php?page=matricula_estudiante" onsubmit="return confirm('¿Desea matricular esta asignatura?');">
                                                                <input type="hidden" name="accion" value="matricular">
                                                                <input type="hidden" name="id_seccion" value="<?php echo $sec["id_seccion"]; ?>">
                                                                
                                                                <?php if ($cupoAct >= $cupoMax): ?>
                                                                    <button class="btn btn-sm btn-secondary disabled" type="button" disabled>Lleno</button>
                                                                <?php else: ?>
                                                                    <button class="btn btn-sm btn-primary" type="submit">
                                                                        <i class="bi bi-bookmark-plus me-1"></i> Matricular
                                                                    </button>
                                                                <?php endif; ?>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                <?php else: ?>
                                    <div class="text-center py-5">
                                        <i class="bi bi-journals text-muted fs-1 d-block mb-3"></i>
                                        <p class="text-muted mb-0">No hay asignaturas disponibles para su plan de estudios en este periodo.</p>
                                    </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>

                    <!-- Columna Derecha: Clases Matriculadas -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm rounded-3">
                            <div class="card-header bg-dark text-white py-3 rounded-top-3 d-flex justify-content-between align-items-center">
                                <h5 class="card-title mb-0"><i class="bi bi-calendar-check me-2"></i>Clases Inscritas</h5>
                                <span class="badge bg-light text-dark fw-bold"><?php echo count($matriculadas); ?> Inscritas</span>
                            </div>
                            <div class="card-body p-4">
                                <?php if (!empty($matriculadas)): ?>
                                    <div class="d-flex flex-column gap-3 mb-4">
                                        <?php foreach ($matriculadas as $m): ?>
                                            <div class="p-3 border rounded-3 bg-light-subtle d-flex justify-content-between align-items-start">
                                                <div>
                                                    <div class="fw-bold text-dark mb-1"><?php echo htmlspecialchars($m["nombre_materia"]); ?></div>
                                                    <div class="text-muted small mb-1">
                                                        <i class="bi bi-tag me-1"></i> <?php echo htmlspecialchars($m["codigo_seccion"]); ?> (<?php echo htmlspecialchars($m["creditos"]); ?> UV)
                                                    </div>
                                                    <div class="text-muted small">
                                                        <i class="bi bi-calendar-week me-1"></i> <?php echo htmlspecialchars(diasLabel($m["dias"])); ?> | <?php echo htmlspecialchars(substr($m["hora_inicio"], 0, 5)); ?>
                                                    </div>
                                                </div>
                                                <?php if ($cancelacionesActivas): ?>
                                                    <form method="POST" action="index.php?page=matricula_estudiante" onsubmit="return confirm('¿Está seguro de cancelar esta asignatura?');">
                                                        <input type="hidden" name="accion" value="cancelar">
                                                        <input type="hidden" name="id_matricula" value="<?php echo $m["id_matricula"]; ?>">
                                                        <button class="btn btn-sm btn-outline-danger border-0 p-2" type="submit" title="Cancelar Asignatura">
                                                            <i class="bi bi-x-circle-fill fs-5"></i>
                                                        </button>
                                                    </form>
                                                <?php else: ?>
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle small mt-1" title="El período de cancelaciones ha expirado. Esta clase está consolidada en su carga oficial.">
                                                        <i class="bi bi-lock-fill me-1"></i> Fija
                                                    </span>
                                                <?php endif; ?>
                                            </div>
                                        <?php endforeach; ?>
                                    </div>
                                    <div class="border-top pt-3 d-flex justify-content-between align-items-center">
                                        <span class="fw-semibold text-secondary">Carga Académica:</span>
                                        <span class="fs-5 fw-bold text-primary"><?php echo $totalCreditos; ?> UV Totales</span>
                                    </div>
                                <?php else: ?>
                                    <div class="text-center py-5">
                                        <i class="bi bi-calendar-x text-muted fs-1 d-block mb-3"></i>
                                        <p class="text-muted mb-0">No ha matriculado ninguna asignatura aún.</p>
                                    </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<?php if ($mensajeError !== ""): ?>
    <script>
        Swal.fire({
            icon: 'error',
            title: 'No se pudo procesar',
            text: '<?php echo addslashes($mensajeError); ?>',
            confirmButtonColor: '#0057d8'
        });
    </script>
<?php endif; ?>

<?php if ($mensajeExito !== ""): ?>
    <script>
        Swal.fire({
            icon: 'success',
            title: '¡Operación Exitosa!',
            text: '<?php echo addslashes($mensajeExito); ?>',
            confirmButtonColor: '#0057d8'
        }).then(() => {
            window.location = "index.php?page=matricula_estudiante";
        });
    </script>
<?php endif; ?>
</body>
</html>
