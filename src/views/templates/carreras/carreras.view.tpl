<?php
require_once __DIR__ . "/../../../dao/CarreraDao.php";
require_once __DIR__ . "/../../../controllers/CarrerasController.php";
require_once __DIR__ . "/../../../controllers/FacultadesController.php";

$verInactivas = ($_GET['ver'] ?? '') === 'inactivas';

// 1. Ejecutar acciones de inactivación / activación si vienen por GET
if (($_GET['accion'] ?? '') === 'inactivar' && isset($_GET['id'])) {
    $resultado = \Controllers\CarrerasController::inactivar($_GET['id']);
    echo '<script>
        window.location = "index.php?page=carreras";
    </script>';
    exit();
}

if (($_GET['accion'] ?? '') === 'activar' && isset($_GET['id'])) {
    $resultado = \Controllers\CarrerasController::activar($_GET['id']);
    $redir = $verInactivas ? "index.php?page=carreras&ver=inactivas" : "index.php?page=carreras";
    echo '<script>
        window.location = "' . $redir . '";
    </script>';
    exit();
}

// 2. Obtener lista de carreras de la DB (Paginada a 4 por página)
$id_facultad = $_GET['id_facultad'] ?? null;
$p = intval($_GET['p'] ?? 1);
if ($p < 1) $p = 1;
$limit = 4;
$offset = ($p - 1) * $limit;

if ($_SESSION["rol"] === "coordinador" && isset($_SESSION["id_facultad"])) {
    $facultadFiltro = $_SESSION["id_facultad"];
} else {
    $facultadFiltro = $id_facultad;
}

$totalCarreras = \Dao\CarreraDao::obtenerTotalCarreras($verInactivas, $facultadFiltro);
$totalPages = ceil($totalCarreras / $limit);

