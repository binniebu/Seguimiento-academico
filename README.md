Sistema de Seguimiento Académico

Descripción del Proyecto

El Sistema de Seguimiento Académico es una aplicación web desarrollada para administrar y controlar la información académica de una institución educativa. El sistema permite gestionar estudiantes, maestros, materias, calificaciones, matrículas, usuarios y reportes académicos desde una única plataforma.

El proyecto fue desarrollado utilizando PHP bajo una arquitectura tipo MVC, MySQL como gestor de base de datos y Bootstrap para la interfaz gráfica.

⸻

Tecnologías Utilizadas

* PHP 8.x
* MySQL
* phpMyAdmin
* Composer
* Bootstrap 5
* HTML5
* CSS3
* JavaScript
* XAMPP
* Git y GitHub

⸻

Estructura del Proyecto

Equipo5_SeminarioSoftware/
│
├── database/
│
├── public/
│   └── css/
│
├── src/
│   ├── controllers/
│   ├── dao/
│   ├── utilities/
│   └── views/
│       └── templates/
│
├── vendor/
│
├── composer.json
├── composer.lock
├── index.php
├── parameters.env
└── README.md

⸻

Explicación de Carpetas

database

Contiene los scripts SQL necesarios para crear e importar la base de datos del sistema.

⸻

public

Contiene los recursos públicos utilizados por la aplicación.

css

Almacena los estilos personalizados utilizados por la interfaz.

⸻

src

Contiene toda la lógica principal del sistema.

controllers

Gestionan las acciones del usuario y conectan las vistas con los datos.

Ejemplos:

* HomeController
* MaestrosController
* EstudiantesController

dao

Contiene las clases encargadas de realizar consultas a la base de datos.

Ejemplos:

* UsuarioDao
* MaestroDao
* Dao
* Table

utilities

Contiene herramientas auxiliares del sistema.

Ejemplos:

* Security.php
* Site.php

views

Contiene todas las vistas y pantallas de la aplicación.

Módulos incluidos:

* Login y Registro
* Dashboard
* Estudiantes
* Maestros
* Materias
* Matrículas
* Calificaciones
* Reportes
* Usuarios

⸻

Funcionalidades del Sistema

Gestión de Usuarios

Permite:

* Registrar usuarios
* Editar usuarios
* Eliminar usuarios
* Asignar roles
* Buscar usuarios

⸻

Gestión de Estudiantes

Permite:

* Registrar estudiantes
* Modificar estudiantes
* Eliminar estudiantes
* Consultar información académica

⸻

Gestión de Maestros

Permite:

* Registrar maestros
* Modificar maestros
* Eliminar maestros
* Asignar especialidades

⸻

Gestión de Materias

Permite:

* Registrar materias
* Asignar maestros
* Administrar cupos

⸻

Gestión de Calificaciones

Permite:

* Registrar notas
* Consultar rendimiento académico
* Generar promedios

⸻

Reportes

Permite visualizar:

* Total de estudiantes
* Estudiantes activos
* Cupos ocupados
* Rendimiento por materia
* Reporte por estudiante
* Carga académica por maestro

⸻

Roles del Sistema

Director

Acceso completo a todos los módulos:

* Home
* Dashboard
* Estudiantes
* Maestros
* Materias
* Calificaciones
* Reportes
* Usuarios

⸻

Maestro

Acceso limitado a:

* Home
* Dashboard
* Materias
* Calificaciones
* Reportes

No tiene acceso a:

* Usuarios
* Gestión de Maestros
* Gestión de Estudiantes

⸻

Estudiante

Acceso limitado a:

* Home
* Dashboard
* Materias
* Calificaciones

No tiene acceso a:

* Usuarios
* Reportes
* Gestión de Maestros
* Gestión de Estudiantes

⸻

Requisitos para Ejecutar el Proyecto

Antes de iniciar el proyecto debe instalar:

* XAMPP
* PHP
* Composer
* Git
* Visual Studio Code

⸻

Instalación del Proyecto

1. Clonar el repositorio

git clone https://github.com/JRAMOS11/Equipo5_SeminarioSoftware.git

2. Ingresar al proyecto

cd Equipo5_SeminarioSoftware

3. Instalar dependencias

composer install

4. Crear la Base de Datos

Abrir phpMyAdmin:

http://localhost/phpmyadmin

Crear la base de datos:

seguimiento_academico

Importar el archivo SQL ubicado dentro de la carpeta:

database/

⸻

5. Configurar parameters.env

Ejemplo:

DB_HOST = localhost
DB_USER = root
DB_PSWD =
DB_DATABASE = seguimiento_academico
DB_PORT = 3306
TIMEZONE = America/Tegucigalpa
BASE_DIR = NWEB/Equipo5_SeminarioSoftware/
DEVELOPMENT = 1

⸻

Ejecución del Proyecto

Iniciar Apache y MySQL desde XAMPP.

Luego abrir:

http://localhost/NWEB/Equipo5_SeminarioSoftware/

o

http://localhost/Equipo5_SeminarioSoftware/

dependiendo de la ubicación del proyecto.

⸻

Comandos Git Utilizados

Verificar cambios:

git status

Agregar cambios:

git add .

Crear commit:

git commit -m "Descripción del cambio"

Subir cambios:

git push origin main

Actualizar repositorio local:

git pull origin main

⸻

Estado Actual del Proyecto

Actualmente el sistema cuenta con:

* Sistema de Login
* Registro de usuarios
* Gestión de maestros
* Gestión de estudiantes
* Gestión de materias
* Gestión de usuarios
* Reportes académicos
* Dashboard principal
* Conexión a MySQL
* Diseño responsive con Bootstrap

⸻
