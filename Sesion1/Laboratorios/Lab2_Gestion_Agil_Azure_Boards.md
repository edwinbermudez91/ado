# 🧪 Laboratorio 2: Gestión Ágil con Azure Boards

Este laboratorio práctico guía al participante en el uso de **Azure Boards** para la gestión ágil de proyectos. Aprenderemos a poblar de forma rápida un backlog completo importando un archivo CSV preconfigurado, entenderemos la jerarquía de requerimientos y personalizaremos tableros Kanban, Sprints y paneles de métricas en **Proyecto-Piloto**.

---

## 🎯 Objetivos del Laboratorio
1.  Poblar el backlog del proyecto `Proyecto-Piloto` importando un archivo CSV jerárquico.
2.  Comprender la jerarquía de requerimientos ágiles bajo buenas prácticas (Épicas, Características, Historias de Usuario con Criterios de Aceptación, Tareas y Bugs).
3.  Personalizar el tablero Kanban (columnas, límites WIP, Swimlanes y estilos de tarjetas).
4.  Realizar la planificación y seguimiento de un Sprint (capacidad y Taskboard).
5.  Crear consultas (*Queries*) y gráficos de seguimiento ágil.

---

## ⏳ Tiempo Estimado: 60 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Importar el Backlog mediante Archivo CSV (Importación Directa)
Para simular un entorno ágil completo y apegado a la realidad del cliente, importaremos una jerarquía estructurada de requerimientos desde un archivo plano:

1.  Ubique el archivo [**`import-work-items.csv`**](import-work-items.csv) en la carpeta de este laboratorio (`Sesion1/Laboratorios/`).
2.  Ingrese a su organización de Azure DevOps y abra su proyecto **`Proyecto-Piloto`**.
3.  En el menú izquierdo, navegue a **Boards > Queries** (Consultas).
4.  En la esquina superior derecha, haga clic en el botón **Import Work Items** (Importar elementos de trabajo).
5.  Haga clic en **Choose File** (Elegir archivo) y seleccione el archivo `import-work-items.csv` que se encuentra localmente en su máquina.
6.  Haga clic en **Import**. Verá que se cargan en pantalla de forma inmediata los elementos de trabajo en una estructura de árbol (jerarquía).
7.  Haga clic en el botón **Save Items** (Guardar elementos) en la esquina superior izquierda del panel para persistir las tarjetas en la base de datos de su proyecto. ¡Listo! Su backlog está poblado.

---

### Paso 2: Entendiendo los Elementos de Trabajo (Work Items) y Buenas Prácticas
Vaya a **Boards > Work Items** en el menú izquierdo de `Proyecto-Piloto` y abra algunas de las tarjetas importadas. El backlog importado modela una estructura empresarial de 3 niveles de Épicas con sus derivados, siguiendo las mejores prácticas de ingeniería de requerimientos:

```
┌────────────────────────────────────────────────────────┐
│                        Epic                            │  Iniciativa de Negocio (Gran Escala)
└───────────┬────────────────────────────────────────────┘
            ▼
┌────────────────────────────────────────────────────────┐
│                      Feature                           │  Funcionalidad Entregable del Sistema
└───────────┬────────────────────────────────────────────┘
            ▼
┌────────────────────────────────────────────────────────┐
│                     User Story                         │  Requisito de Usuario (Valor de Negocio)
└───────────┬────────────────────────────────────────────┘
            ▼
┌────────────────────────────────────────────────────────┐
│               Task (Tarea) / Bug (Error)               │  Actividades Técnicas / Correcciones
└────────────────────────────────────────────────────────┘
```

#### Estructura del Backlog Importado:

