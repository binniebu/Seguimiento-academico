<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class UsuarioDao extends Table
{
    // ==========================================
    // MÉTODOS ORIGINALES (LOGIN Y REGISTRO)
    // ==========================================

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
        $params = array("correo" => $correo);

        return self::obtenerUnRegistro($sqlstr, $params);
    }
    
    public static function obtenerUsuarioPorCorreo($correo)
    {
        $sqlstr = "SELECT u.*, r.nombre_rol 
                   FROM usuarios u
                   INNER JOIN roles r ON u.id_rol = r.id_rol
                   WHERE u.correo = :correo
                   AND u.estado = 'activo';";

        $params = array(
            "correo" => $correo
        );

        return self::obtenerUnRegistro($sqlstr, $params);
    }

    // ==========================================
    // NUEVOS MÉTODOS: GESTIÓN DE USUARIOS (CRUD)
    // ==========================================

    public static function getUsers(
        string $strPartialName = "",
        string $strStatus = "",
        string $strOrderBy = "",
        bool $binOrderDescending = false,
        int $intPage = 0,
        int $intItemsPerPage = 10
    ) {
        $sqlstr = "SELECT u.id_usuario, u.nombre, u.correo, u.id_rol, r.nombre_rol, u.estado, u.fecha_creacion 
                   FROM usuarios u
                   INNER JOIN roles r ON u.id_rol = r.id_rol";
        
        $sqlstrCount = "SELECT COUNT(*) as count FROM usuarios u";
        $conditions = [];
        $params = [];

        if ($strPartialName != "") {
            $conditions[] = "(u.nombre LIKE :partialName OR u.correo LIKE :partialName)";
            $params["partialName"] = "%" . $strPartialName . "%";
        }

        if ($strStatus != "") {
            $conditions[] = "u.estado = :status";
            $params["status"] = $strStatus;
        }

        if (count($conditions) > 0) {
            $sqlstr .= " WHERE " . implode(" AND ", $conditions);
            $sqlstrCount .= " WHERE " . implode(" AND ", $conditions);
        }

        if ($strOrderBy != "" && in_array($strOrderBy, ["id_usuario", "correo", "nombre"])) {
            $sqlstr .= " ORDER BY u." . $strOrderBy;
            if ($binOrderDescending) {
                $sqlstr .= " DESC";
            }
        } else {
            $sqlstr .= " ORDER BY u.id_usuario ASC";
        }

        $intNumeroDeRegistros = self::obtenerUnRegistro($sqlstrCount, $params)["count"];
        $intPagesCount = ceil($intNumeroDeRegistros / $intItemsPerPage);

        if ($intPage > $intPagesCount - 1 && $intPagesCount > 0) {
            $intPage = $intPagesCount - 1;
        }

        $sqlstr .= " LIMIT " . ($intPage * $intItemsPerPage) . ", " . $intItemsPerPage;

        $registros = self::obtenerRegistros($sqlstr, $params);
        return [
            "usuarios" => $registros, 
            "total" => $intNumeroDeRegistros, 
            "page" => $intPage, 
            "itemsPerPage" => $intItemsPerPage
        ];
    }

    public static function getUserById(int $intIdUsuario)
    {
        $sqlstr = "SELECT id_usuario, nombre, correo, id_rol, estado, fecha_creacion 
                   FROM usuarios 
                   WHERE id_usuario = :id_usuario";
        $params = ["id_usuario" => $intIdUsuario];
        return self::obtenerUnRegistro($sqlstr, $params);
    }

    public static function insertUser(
        string $strNombre,
        string $strCorreo,
        string $strPassword,
        int $intIdRol,
        string $strEstado
    ) {
        $sqlstr = "INSERT INTO usuarios (nombre, correo, password, id_rol, estado, fecha_creacion) 
                   VALUES (:nombre, :correo, :password, :id_rol, :estado, NOW())";
        $params = [
            "nombre" => $strNombre,
            "correo" => $strCorreo,
            "password" => password_hash($strPassword, PASSWORD_DEFAULT),
            "id_rol" => $intIdRol,
            "estado" => $strEstado
        ];
        return self::executeNonQuery($sqlstr, $params);
    }

    public static function updateUser(
        int $intIdUsuario,
        string $strNombre,
        string $strCorreo,
        int $intIdRol,
        string $strEstado
    ) {
        $sqlstr = "UPDATE usuarios 
                   SET nombre = :nombre, correo = :correo, 
                       id_rol = :id_rol, estado = :estado 
                   WHERE id_usuario = :id_usuario";
        $params = [
            "id_usuario" => $intIdUsuario,
            "nombre" => $strNombre,
            "correo" => $strCorreo,
            "id_rol" => $intIdRol,
            "estado" => $strEstado
        ];
        return self::executeNonQuery($sqlstr, $params);
    }

    public static function deleteUser(int $intIdUsuario)
    {
        $sqlstr = "DELETE FROM usuarios WHERE id_usuario = :id_usuario";
        $params = ["id_usuario" => $intIdUsuario];
        return self::executeNonQuery($sqlstr, $params);
    }

    public static function getRolesDisponibles()
    {
        $sqlstr = "SELECT id_rol, nombre_rol FROM roles ORDER BY nombre_rol ASC";
        return self::obtenerRegistros($sqlstr);
    }


    // 1. Reporte por Estudiante
    public static function getReporteEstudiantes()
    {
        $sqlstr = "SELECT u.nombre as estudiante, e.cuenta, m.nombre as materia, c.nota, c.observacion
                   FROM calificaciones c
                   INNER JOIN matriculas mat ON c.id_matricula = mat.id_matricula
                   INNER JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                   INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
                   INNER JOIN materias m ON mat.id_materia = m.id_materia
                   ORDER BY u.nombre ASC, m.nombre ASC";
        return self::obtenerRegistros($sqlstr);
    }

    // 2. Reporte por Maestro
    public static function getReporteMaestros()
    {
        $sqlstr = "SELECT u.nombre as maestro, mae.codigo as codigo_maestro, m.nombre as materia, 
                          COUNT(mat.id_matricula) as total_alumnos
                   FROM maestros mae
                   INNER JOIN usuarios u ON mae.id_usuario = u.id_usuario
                   INNER JOIN materias m ON mae.id_maestro = m.id_maestro
                   LEFT JOIN matriculas mat ON m.id_materia = mat.id_materia AND mat.estado = 'activa'
                   GROUP BY mae.id_maestro, m.id_materia
                   ORDER BY u.nombre ASC";
        return self::obtenerRegistros($sqlstr);
    }

    // 3. Reporte por Materia & Promedios
    public static function getReporteMateriasYPromedios()
    {
        $sqlstr = "SELECT m.codigo, m.nombre as materia, 
                          COUNT(c.id_calificacion) as evaluaciones_registradas,
                          ROUND(AVG(c.nota), 2) as promedio_nota,
                          MAX(c.nota) as nota_mas_alta,
                          MIN(c.nota) as nota_mas_baja
                   FROM materias m
                   LEFT JOIN matriculas mat ON m.id_materia = mat.id_materia
                   LEFT JOIN calificaciones c ON mat.id_matricula = c.id_matricula
                   WHERE m.estado = 'activa'
                   GROUP BY m.id_materia
                   ORDER BY promedio_nota DESC";
        return self::obtenerRegistros($sqlstr);
    }

    // 4. Cantidad de estudiantes matriculados (Resumen Global)
    public static function getResumenMatriculasGlobal()
    {
        $sqlstr = "SELECT 
                    (SELECT COUNT(*) FROM estudiantes) as total_estudiantes_sistema,
                    (SELECT COUNT(DISTINCT id_estudiante) FROM matriculas WHERE estado = 'activa') as estudiantes_con_matricula_activa,
                    (SELECT COUNT(*) FROM matriculas WHERE estado = 'activa') as total_cupos_matriculados";
        return self::obtenerUnRegistro($sqlstr);
    }
}