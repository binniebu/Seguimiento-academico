<?php

namespace Controllers;

require_once __DIR__ . "/../dao/PeriodoDao.php";

use Dao\PeriodoDao;

class PeriodosController
{
    public static function listarPeriodos()
    {
        return PeriodoDao::listarPeriodos();
    }

    public static function activarPeriodo($id)
    {
        $periodo = PeriodoDao::obtenerPeriodo($id);
        if (!$periodo) {
            return ["exito" => false, "mensaje" => "El período especificado no existe."];
        }

        $hoy = date('Y-m-d');
        if ($periodo["fecha_fin"] < $hoy) {
            return ["exito" => false, "mensaje" => "No se puede activar un período académico que ya ha finalizado."];
        }

        if (PeriodoDao::activarPeriodo($id)) {
            return ["exito" => true, "mensaje" => "Período académico activado correctamente."];
        }
        return ["exito" => false, "mensaje" => "No se pudo activar el período académico."];
    }

    public static function crearPeriodo($fecha_inicio)
    {
        // 0. Validar que no haya un período sin finalizar
        $periodoNoFinalizado = PeriodoDao::obtenerPeriodoNoFinalizado();
        if ($periodoNoFinalizado) {
            return [
                "exito" => false, 
                "mensaje" => "No se puede crear un nuevo período académico porque el período '" . $periodoNoFinalizado["nombre_periodo"] . "' aún no ha finalizado (Finaliza el: " . $periodoNoFinalizado["fecha_fin"] . ")."
            ];
        }

        if (empty($fecha_inicio)) {
            return ["exito" => false, "mensaje" => "La fecha de inicio es requerida."];
        }

        $timestamp = strtotime($fecha_inicio);
        if (!$timestamp) {
            return ["exito" => false, "mensaje" => "La fecha de inicio no es válida."];
        }

        // 1. Validar que no sea sábado (6) o domingo (7)
        $dayOfWeek = intval(date('N', $timestamp));
        if ($dayOfWeek === 6 || $dayOfWeek === 7) {
            return ["exito" => false, "mensaje" => "El período académico no puede iniciar un sábado o domingo."];
        }

        // 2. Calcular fecha de fin (el sábado de la semana 14)
        $lunesInicio = date('Y-m-d', strtotime('monday this week', $timestamp));
        $fecha_fin = date('Y-m-d', strtotime($lunesInicio . ' +13 weeks +5 days'));

        // 3. Autodetectar periodo según mes
        $month = intval(date('m', $timestamp));
        $year = date('Y', $timestamp);
        
        if ($month >= 1 && $month <= 4) {
            $nombre = "Periodo I - " . $year;
        } elseif ($month >= 5 && $month <= 8) {
            $nombre = "Periodo II - " . $year;
        } else {
            $nombre = "Periodo III - " . $year;
        }

        if (PeriodoDao::crearPeriodo($nombre, $fecha_inicio, $fecha_fin, 'activo')) {
            return ["exito" => true, "mensaje" => "Período '$nombre' creado y activado correctamente. Finaliza el $fecha_fin."];
        }

        return ["exito" => false, "mensaje" => "Ocurrió un error en la base de datos al guardar el período."];
    }

    /**
     * Alterna el proceso de matrícula de forma manual (abrir / cerrar)
     */
    public static function alternarProcesoMatricula(int $estado)
    {
        $periodo = PeriodoDao::obtenerPeriodoActivo();
        if (!$periodo) {
            return ["exito" => false, "mensaje" => "No hay ningún período académico activo."];
        }

        if (PeriodoDao::alternarMatricula(intval($periodo["id_periodo"]), $estado)) {
            $label = $estado === 1 ? "abierto" : "cerrado";
            return [
                "exito" => true,
                "mensaje" => "El proceso de matrícula para el período '" . $periodo["nombre_periodo"] . "' ha sido " . $label . " correctamente."
            ];
        }

        return ["exito" => false, "mensaje" => "No se pudo cambiar el estado de la matrícula."];
    }

    /**
     * [SOLO DESARROLLO] Activa el modo demo de matrícula moviendo la fecha_inicio
     * del período activo al día de hoy. Permite probar el flujo completo sin
     * manipular fechas en la BD manualmente.
     */
    public static function activarModoDemo()
    {
        $periodo = PeriodoDao::obtenerPeriodoActivo();
        if (!$periodo) {
            return ["exito" => false, "mensaje" => "No hay ningún período académico activo."];
        }

        if (PeriodoDao::activarModoDemo(intval($periodo["id_periodo"]))) {
            // Sincronizar el flag manual de matrícula activa
            PeriodoDao::alternarMatricula(intval($periodo["id_periodo"]), 1);
            return [
                "exito" => true,
                "mensaje" => "Modo demo activado. La fecha de inicio del período '" . $periodo["nombre_periodo"] . "' se movió a hoy y se abrieron las matrículas."
            ];
        }

        return ["exito" => false, "mensaje" => "No se pudo activar el modo demo."];
    }

    /**
     * [SOLO DESARROLLO] Desactiva el modo demo de matrícula moviendo la fecha_inicio
     * del período activo a hace 35 días. Esto cierra la matrícula de manera forzada.
     */
    public static function desactivarModoDemo()
    {
        $periodo = PeriodoDao::obtenerPeriodoActivo();
        if (!$periodo) {
            return ["exito" => false, "mensaje" => "No hay ningún período académico activo."];
        }

        if (PeriodoDao::desactivarModoDemo(intval($periodo["id_periodo"]))) {
            // Sincronizar el flag manual de matrícula inactiva
            PeriodoDao::alternarMatricula(intval($periodo["id_periodo"]), 0);
            return [
                "exito" => true,
                "mensaje" => "Modo demo desactivado. La fecha de inicio del período '" . $periodo["nombre_periodo"] . "' se movió a hace 35 días y se cerraron las matrículas."
            ];
        }

        return ["exito" => false, "mensaje" => "No se pudo desactivar el modo demo."];
    }
}
