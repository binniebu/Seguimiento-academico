<?php

namespace Controllers;

require_once __DIR__ . "/../dao/EstadisticasDao.php";

use Dao\EstadisticasDao;

class EstadisticasController
{
    public static function obtenerDatosDashboard()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $rol = $_SESSION["rol"] ?? "";
        $idFacultad = $_SESSION["id_facultad"] ?? null;
        $idCampus = $_SESSION["id_campus"] ?? null;

        $datos = [
            "por_campus" => [],
            "por_carrera" => [],
            "promedios_materias" => [],
            "aprobados_vs_reprobados" => [
                "aprobados" => 0,
                "reprobados" => 0
            ],
            "estado_secciones" => []
        ];

        if ($rol === "director") {
            $datos["por_campus"] = EstadisticasDao::obtenerEstudiantesPorCampus();
            $datos["por_carrera"] = EstadisticasDao::obtenerEstudiantesPorCarrera();
            $datos["promedios_materias"] = EstadisticasDao::obtenerPromediosMaterias();
            $datos["aprobados_vs_reprobados"] = EstadisticasDao::obtenerAprobadosVsReprobados();
            $datos["estado_secciones"] = EstadisticasDao::obtenerEstadoSecciones();
        } elseif ($rol === "coordinador") {
            $datos["por_carrera"] = EstadisticasDao::obtenerEstudiantesPorCarrera($idFacultad, $idCampus);
            $datos["promedios_materias"] = EstadisticasDao::obtenerPromediosMaterias($idFacultad, $idCampus);
            $datos["aprobados_vs_reprobados"] = EstadisticasDao::obtenerAprobadosVsReprobados($idFacultad, $idCampus);
            $datos["estado_secciones"] = EstadisticasDao::obtenerEstadoSecciones($idFacultad, $idCampus);
        } elseif ($rol === "maestro") {
            require_once __DIR__ . "/../dao/MaestroDao.php";
            require_once __DIR__ . "/../dao/CalificacionDao.php";
            require_once __DIR__ . "/../dao/PeriodoDao.php";
            $maestro = \Dao\MaestroDao::obtenerMaestroPorIdUsuario($_SESSION["id_usuario"] ?? null);
            $idMaestro = $maestro ? intval($maestro["id_maestro"]) : 0;
            $periodo = \Dao\PeriodoDao::obtenerPeriodoActivo();
            $idPeriodo = $periodo ? intval($periodo["id_periodo"]) : 0;

            $datos["promedios_materias"] = EstadisticasDao::obtenerPromediosSeccionesMaestro($idMaestro);
            $datos["aprobados_vs_reprobados"] = EstadisticasDao::obtenerAprobadosVsReprobados(null, null, $idMaestro);
            
            $secciones = \Dao\CalificacionDao::obtenerSeccionesMaestro($idMaestro, $idPeriodo);
            $datos["por_carrera"] = array_map(function($s) {
                return [
                    "carrera" => $s["nombre_materia"] . " (" . $s["codigo_seccion"] . ")",
                    "total" => intval($s["total_inscritos"])
                ];
            }, $secciones);
        }

        return $datos;
    }
}
