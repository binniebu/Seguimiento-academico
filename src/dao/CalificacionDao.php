<?php

namespace Dao;

use Dao\Table;

class CalificacionDao extends Table
{
    public static function getCalificaciones(
        string $strPartialName = "",
        string $strOrderBy = "",
        bool $binOrderDescending = false,
        int $intPage = 0,
        int $intItemsPerPage = 10
    ) {
        // SQL combinado para extraer datos legibles de la matrícula, estudiante y materia
        $sqlstr = "SELECT c.id_calificacion, c.id_matricula, c.nota, c.observacion, c.fecha_registro,
                          u.nombre as nombre_estudiante, m.nombre as nombre_materia, mat.periodo
                   FROM calificaciones c
                   INNER JOIN matriculas mat ON c.id_matricula = mat.id_matricula
                   INNER JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN materias m ON mat.id_materia = m.id_materia";
        
        $sqlstrCount = "SELECT COUNT(*) as count 
                        FROM calificaciones c
                        INNER JOIN matriculas mat ON c.id_matricula = mat.id_matricula
                        INNER JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                        INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                        INNER JOIN materias m ON mat.id_materia = m.id_materia";
        
        $conditions = [];
        $params = [];

        if ($strPartialName != "") {
            $conditions[] = "u.nombre LIKE :partialName OR m.nombre LIKE :partialName";
            $params["partialName"] = "%" . $strPartialName . "%";
        }

        if (count($conditions) > 0) {
            $sqlstr .= " WHERE " . implode(" AND ", $conditions);
            $sqlstrCount .= " WHERE " . implode(" AND ", $conditions);
        }

        if ($strOrderBy != "" && in_array($strOrderBy, ["id_calificacion", "nota", "nombre_estudiante"])) {
            $sqlstr .= " ORDER BY " . $strOrderBy;
            if ($binOrderDescending) {
                $sqlstr .= " DESC";
            }
        } else {
            $sqlstr .= " ORDER BY c.id_calificacion ASC";
        }

        $intNumeroDeRegistros = self::obtenerUnRegistro($sqlstrCount, $params)["count"];
        $intPagesCount = ceil($intNumeroDeRegistros / $intItemsPerPage);

        if ($intPage > $intPagesCount - 1 && $intPagesCount > 0) {
            $intPage = $intPagesCount - 1;
        }

        $sqlstr .= " LIMIT " . ($intPage * $intItemsPerPage) . ", " . $intItemsPerPage;

        return [
            "calificaciones" => self::obtenerRegistros($sqlstr, $params),
            "total" => $intNumeroDeRegistros,
            "page" => $intPage,
            "itemsPerPage" => $intItemsPerPage
        ];
    }

    public static function getCalificacionById(int $intIdCalificacion)
    {
        $sqlstr = "SELECT id_calificacion, id_matricula, nota, observacion, fecha_registro 
                   FROM calificaciones 
                   WHERE id_calificacion = :id_calificacion";
        return self::obtenerUnRegistro($sqlstr, ["id_calificacion" => $intIdCalificacion]);
    }

    public static function insertCalificacion(int $intIdMatricula, float $fltNota, string $strObservacion)
    {
        $sqlstr = "INSERT INTO calificaciones (id_matricula, nota, observacion, fecha_registro) 
                   VALUES (:id_matricula, :nota, :observacion, NOW())";
        return self::executeNonQuery($sqlstr, [
            "id_matricula" => $intIdMatricula,
            "nota" => $fltNota,
            "observacion" => $strObservacion
        ]);
    }

    public static function updateCalificacion(int $intIdCalificacion, int $intIdMatricula, float $fltNota, string $strObservacion)
    {
        $sqlstr = "UPDATE calificaciones 
                   SET id_matricula = :id_matricula, nota = :nota, observacion = :observacion 
                   WHERE id_calificacion = :id_calificacion";
        return self::executeNonQuery($sqlstr, [
            "id_calificacion" => $intIdCalificacion,
            "id_matricula" => $intIdMatricula,
            "nota" => $fltNota,
            "observacion" => $strObservacion
        ]);
    }

    public static function deleteCalificacion(int $intIdCalificacion)
    {
        $sqlstr = "DELETE FROM calificaciones WHERE id_calificacion = :id_calificacion";
        return self::executeNonQuery($sqlstr, ["id_calificacion" => $intIdCalificacion]);
    }

    // Auxiliar para cargar las opciones de matrículas existentes en el formulario
    public static function getMatriculasDisponibles()
    {
        $sqlstr = "SELECT m.id_matricula, u.nombre as nombre_estudiante, mat.nombre as nombre_materia, m.periodo
                   FROM matriculas m
                   INNER JOIN estudiantes e ON m.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN materias mat ON m.id_materia = mat.id_materia
                   WHERE m.estado = 'activa'";
        return self::obtenerRegistros($sqlstr);
    }
}

