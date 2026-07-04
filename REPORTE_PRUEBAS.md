# Reporte de Pruebas de Software - Sistema de Seguimiento Académico

## 1. Descripción del Proyecto Asignado
El **Sistema de Seguimiento Académico** es una aplicación web diseñada para centralizar y administrar la información de una institución educativa. Utiliza una arquitectura basada en el patrón Modelo-Vista-Controlador (MVC) en PHP (con namespaces y estándar PSR-4), con almacenamiento relacional en MySQL y una interfaz estructurada con Bootstrap en el frontend. Su propósito principal es facilitar la gestión y el control de estudiantes, maestros, asignaturas, matrículas y calificaciones.

El sistema cuenta con tres tipos de usuarios diferenciados:
* **Director (Administrador):** Posee control total sobre todos los módulos (estudiantes, maestros, materias, reportes y administración de accesos).
* **Maestro:** Tiene permisos limitados para consultar materias y gestionar calificaciones.
* **Estudiante:** Acceso limitado exclusivamente para consultar sus asignaturas matriculadas y sus notas.

---

## 2. Requisitos a Evaluar

### Requisitos Funcionales (RF) del Proyecto:
* **1. Gestión de usuarios:** Registro, inicio de sesión y roles diferenciados (administrador, docente, estudiante) con autenticación segura.
* **2. Seguimiento académico:** Registro de asignaturas, calificaciones y asistencia; generación de reportes; visualización de progreso académico por estudiante.
* **3. Gestión de docentes y cursos:** Creación de cursos y asignación de docentes a materias específicas.
* **4. Notificaciones:** Alertas de bajo rendimiento académico y recordatorios de evaluaciones.
* **5. Interfaz web:** Panel de control accesible y formularios dinámicos para ingreso y consulta de datos.

### Requisitos No Funcionales (RNF) del Proyecto:
* **1. Seguridad:** Uso de cifrado en contraseñas (`password_hash`) y validación de entradas.
* **2. Usabilidad:** Interfaz intuitiva y adaptable a distintos dispositivos (responsive design).
* **3. Compatibilidad:** Ejecución en entorno XAMPP (Apache, MySQL, PHP).

---

## 3. Pruebas de Funcionalidad
A continuación se detallan las pruebas de comportamiento externo ejecutadas sobre los flujos del sistema:

### Caso de prueba: Inicio de sesión con diferentes perfiles de usuario
* **Descripción de la prueba:** Se probó el acceso al sistema utilizando las credenciales predeterminadas para los roles de Director, Maestro y Estudiante.
* **Comportamiento obtenido:** El sistema inició sesión con éxito para cada perfil, redirigiendo a los usuarios al dashboard principal (`index.php?page=home`).
* **Propuesta de mejora:** Ninguna para el flujo básico.

---

### Caso de prueba: Control de acceso según el rol (Middleware RBAC)
* **Descripción de la prueba:** Con una sesión activa de Estudiante, se intentó ingresar directamente escribiendo en la barra de direcciones del navegador la URL restringida de administración de usuarios (`index.php?page=usuarios`).
* **Comportamiento obtenido:** El middleware del servidor bloqueó el acceso con éxito, desplegó una alerta indicando *"No tiene permiso para acceder a esta sección"* y redirigió automáticamente al usuario al `home`.
* **Propuesta de mejora (Usabilidad):** Ocultar dinámicamente de la interfaz las opciones del menú que el usuario no tiene permitidas según su rol activo.

---

### Caso de prueba: Registro y gestión de Estudiantes
* **Descripción de la prueba:** Se ingresó como Director y se registró a un estudiante completando el formulario de nuevo registro.
* **Comportamiento obtenido:** El formulario procesó la petición con éxito, registrando al estudiante en la base de datos y listándolo en la interfaz.
* **Propuestas de mejora:**
  * Reemplazar el campo de texto libre para "Carrera" por un selector dropdown con buscador para evitar errores de tipeo.
  * Agregar un campo de confirmación de contraseña y un control de visibilidad (icono de ojo).
  * Cambiar la eliminación física por una eliminación lógica (campo `estado`) para proteger el historial académico histórico.

---

