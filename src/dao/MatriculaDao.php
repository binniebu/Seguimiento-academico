<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class MatriculaDao extends Table
{
    public static function listarMatriculas($buscar = "", $idFacultad = null)
    {
        $sqlstr = "SELECT m.id_matricula, m.fecha_matricula,
                          u.nombre AS estudiante_nombre, e.cuenta AS estudiante_dni,
                          c.nombre_carrera,
                          sec.codigo_seccion, mat.nombre AS materia_nombre,
                          pa.nombre_periodo
                   FROM matriculas m
                   INNER JOIN estudiantes e ON m.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN secciones sec ON m.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN periodos_academicos pa ON m.id_periodo = pa.id_periodo
                   LEFT JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   WHERE 1=1";

        $params = [];
        if ($buscar !== "") {
            $sqlstr .= " AND (u.nombre LIKE :buscar OR e.cuenta LIKE :buscar OR mat.nombre LIKE :buscar OR sec.codigo_seccion LIKE :buscar)";
            $params["buscar"] = "%" . $buscar . "%";
        }

        if ($idFacultad !== null) {
            $sqlstr .= " AND (mat.id_facultad = :id_facultad OR c.id_facultad = :id_facultad)";
            $params["id_facultad"] = intval($idFacultad);
        }

        $sqlstr .= " ORDER BY m.id_matricula DESC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function registrarMatricula($idEstudiante, $idSeccion, $idPeriodo)
    {
        $sqlstr = "INSERT INTO matriculas (id_estudiante, id_seccion, id_periodo)
                   VALUES (:id_estudiante, :id_seccion, :id_periodo)";
        return self::executeNonQuery($sqlstr, [
            "id_estudiante" => intval($idEstudiante),
            "id_seccion" => intval($idSeccion),
            "id_periodo" => intval($idPeriodo)
        ]);
    }

    public static function cancelarMatricula($idMatricula)
    {
        $sqlstr = "DELETE FROM matriculas WHERE id_matricula = :id_matricula";
        return self::executeNonQuery($sqlstr, ["id_matricula" => intval($idMatricula)]);
    }

    public static function obtenerSeccionesMatriculadas($idEstudiante, $idPeriodo)
    {
        $sqlstr = "SELECT m.id_matricula, sec.id_seccion, sec.codigo_seccion, sec.aula, sec.dias, sec.hora_inicio, sec.hora_fin,
                          mat.nombre AS nombre_materia, mat.codigo AS codigo_materia, mat.creditos
                   FROM matriculas m
                   INNER JOIN secciones sec ON m.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   WHERE m.id_estudiante = :id_estudiante AND m.id_periodo = :id_periodo";
        return self::obtenerRegistros($sqlstr, [
            "id_estudiante" => intval($idEstudiante),
            "id_periodo" => intval($idPeriodo)
        ]);
    }

    public static function obtenerSeccionesDisponiblesParaEstudiante($idEstudiante, $idPeriodo, $idCarrera, $idFacultad)
    {
        $sqlstr = "SELECT sec.*, mat.nombre AS nombre_materia, mat.codigo AS codigo_materia, mat.creditos, mat.id_requisito,
                          u.nombre AS nombre_maestro,
                          (SELECT COUNT(*) FROM matriculas mt WHERE mt.id_seccion = sec.id_seccion) AS cupo_actual,
                          req.nombre AS nombre_requisito
                   FROM secciones sec
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   INNER JOIN maestros mae ON sec.id_maestro = mae.id_maestro
                   INNER JOIN usuarios u ON mae.id_usuario = u.id_usuario
                   LEFT JOIN materias req ON mat.id_requisito = req.id_materia
                   WHERE sec.id_periodo = :id_periodo
                     AND sec.estado = 'Activa'
                     AND (
                         mat.tipo_materia = 'institucional'
                         OR (mat.tipo_materia = 'facultad' AND mat.id_facultad = :id_facultad)
                         OR (mat.tipo_materia = 'carrera' AND mat.id_carrera = :id_carrera)
                     )
                     AND mat.id_materia NOT IN (
                         SELECT s2.id_materia 
                         FROM matriculas m2
                         INNER JOIN secciones s2 ON m2.id_seccion = s2.id_seccion
                         WHERE m2.id_estudiante = :id_estudiante AND m2.id_periodo = :id_periodo
                     )
                     AND mat.id_materia NOT IN (
                         SELECT s3.id_materia
                         FROM calificaciones cal
                         INNER JOIN matriculas m3 ON cal.id_matricula = m3.id_matricula
                         INNER JOIN secciones s3 ON m3.id_seccion = s3.id_seccion
                         WHERE m3.id_estudiante = :id_estudiante AND cal.nota >= 70.00
                     )";

        return self::obtenerRegistros($sqlstr, [
            "id_periodo" => intval($idPeriodo),
            "id_facultad" => intval($idFacultad),
            "id_carrera" => intval($idCarrera),
            "id_estudiante" => intval($idEstudiante)
        ]);
    }

    public static function verificarPrerrequisitoAprobado($idEstudiante, $idRequisito)
    {
        // idRequisito representa el id_materia del prerrequisito (materia exigida)
        if (empty($idRequisito)) {
            return true;
        }

        $sqlstr = "SELECT COUNT(*) AS total
                   FROM calificaciones cal
                   INNER JOIN matriculas m ON cal.id_matricula = m.id_matricula
                   INNER JOIN secciones sec ON m.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   WHERE m.id_estudiante = :id_estudiante
                     AND mat.id_materia = :id_requisito
                     AND cal.nota >= 70.00";

        $res = self::obtenerUnRegistro($sqlstr, [
            "id_estudiante" => intval($idEstudiante),
            "id_requisito" => intval($idRequisito)
        ]);

        return intval($res["total"] ?? 0) > 0;
    }


    public static function obtenerIdRequisitoDeSeccion($idSeccion): int|string|null
    {
        $sqlstr = "SELECT m.id_requisito
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   WHERE s.id_seccion = :id_seccion
                   LIMIT 1";
        $res = self::obtenerUnRegistro($sqlstr, ["id_seccion" => intval($idSeccion)]);
        return $res["id_requisito"] ?? null;
    }

    public static function obtenerNombreMateriaPorIdDePrerrequisitoDeSeccion($idSeccion): string
    {
        $idReq = self::obtenerIdRequisitoDeSeccion($idSeccion);
        if (empty($idReq)) {
            return "Prerrequisito";
        }
        $nombre = self::obtenerNombreMateriaPorId(intval($idReq));
        return $nombre["nombre"] ?? "Prerrequisito";
    }

    public static function verificarPrerrequisitoAprobadoPorSeccion($idEstudiante, $idSeccion): bool
    {
        $idReq = self::obtenerIdRequisitoDeSeccion($idSeccion);
        if (empty($idReq)) {
            return true;
        }

        $sqlstr = "SELECT COUNT(*) AS total
                   FROM calificaciones cal
                   INNER JOIN matriculas m ON cal.id_matricula = m.id_matricula
                   INNER JOIN secciones sec ON m.id_seccion = sec.id_seccion
                   INNER JOIN materias mat ON sec.id_materia = mat.id_materia
                   WHERE m.id_estudiante = :id_estudiante
                     AND mat.id_materia = :id_requisito
                     AND cal.nota >= 70.00";

        $res = self::obtenerUnRegistro($sqlstr, [
            "id_estudiante" => intval($idEstudiante),
            "id_requisito" => intval($idReq)
        ]);

        return intval($res["total"] ?? 0) > 0;
    }

    public static function verificarConflictoHorario($idEstudiante, $idPeriodo, $idSeccion)
    {

        $sqlSec = "SELECT dias, hora_inicio, hora_fin FROM secciones WHERE id_seccion = :id_seccion";
        $target = self::obtenerUnRegistro($sqlSec, ["id_seccion" => $idSeccion]);
        if (!$target) {
            return true;
        }

        $diasNuevos = array_filter(explode(",", str_replace(" ", "", strtolower($target["dias"]))));
        $inicioNuevo = strtotime($target["hora_inicio"]);
        $finNuevo = strtotime($target["hora_fin"]);

        $yaMatriculadas = self::obtenerSeccionesMatriculadas($idEstudiante, $idPeriodo);

        foreach ($yaMatriculadas as $m) {
            $diasExistentes = array_filter(explode(",", str_replace(" ", "", strtolower($m["dias"]))));
            $comparteDia = count(array_intersect($diasNuevos, $diasExistentes)) > 0;
            $traslapaHora = strtotime($m["hora_inicio"]) < $finNuevo
                && strtotime($m["hora_fin"]) > $inicioNuevo;

            if ($comparteDia && $traslapaHora) {
                return $m;
            }
        }

        return false;
    }

    public static function obtenerEstudiantePorUsuario($idUsuario)
    {
        $sqlstr = "SELECT e.*, u.nombre, u.correo, c.id_facultad, c.id_carrera, c.nombre_carrera
                   FROM estudiantes e
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   LEFT JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
                   WHERE e.id_usuario = :id_usuario LIMIT 1";
        return self::obtenerUnRegistro($sqlstr, ["id_usuario" => $idUsuario]);
    }

    public static function obtenerFacultadCoordinadorPorUsuario($idUsuario)
    {
        $sqlstr = "SELECT id_facultad FROM coordinadores WHERE id_usuario = :id";
        return self::obtenerUnRegistro($sqlstr, ["id" => intval($idUsuario)]);
    }

    public static function obtenerMateriaPorIdMateria($idMateria)
    {
        $sqlstr = "
            SELECT m.id_facultad, m.id_carrera, c.id_facultad AS carrera_facultad
            FROM materias m
            LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
            WHERE m.id_materia = :id_materia
            LIMIT 1
        ";
        return self::obtenerUnRegistro($sqlstr, ["id_materia" => intval($idMateria)]);
    }

    public static function obtenerNombreMateriaPorId($idMateria)
    {
        $sqlstr = "SELECT nombre FROM materias WHERE id_materia = :id";
        return self::obtenerUnRegistro($sqlstr, ["id" => intval($idMateria)]);
    }
}


