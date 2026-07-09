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
        $sqlstr = "SELECT c.id_calificacion, c.id_matricula, c.nota, c.observacion, c.fecha_registro,
                          u.nombre as nombre_estudiante, m.nombre as nombre_materia, pa.nombre_periodo as periodo
                   FROM calificaciones c
                   INNER JOIN matriculas mat ON c.id_matricula = mat.id_matricula
                   INNER JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN secciones sec ON mat.id_seccion = sec.id_seccion
                   INNER JOIN materias m ON sec.id_materia = m.id_materia
                   INNER JOIN periodos_academicos pa ON mat.id_periodo = pa.id_periodo";
        
        $sqlstrCount = "SELECT COUNT(*) as count 
                        FROM calificaciones c
                        INNER JOIN matriculas mat ON c.id_matricula = mat.id_matricula
                        INNER JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                        INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                        INNER JOIN secciones sec ON mat.id_seccion = sec.id_seccion
                        INNER JOIN materias m ON sec.id_materia = m.id_materia";
        
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

    public static function getMatriculasDisponibles()
    {
        $sqlstr = "SELECT m.id_matricula, u.nombre as nombre_estudiante, mat.nombre as nombre_materia, pa.nombre_periodo as periodo
                   FROM matriculas m
                   INNER JOIN estudiantes e ON m.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN secciones sec ON m.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN periodos_academicos pa ON m.id_periodo = pa.id_periodo";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerCalificacionesEstudiante($idEstudiante, $idPeriodo)
    {
        $sqlstr = "SELECT mt.id_matricula, m.codigo as codigo_materia, m.nombre as nombre_materia,
                          m.creditos, sec.codigo_seccion,
                          c.nota, c.nota_parcial1, c.nota_parcial2, c.nota_parcial3, c.observacion
                   FROM matriculas mt
                   INNER JOIN secciones sec ON mt.id_seccion = sec.id_seccion
                   INNER JOIN materias m ON sec.id_materia = m.id_materia
                   INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                   LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                   WHERE mt.id_estudiante = :id_estudiante
                     AND pa.id_periodo = :id_periodo
                     AND DATE(NOW()) <= DATE_ADD(pa.fecha_fin, INTERVAL 7 DAY)
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr, [
            "id_estudiante" => intval($idEstudiante),
            "id_periodo" => intval($idPeriodo)
        ]);
    }

    /**
     * Devuelve las secciones asignadas a un maestro en el período activo,
     * incluyendo el total de alumnos inscritos. Usada para las cards de la vista de notas.
     */
    public static function obtenerSeccionesMaestro(int $idMaestro, int $idPeriodo): array
    {
        $sqlstr = "SELECT s.id_seccion, s.codigo_seccion, s.aula, s.dias, s.hora_inicio, s.hora_fin, s.estado,
                          m.codigo AS codigo_materia, m.nombre AS nombre_materia, m.creditos,
                          COUNT(mt.id_matricula) AS total_inscritos,
                          SUM(CASE WHEN c.id_calificacion IS NOT NULL THEN 1 ELSE 0 END) AS total_con_nota
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   INNER JOIN maestros ma ON s.id_maestro = ma.id_maestro
                   LEFT JOIN matriculas mt ON s.id_seccion = mt.id_seccion AND mt.id_periodo = :id_periodo
                   LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                   WHERE ma.id_maestro = :id_maestro
                     AND s.id_periodo = :id_periodo2
                   GROUP BY s.id_seccion
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr, [
            "id_maestro"  => $idMaestro,
            "id_periodo"  => $idPeriodo,
            "id_periodo2" => $idPeriodo
        ]);
    }

    /**
     * Devuelve la lista de alumnos matriculados en una sección,
     * con sus notas parciales y promedio actuales (si existen).
     */
    public static function obtenerAlumnosPorSeccion(int $idSeccion, int $idPeriodo): array
    {
        $sqlstr = "SELECT mt.id_matricula,
                          u.nombre AS nombre_estudiante,
                          e.cuenta AS numero_cuenta,
                          c.id_calificacion,
                          c.nota_parcial1,
                          c.nota_parcial2,
                          c.nota_parcial3,
                          c.nota AS promedio,
                          c.observacion
                   FROM matriculas mt
                   INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                   WHERE mt.id_seccion = :id_seccion
                     AND mt.id_periodo = :id_periodo
                   ORDER BY u.nombre ASC";
        return self::obtenerRegistros($sqlstr, [
            "id_seccion" => $idSeccion,
            "id_periodo" => $idPeriodo
        ]);
    }

    /**
     * Inserta o actualiza las notas parciales de un alumno en una matrícula.
     * Calcula el promedio como (p1 + p2 + p3) / 3 y lo guarda en el campo 'nota'.
     *
     * @param int        $idMatricula  ID de la matrícula
     * @param float|null $p1           Nota del I Parcial (0-100)
     * @param float|null $p2           Nota del II Parcial (0-100)
     * @param float|null $p3           Nota del III Parcial (0-100)
     * @param string     $observacion  Observación opcional
     * @return array ['exito' => bool, 'promedio' => float|null]
     */
    public static function guardarNotasParciales(int $idMatricula, ?float $p1, ?float $p2, ?float $p3, string $observacion = ""): array
    {
        // Si todos los parciales son nulos, no se calcula promedio (es null)
        if ($p1 === null && $p2 === null && $p3 === null) {
            $promedio = null;
        } else {
            // El promedio se calcula sumando las notas y dividiendo siempre entre 3, asumiendo 0 para los no ingresados.
            $val1 = $p1 !== null ? $p1 : 0.0;
            $val2 = $p2 !== null ? $p2 : 0.0;
            $val3 = $p3 !== null ? $p3 : 0.0;
            $promedio = ($val1 + $val2 + $val3) / 3.0;
        }

        // Verificar si ya existe un registro de calificación para esta matrícula
        $existente = self::obtenerUnRegistro(
            "SELECT id_calificacion FROM calificaciones WHERE id_matricula = :id",
            ["id" => $idMatricula]
        );

        if ($existente) {
            $sql = "UPDATE calificaciones
                    SET nota_parcial1 = :p1,
                        nota_parcial2 = :p2,
                        nota_parcial3 = :p3,
                        nota          = :promedio,
                        observacion   = :obs,
                        fecha_registro = NOW()
                    WHERE id_matricula = :id_matricula";
        } else {
            $sql = "INSERT INTO calificaciones (id_matricula, nota_parcial1, nota_parcial2, nota_parcial3, nota, observacion, fecha_registro)
                    VALUES (:id_matricula, :p1, :p2, :p3, :promedio, :obs, NOW())";
        }

        $rows = self::executeNonQuery($sql, [
            "id_matricula" => $idMatricula,
            "p1"           => $p1,
            "p2"           => $p2,
            "p3"           => $p3,
            "promedio"     => $promedio,
            "obs"          => $observacion
        ]);

        return [
            "exito"    => $rows > 0,
            "promedio" => $promedio !== null ? round($promedio, 2) : null
        ];
    }
}
