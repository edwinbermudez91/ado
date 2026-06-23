# 🧪 Laboratorio 4: Pipelines YAML y Azure Artifacts

Este laboratorio práctico guía al participante en la creación de un Pipeline de Integración y Entrega Continua (CI/CD) basado en **YAML** dentro de Azure DevOps, integrando la publicación de paquetes en **Azure Artifacts** y la configuración de aprobaciones manuales.

---

## 🎯 Objetivos del Laboratorio
1.  Inicializar un repositorio Git con una aplicación Node.js de prueba estándar.
2.  Configurar un Feed privado de **Azure Artifacts**.
3.  Escribir un pipeline multi-etapa en **YAML** (`azure-pipelines.yml`) que compile, pruebe y publique artefactos.
4.  Configurar un **Environment** y aplicar una política de aprobación manual antes del despliegue simulado.

---

## ⏳ Tiempo Estimado: 75 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Configurar el Repositorio de Prueba
1.  Vaya a **Repos > Files** en su proyecto `Proyecto-Piloto`.
2.  Si el repositorio ya está inicializado, cree una estructura simple de Node.js creando los siguientes dos archivos (haga clic en el botón superior derecho `...` > **New > File**):

#### `package.json`
```json
{
  "name": "app-prueba-coem",
  "version": "1.0.0",
  "description": "Aplicación Node.js de prueba estándar para capacitación CI/CD",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Ejecutando pruebas unitarias... Exito!\" && exit 0"
  },
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
```

#### `index.js`
```javascript
const _ = require('lodash');
console.log(_.join(['Hola', 'Mundo', 'desde', 'Azure', 'Pipelines!'], ' '));
```

3.  Haga commit de ambos archivos directamente en la rama `main`.

---

### Paso 2: Crear el Feed Privado en Azure Artifacts
1.  En el menú lateral izquierdo, seleccione **Artifacts**.
2.  Haga clic en **+ Create Feed** en la parte superior.
3.  Configure el feed:
    *   **Name**: `coem-packages`
    *   **Visibility**: *Members of my organization* (para mantenerlo privado).
    *   **Upstream sources**: Deje marcada la casilla (permite descargar paquetes públicos a través de su feed privado y almacenarlos en caché).
4.  Haga clic en **Create**.

---

### Paso 3: Configurar el Entorno (Environment) de Aprobaciones
Para asegurar que los despliegues requieran una firma digital (aprobación) antes de ejecutarse:

1.  En el menú lateral izquierdo, vaya a **Pipelines > Environments**.
2.  Haga clic en **Create environment** (o *New Environment*).
3.  Escriba el nombre: `Prod-Environment`.
4.  En **Resource**, seleccione **None** (ya que utilizaremos aprobaciones lógicas de flujo de control).
5.  Haga clic en **Create**.
6.  Una vez creado, haga clic en la pestaña **Approvals and checks** en la esquina superior derecha (los tres puntos `...` > **Approvals and checks**).
7.  Haga clic en **+ Add check** (o en el botón de añadir) y seleccione **Approvals**.
8.  En **Approvers**, agregue su propia cuenta de correo (para probar la aprobación usted mismo) o el grupo `Lideres-Tecnicos`.
9.  Haga clic en **Create**.

---

### Paso 4: Crear el Pipeline Multi-Etapa en YAML
1.  Vaya a **Pipelines** (menú izquierdo) y haga clic en **Create Pipeline** (o *New Pipeline*).
2.  Seleccione **Azure Repos Git** como origen del código.
3.  Seleccione su repositorio `Proyecto-Piloto`.
4.  Seleccione **Starter pipeline** (Pipeline básico).
5.  Reemplace el contenido por defecto del editor por el siguiente código YAML:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Build
  displayName: 'Etapa de Compilación y Prueba'
  jobs:
  - job: CompileCode
    displayName: 'Instalación y Pruebas Unitarias'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '18.x'
      displayName: 'Instalar Node.js'

    - script: |
        npm install
        npm run test
      displayName: 'Instalar Dependencias y Probar'

    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(System.DefaultWorkingDirectory)'
        artifact: 'app-build'
        publishLocation: 'pipeline'
      displayName: 'Publicar Artefacto de Compilación'

- stage: DeployToProd
  displayName: 'Despliegue a Producción'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: DeployApp
    displayName: 'Despliegue Lógico en Prod'
    environment: 'Prod-Environment' # Vincula la aprobación del Paso 3
    strategy:
      runOnce:
        deploy:
          steps:
          - task: DownloadPipelineArtifact@2
            inputs:
              buildType: 'current'
              artifactName: 'app-build'
              targetPath: '$(Pipeline.Workspace)/drop'
            displayName: 'Descargar Artefacto de Compilación'

          - script: |
              echo "Desplegando la aplicación en el servidor de producción..."
              node $(Pipeline.Workspace)/drop/index.js
            displayName: 'Ejecutar Script de Arranque'
```

6.  Haga clic en el botón superior derecho **Save and run** (Guardar y ejecutar).
7.  Se creará el archivo `azure-pipelines.yml` en la raíz de su repositorio y se iniciará la ejecución automáticamente.

---

### Paso 5: Validar la Aprobación y Ejecución
1.  Siga la ejecución visual del pipeline recién creado.
2.  Observará que la primera etapa `Build` se ejecuta y completa correctamente.
3.  La segunda etapa `DeployToProd` entrará en estado **Waiting (Esperando)** con un banner que indica: *"1 approval needs your review before this run can continue to DeployToProd"*.
4.  Haga clic en **Review**, escriba un comentario de aprobación (ej: *Código verificado y listo para producción*) y presione **Approve**.
5.  El pipeline reanudará su ejecución inmediatamente y completará el despliegue ficticio.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Compilación Exitosa (CI)** | Comprobar que el Stage `Build` se ejecutó sin errores y corrió las pruebas unitarias de Node.js. |
| 🔲 | **Artefacto Publicado** | Confirmar que el archivo empaquetado `app-build` aparece listado en los artefactos de la corrida. |
| 🔲 | **Aprobación de Entorno** | Validar que el Stage `DeployToProd` se pausó y solicitó la aprobación manual del usuario asignado. |
| 🔲 | **Ejecución de Código** | Verificar que en los logs de la tarea final de despliegue se imprima el output de index.js (*"Hola Mundo..."*). |

Proceda al [**Lab 5**](Lab5_Integracion_GitLab_Hybrid.md) para configurar la integración híbrida con GitLab y agentes auto-hospedados.
