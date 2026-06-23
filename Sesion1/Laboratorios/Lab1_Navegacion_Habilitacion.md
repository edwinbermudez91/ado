# 🧪 Laboratorio 1: Habilitación de Organización y Navegación Inicial

Este laboratorio práctico guía al participante en la creación de una organización en **Azure DevOps Services**, la inicialización de un proyecto privado y la navegación básica para administrar la plataforma.

---

## 🎯 Objetivos del Laboratorio
1.  Crear una organización gratuita en Azure DevOps Services.
2.  Crear y parametrizar un proyecto privado llamado `Proyecto-Piloto`.
3.  Comprender la diferencia entre **Organization Settings** y **Project Settings**.
4.  Habilitar y deshabilitar servicios del proyecto según las necesidades de la organización.

---

## ⏳ Tiempo Estimado: 45 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Creación de la Organización de Azure DevOps
1.  Abra su navegador web y navegue a [https://dev.azure.com](https://dev.azure.com).
2.  Haga clic en **Start free** (Iniciar gratis).
3.  Inicie sesión con su cuenta Microsoft corporativa o personal (ej. `@outlook.com`, `@hotmail.com` o su cuenta federada de Entra ID).
4.  Si es la primera vez que ingresa, se le presentará una pantalla de bienvenida:
    *   Seleccione su **País/Región**.
    *   Confirme o modifique la **Región de Hospedaje** (se recomienda elegir la más cercana a su ubicación geográfica, por ejemplo, *East US 2* o *South Central US* para latencias óptimas).
5.  Introduzca un nombre único para su organización (ejemplo: `coem-capacitacion-tunombre`) y complete el código de verificación (Captcha) si se le solicita.
6.  Haga clic en **Continue**. El sistema tardará unos segundos en aprovisionar su nueva organización.

---

### Paso 2: Creación del Primer Proyecto Privado (`Proyecto-Piloto`)
Una vez aprovisionada la organización, se le redirigirá automáticamente a la pantalla de creación de proyectos.

1.  En el campo **Project name**, escriba: `Proyecto-Piloto`.
2.  En **Description**, agregue una breve descripción: *Proyecto piloto para pruebas de gobierno, seguridad y CI/CD híbrido.*
3.  En **Visibility**, elija obligatoriamente **Private** (Privado) para garantizar que los activos no estén expuestos públicamente en internet.
4.  Haga clic en **Advanced** para desplegar las opciones avanzadas:
    *   **Version Control**: Asegúrese de seleccionar **Git** (por defecto y estándar de la industria).
    *   **Work Item Process**: Seleccione **Agile** (o *Scrum*, dependiendo de su modelo de trabajo interno). Para este laboratorio utilizaremos **Agile**.
5.  Haga clic en el botón azul **+ Create project**. El sistema creará el proyecto y lo redirigirá al Dashboard de bienvenida de `Proyecto-Piloto`.

---

### Paso 3: Exploración de Configuración a Nivel de Organización vs Proyecto
Es fundamental comprender el alcance de los dos paneles de configuración principales:

```
               ┌──────────────────────────────────────────────────┐
               │              Organization Settings               │
               │ (Usuarios globales, Facturación, Conectividad AD)│
               └────────────────────────┬─────────────────────────┘
                                        │
                         ┌──────────────┴──────────────┐
                         ▼                             ▼
           ┌──────────────────────────┐   ┌──────────────────────────┐
           │     Project Settings     │   │     Project Settings     │
           │  (Equipos, Service Conn) │   │ (Permisos, Repos, Boards)│
           └──────────────────────────┘   └──────────────────────────┘
```

#### 1. Explorar Organization Settings (Configuración Global)
1.  En la esquina inferior izquierda de la pantalla, localice y haga clic en **Organization Settings** (Configuración de la organización).
2.  Examine detenidamente cada uno de los componentes de configuración global organizados por categorías:

##### A. Categoría "General"
*   **Overview (Información general)**: Muestra información básica de la organización (nombre, URL de acceso, ID de la cuenta, región física de hospedaje y zona horaria). También incluye la opción para eliminar la organización de manera permanente si se requiere.
*   **Projects (Proyectos)**: Lista todos los proyectos creados dentro de la organización, mostrando su nivel de visibilidad (público o privado), cantidad de miembros y permitiendo la creación o eliminación masiva de proyectos.
*   **Users (Usuarios)**: Panel centralizado para invitar nuevos usuarios, cambiar sus niveles de acceso (*Basic*, *Stakeholder*, o basados en suscripciones de Visual Studio) y gestionar su asignación a proyectos o licencias.
*   **Billing (Facturación)**: Permite vincular la organización a una suscripción de Azure para el cobro mensual, comprar licencias Basic adicionales y habilitar recursos adicionales de pipelines o almacenamiento.
*   **Global notifications (Notificaciones globales)**: Centraliza las reglas de alertas para correos electrónicos a nivel de toda la organización (ej: alertas ante fallos de compilación general o eventos de administración).
*   **Usage (Uso)**: Muestra gráficos de telemetría sobre el consumo de la API de Azure DevOps por parte de usuarios y scripts, permitiendo detectar cuellos de botella y abusos de rate-limits.
*   **Extensions (Extensiones)**: Tienda local de plugins instalados desde el Visual Studio Marketplace (ej: integraciones con Slack, SonarQube, herramientas de escaneo de vulnerabilidades, etc.).
*   **Microsoft Entra (Directorio Activo)**: Permite vincular la organización de Azure DevOps a tu Directorio Activo de Microsoft (Entra ID) para habilitar el inicio de sesión único (SSO), políticas de MFA y el ciclo de vida centralizado de los usuarios corporativos.

##### B. Categoría "Security"
*   **Security overview (Resumen de seguridad)**: Muestra el estado general de gobernanza y posibles brechas de acceso en la organización.
*   **Policies (Políticas)**: Reglas de seguridad estrictas que aplican a todos los proyectos (ej: permitir o prohibir la creación de proyectos públicos, deshabilitar accesos por SSH, forzar el uso de políticas de acceso condicional).
*   **Permissions (Permisos organizacionales)**: Grupos globales de seguridad (ej: *Project Collection Administrators*, *Project Collection Build Service Accounts*) que dictan quién puede crear nuevos proyectos o modificar la facturación de la organización.

##### C. Categoría "Boards"
*   **Process (Procesos)**: Controla las plantillas de metodologías ágiles a nivel de organización (Basic, Agile, Scrum, CMMI). Desde aquí puedes crear procesos personalizados heredados para agregar campos de datos personalizados a las tareas o modificar sus flujos de estados lógicos.

##### D. Categoría "Pipelines"
*   **Agent pools (Pools de agentes)**: Gestión de la infraestructura de agentes que compilan y despliegan código. Aquí administras tanto los agentes compartidos alojados en Azure (Microsoft-hosted) como tus propios agentes privados instalados en servidores On-Premise.
*   **Settings (Ajustes de compilación)**: Configuraciones globales para pipelines (ej: deshabilitar pipelines clásicos basados en interfaz visual para forzar el uso de YAML estructurado por seguridad).
*   **Deployment pools (Pools de despliegue)**: Agrupaciones lógicas de servidores y máquinas físicas internas de destino sobre las cuales se realizarán las instalaciones y configuraciones.
*   **Parallel jobs (Trabajos en paralelo)**: Muestra la capacidad disponible y los límites contratados para ejecutar ejecuciones de pipelines en simultáneo (tanto para Linux/Windows provistos por Microsoft como autogestionados).
*   **OAuth configurations (Configuraciones OAuth)**: Mapeo y registro de aplicaciones externas que se integrarán con la organización de Azure DevOps de forma segura mediante tokens temporales.

#### 2. Explorar Project Settings (Configuración del Proyecto)
1.  Haga clic en el logo de **Azure DevOps** arriba a la izquierda para volver al Dashboard, ingrese a `Proyecto-Piloto` y haga clic en **Project settings** en la esquina inferior izquierda.
2.  Examine detenidamente cada uno de los componentes de configuración a nivel de proyecto organizados por categorías:

##### A. Categoría "Project Settings" (General)
*   **Overview (Información general)**: Resumen del proyecto (descripción, visibilidad pública/privada, administradores asignados) y el interruptor central para habilitar o deshabilitar módulos completos como Repos, Boards, Pipelines, etc.
*   **Teams (Equipos)**: Creación y administración de equipos de desarrollo específicos dentro de este proyecto que compartirán un backlog o tablero Kanban propio.
*   **Permissions (Permisos)**: Gestión de grupos locales (`Contributors`, `Readers`, `Project Administrators`) y asignación detallada de permisos locales.
*   **Notifications (Notificaciones)**: Reglas y suscripciones para el envío de correos ante eventos específicos que ocurran dentro de este proyecto (ej: fallos de pipelines locales).
*   **Service hooks (Ganchos de servicio)**: Integración saliente mediante webhooks para notificar o interactuar de forma inmediata con herramientas externas (ej: enviar un mensaje a un canal de Slack o actualizar un ticket en Jira cuando una tarea se complete en Boards).
*   **Dashboards (Paneles de control)**: Configuración y administración de las pantallas de métricas y widgets del proyecto.

##### B. Categoría "Boards"
*   **Project configuration (Configuración del proyecto)**: Define la estructura jerárquica de áreas y las fechas/duración de las iteraciones o Sprints del proyecto.
*   **Team configuration (Configuración del equipo)**: Permite personalizar los tableros Kanban, el flujo de trabajo de tareas y los días de trabajo específicos de cada equipo.
*   **GitHub connections (Conexiones de GitHub)**: Integración directa para conectar repositorios de GitHub al proyecto y enlazar commits o PRs directamente a Historias de Usuario en Boards.

##### C. Categoría "Pipelines"
*   **Agent pools (Pools de agentes)**: Asignación y visualización de los recursos de agentes que este proyecto está autorizado a consumir para ejecutar tareas de compilación y despliegue.
*   **Parallel jobs (Trabajos en paralelo)**: Mapeo y límites de ejecuciones simultáneas permitidos para los pipelines locales.
*   **Settings (Ajustes)**: Ajustes de seguridad y configuración para la ejecución de pipelines en este proyecto específico (ej: permisos de acceso a secretos).
*   **Test management (Gestión de pruebas)**: Ajustes sobre el guardado de reportes de calidad y automatización de QA.
*   **Service connections (Conexiones de servicio)**: Creación de credenciales seguras de conexión (Service Connections) hacia nubes (Azure, AWS), repositorios externos (como GitLab) u otras plataformas externas para su uso en pipelines.
*   **XAML build services**: Soporte heredado para agentes de compilación en formato XAML antiguos.

##### D. Categoría "Repos"
*   **Repositories (Repositorios)**: Permite administrar todos los repositorios Git dentro del proyecto, establecer permisos avanzados de lectura/escritura y configurar políticas de protección de ramas (*Branch Policies*) para forzar Pull Requests obligatorios.

##### E. Categoría "Artifacts"
*   **Storage (Almacenamiento)**: Monitoreo de cuota y espacio utilizado por paquetes (npm, NuGet, etc.) subidos a los Feeds de Azure Artifacts locales.

##### F. Categoría "Test"
*   **Retention (Retención)**: Políticas que definen cuántos días se guardarán en la base de datos de Azure DevOps los resultados y reportes de pruebas automatizadas antes de ser depurados automáticamente.

---

### Paso 4: Navegación de Habilitación de Servicios
Supongamos que su organización utilizará GitLab On-Premise para almacenar el código y Jira para el control de tareas, por lo que no requieren los módulos de *Azure Repos* ni *Azure Boards*.

1.  Estando en **Project settings**, permanezca en la pestaña **Overview** (Información general).
2.  Desplácese hacia abajo hasta la sección **Services**.
3.  Desactive los interruptores (toggle switches) de los siguientes servicios:
    *   **Boards**
    *   **Test Plans**
4.  Haga clic en guardar/actualizar (la plataforma los oculta de forma inmediata en el menú lateral izquierdo).
5.  Verifique el menú de navegación izquierdo: observará que ahora solo se muestran los servicios que permanecen activos (ej. *Repos*, *Pipelines* y *Artifacts*).
6.  Vuelva a activar **Boards** para propósitos del siguiente laboratorio, y note cómo reaparece instantáneamente.

---

> [!WARNING]
> Desactivar un servicio a nivel de proyecto solo oculta la interfaz de usuario para los miembros del proyecto; los datos históricos y configuraciones no se eliminan inmediatamente, lo que permite reestablecerlos de forma segura.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Región de Hospedaje** | Validar que la organización se creó en la región geográfica óptima (ej: *East US 2*). |
| 🔲 | **Visibilidad Privada** | Confirmar que `Proyecto-Piloto` está explícitamente configurado como **Private** en su panel. |
| 🔲 | **Módulos Organizacionales** | Ubicar las secciones críticas del menú lateral en *Organization Settings* (General, Seguridad, Boards, Pipelines). |
| 🔲 | **Servicios Habilitados** | Desactivar un módulo (ej. *Boards*), verificar su desaparición y volverlo a activar exitosamente. |

Proceda al [**Lab 2**](Lab2_Gestion_Agil_Azure_Boards.md) para aprender sobre la gestión ágil de proyectos con Azure Boards.
