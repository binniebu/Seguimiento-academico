<?php
require_once __DIR__ . "/../../../controllers/MatriculasController.php";

$matriculas = \Controllers\MatriculasController::listar();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Matrículas</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>

<body>

<div class="container-fluid">
    <div class="row">

        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <main class="col-md-10 px-md-4">

            <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Gestión de Matrículas</h1>

                <a href="index.php?page=matricula_nueva"
                   class="btn btn-primary">
                    <i class="bi bi-plus-circle"></i>
                    Nueva Matrícula
                </a>
            </div>

            <?php if(!empty($matriculas)): ?>

                <div class="table-responsive">

                    <table class="table table-hover">

                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Estudiante</th>
                                <th>Materia</th>
                                <th>Periodo</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>

                        <tbody>

                        <?php foreach($matriculas as $m): ?>

                            <tr>

                                <td><?= $m["id_matricula"] ?></td>
                                <td><?= htmlspecialchars($m["estudiante_nombre"]) ?></td>
                                <td><?= htmlspecialchars($m["materia_nombre"]) ?></td>
                                <td><?= htmlspecialchars($m["periodo"]) ?></td>

                                <td>
                                    <span class="badge bg-success">
                                        <?= htmlspecialchars($m["estado"]) ?>
                                    </span>
                                </td>

                                <td>

                                    <a href="index.php?page=matricula_nueva&id=<?= $m["id_matricula"] ?>"
                                       class="btn btn-sm btn-warning">
                                        <i class="bi bi-pencil"></i>
                                        Editar
                                    </a>

                                    <a href="index.php?page=matricula_eliminar&id=<?= $m["id_matricula"] ?>"
                                       class="btn btn-sm btn-danger"
                                       onclick="return confirm('¿Desea eliminar esta matrícula?');">
                                        <i class="bi bi-trash"></i>
                                        Eliminar
                                    </a>

                                </td>

                            </tr>

                        <?php endforeach; ?>

                        </tbody>

                    </table>

                </div>

            <?php else: ?>

                <div class="alert alert-info">
                    No hay matrículas registradas.
                </div>

            <?php endif; ?>

        </main>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>