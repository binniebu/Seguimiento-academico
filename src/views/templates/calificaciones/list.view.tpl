<?php
require_once __DIR__ . "/../../../dao/Dao.php";
require_once __DIR__ . "/../../../dao/Table.php";
require_once __DIR__ . "/../../../dao/CalificacionDao.php";

$partialName = trim($_GET["partialName"] ?? "");
$pageNum = max(0, intval($_GET["pageNum"] ?? 0));
$mensaje = $_GET["mensaje"] ?? "";

$resultado = \Dao\CalificacionDao::getCalificaciones($partialName, "", false, $pageNum, 10);
$calificaciones = $resultado["calificaciones"];
$total = intval($resultado["total"]);
$itemsPorPagina = intval($resultado["itemsPerPage"]);
$totalPaginas = max(1, (int) ceil($total / $itemsPorPagina));
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultar Calificaciones</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

            <main role="main" class="col-md-10 ml-sm-auto px-md-4">
                <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Consultar Calificaciones</h1>
                    <a href="index.php?page=Calificacion&mode=INS" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Registrar Nota
                    </a>
                </div>

                <?php if ($mensaje !== ""): ?>
                    <div class="alert alert-success"><?php echo htmlspecialchars($mensaje); ?></div>
                <?php endif; ?>

                <form action="index.php" method="get" class="row g-2 mb-3">
                    <input type="hidden" name="page" value="calificaciones">
                    <div class="col-md-8">
                        <input type="text" name="partialName" id="partialName" class="form-control"
                               value="<?php echo htmlspecialchars($partialName); ?>" placeholder="Buscar por estudiante o materia">
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <button type="submit" class="btn btn-outline-secondary">
                            <i class="bi bi-search"></i> Buscar
                        </button>
                        <a href="index.php?page=calificaciones" class="btn btn-outline-secondary">
                            <i class="bi bi-x-circle"></i>
                        </a>
                    </div>
                </form>

                <?php if (!empty($calificaciones)): ?>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Estudiante</th>
                                    <th>Materia</th>
                                    <th>Periodo</th>
                                    <th>Nota</th>
                                    <th>Observacion</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($calificaciones as $calificacion): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($calificacion["id_calificacion"]); ?></td>
                                        <td><?php echo htmlspecialchars($calificacion["nombre_estudiante"]); ?></td>
                                        <td><?php echo htmlspecialchars($calificacion["nombre_materia"]); ?></td>
                                        <td><?php echo htmlspecialchars($calificacion["periodo"]); ?></td>
                                        <td><strong><?php echo htmlspecialchars($calificacion["nota"]); ?>%</strong></td>
                                        <td><?php echo htmlspecialchars($calificacion["observacion"] ?? ""); ?></td>
                                        <td>
                                            <a href="index.php?page=Calificacion&mode=DSP&id_calificacion=<?php echo urlencode($calificacion["id_calificacion"]); ?>" class="btn btn-sm btn-secondary">Ver</a>
                                            <a href="index.php?page=Calificacion&mode=UPD&id_calificacion=<?php echo urlencode($calificacion["id_calificacion"]); ?>" class="btn btn-sm btn-warning">Editar</a>
                                            <a href="index.php?page=Calificacion&mode=DEL&id_calificacion=<?php echo urlencode($calificacion["id_calificacion"]); ?>" class="btn btn-sm btn-danger">Eliminar</a>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>

                    <nav aria-label="Paginacion de calificaciones">
                        <ul class="pagination">
                            <?php for ($i = 0; $i < $totalPaginas; $i++): ?>
                                <li class="page-item <?php echo $i === $pageNum ? "active" : ""; ?>">
                                    <a class="page-link" href="index.php?page=calificaciones&partialName=<?php echo urlencode($partialName); ?>&pageNum=<?php echo $i; ?>">
                                        <?php echo $i + 1; ?>
                                    </a>
                                </li>
                            <?php endfor; ?>
                        </ul>
                    </nav>
                <?php else: ?>
                    <div class="alert alert-info">
                        No hay calificaciones registradas. <a href="index.php?page=Calificacion&mode=INS">Registrar una nueva</a>
                    </div>
                <?php endif; ?>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
