<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Estudiante</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/css/tom-select.bootstrap5.min.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>

<body>

<div class="container mt-4">

    <div class="card shadow">

        <div class="card-header bg-primary text-white">
            <h4>
                <i class="bi bi-people"></i>
                Registro de Estudiante
            </h4>
        </div>

        <div class="card-body">

            <?php
            require_once __DIR__ . "/../../../controllers/EstudiantesController.php";

            $estudiante = null;
            if (isset($_GET['id'])) {
                $estudiante = \Controllers\EstudiantesController::obtener($_GET['id']);
            }

            $isEdit = !empty($estudiante);
            require_once __DIR__ . "/../../../dao/CarreraDao.php";
            require_once __DIR__ . "/../../../dao/EstudianteDao.php";
            $carrerasList = \Dao\CarreraDao::obtenerCarrerasParaRegistro();
            $carrerasAsignadas = $isEdit ? \Dao\EstudianteDao::obtenerCarrerasEstudiante($estudiante["id_estudiante"]) : [];
            $idsCarrerasAsignadas = array_map(fn($c) => intval($c["id_carrera"]), $carrerasAsignadas);

            if (!function_exists('fixDoubleEncoding')) {
                function fixDoubleEncoding($str) {
                    if (strpos($str, '├') !== false || strpos($str, '┬') !== false) {
                        return mb_convert_encoding($str, 'ISO-8859-1', 'UTF-8');
                    }
                    return $str;
                }
            }
            ?>

            <form method="POST" action="index.php?page=estudiante_guardar">

                <?php if ($isEdit): ?>
                    <input type="hidden" name="id_estudiante" value="<?php echo htmlspecialchars($estudiante['id_estudiante']); ?>">
                    <input type="hidden" name="id_usuario" value="<?php echo htmlspecialchars($estudiante['id_usuario']); ?>">
                <?php endif; ?>

                <div class="row">

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nombre Completo</label>
                           <input type="text"
                               name="nombre"
                               class="form-control"
                               value="<?php echo htmlspecialchars($estudiante['nombre'] ?? ''); ?>"
                               required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Correo</label>
                           <input type="email"
                               name="correo"
                               class="form-control"
                               value="<?php echo htmlspecialchars($estudiante['correo'] ?? ''); ?>"
                               required>
                    </div>

                    <?php if (!$isEdit): ?>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Contraseña</label>
                           <input type="password"
                               name="password"
                               class="form-control">
                            <div class="form-text">Obligatoria solo si el correo no existe. Si es un profesor existente, se usara su misma cuenta.</div>
                    </div>
                    <?php endif; ?>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Cuenta</label>
                           <input type="text"
                               name="cuenta"
                               class="form-control"
                               placeholder="2026-001"
                               value="<?php echo htmlspecialchars($estudiante['cuenta'] ?? ''); ?>"
                               required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Carrera(s)</label>
                        <select name="carreras[]" id="carreraSelect" class="form-select" multiple required>
                            <?php foreach ($carrerasList as $c): ?>
                                <?php $selected = in_array(intval($c["id_carrera"]), $idsCarrerasAsignadas, true); ?>
                                <option value="<?php echo intval($c['id_carrera']); ?>" <?php echo $selected ? "selected" : ""; ?>>
                                    <?php echo htmlspecialchars($c['nombre_carrera']); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                        <input type="hidden" name="carrera" id="carreraPrincipal" value="<?php echo htmlspecialchars($estudiante['carrera'] ?? ''); ?>">
                        <div class="form-text">Puede seleccionar mas de una. La primera queda como carrera principal.</div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Teléfono</label>
                           <input type="text"
                               name="telefono"
                               class="form-control"
                               value="<?php echo htmlspecialchars($estudiante['telefono'] ?? ''); ?>">
                    </div>

                </div>

                <div class="mt-4">

                    <button type="submit" class="btn btn-success">
                        <i class="bi bi-save"></i>
                        Guardar Estudiante
                    </button>

                    <a href="index.php?page=estudiantes"
                       class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i>
                        Regresar
                    </a>

                </div>

            </form>

        </div>

    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
// Inicializar TomSelect solo en modo creación (no en edición donde la carrera está deshabilitada)
if (document.getElementById('carreraSelect')) {
    const carreraSelect = new TomSelect('#carreraSelect', {
        placeholder: 'Escribe para buscar la carrera...',
        plugins: ['remove_button'],
        maxOptions: 30,
    });
    const hiddenPrincipal = document.getElementById('carreraPrincipal');
    const syncPrincipal = () => {
        const values = carreraSelect.getValue();
        const firstValue = Array.isArray(values) ? values[0] : values;
        const option = firstValue ? carreraSelect.options[firstValue] : null;
        hiddenPrincipal.value = option ? option.text : '';
    };
    carreraSelect.on('change', syncPrincipal);
    syncPrincipal();
}
</script>
</body>
</html>
