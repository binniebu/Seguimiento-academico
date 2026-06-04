<?php
require_once __DIR__ . "/../../../dao/UsuarioDao.php";

$buscar = trim($_GET["buscar"] ?? "");
$estado = $_GET["estado"] ?? "";
$pagina = max(0, intval($_GET["pagina"] ?? 0));
$mensaje = "";
$error = "";

if (($_GET["accion"] ?? "") === "eliminar" && isset($_GET["id"])) {
    try {
        \Dao\UsuarioDao::deleteUser(intval($_GET["id"]));
        header("Location: index.php?page=usuarios&mensaje=Usuario eliminado correctamente");
        exit();
    } catch (Throwable $ex) {
        $error = "No se pudo eliminar el usuario. Verifique que no tenga registros relacionados.";
    }
}

if (isset($_GET["mensaje"])) {
    $mensaje = $_GET["mensaje"];
}

$resultado = \Dao\UsuarioDao::getUsers($buscar, $estado, "id_usuario", false, $pagina, 10);
$usuarios = $resultado["usuarios"];
$total = intval($resultado["total"]);
$itemsPorPagina = intval($resultado["itemsPerPage"]);
$totalPaginas = max(1, (int) ceil($total / $itemsPorPagina));
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Usuarios</title>
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
                        <li class="nav-item"><a class="nav-link" href="index.php?page=dashboard"><i class="bi bi-house-door"></i> Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=estudiantes"><i class="bi bi-people"></i> Estudiantes</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=maestros"><i class="bi bi-person-badge"></i> Maestros</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=materias"><i class="bi bi-book"></i> Materias</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=calificaciones"><i class="bi bi-graph-up"></i> Calificaciones</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=reportes"><i class="bi bi-file-text"></i> Reportes</a></li>
                        <li class="nav-item"><a class="nav-link active" href="index.php?page=usuarios"><i class="bi bi-person-gear"></i> Usuarios</a></li>
                        <li class="nav-item"><a class="nav-link" href="index.php?page=logout"><i class="bi bi-box-arrow-right"></i> Cerrar sesion</a></li>
                    </ul>
                </div>
            </nav>

            <main role="main" class="col-md-10 ml-sm-auto px-md-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Gestion de Usuarios</h1>
                    <a href="index.php?page=usuario_nuevo" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Nuevo Usuario
                    </a>
                </div>

                <?php if ($mensaje !== ""): ?>
                    <div class="alert alert-success"><?php echo htmlspecialchars($mensaje); ?></div>
                <?php endif; ?>

                <?php if ($error !== ""): ?>
                    <div class="alert alert-danger"><?php echo htmlspecialchars($error); ?></div>
                <?php endif; ?>

                <form method="GET" action="index.php" class="row g-2 mb-3">
                    <input type="hidden" name="page" value="usuarios">
                    <div class="col-md-6">
                        <input type="text" name="buscar" class="form-control" placeholder="Buscar por nombre o correo"
                               value="<?php echo htmlspecialchars($buscar); ?>">
                    </div>
                    <div class="col-md-3">
                        <select name="estado" class="form-select">
                            <option value="">Todos los estados</option>
                            <option value="activo" <?php echo $estado === "activo" ? "selected" : ""; ?>>Activo</option>
                            <option value="inactivo" <?php echo $estado === "inactivo" ? "selected" : ""; ?>>Inactivo</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex gap-2">
                        <button type="submit" class="btn btn-outline-secondary">
                            <i class="bi bi-search"></i> Buscar
                        </button>
                        <a href="index.php?page=usuarios" class="btn btn-outline-secondary">
                            <i class="bi bi-x-circle"></i>
                        </a>
                    </div>
                </form>

                <?php if (!empty($usuarios)): ?>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Nombre</th>
                                    <th>Correo</th>
                                    <th>Rol</th>
                                    <th>Estado</th>
                                    <th>Fecha creacion</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($usuarios as $usuario): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($usuario["id_usuario"]); ?></td>
                                        <td><?php echo htmlspecialchars($usuario["nombre"]); ?></td>
                                        <td><?php echo htmlspecialchars($usuario["correo"]); ?></td>
                                        <td><?php echo htmlspecialchars($usuario["nombre_rol"]); ?></td>
                                        <td>
                                            <span class="badge <?php echo $usuario["estado"] === "activo" ? "bg-success" : "bg-secondary"; ?>">
                                                <?php echo htmlspecialchars(ucfirst($usuario["estado"])); ?>
                                            </span>
                                        </td>
                                        <td><?php echo htmlspecialchars($usuario["fecha_creacion"] ?? ""); ?></td>
                                        <td>
                                            <a href="index.php?page=usuario_editar&id=<?php echo urlencode($usuario["id_usuario"]); ?>" class="btn btn-sm btn-warning">
                                                <i class="bi bi-pencil"></i> Editar
                                            </a>
                                            <a href="index.php?page=usuarios&accion=eliminar&id=<?php echo urlencode($usuario["id_usuario"]); ?>" class="btn btn-sm btn-danger"
                                               onclick="return confirm('Desea eliminar este usuario?');">
                                                <i class="bi bi-trash"></i> Eliminar
                                            </a>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>

                    <nav aria-label="Paginacion de usuarios">
                        <ul class="pagination">
                            <?php for ($i = 0; $i < $totalPaginas; $i++): ?>
                                <li class="page-item <?php echo $i === $pagina ? "active" : ""; ?>">
                                    <a class="page-link" href="index.php?page=usuarios&buscar=<?php echo urlencode($buscar); ?>&estado=<?php echo urlencode($estado); ?>&pagina=<?php echo $i; ?>">
                                        <?php echo $i + 1; ?>
                                    </a>
                                </li>
                            <?php endfor; ?>
                        </ul>
                    </nav>
                <?php else: ?>
                    <div class="alert alert-info">
                        No hay usuarios registrados. <a href="index.php?page=usuario_nuevo">Registrar uno nuevo</a>
                    </div>
                <?php endif; ?>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