$carreras = \Dao\CarreraDao::obtenerCarreras($verInactivas, $facultadFiltro, $limit, $offset);

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
    <title>Gestión de Carreras</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Barra Lateral de Navegación (Sidebar) -->
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <!-- Panel de Contenido Principal -->
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">
                            <?php echo $verInactivas ? 'Gestión de Carreras - Inactivas' : 'Gestión de Carreras'; ?>
                        </h1>
                    </div>
                    <div class="d-flex gap-2">
                        <?php if ($_SESSION["rol"] !== "coordinador"): ?>
                            <?php if ($verInactivas): ?>
                                <a href="index.php?page=carreras" class="btn btn-outline-primary">
                                    <i class="bi bi-tags-fill"></i> Ver Carreras Activas
                                </a>
                            <?php else: ?>
                                <a href="index.php?page=carreras&ver=inactivas" class="btn btn-outline-secondary">
                                    <i class="bi bi-eye-slash"></i> Ver Inactivas
                                </a>
                                 <button type="button" data-bs-toggle="modal" data-bs-target="#modalCarrera" class="btn btn-primary">
                                     <i class="bi bi-plus-circle"></i> Nueva Carrera
                                 </button>
                            <?php endif; ?>
                        <?php endif; ?>
                    </div>
                </div>

                <!-- Tabla de Carreras -->
                <?php if (!empty($carreras)): ?>
                    <!-- Buscador -->
                    <div class="row mb-3">
                        <div class="col-md-5">
                            <div class="input-group shadow-sm">
                                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" id="buscadorCarreras" class="form-control border-start-0" placeholder="Buscar carrera por nombre...">
                            </div>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Nombre de la Carrera</th>
                                    <th class="text-center">Total Materias</th>
                                    <th>Estado</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($carreras as $c): 
                                    $nombreFixed = fixDoubleEncoding($c['nombre_carrera']);
                                    $totalMaterias = intval($c['total_materias'] ?? 0);
                                    
                                    // Regla de Negocio: Si tiene 0 materias y está activa, estado es "Pendiente de carga académica"
                                    $estadoLower = strtolower($c['estado'] ?? '');
                                    $estadoLabel = ucfirst($c['estado'] ?? '');
                                    $badgeClass = 'bg-secondary';
                                    
                                    if ($estadoLower === 'activa') {
                                        if ($totalMaterias === 0) {
                                            $estadoLabel = 'Pendiente de carga académica';
                                            $badgeClass = 'bg-warning text-dark';
                                        } else {
                                            $estadoLabel = 'Activa';
                                            $badgeClass = 'bg-success';
                                        }
                                    } elseif ($estadoLower === 'inactiva') {
                                        $estadoLabel = 'Inactiva';
                                        $badgeClass = 'bg-danger';
                                    }
                                ?>
                                    <tr>
                                        <td class="fw-bold">
                                            <a href="index.php?page=carrera_flujograma&id=<?php echo $c['id_carrera']; ?>" class="text-decoration-none text-primary">
                                                <?php echo htmlspecialchars($nombreFixed); ?> <i class="bi bi-box-arrow-up-right ms-1 small"></i>
                                            </a>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-light text-dark border fw-bold" style="font-size: 13px;">
                                                <?php echo $totalMaterias; ?>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge <?php echo $badgeClass; ?>">
                                                <?php echo htmlspecialchars($estadoLabel); ?>
                                            </span>
                                        </td>
                                        <td class="actions-cell text-end">
                                            <div class="d-flex gap-2 justify-content-end">
                                                <?php if ($_SESSION["rol"] === "coordinador"): ?>
                                                    <span class="text-muted small"><i class="bi bi-info-circle"></i> Solo consulta</span>
                                                <?php else: ?>
                                                     <?php if ($estadoLower === 'inactiva'): ?>
                                                         <a href="index.php?page=carreras&ver=inactivas&accion=activar&id=<?php echo $c['id_carrera']; ?>"
                                                            class="btn btn-sm btn-success"
                                                            data-confirmar="¿Estás seguro de que deseas reactivar esta carrera?"
                                                            data-titulo="Reactivar Carrera"
                                                            data-confirm-text="Sí, reactivar"
                                                            data-icono="question">
                                                             <i class="bi bi-check-circle"></i> Activar
                                                         </a>
                                                     <?php else: ?>
                                                         <button type="button"
                                                            class="btn btn-sm btn-warning btn-editar-carrera"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#modalCarrera"
                                                            data-id="<?php echo $c['id_carrera']; ?>"
                                                            data-nombre="<?php echo htmlspecialchars($nombreFixed); ?>"
                                                            data-facultad="<?php echo $c['id_facultad']; ?>"
                                                            data-estado="<?php echo htmlspecialchars($c['estado']); ?>">
                                                             <i class="bi bi-pencil"></i> Editar
                                                         </button>
                                                         <a href="index.php?page=carreras&accion=inactivar&id=<?php echo $c['id_carrera']; ?>"
                                                            class="btn btn-sm btn-danger"
                                                            data-confirmar="¿Estás seguro de que deseas dar de baja esta carrera?"
                                                            data-titulo="Dar de baja Carrera"
                                                            data-confirm-text="Sí, dar de baja"
                                                            data-icono="warning">
                                                             <i class="bi bi-trash"></i> Dar de baja
                                                         </a>
                                                     <?php endif; ?>
                                                <?php endif; ?>
                                            </div>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>

                    <!-- Control de Paginación -->
                    <?php if ($totalPages > 1): ?>
                        <nav class="mt-4" aria-label="Navegación de páginas">
                            <ul class="pagination justify-content-center">
                                <!-- Anterior -->
                                <li class="page-item <?php echo $p <= 1 ? 'disabled' : ''; ?>">
                                    <a class="page-link" href="index.php?page=carreras<?php 
                                        echo ($verInactivas ? '&ver=inactivas' : '') . 
                                             ($id_facultad !== null ? '&id_facultad=' . urlencode($id_facultad) : '') . 
                                             '&p=' . ($p - 1); 
                                     ?>" aria-label="Anterior">
                                         <span aria-hidden="true">&laquo; Anterior</span>
                                    </a>
                                </li>

                                <!-- Páginas -->
                                <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                                    <li class="page-item <?php echo $p === $i ? 'active' : ''; ?>">
                                        <a class="page-link" href="index.php?page=carreras<?php 
                                            echo ($verInactivas ? '&ver=inactivas' : '') . 
                                                 ($id_facultad !== null ? '&id_facultad=' . urlencode($id_facultad) : '') . 
                                                 '&p=' . $i; 
                                        ?>">
                                            <?php echo $i; ?>
                                        </a>
                                    </li>
                                <?php endfor; ?>

                                <!-- Siguiente -->
                                <li class="page-item <?php echo $p >= $totalPages ? 'disabled' : ''; ?>">
                                    <a class="page-link" href="index.php?page=carreras<?php 
                                        echo ($verInactivas ? '&ver=inactivas' : '') . 
                                             ($id_facultad !== null ? '&id_facultad=' . urlencode($id_facultad) : '') . 
                                             '&p=' . ($p + 1); 
                                     ?>" aria-label="Siguiente">
                                         <span aria-hidden="true">Siguiente &raquo;</span>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    <?php endif; ?>
                <?php else: ?>
                    <div class="alert alert-info">
                        <?php if ($verInactivas): ?>
                            No hay carreras inactivas registradas.
                        <?php else: ?>
                            No hay carreras activas registradas. <a href="index.php?page=carrera_nueva" class="alert-link">Registrar una nueva</a>
                        <?php endif; ?>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<!-- Modal de Carrera -->
