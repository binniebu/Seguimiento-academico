<?php
require_once __DIR__ . "/../../controllers/UsuariosController.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$perfil = \Controllers\UsuariosController::obtenerPerfilActivo();

if (!$perfil) {
    echo "<script>alert('No se pudo cargar la informacion del perfil.'); window.location='index.php?page=home';</script>";
    exit();
}

if (!function_exists("valorPerfil")) {
    function valorPerfil($valor, $fallback = "No registrado") {
        $valor = trim((string) ($valor ?? ""));
        return $valor !== "" ? $valor : $fallback;
    }
}

$rolActual = $_SESSION["rol"] ?? ($perfil["nombre_rol"] ?? "");
$dni = $perfil["dni"] ?? "";

if ($dni === "" && !empty($perfil["documento_dni"])) {
    $dni = basename((string) $perfil["documento_dni"]);
}

$datosAdicionales = array();

if ($rolActual === "coordinador") {
    $datosAdicionales["Facultad administrada"] = valorPerfil($perfil["nombre_facultad"] ?? "");
}

if ($rolActual === "maestro") {
    $datosAdicionales["Titulo profesional"] = valorPerfil($perfil["titulo"] ?? "");
    $datosAdicionales["Numero de empleado"] = valorPerfil($perfil["numero_empleado"] ?? ($perfil["codigo_maestro"] ?? ""));
    $datosAdicionales["Especialidad"] = valorPerfil($perfil["especialidad"] ?? "");
}

if ($rolActual === "estudiante") {
    $datosAdicionales["Carrera"] = valorPerfil($perfil["carrera"] ?? "");
    $datosAdicionales["Telefono"] = valorPerfil($perfil["telefono_estudiante"] ?? "");
}

if ($rolActual === "director") {
    $datosAdicionales["Titulo profesional"] = valorPerfil($perfil["titulo"] ?? "");
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil y Seguridad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <?php require_once __DIR__ . "/sidebar.view.tpl"; ?>

        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn" type="button">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-1">Perfil y Seguridad</h1>
                            <p class="text-muted mb-0">Datos de la cuenta activa y cambio seguro de contraseña.</p>
                        </div>
                    </div>
                    <a href="index.php?page=home" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center gap-3 mb-4">
                                    <div class="rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center" style="width: 56px; height: 56px; font-size: 1.6rem;">
                                        <i class="bi bi-person"></i>
                                    </div>
                                    <div>
                                        <h2 class="h4 mb-0"><?php echo htmlspecialchars(valorPerfil($perfil["nombre"] ?? "")); ?></h2>
                                    </div>
                                </div>

                                <dl class="row mb-0">
                                    <dt class="col-sm-4 text-muted">Nombre</dt>
                                    <dd class="col-sm-8"><?php echo htmlspecialchars(valorPerfil($perfil["nombre"] ?? "")); ?></dd>

                                    <dt class="col-sm-4 text-muted">Correo</dt>
                                    <dd class="col-sm-8"><?php echo htmlspecialchars(valorPerfil($perfil["correo"] ?? "")); ?></dd>

                                    <dt class="col-sm-4 text-muted">DNI</dt>
                                    <dd class="col-sm-8"><?php echo htmlspecialchars(valorPerfil($dni)); ?></dd>

                                    <?php foreach ($datosAdicionales as $etiqueta => $valor): ?>
                                        <dt class="col-sm-4 text-muted"><?php echo htmlspecialchars($etiqueta); ?></dt>
                                        <dd class="col-sm-8"><?php echo htmlspecialchars($valor); ?></dd>
                                    <?php endforeach; ?>
                                </dl>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-7">
                        <div class="card border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center gap-2 mb-3">
                                    <i class="bi bi-shield-lock text-primary fs-4"></i>
                                    <h2 class="h4 mb-0">Cambio de contraseña</h2>
                                </div>

                                <form method="POST" action="index.php?page=perfil_actualizar" autocomplete="off">
                                    <div class="mb-3">
                                        <label class="form-label">Contraseña Actual <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <input type="password"
                                                   name="password_actual"
                                                   class="form-control password-field"
                                                   autocomplete="current-password"
                                                   oncopy="return false;"
                                                   onpaste="return false;"
                                                   required>
                                            <button class="btn btn-outline-secondary toggle-password" type="button" aria-label="Mostrar u ocultar contraseña">
                                                <i class="bi bi-eye-slash"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Nueva Contraseña <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <input type="password"
                                                   name="password_nuevo"
                                                   class="form-control password-field"
                                                   autocomplete="new-password"
                                                   minlength="6"
                                                   oncopy="return false;"
                                                   onpaste="return false;"
                                                   required>
                                            <button class="btn btn-outline-secondary toggle-password" type="button" aria-label="Mostrar u ocultar contraseña">
                                                <i class="bi bi-eye-slash"></i>
                                            </button>
                                        </div>
                                        <div class="form-text">Debe tener minimo 6 caracteres.</div>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label">Confirmar Nueva Contraseña <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <input type="password"
                                                   name="password_confirmar"
                                                   class="form-control password-field"
                                                   autocomplete="new-password"
                                                   minlength="6"
                                                   oncopy="return false;"
                                                   onpaste="return false;"
                                                   required>
                                            <button class="btn btn-outline-secondary toggle-password" type="button" aria-label="Mostrar u ocultar contraseña">
                                                <i class="bi bi-eye-slash"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="alert alert-warning">
                                        <i class="bi bi-info-circle"></i>
                                        Al cambiar la contraseña se cerrara la sesion automaticamente.
                                    </div>

                                    <button type="submit" class="btn btn-primary" 
                                             data-confirmar="¿Desea cambiar su contraseña? Su sesión se cerrará de forma automática y deberá iniciar sesión de nuevo." 
                                             data-titulo="Actualizar Contraseña" 
                                             data-confirm-text="Sí, cambiar contraseña" 
                                             data-icono="question">
                                        <i class="bi bi-key"></i> Actualizar Contraseña
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>

document.querySelectorAll('.toggle-password').forEach(button => {
    button.addEventListener('click', function() {
        const input = this.closest('.input-group').querySelector('.password-field');
        const icon = this.querySelector('i');
        const visible = input.type === 'text';
        input.type = visible ? 'password' : 'text';
        icon.classList.toggle('bi-eye', !visible);
        icon.classList.toggle('bi-eye-slash', visible);
    });
});
</script>
</body>
</html>
