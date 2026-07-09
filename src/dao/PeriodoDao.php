<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class PeriodoDao extends Table
{
    public static function listarPeriodos()
    {
        $sqlstr = "SELECT * FROM periodos_academicos ORDER BY fecha_inicio DESC";
        return self::obtenerRegistros($sqlstr);
    }

    public static function obtenerPeriodo($id)
    {
        $sqlstr = "SELECT * FROM periodos_academicos WHERE id_periodo = :id";
        return self::obtenerUnRegistro($sqlstr, ["id" => $id]);
    }

    public static function obtenerPeriodoActivo()
    {
        $sqlstr = "SELECT * FROM periodos_academicos WHERE estado = 'activo' LIMIT 1";
        return self::obtenerUnRegistro($sqlstr);
    }

    public static function obtenerPeriodoNoFinalizado()
    {
        $hoy = date('Y-m-d');
        $sqlstr = "SELECT * FROM periodos_academicos WHERE fecha_fin >= :hoy LIMIT 1";
        return self::obtenerUnRegistro($sqlstr, ["hoy" => $hoy]);
    }

    public static function crearPeriodo($nombre, $fecha_inicio, $fecha_fin, $estado = 'activo')
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            if ($estado === 'activo') {
                // Desactivar todos los demás periodos
                $sqlDeactivate = "UPDATE periodos_academicos SET estado = 'inactivo'";
                $conn->exec($sqlDeactivate);
            }

            $sqlInsert = "INSERT INTO periodos_academicos (nombre_periodo, fecha_inicio, fecha_fin, estado)
                          VALUES (:nombre, :fecha_inicio, :fecha_fin, :estado)";
            $stmt = $conn->prepare($sqlInsert);
            $stmt->execute([
                "nombre" => $nombre,
                "fecha_inicio" => $fecha_inicio,
                "fecha_fin" => $fecha_fin,
                "estado" => $estado
            ]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            return false;
        }
    }

    public static function activarPeriodo($id)
    {
        $conn = self::getConn();
        try {
            $conn->beginTransaction();

            // Desactivar todos
            $sqlDeactivate = "UPDATE periodos_academicos SET estado = 'inactivo'";
            $conn->exec($sqlDeactivate);

            // Activar el seleccionado
            $sqlUpdate = "UPDATE periodos_academicos SET estado = 'activo' WHERE id_periodo = :id";
            $stmt = $conn->prepare($sqlUpdate);
            $stmt->execute(["id" => $id]);

            $conn->commit();
            return true;
        } catch (\Throwable $ex) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            return false;
        }
    }

    public static function activarModoDemo(int $idPeriodo): bool
    {
        $sql = "UPDATE periodos_academicos SET fecha_inicio = CURDATE() WHERE id_periodo = :id";
        return self::executeNonQuery($sql, ["id" => $idPeriodo]) > 0;
    }

    /**
     * [SOLO DESARROLLO] Mueve la fecha_inicio del periodo activo a hace 35 días,
     * desactivando inmediatamente la ventana de matrícula.
     */
    public static function desactivarModoDemo(int $idPeriodo): bool
    {
        $sql = "UPDATE periodos_academicos SET fecha_inicio = DATE_SUB(CURDATE(), INTERVAL 35 DAY) WHERE id_periodo = :id";
        return self::executeNonQuery($sql, ["id" => $idPeriodo]) > 0;
    }

    /**
     * Alterna el estado de matrícula de forma manual (abierta/cerrada)
     */
    public static function alternarMatricula(int $idPeriodo, int $estado): bool
    {
        $sql = "UPDATE periodos_academicos SET matricula_activa = :estado WHERE id_periodo = :id";
        return self::executeNonQuery($sql, ["id" => $idPeriodo, "estado" => $estado]) > 0;
    }
}
