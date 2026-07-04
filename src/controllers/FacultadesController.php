<?php

namespace Controllers;

require_once __DIR__ . "/../dao/FacultadDao.php";

class FacultadesController
{
    public static function listar()
    {
        return \Dao\FacultadDao::obtenerTodas();
    }

    public static function obtener($id)
    {
        return \Dao\FacultadDao::obtenerPorId($id);
    }

    public static function guardar()
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $nombre = trim($_POST['nombre_facultad'] ?? '');
            $id_facultad = $_POST['id_facultad'] ?? null;
            
            if (empty($nombre)) {
                return ['exito' => false, 'mensaje' => 'El nombre de la facultad es obligatorio'];
            }

            // Validar existencia
            if (\Dao\FacultadDao::existeNombre($nombre, $id_facultad)) {
                return ['exito' => false, 'mensaje' => 'Ya existe una facultad con ese nombre'];
            }

            if ($id_facultad) {
                // Actualizar
                if (\Dao\FacultadDao::actualizar($id_facultad, $nombre)) {
                    return ['exito' => true, 'mensaje' => 'Facultad actualizada correctamente'];
                }
            } else {
                // Crear
                if (\Dao\FacultadDao::crear($nombre)) {
                    return ['exito' => true, 'mensaje' => 'Facultad creada correctamente'];
                }
            }
            
            return ['exito' => false, 'mensaje' => 'Ocurrió un error al guardar la facultad'];
        }
    }
}
?>
