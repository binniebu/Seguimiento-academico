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

<div class="d-flex justify-content-between align-items-center mt-4 mb-4">

    <h2>Gestión de Personal</h2>

    <a href="index.php?page=maestro_nuevo" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i>
        Nuevo Personal
    </a>

</div>

<form method="GET" action="index.php" class="row mb-4">

    <input type="hidden" name="page" value="maestros">

    <div class="col-md-10">
        <input
            type="text"
            class="form-control"
            name="buscar"
            placeholder="Buscar por nombre, correo o DNI"
            value="<?= htmlspecialchars($_GET["buscar"] ?? "") ?>">
    </div>

    <div class="col-md-2">
        <button class="btn btn-success w-100">
            <i class="bi bi-search"></i> Buscar
        </button>
    </div>

</form>

<?php

require_once __DIR__ . "/../../../controllers/MaestrosController.php";

$buscar = $_GET["buscar"] ?? "";

if ($buscar != "") {
    $maestros = \Controllers\MaestrosController::buscarMaestros($buscar);
    $coordinadores = \Controllers\MaestrosController::buscarCoordinadores($buscar);
} else {
    $maestros = \Controllers\MaestrosController::listarMaestros();
    $coordinadores = \Controllers\MaestrosController::listarCoordinadores();
}

?>

<ul class="nav nav-tabs">

    <li class="nav-item">
        <button class="nav-link active"
                data-bs-toggle="tab"
                data-bs-target="#tabMaestros">
            Ver Maestros
        </button>
    </li>

    <li class="nav-item">
        <button class="nav-link"
                data-bs-toggle="tab"
                data-bs-target="#tabCoordinadores">
            Ver Coordinadores
        </button>
    </li>

</ul>

<div class="tab-content mt-4">

<!-- ====================== MAESTROS ===================== -->

<div class="tab-pane fade show active" id="tabMaestros">

<div class="table-responsive">

<table class="table table-striped table-hover table-bordered align-middle">

<thead class="table-primary">

<tr>

<th>No. Empleado</th>
<th>Nombre</th>
<th>Correo</th>
<th>Teléfono</th>
<th>Título</th>
<th>Acciones</th>

</tr>

</thead>

<tbody>

<?php if (count($maestros) > 0): ?>

<?php foreach ($maestros as $m): ?>

<tr>

<td><?= htmlspecialchars($m["numero_empleado"]) ?></td>

<td><?= htmlspecialchars($m["nombre"]) ?></td>

<td><?= htmlspecialchars($m["correo"]) ?></td>

<td><?= htmlspecialchars($m["telefono"] ?? 'N/D') ?></td>

<td><?= htmlspecialchars($m["titulo"] ?? 'N/D') ?></td>

<td width="160">

<a href="index.php?page=maestro_nuevo&id=<?= $m["id_maestro"] ?>"
class="btn btn-warning btn-sm">

<i class="bi bi-pencil"></i>

</a>

<a href="index.php?page=maestros&accion=eliminar&id=<?= $m["id_maestro"] ?>"
class="btn btn-danger btn-sm"
onclick="return confirm('¿Desea eliminar este maestro?')">

<i class="bi bi-trash"></i>

</a>

</td>

</tr>

<?php endforeach; ?>

<?php else: ?>

<tr>

<td colspan="6" class="text-center">

No hay maestros registrados.

</td>

</tr>

<?php endif; ?>

</tbody>

</table>

</div>

</div>

<!-- ====================== COORDINADORES ===================== -->

<div class="tab-pane fade" id="tabCoordinadores">

<div class="table-responsive">

<table class="table table-striped table-hover table-bordered align-middle">
    <thead class="table-primary">
        <tr>
            <th>Nombre</th>
            <th>Correo</th>
            <th>Facultad</th>
            <th>Título</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if (count($coordinadores) > 0): ?>
            <?php foreach ($coordinadores as $c): ?>
            <tr>
                <td><?= htmlspecialchars($c["nombre"]) ?></td>
                <td><?= htmlspecialchars($c["correo"]) ?></td>
                <td><?= htmlspecialchars($c["nombre_facultad"]) ?></td>
                <td><?= htmlspecialchars($c["titulo"] ?? 'N/D') ?></td>
                <td><?= htmlspecialchars($c["estado"] ?? 'N/D') ?></td>
                <td width="160">
                    <a href="index.php?page=maestro_nuevo&id_coordinador=<?= $c["id_coordinador"] ?>" class="btn btn-warning btn-sm">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <a href="index.php?page=maestros&accion=eliminar_coordinador&id=<?= $c["id_coordinador"] ?>" class="btn btn-danger btn-sm" onclick="return confirm('¿Desea eliminar?')">
                        <i class="bi bi-trash"></i>
                    </a>
                </td>
            </tr>
            <?php endforeach; ?>
        <?php else: ?>
            <tr><td colspan="6" class="text-center">No hay coordinadores registrados.</td></tr>
        <?php endif; ?>
    </tbody>
</table>

</div>

</div>

</div>

</main>

</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>

</html>