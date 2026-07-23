# Diccionario de Datos: Sistema de Seguimiento Académico

Este documento detalla el esquema relacional de la base de datos `seguimiento_academico`. Describe cada tabla, sus columnas, tipos de datos, llaves primarias/foráneas y el propósito de cada campo dentro de la lógica del negocio.

---

## Esquema General de Relaciones

El sistema utiliza una arquitectura basada en **Control de Acceso Basado en Roles (RBAC)** y una estructura académica jerárquica:
* **Entidades Organizacionales:** `campus` (Sedes) y `facultades`.
* **Entidades Académicas:** `carreras`, `materias` (Asignaturas), `periodos_academicos` y `secciones` (Clases).
* **Usuarios y Perfiles:** `usuarios` centralizado, especializándose en perfiles individuales mediante `estudiantes`, `maestros` y `coordinadores`.
* **Procesos Clave:** `matriculas` (Inscripción del alumno a una sección) y `calificaciones` (Evaluación de notas parciales y promedio).

---

## Catálogo de Tablas

### 1. `roles`
Almacena los roles de seguridad permitidos en el sistema (Director, Coordinador, Maestro, Estudiante).
* **Motor:** InnoDB | **Collate:** utf8mb4_unicode_ci

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_rol` | INT | NO | PRI | *Autoincrement* | Identificador único del rol. |
| `nombre_rol` | VARCHAR(50) | NO | UNI | NULL | Nombre descriptivo del rol (ej. 'director', 'maestro', 'estudiante', 'coordinador'). |

---

### 2. `usuarios`
Entidad principal que almacena las credenciales de acceso e información personal de todas las personas con acceso al sistema.
* **Motor:** InnoDB | **Collate:** utf8mb4_unicode_ci

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_usuario` | INT | NO | PRI | *Autoincrement* | Identificador único del usuario. |
| `nombre` | VARCHAR(100) | NO | | NULL | Nombre completo del usuario. |
| `correo` | VARCHAR(100) | NO | UNI | NULL | Correo electrónico institucional (usado para Login). |
| `password` | VARCHAR(255) | NO | | NULL | Hash de la contraseña del usuario (encriptado con bcrypt). |
| `id_rol` | INT | NO | MUL | NULL | Identificador del rol principal (FK a `roles.id_rol`). |
| `estado` | VARCHAR(20) | YES | | 'activo' | Estado de la cuenta ('activo', 'pendiente' [aspirantes], 'inactivo'). |
| `titulo` | VARCHAR(150) | YES | | NULL | Grado académico / Título profesional (para maestros/coordinadores). |
| `documento_dni` | VARCHAR(255) | YES | | NULL | Ruta local del archivo PDF/Imagen del DNI subido en el registro. |
| `documento_titulo` | VARCHAR(255) | YES | | NULL | Ruta local del archivo PDF/Imagen del título subido en el registro. |
| `fecha_creacion`| TIMESTAMP | NO | | CURRENT_TIMESTAMP | Fecha/hora en que fue creado el registro (usado para calcular el periodo de ingreso). |

---

### 3. `usuarios_roles`
Tabla intermedia para soportar la asignación de múltiples roles a un mismo usuario.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_usuario` | INT | NO | PRI, FK | NULL | Identificador del usuario (FK a `usuarios.id_usuario`). |
| `id_rol` | INT | NO | PRI, FK | NULL | Identificador del rol asignado (FK a `roles.id_rol`). |

---

### 4. `facultades`
Almacena las divisiones académicas mayores de la universidad.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_facultad` | INT | NO | PRI | *Autoincrement* | Identificador único de la facultad. |
| `nombre_facultad`| VARCHAR(100)| NO | UNI | NULL | Nombre de la facultad (ej. 'Facultad de Ingeniería'). |

---

### 5. `campus`
Almacena las sedes o centros regionales de la universidad distribuidos en el país.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_campus` | INT | NO | PRI | *Autoincrement* | Identificador único de la sede. |
| `nombre_campus` | VARCHAR(100) | NO | UNI | NULL | Nombre descriptivo del campus (ej. 'Campus Central - Tegucigalpa'). |
| `departamento` | VARCHAR(100) | NO | | NULL | Departamento geográfico del país donde está la sede. |
| `estado` | VARCHAR(20) | YES | | 'activo' | Estado operativo del campus ('activo', 'inactivo'). |

---

### 6. `carreras`
Catálogo de los programas de grado de la institución, asociados a una facultad específica.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_carrera` | INT | NO | PRI | *Autoincrement* | Identificador único de la carrera. |
| `nombre_carrera`| VARCHAR(100)| NO | UNI | NULL | Nombre de la carrera (ej. 'Ingeniería en Sistemas'). |
| `id_facultad` | INT | NO | MUL, FK | NULL | Facultad a la que pertenece la carrera (FK a `facultades.id_facultad`). |
| `estado` | VARCHAR(20) | YES | | 'activo' | Estado operativo de la carrera ('activo', 'inactivo'). |

