<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitud de Admisión Académica</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
    <style>
        body {
            background-color: #f4f7fb;
        }
        .register-container {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem 0;
        }
        .register-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 10px 35px rgba(0, 0, 0, 0.15);
            background: #ffffff;
            overflow: hidden;
            width: 100%;
            max-width: 650px;
        }
        .header-panel {
            background: linear-gradient(135deg, #003b8e, #0057d8);
            color: #ffffff;
            padding: 2.5rem;
            text-align: center;
        }
        .header-panel h1 {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
        }
        .header-panel span {
            color: #ffc400;
        }
        .form-label-custom {
            font-weight: bold;
            color: #003b8e;
        }
        .text-primary-custom {
            color: #003b8e !important;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="register-container">
    <div class="register-card">
        
        <!-- Encabezado Estilizado con los colores del Login -->
        <div class="header-panel">
            <h1>Solicitud de <span>Admisión</span></h1>
            <p class="mb-0 text-white-50">Completa tu pre-registro adjuntando tus documentos de respaldo para el ingreso.</p>
        </div>

        <!-- Formulario de Registro -->
        <div class="card-body p-4 p-md-5">
            <form action="index.php?page=register" method="POST" enctype="multipart/form-data" class="needs-validation" novalidate>
                
                <h5 class="text-primary-custom mb-3"><i class="bi bi-person-fill"></i> Datos Personales</h5>
                
                <div class="mb-3">
                    <label class="form-label-custom">Nombre Completo <span class="text-danger">*</span></label>
                    <input type="text" name="nombre" class="form-control" placeholder="Escribe tu nombre y apellidos" value="<?php echo htmlspecialchars($_POST['nombre'] ?? ''); ?>" required>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label-custom">DNI / Identidad <span class="text-danger">*</span></label>
                        <input type="text" name="dni" class="form-control" placeholder="Ej. 0801-1999-12345" value="<?php echo htmlspecialchars($_POST['dni'] ?? ''); ?>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label-custom">Teléfono <span class="text-danger">*</span></label>
                        <input type="tel" name="telefono" class="form-control" placeholder="Ej. 9988-7766" value="<?php echo htmlspecialchars($_POST['telefono'] ?? ''); ?>" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">Correo electrónico <span class="text-danger">*</span></label>
                    <input type="email" name="correo" class="form-control" placeholder="correo@ejemplo.com" value="<?php echo htmlspecialchars($_POST['correo'] ?? ''); ?>" required>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label-custom">Contraseña <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" name="password" id="password" class="form-control" placeholder="Mínimo 6 caracteres" value="<?php echo htmlspecialchars($_POST['password'] ?? ''); ?>" required oncopy="return false;" onpaste="return false;" oncut="return false;" minlength="6">
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                <i class="bi bi-eye-slash"></i>
                            </button>
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label-custom">Confirmar Contraseña <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" name="confirm_password" id="confirm_password" class="form-control" placeholder="Repite tu contraseña" value="<?php echo htmlspecialchars($_POST['confirm_password'] ?? ''); ?>" required oncopy="return false;" onpaste="return false;" oncut="return false;" minlength="6">
                            <button class="btn btn-outline-secondary" type="button" id="toggleConfirmPassword">
                                <i class="bi bi-eye-slash"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <h5 class="text-primary-custom mb-3 mt-4"><i class="bi bi-mortarboard-fill"></i> Nivel Académico</h5>

                <div class="mb-3">
                    <label class="form-label-custom">Carrera a la que aplica <span class="text-danger">*</span></label>
                    <select name="carrera" id="carreraSelect" class="form-select" required>
                        <option value="">Selecciona la carrera de tu elección</option>
                        <?php if (!empty($carrerasActivas)): ?>
                            <?php foreach ($carrerasActivas as $c): ?>
                                <option value="<?php echo htmlspecialchars($c['nombre_carrera']); ?>" <?php echo (isset($_POST['carrera']) && $_POST['carrera'] === $c['nombre_carrera']) ? 'selected' : ''; ?>>
                                    <?php echo htmlspecialchars($c['nombre_carrera']); ?>
                                </option>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </select>
                </div>

                <div class="row mt-4">
                    <div class="col-md-6 mb-3">
                        <label class="form-label-custom text-danger" style="font-size: 13px;"><i class="bi bi-file-earmark-person"></i> Documento DNI / Identificación <span class="text-danger">*</span></label>
                        <input type="file" name="documento_dni" class="form-control" accept=".pdf,.png,.jpg,.jpeg" required>
                        <div class="form-text text-muted" id="dniHelp" style="font-size: 11px;">
                            DNI o Acta de Nacimiento.
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label-custom text-danger" id="tituloLabel" style="font-size: 13px;"><i class="bi bi-file-earmark-medical"></i> Título de Respaldo <span class="text-danger">*</span></label>
                        <input type="file" name="documento_titulo" class="form-control" accept=".pdf,.png,.jpg,.jpeg" required>
                        <div class="form-text text-muted" id="tituloHelp" style="font-size: 11px;">
                            Sube tu Título Académico.
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 py-2 fw-bold mt-4">ENVIAR SOLICITUD</button>
            </form>

            <div class="text-center mt-4 pt-3 border-top">
                <small class="text-muted">¿Ya tienes cuenta?</small><br>
                <a href="index.php?page=login" class="fw-bold" style="color: #0057d8;">INICIAR SESIÓN</a>
            </div>
        </div>
    </div>
</div>

<script>
    // Validaciones dinámicas de la documentación de respaldo según la carrera elegida
    document.getElementById('carreraSelect').addEventListener('change', function() {
        const carrera = this.value;
        const helpText = document.getElementById('tituloHelp');
        const label = document.getElementById('tituloLabel');
        const dniHelp = document.getElementById('dniHelp');

        if (!carrera) {
            helpText.innerHTML = "Sube tu Título Académico.";
            return;
        }

        // Si la carrera elegida es una maestría o postgrado
        if (carrera.toLowerCase().includes('maestría') || carrera.toLowerCase().includes('postgrado')) {
            label.innerHTML = '<i class="bi bi-file-earmark-medical"></i> Título Universitario <span class="text-danger">*</span>';
            helpText.innerHTML = "Título de Pregrado / Licenciatura.";
            dniHelp.innerHTML = "DNI (Identificación) legible.";
        } else {
            label.innerHTML = '<i class="bi bi-file-earmark-medical"></i> Título de Bachiller <span class="text-danger">*</span>';
            helpText.innerHTML = "Título de Educación Media / Bachillerato.";
            dniHelp.innerHTML = "DNI (o Acta de Nacimiento si eres menor).";
        }
    });

    // Deshabilitar envío si los campos no son válidos o si las contraseñas no coinciden
    (function () {
        'use strict'
        var forms = document.querySelectorAll('.needs-validation')
        Array.prototype.slice.call(forms)
            .forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    const password = document.getElementById('password');
                    const confirmPassword = document.getElementById('confirm_password');

                    if (password.value !== confirmPassword.value) {
                        confirmPassword.setCustomValidity('Las contraseñas no coinciden.');
                    } else {
                        confirmPassword.setCustomValidity('');
                    }

                    if (!form.checkValidity()) {
                        event.preventDefault()
                        event.stopPropagation()
                    }
                    form.classList.add('was-validated')
                }, false)
            })
    })()

    // Alternar visibilidad de contraseñas
    function setupPasswordToggle(inputId, toggleId) {
        document.getElementById(toggleId).addEventListener('click', function() {
            const input = document.getElementById(inputId);
            const icon = this.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('bi-eye-slash', 'bi-eye');
            } else {
                input.type = 'password';
                icon.classList.replace('bi-eye', 'bi-eye-slash');
            }
        });
    }

    setupPasswordToggle('password', 'togglePassword');
    setupPasswordToggle('confirm_password', 'toggleConfirmPassword');
</script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    <?php if (!empty($errorMsg)): ?>
    Swal.fire({
        icon: 'error',
        title: 'Error al enviar solicitud',
        text: '<?php echo addslashes($errorMsg); ?>',
        confirmButtonColor: '#003b8e'
    });
    <?php endif; ?>
</script>

</body>
</html>