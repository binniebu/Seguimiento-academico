<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

use Throwable;

class UsuarioDao extends Table
{
   public static function registrarUsuario($nombre, $correo, $password, $idRol)
{
    $sqlstr = "INSERT INTO usuarios (nombre, correo, password, id_rol, estado)
               VALUES (:nombre, :correo, :password, :id_rol, 'activo')";

    $params = array(
        "nombre" => $nombre,
        "correo" => $correo,
        "password" => password_hash($password, PASSWORD_DEFAULT),
        "id_rol" => intval($idRol)
    );

    self::executeNonQuery($sqlstr, $params);

    $usuario = self::obtenerUnRegistro(
        "SELECT id_usuario FROM usuarios WHERE correo = :correo",
        array("correo" => $correo)
    );

    return intval($usuario["id_usuario"]);
}

    public static function registrarEstudianteDesdeUsuario($idUsuario, $cuenta, $carrera, $telefono)
{
    $sqlstr = "INSERT INTO estudiantes (id_usuario, cuenta, carrera, telefono)
               VALUES (:id_usuario, :cuenta, :carrera, :telefono)";

    $params = array(
        "id_usuario" => $idUsuario,
        "cuenta" => $cuenta,
        "carrera" => $carrera,
        "telefono" => $telefono
    );

    return self::executeNonQuery($sqlstr, $params);
   }

    public static function existeCorreo($correo)
    {
        $sqlstr = "SELECT * FROM usuarios WHERE correo = :correo";

        $params = array(
            "correo" => $correo
        );

        return self::obtenerUnRegistro($sqlstr, $params);
    }

    public static function obtenerUsuarioPorCorreo($correo)
    {
        $sqlstr = "SELECT u.*, r.nombre_rol 
                   FROM usuarios u
                   INNER JOIN roles r ON u.id_rol = r.id_rol
                   WHERE u.correo = :correo
                   AND u.estado = 'activo'";

        $params = array(
            "correo" => $correo
        );

        return self::obtenerUnRegistro($sqlstr, $params);
    }

    public static function getResumenMatriculasGlobal()
    {
        $sqlstr = "SELECT
                    (SELECT COUNT(*) FROM estudiantes) AS total_estudiantes_sistema,
                    (SELECT COUNT(DISTINCT id_estudiante) FROM matriculas WHERE estado = 'activa') AS estudiantes_con_matricula_activa,
                    (SELECT COUNT(*) FROM matriculas) AS total_cupos_matriculados";

        return self::obtenerUnRegistro($sqlstr, array());
    }

    public static function getReporteMateriasYPromedios()
    {
        $sqlstr = "SELECT
                    ma.codigo,
                    ma.nombre AS materia,
                    COUNT(c.id_calificacion) AS evaluaciones_registradas,
                    ROUND(AVG(c.nota), 2) AS promedio_nota,
                    MAX(c.nota) AS nota_mas_alta,
                    MIN(c.nota) AS nota_mas_baja
                  FROM materias ma
                  LEFT JOIN matriculas mt ON ma.id_materia = mt.id_materia
                  LEFT JOIN calificaciones c ON mt.id_matricula = c.id_matricula
                  GROUP BY ma.id_materia, ma.codigo, ma.nombre";

        return self::obtenerRegistros($sqlstr, array());
    }

