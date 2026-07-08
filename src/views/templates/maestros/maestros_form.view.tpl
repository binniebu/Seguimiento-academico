<?php

require_once __DIR__ . "/../../../controllers/MaestrosController.php";

use Controllers\MaestrosController;

// -----------------------------------------------
// Detectar si estamos editando un Maestro o Coordinador
// -----------------------------------------------

$idMaestro = $_GET["id"] ?? null;
$idCoordinador = $_GET["id_coordinador"] ?? null;

$editando = false;
$tipo = "maestro"; // valor por defecto para el formulario nuevo
$registro = null;
$rolBloqueado = false;

if ($idMaestro) {

    $registro = MaestrosController::obtenerMaestro($idMaestro);
    $editando = true;
    $tipo = "maestro";

    if ($registro) {
        $rolBloqueado = MaestrosController::tieneClasesActivas($idMaestro);
    }

} elseif ($idCoordinador) {

    $registro = MaestrosController::obtenerCoordinador($idCoordinador);
    $editando = true;
    $tipo = "coordinador";
}

$facultades = MaestrosController::listarFacultades();

// Helper para no repetir htmlspecialchars() en cada campo
function val($valor)
{
    return htmlspecialchars($valor ?? "");
}

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <title><?= $editando ? "Editar" : "Nuevo" ?> Maestro / Coordinador</title>
</head>
<body class="bg-light p-5">

<div class="container">
    <h2 class="mb-4"><?= $editando ? "Editar" : "Registrar" ?> Maestro / Coordinador</h2>

    <form method="POST"
          action="index.php?page=<?= $editando ? "maestro_actualizar" : "maestro_guardar" ?>"
          class="p-4 border rounded shadow-sm bg-white">

        <?php if ($editando): ?>
            <input type="hidden" name="tipo" value="<?= val($tipo) ?>">
            <input type="hidden" name="id" value="<?= val($registro[$tipo === "maestro" ? "id_maestro" : "id_coordinador"]) ?>">
            <input type="hidden" name="id_usuario" value="<?= val($registro["id_usuario"]) ?>">
        <?php endif; ?>

        <div class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label">Nombre Completo</label>
                <input type="text" name="nombre" class="form-control"
                       value="<?= val($registro["nombre"] ?? "") ?>" required>
            </div>

        <div class="col-md-6 mb-3">
          <label class="form-label">DNI</label>
           <input type="text" name="dni" class="form-control"
           value="<?= val($registro["documento_dni"] ?? "") ?>" required>
        </div>

            <div class="col-md-6 mb-3">
                <label class="form-label">Correo Electrónico</label>
                <input type="email" name="correo" class="form-control"
                       value="<?= val($registro["correo"] ?? "") ?>" required>
            </div>

            <div class="col-md-6 mb-3">
                <label class="form-label">Teléfono</label>
                <input type="text" name="telefono" class="form-control"
                       value="<?= val($registro["telefono"] ?? "") ?>" required>
            </div>

            <div class="col-md-6 mb-3">
                <label class="form-label">Título Profesional</label>
                <input type="text" name="titulo" class="form-control"
                       value="<?= val($registro["titulo"] ?? "") ?>" required>
            </div>

            <div class="col-md-6 mb-3">
                <label class="form-label">
                    Contraseña
                    <?php if ($editando): ?>
                        <small class="text-muted">(dejar vacío para no cambiarla)</small>
                    <?php endif; ?>
                </label>
                <input type="password" name="password" class="form-control"
                    <?= $editando ? "" : "required" ?>>
            </div>

            <div class="col-md-12 mb-3">
                <label class="form-label">Rol de Usuario</label>
                <select name="rol" id="select_rol" class="form-select"
                        onchange="toggleFields()"
                    <?= ($editando && $rolBloqueado) ? "disabled" : "" ?>
                        required>
                    <option value="2" <?= $tipo === "maestro" ? "selected" : "" ?>>Maestro</option>
                    <option value="4" <?= $tipo === "coordinador" ? "selected" : "" ?>>Coordinador</option>
                </select>

                <?php if ($editando && $rolBloqueado): ?>
                    <small class="text-danger d-block mt-1">
                        El rol no se puede cambiar: este maestro tiene clases asignadas
                        en el periodo activo.
                    </small>
                    <!-- Si el select está disabled, el navegador NO envía su valor en el POST.
                         Este campo oculto asegura que el rol se siga enviando. -->
                    <input type="hidden" name="rol" value="<?= $tipo === "maestro" ? 2 : 4 ?>">
                <?php endif; ?>
            </div>
        </div>

        <div id="campos_maestro" class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label">Número de Empleado</label>
                <input type="text" name="numero_empleado" class="form-control"
                       value="<?= val($registro["numero_empleado"] ?? "") ?>">
            </div>
        </div>

        <div id="campos_coordinador" class="row" style="display:none;">
            <div class="col-md-6 mb-3">
                <label class="form-label">Facultad Asignada</label>
                <select name="id_facultad" class="form-select">
                    <?php foreach ($facultades as $f): ?>
                        <option value="<?= $f["id_facultad"] ?>"
                            <?= (isset($registro["id_facultad"]) && $registro["id_facultad"] == $f["id_facultad"]) ? "selected" : "" ?>>
                            <?= val($f["nombre_facultad"]) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100">
            <?= $editando ? "Guardar Cambios" : "Guardar Registro" ?>
        </button>

        <a href="index.php?page=maestros" class="btn btn-secondary w-100 mt-2">
            Cancelar
        </a>
    </form>
</div>

<script>
function toggleFields() {
    const rol = document.getElementById('select_rol').value;
    document.getElementById('campos_maestro').style.display = (rol == '2') ? 'flex' : 'none';
    document.getElementById('campos_coordinador').style.display = (rol == '4') ? 'flex' : 'none';
}

// Ejecutar al cargar la página, para que en modo edición
// se muestren los campos correctos según el rol actual
document.addEventListener('DOMContentLoaded', toggleFields);
</script>
</body>
</html>