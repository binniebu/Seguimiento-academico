<?php
require_once __DIR__ . "/../../../controllers/MateriasController.php";
require_once __DIR__ . "/../../../dao/CarreraDao.php";

$materia = null;
$esEdicion = false;
$facultades = \Controllers\MateriasController::obtenerFacultades();
$carreras = \Controllers\MateriasController::obtenerCarrerasActivas();
$todas_materias = [];
$id_carrera_pre = $_GET['id_carrera_pre'] ?? null;
$id_carrera_context = $id_carrera_pre;

if (isset($_GET['id'])) {
    $materia = \Controllers\MateriasController::obtener($_GET['id']);
    $esEdicion = $materia !== null;
    $id_carrera_context = $id_carrera_context ?? ($materia['id_carrera'] ?? null);
}

if ($id_carrera_context) {
    $carreraContext = \Dao\CarreraDao::obtenerCarreraPorId($id_carrera_context);
    if ($carreraContext && !empty($carreraContext['id_facultad'])) {
        $todas_materias = \Dao\MateriaDao::obtenerFlujogramaPorCarrera($id_carrera_context, $carreraContext['id_facultad']);
    } else {
        $todas_materias = \Controllers\MateriasController::listar();
    }
} else {
    $todas_materias = \Controllers\MateriasController::listar();
}

