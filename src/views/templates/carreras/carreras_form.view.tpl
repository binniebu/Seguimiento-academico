<?php
require_once __DIR__ . "/../../../dao/CarreraDao.php";
require_once __DIR__ . "/../../../controllers/FacultadesController.php";

$carrera = null;
if (isset($_GET['id'])) {
    $carrera = \Dao\CarreraDao::obtenerCarreraPorId($_GET['id']);
}

$isEdit = !empty($carrera);
$facultades = \Controllers\FacultadesController::listar();

if (!function_exists('fixDoubleEncoding')) {
    function fixDoubleEncoding($str) {
        if (strpos($str, '├') !== false || strpos($str, '┬') !== false) {
            return mb_convert_encoding($str, 'ISO-8859-1', 'UTF-8');
        }
        return $str;
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $isEdit ? 'Editar Carrera' : 'Nueva Carrera'; ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container mt-5" style="max-width: 600px;">
    <div class="card shadow-sm border-0 main-content-card">
        <div class="pb-3 mb-4 border-bottom">
            <h2 class="page-title mb-0">
                <i class="bi bi-tags"></i>
                <?php echo $isEdit ? 'Editar Carrera' : 'Registrar Nueva Carrera'; ?>
            </h2>
        </div>

        <form method="POST" action="index.php?page=carrera_guardar">
            <?php if ($isEdit): ?>
                <input type="hidden" name="id_carrera" value="<?php echo htmlspecialchars($carrera['id_carrera']); ?>">
            <?php endif; ?>

            <div class="mb-3">
                <label class="form-label">Nombre de la Carrera</label>
                <input type="text" 
                       name="nombre_carrera" 
                       class="form-control" 
                       value="<?php echo htmlspecialchars(fixDoubleEncoding($carrera['nombre_carrera'] ?? '')); ?>" 
                       placeholder="Ej: Ingeniería en Sistemas" 
                       required>
            </div>

            <div class="mb-3">
                <label class="form-label">Facultad Perteneciente <span class="text-danger">*</span></label>
                <select name="id_facultad" class="form-select" required>
                    <option value="">-- Selecciona una facultad --</option>
                    <?php foreach ($facultades as $fac): ?>
                        <option value="<?php echo $fac['id_facultad']; ?>" <?php echo ($carrera['id_facultad'] ?? '') == $fac['id_facultad'] ? 'selected' : ''; ?>>
                            <?php echo htmlspecialchars($fac['nombre_facultad']); ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <?php if ($isEdit): ?>
                <div class="mb-3">
                    <label class="form-label">Estado</label>
                    <select name="estado" class="form-select" required>
                        <option value="activa" <?php echo ($carrera['estado'] ?? '') === 'activa' ? 'selected' : ''; ?>>Activa</option>
                        <option value="inactiva" <?php echo ($carrera['estado'] ?? '') === 'inactiva' ? 'selected' : ''; ?>>Inactiva</option>
                    </select>
                </div>
            <?php endif; ?>

            <div class="mt-4">
                <button type="submit" class="btn btn-success">
                    <i class="bi bi-save"></i> Guardar Carrera
                </button>
                <a href="index.php?page=carreras" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Cancelar
                </a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
