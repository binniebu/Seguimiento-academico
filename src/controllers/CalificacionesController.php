<?php

namespace Controllers;

use Controllers\PublicController;
use Utilities\Context;
use Utilities\Paging;
use Dao\CalificacionDao;
use Views\Renderer;

class CalificacionesController extends PublicController
{
    private $strPartialName = "";
    private $strOrderBy = "";
    private $binOrderDescending = false;
    private $intPageNumber = 1;
    private $intItemsPerPage = 10;
    private $viewData = [];
    private $calificaciones = [];
    private $intCalificacionesCount = 0;
    private $intPages = 0;

    public function run(): void
    {
        $this->getParamsFromContext();
        $this->getParams();
        
        $tmpCalificaciones = CalificacionDao::getCalificaciones(
            $this->strPartialName,
            $this->strOrderBy,
            $this->binOrderDescending,
            $this->intPageNumber - 1,
            $this->intItemsPerPage
        );

        $this->calificaciones = $tmpCalificaciones["calificaciones"];
        $this->intCalificacionesCount = $tmpCalificaciones["total"];
        $this->intPages = $this->intCalificacionesCount > 0 ? ceil($this->intCalificacionesCount / $this->intItemsPerPage) : 1;
        
        if ($this->intPageNumber > $this->intPages && $this->intPages > 0) {
            $this->intPageNumber = $this->intPages;
        }

        $this->setParamsToContext();
        $this->setParamsToDataView();
        
        Renderer::render("calificaciones/list", $this->viewData);
    }

    private function getParams(): void
    {
        $this->strPartialName = isset($_GET["partialName"]) ? $_GET["partialName"] : $this->strPartialName;
        $this->strOrderBy = isset($_GET["orderBy"]) && in_array($_GET["orderBy"], ["id_calificacion", "nota", "clear"]) ? $_GET["orderBy"] : $this->strOrderBy;
        
        if ($this->strOrderBy === "clear") {
            $this->strOrderBy = "";
        }

        $this->binOrderDescending = isset($_GET["orderDescending"]) ? boolval($_GET["orderDescending"]) : $this->binOrderDescending;
        $this->intPageNumber = isset($_GET["pageNum"]) ? intval($_GET["pageNum"]) : $this->intPageNumber;
        $this->intItemsPerPage = isset($_GET["itemsPerPage"]) ? intval($_GET["itemsPerPage"]) : $this->intItemsPerPage;
    }

    private function getParamsFromContext(): void
    {
        $this->strPartialName = Context::getContextByKey("calificaciones_partialName");
        $this->strOrderBy = Context::getContextByKey("calificaciones_orderBy");
        $this->binOrderDescending = boolval(Context::getContextByKey("calificaciones_orderDescending"));
        $this->intPageNumber = intval(Context::getContextByKey("calificaciones_page"));
        $this->intItemsPerPage = intval(Context::getContextByKey("calificaciones_itemsPerPage"));
        
        if ($this->intPageNumber < 1) $this->intPageNumber = 1;
        if ($this->intItemsPerPage < 1) $this->intItemsPerPage = 10;
    }

    private function setParamsToContext(): void
    {
        Context::setContext("calificaciones_partialName", $this->strPartialName, true);
        Context::setContext("calificaciones_orderBy", $this->strOrderBy, true);
        Context::setContext("calificaciones_orderDescending", $this->binOrderDescending, true);
        Context::setContext("calificaciones_page", $this->intPageNumber, true);
        Context::setContext("calificaciones_itemsPerPage", $this->intItemsPerPage, true);
    }

    private function setParamsToDataView(): void
    {
        $this->viewData["partialName"] = $this->strPartialName;
        $this->viewData["orderBy"] = $this->strOrderBy;
        $this->viewData["orderDescending"] = $this->binOrderDescending;
        $this->viewData["pageNum"] = $this->intPageNumber;
        $this->viewData["itemsPerPage"] = $this->intItemsPerPage;
        $this->viewData["calificacionesCount"] = $this->intCalificacionesCount;
        $this->viewData["pages"] = $this->intPages;
        $this->viewData["calificaciones"] = $this->calificaciones;

        if ($this->strOrderBy !== "") {
            $orderByKey = "Order" . ucfirst($this->strOrderBy);
            $this->viewData[$orderByKey] = true;
        }

        $pagination = Paging::getPagination(
            $this->intCalificacionesCount,
            $this->intItemsPerPage,
            $this->intPageNumber,
            "index.php?page=Calificaciones",
            "Calificaciones"
        );
        $this->viewData["pagination"] = $pagination;
    }
}