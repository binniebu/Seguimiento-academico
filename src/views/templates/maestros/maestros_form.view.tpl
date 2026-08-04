<?php
require_once __DIR__ . "/../../../dao/MaestroDao.php";
require_once __DIR__ . "/../../../dao/FacultadDao.php";
require_once __DIR__ . "/../../../dao/CarreraDao.php";
require_once __DIR__ . "/../../../controllers/CampusController.php";

$personal = null;
$rolActual = 2; // Maestro por defecto
$isEdit = false;

if (isset($_GET['id'])) {
    $idMaestro = intval($_GET['id']);
    $personal = \Dao\MaestroDao::obtenerMaestroPorId($idMaestro);
    $rolActual = 2;
    $isEdit = !empty($personal);
} elseif (isset($_GET['id_coordinador'])) {
    $idCoordinador = intval($_GET['id_coordinador']);
    $personal = \Dao\MaestroDao::obtenerCoordinadorPorId($idCoordinador);
    $rolActual = 4;
    $isEdit = !empty($personal);
}

$todasFacultades = \Dao\FacultadDao::obtenerTodas();
$todasCarreras = \Dao\CarreraDao::obtenerCarreras(false);
$todasCampuses = \Controllers\CampusController::listar();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <?php 
        if (!$isEdit) echo "Registrar Personal";
        elseif ($rolActual == 2) echo "Editar Maestro";
        else echo "Editar Coordinador";
        ?>
    </title>
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
                        <h1 class="h2 page-title mb-0">
                            <?php 
                            if (!$isEdit) echo "Registrar Maestro / Coordinador";
                            elseif ($rolActual == 2) echo "Editar Maestro";
                            else echo "Editar Coordinador";
                            ?>
                        </h1>
                    </div>
                    <a href="index.php?page=maestros" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <form method="POST" action="index.php?page=maestro_guardar" class="p-4 border rounded shadow-sm bg-white row g-3">
                    <?php if ($isEdit): ?>
                        <input type="hidden" name="id_usuario" value="<?php echo htmlspecialchars($personal['id_usuario']); ?>">
                        <?php if ($rolActual == 2): ?>
                            <input type="hidden" name="id_maestro" value="<?php echo htmlspecialchars($personal['id_maestro']); ?>">
                        <?php else: ?>
                            <input type="hidden" name="id_coordinador" value="<?php echo htmlspecialchars($personal['id_coordinador']); ?>">
                        <?php endif; ?>
                    <?php endif; ?>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Nombre Completo</label>
                        <input type="text" name="nombre" class="form-control" 
                               value="<?php echo htmlspecialchars($personal['nombre'] ?? ''); ?>" required>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">DNI <span class="text-danger">*</span></label>
                        <input type="text" name="dni" class="form-control" 
                               pattern="[0-9]{13}" maxlength="13" minlength="13"
                               title="El DNI debe constar de exactamente 13 dígitos numéricos."
                               oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                               value="<?php echo htmlspecialchars($personal['dni'] ?? ''); ?>" required>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Correo Electrónico</label>
                        <input type="email" name="correo" class="form-control" 
                               value="<?php echo htmlspecialchars($personal['correo'] ?? ''); ?>" required>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Teléfono</label>
                        <input type="text" name="telefono" class="form-control" 
                               value="<?php echo htmlspecialchars($personal['telefono'] ?? ''); ?>" required>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Título Profesional</label>
                        <input type="text" name="titulo" class="form-control" 
                               value="<?php echo htmlspecialchars($personal['titulo'] ?? ''); ?>" required>
                    </div>

                    <?php if (!$isEdit): ?>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Contraseña</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                    <?php endif; ?>

                    <div class="col-md-12">
                        <label class="form-label fw-semibold">Rol de Usuario</label>
                        <?php if ($isEdit): ?>
                            <!-- Bloqueamos el rol en edición para evitar inconsistencias y usamos un hidden -->
                            <input type="hidden" name="rol" value="<?php echo $rolActual; ?>">
                            <select class="form-select" disabled>
                                <option value="2" <?php echo $rolActual == 2 ? 'selected' : ''; ?>>Maestro</option>
                                <option value="4" <?php echo $rolActual == 4 ? 'selected' : ''; ?>>Coordinador</option>
                            </select>
                        <?php else: ?>
                            <select name="rol" id="select_rol" class="form-select" onchange="toggleFields()" required>
                                <option value="2" <?php echo $rolActual == 2 ? 'selected' : ''; ?>>Maestro</option>
                                <option value="4" <?php echo $rolActual == 4 ? 'selected' : ''; ?>>Coordinador</option>
                            </select>
                        <?php endif; ?>
                    </div>

                    <div class="col-md-12">
                        <label class="form-label fw-semibold">Campus / Sede <span class="text-danger">*</span></label>
                        <?php if ($isEdit): ?>
                            <!-- Bloqueamos el campus en edición tal como los estudiantes y usamos un hidden -->
                            <input type="hidden" name="id_campus" value="<?php echo htmlspecialchars($personal['id_campus'] ?? ''); ?>">
                            <select class="form-select" disabled>
                                <option value="">-- Selecciona un campus --</option>
                                <?php foreach ($todasCampuses as $cp): ?>
                                    <option value="<?php echo $cp['id_campus']; ?>" <?php echo ($personal['id_campus'] ?? '') == $cp['id_campus'] ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($cp['nombre_campus']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        <?php else: ?>
                            <select name="id_campus" id="select_campus" class="form-select" required>
                                <option value="">-- Selecciona un campus --</option>
                                <?php foreach ($todasCampuses as $cp): ?>
                                    <option value="<?php echo $cp['id_campus']; ?>">
                                        <?php echo htmlspecialchars($cp['nombre_campus']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        <?php endif; ?>
                    </div>

                    <!-- Campos específicos para COORDINADOR -->
                    <div id="campos_coordinador" class="col-12 mt-4" style="display:none;">
                        <div class="card bg-light border-0">
                            <div class="card-body row">
                                <h6 class="text-primary mb-3"><i class="bi bi-building"></i> Datos de Facultad (Coordinador)</h6>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Facultad Asignada</label>
                                    <select name="id_facultad" id="select_facultad_coordinador" class="form-select">
                                        <option value="">-- Selecciona una facultad --</option>
                                        <?php foreach ($todasFacultades as $fac): ?>
                                            <option value="<?php echo $fac['id_facultad']; ?>" 
                                                <?php echo ($personal['id_facultad'] ?? '') == $fac['id_facultad'] ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($fac['nombre_facultad']); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Campos específicos para MAESTRO -->
                    <div id="campos_maestro" class="col-12 mt-4" style="display:none;">
                        <div class="card bg-light border-0">
                            <div class="card-body row g-3">
                                <h6 class="text-primary mb-1"><i class="bi bi-person-workspace"></i> Adscripción Académica (Maestro)</h6>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Facultad de Clases</label>
                                    <select name="id_facultad" id="select_facultad_maestro" class="form-select" onchange="filterCareers()">
                                        <option value="">-- Selecciona una facultad --</option>
                                        <?php foreach ($todasFacultades as $fac): ?>
                                            <option value="<?php echo $fac['id_facultad']; ?>" 
                                                <?php echo ($personal['id_facultad'] ?? '') == $fac['id_facultad'] ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($fac['nombre_facultad']); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Carrera de Clases</label>
                                    <select name="id_carrera" id="select_carrera_maestro" class="form-select">
                                        <option value="">-- Selecciona una carrera --</option>
                                        <?php foreach ($todasCarreras as $car): ?>
                                            <option value="<?php echo $car['id_carrera']; ?>" 
                                                data-facultad="<?php echo $car['id_facultad']; ?>"
                                                <?php echo ($personal['id_carrera'] ?? '') == $car['id_carrera'] ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($car['nombre_carrera']); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex gap-3 mt-4">
                        <button type="submit" class="btn btn-primary w-100 py-2">
                            <i class="bi bi-save"></i> Guardar Registro
                        </button>
                        <a href="index.php?page=maestros" class="btn btn-secondary w-100 text-center py-2">
                            Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<script>
function toggleFields() {
    // Si está bloqueado/disabled por edición, tomamos el valor del rol actual
    const rolSelect = document.getElementById('select_rol');
    const rol = rolSelect ? rolSelect.value : "<?php echo $rolActual; ?>";

    const divMaestro = document.getElementById('campos_maestro');
    const divCoordinador = document.getElementById('campos_coordinador');
    const selFacCoord = document.getElementById('select_facultad_coordinador');
    const selFacMaestro = document.getElementById('select_facultad_maestro');
    const selCarMaestro = document.getElementById('select_carrera_maestro');

    if (rol == '2') {
        divMaestro.style.display = 'block';
        divCoordinador.style.display = 'none';
        
        selFacMaestro.disabled = false;
        selCarMaestro.disabled = false;
        selFacCoord.disabled = true;
    } else if (rol == '4') {
        divMaestro.style.display = 'none';
        divCoordinador.style.display = 'block';
        
        selFacMaestro.disabled = true;
        selCarMaestro.disabled = true;
        selFacCoord.disabled = false;
    }
}

function filterCareers() {
    const facultyId = document.getElementById('select_facultad_maestro').value;
    const careerSelect = document.getElementById('select_carrera_maestro');
    const options = careerSelect.options;
    
    let hasVisibleOptionSelected = false;
    
    for (let i = 0; i < options.length; i++) {
        const opt = options[i];
        if (opt.value === "") continue;
        
        const optFacId = opt.getAttribute('data-facultad');
        if (!facultyId || optFacId == facultyId) {
            opt.style.display = 'block';
            if (opt.selected) {
                hasVisibleOptionSelected = true;
            }
        } else {
            opt.style.display = 'none';
            if (opt.selected) {
                opt.selected = false;
            }
        }
    }
    
    if (!hasVisibleOptionSelected) {
        careerSelect.value = "";
    }
}

// Inicializar vistas y filtros
window.onload = function() {
    toggleFields();
    if (document.getElementById('select_facultad_maestro').value !== "") {
        filterCareers();
    }
};
</script>
<script>
// Mostrar alerta SweetAlert2 si existen parámetros de redirección en la URL
<?php
$msg = $_GET['msg'] ?? '';
$tipo_msg = $_GET['tipo_msg'] ?? '';
if ($msg && $tipo_msg):
?>
Swal.fire({
    title: <?php echo json_encode($tipo_msg === "success" ? "¡Éxito!" : "Atención"); ?>,
    text: <?php echo json_encode($msg); ?>,
    icon: <?php echo json_encode($tipo_msg); ?>,
    confirmButtonColor: '#0057d8',
    confirmButtonText: 'Aceptar',
    customClass: {
        popup: 'rounded-4 shadow',
        confirmButton: 'px-4 py-2 font-weight-bold'
    }
});
<?php endif; ?>
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>