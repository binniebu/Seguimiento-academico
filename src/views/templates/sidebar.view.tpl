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
                    <i class="bi bi-house-fill"></i> Home
                </a>
            </li>
            <?php if ($_SESSION["rol"] === "director"): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'estudiantes' ? 'active' : ''; ?>" href="index.php?page=estudiantes">
                        <i class="bi bi-people"></i> Estudiantes
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'maestros' ? 'active' : ''; ?>" href="index.php?page=maestros">
                        <i class="bi bi-person-badge"></i> Maestros
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'carreras' ? 'active' : ''; ?>" href="index.php?page=carreras">
                        <i class="bi bi-tags"></i> Carreras
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'solicitudes_registro' ? 'active' : ''; ?>" href="index.php?page=solicitudes_registro">
                        <i class="bi bi-clipboard-check"></i> Solicitudes
                    </a>
                </li>
            <?php endif; ?>
            <?php if (in_array($_SESSION["rol"], ["director", "maestro"])): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'materias' ? 'active' : ''; ?>" href="index.php?page=materias">
                        <i class="bi bi-book"></i> Materias
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'secciones' ? 'active' : ''; ?>" href="index.php?page=secciones">
                        <i class="bi bi-calendar-event"></i> Secciones
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'matriculas' ? 'active' : ''; ?>" href="index.php?page=matriculas">
                        <i class="bi bi-card-checklist"></i> Matrículas
                    </a>
                </li>
            <?php endif; ?>
            <?php if (in_array($_SESSION["rol"], ["maestro", "estudiante"])): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'calificaciones' ? 'active' : ''; ?>" href="index.php?page=calificaciones">
                        <i class="bi bi-graph-up"></i> Calificaciones
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
                    <a class="nav-link <?php echo $currentPage === 'historial_academico' ? 'active' : ''; ?>" href="index.php?page=historial_academico">
                        <i class="bi bi-file-earmark-text"></i> Historial
                    </a>
                </li>
            <?php endif; ?>
            <?php if ($_SESSION["rol"] === "director"): ?>
                <li class="nav-item">
                    <a class="nav-link <?php echo $currentPage === 'usuarios' ? 'active' : ''; ?>" href="index.php?page=usuarios">
                        <i class="bi bi-person-gear"></i> Usuarios
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
