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

    public static function obtenerDetalleCalificacion(int $idCalificacion)
    {
        $sqlstr = "SELECT c.*, mt.id_estudiante, mt.id_seccion, mt.id_periodo,
                          u.nombre AS nombre_estudiante, e.cuenta,
                          mat.codigo AS codigo_materia, mat.nombre AS nombre_materia,
                          sec.codigo_seccion, pa.nombre_periodo,
                          mae.id_maestro, um.nombre AS nombre_maestro
                   FROM calificaciones c
                   INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                   INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN secciones sec ON mt.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                   INNER JOIN maestros mae ON sec.id_maestro = mae.id_maestro
                   INNER JOIN usuarios um ON mae.id_usuario = um.id_usuario
                   WHERE c.id_calificacion = :id";
        return self::obtenerUnRegistro($sqlstr, ["id" => intval($idCalificacion)]);
    }

    public static function obtenerNotasPorDocente(int $idMaestro, ?int $idPeriodo = null): array
    {
        $params = ["id_maestro" => $idMaestro];
        $wherePeriodo = "";
        if ($idPeriodo !== null) {
            $wherePeriodo = " AND mt.id_periodo = :id_periodo";
            $params["id_periodo"] = $idPeriodo;
        }

        $sqlstr = "SELECT pa.nombre_periodo, sec.codigo_seccion,
                          mat.codigo AS codigo_materia, mat.nombre AS nombre_materia,
                          u.nombre AS nombre_estudiante, e.cuenta,
                          c.nota_parcial1, c.nota_parcial2, c.nota_parcial3, c.nota, c.observacion
                   FROM matriculas mt
                   INNER JOIN secciones sec ON mt.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                   LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                   WHERE sec.id_maestro = :id_maestro
                   $wherePeriodo
                   ORDER BY pa.fecha_inicio DESC, mat.nombre ASC, u.nombre ASC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerDetalleSeccion(int $idSeccion)
    {
        $sqlstr = "SELECT sec.*, mat.codigo AS codigo_materia, mat.nombre AS nombre_materia,
                          u.nombre AS nombre_maestro, pa.nombre_periodo
                   FROM secciones sec
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN maestros mae ON sec.id_maestro = mae.id_maestro
                   INNER JOIN usuarios u ON mae.id_usuario = u.id_usuario
                   INNER JOIN periodos_academicos pa ON sec.id_periodo = pa.id_periodo
                   WHERE sec.id_seccion = :id";
        return self::obtenerUnRegistro($sqlstr, ["id" => intval($idSeccion)]);
    }

    public static function obtenerNotasPorClase(int $idSeccion): array
    {
        $sqlstr = "SELECT mt.id_matricula, u.nombre AS nombre_estudiante, e.cuenta,
                          c.id_calificacion, c.nota_parcial1, c.nota_parcial2, c.nota_parcial3,
                          c.nota, c.observacion
                   FROM matriculas mt
                   INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                   WHERE mt.id_seccion = :id_seccion
                   ORDER BY u.nombre ASC";
        return self::obtenerRegistros($sqlstr, ["id_seccion" => intval($idSeccion)]);
    }

    public static function solicitarCorreccionNota(int $idCalificacion, array $nuevasNotas, string $motivo, int $idSolicitante): array
    {
        $actual = self::obtenerDetalleCalificacion($idCalificacion);
        if (!$actual) {
            return ["exito" => false, "mensaje" => "No se encontro la calificacion."];
        }

        $p1 = $nuevasNotas["parcial1"] ?? null;
        $p2 = $nuevasNotas["parcial2"] ?? null;
        $p3 = $nuevasNotas["parcial3"] ?? null;
        $promedio = (($p1 ?? 0) + ($p2 ?? 0) + ($p3 ?? 0)) / 3;

        $sql = "INSERT INTO solicitudes_correccion_notas
                (id_calificacion, id_matricula, id_maestro, id_solicitante,
                 nota_anterior, nota_nueva,
                 parcial1_anterior, parcial1_nueva,
                 parcial2_anterior, parcial2_nueva,
                 parcial3_anterior, parcial3_nueva,
                 motivo)
                VALUES
                (:id_calificacion, :id_matricula, :id_maestro, :id_solicitante,
                 :nota_anterior, :nota_nueva,
                 :p1_anterior, :p1_nueva,
                 :p2_anterior, :p2_nueva,
                 :p3_anterior, :p3_nueva,
                 :motivo)";

        $ok = self::executeNonQuery($sql, [
            "id_calificacion" => $idCalificacion,
            "id_matricula" => intval($actual["id_matricula"]),
            "id_maestro" => intval($actual["id_maestro"]),
            "id_solicitante" => $idSolicitante,
            "nota_anterior" => $actual["nota"],
            "nota_nueva" => round($promedio, 2),
            "p1_anterior" => $actual["nota_parcial1"],
            "p1_nueva" => $p1,
            "p2_anterior" => $actual["nota_parcial2"],
            "p2_nueva" => $p2,
            "p3_anterior" => $actual["nota_parcial3"],
            "p3_nueva" => $p3,
            "motivo" => $motivo
        ]);

        return [
            "exito" => $ok > 0,
            "mensaje" => $ok > 0 ? "Solicitud de correccion enviada para aprobacion." : "No se pudo registrar la solicitud."
        ];
    }

    public static function listarSolicitudesCorreccion(?int $idMaestro = null): array
    {
        $params = [];
        $where = "";
        if ($idMaestro !== null) {
            $where = " WHERE scn.id_maestro = :id_maestro";
            $params["id_maestro"] = $idMaestro;
        }

        $sqlstr = "SELECT scn.*, ue.nombre AS nombre_estudiante, e.cuenta,
                          mat.nombre AS nombre_materia, mat.codigo AS codigo_materia,
                          pa.nombre_periodo, us.nombre AS solicitante,
                          ua.nombre AS aprobador
                   FROM solicitudes_correccion_notas scn
                   INNER JOIN matriculas mt ON scn.id_matricula = mt.id_matricula
                   INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios ue ON e.id_usuario = ue.id_usuario
                   INNER JOIN secciones sec ON mt.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
                   INNER JOIN usuarios us ON scn.id_solicitante = us.id_usuario
                   LEFT JOIN usuarios ua ON scn.aprobado_por = ua.id_usuario
                   $where
                   ORDER BY scn.fecha_solicitud DESC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function resolverCorreccionNota(int $idSolicitud, string $accion, int $idAprobador, string $comentario = ""): array
    {
        $solicitud = self::obtenerUnRegistro(
            "SELECT * FROM solicitudes_correccion_notas WHERE id_solicitud = :id AND estado = 'pendiente'",
            ["id" => $idSolicitud]
        );
        if (!$solicitud) {
            return ["exito" => false, "mensaje" => "Solicitud no encontrada o ya resuelta."];
        }

        $conn = self::getConn();
        try {
            $conn->beginTransaction();
            if ($accion === "aprobar") {
                self::executeNonQuery(
                    "UPDATE calificaciones
                     SET nota = :nota,
                         nota_parcial1 = :p1,
                         nota_parcial2 = :p2,
                         nota_parcial3 = :p3,
                         observacion = CONCAT(COALESCE(observacion, ''), ' | Correccion aprobada'),
                         corregida = 1,
                         ultima_correccion = NOW(),
                         fecha_registro = NOW()
                     WHERE id_calificacion = :id_calificacion",
                    [
                        "nota" => $solicitud["nota_nueva"],
                        "p1" => $solicitud["parcial1_nueva"],
                        "p2" => $solicitud["parcial2_nueva"],
                        "p3" => $solicitud["parcial3_nueva"],
                        "id_calificacion" => $solicitud["id_calificacion"]
                    ],
                    $conn
                );
                $estado = "aprobada";
            } else {
                $estado = "rechazada";
            }

            self::executeNonQuery(
                "UPDATE solicitudes_correccion_notas
                 SET estado = :estado, fecha_resolucion = NOW(), aprobado_por = :aprobado_por,
                     comentario_resolucion = :comentario
                 WHERE id_solicitud = :id",
                [
                    "estado" => $estado,
                    "aprobado_por" => $idAprobador,
                    "comentario" => $comentario,
                    "id" => $idSolicitud
                ],
                $conn
            );

            $conn->commit();
            return ["exito" => true, "mensaje" => "Solicitud {$estado} correctamente."];
        } catch (\Throwable $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            return ["exito" => false, "mensaje" => "No se pudo resolver la solicitud."];
        }
    }
}
