<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

session_start();

$page = $_GET["page"] ?? "login";

switch ($page) {

    // Autenticación
    case "login":
    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        require_once __DIR__ . "/src/dao/UsuarioDao.php";

        $correo = $_POST["correo"];
        $password = $_POST["password"];

        $usuario = \Dao\UsuarioDao::obtenerUsuarioPorCorreo($correo);

        if ($usuario && password_verify($password, $usuario["password"])) {
            $_SESSION["usuario"] = $usuario["nombre"];
            $_SESSION["correo"] = $usuario["correo"];
            $_SESSION["rol"] = $usuario["nombre_rol"];

            header("Location: index.php?page=dashboard");
            exit();
        } else {
            echo "<script>alert('Correo o contraseña incorrectos'); window.location='index.php?page=login';</script>";
            exit();
        }
    }

    require_once __DIR__ . "/src/views/templates/auth/login.view.tpl";
    break;

    case "register":
    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        require_once __DIR__ . "/src/dao/UsuarioDao.php";

        $nombre = $_POST["nombre"];
        $correo = $_POST["correo"];
        $password = $_POST["password"];
        $rol = $_POST["rol"];

        $existe = \Dao\UsuarioDao::existeCorreo($correo);

        if ($existe) {
            echo "<script>alert('Este correo ya está registrado'); window.location='index.php?page=register';</script>";
            exit();
        }

        \Dao\UsuarioDao::registrarUsuario($nombre, $correo, $password, $rol);

        echo "<script>alert('Usuario registrado correctamente'); window.location='index.php?page=login';</script>";
        exit();
    }

    require_once __DIR__ . "/src/views/templates/auth/register.view.tpl";
    break;

    case "logout":
        session_destroy();
        header("Location: index.php?page=login");
        exit();

    // Dashboard
    case "dashboard":
        require_once __DIR__ . "/src/views/templates/dashboard/dashboard.view.tpl";
        break;

    // Estudiantes
    case "estudiantes":
        require_once __DIR__ . "/src/views/templates/estudiantes/estudiantes.view.tpl";
        break;

    case "estudiante_nuevo":
        require_once __DIR__ . "/src/views/templates/estudiantes/estudiante_nuevo.view.tpl";
        break;

    // Maestros
    case "maestros":
        require_once __DIR__ . "/src/views/templates/maestros/maestros.view.tpl";
        break;

    case "maestro_nuevo":
        require_once __DIR__ . "/src/views/templates/maestros/maestro_nuevo.view.tpl";
        break;

    // Materias
    case "materias":
        require_once __DIR__ . "/src/views/templates/materias/materias.view.tpl";
        break;

    case "materia_nueva":
        require_once __DIR__ . "/src/views/templates/materias/materias_form.view.tpl";
        break;

    // Calificaciones
    case "calificaciones":
    case "Calificaciones":
        require_once __DIR__. "/src/views/templates/calificaciones/list.view.tpl";
        break;

    case "calificacion_nueva":
    case "Calificacion":
        require_once __DIR__ . "/src/views/templates/calificaciones/form.view.tpl";
        break;

    // Reportes
    case "reportes":
        require_once __DIR__ . "/src/views/templates/reportes/reportes.view.tpl";
        break;

    // Página no encontrada
    default:
        echo "<h1>Página no encontrada</h1>";
        echo "<a href='index.php?page=login'>Volver al login</a>";
        break;
}
?>
