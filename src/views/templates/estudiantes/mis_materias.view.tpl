<?php
require_once __DIR__ . "/../../../dao/MisMateriasDao.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$correo = $_SESSION["correo"] ?? "";
$estudiante = \Dao\MisMateriasDao::obtenerEstudiantePorCorreo($correo);

if (!$estudiante) {
    echo "<h3>No se encontró el estudiante relacionado con este usuario.</h3>";
    exit();
}

$idEstudiante = $estudiante["id_estudiante"];


if ($estudiante["carrera"] == "Sin asignar") {
?>
<div class="container mt-4">
    <div class="card">
        <div class="card-header bg-primary text-white">
            Seleccione su carrera
        </div>

        <div class="card-body">
            <p>Antes de continuar con su matrícula debe seleccionar la carrera a la que pertenece.</p>

            <form method="POST" action="index.php?page=actualizar_carrera">

                <div class="mb-3">
                    <label class="form-label">Carrera</label>

                    <select name="carrera" class="form-control" required>
                        <option value="">Seleccione una carrera</option>
                        <option value="Ingeniería en Sistemas">Ingeniería en Sistemas</option>
                        <option value="Administración de Empresas">Administración de Empresas</option>
                        <option value="Derecho">Derecho</option>
                        <option value="Enfermería">Enfermería</option>
                        <option value="Psicología">Psicología</option>
                        <option value="Contaduría">Contaduría</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-success">
                    Guardar Carrera
                </button>

            </form>
        </div>
    </div>
</div>

<?php
    exit();
}

if (($_GET["accion"] ?? "") === "inscribir" && isset($_GET["id_materia"])) {
    \Dao\MisMateriasDao::inscribirMateria($idEstudiante, intval($_GET["id_materia"]));
    header("Location: index.php?page=mis_materias");
    exit();
}

if (($_GET["accion"] ?? "") === "eliminar" && isset($_GET["id_matricula"])) {
    \Dao\MisMateriasDao::eliminarMateria(intval($_GET["id_matricula"]), $idEstudiante);
    header("Location: index.php?page=mis_materias");
    exit();
}

$inscritas = \Dao\MisMateriasDao::obtenerMateriasInscritas($idEstudiante);
$disponibles = \Dao\MisMateriasDao::obtenerMateriasDisponibles($idEstudiante);
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mis Materias</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">

        <?php require_once __DIR__ . "/../sidebar.view.tpl"; ?>

        <main class="col-md-10 ml-sm-auto px-md-4">
            <div class="d-flex justify-content-between align-items-center pt-3 pb-2 mb-3 border-bottom">
                <div>
                    <h1 class="h2">Mi Matrícula</h1>
                    <p class="text-muted mb-0">
                        Estudiante: <?php echo htmlspecialchars($estudiante["nombre"]); ?>
                    </p>
                </div>
            </div>

            <h4>Materias Inscritas</h4>

            <div class="table-responsive mb-5">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Código</th>
                            <th>Materia</th>
                            <th>Periodo</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php if (!empty($inscritas)): ?>
                        <?php foreach ($inscritas as $m): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($m["id_matricula"]); ?></td>
                                <td><?php echo htmlspecialchars($m["codigo"]); ?></td>
                                <td><?php echo htmlspecialchars($m["nombre"]); ?></td>
                                <td><?php echo htmlspecialchars($m["periodo"]); ?></td>
                                <td><span class="badge bg-success"><?php echo htmlspecialchars($m["estado"]); ?></span></td>
                                <td>
                                    <a href="index.php?page=mis_materias&accion=eliminar&id_matricula=<?php echo $m["id_matricula"]; ?>"
                                       class="btn btn-sm btn-danger"
                                       onclick="return confirm('¿Deseas eliminar esta materia de tu matrícula?');">
                                        <i class="bi bi-trash"></i> Eliminar
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="6" class="text-center text-muted">No tienes materias inscritas.</td>
                        </tr>
                    <?php endif; ?>
                    </tbody>
                </table>
            </div>

            <h4>Materias Disponibles</h4>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Código</th>
                            <th>Materia</th>
                            <th>Descripción</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php if (!empty($disponibles)): ?>
                        <?php foreach ($disponibles as $m): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($m["codigo"]); ?></td>
                                <td><?php echo htmlspecialchars($m["nombre"]); ?></td>
                                <td><?php echo htmlspecialchars($m["descripcion"] ?? ""); ?></td>
                                <td>
                                    <a href="index.php?page=mis_materias&accion=inscribir&id_materia=<?php echo $m["id_materia"]; ?>"
                                       class="btn btn-sm btn-primary"
                                       onclick="return confirm('¿Deseas agregar esta materia?');">
                                        <i class="bi bi-plus-circle"></i> Agregar
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="4" class="text-center text-muted">No hay materias disponibles.</td>
                        </tr>
                    <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</div>
</body>
</html>