---

### 7. `estudiantes`
Almacena el perfil del estudiante, asociando su cuenta y carrera a un usuario general y sede física.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_estudiante` | INT | NO | PRI | *Autoincrement* | Identificador único de la ficha de estudiante. |
| `id_usuario` | INT | NO | MUL, FK | NULL | Referencia al usuario de login (FK a `usuarios.id_usuario`). |
| `cuenta` | VARCHAR(20) | NO | UNI | NULL | Número de Cuenta / DNI oficial del estudiante. |
| `carrera` | VARCHAR(100) | NO | | NULL | Nombre descriptivo de la carrera que cursa. |
| `telefono` | VARCHAR(20) | YES | | NULL | Número de teléfono del estudiante. |
| `estado` | VARCHAR(20) | YES | | 'Admitido' | Estado académico ('Admitido', 'activo', 'inactivo', 'graduado'). |
| `id_campus` | INT | YES | MUL, FK | NULL | Sede física/campus al que asiste (FK a `campus.id_campus`). |

---

### 8. `maestros`
Almacena la información laboral de los docentes vinculados a una sede de la institución.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_maestro` | INT | NO | PRI | *Autoincrement* | Identificador único del docente. |
| `id_usuario` | INT | NO | MUL, FK | NULL | Referencia al usuario de login (FK a `usuarios.id_usuario`). |
| `numero_empleado`| VARCHAR(20) | NO | UNI | NULL | Código de identificación laboral interno del maestro. |
| `telefono` | VARCHAR(20) | YES | | NULL | Teléfono de contacto. |
| `id_campus` | INT | YES | MUL, FK | NULL | Campus al que está adscrito el docente (FK a `campus.id_campus`). |

---

### 9. `coordinadores`
Almacena la asignación de coordinadores de carrera/facultad en una sede física de la universidad.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_coordinador`| INT | NO | PRI | *Autoincrement* | Identificador único del registro de coordinación. |
| `id_usuario` | INT | NO | UNI, FK | NULL | Referencia al usuario del coordinador (FK a `usuarios.id_usuario`). |
| `id_facultad` | INT | NO | MUL, FK | NULL | Facultad que administra (FK a `facultades.id_facultad`). |
| `id_campus` | INT | YES | MUL, FK | NULL | Campus en el cual opera su coordinación (FK a `campus.id_campus`). |

---

### 10. `periodos_academicos`
Almacena los ciclos temporales de clases de la universidad.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_periodo` | INT | NO | PRI | *Autoincrement* | Identificador único del periodo académico. |
| `nombre_periodo`| VARCHAR(50) | NO | UNI | NULL | Nombre descriptivo del periodo (ej. 'Periodo I - 2024'). |
| `fecha_inicio` | DATE | NO | | NULL | Fecha de inicio del ciclo escolar. |
| `fecha_fin` | DATE | NO | | NULL | Fecha de finalización del ciclo escolar. |
| `estado` | VARCHAR(20) | YES | | 'activo' | Estado operativo del periodo ('activo', 'inactivo'). |

---

