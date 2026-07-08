<?php

namespace Controllers;

require_once __DIR__ . "/../dao/SolicitudDao.php";
require_once __DIR__ . "/../dao/Dao.php";

class UsuariosController
{
    public static function obtenerPerfilActivo()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $idUsuario = intval($_SESSION["id_usuario"] ?? 0);
        if ($idUsuario <= 0) {
            return false;
        }

        $conn = \Dao\Dao::getConn();
        $selects = array(
            "u.id_usuario",
            "u.nombre",
            "u.correo",
            "u.estado",
            "u.fecha_creacion",
            "r.nombre_rol",
            "e.cuenta AS dni",
            "e.carrera",
            "e.telefono AS telefono_estudiante",
            "f.nombre_facultad"
        );

        $selects[] = self::columnaExiste("usuarios", "titulo") ? "u.titulo" : "NULL AS titulo";
        $selects[] = self::columnaExiste("usuarios", "documento_dni") ? "u.documento_dni" : "NULL AS documento_dni";
        $selects[] = self::columnaExiste("maestros", "numero_empleado") ? "m.numero_empleado" : "NULL AS numero_empleado";
        $selects[] = self::columnaExiste("maestros", "codigo") ? "m.codigo AS codigo_maestro" : "NULL AS codigo_maestro";
        $selects[] = self::columnaExiste("maestros", "especialidad") ? "m.especialidad" : "NULL AS especialidad";
        $selects[] = self::columnaExiste("maestros", "telefono") ? "m.telefono AS telefono_maestro" : "NULL AS telefono_maestro";

        $sqlstr = "SELECT " . implode(", ", $selects) . "
                   FROM usuarios u
                   INNER JOIN roles r ON u.id_rol = r.id_rol
                   LEFT JOIN estudiantes e ON u.id_usuario = e.id_usuario
                   LEFT JOIN maestros m ON u.id_usuario = m.id_usuario
                   LEFT JOIN coordinadores co ON u.id_usuario = co.id_usuario
                   LEFT JOIN facultades f ON co.id_facultad = f.id_facultad
                   WHERE u.id_usuario = :id_usuario
                   LIMIT 1";

        $stmt = $conn->prepare($sqlstr);
        $stmt->execute(array("id_usuario" => $idUsuario));
        $perfil = $stmt->fetch(\PDO::FETCH_ASSOC);

        return $perfil ?: false;
    }

    public static function actualizarPerfilPassword()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $idUsuario = intval($_SESSION["id_usuario"] ?? 0);
        if ($idUsuario <= 0) {
            header("Location: index.php?page=login&mensaje=Sesion expirada");
            exit();
        }

        $passwordActual = $_POST["password_actual"] ?? "";
        $passwordNuevo = $_POST["password_nuevo"] ?? "";
        $passwordConfirmar = $_POST["password_confirmar"] ?? "";

        if ($passwordActual === "" || $passwordNuevo === "" || $passwordConfirmar === "") {
            self::redirigirPerfil("Complete todos los campos de contraseña.");
        }

        if (strlen($passwordNuevo) < 6) {
            self::redirigirPerfil("La nueva contraseña debe tener minimo 6 caracteres.");
        }

        if ($passwordNuevo !== $passwordConfirmar) {
            self::redirigirPerfil("La nueva contraseña y su confirmacion no coinciden.");
        }

        $conn = \Dao\Dao::getConn();
        $stmt = $conn->prepare("SELECT password FROM usuarios WHERE id_usuario = :id_usuario LIMIT 1");
        $stmt->execute(array("id_usuario" => $idUsuario));
        $usuario = $stmt->fetch(\PDO::FETCH_ASSOC);

        if (!$usuario || !password_verify($passwordActual, $usuario["password"])) {
            self::redirigirPerfil("La contraseña actual es incorrecta.");
        }

        $nuevoHash = password_hash($passwordNuevo, PASSWORD_DEFAULT);
        $stmtUpdate = $conn->prepare("UPDATE usuarios SET password = :password WHERE id_usuario = :id_usuario");
        $actualizado = $stmtUpdate->execute(array(
            "password" => $nuevoHash,
            "id_usuario" => $idUsuario
        ));

        if (!$actualizado) {
            self::redirigirPerfil("No se pudo actualizar la contraseña. Intente nuevamente.");
        }

        session_destroy();
        echo "<script>
            alert('Contraseña actualizada correctamente. Ingrese con sus nuevas credenciales.');
            window.location='index.php?page=login';
        </script>";
        exit();
    }

    public static function procesarSolicitud()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $idUsuario = intval($_POST["id_usuario"] ?? $_GET["id"] ?? 0);
        $accion = $_POST["accion"] ?? $_GET["accion"] ?? "";

        if ($idUsuario <= 0) {
            echo "<script>alert('ID de usuario no proporcionado'); window.location='index.php?page=solicitudes_registro';</script>";
            exit();
        }

        if (!in_array($accion, ["aprobar", "rechazar"], true)) {
            echo "<script>alert('Accion no valida'); window.location='index.php?page=solicitudes_registro';</script>";
            exit();
        }

        $rolActivo = $_SESSION["rol"] ?? "";
        if ($rolActivo === "coordinador" && isset($_SESSION["id_facultad"])) {
            $solicitud = \Dao\SolicitudDao::obtenerSolicitudPorIdYFacultad($idUsuario, $_SESSION["id_facultad"]);
        } else {
            $solicitud = \Dao\SolicitudDao::obtenerSolicitudPorId($idUsuario);
        }

        if (!$solicitud) {
            echo "<script>alert('La solicitud no existe, ya fue procesada o no pertenece a tu facultad'); window.location='index.php?page=solicitudes_registro';</script>";
            exit();
        }

        if ($accion === "aprobar") {
            $resultado = \Dao\SolicitudDao::aprobarSolicitud($idUsuario);
            if ($resultado) {
                echo "<script>alert('Solicitud aprobada con exito. Estudiante admitido.'); window.location='index.php?page=solicitudes_registro';</script>";
            } else {
                echo "<script>alert('Error al aprobar la solicitud'); window.location='index.php?page=solicitudes_registro';</script>";
            }
            exit();
        }

        if ($accion === "rechazar") {
            $resultado = \Dao\SolicitudDao::rechazarSolicitud($idUsuario);
            if ($resultado) {
                echo "<script>alert('Solicitud rechazada y eliminada.'); window.location='index.php?page=solicitudes_registro';</script>";
            } else {
                echo "<script>alert('Error al rechazar la solicitud'); window.location='index.php?page=solicitudes_registro';</script>";
            }
            exit();
        }
    }

    private static function columnaExiste($tabla, $columna)
    {
        try {
            $conn = \Dao\Dao::getConn();
            $stmt = $conn->prepare("SHOW COLUMNS FROM `" . str_replace("`", "", $tabla) . "` LIKE :columna");
            $stmt->execute(array("columna" => $columna));
            return (bool) $stmt->fetch(\PDO::FETCH_ASSOC);
        } catch (\Throwable $ex) {
            return false;
        }
    }

    private static function redirigirPerfil($mensaje)
    {
        echo "<script>
            alert('" . htmlspecialchars($mensaje, ENT_QUOTES) . "');
            window.location='index.php?page=perfil';
        </script>";
        exit();
    }
}
