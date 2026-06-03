<?php

namespace Controllers;

require_once __DIR__ . "/../dao/MateriaDao.php";

use Dao\MateriaDao;

class MateriasController
{
    /**
     * Listar todas las materias
     */
    public static function listar()
    {
        return MateriaDao::listarMaterias();
    }

    /**
     * Buscar materias
     */
    public static function buscar($termino)
    {
        if (empty($termino)) {
            return self::listar();
        }
        return MateriaDao::buscarMateria($termino);
    }

    /**
     * Obtener detalle de materia
     */
    public static function obtener($id)
    {
        return MateriaDao::obtenerMateria($id);
    }

    /**
     * Crear nueva materia
     */
    public static function crear($codigo, $nombre, $descripcion, $id_maestro)
    {
        // Validaciones
        if (empty($codigo) || empty($nombre) || empty($id_maestro)) {
            return ['exito' => false, 'mensaje' => 'Campos obligatorios vacíos'];
        }

        if (MateriaDao::existeCodigoMateria($codigo)) {
            return ['exito' => false, 'mensaje' => 'El código de materia ya existe'];
        }

        if (MateriaDao::registrarMateria($codigo, $nombre, $descripcion, $id_maestro)) {
            return ['exito' => true, 'mensaje' => 'Materia registrada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al registrar la materia'];
        }
    }

    /**
     * Actualizar materia
     */
    public static function actualizar($id, $codigo, $nombre, $descripcion, $id_maestro, $estado)
    {
        // Validaciones
        if (empty($codigo) || empty($nombre) || empty($id_maestro)) {
            return ['exito' => false, 'mensaje' => 'Campos obligatorios vacíos'];
        }

        if (MateriaDao::existeCodigoMateria($codigo, $id)) {
            return ['exito' => false, 'mensaje' => 'El código de materia ya existe'];
        }

        if (MateriaDao::actualizarMateria($id, $codigo, $nombre, $descripcion, $id_maestro, $estado)) {
            return ['exito' => true, 'mensaje' => 'Materia actualizada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al actualizar la materia'];
        }
    }

    /**
     * Eliminar materia
     */
    public static function eliminar($id)
    {
        if (MateriaDao::eliminarMateria($id)) {
            return ['exito' => true, 'mensaje' => 'Materia eliminada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al eliminar la materia'];
        }
    }

    /**
     * Obtener maestros para el selector
     */
    public static function obtenerMaestros()
    {
        return MateriaDao::obtenerMaestros();
    }
}

?>
