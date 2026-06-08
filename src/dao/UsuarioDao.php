<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

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
}
?>