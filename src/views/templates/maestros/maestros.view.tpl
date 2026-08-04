<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Personal</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
     <link rel="stylesheet" href="public/css/style.css">
</head>

<body>

<div class="container-fluid">
<div class="row">

<?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

<main class="col-md-10 ms-sm-auto px-md-4">

<div class="d-flex justify-content-between align-items-center mt-4 mb-4 pb-3 border-bottom">
    <div class="d-flex align-items-center gap-3">
        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
            <i class="bi bi-list"></i>
        </button>
        <h2 class="mb-0">Gestión de Personal</h2>
    </div>

    <a href="index.php?page=maestro_nuevo" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i>
        Nuevo Personal
    </a>

</div>

<form method="GET" action="index.php" class="row g-3 mb-4 align-items-center">

    <input type="hidden" name="page" value="maestros">
    <input type="hidden" name="tab" id="active_tab_input" value="<?= htmlspecialchars($_GET['tab'] ?? 'maestros') ?>">

    <div class="col-md-4">
        <input
            type="text"
            class="form-control shadow-sm"
            name="buscar"
            placeholder="Buscar por nombre, correo o DNI"
            value="<?= htmlspecialchars($_GET["buscar"] ?? "") ?>">
    </div>

    <div class="col-md-3">
        <select name="id_campus" class="form-select shadow-sm" onchange="this.form.submit()">
            <?php 
            require_once __DIR__ . "/../../../controllers/CampusController.php";
            $campusFiltro = $_GET["id_campus"] ?? "";
            $campusesList = \Controllers\CampusController::listar();
            ?>
            <option value="" <?= $campusFiltro === "" ? "selected" : "" ?>>Todos los campus</option>
            <?php foreach ($campusesList as $cList): ?>
                <option value="<?= $cList['id_campus'] ?>" <?= strval($campusFiltro) === strval($cList['id_campus']) ? "selected" : "" ?>>
                    <?= htmlspecialchars($cList['nombre_campus']) ?>
                </option>
            <?php endforeach; ?>
        </select>
    </div>

    <div class="col-md-3">
        <select name="estado" class="form-select shadow-sm" onchange="this.form.submit()">
            <?php $estadoFiltro = $_GET["estado"] ?? "todos"; ?>
            <option value="todos" <?= $estadoFiltro === "todos" ? "selected" : "" ?>>Todos los estados</option>
            <option value="activo" <?= $estadoFiltro === "activo" ? "selected" : "" ?>>Activos</option>
            <option value="inactivo" <?= $estadoFiltro === "inactivo" ? "selected" : "" ?>>Inactivos</option>
        </select>
    </div>

    <div class="col-md-2 d-flex gap-2">
        <button type="submit" class="btn btn-success w-100 shadow-sm">
            <i class="bi bi-search"></i>
        </button>
        <?php if (!empty($_GET['buscar']) || ($_GET['estado'] ?? 'todos') !== 'todos' || !empty($_GET['id_campus'])): ?>
            <a href="index.php?page=maestros" class="btn btn-outline-danger shadow-sm" title="Limpiar Filtros">
                <i class="bi bi-x-circle"></i>
            </a>
        <?php endif; ?>
    </div>

</form>

<?php

require_once __DIR__ . "/../../../controllers/MaestrosController.php";
require_once __DIR__ . "/../../../dao/MaestroDao.php";

$buscar = $_GET["buscar"] ?? "";
$estadoFiltro = $_GET["estado"] ?? "todos";
$idCampusFiltro = $_GET["id_campus"] ?? "";

$p_maestros = intval($_GET['p_maestros'] ?? 1);
if ($p_maestros < 1) $p_maestros = 1;

$p_coordinadores = intval($_GET['p_coordinadores'] ?? 1);
if ($p_coordinadores < 1) $p_coordinadores = 1;

$limit = 4;
$offset_maestros = ($p_maestros - 1) * $limit;
$offset_coordinadores = ($p_coordinadores - 1) * $limit;

$totalMaestros = \Dao\MaestroDao::obtenerTotalMaestros($buscar, $estadoFiltro, $idCampusFiltro);
$totalPagesMaestros = ceil($totalMaestros / $limit);

$totalCoordinadores = \Dao\MaestroDao::obtenerTotalCoordinadores($buscar, $estadoFiltro, $idCampusFiltro);
$totalPagesCoordinadores = ceil($totalCoordinadores / $limit);