    public static function getReporteEstudiantes()
    {
        $sqlstr = "SELECT
                    u.nombre AS estudiante,
                    e.cuenta,
                    ma.nombre AS materia,
                    c.nota
                  FROM calificaciones c
                  INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
                  INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
                  INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                  INNER JOIN materias ma ON mt.id_materia = ma.id_materia
                  ORDER BY u.nombre";

        return self::obtenerRegistros($sqlstr, array());
    }
    public static function getUsers($buscar = "", $estado = "", $orderBy = "id_usuario", $descending = false, $page = 0, $itemsPerPage = 10)
    {
        $offset = $page * $itemsPerPage;
        $orderDirection = $descending ? "DESC" : "ASC";

        $where = " WHERE 1=1 ";
        $params = array();

       if ($buscar !== "") {
           $where .= " AND (u.nombre LIKE :buscar OR u.correo LIKE :buscar) ";
           $params["buscar"] = "%" . $buscar . "%";
    }

    if ($estado !== "") {
        $where .= " AND u.estado = :estado ";
        $params["estado"] = $estado;
    }

    $sqlTotal = "SELECT COUNT(*) AS total
                 FROM usuarios u
                 INNER JOIN roles r ON u.id_rol = r.id_rol
                 " . $where;

    $totalRegistro = self::obtenerUnRegistro($sqlTotal, $params);
    $total = intval($totalRegistro["total"] ?? 0);

    $sqlstr = "SELECT 
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.estado,
                    u.fecha_creacion,
                    r.nombre_rol
               FROM usuarios u
               INNER JOIN roles r ON u.id_rol = r.id_rol
               " . $where . "
               ORDER BY u." . $orderBy . " " . $orderDirection . "
               LIMIT " . intval($itemsPerPage) . " OFFSET " . intval($offset);

        $usuarios = self::obtenerRegistros($sqlstr, $params);

        return array(
        "usuarios" => $usuarios,
        "total" => $total,
        "itemsPerPage" => $itemsPerPage
    );
   }