<div class="modal fade" id="modalCarrera" tabindex="-1" aria-labelledby="modalCarreraLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg border-0">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold" id="modalCarreraLabel"><i class="bi bi-tags-fill me-2"></i>Nueva Carrera</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST" action="index.php?page=carrera_guardar">
                <div class="modal-body p-4">
                    <input type="hidden" name="id_carrera" id="modal_id_carrera" value="">
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold text-secondary">Nombre de la Carrera</label>
                        <input type="text" name="nombre_carrera" id="modal_nombre_carrera" class="form-control shadow-sm" placeholder="Ej: Ingeniería en Sistemas" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold text-secondary">Facultad Perteneciente <span class="text-danger">*</span></label>
                        <select name="id_facultad" id="modal_id_facultad" class="form-select shadow-sm" required>
                            <option value="">-- Selecciona una facultad --</option>
                            <?php
                            $facultades = \Controllers\FacultadesController::listar();
                            foreach ($facultades as $fac): ?>
                                <option value="<?php echo $fac['id_facultad']; ?>">
                                    <?php echo htmlspecialchars($fac['nombre_facultad']); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div class="mb-3 d-none" id="modal_estado_container">
                        <label class="form-label fw-bold text-secondary">Estado</label>
                        <select name="estado" id="modal_estado" class="form-select shadow-sm">
                            <option value="activa">Activa</option>
                            <option value="inactiva">Inactiva</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer bg-light border-top p-3">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-success px-4"><i class="bi bi-save me-1"></i>Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalEl = document.getElementById('modalCarrera');
if (modalEl) {
    modalEl.addEventListener('show.bs.modal', function(event) {
        const button = event.relatedTarget;
        if (!button) return;
        
        const isEdit = button.classList.contains('btn-editar-carrera');
        if (isEdit) {
            const id = button.getAttribute('data-id');
            const nombre = button.getAttribute('data-nombre');
            const idFacultad = button.getAttribute('data-facultad');
            const estado = button.getAttribute('data-estado');
            
            document.getElementById('modalCarreraLabel').innerHTML = '<i class="bi bi-pencil-fill me-2"></i>Editar Carrera';
            document.getElementById('modal_id_carrera').value = id || '';
            document.getElementById('modal_nombre_carrera').value = nombre || '';
            document.getElementById('modal_id_facultad').value = idFacultad || '';
            document.getElementById('modal_estado_container').classList.remove('d-none');
            document.getElementById('modal_estado').value = estado || 'activa';
        } else {
            document.getElementById('modalCarreraLabel').innerHTML = '<i class="bi bi-tags-fill me-2"></i>Registrar Nueva Carrera';
            document.getElementById('modal_id_carrera').value = '';
            document.getElementById('modal_nombre_carrera').value = '';
            document.getElementById('modal_id_facultad').value = '';
            document.getElementById('modal_estado_container').classList.add('d-none');
            document.getElementById('modal_estado').value = 'activa';
        }
    });
}

document.getElementById('buscadorCarreras')?.addEventListener('keyup', function() {
    const term = this.value.toLowerCase();
    const rows = document.querySelectorAll('tbody tr');
    
    rows.forEach(row => {
        const tdNombre = row.querySelector('td:first-child');
        if (tdNombre) {
            const nombre = tdNombre.textContent.toLowerCase();
            if (nombre.includes(term)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    });
});

// Mostrar alerta SweetAlert2 si existen parámetros de redirección en la URL
<?php
$msg = $_GET['msg'] ?? '';
$tipo_msg = $_GET['tipo_msg'] ?? '';
if ($msg && $tipo_msg):
?>
Swal.fire({
    title: <?php echo json_encode($tipo_msg === "success" ? "¡Éxito!" : "Atención"); ?>,
    text: <?php echo json_encode($msg); ?>,
    icon: '<?php echo htmlspecialchars($tipo_msg); ?>',
    confirmButtonColor: '#0057d8',
    confirmButtonText: 'Aceptar',
    customClass: {
        popup: 'rounded-4 shadow',
        confirmButton: 'px-4 py-2 font-weight-bold'
    }
});
<?php endif; ?>
</script>
</body>
</html>
