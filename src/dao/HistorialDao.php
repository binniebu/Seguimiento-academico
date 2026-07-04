<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class HistorialDao extends Table
{
    public static function obtenerHistorialAcademico($idEstudiante)
    {
        $sqlstr = "SELECT mt.periodo, m.codigo as codigo_materia, m.nombre as nombre_materia, 
                          m.creditos, c.nota, c.observacion, c.fecha_registro
                   FROM calificaciones c
                   INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                   INNER JOIN materias m ON mt.id_materia = m.id_materia
                   WHERE mt.id_estudiante = :id_estudiante
                   ORDER BY mt.periodo ASC, m.nombre ASC";
        return self::obtenerRegistros($sqlstr, ["id_estudiante" => $idEstudiante]);
    }

    public static function obtenerIndicesAcademicos($idEstudiante)
    {
        // 1. Promedio global acumulado
        $sqlstrGlobal = "SELECT ROUND(AVG(c.nota), 2) as promedio_global
                         FROM calificaciones c
                         INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                         WHERE mt.id_estudiante = :id_estudiante";
        $global = self::obtenerUnRegistro($sqlstrGlobal, ["id_estudiante" => $idEstudiante]);

        // 2. Promedio segmentado por periodo
        $sqlstrPeriodos = "SELECT mt.periodo, ROUND(AVG(c.nota), 2) as promedio_periodo
                           FROM calificaciones c
                           INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                           WHERE mt.id_estudiante = :id_estudiante
                           GROUP BY mt.periodo
                           ORDER BY mt.periodo DESC";
        $periodos = self::obtenerRegistros($sqlstrPeriodos, ["id_estudiante" => $idEstudiante]);

        return [
            "promedio_global" => $global["promedio_global"] ?? 0,
            "periodos" => $periodos
        ];
    }

    public static function obtenerClasesActualmenteCursando($idEstudiante)
    {
        $sqlstr = "SELECT mt.id_matricula, m.codigo as codigo_materia, m.nombre as nombre_materia, 
                          m.creditos, mt.periodo, mt.estado
                   FROM matriculas mt
                   INNER JOIN materias m ON mt.id_materia = m.id_materia
                   INNER JOIN periodos_academicos pa ON mt.periodo = CONCAT(pa.periodo_num, 'PAC-', pa.anio)
                   WHERE mt.id_estudiante = :id_estudiante
                     AND pa.estado = 'activo'
                     AND mt.estado = 'activa'
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr, ["id_estudiante" => $idEstudiante]);
    }
}
