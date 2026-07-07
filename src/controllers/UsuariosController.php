<?php

namespace Controllers;

require_once __DIR__ . "/../dao/SolicitudDao.php";

class UsuariosController
{
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
}

