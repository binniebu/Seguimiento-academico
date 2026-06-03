<?php

namespace Controllers;

use Controllers\PublicController;
use Dao\UsuarioDao;
use Views\Renderer;

class ReportesController extends PublicController
{
    private $viewData = [];

    public function run(): void
    {
        // 1. Cargar Reporte por Estudiante
        $this->viewData["reporte_estudiantes"] = UsuarioDao::getReporteEstudiantes();

        // 2. Cargar Reporte por Maestro
        $this->viewData["reporte_maestros"] = UsuarioDao::getReporteMaestros();

        // 3. Cargar Reporte por Materias y Promedios
        $this->viewData["reporte_materias"] = UsuarioDao::getReporteMateriasYPromedios();

        // 4. Cargar Cantidad de estudiantes matriculados e Indicadores Estadísticos
        $resumen = UsuarioDao::getResumenMatriculasGlobal();
        $this->viewData["total_estudiantes"] = $resumen["total_estudiantes_sistema"];
        $this->viewData["estudiantes_activos"] = $resumen["estudiantes_con_matricula_activa"];
        $this->viewData["total_cupos"] = $resumen["total_cupos_matriculados"];

        // Renderizar la vista unificada en la carpeta reportes
        Renderer::render("reportes/dashboard", $this->viewData);
    }
}