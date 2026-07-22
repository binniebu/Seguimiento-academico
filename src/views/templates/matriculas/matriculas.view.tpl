<?php
require_once __DIR__ . "/../../../controllers/MatriculasController.php";

use Controllers\MatriculasController;

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$buscar = trim($_GET["buscar"] ?? "");
$mensajeExito = "";
$mensajeError = "";

if (isset($_GET["accion"]) && $_GET["accion"] === "cancelar_admin" && isset($_GET["id"])) {
    $res = MatriculasController::cancelarMatriculaEstudiante($_GET["id"]);
    if ($res["exito"]) {
        $mensajeExito = $res["mensaje"];
    } else {
        $mensajeError = $res["mensaje"];
    }
}

$matriculas = MatriculasController::listar($buscar);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitoreo de Matrículas</title>
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
                
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">Monitoreo de Matrículas</h1>
                    </div>
                </div>

                <!-- Barra de búsqueda y filtros -->
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body p-3">
                        <form method="GET" action="index.php" class="row g-3 align-items-center">
                            <input type="hidden" name="page" value="matriculas">
                            
                            <div class="col-md-8">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted">
                                        <i class="bi bi-search"></i>
                                    </span>
                                    <input type="text" 
                                           name="buscar" 
                                           class="form-control border-start-0 ps-0" 
                                           placeholder="Buscar por estudiante, cuenta, materia o sección..." 
                                           value="<?php echo htmlspecialchars($buscar); ?>">
                                </div>
                            </div>
                            
                            <div class="col-md-4 d-flex gap-2">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-funnel me-1"></i> Filtrar
                                </button>
                                <?php if ($buscar !== ""): ?>
                                    <a href="index.php?page=matriculas" class="btn btn-outline-secondary">
                                        Limpiar
                                    </a>
                                <?php endif; ?>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Tabla de Matrículas -->
                <div class="card border-0 shadow-sm rounded-3">
                    <div class="card-body p-0">
                        <?php if (!empty($matriculas)): ?>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Estudiante</th>
                                            <th>Carrera</th>
                                            <th>Sección / Asignatura</th>
                                            <th>Periodo</th>
                                            <th>Fecha Matrícula</th>
                                            <th class="text-end">Acción</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($matriculas as $m): ?>
                                            <tr>
                                                <td>
                                                    <div class="fw-bold text-dark"><?php echo htmlspecialchars($m['estudiante_nombre']); ?></div>
                                                    <span class="badge bg-light text-secondary border small mt-1">Cuenta: <?php echo htmlspecialchars($m['estudiante_dni']); ?></span>
                                                </td>
                                                <td><?php echo htmlspecialchars($m['nombre_carrera'] ?? "Clases Generales"); ?></td>
                                                <td>
                                                    <div class="fw-semibold text-dark"><?php echo htmlspecialchars($m['materia_nombre']); ?></div>
                                                    <span class="text-muted small">Sección: <span class="fw-bold text-primary"><?php echo htmlspecialchars($m['codigo_seccion']); ?></span></span>
                                                </td>
                                                <td>
                                                    <span class="badge bg-info-subtle text-info border border-info-subtle px-2 py-1"><?php echo htmlspecialchars($m['nombre_periodo']); ?></span>
                                                </td>
                                                <td class="text-muted small">
                                                    <?php echo htmlspecialchars(date('d/m/Y h:i A', strtotime($m['fecha_matricula']))); ?>
                                                </td>
                                                <td class="text-end pe-3">
                                                     <a href="index.php?page=matriculas&accion=cancelar_admin&id=<?php echo urlencode($m['id_matricula']); ?>"
                                                        class="btn btn-sm btn-outline-danger"
                                                        data-confirmar="¿Está seguro de realizar la cancelación administrativa de esta matrícula? Esta acción es irreversible y el alumno perderá su plaza." 
                                                        data-titulo="Cancelar Matrícula Administrativamente" 
                                                        data-confirm-text="Sí, dar de baja" 
                                                        data-icono="warning">
                                                        <i class="bi bi-trash-fill me-1"></i> Dar de Baja
                                                    </a>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php else: ?>
                            <div class="text-center py-5">
                                <i class="bi bi-inbox text-muted fs-1 d-block mb-3"></i>
                                <p class="text-muted mb-0">No se encontraron matrículas con los criterios especificados.</p>
                            </div>
                        <?php endif; ?>
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
            title: 'Error Administrativo',
            text: <?php echo json_encode($mensajeError); ?>,
            confirmButtonColor: '#0057d8'
        });
    </script>
<?php endif; ?>

<?php if ($mensajeExito !== ""): ?>
    <script>
        Swal.fire({
            icon: 'success',
            title: '¡Operación Exitosa!',
            text: <?php echo json_encode($mensajeExito); ?>,
            confirmButtonColor: '#0057d8'
        }).then(() => {
            window.location = "index.php?page=matriculas";
        });
    </script>
<?php endif; ?>
</body>
</html>