if ($buscar != "") {
    $maestros = \Controllers\MaestrosController::buscarMaestros($buscar, $estadoFiltro, $idCampusFiltro, $limit, $offset_maestros);
    $coordinadores = \Controllers\MaestrosController::buscarCoordinadores($buscar, $estadoFiltro, $idCampusFiltro, $limit, $offset_coordinadores);
} else {
    $maestros = \Controllers\MaestrosController::listarMaestros($estadoFiltro, $idCampusFiltro, $limit, $offset_maestros);
    $coordinadores = \Controllers\MaestrosController::listarCoordinadores($estadoFiltro, $idCampusFiltro, $limit, $offset_coordinadores);
}

?>

<?php $activeTab = $_GET['tab'] ?? 'maestros'; ?>
<ul class="nav nav-tabs">

    <li class="nav-item">
        <button class="nav-link <?= $activeTab === 'maestros' ? 'active' : '' ?>"
                data-bs-toggle="tab"
                data-bs-target="#tabMaestros">
            Ver Maestros
        </button>
    </li>

    <li class="nav-item">
        <button class="nav-link <?= $activeTab === 'coordinadores' ? 'active' : '' ?>"
                data-bs-toggle="tab"
                data-bs-target="#tabCoordinadores">
            Ver Coordinadores
        </button>
    </li>

</ul>

<div class="tab-content mt-4">

<!-- ====================== MAESTROS ===================== -->
<div class="tab-pane fade <?= $activeTab === 'maestros' ? 'show active' : '' ?>" id="tabMaestros">

<div class="table-responsive">

<table class="table table-hover align-middle">

<thead class="table-light">

<tr>

<th>DNI</th>
<th>Nombre</th>
<th>Correo</th>
<th>Campus / Sede</th>
<th>Teléfono</th>
<th>Título</th>
<th>Estado</th>
<th>Acciones</th>

</tr>

</thead>

<tbody>

<?php if (count($maestros) > 0): ?>

<?php foreach ($maestros as $m): ?>

<tr>

<td><?= htmlspecialchars($m["dni"] ?? 'N/D') ?></td>

<td class="fw-semibold text-dark"><?= htmlspecialchars($m["nombre"]) ?></td>

<td><?= htmlspecialchars($m["correo"]) ?></td>

<td><span class="badge bg-light text-secondary border"><?= htmlspecialchars($m["campus"] ?? 'Sin asignar') ?></span></td>

<td><?= htmlspecialchars($m["telefono"] ?? 'N/D') ?></td>

<td><span class="badge bg-light text-primary border"><?= htmlspecialchars($m["titulo"] ?? 'N/D') ?></span></td>

<td>
    <?php
    $estadoLower = strtolower($m['estado'] ?? '');
    $badgeClass = 'bg-secondary';
    if ($estadoLower === 'activo') {
        $badgeClass = 'bg-success';
    } elseif ($estadoLower === 'inactivo') {
        $badgeClass = 'bg-danger';
    }
    ?>
    <span class="badge <?= $badgeClass ?>">
        <?= ucfirst(htmlspecialchars($m['estado'] ?? '')) ?>
    </span>
</td>

<td>

<a href="index.php?page=maestro_nuevo&id=<?= $m["id_maestro"] ?>"
class="btn btn-warning btn-sm" title="Editar">
    <i class="bi bi-pencil"></i>
</a>

<?php if (($m["estado"] ?? '') === 'inactivo'): ?>
<a href="index.php?page=maestros&accion=activar&id=<?= $m["id_maestro"] ?>"
class="btn btn-success btn-sm"
data-confirmar="¿Desea activar a este miembro del personal docente?"
data-titulo="Activar Personal"
data-confirm-text="Sí, activar"
data-icono="question" title="Activar">
    <i class="bi bi-person-check"></i>
</a>
<?php else: ?>
<a href="index.php?page=maestros&accion=inactivar&id=<?= $m["id_maestro"] ?>"
class="btn btn-danger btn-sm"
data-confirmar="¿Desea inactivar a este miembro del personal docente? Perderá acceso a sus secciones activas."
data-titulo="Inactivar Personal"
data-confirm-text="Sí, inactivar"
data-icono="warning" title="Inactivar">
    <i class="bi bi-person-slash"></i>
</a>
<?php endif; ?>

</td>

</tr>

<?php endforeach; ?>

<?php else: ?>

<tr>

<td colspan="8" class="text-center py-4">
    <i class="bi bi-people fs-2 text-muted"></i>
    <p class="text-muted mb-0 mt-2">No hay maestros registrados.</p>
</td>

</tr>

<?php endif; ?>

</tbody>

</table>

