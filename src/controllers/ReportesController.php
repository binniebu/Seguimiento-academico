<?php

namespace Controllers;

require_once __DIR__ . "/../utilities/SimplePdf.php";
require_once __DIR__ . "/../dao/HistorialDao.php";
require_once __DIR__ . "/../dao/MatriculaDao.php";
require_once __DIR__ . "/../dao/CalificacionDao.php";
require_once __DIR__ . "/../dao/MaestroDao.php";

use Utilities\SimplePdf;
use Dao\HistorialDao;
use Dao\MatriculaDao;
use Dao\CalificacionDao;
use Dao\MaestroDao;

class ReportesController
{
    public static function generarPdf(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $tipo = $_GET["tipo"] ?? "historial";
        switch ($tipo) {
            case "boleta_ultimo_periodo":
                self::boletaUltimoPeriodo();
                break;
            case "notas_docente":
                self::notasDocente();
                break;
            case "notas_clase":
                self::notasClase();
                break;
            case "historial":
            default:
                self::historialAcademico();
                break;
        }
    }

    private static function estudianteActualOSeleccionado(): ?array
    {
        $idEstudiante = intval($_GET["id_estudiante"] ?? 0);
        if ($idEstudiante > 0 && in_array($_SESSION["rol"] ?? "", ["director", "coordinador"], true)) {
            return HistorialDao::obtenerDatosEstudiante($idEstudiante);
        }

        $idUsuario = $_SESSION["id_usuario"] ?? null;
        if (!$idUsuario) {
            return null;
        }
        return MatriculaDao::obtenerEstudiantePorUsuario($idUsuario);
    }

    private static function historialAcademico(): void
    {
        $estudiante = self::estudianteActualOSeleccionado();
        if (!$estudiante) {
            self::pdfMensaje("Historial Academico", "No se encontro estudiante para generar el reporte.");
            return;
        }

        $idCarrera = $_SESSION["id_carrera"] ?? null;
        $historial = HistorialDao::obtenerHistorialAcademico((int)$estudiante["id_estudiante"], $idCarrera);
        $indices = HistorialDao::obtenerIndicesAcademicos((int)$estudiante["id_estudiante"], $idCarrera);

        $pdf = new SimplePdf("Historial academico");
        self::datosEstudiante($pdf, $estudiante);
        $pdf->addKeyValue("Indice global", number_format((float)($indices["promedio_global"] ?? 0), 2) . "%");
        $pdf->addSection("Asignaturas finalizadas");

        if (empty($historial)) {
            $pdf->addLine("No hay calificaciones finalizadas registradas.");
        } else {
            $rows = [];
            foreach ($historial as $h) {
                $nota = number_format((float)$h["nota"], 2);
                $rows[] = [
                    $h["periodo"],
                    $h["codigo_materia"],
                    $h["nombre_materia"],
                    $h["creditos"] . " UV",
                    $nota,
                    ((float)$h["nota"] >= 70 ? "Aprobado" : "Reprobado")
                ];
            }
            $pdf->addTable(["Periodo", "Codigo", "Materia", "UV", "Nota", "Estado"], $rows);
        }
        $dni = preg_replace('/[^0-9]/', '', $estudiante["cuenta"] ?? '');
        $pdf->output("historial" . $dni . ".pdf");
    }

    private static function boletaUltimoPeriodo(): void
    {
        $estudiante = self::estudianteActualOSeleccionado();
        if (!$estudiante) {
            self::pdfMensaje("Boleta ultimo periodo", "No se encontro estudiante para generar el reporte.");
            return;
        }

        $idCarrera = $_SESSION["id_carrera"] ?? null;
        $boleta = HistorialDao::obtenerBoletaUltimoPeriodo((int)$estudiante["id_estudiante"], $idCarrera);
        $pdf = new SimplePdf("Boleta del ultimo periodo");
        self::datosEstudiante($pdf, $estudiante);

        if (!$boleta["periodo"]) {
            $pdf->addLine("El estudiante no tiene matriculas registradas.");
        } else {
            $pdf->addKeyValue("Periodo", $boleta["periodo"]["nombre_periodo"]);
            $pdf->addSection("Detalle de notas");
            $rows = [];
            foreach ($boleta["clases"] as $c) {
                $nota = $c["nota"] !== null ? number_format((float)$c["nota"], 2) : "Pendiente";
                $rows[] = [
                    $c["codigo_materia"],
                    $c["nombre_materia"],
                    $c["codigo_seccion"],
                    $c["nombre_maestro"],
                    self::fmtNota($c["nota_parcial1"]),
                    self::fmtNota($c["nota_parcial2"]),
                    self::fmtNota($c["nota_parcial3"]),
                    $nota
                ];
            }
            $pdf->addTable(["Cod", "Materia", "Sec", "Docente", "P1", "P2", "P3", "Prom"], $rows);
        }

        $dni = preg_replace('/[^0-9]/', '', $estudiante["cuenta"] ?? '');
        $pdf->output("boleta" . $dni . ".pdf");
    }