##### 1. Épica 1: Migración e Integración de Nube Híbrida
Iniciativa global para conectar e integrar repositorios locales con Azure DevOps de manera segura.
*   **Feature 1.1: Agentes de Compilación Auto-Hospedados**
    *   **User Story 1.1.1: Registro Automatizado de GitLab Runner en VM local** (Infraestructura)
        *   *Formato Estándar (User Story)*: *"Como administrador de plataforma, quiero registrar el Runner de forma no interactiva para automatizar el aprovisionamiento de máquinas."*
        *   *Criterios de Aceptación*:
            1. El script debe ejecutarse de forma no interactiva (unattended).
            2. El Runner registrado debe figurar activo y verde en GitLab.
            3. El token de registro debe pasarse de forma segura sin exponerse en texto plano.
        *   **Task 1.1.1.1**: Descargar e instalar binarios del Runner.
        *   **Task 1.1.1.2**: Escribir script de registro desatendido.
        *   **Task 1.1.1.3**: Validar comunicación SSL inicial.
    *   **User Story 1.1.2: Inyección de Certificado CA Corporativo** (Seguridad)
        *   *Formato Estándar (User Story)*: *"Como ingeniero de seguridad de red, quiero instalar los certificados raíz autofirmados de la organización en los Runners para establecer conexiones HTTPS seguras y evitar alertas de certificados no confiables."*
        *   *Criterios de Aceptación*:
            1. Comunicación sin errores de tipo 'x509: certificate signed by unknown authority' en ejecuciones del Runner.
            2. Los certificados de la CA interna deben ser configurados en el archivo config.toml.
        *   **Task 1.1.2.1**: Copiar certificado CA en la ruta de certs.
        *   **Task 1.1.2.2**: Configurar la variable ca_file en config.toml.
    *   **Bug 1.1.3: Error de certificado x509 desconocido durante el registro**: Reporte de fallo TLS al registrar el agente local.
*   **Feature 1.2: Conectividad y Redes Híbridas Seguras**
    *   **User Story 1.2.1: Configuración de Proxy Corporativo en Agentes** (Redes)
        *   *Formato Estándar (User Story)*: *"Como administrador de infraestructura, quiero configurar las variables de entorno de proxy (HTTP_PROXY, HTTPS_PROXY, NO_PROXY) en el servicio de GitLab Runner para permitir descargas de dependencias externas a través del proxy corporativo sin comprometer la seguridad."*
        *   *Criterios de Aceptación*:
            1. Las variables de proxy deben estar declaradas en la configuración del servicio del Runner.
            2. El Runner debe poder descargar paquetes públicos a través del proxy.
            3. El tráfico hacia servidores locales de GitLab debe omitir el proxy.
        *   **Task 1.2.1.1**: Configurar variables en /etc/default/gitlab-runner.
        *   **Task 1.2.1.2**: Validar exclusión de proxy para GitLab local.

##### 2. Épica 2: Automatización de Pipelines y Ciclo de Vida CI/CD
Diseño de workflows y optimización de pipelines multi-etapa en YAML.
*   **Feature 2.1: Pipelines como Código y Calidad**
    *   **User Story 2.1.1: Pipeline Multietapa para Node.js** (Automatización)
        *   *Formato Estándar (User Story)*: *"Como desarrollador de software, quiero un pipeline de CI automático que compile el código y ejecute pruebas unitarias ante cada commit para detectar errores de forma temprana en la rama principal."*
        *   *Criterios de Aceptación*:
            1. Ejecución automática en commits a main y Pull Requests.
            2. Publicación de reportes de pruebas en Azure Pipelines.
        *   **Task 2.1.1.1**: Crear archivo azure-pipelines.yml.
        *   **Task 2.1.1.2**: Configurar tareas NodeTool y comandos npm.
    *   **User Story 2.1.2: Gestión de Paquetes en Feeds Privados de Azure Artifacts** (Gestión de Dependencias)
        *   *Formato Estándar (User Story)*: *"Como arquitecto de software, quiero publicar librerías comunes compiladas en un Feed privado para controlar versiones y consumirlas de manera segura dentro de la organización."*
        *   *Criterios de Aceptación*:
            1. Publicación exitosa de paquetes NPM usando tokens de autenticación del pipeline.
            2. Control de accesos restringido para que solo desarrolladores autenticados puedan consumir del feed.
        *   **Task 2.1.2.1**: Crear feed coem-packages en Azure Artifacts.
        *   **Task 2.1.2.2**: Configurar archivo .npmrc en el repositorio.
*   **Feature 2.2: Aseguramiento de Calidad y Escaneo de Vulnerabilidades**
    *   **User Story 2.2.1: Integración de Escaneo de Seguridad de Dependencias (SCA)** (Seguridad en Código)
        *   *Formato Estándar (User Story)*: *"Como oficial de seguridad, quiero integrar una herramienta de análisis de dependencias (como npm audit) en el pipeline de CI para bloquear compilaciones que incluyan librerías con vulnerabilidades críticas."*
        *   *Criterios de Aceptación*:
            1. El pipeline debe fallar si se detectan vulnerabilidades de severidad 'Critical' o 'High' en dependencias directas.
            2. Debe publicarse un reporte como artefacto de compilación.
        *   **Task 2.2.1.1**: Agregar paso de npm audit en el pipeline.

