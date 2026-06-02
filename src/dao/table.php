<?php

namespace Dao;

use PDO;

abstract class Table
{
    private static ?PDO $_conn = null;

    protected static function getConn(): PDO
    {
        if (self::$_conn === null) {
            self::$_conn = Dao::getConn();
        }

        return self::$_conn;
    }

    private static array $_bindMapping = array(
        "boolean" => PDO::PARAM_BOOL,
        "integer" => PDO::PARAM_INT,
        "double" => PDO::PARAM_STR,
        "string" => PDO::PARAM_STR,
        "array" => PDO::PARAM_STR,
        "object" => PDO::PARAM_STR,
        "resource" => PDO::PARAM_STR,
        "NULL" => PDO::PARAM_NULL,
        "unknown type" => PDO::PARAM_STR
    );

    protected static function getBindType(mixed $value): int
    {
        $valueType = gettype($value);

        if (isset(self::$_bindMapping[$valueType])) {
            return self::$_bindMapping[$valueType];
        }

        return PDO::PARAM_STR;
    }

    protected static function obtenerRegistros(string $sqlstr, array $params = array(), &$conn = null): array
    {
        $pConn = ($conn !== null) ? $conn : self::getConn();

        $query = $pConn->prepare($sqlstr);

        foreach ($params as $key => $value) {
            $query->bindValue(":" . $key, $value, self::getBindType($value));
        }

        $query->execute();
        $query->setFetchMode(PDO::FETCH_ASSOC);

        return $query->fetchAll();
    }

    protected static function obtenerUnRegistro(string $sqlstr, array $params = array(), &$conn = null): array|false
    {
        $pConn = ($conn !== null) ? $conn : self::getConn();

        $query = $pConn->prepare($sqlstr);

        foreach ($params as $key => $value) {
            $query->bindValue(":" . $key, $value, self::getBindType($value));
        }

        $query->execute();
        $query->setFetchMode(PDO::FETCH_ASSOC);

        return $query->fetch();
    }

    protected static function executeNonQuery(string $sqlstr, array $params = array(), &$conn = null): bool
    {
        $pConn = ($conn !== null) ? $conn : self::getConn();

        $query = $pConn->prepare($sqlstr);

        foreach ($params as $key => $value) {
            $query->bindValue(":" . $key, $value, self::getBindType($value));
        }

        return $query->execute();
    }

    protected static function executeNonQueryRows(string $sqlstr, array $params = array(), &$conn = null): int
    {
        $pConn = ($conn !== null) ? $conn : self::getConn();

        $query = $pConn->prepare($sqlstr);

        foreach ($params as $key => $value) {
            $query->bindValue(":" . $key, $value, self::getBindType($value));
        }

        $query->execute();

        return $query->rowCount();
    }

    protected static function getLastInsertId(): string|false
    {
        return self::getConn()->lastInsertId();
    }
}

?>