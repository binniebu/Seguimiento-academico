<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

use PDOException;

class SeccionDao extends Table
{
    public static function obtenerPeriodoActivo()
    {
        $sqlstr = "SELECT *
                   FROM periodos_academicos
                   WHERE estado = 'activo'
                   ORDER BY fecha_inicio DESC, id_periodo DESC
                   LIMIT 1";
        return self::obtenerUnRegistro($sqlstr);
    }

    public static function obtenerPeriodoAnterior($idPeriodoActivo)
    {
        $periodoActivo = self::obtenerUnRegistro(
            "SELECT id_periodo, fecha_inicio FROM periodos_academicos WHERE id_periodo = :id_periodo",
            ["id_periodo" => $idPeriodoActivo]
        );

        if (!$periodoActivo) {
            return false;
        }

        $sqlstr = "SELECT *
                   FROM periodos_academicos
                   WHERE id_periodo <> :id_periodo
                     AND (
                         fecha_inicio < :fecha_inicio
                         OR id_periodo < :id_periodo_orden
                     )
                   ORDER BY fecha_inicio DESC, id_periodo DESC
                   LIMIT 1";

        return self::obtenerUnRegistro($sqlstr, [
            "id_periodo" => $idPeriodoActivo,
            "fecha_inicio" => $periodoActivo["fecha_inicio"],
            "id_periodo_orden" => $idPeriodoActivo
        ]);
    }

    public static function obtenerSecciones($buscar = "", $idPeriodo = null, $idFacultad = null, $naturaleza = "todas", $filtroCarrera = "todas")
    {
        $sqlstr = "SELECT s.id_seccion, s.codigo_seccion, s.id_materia, s.id_maestro, s.id_periodo,
                          s.aula, s.dias, s.hora_inicio, s.hora_fin, s.cupo_maximo, s.estado,
                          m.nombre AS nombre_materia, m.codigo AS codigo_materia,
                          u.nombre AS nombre_maestro,
                          f.nombre_facultad,
                          c.nombre_carrera,
                          (SELECT COUNT(*) FROM matriculas mt WHERE mt.id_seccion = s.id_seccion) AS cupo_actual
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   INNER JOIN maestros ma ON s.id_maestro = ma.id_maestro
                   INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   LEFT JOIN facultades f ON m.id_facultad = f.id_facultad
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   WHERE 1 = 1";

        $params = [];

        if ($buscar !== "") {
            $sqlstr .= " AND (
                            m.nombre LIKE :buscar
                            OR m.codigo LIKE :buscar
                            OR s.codigo_seccion LIKE :buscar
                            OR s.aula LIKE :buscar
                            OR u.nombre LIKE :buscar
                        )";
            $params["buscar"] = "%" . $buscar . "%";
        }

        if ($idPeriodo !== null) {
            $sqlstr .= " AND s.id_periodo = :id_periodo";
            $params["id_periodo"] = intval($idPeriodo);
        }

