<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

session_start();

// Include RoleMiddleware for access control
require_once __DIR__ . "/src/utilities/RoleMiddleware.php";
 require_once __DIR__ . "/src/dao/UsuarioDao.php";
        require_once __DIR__ . "/src/dao/EstudianteDao.php";
        require_once __DIR__ . "/src/dao/MisMateriasDao.php";


$page = $_GET["page"] ?? "login";

// Check access control for all pages except login and register
if ($page !== "login" && $page !== "register") {
    \Utilities\RoleMiddleware::checkAccess($page);
}

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

            header("Location: index.php?page=home");
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
        
        // Validar que solo pueda existir un Director en el sistema
          if (intval($rol) === 1 && \Dao\UsuarioDao::existeDirector()) {
           echo "<script>
            alert('Ya existe un Director registrado. No se puede crear otro Director.');
            window.location='index.php?page=register';
          </script>";
            exit();
         }
        $existe = \Dao\UsuarioDao::existeCorreo($correo);

        if ($existe) {
            echo "<script>alert('Este correo ya está registrado'); window.location='index.php?page=register';</script>";
            exit();
        }

        $idUsuario = \Dao\UsuarioDao::registrarUsuario($nombre, $correo, $password, $rol);

         if (intval($rol) === 3) {
         $cuenta = "EST-" . str_pad($idUsuario, 3, "0", STR_PAD_LEFT);
          $carrera = "Sin asignar";
          $telefono = "";

              \Dao\UsuarioDao::registrarEstudianteDesdeUsuario(
              $idUsuario,
              $cuenta,
              $carrera,
              $telefono
    );
}

echo "<script>alert('Usuario registrado correctamente'); window.location='index.php?page=login';</script>";
exit();
    }

    require_once __DIR__ . "/src/views/templates/auth/register.view.tpl";
    break;

    case "logout":
        session_destroy();
        header("Location: index.php?page=login");
        exit();
    case "actualizar_carrera":

    \Dao\EstudianteDao::actualizarCarreraPorCorreo(
        $_SESSION["correo"],
        $_POST["carrera"]
    );

    header("Location: index.php?page=mis_materias");
    exit();

break;    

     // Home
    case "home":
        require_once __DIR__ . "/src/views/templates/home.view.tpl";
        break;

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

    case "estudiante_guardar":
        require_once __DIR__ . "/src/controllers/EstudiantesController.php";
        \Controllers\EstudiantesController::guardar();
        break;

    // Maestros
    
    case "maestros":
    require_once __DIR__ . "/src/views/templates/maestros/maestros.view.tpl";
    break;

case "maestro_nuevo":
    require_once __DIR__ . "/src/views/templates/maestros/maestros_form.view.tpl";
    break;

case "maestro_guardar":
    require_once __DIR__ . "/src/controllers/MaestrosController.php";
    \Controllers\MaestrosController::guardar();
    break;
    
    //matriculas
    case "matriculas":
    include_once "src/views/templates/matriculas/matriculas.view.tpl";
    break;

    case "matricula_nueva":
    include_once "src/views/templates/matriculas/matriculas_form.view.tpl";
    break;
    
    // Materias
    case "materias":
        require_once __DIR__ . "/src/views/templates/materias/materias.view.tpl";
        break;
        
    case "mis_materias":
    require_once __DIR__ . "/src/views/templates/estudiantes/mis_materias.view.tpl";
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
    // Usuarios
    case "usuarios":
        require_once __DIR__ . "/src/views/templates/usuarios/users.view.tpl";
        break;

    case "usuario_nuevo":
        require_once __DIR__ . "/src/views/templates/usuarios/user.view.tpl";
        break;   

    // --- Nuevas Rutas de Reingeniería ---
    
    // Gestión de Carreras
    case "carreras":
        require_once __DIR__ . "/src/views/templates/carreras/carreras.view.tpl";
        break;
    case "carrera_nueva":
        require_once __DIR__ . "/src/views/templates/carreras/carreras_form.view.tpl";
        break;
    case "carrera_guardar":
        require_once __DIR__ . "/src/controllers/CarrerasController.php";
        \Controllers\CarrerasController::guardar();
        break;

    // Gestión de Secciones
    case "secciones":
        require_once __DIR__ . "/src/views/templates/materias/secciones.view.tpl";
        break;
    case "seccion_nueva":
        require_once __DIR__ . "/src/views/templates/materias/secciones_form.view.tpl";
        break;
    case "seccion_guardar":
        require_once __DIR__ . "/src/controllers/MateriasController.php";
        \Controllers\MateriasController::guardarSeccion();
        break;

    // Gestión de Pre-registro y Admisiones
    case "solicitudes_registro":
        require_once __DIR__ . "/src/views/templates/usuarios/solicitudes.view.tpl";
        break;
    case "solicitud_detalle":
        require_once __DIR__ . "/src/views/templates/usuarios/solicitud.view.tpl";
        break;
    case "solicitud_procesar":
        require_once __DIR__ . "/src/controllers/UsuariosController.php";
        \Controllers\UsuariosController::procesarSolicitud();
        break;

    // Historial Académico
    case "historial_academico":
        require_once __DIR__ . "/src/views/templates/estudiantes/historial.view.tpl";
        break;

    // Conmutador de Roles (Switch Role)
    case "switch_role":
        $nuevoRol = $_GET["rol"] ?? "";
        if (isset($_SESSION["usuario"]) && isset($_SESSION["correo"])) {
            require_once __DIR__ . "/src/dao/UsuarioDao.php";
            $rolesUsuario = \Dao\UsuarioDao::obtenerRolesPorCorreo($_SESSION["correo"]);
            if (in_array($nuevoRol, $rolesUsuario)) {
                $_SESSION["rol"] = $nuevoRol;
                header("Location: index.php?page=home");
                exit();
            }
        }
        header("Location: index.php?page=home&mensaje=Rol invalido o no asignado");
        exit();



    // Página no encontrada
    default:
        echo "<h1>Página no encontrada</h1>";
        echo "<a href='index.php?page=login'>Volver al login</a>";
        break;
}
?>