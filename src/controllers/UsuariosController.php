<?php

namespace Controllers;

require_once __DIR__ . "/../dao/SolicitudDao.php";

class UsuariosController
{
    public static function procesarSolicitud()
    {
        $idUsuario = $_POST["id_usuario"] ?? $_GET["id"] ?? null;
        $accion = $_POST["accion"] ?? $_GET["accion"] ?? "";

        if (!$idUsuario) {
            echo "<script>alert('ID de usuario no proporcionado'); window.location='index.php?page=solicitudes_registro';</script>";
            exit();
        }

        if ($accion === "aprobar") {
            $resultado = \Dao\SolicitudDao::aprobarSolicitud($idUsuario);
            if ($resultado) {
                echo "<script>alert('Solicitud aprobada con éxito. Estudiante admitido.'); window.location='index.php?page=solicitudes_registro';</script>";
            } else {
                echo "<script>alert('Error al aprobar la solicitud'); window.location='index.php?page=solicitudes_registro';</script>";
            }
            exit();
        } elseif ($accion === "rechazar") {
            $resultado = \Dao\SolicitudDao::rechazarSolicitud($idUsuario);
            if ($resultado) {
                echo "<script>alert('Solicitud rechazada y eliminada.'); window.location='index.php?page=solicitudes_registro';</script>";
            } else {
                echo "<script>alert('Error al rechazar la solicitud'); window.location='index.php?page=solicitudes_registro';</script>";
            }
            exit();
        }

        echo "<script>alert('Acción no válida'); window.location='index.php?page=solicitudes_registro';</script>";
        exit();
    }
}