        if ($idFacultad !== null) {
            $sqlstr .= " AND (
                            m.tipo_materia = 'institucional'
                            OR m.id_facultad = :id_facultad
                            OR c.id_facultad = :id_facultad
                        )";
            $params["id_facultad"] = intval($idFacultad);
        }

        if ($naturaleza !== "todas" && $naturaleza !== "") {
            if ($naturaleza === "institucional") {
                $sqlstr .= " AND m.tipo_materia = 'institucional'";
            } elseif ($naturaleza === "facultad") {
                $sqlstr .= " AND m.tipo_materia = 'facultad'";
            } elseif ($naturaleza === "carrera") {
                $sqlstr .= " AND m.tipo_materia = 'carrera'";
                if ($filtroCarrera !== "todas" && $filtroCarrera !== "") {
                    $sqlstr .= " AND m.id_carrera = :filtro_carrera";
                    $params["filtro_carrera"] = intval($filtroCarrera);
                }
            }
        } else {
            if ($filtroCarrera !== "todas" && $filtroCarrera !== "") {
                $sqlstr .= " AND m.tipo_materia = 'carrera' AND m.id_carrera = :filtro_carrera";
                $params["filtro_carrera"] = intval($filtroCarrera);
            }
        }

        $sqlstr .= " ORDER BY m.nombre ASC, s.dias ASC, s.hora_inicio ASC";

        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function obtenerSeccionPorId($idSeccion)
    {
        $sqlstr = "SELECT s.*, m.nombre AS nombre_materia, m.codigo AS codigo_materia,
                          m.tipo_materia, m.id_facultad AS id_facultad_materia,
                          c.id_facultad AS id_facultad_carrera,
                          u.nombre AS nombre_maestro
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   INNER JOIN maestros ma ON s.id_maestro = ma.id_maestro
                   INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   WHERE s.id_seccion = :id_seccion";
        return self::obtenerUnRegistro($sqlstr, ["id_seccion" => $idSeccion]);
    }

    public static function obtenerMateriasProgramables($idFacultad = null)
    {
        $sqlstr = "SELECT m.id_materia, m.codigo, m.nombre, m.tipo_materia,
                          f.nombre_facultad, c.nombre_carrera,
                          m.id_facultad, m.id_carrera
                   FROM materias m
                   LEFT JOIN facultades f ON m.id_facultad = f.id_facultad
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   WHERE m.estado = 'activa'";

        $params = [];
        if ($idFacultad !== null) {
            $sqlstr .= " AND (
                            m.tipo_materia = 'institucional'
                            OR m.id_facultad = :id_facultad
                            OR c.id_facultad = :id_facultad
                        )";
            $params["id_facultad"] = intval($idFacultad);
        }

        $sqlstr .= " ORDER BY m.codigo ASC, m.nombre ASC";
        return self::obtenerRegistros($sqlstr, $params);
    }

    public static function materiaDisponibleParaFacultad($idMateria, $idFacultad = null)
    {
        if ($idFacultad === null) {
            return (bool) self::obtenerUnRegistro(
                "SELECT id_materia FROM materias WHERE id_materia = :id_materia AND estado = 'activa'",
                ["id_materia" => $idMateria]
            );
        }

        $sqlstr = "SELECT m.id_materia
                   FROM materias m
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   WHERE m.id_materia = :id_materia
                     AND m.estado = 'activa'
                     AND (
                         m.tipo_materia = 'institucional'
                         OR m.id_facultad = :id_facultad
                         OR c.id_facultad = :id_facultad
                     )";

        return (bool) self::obtenerUnRegistro($sqlstr, [
            "id_materia" => $idMateria,
            "id_facultad" => $idFacultad
        ]);
    }

    public static function obtenerMaestrosSeleccionables($excluirCoordinadores = true)
    {
        $sqlstr = "SELECT ma.id_maestro, ma.numero_empleado AS codigo, u.nombre, u.correo,
                          ma.id_facultad, ma.id_carrera
                   FROM maestros ma
                   INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   WHERE u.estado = 'activo'";

        if ($excluirCoordinadores) {
            $sqlstr .= " AND NOT EXISTS (
                            SELECT 1
                            FROM coordinadores co
                            WHERE co.id_usuario = ma.id_usuario
                        )";
        }

        $sqlstr .= " ORDER BY u.nombre ASC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function maestroPuedeImpartir($idMaestro, $excluirCoordinadores = true)
    {
        $sqlstr = "SELECT ma.id_maestro
                   FROM maestros ma
                   INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario
                   WHERE ma.id_maestro = :id_maestro
                     AND u.estado = 'activo'";

        if ($excluirCoordinadores) {
            $sqlstr .= " AND NOT EXISTS (
                            SELECT 1
                            FROM coordinadores co
                            WHERE co.id_usuario = ma.id_usuario
                        )";
        }

        return (bool) self::obtenerUnRegistro($sqlstr, ["id_maestro" => $idMaestro]);
    }

    public static function existeCodigoSeccion($codigoSeccion, $excluirId = null)
    {
        $sqlstr = "SELECT COUNT(*) AS total FROM secciones WHERE codigo_seccion = :codigo_seccion";
        $params = ["codigo_seccion" => $codigoSeccion];

        if ($excluirId !== null) {
            $sqlstr .= " AND id_seccion <> :id_seccion";
            $params["id_seccion"] = $excluirId;
        }

        $resultado = self::obtenerUnRegistro($sqlstr, $params);
        return intval($resultado["total"] ?? 0) > 0;
    }

    public static function crearSeccion($idMateria, $idMaestro, $idPeriodo, $codigoSeccion, $aula, $dias, $horaInicio, $horaFin, $cupoMaximo, $estado = "Borrador")
    {
        $sqlstr = "INSERT INTO secciones
                       (codigo_seccion, id_materia, id_maestro, id_periodo, aula, dias, hora_inicio, hora_fin, cupo_maximo, estado)
                   VALUES
                       (:codigo_seccion, :id_materia, :id_maestro, :id_periodo, :aula, :dias, :hora_inicio, :hora_fin, :cupo_maximo, :estado)";

        return self::executeNonQuery($sqlstr, [
            "codigo_seccion" => $codigoSeccion,
            "id_materia" => intval($idMateria),
            "id_maestro" => intval($idMaestro),
            "id_periodo" => intval($idPeriodo),
            "aula" => $aula,
            "dias" => $dias,
            "hora_inicio" => $horaInicio,
            "hora_fin" => $horaFin,
            "cupo_maximo" => intval($cupoMaximo),
            "estado" => $estado
        ]);
    }

    public static function actualizarSeccion($idSeccion, $idMateria, $idMaestro, $codigoSeccion, $aula, $dias, $horaInicio, $horaFin, $cupoMaximo, $estado)
    {
        $sqlstr = "UPDATE secciones
                   SET codigo_seccion = :codigo_seccion,
                       id_materia = :id_materia,
                       id_maestro = :id_maestro,
                       aula = :aula,
                       dias = :dias,
                       hora_inicio = :hora_inicio,
                       hora_fin = :hora_fin,
                       cupo_maximo = :cupo_maximo,
                       estado = :estado
                   WHERE id_seccion = :id_seccion";

        return self::executeNonQuery($sqlstr, [
            "id_seccion" => intval($idSeccion),
            "codigo_seccion" => $codigoSeccion,
            "id_materia" => intval($idMateria),
            "id_maestro" => intval($idMaestro),
            "aula" => $aula,
            "dias" => $dias,
            "hora_inicio" => $horaInicio,
            "hora_fin" => $horaFin,
            "cupo_maximo" => intval($cupoMaximo),
            "estado" => $estado
        ]);
    }

    public static function eliminarSeccion($idSeccion)
    {
        $sqlstr = "DELETE FROM secciones WHERE id_seccion = :id_seccion";
        return self::executeNonQuery($sqlstr, ["id_seccion" => intval($idSeccion)]);
    }

    public static function activarBorradores($idPeriodo, $idFacultad = null)
    {
        $sqlstr = "UPDATE secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
                   SET s.estado = 'Activa'
                   WHERE s.id_periodo = :id_periodo
                     AND s.estado = 'Borrador'";

        $params = ["id_periodo" => intval($idPeriodo)];

        if ($idFacultad !== null) {
            $sqlstr .= " AND (
                            m.tipo_materia = 'institucional'
                            OR m.id_facultad = :id_facultad
                            OR c.id_facultad = :id_facultad
                        )";
            $params["id_facultad"] = intval($idFacultad);
        }

        return self::executeNonQueryRows($sqlstr, $params);
    }

    public static function buscarChoqueAula($idPeriodo, $aula, $dias, $horaInicio, $horaFin, $excluirId = null)
    {
        $sqlstr = "SELECT s.id_seccion, s.codigo_seccion, s.dias, s.hora_inicio, s.hora_fin,
                          m.nombre AS nombre_materia
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   WHERE s.id_periodo = :id_periodo
                     AND LOWER(s.aula) = LOWER(:aula)";

        $params = [
            "id_periodo" => intval($idPeriodo),
            "aula" => trim($aula)
        ];

        if ($excluirId !== null) {
            $sqlstr .= " AND s.id_seccion <> :id_seccion";
            $params["id_seccion"] = intval($excluirId);
        }

        $secciones = self::obtenerRegistros($sqlstr, $params);
        return self::primerTraslape($secciones, $dias, $horaInicio, $horaFin);
    }

    public static function buscarChoqueMaestro($idPeriodo, $idMaestro, $dias, $horaInicio, $horaFin, $excluirId = null)
    {
        $sqlstr = "SELECT s.id_seccion, s.codigo_seccion, s.dias, s.hora_inicio, s.hora_fin,
                          m.nombre AS nombre_materia
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   WHERE s.id_periodo = :id_periodo
                     AND s.id_maestro = :id_maestro";

        $params = [
            "id_periodo" => intval($idPeriodo),
            "id_maestro" => intval($idMaestro)
        ];

        if ($excluirId !== null) {
            $sqlstr .= " AND s.id_seccion <> :id_seccion";
            $params["id_seccion"] = intval($excluirId);
        }

        $secciones = self::obtenerRegistros($sqlstr, $params);
        return self::primerTraslape($secciones, $dias, $horaInicio, $horaFin);
    }

    public static function existeSeccionEquivalente($idPeriodo, $idMateria, $idMaestro, $aula, $dias, $horaInicio, $horaFin)
    {
        $sqlstr = "SELECT id_seccion
                   FROM secciones
                   WHERE id_periodo = :id_periodo
                     AND id_materia = :id_materia
                     AND id_maestro = :id_maestro
                     AND LOWER(aula) = LOWER(:aula)
                     AND dias = :dias
                     AND hora_inicio = :hora_inicio
                     AND hora_fin = :hora_fin
                   LIMIT 1";

        return (bool) self::obtenerUnRegistro($sqlstr, [
            "id_periodo" => intval($idPeriodo),
            "id_materia" => intval($idMateria),
            "id_maestro" => intval($idMaestro),
            "aula" => trim($aula),
            "dias" => $dias,
            "hora_inicio" => $horaInicio,
            "hora_fin" => $horaFin
        ]);
    }

    public static function clonarPeriodoAnterior($idPeriodoOrigen, $idPeriodoDestino, $idFacultad = null)
    {
        $origen = self::obtenerSecciones("", $idPeriodoOrigen, $idFacultad);
        $copiadas = 0;
        $omitidas = 0;

        $conn = self::getConn();

        try {
            $conn->beginTransaction();

            foreach ($origen as $seccion) {
                $dias = self::normalizarDias($seccion["dias"]);

                if (self::existeSeccionEquivalente(
                    $idPeriodoDestino,
                    $seccion["id_materia"],
                    $seccion["id_maestro"],
                    $seccion["aula"],
                    $dias,
                    $seccion["hora_inicio"],
                    $seccion["hora_fin"]
                )) {
                    $omitidas++;
                    continue;
                }

                if (self::buscarChoqueAula($idPeriodoDestino, $seccion["aula"], $dias, $seccion["hora_inicio"], $seccion["hora_fin"])) {
                    $omitidas++;
                    continue;
                }

                if (self::buscarChoqueMaestro($idPeriodoDestino, $seccion["id_maestro"], $dias, $seccion["hora_inicio"], $seccion["hora_fin"])) {
                    $omitidas++;
                    continue;
                }

                $codigo = self::generarCodigoClonado($seccion["codigo_seccion"], $idPeriodoDestino);

                $sqlstr = "INSERT INTO secciones
                               (codigo_seccion, id_materia, id_maestro, id_periodo, aula, dias, hora_inicio, hora_fin, cupo_maximo, estado)
                           VALUES
                               (:codigo_seccion, :id_materia, :id_maestro, :id_periodo, :aula, :dias, :hora_inicio, :hora_fin, :cupo_maximo, 'Borrador')";

                self::executeNonQuery($sqlstr, [
                    "codigo_seccion" => $codigo,
                    "id_materia" => intval($seccion["id_materia"]),
                    "id_maestro" => intval($seccion["id_maestro"]),
                    "id_periodo" => intval($idPeriodoDestino),
                    "aula" => $seccion["aula"],
                    "dias" => $dias,
                    "hora_inicio" => $seccion["hora_inicio"],
                    "hora_fin" => $seccion["hora_fin"],
                    "cupo_maximo" => intval($seccion["cupo_maximo"])
                ], $conn);

                $copiadas++;
            }

            $conn->commit();

            return [
                "exito" => true,
                "copiadas" => $copiadas,
                "omitidas" => $omitidas
            ];
        } catch (PDOException $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }

            return [
                "exito" => false,
                "copiadas" => $copiadas,
                "omitidas" => $omitidas
            ];
        }
    }

    public static function usuarioPuedeGestionarSeccion($idSeccion, $idFacultad = null)
    {
        if ($idFacultad === null) {
            return true;
        }

        $seccion = self::obtenerSeccionPorId($idSeccion);
        if (!$seccion) {
            return false;
        }

        return $seccion["tipo_materia"] === "institucional"
            || intval($seccion["id_facultad_materia"] ?? 0) === intval($idFacultad)
            || intval($seccion["id_facultad_carrera"] ?? 0) === intval($idFacultad);
    }

    public static function normalizarDias($dias)
    {
        $orden = ["Lu", "Ma", "Mi", "Ju", "Vi", "Sa", "Do"];
        $valor = is_array($dias) ? implode(",", $dias) : (string) $dias;
        $valor = str_replace(["-", ";", " "], ",", $valor);
        $partes = array_filter(array_map("trim", explode(",", $valor)));
        $seleccionados = [];

        foreach ($orden as $dia) {
            if (in_array($dia, $partes, true)) {
                $seleccionados[] = $dia;
            }
        }

        return implode(",", $seleccionados);
    }

    private static function primerTraslape($secciones, $dias, $horaInicio, $horaFin)
    {
        $diasNuevos = array_filter(explode(",", self::normalizarDias($dias)));
        $inicioNuevo = strtotime($horaInicio);
        $finNuevo = strtotime($horaFin);

        foreach ($secciones as $seccion) {
            $diasExistentes = array_filter(explode(",", self::normalizarDias($seccion["dias"])));
            $comparteDia = count(array_intersect($diasNuevos, $diasExistentes)) > 0;
            $traslapaHora = strtotime($seccion["hora_inicio"]) < $finNuevo
                && strtotime($seccion["hora_fin"]) > $inicioNuevo;

            if ($comparteDia && $traslapaHora) {
                return $seccion;
            }
        }

        return false;
    }

    private static function generarCodigoClonado($codigoBase, $idPeriodoDestino)
    {
        $base = strtoupper(preg_replace('/[^A-Z0-9]/i', '', (string) $codigoBase));
        $base = substr($base !== "" ? $base : "SEC", 0, 12);
        $sufijo = "P" . intval($idPeriodoDestino);
        $codigo = substr($base . "-" . $sufijo, 0, 20);
        $contador = 1;

        while (self::existeCodigoSeccion($codigo)) {
            $extra = "-" . $contador;
            $codigo = substr($base, 0, 20 - strlen($sufijo) - strlen($extra) - 1) . "-" . $sufijo . $extra;
            $contador++;
        }

        return $codigo;
    }

    public static function extenderCupo($idSeccion, $incremento = 5)
    {
        $sqlstr = "UPDATE secciones 
                   SET cupo_maximo = cupo_maximo + :incremento 
                   WHERE id_seccion = :id_seccion";
        return self::executeNonQuery($sqlstr, [
            "incremento" => intval($incremento),
            "id_seccion" => intval($idSeccion)
        ]);
    }

    /**
     * Devuelve todas las secciones asignadas a un maestro en un periodo específico.
     * Utilizado por la vista "Mis Secciones" del rol maestro.
     */
    public static function obtenerSeccionesPorMaestro($idMaestro, $idPeriodo)
    {
        $sqlstr = "SELECT
                       sec.id_seccion,
                       sec.codigo_seccion,
                       sec.aula,
                       sec.dias,
                       sec.hora_inicio,
                       sec.hora_fin,
                       sec.cupo_maximo,
                       (SELECT COUNT(*) FROM matriculas mt
                        WHERE mt.id_seccion = sec.id_seccion
                          AND mt.id_periodo = :id_periodo2) AS cupo_actual,
                       sec.estado,
                       m.codigo        AS codigo_materia,
                       m.nombre        AS nombre_materia,
                       m.creditos,
                       f.nombre_facultad AS nombre_facultad,
                       c.nombre_carrera,
                       u.nombre        AS nombre_maestro
                   FROM secciones sec
                   INNER JOIN materias m   ON sec.id_materia = m.id_materia
                   INNER JOIN maestros mae ON sec.id_maestro = mae.id_maestro
                   INNER JOIN usuarios u   ON mae.id_usuario = u.id_usuario
                   LEFT  JOIN facultades f ON m.id_facultad  = f.id_facultad
                   LEFT  JOIN carreras c   ON m.id_carrera   = c.id_carrera
                   WHERE sec.id_maestro = :id_maestro
                     AND sec.id_periodo = :id_periodo
                   ORDER BY m.nombre ASC";
        return self::obtenerRegistros($sqlstr, [
            "id_maestro"  => $idMaestro,
            "id_periodo"  => $idPeriodo,
            "id_periodo2" => $idPeriodo,   // PDO no permite reusar el mismo parámetro nombrado
        ]);
    }

    /**
     * Devuelve el historial de secciones dictadas por el maestro en periodos pasados.
     */
    public static function obtenerHistorialSeccionesMaestro($idMaestro)
    {
        $sqlstr = "SELECT
                       sec.id_seccion,
                       sec.codigo_seccion,
                       sec.aula,
                       sec.dias,
                       sec.hora_inicio,
                       sec.hora_fin,
                       sec.cupo_maximo,
                       (SELECT COUNT(*) FROM matriculas mt WHERE mt.id_seccion = sec.id_seccion) AS cupo_actual,
                       sec.estado,
                       m.codigo        AS codigo_materia,
                       m.nombre        AS nombre_materia,
                       m.creditos,
                       pa.nombre_periodo AS periodo,
                       pa.fecha_inicio
                   FROM secciones sec
                   INNER JOIN materias m   ON sec.id_materia = m.id_materia
                   INNER JOIN maestros mae ON sec.id_maestro = mae.id_maestro
                   INNER JOIN periodos_academicos pa ON sec.id_periodo = pa.id_periodo
                   WHERE sec.id_maestro = :id_maestro
                     AND pa.estado = 'inactivo'
                   ORDER BY pa.fecha_inicio DESC, m.nombre ASC";
        return self::obtenerRegistros($sqlstr, ["id_maestro" => $idMaestro]);
    }
}