</div>

        <!-- Control de Paginación Maestros -->
        <?php if ($totalPagesMaestros > 1): ?>
            <nav class="mt-4" aria-label="Navegación de páginas maestros">
                <ul class="pagination justify-content-center">
                    <!-- Anterior -->
                    <li class="page-item <?php echo $p_maestros <= 1 ? 'disabled' : ''; ?>">
                        <a class="page-link" href="index.php?page=maestros<?php 
                            echo ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                 (($estadoFiltro !== 'todos') ? '&estado=' . urlencode($estadoFiltro) : '') . 
                                 ($idCampusFiltro !== '' ? '&id_campus=' . urlencode($idCampusFiltro) : '') . 
                                 '&tab=maestros' .
                                 '&p_coordinadores=' . $p_coordinadores .
                                 '&p_maestros=' . ($p_maestros - 1); 
                         ?>" aria-label="Anterior">
                             <span aria-hidden="true">&laquo; Anterior</span>
                        </a>
                    </li>

                    <!-- Páginas -->
                    <?php for ($i = 1; $i <= $totalPagesMaestros; $i++): ?>
                        <li class="page-item <?php echo $p_maestros === $i ? 'active' : ''; ?>">
                            <a class="page-link" href="index.php?page=maestros<?php 
                                echo ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                     (($estadoFiltro !== 'todos') ? '&estado=' . urlencode($estadoFiltro) : '') . 
                                     ($idCampusFiltro !== '' ? '&id_campus=' . urlencode($idCampusFiltro) : '') . 
                                     '&tab=maestros' .
                                     '&p_coordinadores=' . $p_coordinadores .
                                     '&p_maestros=' . $i; 
                            ?>">
                                <?php echo $i; ?>
                            </a>
                        </li>
                    <?php endfor; ?>

                    <!-- Siguiente -->
                    <li class="page-item <?php echo $p_maestros >= $totalPagesMaestros ? 'disabled' : ''; ?>">
                        <a class="page-link" href="index.php?page=maestros<?php 
                            echo ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                 (($estadoFiltro !== 'todos') ? '&estado=' . urlencode($estadoFiltro) : '') . 
                                 ($idCampusFiltro !== '' ? '&id_campus=' . urlencode($idCampusFiltro) : '') . 
                                 '&tab=maestros' .
                                 '&p_coordinadores=' . $p_coordinadores .
                                 '&p_maestros=' . ($p_maestros + 1); 
                         ?>" aria-label="Siguiente">
                             <span aria-hidden="true">Siguiente &raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
        <?php endif; ?>

</div>

<!-- ====================== COORDINADORES ===================== -->

<div class="tab-pane fade <?= $activeTab === 'coordinadores' ? 'show active' : '' ?>" id="tabCoordinadores">

<div class="table-responsive">

<table class="table table-hover align-middle">
    <thead class="table-light">
        <tr>
            <th>DNI</th>
            <th>Nombre</th>
            <th>Correo</th>
            <th>Facultad</th>
            <th>Campus / Sede</th>
            <th>Título</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if (count($coordinadores) > 0): ?>
            <?php foreach ($coordinadores as $c): ?>
            <tr>
                <td><?= htmlspecialchars($c["dni"] ?? 'N/D') ?></td>
                <td class="fw-semibold text-dark"><?= htmlspecialchars($c["nombre"]) ?></td>
                <td><?= htmlspecialchars($c["correo"]) ?></td>
                <td><span class="badge bg-light text-primary border"><?= htmlspecialchars($c["nombre_facultad"]) ?></span></td>
                <td><span class="badge bg-light text-secondary border"><?= htmlspecialchars($c["campus"] ?? 'Sin asignar') ?></span></td>
                <td><span class="badge bg-light text-dark border"><?= htmlspecialchars($c["titulo"] ?? 'N/D') ?></span></td>
                <td>
                    <?php
                    $estadoLower = strtolower($c['estado'] ?? '');
                    $badgeClass = 'bg-secondary';
                    if ($estadoLower === 'activo') {
                        $badgeClass = 'bg-success';
                    } elseif ($estadoLower === 'inactivo') {
                        $badgeClass = 'bg-danger';
                    }
                    ?>
                    <span class="badge <?= $badgeClass ?>">
                        <?= ucfirst(htmlspecialchars($c['estado'] ?? '')) ?>
                    </span>
                </td>
                <td>
                    <a href="index.php?page=maestro_nuevo&id_coordinador=<?= $c["id_coordinador"] ?>" class="btn btn-warning btn-sm" title="Editar">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <?php if (($c["estado"] ?? '') === 'inactivo'): ?>
                        <a href="index.php?page=maestros&accion=activar_coordinador&id=<?= $c["id_coordinador"] ?>" class="btn btn-success btn-sm" 
                           data-confirmar="¿Desea activar la cuenta de este coordinador de facultad?" 
                           data-titulo="Activar Coordinador" 
                           data-confirm-text="Sí, activar" 
                           data-icono="question" title="Activar">
                            <i class="bi bi-person-check"></i>
                        </a>
                    <?php else: ?>
                        <a href="index.php?page=maestros&accion=inactivar_coordinador&id=<?= $c["id_coordinador"] ?>" class="btn btn-danger btn-sm" 
                           data-confirmar="¿Desea inactivar la cuenta de este coordinador de facultad?" 
                           data-titulo="Inactivar Coordinador" 
                           data-confirm-text="Sí, inactivar" 
                           data-icono="warning" title="Inactivar">
                            <i class="bi bi-person-slash"></i>
                        </a>
                    <?php endif; ?>
                </td>
            </tr>
            <?php endforeach; ?>
        <?php else: ?>
            <tr>
                <td colspan="8" class="text-center py-4">
                    <i class="bi bi-people fs-2 text-muted"></i>
                    <p class="text-muted mb-0 mt-2">No hay coordinadores registrados.</p>
                </td>
            </tr>
        <?php endif; ?>
    </tbody>
