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
        $sqlstr = "SELECT m.*, f.nombre_facultad 
                   FROM materias m 
                   LEFT JOIN facultades f ON m.id_facultad = f.id_facultad 
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr);
    }

    /**
     * Obtener materia por ID
     */
    public static function obtenerMateria($id)
    {
        $sqlstr = "SELECT m.*, f.nombre_facultad 
                   FROM materias m 
                   LEFT JOIN facultades f ON m.id_facultad = f.id_facultad 
                   WHERE m.id_materia = :id";
        $params = array("id" => $id);
        return self::obtenerUnRegistro($sqlstr, $params);
    }

    /**
     * Registrar nueva materia
     */
    public static function registrarMateria($codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito = null, $estado = 'activa')
    {
        // Limpiar dependencias
        if ($tipo_materia === 'institucional') {
            $id_facultad = null;
            $id_carrera = null;
        } elseif ($tipo_materia === 'facultad') {
            $id_carrera = null;
        }
        
        // Limpiar requisito si está vacío o es inválido
        if (empty($id_requisito) || $id_requisito == 0) {
            $id_requisito = null;
        }
        
        $sqlstr = "INSERT INTO materias (codigo, nombre, descripcion, creditos, periodo, tipo_materia, id_facultad, id_carrera, id_requisito, estado) 
                   VALUES (:codigo, :nombre, :descripcion, :creditos, :periodo, :tipo_materia, :id_facultad, :id_carrera, :id_requisito, :estado)";
        $params = array(
            "codigo" => $codigo,
            "nombre" => $nombre,
            "descripcion" => $descripcion,
            "creditos" => $creditos,
            "periodo" => $periodo,
            "tipo_materia" => $tipo_materia,
            "id_facultad" => $id_facultad,
            "id_carrera" => $id_carrera,
            "id_requisito" => $id_requisito,
            "estado" => $estado
        );
        return self::executeNonQuery($sqlstr, $params);
    }

    /**
     * Actualizar materia
     */
    public static function actualizarMateria($id, $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito, $estado)
    {
        // Limpiar dependencias
        if ($tipo_materia === 'institucional') {
            $id_facultad = null;
            $id_carrera = null;
        } elseif ($tipo_materia === 'facultad') {
            $id_carrera = null;
        }

        // Limpiar requisito si está vacío o es inválido
        if (empty($id_requisito) || $id_requisito == 0) {
            $id_requisito = null;
        }

        $sqlstr = "UPDATE materias 
                   SET codigo = :codigo, nombre = :nombre, descripcion = :descripcion, 
                       creditos = :creditos, periodo = :periodo, tipo_materia = :tipo_materia, 
                       id_facultad = :id_facultad, id_carrera = :id_carrera, 
                       id_requisito = :id_requisito, estado = :estado 
                   WHERE id_materia = :id";
        $params = array(
            "id" => $id,
            "codigo" => $codigo,
            "nombre" => $nombre,
            "descripcion" => $descripcion,
            "creditos" => $creditos,
            "periodo" => $periodo,
            "tipo_materia" => $tipo_materia,
            "id_facultad" => $id_facultad,
            "id_carrera" => $id_carrera,
            "id_requisito" => $id_requisito,
            "estado" => $estado
        );
        return self::executeNonQuery($sqlstr, $params);
    }

    /**
     * Dar de baja una materia (soft delete: cambia estado a 'inactiva', no borra el registro)
     */
    public static function inactivarMateria($id)
    {
        $sqlstr = "UPDATE materias SET estado = 'inactiva' WHERE id_materia = :id";
        $params = array("id" => $id);
        return self::executeNonQuery($sqlstr, $params);
    }

    /**
     * Buscar materias por nombre o código
     */
    public static function buscarMateria($termino)
    {
        $sqlstr = "SELECT m.*, f.nombre_facultad 
                   FROM materias m 
                   LEFT JOIN facultades f ON m.id_facultad = f.id_facultad 
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
     * Verificar si existe nombre de materia
     */
    public static function existeNombreMateria($nombre, $excluir_id = null)
    {
        if ($excluir_id) {
            $sqlstr = "SELECT COUNT(*) as total FROM materias WHERE nombre = :nombre AND id_materia != :id";
            $params = array("nombre" => $nombre, "id" => $excluir_id);
        } else {
            $sqlstr = "SELECT COUNT(*) as total FROM materias WHERE nombre = :nombre";
            $params = array("nombre" => $nombre);
        }
        $result = self::obtenerUnRegistro($sqlstr, $params);
        return $result['total'] > 0;
    }

    /**
     * Obtener facultades para selector
     */
    public static function obtenerFacultades()
    {
        $sqlstr = "SELECT id_facultad, nombre_facultad FROM facultades ORDER BY nombre_facultad ASC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerCarrerasActivas()
    {
        $sqlstr = "SELECT id_carrera, nombre_carrera FROM carreras WHERE estado = 'activa' ORDER BY nombre_carrera ASC";
        return self::obtenerRegistros($sqlstr);
    }

    /**
     * Obtener el flujograma (todas las materias aplicables a una carrera)
     */
    public static function obtenerFlujogramaPorCarrera($id_carrera, $id_facultad)
    {
        // Obtenemos:
        // 1. Institucionales
        // 2. De la facultad correspondiente a la carrera
        // 3. De la carrera misma
        // Y hacemos un LEFT JOIN a la misma tabla para traer el nombre del requisito
        $sqlstr = "SELECT m.*, r.nombre as nombre_requisito 
                   FROM materias m
                   LEFT JOIN materias r ON m.id_requisito = r.id_materia
                   WHERE m.estado = 'activa' 
                     AND (
                         m.tipo_materia = 'institucional'
                         OR (m.tipo_materia = 'facultad' AND m.id_facultad = :id_facultad)
                         OR (m.tipo_materia = 'carrera' AND m.id_carrera = :id_carrera)
                     )
                   ORDER BY m.periodo ASC, m.tipo_materia DESC, m.nombre ASC";
                   
        return self::obtenerRegistros($sqlstr, [
            "id_facultad" => $id_facultad,
            "id_carrera" => $id_carrera
        ]);
    }
}

?>