### Caso de prueba: Registro de calificaciones por el Maestro
* **Descripción de la prueba:** Se intentó ingresar al módulo de calificaciones con el usuario del Maestro (`juan.garcia@escuela.com`) para registrar una nota.
* **Comportamiento obtenido (Fallo Inicial):** El sistema denegaba el acceso al Maestro a la pantalla de guardar calificaciones (`page=Calificacion`), mostrando una alerta de error por falta de permisos.
* **Solución y Comportamiento Corregido:** Se detectó que el frontend solicitaba `page=Calificacion` (con mayúscula) mientras que el archivo de permisos de [RoleMiddleware.php](file:///c:/xampp/htdocs/Seguimiento-academico/src/utilities/RoleMiddleware.php) validaba en minúsculas. Se corrigió agregando `"Calificacion"` y `"Calificaciones"` al listado de permisos del rol de maestro y director. Tras la corrección, los usuarios logran registrar, editar y consultar notas exitosamente.

---

### Caso de prueba: Validación de límites en ingreso de calificaciones (Notas)
* **Descripción de la prueba:** Se intentó registrar calificaciones con valores extremos (números negativos, notas mayores a 100) y caracteres alfabéticos.
* **Comportamiento obtenido:** El campo de texto de nota bloquea el ingreso de caracteres alfabéticos a nivel de interfaz (HTML5). Si se digita una nota como `-5` o `105`, el backend en PHP impide el envío y muestra la alerta: *"La nota debe estar entre 0 y 100"*.
* **Propuestas de mejora:** Ninguna. Las validaciones de límites están bien estructuradas tanto en el cliente como en el servidor.

---

### Caso de prueba: Control de Duplicidad en el Registro de Usuarios
* **Descripción de la prueba:** Se intentó registrar un usuario nuevo con un correo electrónico que ya existe en el sistema (`ramos11@gmail.com`).
* **Comportamiento obtenido:** El sistema detectó la duplicidad en la base de datos, abortó el registro y emitió una alerta de JavaScript indicando que el correo ya está en uso.
* **Propuestas de mejora:** Mostrar la advertencia de correo duplicado directamente debajo del campo de texto como alerta HTML en lugar de una ventana emergente nativa.

---

### Caso de prueba: Inscripción y Cancelación de Materias (Flujo del Estudiante)
* **Descripción de la prueba:** Un estudiante ingresa a "Mis Materias" (`index.php?page=mis_materias`), inscribe una clase de la lista de disponibles y posteriormente la elimina.
* **Comportamiento obtenido:** El sistema realiza las inserciones y eliminaciones de matrícula de forma inmediata en la base de datos tras solicitar confirmación del estudiante en la interfaz.

---

### Caso de prueba: Visualización de Reportes Académicos Consolidados
* **Descripción de la prueba:** Se ingresó como Director al módulo de Reportes (`index.php?page=reportes`) para revisar métricas.
* **Comportamiento obtenido:** El sistema realiza las consultas consolidadas correctamente en la base de datos y muestra tablas con totales de estudiantes activos, promedios e indicadores.

---

## 4. Pruebas de Usabilidad (UX / Experiencia de Usuario)

### Caso de prueba: Adaptabilidad a dispositivos móviles (Responsive Design)
* **Comportamiento Obtenido:** Las tablas de datos son legibles gracias a que el sistema activa barras de desplazamiento horizontal. Sin embargo, en móviles el menú superior se apila toscamente en lugar de colapsarse bajo un botón de hamburguesa; la pantalla de inicio (Home) muestra márgenes en blanco excesivos en la parte inferior, y la interfaz de inicio de sesión (Login) se deforma estirándose a lo largo de toda la pantalla de forma desproporcionada.
* **Propuestas de Mejora:** Limitar el ancho máximo del login (`max-width: 450px`), implementar un menú colapsable móvil en Bootstrap, y corregir las alturas del layout del home.

---

### Caso de prueba: Consistencia en la Navegación e Indicadores de Pantalla Activa
* **Comportamiento Obtenido:** La navegación responde bien y el middleware redirige de manera segura al `home` si se intenta entrar a secciones bloqueadas. Sin embargo, la barra de navegación no resalta de ninguna manera la opción o pestaña en la que se encuentra ubicado actualmente el usuario.
* **Propuestas de Mejora:** Agregar dinámicamente la clase `.active` de Bootstrap mediante PHP condicional en el menú lateral.

---

## 5. Pruebas de Caja Negra

### Caso de prueba: Validación de límites numéricos y equivalencias en Notas
* **Comportamiento Obtenido:** Las notas válidas (`85.00`) y límites exactos (`0.00` y `100.00`) se guardaron con éxito en la base de datos, mientras que las notas fuera de límites (`-0.01` y `100.01`) y letras fueron rechazadas por HTML5 y PHP.

---

### Caso de prueba: Resistencia ante caracteres especiales (Sanitización en Login)
* **Comportamiento Obtenido:** Al intentar ingresar caracteres de inyección de código SQL (`admin' OR '1'='1`) en los campos del inicio de sesión, el sistema los trató como texto plano y denegó el acceso de forma segura sin revelar información técnica ni errores en pantalla.

---

## 6. Pruebas de Caja Blanca
Se analizó la lógica de control del middleware de seguridad en [RoleMiddleware.php](file:///c:/xampp/htdocs/Seguimiento-academico/src/utilities/RoleMiddleware.php#L7-L121) para evaluar la cobertura de caminos decisionales en la función `checkAccess()`:

* **Camino Lógico 1 (Rutas Públicas):** Acceso libre sin verificar sesión a páginas como `login` y `register`. *(Resultado: PASÓ).*
* **Camino Lógico 2 (Acceso Anónimo):** Bloqueo y redirección al login cuando no existe `$_SESSION["usuario"]`. *(Resultado: PASÓ).*
* **Camino Lógico 3 (Rol Inválido):** Redirección al login en caso de que `$_SESSION["rol"]` contenga un rol no definido en el array de permisos. *(Resultado: PASÓ).*
* **Camino Lógico 4 (Ruta Restringida):** Bloqueo, alerta visual y redirección al `home` si un rol intenta entrar a una ruta denegada (ej: Estudiante a `page=usuarios`). *(Resultado: PASÓ).*
* **Camino Lógico 5 (Acceso Exitoso):** Retorno de `true` y visualización correcta si se cumplen todos los permisos del rol. *(Resultado: PASÓ).*

---

## 7. Debilidades Detectadas

### A. Fallas de Seguridad Críticas
* **Selección de Roles Libre en el Registro Público:** El formulario de creación de usuarios permite a cualquier visitante registrarse y seleccionar libremente el rol de Maestro o de Director. Esto representa una **falla crítica de escalada de privilegios** que compromete la seguridad completa del sistema.
* **Falta de Bitácora de Cambios (Auditoría):** Las modificaciones en las calificaciones no se registran en ninguna bitácora. No hay forma de auditar qué usuario modificó una nota, cuándo lo hizo ni cuál era el valor original.

### B. Fallas de Lógica y Funcionamiento
* **Borrado Físico de Registros:** La eliminación de alumnos destruye físicamente el registro en la base de datos mediante sentencias `DELETE`, rompiendo la integridad referencial histórica.
* **Periodos Académicos Estáticos:** El periodo actual (`'2026-II'`) está programado de forma fija (hardcoded) en la consulta SQL de matrícula.

### C. Deficiencias de Experiencia de Usuario (UX/UI)
* **Menús Estáticos No Adaptativos:** Los estudiantes ven opciones administrativas de menú a las que tienen prohibido ingresar.
* **Alertas JavaScript Intrusivas:** Uso de `alert()` de JS para retroalimentación, lo cual congela la pestaña del navegador y rompe la estética de Bootstrap.

---

## 8. Análisis de Resultados e Ingeniería de Mejoras

Para la fase de reingeniería del sistema se propone implementar:
* **Estructura Multirrol:** Reemplazar el esquema de base de datos uno a uno por una tabla intermedia de asociación de roles (`usuarios_roles`) e implementar un selector de perfil (Role Switcher) en la interfaz para usuarios que actúan como docentes y estudiantes de forma simultánea.
* **Portal del Maestro Segmentado:** Cambiar la visualización de alumnos global por un sistema de carpetas/secciones donde el docente acceda de forma explícita a la materia y sección que imparte.
* **Historial Académico del Alumno:** Implementar la visualización del historial completo (Certificación de Estudios) que calcule automáticamente el índice del periodo y el índice acumulado ponderado global, junto a un desglose detallado de las calificaciones por parciales en curso.
* **Periodo Académico Dinámico y Matrícula Lógica:** Crear un panel administrativo donde el Director configure fechas de inicio y cierre de matrícula. El sistema determinará automáticamente en qué periodo (1PAC, 2PAC, 3PAC) y año se encuentra en curso. Asimismo, la cancelación de materias ejecutará un borrado lógico (cambio de estado de matrícula).
* **Segregación de Roles:** Retirar la capacidad de alteración de notas al usuario Director/Administrador, delegando esta función de manera exclusiva a los docentes de cada materia.

---

## 9. Conclusiones
* **Calidad de Software:** Las pruebas demostraron la necesidad crítica de realizar validaciones exhaustivas antes de pasar a producción, evidenciada por el fallo de mayúsculas que bloqueaba el módulo de calificaciones.
* **Robustez del Backend:** A pesar de los problemas visuales de la interfaz, el middleware RBAC bloquea de forma segura a nivel de servidor cualquier intrusión por URL.
* **Necesidad de Reingeniería:** Un software funcional requiere de validaciones y controles lógicos mucho más estrictos (como prerrequisitos de asignaturas e inmutabilidad de datos históricos) para operar formalmente en un entorno institucional.