    private static function notasDocente(): void
    {
        $idMaestro = intval($_GET["id_maestro"] ?? 0);
        if (($idMaestro <= 0) && ($_SESSION["rol"] ?? "") === "maestro") {
            $maestro = MaestroDao::obtenerMaestroPorIdUsuario($_SESSION["id_usuario"]);
            $idMaestro = intval($maestro["id_maestro"] ?? 0);
        }

        if ($idMaestro <= 0) {
            self::pdfMensaje("Notas por docente", "Seleccione un docente valido.");
            return;
        }

        $notas = CalificacionDao::obtenerNotasPorDocente($idMaestro);
        $pdf = new SimplePdf("Notas por docente");
        $pdf->addKeyValue("Fecha de emision", date("d/m/Y H:i"));
        $pdf->addSection("Detalle");
        if (empty($notas)) {
            $pdf->addLine("No hay notas registradas para este docente.");
        } else {
            $rows = [];
            foreach ($notas as $n) {
                $rows[] = [
                    $n["nombre_periodo"],
                    $n["codigo_seccion"],
                    self::limitar($n["nombre_materia"], 22),
                    self::limitar($n["nombre_estudiante"], 22),
                    self::fmtNota($n["nota_parcial1"]),
                    self::fmtNota($n["nota_parcial2"]),
                    self::fmtNota($n["nota_parcial3"]),
                    self::fmtNota($n["nota"])
                ];
            }
            $pdf->addTable(["Periodo", "Sec", "Clase", "Alumno", "P1", "P2", "P3", "Prom"], $rows);
        }
        $pdf->output("notas_docente.pdf");
    }

    private static function notasClase(): void
    {
        $idSeccion = intval($_GET["id_seccion"] ?? 0);
        if ($idSeccion <= 0) {
            self::pdfMensaje("Notas por clase", "Seleccione una clase o seccion valida.");
            return;
        }

        $seccion = CalificacionDao::obtenerDetalleSeccion($idSeccion);
        $notas = CalificacionDao::obtenerNotasPorClase($idSeccion);
        $pdf = new SimplePdf("Notas por clase");
        if ($seccion) {
            $pdf->addKeyValue("Clase", $seccion["codigo_materia"] . " - " . $seccion["nombre_materia"]);
            $pdf->addKeyValue("Seccion", $seccion["codigo_seccion"]);
            $pdf->addKeyValue("Docente", $seccion["nombre_maestro"]);
            $pdf->addKeyValue("Periodo", $seccion["nombre_periodo"]);
        }
        $pdf->addSection("Alumnos");
        if (empty($notas)) {
            $pdf->addLine("No hay alumnos matriculados en esta seccion.");
        } else {
            $rows = [];
            foreach ($notas as $n) {
                $rows[] = [
                    self::limitar($n["nombre_estudiante"], 28),
                    $n["cuenta"],
                    self::fmtNota($n["nota_parcial1"]),
                    self::fmtNota($n["nota_parcial2"]),
                    self::fmtNota($n["nota_parcial3"]),
                    self::fmtNota($n["nota"])
                ];
            }
            $pdf->addTable(["Alumno", "Cuenta", "P1", "P2", "P3", "Prom"], $rows);
        }
        $pdf->output("notas_clase.pdf");
    }

    private static function datosEstudiante(SimplePdf $pdf, array $estudiante): void
    {
        $pdf->addKeyValue("Estudiante", $estudiante["nombre"] ?? "");
        $pdf->addKeyValue("Cuenta/DNI", $estudiante["cuenta"] ?? "");
        
        $idCarrera = $_SESSION["id_carrera"] ?? null;
        $nombreCarrera = $estudiante["nombre_carrera"] ?? $estudiante["carrera"] ?? "";
        if ($idCarrera) {
            require_once __DIR__ . "/../dao/CarreraDao.php";
            $car = \Dao\CarreraDao::obtenerCarreraPorId($idCarrera);
            if ($car) {
                $nombreCarrera = $car["nombre_carrera"];
            }
        }
        $pdf->addKeyValue("Carrera", $nombreCarrera);
        $pdf->addKeyValue("Campus", $estudiante["campus"] ?? "Sin asignar");
        $pdf->addKeyValue("Fecha de emision", date("d/m/Y H:i"));
    }

    private static function fmtNota($nota): string
    {
        return $nota === null || $nota === "" ? "-" : number_format((float)$nota, 0);
    }

    private static function limitar(string $texto, int $max): string
    {
        return strlen($texto) > $max ? substr($texto, 0, $max - 3) . "..." : $texto;
    }

    private static function pdfMensaje(string $titulo, string $mensaje): void
    {
        $pdf = new SimplePdf($titulo);
        $pdf->addLine($mensaje);
        $pdf->output("reporte.pdf");
    }
}

?>
