<?php

namespace Controllers;

require_once __DIR__ . "/../dao/CampusDao.php";

use Dao\CampusDao;

class CampusController
{
    public static function listar()
    {
        return CampusDao::obtenerCampuses(true);
    }

    public static function obtenerPorId($id)
    {
        return CampusDao::obtenerCampusPorId($id);
    }

    public static function guardar($id, $nombre, $departamento, $estado = 'activo')
    {
        if (empty($nombre) || empty($departamento)) {
            return ["exito" => false, "mensaje" => "Todos los campos son obligatorios."];
        }

        if (empty($id)) {
            // Registrar nuevo campus
            if (CampusDao::registrarCampus($nombre, $departamento)) {
                return ["exito" => true, "mensaje" => "Campus registrado correctamente."];
            }
        } else {
            // Actualizar existente
            if (CampusDao::actualizarCampus($id, $nombre, $departamento, $estado)) {
                return ["exito" => true, "mensaje" => "Campus actualizado correctamente."];
            }
        }
        return ["exito" => false, "mensaje" => "Ocurrió un error en la base de datos al guardar el campus."];
    }
}
