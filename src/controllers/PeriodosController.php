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
}