##### 3. Épica 3: Gobierno, Seguridad y Aislamiento de Entornos
Estándares de seguridad para despliegues a entornos productivos y control de accesos.
*   **Feature 3.1: Control de Accesos y Aprobaciones Manuales**
    *   **User Story 3.1.1: Compuertas de Aprobación Manual para Despliegues a Producción** (Gobierno)
        *   *Formato Estándar (User Story)*: *"Como jefe de lanzamientos, quiero que los despliegues a Producción se pausen requiriendo autorización manual explícita para mitigar riesgos operativos."*
        *   *Criterios de Aceptación*:
            1. Pausa obligatoria del stage de despliegue a producción.
            2. Notificación automática por correo a los miembros del grupo Aprobadores-Produccion.
            3. Comentario justificativo obligatorio al aprobar.
        *   **Task 3.1.1.1**: Configurar Prod-Environment con aprobador.
    *   **User Story 3.1.2: Aislamiento de Permisos en Service Connections** (Seguridad en Conexiones)
        *   *Formato Estándar (User Story)*: *"Como oficial de seguridad, quiero limitar el uso de la Service Connection de Producción al grupo de Líderes Técnicos para evitar despliegues no autorizados desde ramas de desarrollo."*
        *   *Criterios de Aceptación*:
            1. Desarrolladores externos con rol Reader sobre la conexión.
            2. Solo pipelines oficiales corriendo en ramas protegidas (como main) pueden hacer uso de esta Service Connection.
        *   **Task 3.1.2.1**: Configurar seguridad de la Service Connection.
    *   **Bug 3.1.3: Fuga de credenciales en logs de ejecución del pipeline**: Reporte de contraseñas expuestas en salida estándar de pipelines.
        *   **Task 3.1.3.1**: Enmascarar variables secretas en logs.
*   **Feature 3.2: Políticas de Rama y Cumplimiento Normativo**
    *   **User Story 3.2.1: Políticas de Rama (Branch Policies) en main** (Gobierno de Código)
        *   *Formato Estándar (User Story)*: *"Como líder de desarrollo, quiero exigir que todas las integraciones a la rama main se realicen mediante Pull Requests con al menos una aprobación y compilación exitosa para mantener la estabilidad del código."*
        *   *Criterios de Aceptación*:
            1. Bloqueo de empuje directo (push) a main.
            2. Exigir revisión por pares.
            3. Compilación de validación de CI obligatoria.
        *   **Task 3.2.1.1**: Configurar Branch Policies para la rama main.

---

### Paso 3: Parametrización y Configuración del Tablero Kanban
Vaya a **Boards > Boards** para ver el flujo Kanban visual de las Historias de Usuario.

#### 1. Personalizar Columnas y Límites WIP (Work in Progress)
1.  Haga clic en el icono de engranaje ⚙️ (Configuración del Tablero) en la esquina superior derecha.
2.  Seleccione **Columns** en la barra lateral izquierda del menú de configuración.
3.  Añadiremos un nuevo estado intermedio:
    *   Haga clic en **+ Column**.
    *   **Column name**: `In Review` (En Revisión).
    *   **State**: Seleccione `Active` (esto mapea la columna al estado activo de flujo de trabajo).
    *   **WIP limit**: Escriba `3` (límite de historias simultáneas que pueden estar en revisión para evitar cuellos de botella).
4.  Arrastre la columna `In Review` para posicionarla entre `Doing` y `Done`.
5.  Haga clic en **Save** en la parte inferior derecha.

#### 2. Configurar Swimlanes (Líneas de Servicio de Alta Prioridad)
Los Swimlanes dividen horizontalmente el tablero para canalizar flujos de trabajo específicos (ej: tareas de emergencia o bugs críticos).
1.  Abra nuevamente la configuración ⚙️ y seleccione **Swimlanes**.
2.  Haga clic en **+ Add swimlane**.
3.  **Name**: `Expedite` (Urgente).
4.  Haga clic en **Save**.
5.  Verá una nueva división horizontal en la parte superior de su tablero. Pruebe arrastrando una tarjeta a la pista `Expedite` para priorizarla.

#### 3. Estilos de Tarjetas (Card Styling) y Reglas de Color
Haremos que las tarjetas de alta prioridad se pinten de color rojo de forma automática:
1.  Abra la configuración ⚙️ y seleccione **Styles**.
2.  Haga clic en **+ Add style rule**.
3.  **Name**: `Alta Prioridad`.
4.  **Card color**: Seleccione un color rojo suave.
5.  Defina la regla en la sección **Rule criteria**:
    *   **Field**: `Priority`
    *   **Operator**: `=`
    *   **Value**: `1`
6.  Haga clic en **Save**. Cualquier elemento que tenga prioridad 1 cambiará de color automáticamente en el tablero.

