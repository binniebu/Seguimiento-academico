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
            header("Location: index.php?page=carreras&msg=" . urlencode("El nombre de la carrera es requerido.") . "&tipo_msg=error");
            exit();
        }

        if (\Dao\CarreraDao::existeNombreCarrera($nombre_carrera, $id_carrera)) {
            header("Location: index.php?page=carreras&msg=" . urlencode("Error: Ya existe una carrera registrada con el nombre \"" . $nombre_carrera . "\".") . "&tipo_msg=error");
            exit();
        }

        if ($id_carrera) {
            $resultado = \Dao\CarreraDao::actualizarCarrera($id_carrera, $nombre_carrera, $estado, $id_facultad);
            if ($resultado) {
                header("Location: index.php?page=carreras&msg=" . urlencode("Carrera actualizada correctamente.") . "&tipo_msg=success");
            } else {
                header("Location: index.php?page=carreras&msg=" . urlencode("Error al actualizar la carrera.") . "&tipo_msg=error");
            }
        } else {
            $resultado = \Dao\CarreraDao::registrarCarrera($nombre_carrera, $id_facultad);
            if ($resultado) {
                header("Location: index.php?page=carreras&msg=" . urlencode("Carrera registrada correctamente.") . "&tipo_msg=success");
            } else {
                header("Location: index.php?page=carreras&msg=" . urlencode("Error al registrar la carrera.") . "&tipo_msg=error");
            }
        }
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
