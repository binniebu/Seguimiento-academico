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

                <!-- Cuadrícula de Accesos Rápidos (Tarjetas Dashboard) -->
                <div class="row">
                    <?php if ($_SESSION["rol"] === "director"): ?>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Estudiantes</h5>
                                <p class="text-muted small">Administración completa y consulta de estudiantes registrados.</p>
                                <a href="index.php?page=estudiantes" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Maestros</h5>
                                <p class="text-muted small">Registro y control de personal docente.</p>
                                <a href="index.php?page=maestros" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Carreras</h5>
                                <p class="text-muted small">Configuración de carreras universitarias y facultades.</p>
                                <a href="index.php?page=carreras" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Solicitudes</h5>
                                <p class="text-muted small">Aprobación de pre-registros y consulta de documentos PDF.</p>
                                <a href="index.php?page=solicitudes_registro" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                    <?php endif; ?>

                    <?php if (in_array($_SESSION["rol"], ["director", "maestro"])): ?>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Materias</h5>
                                <p class="text-muted small">Gestión y control de asignaturas académicas.</p>
                                <a href="index.php?page=materias" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Secciones</h5>
                                <p class="text-muted small">Horarios, aulas y cupos disponibles por asignatura.</p>
                                <a href="index.php?page=secciones" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Matrículas</h5>
                                <p class="text-muted small">Control e inscripción de asignaturas por estudiantes.</p>
                                <a href="index.php?page=matriculas" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                    <?php endif; ?>

                    <div class="col-md-4 mb-4">
                        <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                            <h5 class="fw-bold">Calificaciones</h5>
                            <p class="text-muted small">Registro y visualización de notas de estudiantes.</p>
                            <a href="index.php?page=calificaciones" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                        </div>
                    </div>

                    <?php if ($_SESSION["rol"] === "estudiante"): ?>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Mis Materias</h5>
                                <p class="text-muted small">Consulta e inscripción a asignaturas del período.</p>
                                <a href="index.php?page=mis_materias" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Historial Académico</h5>
                                <p class="text-muted small">Visualización de notas históricas e índices académicos.</p>
                                <a href="index.php?page=historial_academico" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                    <?php endif; ?>

                    <?php if ($_SESSION["rol"] === "director"): ?>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Usuarios</h5>
                                <p class="text-muted small">Control de credenciales, accesos y perfiles.</p>
                                <a href="index.php?page=usuarios" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 h-100 p-3 shadow-sm" style="background-color: #f8fafc; border-radius: 12px;">
                                <h5 class="fw-bold">Reportes</h5>
                                <p class="text-muted small">Estadísticas e informes académicos globales.</p>
                                <a href="index.php?page=reportes" class="btn btn-sm btn-primary mt-auto align-self-start">Ingresar</a>
                            </div>
                        </div>
                    <?php endif; ?>
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