<?php
require_once __DIR__ . "/../../../dao/CarreraDao.php";
require_once __DIR__ . "/../../../controllers/CarrerasController.php";

$verInactivas = ($_GET['ver'] ?? '') === 'inactivas';

// 1. Ejecutar acciones de inactivación / activación si vienen por GET
if (($_GET['accion'] ?? '') === 'inactivar' && isset($_GET['id'])) {
    $resultado = \Controllers\CarrerasController::inactivar($_GET['id']);
    echo '<script>
        alert("' . htmlspecialchars($resultado['mensaje']) . '");
        window.location = "index.php?page=carreras";
    </script>';
    exit();
}

if (($_GET['accion'] ?? '') === 'activar' && isset($_GET['id'])) {
    $resultado = \Controllers\CarrerasController::activar($_GET['id']);
    $redir = $verInactivas ? "index.php?page=carreras&ver=inactivas" : "index.php?page=carreras";
    echo '<script>
        alert("' . htmlspecialchars($resultado['mensaje']) . '");
        window.location = "' . $redir . '";
    </script>';
    exit();
}

// 2. Obtener lista de carreras de la DB
$id_facultad = $_GET['id_facultad'] ?? null;
if ($_SESSION["rol"] === "coordinador" && isset($_SESSION["id_facultad"])) {
    $carreras = \Dao\CarreraDao::obtenerCarreras($verInactivas, $_SESSION["id_facultad"]);
} else {
    $carreras = \Dao\CarreraDao::obtenerCarreras($verInactivas, $id_facultad);
}

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
                                <a href="index.php?page=carrera_nueva" class="btn btn-primary">
                                    <i class="bi bi-plus-circle"></i> Nueva Carrera
                                </a>
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
                                                           onclick="return confirm('¿Estás seguro de que deseas reactivar esta carrera?');">
                                                            <i class="bi bi-check-circle"></i> Activar
                                                        </a>
                                                    <?php else: ?>
                                                        <a href="index.php?page=carrera_nueva&id=<?php echo $c['id_carrera']; ?>"
                                                           class="btn btn-sm btn-warning">
                                                            <i class="bi bi-pencil"></i> Editar
                                                        </a>
                                                        <a href="index.php?page=carreras&accion=inactivar&id=<?php echo $c['id_carrera']; ?>"
                                                           class="btn btn-sm btn-danger"
                                                           onclick="return confirm('¿Estás seguro de que deseas dar de baja esta carrera?');">
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.querySelectorAll('.toggleSidebarBtn').forEach(btn => {
    btn.addEventListener('click', function() {
        const sidebar = document.querySelector('.sidebar');
        const main = document.querySelector('main');
        if (sidebar.classList.contains('collapsed')) {
            sidebar.classList.remove('collapsed');
            main.classList.replace('col-md-12', 'col-md-10');
        } else {
            sidebar.classList.add('collapsed');
            main.classList.replace('col-md-10', 'col-md-12');
        }
    });
});

document.getElementById('buscadorCarreras')?.addEventListener('keyup', function() {
    const term = this.value.toLowerCase();
    const rows = document.querySelectorAll('tbody tr');
    
    rows.forEach(row => {
        const tdNombre = row.querySelector('td:nth-child(2)');
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
</script>
</body>
</html>
