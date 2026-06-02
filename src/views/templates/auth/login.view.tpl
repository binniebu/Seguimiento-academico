<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Iniciar sesión</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>

<div class="login-container">
    <div class="info-panel">
        <h1>Seguimiento<br><span>Académico</span></h1>
        <p>Sistema web para gestionar estudiantes, maestros, materias y calificaciones.</p>
    </div>

    <div class="form-panel">
        <div class="card-login">
            <h2>Iniciar sesión</h2>
            <p class="text-muted">Accede con tu cuenta institucional</p>

            <form action="index.php?page=login" method="POST">
                <div class="mb-3">
                    <label>Correo electrónico</label>
                    <input type="email" name="correo" class="form-control" placeholder="ejemplo@correo.com" required>
                </div>

                <div class="mb-3">
                    <label>Contraseña</label>
                    <input type="password" name="password" class="form-control" placeholder="Ingresa tu contraseña" required>
                </div>

                <button type="submit" class="btn btn-primary w-100">INGRESAR</button>
            </form>

            <div class="text-center mt-4">
                <small>¿No tienes una cuenta?</small><br>
                <a href="index.php?page=register">REGÍSTRATE AQUÍ</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>