<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class EstadisticasDao extends Table
{
    public static function obtenerEstudiantesPorCampus()
    {
        $sqlstr = "SELECT cp.nombre_campus AS campus, COUNT(e.id_estudiante) AS total
                   FROM estudiantes e
                   INNER JOIN campus cp ON e.id_campus = cp.id_campus
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   WHERE u.estado = 'activo'
                   GROUP BY cp.nombre_campus
                   ORDER BY total DESC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerEstudiantesPorCarrera($idFacultad = null, $idCampus = null)
    {
        $sqlstr = "SELECT c.nombre_carrera AS carrera, COUNT(e.id_estudiante) AS total
                   FROM estudiantes e
                   INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   WHERE u.estado = 'activo'";
        
        $params = [];
        if ($idFacultad !== null && $idFacultad !== "") {
            $sqlstr .= " AND c.id_facultad = :id_facultad";
            $params["id_facultad"] = intval($idFacultad);
        }
        if ($idCampus !== null && $idCampus !== "") {
            $sqlstr .= " AND e.id_campus = :id_campus";
            $params["id_campus"] = intval($idCampus);
        }

        $sqlstr .= " GROUP BY c.nombre_carrera
                     ORDER BY total DESC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerPromediosMaterias($idFacultad = null, $idCampus = null)
    {
        $sqlstr = "SELECT m.nombre AS materia, ROUND(AVG(cal.nota), 2) AS promedio
                   FROM calificaciones cal
                   INNER JOIN matriculas mt ON cal.id_matricula = mt.id_matricula
                   INNER JOIN secciones s ON mt.id_seccion = s.id_seccion
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   INNER JOIN maestros mae ON s.id_maestro = mae.id_maestro
                   WHERE 1=1";
        
        $params = [];
        if ($idFacultad !== null && $idFacultad !== "") {
            $sqlstr .= " AND (m.id_facultad = :id_facultad OR c.id_facultad = :id_facultad)";
            $params["id_facultad"] = intval($idFacultad);
        }
        if ($idCampus !== null && $idCampus !== "") {
            $sqlstr .= " AND mae.id_campus = :id_campus";
            $params["id_campus"] = intval($idCampus);
        }

        $sqlstr .= " GROUP BY m.id_materia, m.nombre
                     ORDER BY promedio DESC
                     LIMIT 8";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerAprobadosVsReprobados($idFacultad = null, $idCampus = null, $idMaestro = null)
    {
        $sqlstr = "SELECT 
                       SUM(CASE WHEN cal.nota >= 70 THEN 1 ELSE 0 END) AS aprobados,
                       SUM(CASE WHEN cal.nota < 70 THEN 1 ELSE 0 END) AS reprobados
                   FROM calificaciones cal
                   INNER JOIN matriculas mt ON cal.id_matricula = mt.id_matricula
                   INNER JOIN secciones s ON mt.id_seccion = s.id_seccion
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   INNER JOIN maestros mae ON s.id_maestro = mae.id_maestro
                   WHERE 1=1";
        
        $params = [];
        if ($idFacultad !== null && $idFacultad !== "") {
            $sqlstr .= " AND (m.id_facultad = :id_facultad OR c.id_facultad = :id_facultad)";
            $params["id_facultad"] = intval($idFacultad);
        }
        if ($idCampus !== null && $idCampus !== "") {
            $sqlstr .= " AND mae.id_campus = :id_campus";
            $params["id_campus"] = intval($idCampus);
        }
        if ($idMaestro !== null && $idMaestro !== "") {
            $sqlstr .= " AND s.id_maestro = :id_maestro";
            $params["id_maestro"] = intval($idMaestro);
        }

        $res = self::obtenerUnRegistro($sqlstr, $params);
        return [
            "aprobados" => intval($res["aprobados"] ?? 0),
            "reprobados" => intval($res["reprobados"] ?? 0)
        ];
    }

    public static function obtenerEstadoSecciones($idFacultad = null, $idCampus = null)
    {
        $sqlstr = "SELECT s.estado, COUNT(*) AS total
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   INNER JOIN maestros mae ON s.id_maestro = mae.id_maestro
                   WHERE 1=1";
        
        $params = [];
        if ($idFacultad !== null && $idFacultad !== "") {
            $sqlstr .= " AND (m.id_facultad = :id_facultad OR c.id_facultad = :id_facultad)";
            $params["id_facultad"] = intval($idFacultad);
        }
        if ($idCampus !== null && $idCampus !== "") {
            $sqlstr .= " AND mae.id_campus = :id_campus";
            $params["id_campus"] = intval($idCampus);
        }

        $sqlstr .= " GROUP BY s.estado";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerPromediosSeccionesMaestro($idMaestro)
    {
        $sqlstr = "SELECT CONCAT(m.nombre, ' (', s.codigo_seccion, ')') AS materia, ROUND(AVG(cal.nota), 2) AS promedio
                   FROM calificaciones cal
                   INNER JOIN matriculas mt ON cal.id_matricula = mt.id_matricula
                   INNER JOIN secciones s ON mt.id_seccion = s.id_seccion
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   WHERE s.id_maestro = :id_maestro
                   GROUP BY s.id_seccion, m.nombre, s.codigo_seccion
                   ORDER BY promedio DESC";
        return self::obtenerRegistros($sqlstr, ["id_maestro" => intval($idMaestro)]);
    }
}
