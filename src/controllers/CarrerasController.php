<?php

namespace Controllers;

require_once __DIR__ . "/../dao/CarreraDao.php";

class CarrerasController
{
    public static function guardar()
    {
        $id_carrera = $_POST["id_carrera"] ?? null;
        $nombre_carrera = $_POST["nombre_carrera"] ?? "";
        $estado = $_POST["estado"] ?? "activa";
        $id_facultad = $_POST["id_facultad"] ?? null;
        
        if (empty($id_facultad)) {
            $id_facultad = null;
        }

        if ($nombre_carrera === "") {
            echo "<script>alert('El nombre de la carrera es requerido'); window.location='index.php?page=carreras';</script>";
            exit();
        }

        if (\Dao\CarreraDao::existeNombreCarrera($nombre_carrera, $id_carrera)) {
            $redir = $id_carrera ? "index.php?page=carrera_nueva&id=" . urlencode($id_carrera) : "index.php?page=carrera_nueva";
            echo "<script>
                alert('Error: Ya existe una carrera registrada con el nombre \"" . htmlspecialchars($nombre_carrera) . "\".');
                window.location = '" . $redir . "';
            </script>";
            exit();
        }

        if ($id_carrera) {
            $resultado = \Dao\CarreraDao::actualizarCarrera($id_carrera, $nombre_carrera, $estado, $id_facultad);
            $msg = $resultado ? 'Carrera actualizada correctamente' : 'Error al actualizar carrera';
        } else {
            $resultado = \Dao\CarreraDao::registrarCarrera($nombre_carrera, $id_facultad);
            $msg = $resultado ? 'Carrera registrada correctamente' : 'Error al registrar carrera';
        }

        echo "<script>alert('" . htmlspecialchars($msg) . "'); window.location='index.php?page=carreras';</script>";
        exit();
    }

    public static function inactivar($id)
    {
        $resultado = \Dao\CarreraDao::inactivarCarrera($id);
        return [
            "exito" => $resultado,
            "mensaje" => $resultado ? "Carrera dada de baja correctamente" : "Error al dar de baja la carrera"
        ];
    }

    public static function activar($id)
    {
        $resultado = \Dao\CarreraDao::activarCarrera($id);
        return [
            "exito" => $resultado,
            "mensaje" => $resultado ? "Carrera reactivada correctamente" : "Error al reactivar la carrera"
        ];
    }
}
