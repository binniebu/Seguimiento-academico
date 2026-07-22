<?php
require_once __DIR__ . "/../../../controllers/CampusController.php";

$campus = null;
$esEdicion = false;

if (isset($_GET['id'])) {
    $campus = \Controllers\CampusController::obtenerPorId($_GET['id']);
    $esEdicion = $campus !== false && $campus !== null;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $esEdicion ? 'Editar Campus / Sede' : 'Nuevo Campus / Sede'; ?></title>
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
                            <h1 class="h2 page-title mb-0"><?php echo $esEdicion ? 'Editar Campus / Sede' : 'Registro de Nuevo Campus / Sede'; ?></h1>
                        </div>
                        <a href="index.php?page=campuses" class="btn btn-secondary">
                            <i class="bi bi-arrow-left"></i> Volver al listado
                        </a>
                    </div>

                    <div class="row mt-4">
                        <div class="col-md-8 offset-md-2 col-lg-6 offset-lg-3">
                            <div class="card shadow-sm border-0">
                                <div class="card-body p-4">
                                    <form method="POST" action="index.php?page=campus_guardar">
                                        <?php if ($esEdicion): ?>
                                            <input type="hidden" name="id_campus" value="<?php echo htmlspecialchars($campus['id_campus']); ?>">
                                        <?php endif; ?>

                                        <div class="mb-4">
                                            <label for="nombre_campus" class="form-label fw-bold">Nombre del Campus <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control form-control-lg" id="nombre_campus" name="nombre_campus" 
                                                   value="<?php echo htmlspecialchars($campus['nombre_campus'] ?? ''); ?>" 
                                                   required maxlength="100" placeholder="Ej: Campus Valle de Sula">
                                        </div>

                                        <div class="mb-4">
                                            <label for="departamento" class="form-label fw-bold">Departamento / Ubicación <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control form-control-lg" id="departamento" name="departamento" 
                                                   value="<?php echo htmlspecialchars($campus['departamento'] ?? ''); ?>" 
                                                   required maxlength="100" placeholder="Ej: Cortés">
                                        </div>

                                        <?php if ($esEdicion): ?>
                                            <div class="mb-4">
                                                <label for="estado" class="form-label fw-bold">Estado <span class="text-danger">*</span></label>
                                                <select class="form-select form-select-lg" id="estado" name="estado" required>
                                                    <option value="activo" <?php echo ($campus['estado'] === 'activo') ? 'selected' : ''; ?>>Activo</option>
                                                    <option value="inactivo" <?php echo ($campus['estado'] === 'inactivo') ? 'selected' : ''; ?>>Inactivo</option>
                                                </select>
                                            </div>
                                        <?php endif; ?>

                                        <div class="d-flex gap-2 pt-2">
                                            <button type="submit" class="btn btn-primary px-4 py-2 fw-bold">
                                                <i class="bi bi-check-circle"></i> 
                                                <?php echo $esEdicion ? 'Guardar Cambios' : 'Registrar Campus'; ?>
                                            </button>
                                            <a href="index.php?page=campuses" class="btn btn-outline-secondary px-4 py-2">
                                                Cancelar
                                            </a>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
