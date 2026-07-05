# 🧪 Laboratorio 3: Parametrización de Usuarios, Roles, Permisos y Aislamiento de Entornos

Este laboratorio práctico enseña cómo gestionar la gobernanza de accesos en **Azure DevOps Services**. Aprenderá a crear grupos personalizados, configurar políticas de seguridad sobre repositorios de código y proteger recursos compartidos para aislar los entornos de desarrollo, pruebas y producción.

---

## 🎯 Objetivos del Laboratorio
1.  Invitar usuarios a la organización y comprender la asignación de niveles de acceso (*Basic* vs *Stakeholder*).
2.  Crear grupos de seguridad personalizados a nivel de proyecto.
3.  Establecer políticas de seguridad e impedir modificaciones directas en ramas críticas (*Branch Policies*).
4.  Crear una Conexión de Servicio (Service Connection) ficticia y restringir sus permisos para simular el aislamiento del entorno de Producción.

---

## ⏳ Tiempo Estimado: 60 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Gestión de Usuarios y Niveles de Acceso
1.  Vaya a **Organization Settings** (esquina inferior izquierda de la pantalla principal de la organización).
2.  Haga clic en la pestaña **Users**.
3.  Haga clic en el botón superior derecho **+ Add users**.
4.  Complete la información del usuario de prueba:
    *   **Users**: Ingrese el correo de un compañero o una dirección alternativa.
    *   **Access level**: 
        *   **Basic**: Seleccione este nivel para miembros del equipo que necesiten programar (leer/escribir repos) u orquestar pipelines.
        *   **Stakeholder**: Seleccione este nivel para perfiles de negocio (solo tableros e información general).
    *   **Add to projects**: Escriba `Proyecto-Piloto` y selecciónelo.
    *   **Azure DevOps Groups**: Déjelo por defecto en **Contributors** para este paso.
5.  Haga clic en **Add**.

---

### Paso 2: Creación de Grupos de Seguridad Personalizados
En lugar de asignar permisos usuario por usuario, crearemos grupos según el rol operativo del equipo.

1.  Regrese a su proyecto `Proyecto-Piloto` y abra **Project settings** (Configuración del proyecto) > **Permissions**.
2.  Haga clic en la pestaña **Groups**.
3.  Haga clic en el botón **+ New Group** arriba a la derecha.
4.  Configure el primer grupo:
    *   **Group name**: `Lideres-Tecnicos`
    *   **Description**: *Líderes técnicos con capacidad de aprobación de código y configuración de infraestructura.*
5.  Haga clic en **Create**.
6.  Repita el procedimiento para crear un segundo grupo:
    *   **Group name**: `Desarrolladores-Externos`
    *   **Description**: *Desarrolladores externos con permisos restringidos de escritura y sin acceso a producción.*
7.  Haga clic en **Create**.

---

### Paso 3: Configuración de Permisos y Políticas en Repositorios (Aislamiento de Ramas)
Para evitar que un desarrollador de `Desarrolladores-Externos` modifique directamente la rama principal (`main`) o realice un *Force Push* (reescribir el historial de Git):

#### 1. Configurar Permisos Generales sobre Repositorios
1.  Asegúrese de estar en el proyecto **`Proyecto-Piloto`**. Si salió de la configuración, abra **Project settings** (Configuración del proyecto) en la esquina inferior izquierda.
2.  En el menú lateral de configuración, bajo la sección **Repos**, haga clic en **Repositories**.
3.  Haga clic en la pestaña **Security** en la parte superior derecha.
4.  En la barra lateral izquierda, busque el grupo escribiendo `Desarrolladores-Externos` en el cuadro de búsqueda **`Search for users or groups`** (Buscar usuarios o grupos) y selecciónelo (los grupos personalizados no aparecen en la lista predeterminada hasta que se buscan).
5.  Una vez seleccionado y agregado a la lista, asegúrese de hacer clic en él.
6.  En el panel derecho, busque el permiso **Force push (rewrite history, delete branches and tags)** y cámbielo explícitamente a **Deny** (Denegar).
7.  Busque el permiso **Bypass policies when pushing** y cámbielo a **Deny**.

