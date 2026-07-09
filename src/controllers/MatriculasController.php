<?php

namespace Controllers;

require_once __DIR__ . '/../dao/MatriculaDao.php';
require_once __DIR__ . '/../dao/PeriodoDao.php';
require_once __DIR__ . '/../dao/SeccionDao.php';

use Dao\MatriculaDao;
use Dao\PeriodoDao;
use Dao\SeccionDao;

class MatriculasController
{
    public static function listar($buscar = "")
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $idFacultad = null;
        if (($_SESSION["rol"] ?? "") === "coordinador") {
            $idFacultad = $_SESSION["id_facultad"] ?? null;
        }

        return MatriculaDao::listarMatriculas($buscar, $idFacultad);
    }

    public static function esPeriodoAdicionesActivo()
    {
        $periodo = PeriodoDao::obtenerPeriodoActivo();
        if (!$periodo) {
            return false;
        }
        return intval($periodo["matricula_activa"] ?? 0) === 1;
    }

    public static function esPeriodoCancelacionesActivo()
    {
        $periodo = PeriodoDao::obtenerPeriodoActivo();
        if (!$periodo) {
            return false;
        }
        return intval($periodo["matricula_activa"] ?? 0) === 1;
    }

    public static function esPeriodoMatriculaActivo()
    {
        return self::esPeriodoCancelacionesActivo();
    }

    public static function matricularSeccion($idSeccion)
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $idUsuario = $_SESSION["id_usuario"] ?? null;
        if (!$idUsuario) {
            return ["exito" => false, "mensaje" => "Sesión no válida."];
        }

        // 1. Validar que el periodo de adiciones esté activo
        if (!self::esPeriodoAdicionesActivo()) {
            return ["exito" => false, "mensaje" => "El período para adicionar asignaturas ha finalizado (límite: 1 semana después del inicio de clases)."];
        }

        $periodo = PeriodoDao::obtenerPeriodoActivo();
        $idPeriodo = $periodo["id_periodo"];

        // 2. Obtener datos del estudiante
        $estudiante = MatriculaDao::obtenerEstudiantePorUsuario($idUsuario);
        if (!$estudiante) {
            return ["exito" => false, "mensaje" => "No se encontró el registro de estudiante para este usuario."];
        }
        $idEstudiante = $estudiante["id_estudiante"];

        // 3. Obtener datos de la sección
        $seccion = SeccionDao::obtenerSeccionPorId($idSeccion);
        if (!$seccion) {
            return ["exito" => false, "mensaje" => "La sección no existe."];
        }

        if ($seccion["estado"] !== "Activa") {
            return ["exito" => false, "mensaje" => "Esta sección no está activa para matrícula."];
        }

        // 4. Incompatibilidad de Coordinador: No puede matricular carreras de su propia facultad
        $coord = MatriculaDao::obtenerFacultadCoordinadorPorUsuario($idUsuario);
        if ($coord) {
            $idFacultadCoordinador = intval($coord["id_facultad"]);

            // Verificar facultad de la materia o de la carrera
            $materia = MatriculaDao::obtenerMateriaPorIdMateria($seccion["id_materia"]);

            if ($materia) {
                $facultadMateria = intval($materia["id_facultad"] ?? 0);
                $facultadCarrera = intval($materia["carrera_facultad"] ?? 0);

                if ($facultadMateria === $idFacultadCoordinador || $facultadCarrera === $idFacultadCoordinador) {
                    return ["exito" => false, "mensaje" => "Incompatibilidad Académica: Como coordinador de esta facultad, no tiene permitido matricular asignaturas adscritas a ella."];
                }
            }
        }


        // 5. Validar cupo
        $cupoActual = intval($seccion["cupo_actual"] ?? 0);
        $cupoMaximo = intval($seccion["cupo_maximo"] ?? 0);
        if ($cupoActual >= $cupoMaximo) {
            return ["exito" => false, "mensaje" => "La sección ya no cuenta con cupos disponibles."];
        }

        // 6. Validar Prerrequisito (Aprobado con 70%)
        // NOTA: `obtenerSeccionPorId()` NO trae id_requisito; el prerrequisito vive en `materias`.
        // Por eso validamos el requisito directamente contra la sección objetivo.
        $aprobado = MatriculaDao::verificarPrerrequisitoAprobadoPorSeccion($idEstudiante, $idSeccion);
        if (!$aprobado) {
            $nombreReq = MatriculaDao::obtenerNombreMateriaPorIdDePrerrequisitoDeSeccion($idSeccion);
            return ["exito" => false, "mensaje" => "No cumple con el prerrequisito aprobado: '$nombreReq' (Nota mínima de 70)."];
        }


        // 7. Validar choque de horarios
        $conflicto = MatriculaDao::verificarConflictoHorario($idEstudiante, $idPeriodo, $idSeccion);
        if ($conflicto) {
            $nombreConflicto = $conflicto["nombre_materia"];
            $horaConflicto = substr($conflicto["hora_inicio"], 0, 5) . " - " . substr($conflicto["hora_fin"], 0, 5);
            return ["exito" => false, "mensaje" => "Conflicto de Horario: Se traslapa con la asignatura '$nombreConflicto' ($horaConflicto)."];
        }

        // 8. Registrar Matrícula
        if (MatriculaDao::registrarMatricula($idEstudiante, $idSeccion, $idPeriodo)) {
            return ["exito" => true, "mensaje" => "Asignatura matriculada con éxito."];
        }

        return ["exito" => false, "mensaje" => "Error al guardar la matrícula."];
    }

    public static function cancelarMatriculaEstudiante($idMatricula)
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        // Validar que el periodo de matrícula esté activo
        if (!self::esPeriodoMatriculaActivo()) {
            return ["exito" => false, "mensaje" => "La cancelación no está habilitada fuera del periodo de matrícula."];
        }

        if (MatriculaDao::cancelarMatricula($idMatricula)) {
            return ["exito" => true, "mensaje" => "Asignatura cancelada correctamente."];
        }
        return ["exito" => false, "mensaje" => "No se pudo cancelar la asignatura."];
    }
}