    public static function getReporteMaestros()
{
    $sqlstr = "SELECT
                u.nombre AS maestro,
                m.codigo AS codigo_maestro,
                COALESCE(ma.nombre, 'Sin asignar') AS materia,
                COUNT(mt.id_estudiante) AS total_alumnos
              FROM maestros m
              INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
              LEFT JOIN materias ma ON ma.id_maestro = m.id_maestro
              LEFT JOIN matriculas mt ON mt.id_materia = ma.id_materia
              GROUP BY m.id_maestro, u.nombre, m.codigo, ma.nombre
              ORDER BY u.nombre";

    return self::obtenerRegistros($sqlstr, array());
}
public static function existeDirector()
{
    $sqlstr = "SELECT COUNT(*) AS total
               FROM usuarios u
               INNER JOIN roles r ON u.id_rol = r.id_rol
               WHERE r.nombre_rol = 'director'";

    $resultado = self::obtenerUnRegistro($sqlstr, array());

    return intval($resultado["total"] ?? 0) > 0;
}
public static function obtenerRolesPorCorreo($correo)
{
    $sqlstr = "SELECT r.nombre_rol 
               FROM usuarios_roles ur
               INNER JOIN usuarios u ON ur.id_usuario = u.id_usuario
               INNER JOIN roles r ON ur.id_rol = r.id_rol
               WHERE u.correo = :correo";
    $roles = self::obtenerRegistros($sqlstr, array("correo" => $correo));
    $rolesArray = array();
    foreach ($roles as $r) {
        $rolesArray[] = $r["nombre_rol"];
    }
    return $rolesArray;
}

public static function obtenerFacultadCoordinador($id_usuario)
{
    $sqlstr = "SELECT id_facultad FROM coordinadores WHERE id_usuario = :id_usuario LIMIT 1";
    $result = self::obtenerUnRegistro($sqlstr, array("id_usuario" => $id_usuario));
    return $result ? intval($result["id_facultad"]) : null;
}

public static function obtenerCampusUsuario($id_usuario, $rol)
{
    $table = "";
    if ($rol === "coordinador") {
        $table = "coordinadores";
    } elseif ($rol === "estudiante") {
        $table = "estudiantes";
    } elseif ($rol === "maestro") {
        $table = "maestros";
    } else {
        return null;
    }

    $sqlstr = "SELECT id_campus FROM $table WHERE id_usuario = :id_usuario LIMIT 1";
    $result = self::obtenerUnRegistro($sqlstr, array("id_usuario" => $id_usuario));
    return $result ? ($result["id_campus"] !== null ? intval($result["id_campus"]) : null) : null;
}

public static function getDashboardDirector()
{
    return array(
        "total_estudiantes_activos" => self::safeScalar(
            "SELECT COUNT(*) AS total
             FROM estudiantes e
             INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
             WHERE u.estado = 'activo'
               AND COALESCE(e.estado, 'Admitido') NOT IN ('Bloqueado', 'Inactivo', 'inactivo')"
        ),
        "total_docentes_activos" => self::safeScalar(
            "SELECT COUNT(*) AS total
             FROM maestros m
             INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
             WHERE u.estado = 'activo'"
        ),
        "solicitudes_pendientes" => self::safeScalar(
            "SELECT COUNT(*) AS total
             FROM usuarios u
             INNER JOIN estudiantes e ON u.id_usuario = e.id_usuario
             WHERE u.estado = 'pendiente'"
        )
    );
}

public static function getDashboardCoordinador($idFacultad)
{
    if (empty($idFacultad)) {
        return array(
            "estudiantes_matriculados" => 0,
            "secciones_activas" => 0,
            "secciones_cupo_bajo" => array()
        );
    }

    return array(
        "estudiantes_matriculados" => self::safeScalar(
            "SELECT COUNT(DISTINCT mt.id_estudiante) AS total
             FROM matriculas mt
             INNER JOIN estudiantes e ON mt.id_estudiante = e.id_estudiante
             INNER JOIN carreras c ON (e.carrera = c.nombre_carrera OR CAST(e.carrera AS CHAR) = CAST(c.id_carrera AS CHAR))
             INNER JOIN periodos_academicos p ON mt.id_periodo = p.id_periodo AND p.estado = 'activo'
             WHERE c.id_facultad = :id_facultad",
            array("id_facultad" => intval($idFacultad))
        ),
        "secciones_activas" => self::safeScalar(
            "SELECT COUNT(*) AS total
             FROM secciones s
             INNER JOIN materias m ON s.id_materia = m.id_materia
             LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
             INNER JOIN periodos_academicos p ON s.id_periodo = p.id_periodo AND p.estado = 'activo'
             WHERE s.estado = 'Activa'
               AND (
                    m.tipo_materia = 'institucional'
                    OR m.id_facultad = :id_facultad
                    OR c.id_facultad = :id_facultad
               )",
            array("id_facultad" => intval($idFacultad))
        ),
        "secciones_cupo_bajo" => self::safeRows(
            "SELECT s.id_seccion, s.codigo_seccion, s.aula, s.dias, s.hora_inicio, s.hora_fin,
                    s.cupo_maximo, m.nombre AS materia,
                    COUNT(mt.id_matricula) AS inscritos,
                    GREATEST(s.cupo_maximo - COUNT(mt.id_matricula), 0) AS cupos_disponibles
             FROM secciones s
             INNER JOIN materias m ON s.id_materia = m.id_materia
             LEFT JOIN carreras c ON m.id_carrera = c.id_carrera
             INNER JOIN periodos_academicos p ON s.id_periodo = p.id_periodo AND p.estado = 'activo'
             LEFT JOIN matriculas mt ON s.id_seccion = mt.id_seccion
             WHERE s.estado = 'Activa'
               AND (
                    m.tipo_materia = 'institucional'
                    OR m.id_facultad = :id_facultad
                    OR c.id_facultad = :id_facultad
               )
             GROUP BY s.id_seccion, s.codigo_seccion, s.aula, s.dias, s.hora_inicio, s.hora_fin, s.cupo_maximo, m.nombre
             HAVING cupos_disponibles < 5
             ORDER BY cupos_disponibles ASC, m.nombre ASC
             LIMIT 6",
            array("id_facultad" => intval($idFacultad))
        )
    );
}

public static function getDashboardMaestro($correo)
{
    $secciones = self::safeRows(
        "SELECT s.id_seccion, s.codigo_seccion, s.aula, s.dias, s.hora_inicio, s.hora_fin,
                s.cupo_maximo, s.estado, m.codigo AS codigo_materia, m.nombre AS materia,
                COUNT(mt.id_matricula) AS inscritos
         FROM maestros ma
         INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario
         INNER JOIN secciones s ON ma.id_maestro = s.id_maestro
         INNER JOIN materias m ON s.id_materia = m.id_materia
         INNER JOIN periodos_academicos p ON s.id_periodo = p.id_periodo AND p.estado = 'activo'
         LEFT JOIN matriculas mt ON s.id_seccion = mt.id_seccion
         WHERE u.correo = :correo
           AND s.estado IN ('Activa', 'Borrador')
         GROUP BY s.id_seccion, s.codigo_seccion, s.aula, s.dias, s.hora_inicio, s.hora_fin, s.cupo_maximo, s.estado, m.codigo, m.nombre
         ORDER BY s.dias ASC, s.hora_inicio ASC",
        array("correo" => $correo)
    );

    $totalSecciones = count($secciones);
    $totalAlumnos = 0;
    foreach ($secciones as $sec) {
        $totalAlumnos += intval($sec["inscritos"]);
    }

    $totalConNota = intval(self::safeScalar(
        "SELECT COUNT(c.id_calificacion) AS total
         FROM maestros ma
         INNER JOIN usuarios u ON ma.id_usuario = u.id_usuario
         INNER JOIN secciones s ON ma.id_maestro = s.id_maestro
         INNER JOIN periodos_academicos p ON s.id_periodo = p.id_periodo AND p.estado = 'activo'
         INNER JOIN matriculas mt ON s.id_seccion = mt.id_seccion
         INNER JOIN calificaciones c ON mt.id_matricula = c.id_matricula
         WHERE u.correo = :correo
           AND s.estado IN ('Activa', 'Borrador')",
        array("correo" => $correo)
    ));

    $porcentajeAvance = $totalAlumnos > 0 ? round(($totalConNota / $totalAlumnos) * 100, 1) : 0;

    return array(
        "secciones" => $secciones,
        "total_secciones" => $totalSecciones,
        "total_alumnos" => $totalAlumnos,
        "total_con_nota" => $totalConNota,
        "porcentaje_avance" => $porcentajeAvance
    );
}

public static function getDashboardEstudiante($correo, $idCarrera = null)
{
    $estudiante = self::safeOne(
        "SELECT e.id_estudiante, e.carrera
         FROM estudiantes e
         INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
         WHERE u.correo = :correo
         LIMIT 1",
        array("correo" => $correo)
    );

    if (!$estudiante) {
        return array(
            "promedio_global" => 0,
            "uv_matriculadas" => 0,
            "horario" => array(),
            "avance_plan" => 0,
            "materias_aprobadas" => 0,
            "materias_plan" => 0
        );
    }

    $idEstudiante = intval($estudiante["id_estudiante"]);

    // Construir dinámicamente la condición de filtrado por carrera para evitar solapamientos booleanos
    $carreraJoinCond = "";
    $params = array("id_estudiante" => $idEstudiante);
    $planParams = array();
    if ($idCarrera) {
        $carreraJoinCond = "AND cr.id_carrera = :id_carrera";
        $params["id_carrera"] = intval($idCarrera);
        $planParams["id_carrera"] = intval($idCarrera);
    } else {
        $carreraJoinCond = "AND (cr.nombre_carrera = :carrera OR CAST(cr.id_carrera AS CHAR) = CAST(:carrera AS CHAR))";
        $params["carrera"] = $estudiante["carrera"];
        $planParams["carrera"] = $estudiante["carrera"];
    }

    // El promedio global solo toma en cuenta clases de periodos inactivos o finalizados que pertenecen al plan de la carrera seleccionada
    $sqlPromedio = "SELECT ROUND(AVG(c.nota), 2) AS total
         FROM calificaciones c
         INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
         INNER JOIN secciones s ON mt.id_seccion = s.id_seccion
         INNER JOIN materias m ON s.id_materia = m.id_materia
         CROSS JOIN carreras cr
         INNER JOIN periodos_academicos pa ON mt.id_periodo = pa.id_periodo
         WHERE mt.id_estudiante = :id_estudiante
           AND (pa.estado = 'inactivo' OR DATE(NOW()) > DATE_ADD(pa.fecha_fin, INTERVAL 7 DAY))
           $carreraJoinCond
           AND (
                m.tipo_materia = 'institucional'
                OR (m.tipo_materia = 'facultad' AND m.id_facultad = cr.id_facultad)
                OR (m.tipo_materia = 'carrera' AND m.id_carrera = cr.id_carrera)
           )";
    $promedio = self::safeScalar($sqlPromedio, $params);

    // Contar el número de materias matriculadas en el periodo actual
    $materiasMatriculadas = self::safeScalar(
        "SELECT COUNT(mt.id_matricula) AS total
         FROM matriculas mt
         INNER JOIN periodos_academicos p ON mt.id_periodo = p.id_periodo AND p.estado = 'activo'
         WHERE mt.id_estudiante = :id_estudiante",
        array("id_estudiante" => $idEstudiante)
    );

    $horario = self::safeRows(
        "SELECT m.codigo, m.nombre AS materia, s.aula, s.dias, s.hora_inicio, s.hora_fin
         FROM matriculas mt
         INNER JOIN secciones s ON mt.id_seccion = s.id_seccion
         INNER JOIN materias m ON s.id_materia = m.id_materia
         INNER JOIN periodos_academicos p ON mt.id_periodo = p.id_periodo AND p.estado = 'activo'
         WHERE mt.id_estudiante = :id_estudiante
         ORDER BY s.dias ASC, s.hora_inicio ASC",
        array("id_estudiante" => $idEstudiante)
    );

    $sqlPlan = "SELECT COUNT(*) AS total
         FROM materias m
         CROSS JOIN carreras cr
         WHERE m.estado = 'activa'
           $carreraJoinCond
           AND (
                m.tipo_materia = 'institucional'
                OR (m.tipo_materia = 'facultad' AND m.id_facultad = cr.id_facultad)
                OR (m.tipo_materia = 'carrera' AND m.id_carrera = cr.id_carrera)
           )";
    $materiasPlan = self::safeScalar($sqlPlan, $planParams);

    $sqlAprobadas = "SELECT COUNT(DISTINCT s.id_materia) AS total
         FROM calificaciones c
         INNER JOIN matriculas mt ON c.id_matricula = mt.id_matricula
         INNER JOIN secciones s ON mt.id_seccion = s.id_seccion
         INNER JOIN materias m ON s.id_materia = m.id_materia
         CROSS JOIN carreras cr
         WHERE mt.id_estudiante = :id_estudiante
           AND c.nota >= 70
           $carreraJoinCond
           AND (
                m.tipo_materia = 'institucional'
                OR (m.tipo_materia = 'facultad' AND m.id_facultad = cr.id_facultad)
                OR (m.tipo_materia = 'carrera' AND m.id_carrera = cr.id_carrera)
           )";
    $materiasAprobadas = self::safeScalar($sqlAprobadas, $params);

    $avance = $materiasPlan > 0 ? round(($materiasAprobadas / $materiasPlan) * 100) : 0;

    return array(
        "promedio_global" => $promedio,
        "materias_matriculadas" => $materiasMatriculadas,
        "horario" => $horario,
        "avance_plan" => min(100, intval($avance)),
        "materias_aprobadas" => $materiasAprobadas,
        "materias_plan" => $materiasPlan
    );
}

private static function safeScalar($sqlstr, $params = array())
{
    $registro = self::safeOne($sqlstr, $params);
    return $registro ? floatval($registro["total"] ?? 0) : 0;
}

private static function safeOne($sqlstr, $params = array())
{
    try {
        return self::obtenerUnRegistro($sqlstr, $params);
    } catch (Throwable $ex) {
        return false;
    }
}

private static function safeRows($sqlstr, $params = array())
{
    try {
        return self::obtenerRegistros($sqlstr, $params);
    } catch (Throwable $ex) {
        return array();
    }
}
}
?>
