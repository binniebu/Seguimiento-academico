<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <title>Nuevo Maestro</title>
</head>
<body class="bg-light p-5">

<div class="container">
    <h2 class="mb-4">Registrar Maestro / Coordinador</h2>
    <form method="POST" action="index.php?page=maestro_guardar" class="p-4 border rounded shadow-sm bg-white">
        <div class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label">Nombre Completo</label>
                <input type="text" name="nombre" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label">DNI</label>
                <input type="text" name="dni" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label">Correo Electrónico</label>
                <input type="email" name="correo" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label">Teléfono</label>
                <input type="text" name="telefono" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label">Título Profesional</label>
                <input type="text" name="titulo" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <div class="col-md-12 mb-3">
                <label class="form-label">Rol de Usuario</label>
                <select name="rol" id="select_rol" class="form-select" onchange="toggleFields()" required>
                    <option value="2">Maestro</option>
                    <option value="4">Coordinador</option>
                </select>
            </div>
        </div>

        <div id="campos_maestro" class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label">Número de Empleado</label>
                <input type="text" name="numero_empleado" class="form-control">
            </div>
        </div>

        <div id="campos_coordinador" class="row" style="display:none;">
            <div class="col-md-6 mb-3">
                <label class="form-label">Facultad Asignada</label>
                <select name="id_facultad" class="form-select">
                    <option value="1">Facultad de Ingeniería</option>
                    <option value="2">Facultad de Ciencias de la Salud</option>
                    <option value="3">Facultad de Ciencias Económicas</option>
                </select>
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100">Guardar Registro</button>
    </form>
</div>

<script>
function toggleFields() {
    const rol = document.getElementById('select_rol').value;
    document.getElementById('campos_maestro').style.display = (rol == '2') ? 'flex' : 'none';
    document.getElementById('campos_coordinador').style.display = (rol == '4') ? 'flex' : 'none';
}
</script>
</body>
</html>