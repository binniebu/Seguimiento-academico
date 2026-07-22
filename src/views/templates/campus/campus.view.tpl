<?php
require_once __DIR__ . "/../../../controllers/CampusController.php";
$campuses = \Controllers\CampusController::listar();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Campus / Sedes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <!-- Main content -->
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card bg-white rounded shadow-sm p-4">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">Catálogo de Campus / Sedes</h1>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="index.php?page=campus_nuevo" class="btn btn-primary fw-bold">
                            <i class="bi bi-plus-circle"></i> Nuevo Campus
                        </a>
                    </div>
                </div>

                <div class="alert alert-info border-0 shadow-sm mb-4">
                    <i class="bi bi-info-circle-fill me-2"></i> <strong>Aviso:</strong> Los campus representan las distintas sedes geográficas de la universidad. Puede editar sus nombres, departamentos o desactivarlos si ya no están disponibles para nuevas admisiones.
                </div>

                <!-- Tabla de Campus -->
                <?php if (!empty($campuses)): ?>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Nombre del Campus</th>
                                    <th>Ubicación / Departamento</th>
                                    <th class="text-center">Estado</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($campuses as $cp): ?>
                                    <tr>
                                        <td class="fw-semibold text-dark"><?php echo htmlspecialchars($cp['nombre_campus']); ?></td>
                                        <td><?php echo htmlspecialchars($cp['departamento']); ?></td>
                                        <td class="text-center">
                                            <?php if ($cp['estado'] === 'activo'): ?>
                                                <span class="badge bg-success">Activo</span>
                                            <?php else: ?>
                                                <span class="badge bg-danger">Inactivo</span>
                                            <?php endif; ?>
                                        </td>
                                        <td class="text-end">
                                            <a href="index.php?page=campus_nuevo&id=<?php echo $cp['id_campus']; ?>" class="btn btn-sm btn-warning">
                                                <i class="bi bi-pencil"></i> Editar
                                            </a>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php else: ?>
                    <div class="text-center py-5">
                        <i class="bi bi-building fs-1 text-muted"></i>
                        <p class="text-muted mt-2">No hay campus registrados en el sistema.</p>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
