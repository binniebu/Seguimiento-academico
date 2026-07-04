<?php

namespace Dao;

require_once __DIR__ . "/Dao.php";
require_once __DIR__ . "/Table.php";

class SeccionDao extends Table
{
    public static function obtenerSecciones($buscar = "")
    {
        $sqlstr = "SELECT s.id_seccion, s.id_materia, s.codigo_seccion, s.horario, s.dias_clase, s.aula, s.cupo_maximo, s.cupo_actual,
                          m.nombre as nombre_materia, m.codigo as codigo_materia
                   FROM secciones s
                   INNER JOIN materias m ON s.id_materia = m.id_materia
                   WHERE m.nombre LIKE :buscar OR s.codigo_seccion LIKE :buscar
                   ORDER BY m.nombre ASC, s.codigo_seccion ASC";
        return self::obtenerRegistros($sqlstr, ["buscar" => "%" . $buscar . "%"]);
    }

    public static function obtenerSeccionPorId($idSeccion)
    {
        $sqlstr = "SELECT id_seccion, id_materia, codigo_seccion, horario, dias_clase, aula, cupo_maximo, cupo_actual 
                   FROM secciones 
                   WHERE id_seccion = :id_seccion";
        return self::obtenerUnRegistro($sqlstr, ["id_seccion" => $idSeccion]);
    }

    public static function crearSeccion($idMateria, $codigoSeccion, $horario, $diasClase, $aula, $cupoMaximo)
    {
        $sqlstr = "INSERT INTO secciones (id_materia, codigo_seccion, horario, dias_clase, aula, cupo_maximo, cupo_actual) 
                   VALUES (:id_materia, :codigo_seccion, :horario, :dias_clase, :aula, :cupo_maximo, 0)";
        return self::executeNonQuery($sqlstr, [
            "id_materia" => $idMateria,
            "codigo_seccion" => $codigoSeccion,
            "horario" => $horario,
            "dias_clase" => $diasClase,
            "aula" => $aula,
            "cupo_maximo" => $cupoMaximo
        ]);
    }

    public static function actualizarSeccion($idSeccion, $codigoSeccion, $horario, $diasClase, $aula, $cupoMaximo)
    {
        $sqlstr = "UPDATE secciones 
                   SET codigo_seccion = :codigo_seccion, horario = :horario, dias_clase = :dias_clase, 
                       aula = :aula, cupo_maximo = :cupo_maximo 
                   WHERE id_seccion = :id_seccion";
        return self::executeNonQuery($sqlstr, [
            "id_seccion" => $idSeccion,
            "codigo_seccion" => $codigoSeccion,
            "horario" => $horario,
            "dias_clase" => $diasClase,
            "aula" => $aula,
            "cupo_maximo" => $cupoMaximo
        ]);
    }

    public static function modificarCupo($idSeccion, $nuevoCupoMaximo)
    {
        $sqlstr = "UPDATE secciones SET cupo_maximo = :cupo_maximo WHERE id_seccion = :id_seccion";
        return self::executeNonQuery($sqlstr, [
            "id_seccion" => $idSeccion,
            "cupo_maximo" => $nuevoCupoMaximo
        ]);
    }

    public static function eliminarSeccion($idSeccion)
    {
        $sqlstr = "DELETE FROM secciones WHERE id_seccion = :id_seccion";
        return self::executeNonQuery($sqlstr, ["id_seccion" => $idSeccion]);
    }
}
