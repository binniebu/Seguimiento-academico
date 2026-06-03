<?php

namespace Controllers;

use Controllers\PublicController;
use Views\Renderer;
use Dao\CalificacionDao;
use Utilities\Site;
use Utilities\Validators;

class CalificacionController extends PublicController
{
    private $viewData = [];
    private $mode = "DSP";
    private $modeDescriptions = [
        "DSP" => "Detalle de Calificación #%s",
        "INS" => "Registrar Nota",
        "UPD" => "Editar Nota #%s",
        "DEL" => "Eliminar Nota #%s"
    ];

    private $readonly = "";
    private $showCommitBtn = true;

    private $calificacion = [
        "id_calificacion" => 0,
        "id_matricula" => 0,
        "nota" => 0.00,
        "observacion" => ""
    ];

    public function run(): void
    {
        try {
            $this->getData();

            if ($this->isPostBack()) {
                if ($this->validateData()) {
                    $this->handlePostAction();
                }
            }

            $this->setViewData();
            Renderer::render("calificaciones/form", $this->viewData);

        } catch (\Exception $ex) {
            Site::redirectToWithMsg(
                "index.php?page=Calificaciones",
                $ex->getMessage()
            );
        }
    }

    private function getData()
    {
        $this->mode = $_GET["mode"] ?? "NOF";

        if (isset($this->modeDescriptions[$this->mode])) {
            $this->readonly = ($this->mode === "DEL" || $this->mode === "DSP") ? "readonly" : "";
            $this->showCommitBtn = $this->mode !== "DSP";

            if ($this->mode !== "INS") {
                $this->calificacion = CalificacionDao::getCalificacionById(
                    intval($_GET["id_calificacion"])
                );

                if (!$this->calificacion) {
                    throw new \Exception("No se encontró el registro de calificación", 1);
                }
            }
        } else {
            throw new \Exception("Formulario cargado en modalidad inválida", 1);
        }
    }

    private function validateData()
    {
        $errors = [];

        $this->calificacion["id_calificacion"] = intval($_POST["id_calificacion"] ?? 0);
        $this->calificacion["id_matricula"] = intval($_POST["id_matricula"] ?? 0);
        $this->calificacion["nota"] = floatval($_POST["nota"] ?? 0.00);
        $this->calificacion["observacion"] = strval($_POST["observacion"] ?? "");

        if ($this->calificacion["id_matricula"] <= 0) {
            $errors["id_matricula_error"] = "Debe seleccionar una matrícula válida";
        }

        if ($this->calificacion["nota"] < 0 || $this->calificacion["nota"] > 100) {
            $errors["nota_error"] = "La nota debe estar comprendida entre 0 y 100";
        }

        if (count($errors) > 0) {
            foreach ($errors as $key => $value) {
                $this->calificacion[$key] = $value;
            }
            return false;
        }

        return true;
    }

    private function handlePostAction()
    {
        switch ($this->mode) {
            case "INS":
                $this->handleInsert();
                break;
            case "UPD":
                $this->handleUpdate();
                break;
            case "DEL":
                $this->handleDelete();
                break;
            default:
                throw new \Exception("Modo inválido", 1);
        }
    }

    private function handleInsert()
    {
        $result = CalificacionDao::insertCalificacion(
            $this->calificacion["id_matricula"],
            $this->calificacion["nota"],
            $this->calificacion["observacion"]
        );

        if ($result > 0) {
            Site::redirectToWithMsg("index.php?page=Calificaciones", "Nota registrada exitosamente");
        }
    }

    private function handleUpdate()
    {
        $result = CalificacionDao::updateCalificacion(
            $this->calificacion["id_calificacion"],
            $this->calificacion["id_matricula"],
            $this->calificacion["nota"],
            $this->calificacion["observacion"]
        );

        if ($result > 0) {
            Site::redirectToWithMsg("index.php?page=Calificaciones", "Nota actualizada exitosamente");
        }
    }

    private function handleDelete()
    {
        $result = CalificacionDao::deleteCalificacion($this->calificacion["id_calificacion"]);

        if ($result > 0) {
            Site::redirectToWithMsg("index.php?page=Calificaciones", "Nota eliminada correctamente");
        }
    }

    private function setViewData(): void
    {
        $this->viewData["mode"] = $this->mode;
        $this->viewData["FormTitle"] = sprintf(
            $this->modeDescriptions[$this->mode],
            $this->calificacion["id_calificacion"]
        );
        $this->viewData["showCommitBtn"] = $this->showCommitBtn;
        $this->viewData["readonly"] = $this->readonly;

        // Cargar combobox de matrículas
        $dbMatriculas = CalificacionDao::getMatriculasDisponibles();
        $matriculasList = [];
        foreach ($dbMatriculas as $mat) {
            $mat["selected"] = ($mat["id_matricula"] == $this->calificacion["id_matricula"]) ? "selected" : "";
            $matriculasList[] = $mat;
        }

        $this->viewData["calificacion"] = $this->calificacion;
        $this->viewData["matriculas"] = $matriculasList;
    }
}