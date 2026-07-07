<?php

namespace Controllers;

require_once __DIR__ . "/../dao/MateriaDao.php";
require_once __DIR__ . "/../dao/SeccionDao.php";

use Dao\MateriaDao;
use Dao\SeccionDao;

class MateriasController
{
    /**
     * Listar todas las materias
     */
    public static function listar()
    {
        return MateriaDao::listarMaterias();
    }

    /**
     * Buscar materias
     */
    public static function buscar($termino)
    {
        if (empty($termino)) {
            return self::listar();
        }
        return MateriaDao::buscarMateria($termino);
    }

    /**
     * Obtener detalle de materia
     */
    public static function obtener($id)
    {
        return MateriaDao::obtenerMateria($id);
    }

    /**
     * Crear nueva materia
     */
    public static function crear($codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito = null)
    {
        // Validaciones
        if (empty($codigo) || empty($nombre) || empty($creditos) || empty($periodo) || empty($tipo_materia)) {
            return ['exito' => false, 'mensaje' => 'Campos obligatorios vacíos'];
        }

        if (MateriaDao::existeCodigoMateria($codigo)) {
            return ['exito' => false, 'mensaje' => 'El código de materia ya existe. No se pueden duplicar códigos.'];
        }

        if (MateriaDao::existeNombreMateria($nombre)) {
            return ['exito' => false, 'mensaje' => 'El nombre de la materia ya existe. No se pueden duplicar materias.'];
        }

        if (!empty($id_requisito)) {
            $requisito = MateriaDao::obtenerMateria($id_requisito);
            if ($requisito && intval($periodo) <= intval($requisito['periodo'])) {
                return [
                    'exito' => false, 
                    'mensaje' => "Error de flujo académico: No puedes cursar esta clase en el Periodo {$periodo} si su requisito ('{$requisito['nombre']}') se cursa en el Periodo {$requisito['periodo']}. El periodo debe ser estrictamente mayor."
                ];
            }
        }

        if (MateriaDao::registrarMateria($codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito)) {
            return ['exito' => true, 'mensaje' => 'Materia registrada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al registrar la materia'];
        }
    }

    /**
     * Actualizar materia
     */
    public static function actualizar($id, $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito, $estado)
    {
        // Validaciones
        if (empty($codigo) || empty($nombre) || empty($creditos) || empty($periodo) || empty($tipo_materia)) {
            return ['exito' => false, 'mensaje' => 'Campos obligatorios vacíos'];
        }

        if (MateriaDao::existeCodigoMateria($codigo, $id)) {
            return ['exito' => false, 'mensaje' => 'El código de materia ya existe. No se pueden duplicar códigos.'];
        }

        if (MateriaDao::existeNombreMateria($nombre, $id)) {
            return ['exito' => false, 'mensaje' => 'El nombre de la materia ya existe. No se pueden duplicar materias.'];
        }

        if (!empty($id_requisito)) {
            $requisito = MateriaDao::obtenerMateria($id_requisito);
            if ($requisito && intval($periodo) <= intval($requisito['periodo'])) {
                return [
                    'exito' => false, 
                    'mensaje' => "Error de flujo académico: No puedes cursar esta clase en el Periodo {$periodo} si su requisito ('{$requisito['nombre']}') se cursa en el Periodo {$requisito['periodo']}. El periodo debe ser estrictamente mayor."
                ];
            }
        }

        if (MateriaDao::actualizarMateria($id, $codigo, $nombre, $descripcion, $creditos, $periodo, $tipo_materia, $id_facultad, $id_carrera, $id_requisito, $estado)) {
            return ['exito' => true, 'mensaje' => 'Materia actualizada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al actualizar la materia'];
        }
    }

    /**
     * Eliminar materia
     */
    public static function eliminar($id)
    {
        if (MateriaDao::eliminarMateria($id)) {
            return ['exito' => true, 'mensaje' => 'Materia eliminada correctamente'];
        } else {
            return ['exito' => false, 'mensaje' => 'Error al eliminar la materia'];
        }
    }

    /**
     * Obtener facultades para el selector
     */
    public static function obtenerFacultades()
    {
        return MateriaDao::obtenerFacultades();
    }

    /**
     * Renderizar la vista de Flujograma de Carrera
     */
    public static function verFlujograma()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        $id_carrera = $_GET['id'] ?? null;
        
        // Bloquear si el coordinador intenta ver otra carrera fuera de su facultad
        if (isset($_SESSION["rol"]) && $_SESSION["rol"] === "coordinador") {
            require_once __DIR__ . "/../dao/CarreraDao.php";
            $carreraContext = \Dao\CarreraDao::obtenerCarreraPorId($id_carrera);
            if (!$carreraContext || $carreraContext["id_facultad"] != ($_SESSION["id_facultad"] ?? null)) {
                echo "<script>alert('No tiene permiso para gestionar el flujograma de esta carrera'); window.location='index.php?page=carreras';</script>";
                exit();
            }
        }

        if (!$id_carrera) {
            header("Location: index.php?page=carreras");
            exit;
        }

