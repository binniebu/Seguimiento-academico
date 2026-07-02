<?php
require_once __DIR__ . "/../../../dao/Dao.php";
require_once __DIR__ . "/../../../dao/Table.php";
require_once __DIR__ . "/../../../dao/CalificacionDao.php";

$mode = $_GET["mode"] ?? "INS";
$idCalificacion = intval($_GET["id_calificacion"] ?? 0);
$error = "";
$readonly = in_array($mode, ["DSP", "DEL"], true);
$calificacion = [
    "id_calificacion" => 0,
    "id_matricula" => 0,
    "nota" => "",
    "observacion" => ""
];

$titulos = [
    "DSP" => "Detalle de Calificacion",
    "INS" => "Registrar Nota",
    "UPD" => "Editar Nota",
    "DEL" => "Eliminar Nota"
];

if (!isset($titulos[$mode])) {
    header("Location: index.php?page=calificaciones&mensaje=Modo invalido");
    exit();
}

if ($mode !== "INS") {
    $registro = \Dao\CalificacionDao::getCalificacionById($idCalificacion);
    if (!$registro) {
        header("Location: index.php?page=calificaciones&mensaje=Calificacion no encontrada");
        exit();
    }
    $calificacion = $registro;
}

if ($_SERVER["REQUEST_METHOD"] === "POST" && $mode !== "DSP") {
    $calificacion["id_calificacion"] = intval($_POST["id_calificacion"] ?? $idCalificacion);
    $calificacion["id_matricula"] = intval($_POST["id_matricula"] ?? 0);
    $calificacion["nota"] = floatval($_POST["nota"] ?? 0);
    $calificacion["observacion"] = trim($_POST["observacion"] ?? "");

    if ($calificacion["id_matricula"] <= 0) {
        $error = "Debe seleccionar una matricula.";
    } elseif ($calificacion["nota"] < 0 || $calificacion["nota"] > 100) {
        $error = "La nota debe estar entre 0 y 100.";
    } else {
        try {
            if ($mode === "INS") {
                \Dao\CalificacionDao::insertCalificacion(
                    $calificacion["id_matricula"],
                    $calificacion["nota"],
                    $calificacion["observacion"]
                );
                header("Location: index.php?page=calificaciones&mensaje=Nota registrada correctamente");
                exit();
            }

            if ($mode === "UPD") {
                \Dao\CalificacionDao::updateCalificacion(
                    $idCalificacion,
                    $calificacion["id_matricula"],
                    $calificacion["nota"],
                    $calificacion["observacion"]
                );
                header("Location: index.php?page=calificaciones&mensaje=Nota actualizada correctamente");
                exit();
            }

            if ($mode === "DEL") {
                \Dao\CalificacionDao::deleteCalificacion($idCalificacion);
                header("Location: index.php?page=calificaciones&mensaje=Nota eliminada correctamente");
                exit();
            }
        } catch (Throwable $ex) {
            $error = "No se pudo guardar la calificacion. Revise los datos ingresados.";
        }
    }
}

$matriculas = \Dao\CalificacionDao::getMatriculasDisponibles();
$titulo = $titulos[$mode];
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($titulo); ?></title>
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
                    <h1 class="h2"><?php echo htmlspecialchars($titulo); ?></h1>
                    <a href="index.php?page=calificaciones" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <?php if ($error !== ""): ?>
                    <div class="alert alert-danger"><?php echo htmlspecialchars($error); ?></div>
                <?php endif; ?>

                <?php if ($mode === "DEL"): ?>
                    <div class="alert alert-warning">Confirme que desea eliminar esta calificacion.</div>
                <?php endif; ?>

                <form action="index.php?page=Calificacion&mode=<?php echo urlencode($mode); ?>&id_calificacion=<?php echo urlencode($idCalificacion); ?>" method="post" class="row g-3">
                    <input type="hidden" name="id_calificacion" value="<?php echo htmlspecialchars($calificacion["id_calificacion"]); ?>">

                    <div class="col-md-6">
                        <label class="form-label" for="id_matricula">Estudiante / Clase</label>
                        <select class="form-select" name="id_matricula" id="id_matricula" <?php echo $readonly ? "disabled" : ""; ?> required>
                            <option value="0">Seleccione una matricula</option>
                            <?php foreach ($matriculas as $matricula): ?>
                                <option value="<?php echo htmlspecialchars($matricula["id_matricula"]); ?>" <?php echo intval($matricula["id_matricula"]) === intval($calificacion["id_matricula"]) ? "selected" : ""; ?>>
                                    <?php echo htmlspecialchars($matricula["nombre_estudiante"] . " - " . $matricula["nombre_materia"] . " (" . $matricula["periodo"] . ")"); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                        <?php if ($readonly): ?>
                            <input type="hidden" name="id_matricula" value="<?php echo htmlspecialchars($calificacion["id_matricula"]); ?>">
                        <?php endif; ?>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label" for="nota">Nota Obtenida</label>
                        <input class="form-control" type="number" step="0.01" id="nota" name="nota"
                               value="<?php echo htmlspecialchars($calificacion["nota"]); ?>" min="0" max="100" <?php echo $readonly ? "readonly" : ""; ?> required>
                    </div>

                    <div class="col-12">
                        <label class="form-label" for="observacion">Observacion</label>
                        <input class="form-control" type="text" id="observacion" name="observacion"
                               value="<?php echo htmlspecialchars($calificacion["observacion"] ?? ""); ?>" <?php echo $readonly ? "readonly" : ""; ?>>
                    </div>

                    <div class="col-12 d-flex gap-2">
                        <?php if ($mode !== "DSP"): ?>
                            <button type="submit" class="btn <?php echo $mode === "DEL" ? "btn-danger" : "btn-primary"; ?>">
                                <i class="bi bi-save"></i> <?php echo $mode === "DEL" ? "Eliminar" : "Guardar"; ?>
                            </button>
                        <?php endif; ?>
                        <a href="index.php?page=calificaciones" class="btn btn-outline-secondary">Cancelar</a>
                    </div>
                </form>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
