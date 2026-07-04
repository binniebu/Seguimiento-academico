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
    public static function crear($codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito = null)
    {
        // Validaciones
        if (empty($codigo) || empty($nombre) || empty($creditos) || empty($periodo) || empty($tipo_materia)) {
            return ['exito' => false, 'mensaje' => 'Campos obligatorios vacíos'];
        }

        if (MateriaDao::existeCodigoMateria($codigo)) {
            return ['exito' => false, 'mensaje' => 'El código de materia ya existe. No se pueden duplicar códigos.'];
        }

        if (MateriaDao::existeNombreMateria($nombre)) {
            return ['exito' => false, 'mensaje' => 'El nombre de la materia ya existe. No se pueden duplicar materias.'];
        }

        if (!empty($id_requisito)) {
            $requisito = MateriaDao::obtenerMateria($id_requisito);
            if ($requisito && intval($periodo) <= intval($requisito['periodo'])) {
                return [
                    'exito' => false, 
                    'mensaje' => "Error de flujo académico: No puedes cursar esta clase en el Periodo {$periodo} si su requisito ('{$requisito['nombre']}') se cursa en el Periodo {$requisito['periodo']}. El periodo debe ser estrictamente mayor."
                ];
            }
        }

        if (MateriaDao::registrarMateria($codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito)) {
            return ['exito' => true, 'mensaje' => 'Materia registrada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al registrar la materia'];
        }
    }

    /**
     * Actualizar materia
     */
    public static function actualizar($id, $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito, $estado)
    {
        // Validaciones
        if (empty($codigo) || empty($nombre) || empty($creditos) || empty($periodo) || empty($tipo_materia)) {
            return ['exito' => false, 'mensaje' => 'Campos obligatorios vacíos'];
        }

        if (MateriaDao::existeCodigoMateria($codigo, $id)) {
            return ['exito' => false, 'mensaje' => 'El código de materia ya existe. No se pueden duplicar códigos.'];
        }

        if (MateriaDao::existeNombreMateria($nombre, $id)) {
            return ['exito' => false, 'mensaje' => 'El nombre de la materia ya existe. No se pueden duplicar materias.'];
        }

        if (!empty($id_requisito)) {
            $requisito = MateriaDao::obtenerMateria($id_requisito);
            if ($requisito && intval($periodo) <= intval($requisito['periodo'])) {
                return [
                    'exito' => false, 
                    'mensaje' => "Error de flujo académico: No puedes cursar esta clase en el Periodo {$periodo} si su requisito ('{$requisito['nombre']}') se cursa en el Periodo {$requisito['periodo']}. El periodo debe ser estrictamente mayor."
                ];
            }
        }

        if (MateriaDao::actualizarMateria($id, $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito, $estado)) {
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
     * Obtener facultades para el selector
     */
    public static function obtenerFacultades()
    {
        return MateriaDao::obtenerFacultades();
    }

    /**
     * Renderizar la vista de Flujograma de Carrera
     */
    public static function verFlujograma()
    {
        $id_carrera = $_GET['id'] ?? null;
        if (!$id_carrera) {
            header("Location: index.php?page=carreras");
            exit;
        }

        require_once __DIR__ . "/../dao/CarreraDao.php";
        $carrera = \Dao\CarreraDao::obtenerCarreraPorId($id_carrera);
        
        if (!$carrera) {
            header("Location: index.php?page=carreras");
            exit;
        }

        $id_facultad = $carrera['id_facultad'] ?? null;
        $materias = MateriaDao::obtenerFlujogramaPorCarrera($id_carrera, $id_facultad);

        require_once __DIR__ . "/../views/templates/materias/carrera_flujograma.view.tpl";
    }

    /**
     * Obtener carreras para el selector
     */
    public static function obtenerCarrerasActivas()
    {
        return MateriaDao::obtenerCarrerasActivas();
    }
}

?>
