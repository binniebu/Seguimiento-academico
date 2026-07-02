<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Maestros</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">

        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <main role="main" class="col-md-10 ml-sm-auto px-md-4">
            <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Gestión de Maestros</h1>
                <a href="index.php?page=maestro_nuevo" class="btn btn-primary">
                    <i class="bi bi-plus-circle"></i> Nuevo Maestro
                </a>
            </div>

            <div class="mb-3">
                <form method="GET" action="index.php" class="d-flex gap-2">
                    <input type="hidden" name="page" value="maestros">
                    <input type="text" name="buscar" class="form-control" placeholder="Buscar por nombre, correo o código..."
                           value="<?php echo htmlspecialchars($_GET['buscar'] ?? ''); ?>">
                    <button type="submit" class="btn btn-outline-secondary">
                        <i class="bi bi-search"></i> Buscar
                    </button>
                </form>
            </div>

            <?php
            require_once __DIR__ . "/../../../controllers/MaestrosController.php";

            $buscar = $_GET['buscar'] ?? '';
            $maestros = $buscar
                ? \Controllers\MaestrosController::buscar($buscar)
                : \Controllers\MaestrosController::listar();

            if (!empty($maestros)): ?>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Código</th>
                                <th>Nombre</th>
                                <th>Correo</th>
                                <th>Especialidad</th>
                                <th>Teléfono</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($maestros as $maestro): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($maestro['codigo']); ?></td>
                                    <td><?php echo htmlspecialchars($maestro['nombre']); ?></td>
                                    <td><?php echo htmlspecialchars($maestro['correo']); ?></td>
                                    <td><?php echo htmlspecialchars($maestro['especialidad']); ?></td>
                                    <td><?php echo htmlspecialchars($maestro['telefono']); ?></td>
                                    <td>
                                        <span class="badge bg-success">
                                            Activo
                                        </span>
                                    </td>
                                    <td>
                                        <a href="index.php?page=maestro_nuevo&id=<?php echo $maestro['id_maestro']; ?>"
                                           class="btn btn-sm btn-warning">
                                            <i class="bi bi-pencil"></i> Editar
                                        </a>

                                        <a href="index.php?page=maestros&accion=eliminar&id=<?php echo $maestro['id_maestro']; ?>"
                                           class="btn btn-sm btn-danger"
                                           onclick="return confirm('¿Estás seguro de que deseas eliminar este maestro?');">
                                            <i class="bi bi-trash"></i> Eliminar
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php else: ?>
                <div class="alert alert-info">
                    No hay maestros registrados. <a href="index.php?page=maestro_nuevo">Registrar uno nuevo</a>
                </div>
            <?php endif; ?>

            <?php
            if (($_GET['accion'] ?? '') === 'eliminar' && isset($_GET['id'])) {
                $resultado = \Controllers\MaestrosController::eliminar($_GET['id']);

                if ($resultado['exito']) {
                    echo '<script>
                        alert("' . htmlspecialchars($resultado['mensaje']) . '");
                        window.location = "index.php?page=maestros";
                    </script>';
                } else {
                    echo '<div class="alert alert-danger">' . htmlspecialchars($resultado['mensaje']) . '</div>';
                }
            }
            ?>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>