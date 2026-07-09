# Sistema de Seguimiento Académico y Gestión de Matrícula

El Sistema de Seguimiento Académico y Gestión de Matrícula es una plataforma web moderna, centralizada e interactiva diseñada para administrar de manera eficiente la estructura académica, el expediente del estudiante, la programación docente y el proceso de calificaciones de una institución de educación superior.

El sistema se basa en un diseño premium enfocado en la usabilidad, responsividad móvil total y arquitectura MVC limpia bajo PHP Vanilla y base de datos relacional MySQL.

---

## 📌 Tabla de Contenidos
1. [Características Principales](#-características-principales)
2. [Arquitectura y Stack Tecnológico](#-arquitectura-y-stack-tecnológico)
3. [Estructura del Proyecto](#-estructura-del-proyecto)
4. [Roles y Permisos del Sistema](#-roles-y-permisos-del-sistema)
5. [Lógica de Negocio y Reglas Críticas](#-lógica-de-negocio-y-reglas-críticas)
6. [Instalación y Configuración](#-instalación-y-configuración)
7. [Credenciales Demo de Prueba](#-credenciales-demo-de-prueba)

---

## 🌟 Características Principales

*   **Matrícula Manual Centralizada:** El Director tiene la potestad de abrir o cerrar los periodos de matrícula académica en tiempo real a través de un panel de control con un solo clic.
*   **Gestión de Admisiones (Aspirantes):** Sistema de registro público de estudiantes con carga digital de DNI y título de respaldo. El Coordinador audita, aprueba o rechaza solicitudes de matrícula de forma interactiva.
*   **Control del Flujo de Notas:** Los docentes registran notas por parcial (I, II y III). El sistema realiza cálculos en tiempo real y gestiona estados dinámicos (Cursando, Aprobado, Reprobado).
*   **Dashboard y KPI Ejecutivos:** Índices académicos globales automáticos, cálculo de avance del plan de estudios y visualización interactiva de horarios en formato de agenda semanal.
*   **Experiencia de Usuario:** Alertas interactivas integradas con **SweetAlert2** para confirmaciones seguras y buscador instantáneo de elementos.
*   **Diseño 100% Responsivo:** Panel adaptado para celulares y tablets mediante un menú lateral (drawer) deslizable y tablas dinámicas fluidas.

---

## 🛠️ Arquitectura y Stack Tecnológico

La aplicación está construida sobre una arquitectura desacoplada de **Modelo-Vista-Controlador (MVC)** vanilla sin frameworks de terceros, asegurando velocidad y control absoluto de los flujos:

*   **Backend:** PHP 8.x con PDO (PHP Data Objects) para acceso seguro y mitigación de Inyecciones SQL mediante consultas parametrizadas.
*   **Base de Datos:** MySQL 8.x con integridad referencial robusta y triggers/cálculos a nivel de software.
*   **Frontend:** Bootstrap 5.3.3 (Maquetación y Grid), Vanilla CSS3 (Estilos premium y animaciones) y JavaScript ES6 (Asincronismo e interactividad).
*   **Librerías Extra:** 
    *   [SweetAlert2](https://sweetalert2.github.io/) para diálogos y confirmaciones de usuario.
    *   [Tom Select](https://tom-select.js.org/) para buscadores embebidos en menús desplegables (Selects).
    *   [Bootstrap Icons](https://icons.getbootstrap.com/) para iconografía general.

---

## 📂 Estructura del Proyecto

```text
Seguimiento-academico/
├── database/               # Scripts de base de datos y esquema SQL de instalación
├── public/                 # Recursos públicos expuestos
│   ├── css/
│   │   └── style.css       # Estilos visuales del sistema (incluye reglas responsive)
│   └── js/
│       ├── sidebar.js      # Control centralizado del menú responsivo móvil y desktop
│       └── confirmaciones.js # Interceptor centralizado de SweetAlert2 para confirmaciones
├── src/                    # Código fuente del sistema
│   ├── controllers/        # Controladores MVC (lógica de interacción y negocio)
│   ├── dao/                # Data Access Objects (capa de consultas SQL parametrizadas)
│   ├── utilities/          # Middlewares y utilidades (seguridad, sesión, roles)
│   └── views/
│       └── templates/      # Plantillas de la interfaz gráfica (.tpl)
├── index.php               # Enrutador central de la aplicación
├── parameters.env          # Configuración de variables de entorno del sistema
└── README.md               # Documentación general
```

---

## 👥 Roles y Permisos del Sistema

El sistema implementa un control de acceso basado en roles (**RBAC**) gestionado por `RoleMiddleware.php`:

| Rol | Vistas en Sidebar | Acciones del Dashboard (Inicio) | Permisos Clave |
| :--- | :--- | :--- | :--- |
| **Director** | Inicio, Estudiantes, Personal | Gestión de Facultades, Periodos, Carreras y Secciones | Control y alternancia manual del periodo de matrícula, dar de alta/baja personal y coordinadores. |
| **Coordinador** | Inicio, Estudiantes | Gestión de Carreras, Secciones y Solicitudes de Registro | Aprobar/rechazar solicitudes de matrícula de aspirantes, dar de alta/baja estudiantes, programar secciones. |
| **Maestro** | Inicio, Mis Secciones | Registrar Calificaciones (Ingreso directo de parciales I, II, III) | Asentar notas, ver listado de alumnos asignados por sección, control de asistencia visual. |
| **Estudiante** | Inicio, Mis Materias, Mi Flujograma, Historial | Ver índice acumulado, Horario semanal, Avance del Plan | Matricular asignaturas y cancelarlas (si la matrícula está abierta), ver notas parciales. |

---

## 📐 Lógica de Negocio y Reglas Críticas

### 1. Cálculo de Calificaciones y Aprobación
*   El promedio final de una clase se calcula como la sumatoria de las notas de los tres parciales dividida **siempre entre 3**:
    $$\text{Promedio} = \frac{\text{Parcial I} + \text{Parcial II} + \text{Parcial III}}{3}$$
*   Si un docente aún no registra la nota de algún parcial, el sistema la computa como `0.00` para efectos del promedio acumulado.
*   Mientras falte asentar algún parcial, el estado de la asignatura en el perfil del alumno figurará como **CURSANDO** (color celeste). Solo se mostrará **APROBADO** ($\ge 70\%$) o **REPROBADO** ($< 70\%$) cuando las tres notas estén completas en el sistema.

### 2. Promedio Académico Global (Índice)
*   El promedio global de la carrera del estudiante no considera las materias activas en curso (para evitar penalizarlo con promedios incompletos).
*   El índice se recalcula exclusivamente al finalizar cada período académico a partir de las calificaciones consolidadas en el historial.

### 3. Matrícula y Cancelaciones
*   El Director abre la matrícula de forma manual desde el portal. Esto activa la visualización del módulo de matrícula e inscripción en la sesión del Estudiante.
*   El Estudiante solo puede inscribir materias si:
    *   La asignatura pertenece a su carrera u orientada a asignaturas institucionales.
    *   Cumple con los requisitos académicos de la materia (prerrequisitos aprobados).
    *   La sección cuenta con cupos disponibles (los cupos se decrementan con cada matrícula).
    *   No tiene cruces de horario en su agenda semanal.

---

## 🚀 Instalación y Configuración

### Requisitos Previos
*   XAMPP (con PHP 8.1 o superior y MySQL).
*   Composer (para instalar dependencias de desarrollo).

### Pasos para Configuración Local
1.  **Clonar el repositorio** dentro de la carpeta `htdocs` de XAMPP:
    ```bash
    cd C:\xampp\htdocs
    git clone https://github.com/binniebu/Seguimiento-academico.git
    ```
2.  **Configurar variables de entorno:**
    *   Renombra o edita el archivo `parameters.env` en la raíz del proyecto.
    *   Asegúrate de configurar los accesos de tu base de datos local y la variable `BASE_DIR` con la ruta relativa del proyecto en XAMPP:
    ```ini
    DB_HOST = "localhost"
    DB_USER = "root"
    DB_PSWD = ""
    DB_DATABASE = "seguimiento_academico"
    DB_PORT = 3306
    TIMEZONE = "America/Tegucigalpa"
    BASE_DIR = "Seguimiento-academico/"
    DEVELOPMENT = 1
    ```
3.  **Importar Base de Datos:**
    *   Crea una base de datos en phpMyAdmin con el nombre `seguimiento_academico`.
    *   Importa el archivo SQL de instalación estructurado que se encuentra en la ruta `database/seguimiento_academico.sql`.
4.  **Ejecutar Servidor Local:**
    *   Inicia los servicios de **Apache** y **MySQL** desde el Panel de Control de XAMPP.
    *   Accede al sistema a través de tu navegador favorito:
    ```text
    http://localhost/Seguimiento-academico/
    ```
