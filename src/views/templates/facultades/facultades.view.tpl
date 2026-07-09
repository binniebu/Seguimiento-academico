<?php
require_once __DIR__ . "/../../../controllers/FacultadesController.php";
require_once __DIR__ . "/../../../dao/CarreraDao.php";

$facultades = \Controllers\FacultadesController::listar();
$todasLasCarreras = \Dao\CarreraDao::obtenerCarreras(); // Incluye c.id_facultad
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Facultades</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <!-- Main content -->
        <main role="main" class="col-md-10 ml-sm-auto px-md-4 py-4">
            <div class="main-content-card">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div class="d-flex align-items-center gap-3">
                        <button id="toggleSidebarHeader" class="btn btn-sm btn-outline-secondary toggleSidebarBtn">
                            <i class="bi bi-list"></i>
                        </button>
                        <h1 class="h2 page-title mb-0">Catálogo de Facultades</h1>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="index.php?page=facultad_nueva" class="btn btn-primary">
                            <i class="bi bi-plus-circle"></i> Nueva Facultad
                        </a>
                    </div>
                </div>

                <div class="alert alert-info border-0 shadow-sm mb-4">
                    <i class="bi bi-info-circle-fill me-2"></i> <strong>Aviso:</strong> Las facultades representan el nivel académico más alto de la institución. Por motivos de integridad y para evitar la pérdida de carreras y materias asociadas, <strong>no se permite eliminar o dar de baja</strong> facultades existentes. Si hay un error, puede editar el nombre.
                </div>

                <!-- Tabla de Facultades -->
                <?php if (!empty($facultades)): ?>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Nombre de la Facultad</th>
                                    <th class="text-center">Carreras Adscritas</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($facultades as $f): 
                                    $totalCarreras = intval($f['total_carreras'] ?? 0);
                                ?>
                                    <tr>
                                        <td class="fw-bold">
                                            <a href="#" class="text-decoration-none text-primary" data-bs-toggle="modal" data-bs-target="#modalFacultad<?php echo $f['id_facultad']; ?>" title="Ver carreras de esta facultad">
                                                <?php echo htmlspecialchars($f['nombre_facultad']); ?> <i class="bi bi-window ms-1 small"></i>
                                            </a>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-light text-dark border fw-bold" style="font-size: 13px;">
                                                <?php echo $totalCarreras; ?>
                                            </span>
                                        </td>
                                        <td class="actions-cell text-end">
                                            <a href="index.php?page=facultad_nueva&id=<?php echo $f['id_facultad']; ?>"
                                               class="btn btn-sm btn-warning">
                                                <i class="bi bi-pencil"></i> Editar Nombre
                                            </a>
                                        </td>
                                    </tr>
                                    
                                    <!-- Modal para listar carreras -->
                                    <div class="modal fade" id="modalFacultad<?php echo $f['id_facultad']; ?>" tabindex="-1" aria-labelledby="modalLabel<?php echo $f['id_facultad']; ?>" aria-hidden="true">
                                      <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content border-0 shadow">
                                          <div class="modal-header bg-light">
                                            <h5 class="modal-title text-primary" id="modalLabel<?php echo $f['id_facultad']; ?>">
                                                <i class="bi bi-building me-2"></i><?php echo htmlspecialchars($f['nombre_facultad']); ?>
                                            </h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                          </div>
                                          <div class="modal-body">
                                            <h6 class="text-muted mb-3">Carreras Adscritas:</h6>
                                            <?php 
                                            $carrerasFacultad = array_filter($todasLasCarreras, function($c) use ($f) {
                                                return $c['id_facultad'] == $f['id_facultad'];
                                            });
                                            if (empty($carrerasFacultad)): ?>
                                                <div class="alert alert-secondary border-0 text-center py-4 mb-0">
                                                    <i class="bi bi-inbox fs-3 d-block mb-2 text-muted"></i>
                                                    No hay carreras adscritas a esta facultad actualmente.
                                                </div>
                                            <?php else: ?>
                                                <div class="list-group list-group-flush border rounded">
                                                <?php foreach ($carrerasFacultad as $cf): ?>
                                                    <div class="list-group-item d-flex justify-content-between align-items-center">
                                                        <span class="fw-medium text-dark"><?php echo htmlspecialchars($cf['nombre_carrera']); ?></span>
                                                        <a href="index.php?page=carrera_flujograma&id=<?php echo $cf['id_carrera']; ?>" class="btn btn-sm btn-outline-primary rounded-pill" title="Ver Flujograma">
                                                            <i class="bi bi-diagram-3 me-1"></i> Flujograma
                                                        </a>
                                                    </div>
                                                <?php endforeach; ?>
                                                </div>
                                            <?php endif; ?>
                                          </div>
                                          <div class="modal-footer border-top-0 pt-0">
                                            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cerrar</button>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                    
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php else: ?>
                    <div class="alert alert-warning">
                        No hay facultades registradas en el sistema. <a href="index.php?page=facultad_nueva" class="alert-link">Registrar la primera</a>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// El control de sidebar lo maneja de forma robusta public/js/sidebar.js cargado en sidebar.view.tpl
</script>
</body>
</html>
