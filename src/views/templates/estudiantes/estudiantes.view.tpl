<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Estudiantes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">

        <nav class="col-md-2 d-md-block bg-light sidebar">
            <div class="sidebar-sticky pt-3">
                <h6 class="sidebar-heading px-3 mt-4 mb-2 text-muted">Menu</h6>
                <ul class="nav flex-column">
                    <li class="nav-item">
                       <a class="nav-link" href="index.php?page=home">
                           <i class="bi bi-house-fill"></i> Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=dashboard">
                            <i class="bi bi-house-door"></i> Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="index.php?page=estudiantes">
                            <i class="bi bi-people"></i> Estudiantes
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=maestros">
                            <i class="bi bi-person-badge"></i> Maestros
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=materias">
                            <i class="bi bi-book"></i> Materias
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=calificaciones">
                            <i class="bi bi-graph-up"></i> Calificaciones
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=reportes">
                            <i class="bi bi-file-text"></i> Reportes
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=logout">
                            <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                        </a>
                    </li>
                </ul>
            </div>
        </nav>

        <main role="main" class="col-md-10 ml-sm-auto px-md-4">
            <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Gestión de Estudiantes</h1>
                <a href="index.php?page=estudiante_nuevo" class="btn btn-primary">
                    <i class="bi bi-plus-circle"></i> Nuevo Estudiante
                </a>
            </div>

            <div class="mb-3">
                <form method="GET" action="index.php" class="d-flex gap-2">
                    <input type="hidden" name="page" value="estudiantes">
                    <input type="text" name="buscar" class="form-control" placeholder="Buscar por nombre, correo o cuenta..."
                           value="<?php echo htmlspecialchars($_GET['buscar'] ?? ''); ?>">
                    <button type="submit" class="btn btn-outline-secondary">
                        <i class="bi bi-search"></i> Buscar
                    </button>
                </form>
            </div>

            <?php
            require_once __DIR__ . "/../../../controllers/EstudiantesController.php";

            $buscar = $_GET['buscar'] ?? '';
            $estudiantes = $buscar
                ? \Controllers\EstudiantesController::buscar($buscar)
                : \Controllers\EstudiantesController::listar();

            if (!empty($estudiantes)): ?>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Cuenta</th>
                                <th>Nombre</th>
                                <th>Correo</th>
                                <th>Carrera</th>
                                <th>Teléfono</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($estudiantes as $estudiante): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($estudiante['cuenta']); ?></td>
                                    <td><?php echo htmlspecialchars($estudiante['nombre']); ?></td>
                                    <td><?php echo htmlspecialchars($estudiante['correo']); ?></td>
                                    <td><?php echo htmlspecialchars($estudiante['carrera']); ?></td>
                                    <td><?php echo htmlspecialchars($estudiante['telefono']); ?></td>
                                    <td>
                                        <span class="badge bg-success">
                                            Activo
                                        </span>
                                    </td>
                                    <td>
                                        <a href="index.php?page=estudiante_nuevo&id=<?php echo $estudiante['id_estudiante']; ?>"
                                           class="btn btn-sm btn-warning">
                                            <i class="bi bi-pencil"></i> Editar
                                        </a>

                                        <a href="index.php?page=estudiantes&accion=eliminar&id=<?php echo $estudiante['id_estudiante']; ?>"
                                           class="btn btn-sm btn-danger"
                                           onclick="return confirm('¿Estás seguro de que deseas eliminar este estudiante?');">
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
                    No hay estudiantes registrados. <a href="index.php?page=estudiante_nuevo">Registrar uno nuevo</a>
                </div>
            <?php endif; ?>

            <?php
            if (($_GET['accion'] ?? '') === 'eliminar' && isset($_GET['id'])) {
                $resultado = \Controllers\EstudiantesController::eliminar($_GET['id']);

                if ($resultado['exito']) {
                    echo '<script>
                        alert("' . htmlspecialchars($resultado['mensaje']) . '");
                        window.location = "index.php?page=estudiantes";
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
