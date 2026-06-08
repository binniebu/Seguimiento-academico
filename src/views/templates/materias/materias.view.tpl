<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Materias</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
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
                            <a class="nav-link" href="index.php?page=estudiantes">
                                <i class="bi bi-people"></i> Estudiantes
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=maestros">
                                <i class="bi bi-person-badge"></i> Maestros
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="index.php?page=materias">
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

            <!-- Main content -->
            <main role="main" class="col-md-10 ml-sm-auto px-md-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Gestión de Materias</h1>
                    <a href="index.php?page=materia_nueva" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Nueva Materia
                    </a>
                </div>

                <!-- Búsqueda -->
                <div class="mb-3">
                    <form method="GET" action="index.php" class="d-flex gap-2">
                        <input type="hidden" name="page" value="materias">
                        <input type="text" name="buscar" class="form-control" placeholder="Buscar por nombre o código..." 
                               value="<?php echo htmlspecialchars($_GET['buscar'] ?? ''); ?>">
                        <button type="submit" class="btn btn-outline-secondary">
                            <i class="bi bi-search"></i> Buscar
                        </button>
                    </form>
                </div>

                <!-- Listado de materias -->
                <?php
                require_once __DIR__ . "/../../../controllers/MateriasController.php";
                
                $buscar = $_GET['buscar'] ?? '';
                $materias = $buscar 
                    ? \Controllers\MateriasController::buscar($buscar) 
                    : \Controllers\MateriasController::listar();
                
                if (!empty($materias)): ?>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Código</th>
                                    <th>Nombre</th>
                                    <th>Descripción</th>
                                    <th>Maestro</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($materias as $materia): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($materia['codigo']); ?></td>
                                        <td><?php echo htmlspecialchars($materia['nombre']); ?></td>
                                        <td><?php echo htmlspecialchars(substr($materia['descripcion'] ?? '', 0, 50)); ?></td>
                                        <td><?php echo htmlspecialchars($materia['maestro_nombre'] ?? 'Sin asignar'); ?></td>
                                        <td>
                                            <span class="badge <?php echo $materia['estado'] === 'activa' ? 'bg-success' : 'bg-warning'; ?>">
                                                <?php echo ucfirst($materia['estado']); ?>
                                            </span>
                                        </td>
                                        <td>
                                            <a href="index.php?page=materia_nueva&id=<?php echo $materia['id_materia']; ?>" 
                                               class="btn btn-sm btn-warning">
                                                <i class="bi bi-pencil"></i> Editar
                                            </a>
                                            <a href="index.php?page=materias&accion=eliminar&id=<?php echo $materia['id_materia']; ?>" 
                                               class="btn btn-sm btn-danger" 
                                               onclick="return confirm('¿Estás seguro de que deseas eliminar esta materia?');">
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
                        No hay materias registradas. <a href="index.php?page=materia_nueva">Registrar una nueva</a>
                    </div>
                <?php endif; ?>

                <!-- Acciones -->
                <?php
                if ($_GET['accion'] ?? '' === 'eliminar' && isset($_GET['id'])) {
                    $resultado = \Controllers\MateriasController::eliminar($_GET['id']);
                    if ($resultado['exito']) {
                        echo '<script>
                            alert("' . htmlspecialchars($resultado['mensaje']) . '");
                            window.location = "index.php?page=materias";
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
