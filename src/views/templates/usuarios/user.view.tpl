<?php
require_once __DIR__ . "/../../../dao/UsuarioDao.php";

$esEdicion = ($_GET["page"] ?? "") === "usuario_editar";
$idUsuario = intval($_GET["id"] ?? 0);
$error = "";
$usuario = [
    "id_usuario" => 0,
    "nombre" => "",
    "correo" => "",
    "id_rol" => "",
    "estado" => "activo"
];

if ($esEdicion) {
    $usuarioExistente = \Dao\UsuarioDao::getUserById($idUsuario);
    if (!$usuarioExistente) {
        header("Location: index.php?page=usuarios&mensaje=Usuario no encontrado");
        exit();
    }
    $usuario = $usuarioExistente;
}

$roles = \Dao\UsuarioDao::getRolesDisponibles();

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $nombre = trim($_POST["nombre"] ?? "");
    $correo = trim($_POST["correo"] ?? "");
    $password = $_POST["password"] ?? "";
    $idRol = intval($_POST["id_rol"] ?? 0);
    $estado = $_POST["estado"] ?? "activo";

    if ($nombre === "" || $correo === "" || $idRol <= 0) {
        $error = "Nombre, correo y rol son obligatorios.";
    } elseif (!$esEdicion && trim($password) === "") {
        $error = "La contrasena es obligatoria para usuarios nuevos.";
    } else {
        try {
            if ($esEdicion) {
                \Dao\UsuarioDao::updateUser($idUsuario, $nombre, $correo, $idRol, $estado);
                header("Location: index.php?page=usuarios&mensaje=Usuario actualizado correctamente");
                exit();
            }

            if (\Dao\UsuarioDao::existeCorreo($correo)) {
                $error = "Este correo ya esta registrado.";
            } else {
                \Dao\UsuarioDao::insertUser($nombre, $correo, $password, $idRol, $estado);
                header("Location: index.php?page=usuarios&mensaje=Usuario creado correctamente");
                exit();
            }
        } catch (Throwable $ex) {
            $error = "No se pudo guardar el usuario. Revise los datos ingresados.";
        }
    }

    $usuario["nombre"] = $nombre;
    $usuario["correo"] = $correo;
    $usuario["id_rol"] = $idRol;
    $usuario["estado"] = $estado;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $esEdicion ? "Editar Usuario" : "Nuevo Usuario"; ?></title>
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
                    <h1 class="h2"><?php echo $esEdicion ? "Editar Usuario" : "Nuevo Usuario"; ?></h1>
                    <a href="index.php?page=usuarios" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <?php if ($error !== ""): ?>
                    <div class="alert alert-danger"><?php echo htmlspecialchars($error); ?></div>
                <?php endif; ?>

                <form method="POST" action="index.php?page=<?php echo $esEdicion ? "usuario_editar&id=" . urlencode($idUsuario) : "usuario_nuevo"; ?>" class="row g-3">
                    <div class="col-md-6">
                        <label for="nombre" class="form-label">Nombre</label>
                        <input type="text" id="nombre" name="nombre" class="form-control" required
                               value="<?php echo htmlspecialchars($usuario["nombre"]); ?>">
                    </div>
                    <div class="col-md-6">
                        <label for="correo" class="form-label">Correo</label>
                        <input type="email" id="correo" name="correo" class="form-control" required
                               value="<?php echo htmlspecialchars($usuario["correo"]); ?>">
                    </div>
                    <?php if (!$esEdicion): ?>
                        <div class="col-md-6">
                            <label for="password" class="form-label">Contrasena</label>
                            <input type="password" id="password" name="password" class="form-control" required>
                        </div>
                    <?php endif; ?>
                    <div class="col-md-6">
                        <label for="id_rol" class="form-label">Rol</label>
                        <select id="id_rol" name="id_rol" class="form-select" required>
                            <option value="">Seleccione un rol</option>
                            <?php foreach ($roles as $rol): ?>
                                <option value="<?php echo htmlspecialchars($rol["id_rol"]); ?>" <?php echo intval($usuario["id_rol"]) === intval($rol["id_rol"]) ? "selected" : ""; ?>>
                                    <?php echo htmlspecialchars($rol["nombre_rol"]); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label for="estado" class="form-label">Estado</label>
                        <select id="estado" name="estado" class="form-select">
                            <option value="activo" <?php echo $usuario["estado"] === "activo" ? "selected" : ""; ?>>Activo</option>
                            <option value="inactivo" <?php echo $usuario["estado"] === "inactivo" ? "selected" : ""; ?>>Inactivo</option>
                        </select>
                    </div>
                    <div class="col-12 d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save"></i> Guardar
                        </button>
                        <a href="index.php?page=usuarios" class="btn btn-outline-secondary">Cancelar</a>
                    </div>
                </form>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
