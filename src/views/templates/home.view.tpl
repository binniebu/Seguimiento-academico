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
        <nav class="col-md-2 d-md-block bg-light sidebar">
            <div class="sidebar-sticky pt-3">
                <div class="d-flex justify-content-between align-items-center px-3 mt-4 mb-2">
                    <h6 class="sidebar-heading p-0 m-0 text-muted">Menu</h6>
                    <button class="btn btn-sm text-white p-0 toggleSidebarBtn" style="font-size: 16px; border: none; background: transparent;">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a class="nav-link active" href="index.php?page=home">
                            <i class="bi bi-house-fill"></i> Home
                        </a>
                    </li>
                    <?php if ($_SESSION["rol"] === "director"): ?>
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
                            <a class="nav-link" href="index.php?page=carreras">
                                <i class="bi bi-tags"></i> Carreras
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=solicitudes_registro">
                                <i class="bi bi-clipboard-check"></i> Solicitudes
                            </a>
                        </li>
                    <?php endif; ?>
                    <?php if (in_array($_SESSION["rol"], ["director", "maestro"])): ?>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=materias">
                                <i class="bi bi-book"></i> Materias
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=secciones">
                                <i class="bi bi-calendar-event"></i> Secciones
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=matriculas">
                                <i class="bi bi-card-checklist"></i> Matrículas
                            </a>
                        </li>
                    <?php endif; ?>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?page=calificaciones">
                            <i class="bi bi-graph-up"></i> Calificaciones
                        </a>
                    </li>
                    <?php if ($_SESSION["rol"] === "estudiante"): ?>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=mis_materias">
                                <i class="bi bi-journal-bookmark"></i> Mis Materias
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=historial_academico">
                                <i class="bi bi-file-earmark-text"></i> Historial
                            </a>
                        </li>
                    <?php endif; ?>
                    <?php if ($_SESSION["rol"] === "director"): ?>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=usuarios">
                                <i class="bi bi-person-gear"></i> Usuarios
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="index.php?page=reportes">
                                <i class="bi bi-file-bar-graph"></i> Reportes
                            </a>
                        </li>
                    <?php endif; ?>
                    <li class="nav-item">
                        <a class="nav-link text-danger" href="index.php?page=logout">
                            <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                        </a>
                    </li>
                </ul>
            </div>
        </nav>

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