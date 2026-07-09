<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class HistorialDao extends Table
{
    public static function obtenerHistorialAcademico($idEstudiante)
    {
        $sqlstr = "SELECT pa.nombre_periodo AS periodo, m.codigo as codigo_materia, m.nombre as nombre_materia, 
                          m.creditos, c.nota, c.observacion, c.fecha_registro
                   FROM calificaciones c
                   INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                   INNER JOIN secciones sec ON mt.id_seccion = sec.id_seccion
                   INNER JOIN materias m ON sec.id_materia = m.id_materia
                   INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                   WHERE mt.id_estudiante = :id_estudiante
                     AND (pa.estado = 'inactivo' OR DATE(NOW()) > DATE_ADD(pa.fecha_fin, INTERVAL 7 DAY))
                   ORDER BY pa.fecha_inicio ASC, m.nombre ASC";
        return self::obtenerRegistros($sqlstr, ["id_estudiante" => $idEstudiante]);
    }

    public static function obtenerIndicesAcademicos($idEstudiante)
    {
        // 1. Promedio global acumulado (excluyendo el periodo actual mientras esté en curso o en semana de subir notas)
        $sqlstrGlobal = "SELECT ROUND(AVG(c.nota), 2) as promedio_global
                         FROM calificaciones c
                         INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                         INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                         WHERE mt.id_estudiante = :id_estudiante
                           AND (pa.estado = 'inactivo' OR DATE(NOW()) > DATE_ADD(pa.fecha_fin, INTERVAL 7 DAY))";
        $global = self::obtenerUnRegistro($sqlstrGlobal, ["id_estudiante" => $idEstudiante]);

        // 2. Promedio segmentado por periodo (excluyendo el periodo actual mientras esté en curso o en semana de subir notas)
        $sqlstrPeriodos = "SELECT pa.nombre_periodo AS periodo, ROUND(AVG(c.nota), 2) as promedio_periodo
                           FROM calificaciones c
                           INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                           INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                           WHERE mt.id_estudiante = :id_estudiante
                             AND (pa.estado = 'inactivo' OR DATE(NOW()) > DATE_ADD(pa.fecha_fin, INTERVAL 7 DAY))
                           GROUP BY pa.id_periodo
                           ORDER BY pa.fecha_inicio DESC";
        $periodos = self::obtenerRegistros($sqlstrPeriodos, ["id_estudiante" => $idEstudiante]);

        return [
            "promedio_global" => $global["promedio_global"] ?? 0,
            "periodos" => $periodos
        ];
    }

    public static function obtenerClasesActualmenteCursando($idEstudiante)
    {
        // El alumno ve sus clases en "Mis Materias" durante las 13 semanas del período y la semana 14 (de subida de notas)
        $sqlstr = "SELECT mt.id_matricula, m.codigo as codigo_materia, m.nombre as nombre_materia, 
                          m.creditos, pa.nombre_periodo AS periodo, sec.codigo_seccion, sec.aula, sec.dias, sec.hora_inicio, sec.hora_fin,
                          u.nombre AS nombre_maestro,
                          c.nota, c.nota_parcial1, c.nota_parcial2, c.nota_parcial3, c.observacion
                   FROM matriculas mt
                   INNER JOIN secciones sec ON mt.id_seccion = sec.id_seccion
                   INNER JOIN materias m ON sec.id_materia = m.id_materia
                   INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                   INNER JOIN maestros mae ON sec.id_maestro = mae.id_maestro
                   INNER JOIN usuarios u ON mae.id_usuario = u.id_usuario
                   LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                   WHERE mt.id_estudiante = :id_estudiante
                     AND pa.estado = 'activo'
                     AND DATE(NOW()) <= DATE_ADD(pa.fecha_fin, INTERVAL 7 DAY)
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr, ["id_estudiante" => $idEstudiante]);
    }
}
