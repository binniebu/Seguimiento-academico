<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class MateriaDao extends Table
{
    /**
     * Obtener todas las materias
     */
    public static function listarMaterias()
    {
        $sqlstr = "SELECT m.*, u.nombre as maestro_nombre 
                   FROM materias m 
                   LEFT JOIN maestros ma ON m.id_maestro = ma.id_maestro 
                   LEFT JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr);
    }

    /**
     * Obtener materia por ID
     */
    public static function obtenerMateria($id)
    {
        $sqlstr = "SELECT m.*, u.nombre as maestro_nombre 
                   FROM materias m 
                   LEFT JOIN maestros ma ON m.id_maestro = ma.id_maestro 
                   LEFT JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   WHERE m.id_materia = :id";
        $params = array("id" => $id);
        return self::obtenerUnRegistro($sqlstr, $params);
    }

    /**
     * Registrar nueva materia
     */
    public static function registrarMateria($codigo, $nombre, $descripcion, $id_maestro, $estado = 'activa')
    {
        $sqlstr = "INSERT INTO materias (codigo, nombre, descripcion, id_maestro, estado) 
                   VALUES (:codigo, :nombre, :descripcion, :id_maestro, :estado)";
        $params = array(
            "codigo" => $codigo,
            "nombre" => $nombre,
            "descripcion" => $descripcion,
            "id_maestro" => $id_maestro,
            "estado" => $estado
        );
        return self::executeNonQuery($sqlstr, $params);
    }

    /**
     * Actualizar materia
     */
    public static function actualizarMateria($id, $codigo, $nombre, $descripcion, $id_maestro, $estado)
    {
        $sqlstr = "UPDATE materias 
                   SET codigo = :codigo, nombre = :nombre, descripcion = :descripcion, 
                       id_maestro = :id_maestro, estado = :estado 
                   WHERE id_materia = :id";
        $params = array(
            "id" => $id,
            "codigo" => $codigo,
            "nombre" => $nombre,
            "descripcion" => $descripcion,
            "id_maestro" => $id_maestro,
            "estado" => $estado
        );
        return self::executeNonQuery($sqlstr, $params);
    }

    /**
     * Eliminar materia
     */
    public static function eliminarMateria($id)
    {
        $sqlstr = "DELETE FROM materias WHERE id_materia = :id";
        $params = array("id" => $id);
        return self::executeNonQuery($sqlstr, $params);
    }

    /**
     * Buscar materias por nombre o código
     */
    public static function buscarMateria($termino)
    {
        $sqlstr = "SELECT m.*, u.nombre as maestro_nombre 
                   FROM materias m 
                   LEFT JOIN maestros ma ON m.id_maestro = ma.id_maestro 
                   LEFT JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   WHERE m.nombre LIKE :termino OR m.codigo LIKE :termino 
                   ORDER BY m.nombre ASC";
        $buscar = "%{$termino}%";
        $params = array("termino" => $buscar);
        return self::obtenerRegistros($sqlstr, $params);
    }

    /**
     * Verificar si existe código de materia
     */
    public static function existeCodigoMateria($codigo, $excluir_id = null)
    {
        if ($excluir_id) {
            $sqlstr = "SELECT COUNT(*) as total FROM materias WHERE codigo = :codigo AND id_materia != :id";
            $params = array("codigo" => $codigo, "id" => $excluir_id);
        } else {
            $sqlstr = "SELECT COUNT(*) as total FROM materias WHERE codigo = :codigo";
            $params = array("codigo" => $codigo);
        }
        $result = self::obtenerUnRegistro($sqlstr, $params);
        return $result['total'] > 0;
    }

    /**
     * Obtener maestros para selector
     */
    public static function obtenerMaestros()
    {
        $sqlstr = "SELECT ma.id_maestro, u.nombre FROM maestros ma 
                   INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario 
                   WHERE u.estado = 'activo' ORDER BY u.nombre ASC";
        return self::obtenerRegistros($sqlstr);
    }
}

?>
