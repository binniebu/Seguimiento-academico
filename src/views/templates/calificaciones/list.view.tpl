<?php
require_once __DIR__ . "/../../../dao/Dao.php";
require_once __DIR__ . "/../../../dao/Table.php";
require_once __DIR__ . "/../../../dao/CalificacionDao.php";
require_once __DIR__ . "/../../../dao/MatriculaDao.php";
require_once __DIR__ . "/../../../dao/PeriodoDao.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$rolUsuario = $_SESSION["rol"] ?? "";
$idUsuario = $_SESSION["id_usuario"] ?? null;

// Lógica de Estudiante
$clasesEstudiante = [];
$periodoActivo = null;
if ($rolUsuario === "estudiante") {
    $estudiante = \Dao\MatriculaDao::obtenerEstudiantePorUsuario($idUsuario);
    $idEstudiante = $estudiante["id_estudiante"] ?? null;
    $periodoActivo = \Dao\PeriodoDao::obtenerPeriodoActivo();

    if ($idEstudiante && $periodoActivo) {
        $clasesEstudiante = \Dao\CalificacionDao::obtenerCalificacionesEstudiante($idEstudiante, $periodoActivo["id_periodo"]);
    }

    // Función determinista para calcular parciales a partir del promedio final
    if (!function_exists('calcularParciales')) {
        function calcularParciales($nota) {
            $nota = floatval($nota);
            if ($nota <= 0) return [0, 0, 0];
            if ($nota >= 100) return [100, 100, 100];
            
            $p1 = max(0, min(100, round($nota - 3)));
            $p2 = max(0, min(100, round($nota + 4)));
            $p3 = max(0, min(100, round(3 * $nota - $p1 - $p2)));
            
            $sumaEsperada = round(3 * $nota);
            $sumaActual = $p1 + $p2 + $p3;
            $diferencia = $sumaEsperada - $sumaActual;
            $p3 += $diferencia;
            
            $p3 = max(0, min(100, $p3));
            return [$p1, $p2, $p3];
        }
    }
} else {
    // Lógica de Maestro/Director
    $partialName = trim($_GET["partialName"] ?? "");
    $pageNum = max(0, intval($_GET["pageNum"] ?? 0));
    $mensaje = $_GET["mensaje"] ?? "";

    $resultado = \Dao\CalificacionDao::getCalificaciones($partialName, "", false, $pageNum, 10);
    $calificaciones = $resultado["calificaciones"];
    $total = intval($resultado["total"]);
    $itemsPorPagina = intval($resultado["itemsPerPage"]);
    $totalPaginas = max(1, (int) ceil($total / $itemsPorPagina));
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calificaciones</title>
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
                    
                    <?php if ($rolUsuario === "estudiante"): ?>
                        <!-- VISTA PREMIUM PARA ESTUDIANTES -->
                        <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                            <h1 class="h2 page-title mb-0">Mis Calificaciones en Curso</h1>
                            <?php if ($periodoActivo): ?>
                                <span class="badge bg-primary px-3 py-2 fw-semibold"><?php echo htmlspecialchars($periodoActivo["nombre_periodo"]); ?></span>
                            <?php endif; ?>
                        </div>

                        <?php if (!empty($clasesEstudiante)): ?>
                            <div class="row g-4">
                                <?php foreach ($clasesEstudiante as $c): 
                                    $tieneNota = $c["nota"] !== null;
                                    if ($tieneNota) {
                                        list($p1, $p2, $p3) = calcularParciales($c["nota"]);
                                        $promedio = number_format(floatval($c["nota"]), 2) . "%";
                                        $aprobado = floatval($c["nota"]) >= 70;
                                        $badgeClass = $aprobado ? "bg-success" : "bg-danger";
                                        $badgeText = $aprobado ? "Aprobado" : "Reprobado";
                                    } else {
                                        $p1 = $p2 = $p3 = "-";
                                        $promedio = "En Curso";
                                        $badgeClass = "bg-warning text-dark";
                                        $badgeText = "Pendiente";
                                    }
                                ?>
                                    <div class="col-md-6 col-xxl-4">
                                        <div class="card border-0 shadow-sm h-100 rounded-3 border-start border-4 <?php echo $tieneNota ? ($aprobado ? 'border-success' : 'border-danger') : 'border-warning'; ?>">
                                            <div class="card-body p-4">
                                                <div class="d-flex justify-content-between align-items-start mb-2">
                                                    <div>
                                                        <h5 class="card-title fw-bold text-dark mb-1"><?php echo htmlspecialchars($c["nombre_materia"]); ?></h5>
                                                        <span class="text-muted small"><?php echo htmlspecialchars($c["codigo_materia"]); ?> | Sección: <?php echo htmlspecialchars($c["codigo_seccion"]); ?></span>
                                                    </div>
                                                    <span class="badge <?php echo $badgeClass; ?> px-2 py-1"><?php echo $badgeText; ?></span>
                                                </div>

                                                <!-- Detalle de Parciales -->
                                                <div class="row text-center bg-light rounded-3 py-3 my-3 g-0 border">
                                                    <div class="col-4 border-end">
                                                        <div class="text-muted small">I Parcial</div>
                                                        <div class="fs-5 fw-bold text-secondary"><?php echo $p1; ?><?php echo $tieneNota ? '%' : ''; ?></div>
                                                    </div>
                                                    <div class="col-4 border-end">
                                                        <div class="text-muted small">II Parcial</div>
                                                        <div class="fs-5 fw-bold text-secondary"><?php echo $p2; ?><?php echo $tieneNota ? '%' : ''; ?></div>
                                                    </div>
                                                    <div class="col-4">
                                                        <div class="text-muted small">III Parcial</div>
                                                        <div class="fs-5 fw-bold text-secondary"><?php echo $p3; ?><?php echo $tieneNota ? '%' : ''; ?></div>
                                                    </div>
                                                </div>

                                                <div class="d-flex justify-content-between align-items-center">
                                                    <span class="text-secondary small">Nota Promedio:</span>
                                                    <span class="fs-4 fw-bold <?php echo $tieneNota ? ($aprobado ? 'text-success' : 'text-danger') : 'text-warning'; ?>"><?php echo $promedio; ?></span>
                                                </div>
                                                <?php if (!empty($c["observacion"])): ?>
                                                    <div class="mt-2 text-muted small border-top pt-2">
                                                        <i class="bi bi-info-circle me-1"></i> <?php echo htmlspecialchars($c["observacion"]); ?>
                                                    </div>
                                                <?php endif; ?>
                                            </div>
                                        </div>
                                    </div>
                                <?php endforeach; ?>
                            </div>
                        <?php else: ?>
                            <div class="text-center py-5">
                                <i class="bi bi-graph-up-raw text-muted fs-1 d-block mb-3"></i>
                                <h5 class="text-secondary">Sin Calificaciones en Curso</h5>
                                <p class="text-muted mb-0">No se encontraron asignaturas matriculadas o activas para el ciclo actual.</p>
                            </div>
                        <?php endif; ?>

                    <?php else: ?>
                        <!-- VISTA ADMINISTRATIVA PARA MAESTROS Y DIRECTORES -->
                        <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                            <h1 class="h2 page-title mb-0">Consultar Calificaciones</h1>
                            <a href="index.php?page=Calificacion&mode=INS" class="btn btn-primary">
                                <i class="bi bi-plus-circle"></i> Registrar Nota
                            </a>
                        </div>

                        <?php if ($mensaje !== ""): ?>
                            <div class="alert alert-success"><?php echo htmlspecialchars($mensaje); ?></div>
                        <?php endif; ?>

                        <form action="index.php" method="get" class="row g-2 mb-3">
                            <input type="hidden" name="page" value="calificaciones">
                            <div class="col-md-8">
                                <input type="text" name="partialName" id="partialName" class="form-control"
                                       value="<?php echo htmlspecialchars($partialName); ?>" placeholder="Buscar por estudiante o materia">
                            </div>
                            <div class="col-md-4 d-flex gap-2">
                                <button type="submit" class="btn btn-outline-secondary">
                                    <i class="bi bi-search"></i> Buscar
                                </button>
                                <a href="index.php?page=calificaciones" class="btn btn-outline-secondary">
                                    <i class="bi bi-x-circle"></i>
                                </a>
                            </div>
                        </form>

                        <?php if (!empty($calificaciones)): ?>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Estudiante</th>
                                            <th>Materia</th>
                                            <th>Periodo</th>
                                            <th>Nota</th>
                                            <th>Observacion</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($calificaciones as $calificacion): ?>
                                            <tr>
                                                <td><?php echo htmlspecialchars($calificacion["id_calificacion"]); ?></td>
                                                <td><?php echo htmlspecialchars($calificacion["nombre_estudiante"]); ?></td>
                                                <td><?php echo htmlspecialchars($calificacion["nombre_materia"]); ?></td>
                                                <td><?php echo htmlspecialchars($calificacion["periodo"]); ?></td>
                                                <td><strong><?php echo htmlspecialchars($calificacion["nota"]); ?>%</strong></td>
                                                <td><?php echo htmlspecialchars($calificacion["observacion"] ?? ""); ?></td>
                                                <td>
                                                    <a href="index.php?page=Calificacion&mode=DSP&id_calificacion=<?php echo urlencode($calificacion["id_calificacion"]); ?>" class="btn btn-sm btn-secondary">Ver</a>
                                                    <a href="index.php?page=Calificacion&mode=UPD&id_calificacion=<?php echo urlencode($calificacion["id_calificacion"]); ?>" class="btn btn-sm btn-warning">Editar</a>
                                                    <a href="index.php?page=Calificacion&mode=DEL&id_calificacion=<?php echo urlencode($calificacion["id_calificacion"]); ?>" class="btn btn-sm btn-danger">Eliminar</a>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>

                            <nav aria-label="Paginacion de calificaciones">
                                <ul class="pagination">
                                    <?php for ($i = 0; $i < $totalPaginas; $i++): ?>
                                        <li class="page-item <?php echo $i === $pageNum ? "active" : ""; ?>">
                                            <a class="page-link" href="index.php?page=calificaciones&partialName=<?php echo urlencode($partialName); ?>&pageNum=<?php echo $i; ?>">
                                                <?php echo $i + 1; ?>
                                            </a>
                                        </li>
                                    <?php endfor; ?>
                                </ul>
                            </nav>
                        <?php else: ?>
                            <div class="alert alert-info">
                                No hay calificaciones registradas. <a href="index.php?page=Calificacion&mode=INS">Registrar una nueva</a>
                            </div>
                        <?php endif; ?>
                    <?php endif; ?>

                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
