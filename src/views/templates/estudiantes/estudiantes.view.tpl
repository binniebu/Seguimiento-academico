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
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <?php
        $ver = $_GET['ver'] ?? 'activos';
        $verInactivos = ($ver === 'inactivos');
        $verGraduados = ($ver === 'graduados');
        ?>
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">
                            <?php 
                                if ($ver === 'inactivos') echo 'Gestión de Estudiantes - Bajas / Reingresos';
                                elseif ($ver === 'graduados') echo 'Gestión de Estudiantes - Graduados';
                                else echo 'Gestión de Estudiantes';
                            ?>
                        </h1>
                    </div>
                    <div class="d-flex gap-2 align-items-center">
                        <a href="index.php?page=estudiantes" class="btn btn-sm <?php echo ($ver === 'activos') ? 'btn-primary' : 'btn-outline-primary'; ?>">
                            <i class="bi bi-people-fill"></i> Activos
                        </a>
                        <a href="index.php?page=estudiantes&ver=graduados" class="btn btn-sm <?php echo ($ver === 'graduados') ? 'btn-primary' : 'btn-outline-primary'; ?>">
                            <i class="bi bi-mortarboard-fill"></i> Graduados
                        </a>
                        <a href="index.php?page=estudiantes&ver=inactivos" class="btn btn-sm <?php echo ($ver === 'inactivos') ? 'btn-primary' : 'btn-outline-secondary'; ?>">
                            <i class="bi bi-person-slash"></i> Bajas / Reingresos
                        </a>
                        <?php if ($ver === 'activos'): ?>
                            <a href="index.php?page=estudiante_nuevo" class="btn btn-sm btn-success ms-2">
                                <i class="bi bi-plus-circle"></i> Nuevo Estudiante
                            </a>
                        <?php endif; ?>
                    </div>
                </div>

                <div class="mb-4">
                    <form method="GET" action="index.php" class="d-flex gap-2">
                        <input type="hidden" name="page" value="estudiantes">
                        <?php if ($ver !== 'activos'): ?>
                            <input type="hidden" name="ver" value="<?php echo htmlspecialchars($ver); ?>">
                        <?php endif; ?>
                        <input type="text" name="buscar" class="form-control" placeholder="Buscar por nombre, correo o cuenta..."
                               value="<?php echo htmlspecialchars($_GET['buscar'] ?? ''); ?>">
                        <button type="submit" class="btn btn-outline-secondary">
                            <i class="bi bi-search"></i> Buscar
                        </button>
                        <?php if (!empty($_GET['buscar'])): ?>
                            <a href="index.php?page=estudiantes<?php echo ($ver !== 'activos') ? '&ver=' . urlencode($ver) : ''; ?>" class="btn btn-outline-danger">
                                <i class="bi bi-x-circle"></i> Limpiar
                            </a>
                        <?php endif; ?>
                    </form>
                </div>

            <?php
            require_once __DIR__ . "/../../../dao/EstudianteDao.php";
            require_once __DIR__ . "/../../../controllers/EstudiantesController.php";

            $buscar = $_GET['buscar'] ?? '';
            $p = intval($_GET['p'] ?? 1);
            if ($p < 1) $p = 1;
            $limit = 5; // 5 estudiantes por página
            $offset = ($p - 1) * $limit;

            // Determinar si es coordinador para filtrar por su facultad
            $idFacultad = ($_SESSION["rol"] === "coordinador") ? ($_SESSION["id_facultad"] ?? null) : null;

            $totalEstudiantes = \Dao\EstudianteDao::obtenerTotalEstudiantes($buscar, $ver, $idFacultad);
            $totalPages = ceil($totalEstudiantes / $limit);
            if ($totalPages < 1) $totalPages = 1;
            if ($p > $totalPages) {
                $p = $totalPages;
                $offset = ($p - 1) * $limit;
            }

            $estudiantes = \Dao\EstudianteDao::obtenerEstudiantes($buscar, $ver, $limit, $offset, $idFacultad);

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
                                         <?php
                                         $estadoLower = strtolower($estudiante['estado'] ?? '');
                                         $badgeClass = 'bg-secondary';
                                         if ($estadoLower === 'activo' || $estadoLower === 'admitido') {
                                             $badgeClass = 'bg-success';
                                         } elseif ($estadoLower === 'suspendido') {
                                             $badgeClass = 'bg-danger';
                                         } elseif ($estadoLower === 'pendiente') {
                                             $badgeClass = 'bg-warning text-dark';
                                         }
                                         ?>
                                         <span class="badge <?php echo $badgeClass; ?>">
                                             <?php echo ucfirst(htmlspecialchars($estudiante['estado'] ?? '')); ?>
                                         </span>
                                     </td>
                                      <td class="actions-cell">
                                         <div class="d-flex flex-column gap-1">
                                            <?php if ($ver === 'inactivos'): ?>
                                                <a href="index.php?page=estudiantes&ver=inactivos&accion=activar&id=<?php echo $estudiante['id_estudiante']; ?>"
                                                   class="btn btn-sm btn-success"
                                                   onclick="return confirm('¿Estás seguro de que deseas reactivar este estudiante?');">
                                                    <i class="bi bi-person-check"></i> Activar Cuenta
                                                </a>
                                            <?php elseif ($ver === 'graduados'): ?>
                                                <span class="text-muted small text-center">Sin acciones</span>
                                            <?php else: ?>
                                                 <a href="index.php?page=estudiante_nuevo&id=<?php echo $estudiante['id_estudiante']; ?>"
                                                    class="btn btn-sm btn-warning">
                                                     <i class="bi bi-pencil"></i> Editar
                                                 </a>

                                                 <a href="index.php?page=estudiantes&accion=eliminar&id=<?php echo $estudiante['id_estudiante']; ?>"
                                                    class="btn btn-sm btn-danger"
                                                    onclick="return confirm('¿Estás seguro de que deseas dar de baja a este estudiante?');">
                                                     <i class="bi bi-person-x"></i> Dar de baja
                                                 </a>
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
                                <a class="page-link" href="index.php?page=estudiantes<?php 
                                    echo ($ver !== 'activos' ? '&ver=' . urlencode($ver) : '') . 
                                         ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                         '&p=' . ($p - 1); 
                                ?>" aria-label="Anterior">
                                    <span aria-hidden="true">&laquo; Anterior</span>
                                </a>
                            </li>

                            <!-- Páginas -->
                            <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                                <li class="page-item <?php echo $p === $i ? 'active' : ''; ?>">
                                    <a class="page-link" href="index.php?page=estudiantes<?php 
                                        echo ($ver !== 'activos' ? '&ver=' . urlencode($ver) : '') . 
                                             ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
                                             '&p=' . $i; 
                                    ?>">
                                        <?php echo $i; ?>
                                    </a>
                                </li>
                            <?php endfor; ?>

                            <!-- Siguiente -->
                            <li class="page-item <?php echo $p >= $totalPages ? 'disabled' : ''; ?>">
                                <a class="page-link" href="index.php?page=estudiantes<?php 
                                    echo ($ver !== 'activos' ? '&ver=' . urlencode($ver) : '') . 
                                         ($buscar !== '' ? '&buscar=' . urlencode($buscar) : '') . 
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
                    <?php if ($buscar !== ''): ?>
                        No se encontraron estudiantes que coincidan con la búsqueda: "<strong><?php echo htmlspecialchars($buscar); ?></strong>".
                    <?php elseif ($ver === 'inactivos'): ?>
                        No hay estudiantes de baja o suspendidos en este momento.
                    <?php elseif ($ver === 'graduados'): ?>
                        No hay estudiantes graduados registrados en este momento.
                    <?php else: ?>
                        No hay estudiantes activos registrados. <a href="index.php?page=estudiante_nuevo" class="alert-link">Registrar uno nuevo</a>
                    <?php endif; ?>
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

             if (($_GET['accion'] ?? '') === 'activar' && isset($_GET['id'])) {
                 $resultado = \Controllers\EstudiantesController::activar($_GET['id']);

                 if ($resultado['exito']) {
                     echo '<script>
                         alert("' . htmlspecialchars($resultado['mensaje']) . '");
                         window.location = "index.php?page=estudiantes&ver=inactivos";
                     </script>';
                 } else {
                     echo '<div class="alert alert-danger">' . htmlspecialchars($resultado['mensaje']) . '</div>';
                 }
             }
             ?>
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
</script>
</body>
</html>
