<?php
$currentPage = $_GET['page'] ?? 'home';
?>
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
                <a class="nav-link <?php echo $currentPage === 'home' ? 'active' : ''; ?>" href="index.php?page=home">
                    <i class="bi bi-house-fill"></i> Inicio
                </a>
            </li>

            <?php if (in_array($_SESSION["rol"], ["director", "coordinador"])): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'estudiantes' ? 'active' : ''; ?>" href="index.php?page=estudiantes">
                        <i class="bi bi-people"></i> Estudiantes
                    </a>
                </li>
            <?php endif; ?>

            <?php if ($_SESSION["rol"] === "director"): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'maestros' ? 'active' : ''; ?>" href="index.php?page=maestros">
                        <i class="bi bi-people-fill"></i> Personal
                    </a>
                </li>
            <?php endif; ?>



            <?php if ($_SESSION["rol"] === "maestro"): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo in_array($currentPage, ['secciones','notas_maestro']) ? 'active' : ''; ?>" href="index.php?page=secciones">
                        <i class="bi bi-calendar-event"></i> Mis Secciones
                    </a>
                </li>
            <?php endif; ?>

            <?php if ($_SESSION["rol"] === "estudiante"): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'mis_materias' ? 'active' : ''; ?>" href="index.php?page=mis_materias">
                        <i class="bi bi-journal-bookmark"></i> Mis Materias
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'mi_flujograma' ? 'active' : ''; ?>" href="index.php?page=mi_flujograma">
                        <i class="bi bi-diagram-3"></i> Mi Flujograma
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'historial_academico' ? 'active' : ''; ?>" href="index.php?page=historial_academico">
                        <i class="bi bi-file-earmark-text"></i> Historial
                    </a>
                </li>
                <?php
                require_once __DIR__ . "/../../controllers/MatriculasController.php";
                if (\Controllers\MatriculasController::esPeriodoMatriculaActivo()):
                ?>
                    <li class="nav-item">
                        <a class="nav-link <?php echo $currentPage === 'matricula_estudiante' ? 'active' : ''; ?>" href="index.php?page=matricula_estudiante">
                            <i class="bi bi-bookmark-plus-fill"></i> Matricular Clases
                        </a>
                    </li>
                <?php endif; ?>
            <?php endif; ?>

            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'perfil' ? 'active' : ''; ?>" href="index.php?page=perfil">
                    <i class="bi bi-person-circle"></i> Mi Perfil
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-danger" href="index.php?page=logout">
                    <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                </a>
            </li>
        </ul>
    </div>
</nav>
<!-- Script centralizado del sidebar — se carga una sola vez para todos los templates -->
<script src="public/js/sidebar.js"></script>