// Procesar formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $codigo = $_POST['codigo'] ?? '';
    $nombre = $_POST['nombre'] ?? '';
    $descripcion = $_POST['descripcion'] ?? '';
    $creditos = $_POST['creditos'] ?? 3;
    $periodo = $_POST['periodo'] ?? 1;
    $tipo_materia = $_POST['tipo_materia'] ?? 'institucional';
    $id_facultad = $_POST['id_facultad'] ?? null;
    $id_carrera = $_POST['id_carrera'] ?? null;
    $id_requisito = $_POST['id_requisito'] ?? null;
    
    if (empty($id_facultad) || $tipo_materia === 'institucional') {
        $id_facultad = null;
        $id_carrera = null;
    } elseif ($tipo_materia === 'facultad') {
        $id_carrera = null;
    }

    if ($esEdicion) {
        $estado = $_POST['estado'] ?? 'activa';
        $resultado = \Controllers\MateriasController::actualizar(
            $_GET['id'], $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito, $estado
        );
    } else {
        $resultado = \Controllers\MateriasController::crear(
            $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito
        );
    }

    if ($resultado['exito']) {
        $successMsg = $resultado['mensaje'];
        $idC = htmlspecialchars($id_carrera_pre ?? ($materia['id_carrera'] ?? ''));
        $redirectUrl = $idC ? "index.php?page=carrera_flujograma&id=$idC" : "index.php?page=carreras";
    } else {
        $errorMsg = $resultado['mensaje'];
        $materia = $_POST; // Retener los datos rellenados
        if ($esEdicion && isset($_GET['id'])) {
            $materia['id_materia'] = $_GET['id'];
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Materias</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.css" rel="stylesheet">
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
                    <h1 class="h2">Registro de Materias</h1>
                    <a href="index.php?page=<?php echo $id_carrera_pre || (isset($materia) && $materia['id_carrera']) ? 'carrera_flujograma&id=' . ($id_carrera_pre ?? $materia['id_carrera']) : 'carreras'; ?>" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <div class="row">
                    <div class="col-md-8 offset-md-2">
                        <div class="card">
                            <div class="card-body">
                                <form method="POST" action="">
                                    <div class="mb-3">
                                        <label for="codigo" class="form-label">Código de Materia <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="codigo" name="codigo" 
                                               value="<?php echo htmlspecialchars($materia['codigo'] ?? ''); ?>" required maxlength="30">
                                        <small class="text-muted">Código único de la materia (ej. MAT-101)</small>
                                    </div>

                                    <div class="mb-3">
                                        <label for="nombre" class="form-label">Nombre <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="nombre" name="nombre" 
                                               value="<?php echo htmlspecialchars($materia['nombre'] ?? ''); ?>" required maxlength="100">
                                    </div>

                                    <div class="mb-3">
                                        <label for="descripcion" class="form-label">Descripción</label>
                                        <textarea class="form-control" id="descripcion" name="descripcion" rows="4"><?php echo htmlspecialchars($materia['descripcion'] ?? ''); ?></textarea>
                                    </div>

                                    <div class="mb-3">
                                         <label for="creditos" class="form-label">Créditos <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="creditos" name="creditos" 
                                               value="<?php echo htmlspecialchars($materia['creditos'] ?? '3'); ?>" required min="1" max="10">
                                    </div>

                                    <div class="mb-3">
                                        <label for="periodo" class="form-label text-primary fw-bold"><i class="bi bi-calendar3"></i> Periodo/Semestre Sugerido <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control border-primary" id="periodo" name="periodo" 
                                               value="<?php echo htmlspecialchars($materia['periodo'] ?? '1'); ?>" required min="1" max="15">
                                        <small class="text-muted">Define el orden en el que aparecerá en el flujograma (ej. 1 para primer periodo, 2 para segundo)</small>
                                    </div>

                                    <div class="mb-3">
                                        <label for="tipo_materia" class="form-label">Tipo de Materia <span class="text-danger">*</span></label>
                                        <select class="form-select" id="tipo_materia" name="tipo_materia" required onchange="toggleFacultad()">
                                            <option value="institucional" <?php echo (isset($materia) && $materia['tipo_materia'] == 'institucional') ? 'selected' : ''; ?>>Institucional (Común para todas las carreras)</option>
                                            <option value="facultad" <?php echo (isset($materia) && $materia['tipo_materia'] == 'facultad') ? 'selected' : ''; ?>>Generales de Facultad (Ej: Matemáticas para ingenierías)</option>
                                            <option value="carrera" <?php echo (isset($materia) && $materia['tipo_materia'] == 'carrera') ? 'selected' : ''; ?>>Nata de Carrera (Exclusiva de la carrera)</option>
                                        </select>
                                    </div>

                                    <div class="mb-3" id="facultad_container" style="display: <?php echo (!isset($materia) || $materia['tipo_materia'] === 'institucional') ? 'none' : 'block'; ?>">
                                        <label for="id_facultad" class="form-label">Facultad Perteneciente <span class="text-danger">*</span></label>
                                        <select class="form-select" id="id_facultad" name="id_facultad">
                                            <option value="">-- Selecciona la facultad base --</option>
                                            <?php foreach ($facultades as $fac): ?>
                                                <option value="<?php echo $fac['id_facultad']; ?>"
                                                    <?php echo (isset($materia) && $materia['id_facultad'] == $fac['id_facultad']) ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($fac['nombre_facultad']); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>

                                    <div class="mb-3" id="carrera_container" style="display: <?php echo (isset($materia) && $materia['tipo_materia'] === 'carrera') || $id_carrera_pre ? 'block' : 'none'; ?>">
                                        <label for="id_carrera" class="form-label">Carrera Perteneciente <span class="text-danger">*</span></label>
                                        <select class="form-select" id="id_carrera" name="id_carrera">
                                            <option value="">-- Selecciona la carrera --</option>
                                            <?php foreach ($carreras as $car): ?>
                                                <option value="<?php echo $car['id_carrera']; ?>"
                                                    <?php 
                                                        $selected = '';
                                                        if (isset($materia) && $materia['id_carrera'] == $car['id_carrera']) $selected = 'selected';
                                                        elseif ($id_carrera_pre == $car['id_carrera']) $selected = 'selected';
                                                        echo $selected;
                                                    ?>>
                                                    <?php echo htmlspecialchars($car['nombre_carrera']); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>

                                    <div class="mb-3 border-top pt-3 mt-4">
                                        <label for="id_requisito" class="form-label text-warning fw-bold"><i class="bi bi-lock-fill"></i> Requisito Previo (Opcional)</label>
                                        <select class="form-select" id="id_requisito" name="id_requisito">
                                            <option value="">-- Ninguno (Materia base) --</option>
                                            <?php foreach ($todas_materias as $tm): 
                                                // Evitar que una materia se requiera a sí misma
                                                if (isset($materia) && $materia['id_materia'] == $tm['id_materia']) continue;
                                            ?>
                                                <option value="<?php echo $tm['id_materia']; ?>"
                                                    <?php echo (isset($materia) && $materia['id_requisito'] == $tm['id_materia']) ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($tm['codigo'] . ' - ' . $tm['nombre']); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                        <small class="text-muted">Si seleccionas una materia, el alumno no podrá cursar esta clase sin haber aprobado el requisito primero.</small>
                                    </div>

                                    <?php if ($esEdicion): ?>
                                        <div class="mb-3">
                                            <label for="estado" class="form-label">Estado</label>
                                            <select class="form-select" id="estado" name="estado">
                                                <option value="activa" <?php echo ($materia['estado'] === 'activa') ? 'selected' : ''; ?>>Activa</option>
                                                <option value="inactiva" <?php echo ($materia['estado'] === 'inactiva') ? 'selected' : ''; ?>>Inactiva</option>
                                            </select>
                                        </div>
                                    <?php endif; ?>

                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-check-circle"></i> 
                                            <?php echo $esEdicion ? 'Actualizar' : 'Registrar'; ?>
                                        </button>
                                        <a href="index.php?page=<?php echo $id_carrera_pre || (isset($materia) && $materia['id_carrera']) ? 'carrera_flujograma&id=' . ($id_carrera_pre ?? $materia['id_carrera']) : 'carreras'; ?>" class="btn btn-secondary px-4">
                                            Cancelar
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function toggleFacultad() {
            var tipo = document.getElementById('tipo_materia').value;
            var containerFacultad = document.getElementById('facultad_container');
            var selectFacultad = document.getElementById('id_facultad');
            var containerCarrera = document.getElementById('carrera_container');
            var selectCarrera = document.getElementById('id_carrera');
            
            if (tipo === 'institucional') {
                containerFacultad.style.display = 'none';
                selectFacultad.removeAttribute('required');
                selectFacultad.value = '';
                
                containerCarrera.style.display = 'none';
                selectCarrera.removeAttribute('required');
                selectCarrera.value = '';
            } else if (tipo === 'facultad') {
                containerFacultad.style.display = 'block';
                selectFacultad.setAttribute('required', 'required');
                
                containerCarrera.style.display = 'none';
                selectCarrera.removeAttribute('required');
                selectCarrera.value = '';
            } else if (tipo === 'carrera') {
                containerFacultad.style.display = 'block';
                selectFacultad.setAttribute('required', 'required');
                
                containerCarrera.style.display = 'block';
                selectCarrera.setAttribute('required', 'required');
            }
        }
        
        document.addEventListener("DOMContentLoaded", function() {
            toggleFacultad();
            
            new TomSelect("#id_requisito", {
                create: false,
                sortField: { field: "text", direction: "asc" }
            });
            
            <?php if (!empty($errorMsg)): ?>
            Swal.fire({
                icon: 'error',
                title: 'No se pudo guardar',
                text: <?php echo json_encode($errorMsg); ?>,
                confirmButtonColor: '#0d6efd'
            });
            <?php endif; ?>
            
            <?php if (!empty($successMsg)): ?>
            Swal.fire({
                icon: 'success',
                title: '¡Éxito!',
                text: <?php echo json_encode($successMsg); ?>,
                confirmButtonColor: '#198754',
                allowOutsideClick: false
            }).then(() => {
                window.location = '<?php echo $redirectUrl; ?>';
            });
            <?php endif; ?>
        });
    </script>
</body>
</html>