</table>

</div>

        <!-- Control de Paginación Coordinadores -->
        <?php if ($totalPagesCoordinadores > 1): ?>
            <nav class="mt-4" aria-label="Navegación de páginas coordinadores">
                <ul class="pagination justify-content-center">
                    <!-- Anterior -->
                    <li class="page-item <?php echo $p_coordinadores <= 1 ? 'disabled' : ''; ?>">
                        <a class="page-link" href="index.php?page=maestros<?php 
                            echo ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                 (($estadoFiltro !== 'todos') ? '&estado=' . urlencode($estadoFiltro) : '') . 
                                 ($idCampusFiltro !== '' ? '&id_campus=' . urlencode($idCampusFiltro) : '') . 
                                 '&tab=coordinadores' .
                                 '&p_maestros=' . $p_maestros .
                                 '&p_coordinadores=' . ($p_coordinadores - 1); 
                         ?>" aria-label="Anterior">
                             <span aria-hidden="true">&laquo; Anterior</span>
                        </a>
                    </li>

                    <!-- Páginas -->
                    <?php for ($i = 1; $i <= $totalPagesCoordinadores; $i++): ?>
                        <li class="page-item <?php echo $p_coordinadores === $i ? 'active' : ''; ?>">
                            <a class="page-link" href="index.php?page=maestros<?php 
                                echo ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                     (($estadoFiltro !== 'todos') ? '&estado=' . urlencode($estadoFiltro) : '') . 
                                     ($idCampusFiltro !== '' ? '&id_campus=' . urlencode($idCampusFiltro) : '') . 
                                     '&tab=coordinadores' .
                                     '&p_maestros=' . $p_maestros .
                                     '&p_coordinadores=' . $i; 
                            ?>">
                                <?php echo $i; ?>
                            </a>
                        </li>
                    <?php endfor; ?>

                    <!-- Siguiente -->
                    <li class="page-item <?php echo $p_coordinadores >= $totalPagesCoordinadores ? 'disabled' : ''; ?>">
                        <a class="page-link" href="index.php?page=maestros<?php 
                            echo ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                 (($estadoFiltro !== 'todos') ? '&estado=' . urlencode($estadoFiltro) : '') . 
                                 ($idCampusFiltro !== '' ? '&id_campus=' . urlencode($idCampusFiltro) : '') . 
                                 '&tab=coordinadores' .
                                 '&p_maestros=' . $p_maestros .
                                 '&p_coordinadores=' . ($p_coordinadores + 1); 
                         ?>" aria-label="Siguiente">
                             <span aria-hidden="true">Siguiente &raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
        <?php endif; ?>

</div>

</div>

</main>

</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    const activeTabInput = document.getElementById('active_tab_input');
    const tabElList = document.querySelectorAll('button[data-bs-toggle="tab"]');
    
    tabElList.forEach(tabEl => {
        tabEl.addEventListener('shown.bs.tab', function (event) {
            const targetId = event.target.getAttribute('data-bs-target');
            const tabName = targetId === '#tabCoordinadores' ? 'coordinadores' : 'maestros';
            if (activeTabInput) activeTabInput.value = tabName;
            
            // Actualizar el parámetro en la URL sin recargar la página
            const newUrl = new URL(window.location.href);
            newUrl.searchParams.set('tab', tabName);
            window.history.replaceState({}, '', newUrl);
        });
    });
});
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
</body>

</html>