### 11. `materias`
Catálogo general de asignaturas de la universidad, con créditos y reglas de prerrequisito.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_materia` | INT | NO | PRI | *Autoincrement* | Identificador único de la materia. |
| `codigo` | VARCHAR(20) | NO | UNI | NULL | Código académico de la materia (ej. 'MAT101', 'FIS102'). |
| `nombre` | VARCHAR(100) | NO | | NULL | Nombre descriptivo de la materia. |
| `descripcion` | TEXT | YES | | NULL | Descripción detallada de los objetivos de la materia. |
| `creditos` | INT | YES | | 3 | Unidades Valorativas (UV) o créditos de la asignatura. |
| `periodo` | INT | YES | | 1 | Número de cuatrimestre recomendado en el flujograma. |
| `tipo_materia` | VARCHAR(30) | YES | | 'institucional'| Tipo de materia ('institucional' [común], 'facultad' o 'carrera'). |
| `id_facultad` | INT | YES | MUL, FK | NULL | Facultad que la imparte (FK a `facultades.id_facultad`). |
| `id_carrera` | INT | YES | MUL, FK | NULL | Carrera a la que pertenece (FK a `carreras.id_carrera`). |
| `id_requisito` | INT | YES | MUL, FK | NULL | Prerrequisito: materia que debe aprobarse antes (FK a `materias.id_materia`). |
| `estado` | VARCHAR(20) | YES | | 'activa' | Estado ('activa', 'inactiva'). |

---

### 12. `secciones`
Representa los horarios, aulas y maestros asignados a una asignatura en un período escolar específico.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_seccion` | INT | NO | PRI | *Autoincrement* | Identificador único de la sección. |
| `codigo_seccion`| VARCHAR(20) | NO | UNI | NULL | Código único de sección (ej. '0700-ING-2026'). |
| `id_materia` | INT | NO | MUL, FK | NULL | Asignatura vinculada (FK a `materias.id_materia`). |
| `id_maestro` | INT | NO | MUL, FK | NULL | Maestro asignado (FK a `maestros.id_maestro`). |
| `id_periodo` | INT | NO | MUL, FK | NULL | Ciclo académico en que se dicta (FK a `periodos_academicos.id_periodo`). |
| `aula` | VARCHAR(50) | NO | | NULL | Código de aula física asignada. |
| `dias` | VARCHAR(50) | NO | | NULL | Días que se imparte la clase (ej. 'Lu-Mi', 'Ma-Ju', 'Vi'). |
| `hora_inicio` | TIME | NO | | NULL | Hora de inicio de la clase. |
| `hora_fin` | TIME | NO | | NULL | Hora de finalización de la clase. |
| `cupo_maximo` | INT | YES | | 30 | Cantidad máxima de estudiantes admitidos en la sección. |
| `estado` | VARCHAR(20) | YES | | 'Borrador' | Estado de la sección ('Borrador', 'Activa', 'Cerrada'). |

---

### 13. `matriculas`
Registra la inscripción de un estudiante a una sección de clase en un determinado período.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_matricula` | INT | NO | PRI | *Autoincrement* | Identificador único de la matrícula. |
| `id_estudiante` | INT | NO | MUL, FK | NULL | Estudiante matriculado (FK a `estudiantes.id_estudiante`). |
| `id_seccion` | INT | NO | MUL, FK | NULL | Sección en la que se inscribe (FK a `secciones.id_seccion`). |
| `id_periodo` | INT | NO | MUL, FK | NULL | Período académico en curso (FK a `periodos_academicos.id_periodo`). |
| `fecha_matricula`| TIMESTAMP| YES | | CURRENT_TIMESTAMP| Fecha y hora en que se oficializó la matrícula. |

*Nota:* Posee un índice único compuesto `estudiante_seccion (id_estudiante, id_seccion)` para evitar que un alumno se matricule dos veces en la misma sección.

---

### 14. `calificaciones`
Almacena el registro de calificaciones finales e históricas del estudiante asociadas a su matrícula.
* **Motor:** InnoDB

| Columna | Tipo de Datos | Nulo | Llave | Predeterminado | Descripción |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `id_calificacion`| INT | NO | PRI | *Autoincrement* | Identificador único del registro de calificación. |
| `id_matricula` | INT | NO | UNI, FK | NULL | Referencia de la matrícula (FK a `matriculas.id_matricula`). |
| `nota` | DECIMAL(5,2)| NO | | NULL | Nota Final o Promedio acumulado de la asignatura (0.00% a 100.00%). |
| `observacion` | VARCHAR(150)| YES | | NULL | Observación adicional del registro de nota. |
| `nota_parcial1`| DECIMAL(5,2)| YES | | NULL | Calificación acumulada obtenida en el Primer Parcial. |
| `nota_parcial2`| DECIMAL(5,2)| YES | | NULL | Calificación acumulada obtenida en el Segundo Parcial. |
| `nota_parcial3`| DECIMAL(5,2)| YES | | NULL | Calificación acumulada obtenida en el Tercer Parcial. |
| `fecha_registro`| TIMESTAMP | YES | | CURRENT_TIMESTAMP| Fecha de guardado o actualización de la nota. |
