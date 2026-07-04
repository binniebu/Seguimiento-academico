<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Seguimiento Académico</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Barra Lateral de Navegación (Sidebar) -->
        <?php require_once __DIR__ . "/sidebar.view.tpl"; ?>


        <!-- Panel de Contenido Principal -->
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <!-- Saludo y selector de perfiles para multirrol -->
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <div>
                            <h1 class="h2 page-title mb-0">Bienvenido, <?php echo htmlspecialchars($_SESSION["usuario"] ?? ''); ?></h1>
                        </div>
                    </div>
                        <p class="text-muted mb-0" style="font-size: 14px;">Rol de sesión actual: <strong><?php echo ucfirst(htmlspecialchars($_SESSION["rol"] ?? '')); ?></strong></p>
                    </div>

                    <?php
                    require_once __DIR__ . "/../../dao/UsuarioDao.php";
                    $rolesDisponibles = \Dao\UsuarioDao::obtenerRolesPorCorreo($_SESSION["correo"] ?? "");
                    if (count($rolesDisponibles) > 1):
                    ?>
                        <div class="d-flex align-items-center gap-2">
                            <label class="form-label mb-0 text-muted" style="font-size: 13px;">Cambiar de vista:</label>
                            <select onchange="window.location='index.php?page=switch_role&rol=' + this.value" class="form-select form-select-sm w-auto">
                                <?php foreach ($rolesDisponibles as $r): ?>
                                    <option value="<?php echo htmlspecialchars($r); ?>" <?php echo $r === $_SESSION["rol"] ? "selected" : ""; ?>>
                                        <?php echo ucfirst(htmlspecialchars($r)); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    <?php endif; ?>
                </div>

                <!-- Cuadrícula de Accesos Rápidos (Removida por solicitud del usuario) -->
                <div class="my-5 py-5 text-center">
                    <p class="text-muted">Espacio reservado para el Dashboard de cada Rol. El integrante asignado maquetará las métricas aquí.</p>
                </div>

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