---

### Paso 4: Planificación de Sprints y Gestión de Capacidad
En Azure Boards, los Sprints definen iteraciones de tiempo fijas (típicamente de 2 a 3 semanas) donde el equipo se compromete a entregar un conjunto de elementos de trabajo. Por defecto en proyectos nuevos, estas iteraciones se nombran como **`Iteration 1`**, **`Iteration 2`**, etc.

> [!IMPORTANT]
> **Comportamiento Crítico en Azure DevOps:**
> Al cambiar la iteración (*Iteration Path*) de una Historia de Usuario (User Story) para enviarla a un sprint (ej: `Iteration 1`), **sus tareas hijas (Tasks) no heredan este cambio de forma automática** y permanecen en el Backlog general (iteración raíz).
> Para que las tareas e historias aparezcan de forma correcta en el **Taskboard** (Tablero de Sprints), **tanto la Historia de Usuario como sus Tareas individuales deben estar asignadas explícitamente a la misma iteración (`Iteration 1`)**.

#### 1. Asignar Historias de Usuario y Tareas al Sprint (Bulk Edit)
Para asignar tanto las historias de usuario como todas sus tareas derivadas a la iteración activa de forma simultánea:
1.  En el menú izquierdo, navegue a **Boards > Backlogs** para abrir el backlog general de su proyecto `Proyecto-Piloto`.
2.  Asegúrese de estar en la vista de **Backlog items** (Historias de Usuario).
3.  En la esquina superior derecha, haga clic en el icono de engranaje de opciones de visualización (o el menú **View options**) y asegúrese de que:
    *   **Parents** (Padres) esté configurado en **On** (para poder ver la estructura jerárquica).
    *   Haga clic en el botón de vista lateral **Planning** (Planificación) para abrir el panel derecho donde se listan las iteraciones (`Iteration 1`, `Iteration 2`, etc.).
4.  Expanda los elementos en el backlog principal haciendo clic en la flecha de expansión junto a la Historia de Usuario `User Story 1.1.1` para ver sus tareas hijas (`Task 1.1.1.1`, `Task 1.1.1.2`, etc.).
5.  Seleccione los siguientes elementos simultáneamente manteniendo presionada la tecla **`Ctrl`** (o **`Cmd`** en macOS) y haciendo clic sobre cada uno:
    *   `User Story 1.1.1: Registro Automatizado de GitLab Runner en VM local`
    *   `Task 1.1.1.1: Descargar e instalar binarios del Runner`
    *   `Task 1.1.1.2: Escribir script de registro desatendido`
    *   `Task 1.1.1.3: Validar comunicación SSL inicial`
6.  Una vez seleccionados, arrástrelos todos juntos y suéltelos sobre el contenedor **`Iteration 1`** en el panel de planificación lateral a la derecha.
7.  *(Método Alternativo)*: También puede hacer clic en los tres puntos (`...`) junto a cualquier elemento seleccionado, hacer clic en **Edit** (o **Move to Iteration**), seleccionar la ruta de iteración **`Proyecto-Piloto\Iteration 1`** y hacer clic en guardar. Repita este proceso de asignación para la `User Story 1.1.2` con sus tareas y el Bug `Bug 1.1.3`.

#### 2. Configurar la Capacidad del Equipo (Capacity Planning)
La planificación de capacidad permite medir si el compromiso del equipo es realista según las horas de trabajo disponibles de sus integrantes.
1.  Navegue a **Boards > Sprints** en el menú izquierdo.
2.  Asegúrese de estar situado en la iteración correspondiente (en la esquina superior derecha debe estar seleccionado **`Iteration 1`**).
3.  Haga clic en la pestaña **Capacity** (Capacidad) en la parte superior derecha.
4.  Localice su usuario en la lista de miembros y asigne los siguientes valores:
    *   **Activity**: Seleccione `Development` (Desarrollo).
    *   **Capacity per day**: Defina `6` (representa 6 horas productivas de trabajo por día laboral).
    *   **Days off**: (Opcional) Permite definir días libres o festivos durante el sprint.
5.  Haga clic en el botón **Save** (Guardar) en la barra de menú superior de la capacidad.