```
🔒 Seguridad del Repositorio para 'Desarrolladores-Externos':
├── Force Push ──────────────► [Deny]  (Evita borrar ramas críticas)
└── Bypass Policies ─────────► [Deny]  (Fuerza el cumplimiento de reglas)
```

#### 2. Configurar Políticas de Rama (Branch Policies) en `main`
1.  **Salga de la configuración del proyecto**: haga clic en el nombre del proyecto **`Proyecto-Piloto`** en la esquina superior izquierda (en la ruta de navegación o *breadcrumbs*) o haga clic en el botón de retroceso de su navegador. Esto le devolverá al panel principal del proyecto.
2.  En el menú de navegación izquierdo principal, vaya a **Repos > Branches** (Repositorios > Ramas).
3.  Si el repositorio está vacío, cree un archivo inicial rápido haciendo clic en el botón **Initialize** (en la sección inferior del mensaje de repositorio vacío). Esto creará automáticamente un archivo `README.md` en la rama `main`.
4.  Una vez inicializado, regrese a **Repos > Branches** en el menú izquierdo.
5.  Pase el cursor sobre la rama `main`, haga clic en los tres puntos (`...`) en el extremo derecho de la fila y seleccione **Branch policies** (Políticas de la rama).
5.  Active las siguientes políticas de cumplimiento normativo:
    *   **Require a minimum number of reviewers**: Active este interruptor.
        *   Defina el número mínimo de revisores en **1** o **2**.
        *   Asegúrese de mantener **desmarcada** la casilla **`Allow requestors to approve their own changes`** (esto prohíbe que el creador del Pull Request apruebe su propio código).
        *   Marque la casilla **`Prohibit the most recent pusher from approving their own changes`** (evita que la última persona que subió código al Pull Request pueda auto-aprobarse).
    *   **Check for linked work items**: Active para forzar que todo cambio de código esté asociado a una tarea en los tableros.
    *   **Check for comment resolution**: Active para garantizar que todas las discusiones del código se resuelvan antes de fusionar.

---

### Paso 4: Aislamiento de Entornos mediante Service Connections
Las conexiones de servicio permiten a los pipelines desplegar en nubes (Azure, AWS) u otras herramientas. Es crítico que los desarrolladores externos no puedan usar libremente la conexión del entorno de Producción.

1.  En **Project settings**, haga clic en **Service connections**.
2.  Haga clic en **Create service connection** y seleccione **Generic** (para fines de simulación).
3.  Haga clic en **Next**.
4.  Configure lo siguiente:
    *   **Server URL**: `https://api.produccion.empresa.com`
    *   **Service connection name**: `Prod-Environment-Connection`
    *   **Description**: *Conexión segura para despliegues al entorno productivo.*
    *   **Security**: Deje marcada la opción *Grant access permission to all pipelines* (la restringiremos manualmente a continuación).
5.  Haga clic en **Save**.
6.  Ahora, haga clic sobre la conexión recién creada `Prod-Environment-Connection`.
7.  En la esquina superior derecha, haga clic en los tres puntos (`...`) y seleccione **Security**.
8.  En la sección **User permissions**:
    *   Haga clic en **+ Add**.
    *   Busque al grupo `Desarrolladores-Externos` y asígnele el rol **Reader** (solo pueden verla, no pueden usarla para desplegar).
    *   Busque al grupo `Lideres-Tecnicos` y asígnele el rol **User** o **Administrator** (pueden usarla en sus pipelines).
9.  En la sección **Pipeline permissions**:
    *   Haga clic en **+** y restrinja su uso únicamente a los pipelines ubicados en carpetas de despliegue seguro o bajo ramas aprobadas.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Permisos de Repositorio** | Confirmar que el grupo `Desarrolladores-Externos` tiene el permiso *Force push* denegado explícitamente. |
| 🔲 | **Políticas de Rama (main)** | Validar que la rama `main` requiere al menos 1 revisor externo y no permite auto-aprobación del autor. |
| 🔲 | **Seguridad en Service Connection** | Comprobar que `Prod-Environment-Connection` restringe al grupo externo al rol de solo lectura (*Reader*). |

Proceda a la [**Sesión 2**](../../Sesion2/README.md) para iniciar con la Estrategia CI/CD e Integración Híbrida, o vaya directamente al [**Lab 4**](../../Sesion2/Laboratorios/Lab4_Pipelines_Artifacts.md).
