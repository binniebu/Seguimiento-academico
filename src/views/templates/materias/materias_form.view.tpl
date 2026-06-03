<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Materias</title>
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
                            <a class="nav-link" href="index.php?page=dashboard">
                                <i class="bi bi-house-door"></i> Dashboard
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
                    <h1 class="h2">Registro de Materias</h1>
                    <a href="index.php?page=materias" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <?php
                require_once __DIR__ . "/../../../controllers/MateriasController.php";
                
                $materia = null;
                $esEdicion = false;
                $maestros = \Controllers\MateriasController::obtenerMaestros();

                if (isset($_GET['id'])) {
                    $materia = \Controllers\MateriasController::obtener($_GET['id']);
                    $esEdicion = $materia !== null;
                }

                // Procesar formulario
                if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                    $codigo = $_POST['codigo'] ?? '';
                    $nombre = $_POST['nombre'] ?? '';
                    $descripcion = $_POST['descripcion'] ?? '';
                    $id_maestro = $_POST['id_maestro'] ?? '';
                    
                    if ($esEdicion) {
                        $estado = $_POST['estado'] ?? 'activa';
                        $resultado = \Controllers\MateriasController::actualizar(
                            $_GET['id'], $codigo, $nombre, $descripcion, $id_maestro, $estado
                        );
                    } else {
                        $resultado = \Controllers\MateriasController::crear(
                            $codigo, $nombre, $descripcion, $id_maestro
                        );
                    }

                    if ($resultado['exito']) {
                        echo '<div class="alert alert-success">' . htmlspecialchars($resultado['mensaje']) . '</div>';
                        echo '<script>
                            setTimeout(function() {
                                window.location = "index.php?page=materias";
                            }, 1500);
                        </script>';
                    } else {
                        echo '<div class="alert alert-danger">' . htmlspecialchars($resultado['mensaje']) . '</div>';
                    }
                }
                ?>

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
                                        <label for="id_maestro" class="form-label">Maestro Asignado <span class="text-danger">*</span></label>
                                        <select class="form-select" id="id_maestro" name="id_maestro" required>
                                            <option value="">-- Selecciona un maestro --</option>
                                            <?php foreach ($maestros as $maestro): ?>
                                                <option value="<?php echo $maestro['id_maestro']; ?>"
                                                    <?php echo ($materia && $materia['id_maestro'] == $maestro['id_maestro']) ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($maestro['nombre']); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
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
                                        <a href="index.php?page=materias" class="btn btn-secondary">
                                            <i class="bi bi-x-circle"></i> Cancelar
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
</body>
</html>