#### 3. Estimar Tareas y Asignar Responsables en el Taskboard
Con los elementos asignados correctamente a la iteración, las tareas ahora se mostrarán en su tablero:
1.  Haga clic en la pestaña **Taskboard** (Tablero de Tareas) en la parte superior.
2.  Ahora verá las Historias de Usuario (ej. `User Story 1.1.1` y `User Story 1.1.2`) listadas horizontalmente como filas, y sus tareas hijas vinculadas aparecerán como tarjetas independientes en la columna **To Do**.
3.  Haga clic en el título de la tarjeta de la tarea **`Task 1.1.1.1: Descargar e instalar binarios del Runner`** para abrirla:
    *   **Assigned To**: Asígnela a su propio usuario (ej: `Edwin Harley Bermudez Cuervo`).
    *   **Remaining Work** (Trabajo Restante): Ingrese `8` (representa 8 horas de esfuerzo estimado).
    *   Haga clic en **Save & Close**.
4.  Abra la tarjeta **`Task 1.1.1.2: Escribir script de registro desatendido`**:
    *   **Assigned To**: Seleccione su propio usuario.
    *   **Remaining Work**: Ingrese `12` (12 horas de esfuerzo estimado).
    *   Haga clic en **Save & Close**.

#### 4. Validar el Gráfico de Carga de Capacidad (Work Details)
1.  Haga clic en la pestaña **Backlog** (dentro de la vista de Sprints).
2.  En la esquina superior derecha, haga clic en el icono de vista de panel lateral y seleccione **Work details** (Detalles del trabajo) para abrir el panel lateral de capacidad.
3.  Observe los gráficos de barra en tiempo real:
    *   **Barra del Equipo (Team)**: Muestra el total de horas estimadas en las tareas frente a la capacidad total disponible de todo el equipo en el sprint.
    *   **Barra Individual (Por Persona)**: Mostrará cuántas horas tiene asignadas de su capacidad total disponible (ej. `20 de 60 horas asignadas` en color verde).
    *   **Simulación de Sobrecarga**: Si incrementa las horas de trabajo restante de sus tareas por encima de la capacidad máxima de días útiles del sprint, la barra se tornará automáticamente de color **rojo**, alertando visualmente de una sobrecarga de trabajo.

#### 5. Uso del Taskboard en las Daily Standups
1.  Durante la reunión diaria de sincronización (Daily), los miembros del equipo acceden a la pestaña **Taskboard**.
2.  Con una interacción simple de arrastrar y soltar (Drag & Drop), mueva la tarjeta de la tarea **`Task 1.1.1.1`** de `To Do` a `In Progress` y finalmente a `Done` para reflejar el progreso en tiempo real.

---

### Paso 5: Consultas (Queries) y Dashboards
Para monitorear el proyecto de manera estratégica:

#### 1. Crear una Consulta de Bugs Activos
1.  En el menú izquierdo, vaya a **Boards > Queries**.
2.  Haga clic en **New query** (Nueva consulta).
3.  Configure las cláusulas de la consulta:
    *   `Work Item Type` `=` `Bug`
    *   `And` `State` `=` `Active`
4.  Haga clic en **Run query** (Ejecutar consulta) para comprobar los resultados.
5.  Haga clic en **Save query** (Guardar consulta):
    *   **Name**: `Bugs Activos del Proyecto`
    *   **Folder**: Seleccione **Shared Queries** (para que otros miembros del equipo puedan verla).
6.  Haga clic en **OK**.

#### 2. Crear un Gráfico en el Dashboard
1.  Estando en su consulta guardada, haga clic en la pestaña **Charts** (Gráficos) en la parte superior.
2.  Haga clic en **New chart**.
3.  Configure un gráfico de tipo **Pie** (Pastel) agrupado por **Assigned To** para ver quién tiene más bugs asignados.
4.  Haga clic en **OK**.
5.  Haga clic en los tres puntos (`...`) del gráfico y seleccione **Add to dashboard** para enviarlo a la pantalla de inicio del proyecto.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Aprovisionamiento del Backlog** | Validar que el backlog del proyecto `Proyecto-Piloto` fue importado correctamente con 3 Épicas y sus derivados. |
| 🔲 | **Columna Kanban & WIP** | Comprobar que la columna `In Review` fue insertada con un límite WIP máximo de **3**. |
| 🔲 | **Swimlane de Emergencias** | Verificar la existencia de la pista horizontal `Expedite` arriba del flujo Kanban. |
| 🔲 | **Planificación y Capacidad** | Definir horas de capacidad diarias del desarrollador y validar el estado visual en el panel *Backlog*. |
| 🔲 | **Consulta Guardada** | Asegurar que la query `Bugs Activos del Proyecto` se guardó correctamente en *Shared Queries*. |

Proceda al [**Lab 3**](Lab3_Parametrizacion_Usuarios_Roles.md) para configurar usuarios, permisos y seguridad de entornos.
