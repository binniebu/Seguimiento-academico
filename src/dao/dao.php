<?php

namespace Dao;

use PDO;
use PDOException;

class Dao
{
    private static ?PDO $_conn = null;

    private function __construct()
    {
    }

    private function __clone()
    {
    }

    public static function getConn($dds = null, $user = null, $pswd = null)
    {
        if (self::$_conn == null) {

            $envPath = __DIR__ . "/../../parameters.env";
            $env = parse_ini_file($envPath);

            $provider = $env["DB_PROVIDER"];
            $server = $env["DB_SERVER"];
            $database = $env["DB_DATABASE"];
            $port = $env["DB_PORT"];
            $dbUser = $env["DB_USER"];
            $dbPswd = $env["DB_PSWD"];

            $dds = sprintf(
                "%s:host=%s;dbname=%s;port=%s;charset=utf8",
                $provider,
                $server,
                $database,
                $port
            );

            try {
                self::$_conn = new PDO(
                    $dds,
                    $dbUser,
                    $dbPswd,
                    array(
                        PDO::ATTR_EMULATE_PREPARES => true,
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_PERSISTENT => false
                    )
                );
            } catch (PDOException $ex) {
                die("Error de conexión: " . $ex->getMessage());
            }
        }

        return self::$_conn;
    }
}
?>