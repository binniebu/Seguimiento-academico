<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>

<div class="login-container">
    <div class="info-panel">
        <h1>Crear<br><span>Cuenta</span></h1>
        <p>Registra tu acceso según tu rol dentro del sistema académico.</p>
    </div>

    <div class="form-panel">
        <div class="card-login">
            <h2>Registro</h2>
            <p class="text-muted">Completa tus datos</p>

            <form action="index.php?page=register" method="POST">
                <div class="mb-3">
                    <label>Nombre completo</label>
                    <input type="text" name="nombre" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label>Correo electrónico</label>
                    <input type="email" name="correo" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label>Contraseña</label>
                    <input type="password" name="password" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label>Rol</label>
                    <select name="rol" class="form-select" required>
                        <option value="">Seleccione un rol</option>
                        <option value="1">Director</option>
                        <option value="2">Maestro</option>
                        <option value="3">Estudiante</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary w-100">REGISTRARSE</button>
            </form>

            <div class="text-center mt-4">
                <small>¿Ya tienes cuenta?</small><br>
                <a href="index.php?page=login">INICIAR SESIÓN</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>