        require_once __DIR__ . "/../dao/CarreraDao.php";
        $carrera = \Dao\CarreraDao::obtenerCarreraPorId($id_carrera);
        
        if (!$carrera) {
            header("Location: index.php?page=carreras");
            exit;
        }

        $id_facultad = $carrera['id_facultad'] ?? null;
        $materias = MateriaDao::obtenerFlujogramaPorCarrera($id_carrera, $id_facultad);

        require_once __DIR__ . "/../views/templates/materias/carrera_flujograma.view.tpl";
    }

    /**
     * Obtener carreras para el selector
     */
    public static function obtenerCarrerasActivas()
    {
        return MateriaDao::obtenerCarrerasActivas();
    }

    public static function listarSecciones($buscar = "")
    {
        $periodoActivo = SeccionDao::obtenerPeriodoActivo();
        $idPeriodo = $periodoActivo["id_periodo"] ?? null;
        $idFacultad = self::facultadCoordinadorActual();

        if (!$idPeriodo) {
            return [];
        }

        return SeccionDao::obtenerSecciones($buscar, $idPeriodo, $idFacultad);
    }

    public static function obtenerPeriodoActivo()
    {
        return SeccionDao::obtenerPeriodoActivo();
    }

    public static function obtenerPeriodoAnterior($idPeriodoActivo)
    {
        return SeccionDao::obtenerPeriodoAnterior($idPeriodoActivo);
    }

    public static function obtenerSeccion($idSeccion)
    {
        $idFacultad = self::facultadCoordinadorActual();

        if (!SeccionDao::usuarioPuedeGestionarSeccion($idSeccion, $idFacultad)) {
            return false;
        }

        return SeccionDao::obtenerSeccionPorId($idSeccion);
    }

    public static function obtenerMateriasProgramables()
    {
        return SeccionDao::obtenerMateriasProgramables(self::facultadCoordinadorActual());
    }

    public static function obtenerMaestrosSeleccionables()
    {
        $periodoActivo = SeccionDao::obtenerPeriodoActivo();
        return SeccionDao::obtenerMaestrosSeleccionables(!empty($periodoActivo));
    }

    public static function guardarSeccion()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $idSeccion = $_POST["id_seccion"] ?? null;
        $idMateria = $_POST["id_materia"] ?? "";
        $idMaestro = $_POST["id_maestro"] ?? "";
        $codigoSeccion = trim($_POST["codigo_seccion"] ?? "");
        $aula = trim($_POST["aula"] ?? "");
        $dias = SeccionDao::normalizarDias($_POST["dias"] ?? []);
        $horaInicio = $_POST["hora_inicio"] ?? "";
        $horaFin = $_POST["hora_fin"] ?? "";
        $cupoMaximo = intval($_POST["cupo_maximo"] ?? 0);
        $estado = $_POST["estado"] ?? "Borrador";

        $redir = $idSeccion
            ? "index.php?page=seccion_nueva&id=" . urlencode($idSeccion)
            : "index.php?page=seccion_nueva";

        $periodoActivo = SeccionDao::obtenerPeriodoActivo();
        if (!$periodoActivo) {
            self::alertarYRedirigir("No hay un periodo academico activo para programar secciones.", "index.php?page=secciones");
        }

        $idPeriodo = intval($periodoActivo["id_periodo"]);
        $idFacultad = self::facultadCoordinadorActual();

        if ($idSeccion && !SeccionDao::usuarioPuedeGestionarSeccion($idSeccion, $idFacultad)) {
            self::alertarYRedirigir("No tiene permiso para modificar esta seccion.", "index.php?page=secciones");
        }

        if (empty($idMateria) || empty($idMaestro) || $aula === "" || $dias === "" || $horaInicio === "" || $horaFin === "" || $cupoMaximo <= 0) {
            self::alertarYRedirigir("Complete todos los campos obligatorios de la seccion.", $redir);
        }

        if (strtotime($horaInicio) >= strtotime($horaFin)) {
            self::alertarYRedirigir("La hora de inicio debe ser menor que la hora de fin.", $redir);
        }

        if (!in_array($estado, ["Borrador", "Activa", "Cerrada"], true)) {
            $estado = "Borrador";
        }

        if (!SeccionDao::materiaDisponibleParaFacultad($idMateria, $idFacultad)) {
            self::alertarYRedirigir("La asignatura seleccionada no pertenece a su alcance academico.", $redir);
        }

        if (!SeccionDao::maestroPuedeImpartir($idMaestro, true)) {
            self::alertarYRedirigir("El docente seleccionado no puede impartir clases en el periodo activo.", $redir);
        }

        if ($codigoSeccion === "") {
            $codigoSeccion = self::generarCodigoSeccion($idMateria, $idPeriodo, $dias, $horaInicio);
        }

        if (SeccionDao::existeCodigoSeccion($codigoSeccion, $idSeccion)) {
            self::alertarYRedirigir("Ya existe una seccion con ese codigo.", $redir);
        }

        $choqueAula = SeccionDao::buscarChoqueAula($idPeriodo, $aula, $dias, $horaInicio, $horaFin, $idSeccion);
        if ($choqueAula) {
            self::alertarYRedirigir(
                "Choque de aula: " . $aula . " ya esta ocupada por " . ($choqueAula["nombre_materia"] ?? "otra seccion") . " en ese horario.",
                $redir
            );
        }

        $choqueMaestro = SeccionDao::buscarChoqueMaestro($idPeriodo, $idMaestro, $dias, $horaInicio, $horaFin, $idSeccion);
        if ($choqueMaestro) {
            self::alertarYRedirigir(
                "Choque de docente: el maestro ya tiene " . ($choqueMaestro["nombre_materia"] ?? "otra seccion") . " en ese horario.",
                $redir
            );
        }

        if ($idSeccion) {
            $resultado = SeccionDao::actualizarSeccion(
                $idSeccion,
                $idMateria,
                $idMaestro,
                $codigoSeccion,
                $aula,
                $dias,
                $horaInicio,
                $horaFin,
                $cupoMaximo,
                $estado
            );
            $mensaje = $resultado ? "Seccion actualizada correctamente." : "Error al actualizar la seccion.";
        } else {
            $resultado = SeccionDao::crearSeccion(
                $idMateria,
                $idMaestro,
                $idPeriodo,
                $codigoSeccion,
                $aula,
                $dias,
                $horaInicio,
                $horaFin,
                $cupoMaximo,
                $estado
            );
            $mensaje = $resultado ? "Seccion creada correctamente." : "Error al crear la seccion.";
        }

        self::alertarYRedirigir($mensaje, "index.php?page=secciones");
    }

    public static function eliminarSeccion($idSeccion)
    {
        $idFacultad = self::facultadCoordinadorActual();

        if (!SeccionDao::usuarioPuedeGestionarSeccion($idSeccion, $idFacultad)) {
            return ["exito" => false, "mensaje" => "No tiene permiso para eliminar esta seccion."];
        }

        $resultado = SeccionDao::eliminarSeccion($idSeccion);
        return [
            "exito" => $resultado,
            "mensaje" => $resultado ? "Seccion eliminada correctamente." : "Error al eliminar la seccion."
        ];
    }

    public static function clonarSeccionesPeriodoAnterior()
    {
        $periodoActivo = SeccionDao::obtenerPeriodoActivo();
        if (!$periodoActivo) {
            return ["exito" => false, "mensaje" => "No hay periodo activo para recibir secciones."];
        }

        $periodoAnterior = SeccionDao::obtenerPeriodoAnterior($periodoActivo["id_periodo"]);
        if (!$periodoAnterior) {
            return ["exito" => false, "mensaje" => "No se encontro un periodo anterior para clonar."];
        }

        $resultado = SeccionDao::clonarPeriodoAnterior(
            $periodoAnterior["id_periodo"],
            $periodoActivo["id_periodo"],
            self::facultadCoordinadorActual()
        );

        if (!$resultado["exito"]) {
            return ["exito" => false, "mensaje" => "Error al clonar las secciones del periodo anterior."];
        }

        return [
            "exito" => true,
            "mensaje" => "Clonacion completada: {$resultado['copiadas']} secciones copiadas y {$resultado['omitidas']} omitidas por duplicado o choque."
        ];
    }

    public static function activarBorradores()
    {
        $periodoActivo = SeccionDao::obtenerPeriodoActivo();
        if (!$periodoActivo) {
            return ["exito" => false, "mensaje" => "No hay periodo activo."];
        }

        $actualizadas = SeccionDao::activarBorradores($periodoActivo["id_periodo"], self::facultadCoordinadorActual());
        return [
            "exito" => true,
            "mensaje" => "{$actualizadas} secciones en borrador fueron activadas."
        ];
    }

    private static function facultadCoordinadorActual()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        if (($_SESSION["rol"] ?? "") === "coordinador") {
            return $_SESSION["id_facultad"] ?? null;
        }

        return null;
    }

    private static function generarCodigoSeccion($idMateria, $idPeriodo, $dias, $horaInicio)
    {
        $materia = MateriaDao::obtenerMateria($idMateria);
        $codigoMateria = $materia["codigo"] ?? "SEC";
        $base = strtoupper(preg_replace('/[^A-Z0-9]/i', '', $codigoMateria));
        $base = substr($base !== "" ? $base : "SEC", 0, 8);
        $diasCodigo = substr(str_replace(",", "", $dias), 0, 4);
        $horaCodigo = str_replace(":", "", substr($horaInicio, 0, 5));
        $codigo = substr($base . "-" . $diasCodigo . "-" . $horaCodigo . "P" . intval($idPeriodo), 0, 20);
        $contador = 1;

        while (SeccionDao::existeCodigoSeccion($codigo)) {
            $sufijo = "-" . $contador;
            $codigo = substr($base . "-" . $diasCodigo . "-" . $horaCodigo . "P" . intval($idPeriodo), 0, 20 - strlen($sufijo)) . $sufijo;
            $contador++;
        }

        return $codigo;
    }

    private static function alertarYRedirigir($mensaje, $url)
    {
        echo "<script>alert('" . htmlspecialchars($mensaje, ENT_QUOTES) . "'); window.location='" . $url . "';</script>";
        exit();
    }
}

?>
