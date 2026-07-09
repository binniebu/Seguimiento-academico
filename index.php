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
if (!in_array($page, ["login", "register"], true)) {
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
            $_SESSION["id_usuario"] = $usuario["id_usuario"];
            $_SESSION["usuario"] = $usuario["nombre"];
            $_SESSION["correo"] = $usuario["correo"];
            $_SESSION["rol"] = $usuario["nombre_rol"];

            if ($usuario["nombre_rol"] === "coordinador") {
                $_SESSION["id_facultad"] = \Dao\UsuarioDao::obtenerFacultadCoordinador($usuario["id_usuario"]);
                unset($_SESSION["id_carrera"]);
            } elseif ($usuario["nombre_rol"] === "estudiante") {
                require_once __DIR__ . "/src/dao/EstudianteDao.php";
                $carreraData = \Dao\EstudianteDao::obtenerCarreraIdPorUsuario($usuario["id_usuario"]);
                $_SESSION["id_carrera"] = $carreraData["id_carrera"] ?? null;
                $_SESSION["id_facultad"] = $carreraData["id_facultad"] ?? null;
            } else {
                unset($_SESSION["id_facultad"]);
                unset($_SESSION["id_carrera"]);
            }

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
    $errorMsg = "";
    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        require_once __DIR__ . "/src/dao/UsuarioDao.php";
        require_once __DIR__ . "/src/dao/SolicitudDao.php";
        $nombre = $_POST["nombre"] ?? "";
        $correo = $_POST["correo"] ?? "";
        $password = $_POST["password"] ?? "";
        $confirmPassword = $_POST["confirm_password"] ?? "";
        $dni = $_POST["dni"] ?? "";
        $carrera = $_POST["carrera"] ?? "";
        $telefono = $_POST["telefono"] ?? "";
        
        if ($password !== $confirmPassword) {
            $errorMsg = 'Las contraseñas no coinciden';
        } else {
            $existe = \Dao\UsuarioDao::existeCorreo($correo);
            if ($existe) {
                $errorMsg = 'Este correo ya está registrado';
            } else {
                // Procesar subida de archivo DNI
                $dniPath = "";
                if (isset($_FILES["documento_dni"]) && $_FILES["documento_dni"]["error"] === UPLOAD_ERR_OK) {
                    $fileTmpPath = $_FILES["documento_dni"]["tmp_name"];
                    $fileName = $_FILES["documento_dni"]["name"];
                    $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                    if (in_array($fileExtension, ["pdf", "jpg", "jpeg", "png"])) {
                        $newFileName = md5(time() . "dni_" . $fileName) . '.' . $fileExtension;
                        $uploadDir = __DIR__ . "/public/uploads/";
                        if (!is_dir($uploadDir)) {
                            mkdir($uploadDir, 0777, true);
                        }
                        if (move_uploaded_file($fileTmpPath, $uploadDir . $newFileName)) {
                            $dniPath = "public/uploads/" . $newFileName;
                        }
                    }
                }

                // Procesar subida de archivo Título
                $tituloPath = "";
                if (isset($_FILES["documento_titulo"]) && $_FILES["documento_titulo"]["error"] === UPLOAD_ERR_OK) {
                    $fileTmpPath = $_FILES["documento_titulo"]["tmp_name"];
                    $fileName = $_FILES["documento_titulo"]["name"];
                    $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                    if (in_array($fileExtension, ["pdf", "jpg", "jpeg", "png"])) {
                        $newFileName = md5(time() . "titulo_" . $fileName) . '.' . $fileExtension;
                        $uploadDir = __DIR__ . "/public/uploads/";
                        if (!is_dir($uploadDir)) {
                            mkdir($uploadDir, 0777, true);
                        }
                        if (move_uploaded_file($fileTmpPath, $uploadDir . $newFileName)) {
                            $tituloPath = "public/uploads/" . $newFileName;
                        }
                    }
                }

                if (empty($dniPath) || empty($tituloPath)) {
                    $errorMsg = 'Debe subir obligatoriamente tanto el DNI/Identificación como el Título de respaldo (PDF, JPG, PNG).';
                } else {
                    $resultado = \Dao\SolicitudDao::registrarPreRegistro(
                        $nombre,
                        $correo,
                        $password,
                        $dni,
                        $carrera,
                        $telefono,
                        $dniPath,
                        $tituloPath
                    );

                    if ($resultado) {
                        echo "<script>alert('Solicitud enviada correctamente. Su cuenta estará pendiente de aprobación por el coordinador.'); window.location='index.php?page=login';</script>";
                        exit();
                    } else {
                        $errorMsg = 'Error al procesar el pre-registro.';
                    }
                }
            }
        }
    }

    // Cargar carreras activas para el select del formulario
    require_once __DIR__ . "/src/dao/CarreraDao.php";
    $carrerasActivas = \Dao\CarreraDao::obtenerCarrerasParaRegistro();
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

    // Perfil y Seguridad
    case "perfil":
        if (!isset($_SESSION["usuario"])) {
            header("Location: index.php?page=login");
            exit();
        }
        require_once __DIR__ . "/src/views/templates/perfil.view.tpl";
        break;

    case "perfil_actualizar":
        if (!isset($_SESSION["usuario"])) {
            header("Location: index.php?page=login");
            exit();
        }
        require_once __DIR__ . "/src/controllers/UsuariosController.php";
        \Controllers\UsuariosController::actualizarPerfilPassword();
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
  // Maestros

    case "maestros":

        require_once __DIR__ . "/src/controllers/MaestrosController.php";

        $accion = $_GET["accion"] ?? "";

        if ($accion === "inactivar" && isset($_GET["id"])) {
            \Controllers\MaestrosController::inactivar($_GET["id"]);
            header("Location: index.php?page=maestros");
            exit();
        }

        if ($accion === "activar" && isset($_GET["id"])) {
            \Controllers\MaestrosController::activar($_GET["id"]);
            header("Location: index.php?page=maestros");
            exit();
        }

        if ($accion === "inactivar_coordinador" && isset($_GET["id"])) {
            \Controllers\MaestrosController::inactivarCoordinador($_GET["id"]);
            header("Location: index.php?page=maestros");
            exit();
        }

        if ($accion === "activar_coordinador" && isset($_GET["id"])) {
            \Controllers\MaestrosController::activarCoordinador($_GET["id"]);
            header("Location: index.php?page=maestros");
            exit();
        }

        require_once __DIR__ . "/src/views/templates/maestros/maestros.view.tpl";
        break;

    case "maestro_nuevo":
        require_once __DIR__ . "/src/views/templates/maestros/maestros_form.view.tpl";
        break;

    case "maestro_guardar":
        require_once __DIR__ . "/src/controllers/MaestrosController.php";
        \Controllers\MaestrosController::guardar();
        break;

    case "maestro_actualizar":
        require_once __DIR__ . "/src/controllers/MaestrosController.php";
        \Controllers\MaestrosController::actualizar();
        break;
    
    // Materias
    case "mis_materias":
    require_once __DIR__ . "/src/views/templates/estudiantes/mis_materias.view.tpl";
    break;

    // Matrícula
    case "matricula_estudiante":
        require_once __DIR__ . "/src/views/templates/matriculas/matricula_estudiante.view.tpl";
        break;
    case "matriculas":
        require_once __DIR__ . "/src/views/templates/matriculas/matriculas.view.tpl";
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


    // --- Nuevas Rutas de Reingeniería ---
    
    // Gestión de Periodos
    case "periodos":
        require_once __DIR__ . "/src/views/templates/facultades/periodos.view.tpl";
        break;

    // Gestión de Facultades
    case "facultades":
        require_once __DIR__ . "/src/views/templates/facultades/facultades.view.tpl";
        break;
    case "facultad_nueva":
        require_once __DIR__ . "/src/views/templates/facultades/facultades_form.view.tpl";
        break;
    case "facultad_guardar":
        require_once __DIR__ . "/src/controllers/FacultadesController.php";
        \Controllers\FacultadesController::guardar();
        break;
    
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
        
    case "carrera_flujograma":
        require_once __DIR__ . "/src/controllers/MateriasController.php";
        \Controllers\MateriasController::verFlujograma();
        break;

    case "mi_flujograma":
        // Ruta exclusiva del estudiante: usa el id_carrera de su sesión
        if (!isset($_SESSION["id_carrera"]) || !$_SESSION["id_carrera"]) {
            echo "<script>alert('No tienes una carrera asignada.'); window.location='index.php?page=home';</script>";
            exit();
        }
        $_GET["id"] = $_SESSION["id_carrera"];
        require_once __DIR__ . "/src/controllers/MateriasController.php";
        \Controllers\MateriasController::verFlujograma();
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
                
                if ($nuevoRol === "coordinador" && isset($_SESSION["id_usuario"])) {
                    $_SESSION["id_facultad"] = \Dao\UsuarioDao::obtenerFacultadCoordinador($_SESSION["id_usuario"]);
                } else {
                    unset($_SESSION["id_facultad"]);
                }
                
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
