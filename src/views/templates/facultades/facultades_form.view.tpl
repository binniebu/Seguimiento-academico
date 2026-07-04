<?php
require_once __DIR__ . "/../../../controllers/FacultadesController.php";

$facultad = null;
$esEdicion = false;

if (isset($_GET['id'])) {
    $facultad = \Controllers\FacultadesController::obtener($_GET['id']);
    $esEdicion = $facultad !== false && $facultad !== null;
}

// Procesar formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resultado = \Controllers\FacultadesController::guardar();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $esEdicion ? 'Editar Facultad' : 'Nueva Facultad'; ?></title>
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
            <main role="main" class="col-md-10 ml-sm-auto px-md-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><?php echo $esEdicion ? 'Editar Nombre de la Facultad' : 'Registro de Nueva Facultad'; ?></h1>
                    <a href="index.php?page=facultades" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Volver al catálogo
                    </a>
                </div>

                <?php if (isset($resultado)): ?>
                    <div class="alert alert-<?php echo $resultado['exito'] ? 'success' : 'danger'; ?>">
                        <?php echo htmlspecialchars($resultado['mensaje']); ?>
                    </div>
                    <?php if ($resultado['exito']): ?>
                        <script>
                            setTimeout(function() {
                                window.location = "index.php?page=facultades";
                            }, 100);
                        </script>
                    <?php endif; ?>
                <?php endif; ?>

                <div class="row mt-4">
                    <div class="col-md-6 offset-md-3">
                        <div class="card shadow-sm border-0">
                            <div class="card-body p-4">
                                <form method="POST" action="">
                                    <?php if ($esEdicion): ?>
                                        <input type="hidden" name="id_facultad" value="<?php echo htmlspecialchars($facultad['id_facultad']); ?>">
                                    <?php endif; ?>

                                    <div class="mb-4">
                                        <label for="nombre_facultad" class="form-label fw-bold">Nombre de la Facultad <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-lg" id="nombre_facultad" name="nombre_facultad" 
                                               value="<?php echo htmlspecialchars($facultad['nombre_facultad'] ?? ''); ?>" 
                                               required maxlength="100" placeholder="Ej: Ciencias Médicas">
                                    </div>

                                    <div class="d-flex gap-2 pt-2">
                                        <button type="submit" class="btn btn-primary px-4 py-2">
                                            <i class="bi bi-check-circle"></i> 
                                            <?php echo $esEdicion ? 'Guardar Cambios' : 'Registrar Facultad'; ?>
                                        </button>
                                        <a href="index.php?page=facultades" class="btn btn-outline-secondary px-4 py-2">
                                            Cancelar
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>
                        
                        <?php if ($esEdicion): ?>
                        <div class="alert alert-info mt-4">
                            <i class="bi bi-info-circle"></i> Al cambiar el nombre de esta facultad, el nuevo nombre se reflejará automáticamente en todas las carreras y materias adscritas a ella.
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
