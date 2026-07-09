<?php
require_once __DIR__ . "/../../../controllers/PeriodosController.php";

use Controllers\PeriodosController;

$mensajeError = "";
$mensajeExito = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    if (isset($_POST["accion"]) && $_POST["accion"] === "crear") {
        $resultado = PeriodosController::crearPeriodo($_POST["fecha_inicio"] ?? "");
        if ($resultado["exito"]) {
            $mensajeExito = $resultado["mensaje"];
        } else {
            $mensajeError = $resultado["mensaje"];
        }
    }
}

if (isset($_GET["accion"]) && $_GET["accion"] === "activar" && isset($_GET["id"])) {
    $resultado = PeriodosController::activarPeriodo($_GET["id"]);
    if ($resultado["exito"]) {
        $mensajeExito = $resultado["mensaje"];
    } else {
        $mensajeError = $resultado["mensaje"];
    }
}

$periodos = PeriodosController::listarPeriodos();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Periodos Académicos</title>
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
                        <h1 class="h2 page-title mb-0">Gestión de Periodos Académicos</h1>
                    </div>
                </div>

                <div class="row g-4">
                    <!-- Formulario de Configuración -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm rounded-3">
                            <div class="card-header bg-primary text-white py-3 rounded-top-3">
                                <h5 class="card-title mb-0"><i class="bi bi-calendar-plus me-2"></i>Activar Nuevo Periodo</h5>
                            </div>
                            <div class="card-body p-4">
                                <p class="text-muted small">
                                    Ingrese la fecha de inicio del período académico. El sistema calculará automáticamente la fecha de finalización (14 semanas totales, incluyendo 1 de entrega de notas) y autodetectará el nombre según el mes de inicio.
                                </p>
                                <form method="POST" action="index.php?page=periodos" autocomplete="off">
                                    <input type="hidden" name="accion" value="crear">
                                    
                                    <div class="mb-3">
                                        <label for="fecha_inicio" class="form-label">Fecha de Inicio</label>
                                        <input type="date" id="fecha_inicio" name="fecha_inicio" class="form-control" required>
                                        <div class="form-text">
                                            No se permiten sábados o domingos.
                                        </div>
                                    </div>

                                    <button type="submit" class="btn btn-primary w-100 mt-2">
                                        <i class="bi bi-play-circle me-1"></i> Calcular y Activar
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Listado de Periodos -->
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm rounded-3">
                            <div class="card-header bg-light py-3 rounded-top-3">
                                <h5 class="card-title mb-0 text-secondary"><i class="bi bi-calendar-event me-2"></i>Historial de Periodos</h5>
                            </div>
                            <div class="card-body p-4">
                                <?php if (!empty($periodos)): ?>
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle">
                                            <thead>
                                                <tr>
                                                    <th>Periodo</th>
                                                    <th>Fecha Inicio</th>
                                                    <th>Fecha Fin</th>
                                                    <th class="text-center">Estado</th>
                                                    <th class="text-end">Acción</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($periodos as $p): ?>
                                                    <tr>
                                                        <td class="fw-bold text-dark"><?php echo htmlspecialchars($p['nombre_periodo']); ?></td>
                                                        <td><?php echo htmlspecialchars($p['fecha_inicio']); ?></td>
                                                        <td><?php echo htmlspecialchars($p['fecha_fin']); ?></td>
                                                        <td class="text-center">
                                                            <?php if ($p['estado'] === 'activo'): ?>
                                                                <span class="badge bg-success">Activo</span>
                                                            <?php else: ?>
                                                                <span class="badge bg-secondary">Inactivo</span>
                                                            <?php endif; ?>
                                                        </td>
                                                        <td class="text-end">
                                                            <?php if ($p['estado'] === 'activo'): ?>
                                                                <button class="btn btn-sm btn-light disabled" disabled>Vigente</button>
                                                            <?php elseif ($p['fecha_fin'] < date('Y-m-d')): ?>
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-2">Finalizado</span>
                                                            <?php else: ?>
                                                                <a href="index.php?page=periodos&accion=activar&id=<?php echo $p['id_periodo']; ?>" 
                                                                   class="btn btn-sm btn-outline-primary"
                                                                   onclick="return confirm('¿Desea activar este periodo académico? Se desactivará el periodo actual.');">
                                                                    <i class="bi bi-check-circle me-1"></i> Activar
                                                                </a>
                                                            <?php endif; ?>
                                                        </td>
                                                    </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                <?php else: ?>
                                    <div class="text-center py-5">
                                        <i class="bi bi-inbox text-muted fs-1 d-block mb-3"></i>
                                        <p class="text-muted mb-0">No hay periodos registrados en el sistema.</p>
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
            title: 'Error de Validación',
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
            window.location = "index.php?page=periodos";
        });
    </script>
<?php endif; ?>
</body>
</html>
