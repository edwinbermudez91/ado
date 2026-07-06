# 🧪 Laboratorio 5: Pipeline CI/CD Clásico (Build & Release) para Aplicación PHP con GitLab y Despliegue en Azure VM

Este laboratorio práctico guía al participante en la configuración de un ciclo de vida completo de Integración Continua (CI) y Despliegue Continuo (CD) utilizando la interfaz **Clásica (Visual/Classic)** de Azure DevOps. Esto permite conectar repositorios locales o híbridos de **GitLab** que no pueden integrarse directamente mediante disparadores YAML nativos de Azure DevOps de forma directa.

Construiremos una aplicación web PHP para el control de temperaturas de las principales ciudades de Colombia, implementando buenas prácticas de **DevSecOps** (análisis de código estático, revisión de seguridad en librerías y pruebas unitarias automáticas) y un esquema de liberación por etapas (**Desarrollo** y **Producción**) inyectando variables seguras a servidores en Azure.

---

## 🎯 Objetivos del Laboratorio
1. Crear una aplicación PHP modular con lógica de negocio, interfaz web moderna y pruebas automáticas en GitLab.
2. Configurar la integración del código fuente en un **Classic Build Pipeline (CI)** en Azure DevOps usando la conexión de servicio con GitLab.
3. Ejecutar análisis estático (Linting/Estilos), escaneo de seguridad de dependencias y pruebas unitarias (PHPUnit) en la fase de CI.
4. Crear un **Classic Release Pipeline (CD)** con dos etapas: **Desarrollo** y **Producción**, vinculando grupos de variables (`Variable Groups`) específicos para cada ambiente.
5. Configurar el despliegue automático hacia servidores Linux Ubuntu alojados en Azure mediante el agente auto-hospedado configurado en el Lab 4.
6. Aplicar directrices DevSecOps de validación de permisos en directorios de servidor web y ejecución de pruebas de humo (Smoke Tests).

---

## ⏳ Tiempo Estimado: 60 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Estructurar la Aplicación PHP en GitLab
1. En su repositorio de GitLab, cree un nuevo proyecto o use el repositorio existente llamado `temperaturas-colombia`.
2. Cree la siguiente estructura de archivos en la raíz del repositorio:

```text
temperaturas-colombia/
├── src/
│   └── TemperatureService.php      # Lógica de temperaturas y conversión Fahrenheit
├── tests/
│   └── TemperatureServiceTest.php  # Pruebas unitarias de PHPUnit
├── composer.json                   # Dependencias de producción y desarrollo (PHPUnit, PHPCS)
├── index.php                       # Interfaz visual de consulta de clima
└── .gitignore                      # Exclusiones de Git (vendor/, .env, etc.)
```

#### `.gitignore`
Evita subir dependencias locales y credenciales al repositorio GitLab:
```text
/vendor/
.env
composer.lock
.phpunit.result.cache
```

#### `composer.json`
Define las dependencias del proyecto. Utilizaremos `phpunit` para pruebas unitarias y `php_codesniffer` para asegurar las pautas de estilo de código (PSR-12).
```json
{
  "name": "inm/temperaturas-colombia",
  "description": "Servicio de control de temperaturas de ciudades de Colombia",
  "type": "project",
  "require": {
    "php": ">=7.4"
  },
  "require-dev": {
    "phpunit/phpunit": "^9.5",
    "squizlabs/php_codesniffer": "^3.7"
  },
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  }
}
```

#### `src/TemperatureService.php`
Lógica de negocio de la aplicación que gestiona las temperaturas de las ciudades y la conversión de unidades.
```php
<?php

namespace App;

class TemperatureService
{
    private $temperaturas = [
        'Bogota' => 14.5,
        'Medellin' => 22.2,
        'Cali' => 27.8,
        'Barranquilla' => 31.0,
        'Cartagena' => 30.5,
        'Bucaramanga' => 25.0
    ];

    public function getTemperature(string $ciudad)
    {
        $ciudadNormalize = str_replace(
            ['á', 'é', 'í', 'ó', 'ú', 'Á', 'É', 'Í', 'Ó', 'Ú'],
            ['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'],
            $ciudad
        );
        $ciudadKey = ucfirst(strtolower(trim($ciudadNormalize)));

        if (array_key_exists($ciudadKey, $this->temperaturas)) {
            return [
                'status' => 'success',
                'ciudad' => $ciudadKey,
                'temperatura' => $this->temperaturas[$ciudadKey],
                'unidad' => 'Celsius'
            ];
        }

        return [
            'status' => 'error',
            'message' => 'Ciudad no registrada en la red del INM'
        ];
    }

    public function convertToFahrenheit(float $celsius): float
    {
        return ($celsius * 9 / 5) + 32;
    }
}
```

#### `tests/TemperatureServiceTest.php`
Pruebas unitarias para validar el correcto funcionamiento del servicio y la conversión de grados.
```php
<?php

namespace Tests;

use PHPUnit\Framework\TestCase;
use App\TemperatureService;

class TemperatureServiceTest extends TestCase
{
    public function testGetTemperatureSuccess()
    {
        $service = new TemperatureService();
        $response = $service->getTemperature('Medellín');
        $this->assertEquals('success', $response['status']);
        $this->assertEquals(22.2, $response['temperatura']);
    }

    public function testGetTemperatureNotFound()
    {
        $service = new TemperatureService();
        $response = $service->getTemperature('Leticia');
        $this->assertEquals('error', $response['status']);
        $this->assertEquals('Ciudad no registrada en la red del INM', $response['message']);
    }

    public function testConvertToFahrenheit()
    {
        $service = new TemperatureService();
        $this->assertEquals(32, $service->convertToFahrenheit(0));
        $this->assertEquals(59, $service->convertToFahrenheit(15));
    }
}
```

#### `index.php`
Interfaz visual web en HTML/CSS y PHP para consultar las temperaturas de manera interactiva.
```php
<?php
require 'vendor/autoload.php';
use App\TemperatureService;

// Cargar variables de entorno simuladas desde un archivo .env si existe
$envFile = __DIR__ . '/.env';
$appEnv = 'Local';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            putenv(trim($key) . '=' . trim($value));
        }
    }
    $appEnv = getenv('API_ENV') ?: 'Desconocido';
}

$service = new TemperatureService();
$resultado = null;
$ciudadSeleccionada = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $ciudadSeleccionada = $_POST['ciudad'] ?? '';
    if (!empty($ciudadSeleccionada)) {
        $resultado = $service->getTemperature($ciudadSeleccionada);
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>INM - Control de Temperaturas de Colombia</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0f2f5; margin: 0; padding: 20px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 100%; max-width: 450px; }
        h1 { color: #003366; text-align: center; margin-top: 0; font-size: 24px; }
        .badge { display: inline-block; padding: 5px 10px; background-color: #e0f2fe; color: #0369a1; border-radius: 20px; font-size: 12px; font-weight: bold; margin-bottom: 20px; }
        .badge-prod { background-color: #fee2e2; color: #b91c1c; }
        form { display: flex; flex-direction: column; gap: 15px; }
        select, button { padding: 12px; border-radius: 6px; border: 1px solid #ccc; font-size: 16px; }
        button { background-color: #003366; color: white; border: none; cursor: pointer; font-weight: bold; }
        button:hover { background-color: #002244; }
        .result { margin-top: 20px; padding: 15px; border-radius: 6px; border-left: 5px solid #10b981; background-color: #f0fdf4; }
        .result.error { border-left-color: #ef4444; background-color: #fef2f2; color: #b91c1c; }
    </style>
</head>
<body>
    <div class="card">
        <h1>INM - Consulta de Temperaturas</h1>
        <center>
            <span class="badge <?php echo strtolower($appEnv) === 'produccion' ? 'badge-prod' : ''; ?>">
                Entorno: <?php echo htmlspecialchars($appEnv); ?>
            </span>
        </center>
        
        <form method="POST">
            <label for="ciudad">Seleccione una ciudad de Colombia:</label>
            <select name="ciudad" id="ciudad" required>
                <option value="">-- Seleccionar --</option>
                <option value="Bogota" <?php echo $ciudadSeleccionada === 'Bogota' ? 'selected' : ''; ?>>Bogotá</option>
                <option value="Medellin" <?php echo $ciudadSeleccionada === 'Medellin' ? 'selected' : ''; ?>>Medellín</option>
                <option value="Cali" <?php echo $ciudadSeleccionada === 'Cali' ? 'selected' : ''; ?>>Cali</option>
                <option value="Barranquilla" <?php echo $ciudadSeleccionada === 'Barranquilla' ? 'selected' : ''; ?>>Barranquilla</option>
                <option value="Cartagena" <?php echo $ciudadSeleccionada === 'Cartagena' ? 'selected' : ''; ?>>Cartagena</option>
                <option value="Bucaramanga" <?php echo $ciudadSeleccionada === 'Bucaramanga' ? 'selected' : ''; ?>>Bucaramanga</option>
                <option value="Leticia" <?php echo $ciudadSeleccionada === 'Leticia' ? 'selected' : ''; ?>>Leticia (Fuera de Red)</option>
            </select>
            <button type="submit">Consultar Clima</button>
        </form>

        <?php if ($resultado): ?>
            <?php if ($resultado['status'] === 'success'): ?>
                <div class="result">
                    <strong>Ciudad:</strong> <?php echo htmlspecialchars($resultado['ciudad']); ?><br>
                    <strong>Temperatura:</strong> <?php echo htmlspecialchars($resultado['temperatura']); ?> °C 
                    (<?php echo $service->convertToFahrenheit($resultado['temperatura']); ?> °F)<br>
                    <strong>Unidad:</strong> <?php echo htmlspecialchars($resultado['unidad']); ?>
                </div>
            <?php else: ?>
                <div class="result error">
                    <strong>Error:</strong> <?php echo htmlspecialchars($resultado['message']); ?>
                </div>
            <?php endif; ?>
        <?php endif; ?>
    </div>
</body>
</html>
```

---

### Paso 2: Crear el Classic Build Pipeline (CI) en Azure DevOps
Dado que GitLab local está conectado por medio de un Service Connection ("Other Git"), utilizaremos el diseñador visual clásico.

1. **Crear Pipeline de Compilación**:
   * En Azure DevOps, vaya a **Pipelines > Pipelines** y haga clic en **New Pipeline**.
   * En la parte inferior de la ventana, haga clic en el enlace **Use the classic editor**.
   * **Select a source**: Seleccione **Other Git**.
   * **Connection**: Seleccione la conexión de servicio que creamos en el Lab 4 (`GitLab-Connection` o `GitLab-Meteo-Repo`).
   * **Default branch**: Escriba `master` o `main`.
   * Haga clic en **Continue**.
   * En la plantilla de inicio, seleccione **Empty job** (Trabajo vacío) y presione **Apply**.

2. **Configurar el Agente**:
   * Seleccione **Pipeline** en la jerarquía superior.
   * **Agent pool**: Seleccione **Pool-OnPremise** (su agente auto-hospedado configurado en la máquina Linux en el Lab 4).

3. **Agregar las Tareas del Pipeline (Build Steps)**:
   Haga clic en el icono **`+`** al lado de **Agent job 1** y agregue las siguientes tareas en orden secuencial:

   * **Tarea 1: Command Line (Línea de comandos)**
     * **Display name**: `Instalar Dependencias de Composer`
     * **Script**:
       ```bash
       composer install --no-interaction --prefer-dist
       ```
   
   * **Tarea 2: Command Line (Análisis de Código Estático - Linter)**
     * **Display name**: `Validación de Sintaxis PHP (Linter)`
     * **Script**:
       ```bash
       # Busca errores de sintaxis en todos los archivos del directorio de trabajo
       find . -name "*.php" ! -path "./vendor/*" -exec php -l {} \;
       ```

   * **Tarea 3: Command Line (Validación de Estilos de Código)**
     * **Display name**: `Ejecutar PHP_CodeSniffer`
     * **Script**:
       ```bash
       # Comprobación de estándares PSR-12
       ./vendor/bin/phpcs --standard=PSR12 src/ tests/
       ```
     * **Control Options**: Marque *Continue on error* si desea que el pipeline continúe aunque existan advertencias de estilos (opcional).
     * > [!TIP]
        > **¿Qué hacer si esta tarea falla por errores de estilo (PSR-12)?**  
        > Puedes corregir casi todas las inconsistencias de formato automáticamente desde tu terminal local ejecutando:  
        > `**./vendor/bin/phpcbf --standard=PSR12 src/ tests/**`.  
        > Si reporta un error manual de namespace en los tests, añade `namespace Tests;` al inicio del archivo de pruebas.

   * **Tarea 4: Command Line (Análisis de Seguridad de Dependencias - DevSecOps)**
     * **Display name**: `Análisis de Vulnerabilidad en Dependencias`
     * **Script**:
       ```bash
       # Descargar herramienta liviana de auditoría de seguridad
       curl -sSLo local-php-security-checker https://github.com/fabpot/local-php-security-checker/releases/download/v2.0.6/local-php-security-checker_linux_amd64
       chmod +x local-php-security-checker
       # Ejecutar análisis sobre composer.lock
       ./local-php-security-checker --path=./composer.lock
       ```
     * *(Nota: Esta herramienta verifica que no se introduzcan librerías con vulnerabilidades de seguridad conocidas en nuestro código).*

   * **Tarea 5: Command Line (Pruebas Unitarias)**
     * **Display name**: `Ejecutar Pruebas PHPUnit`
     * **Script**:
       ```bash
       ./vendor/bin/phpunit tests/TemperatureServiceTest.php
       ```

   * **Tarea 6: Command Line (Preparación del Entorno Limpio para Empaque)**
     * **Display name**: `Remover dependencias de desarrollo`
     * **Script**:
       ```bash
       # Elimina dependencias de test y linter para no llevar peso muerto a los servidores
       composer install --no-dev --optimize-autoloader --no-interaction
       ```

   * **Tarea 7: Archive files (Archivar archivos)**
     * **Display name**: `Empaquetar aplicación (ZIP)`
     * **Root folder or file to archive**: `$(System.DefaultWorkingDirectory)`
     * **Prefix root folder name to archive paths**: Desmarcar (falso).
     * **Archive type**: `zip`
     * **Archive file to create**: `$(Build.ArtifactStagingDirectory)/temperaturas-app.zip`

   * **Tarea 8: Publish build artifacts (Publicar artefactos)**
     * **Display name**: `Publicar Artefacto`
     * **Path to publish**: `$(Build.ArtifactStagingDirectory)/temperaturas-app.zip`
     * **Artifact name**: `drop`
     * **Artifact publish location**: `Azure Pipelines`

4. Haga clic en el botón superior **Save & queue**, seleccione **Save** (y opcionalmente ejecute para comprobar que todo compila, pasa las pruebas de seguridad y crea el artefacto).

---

### Paso 3: Crear los Variable Groups (Grupos de Variables) para los Ambientes
Para separar la configuración por entornos, utilizaremos el módulo centralizado de Azure DevOps.

1. Vaya a **Pipelines > Library** en el menú izquierdo.
2. Haga clic en **+ Variable group**.
3. **Grupo de Variable 1 (Desarrollo)**:
   * **Variable group name**: `Meteo-Config-Dev`
   * Agregue las variables:
     * `DB_HOST` = `dev-db-colombia.internal`
     * `DB_USER` = `dev_inm_user`
     * `DB_PASSWORD` = `D3vS3cur3P@ssw0rd!` (Haga clic en el icono del **candado** para protegerla).
     * `API_ENV` = `Desarrollo`
   * Haga clic en **Save**.
4. **Grupo de Variable 2 (Producción)**:
   * Cree un nuevo grupo con el nombre `Meteo-Config-Prod`.
   * Agregue las variables:
     * `DB_HOST` = `prod-db-colombia.database.windows.net`
     * `DB_USER` = `prod_inm_admin`
     * `DB_PASSWORD` = `Pr0dS3cur3P@ssw0rd!2026` (Haga clic en el icono del **candado** para protegerla).
     * `API_ENV` = `Produccion`
   * Haga clic en **Save**.

---

### Paso 4: Crear el Classic Release Pipeline (CD)
El despliegue se realizará a dos servidores virtuales Ubuntu independientes alojados en Azure (uno asignado a **Desarrollo** y otro a **Producción**).

#### 1. Estructura Inicial del Release:
1. En Azure DevOps, vaya a **Pipelines > Releases** y haga clic en **New pipeline**.
2. Seleccione **Empty job** para la primera etapa.
3. Nombre de la etapa: Cambie `Stage 1` por **Desarrollo**.
4. Haga clic en **+ Add an artifact** (Agregar origen de artefacto):
   * **Source type**: `Build`.
   * **Project**: Seleccione su proyecto.
   * **Source (build pipeline)**: Seleccione el pipeline de compilación clásico creado en el Paso 2.
   * **Default version**: `Latest`.
   * Haga clic en **Add**.

#### 2. Configurar Etapas y Aprobaciones (DevSecOps):
1. **Etapa Desarrollo**:
   * Haga clic en los detalles del stage **Desarrollo** y luego en la pestaña de configuración del mismo.
2. **Etapa Producción**:
   * En la pantalla principal del release, presione **+ Add** al lado de la etapa Desarrollo para crear una nueva etapa.
   * Seleccione **Empty job** y asígnele el nombre **Producción**.
   * **Aprobación Previa (Gatekeeper de Seguridad)**: En el círculo de pre-condición de la etapa **Producción** (el icono de rayo/persona al lado izquierdo del bloque), active **Pre-deployment approvals**.
   * Añada a un usuario (por ejemplo, usted mismo) como aprobador obligatorio. Esta es una buena práctica crítica en DevSecOps para impedir el paso inmediato a entornos productivos sin autorización.

#### 3. Vincular los Variable Groups por Stage:
1. Haga clic en la pestaña **Variables** (en la parte superior del editor de releases) y seleccione **Variable groups**.
2. Haga clic en **Link variable group**.
3. Seleccione `Meteo-Config-Dev`.
   * **Scope**: Limite el alcance seleccionando únicamente la etapa **Desarrollo**.
4. Vuelva a hacer clic en **Link variable group** y seleccione `Meteo-Config-Prod`.
   * **Scope**: Limite el alcance seleccionando únicamente la etapa **Producción**.
*(De esta forma, cada entorno resolverá las variables dinámicamente con los valores correspondientes al ejecutarse el despliegue).*

---

### Paso 5: Definir las Tareas de Despliegue en las VMs de Azure (Desarrollo y Producción)
Dado que el despliegue es físico sobre dos servidores web Apache en Ubuntu corriendo en Azure, utilizaremos tareas ejecutadas en el contexto de sus agentes de despliegue correspondientes.

*(Nota: Para este laboratorio utilizaremos los directorios locales de despliegue configurados en el Lab 4: `/var/www/html/desarrollo` y `/var/www/html/produccion` como simulación directa de los targets).*

#### Tareas del Stage: **Desarrollo**
1. Haga clic en **Tasks** y seleccione la etapa **Desarrollo**.
2. **Agent job**: Asegúrese de que el pool sea **Pool-OnPremise**.
3. Agregue las siguientes tareas al trabajo:

* **Tarea 1: Extract Files (Extraer archivos)**
  * **Display name**: `Descomprimir Aplicación en /var/www/html/desarrollo`
  * **Archive file patterns**: `**/*.zip`
  * **Destination folder**: `/var/www/html/desarrollo`
  * **Clean destination folder before extracting**: Marcado.

* **Tarea 2: Command Line (Generación segura de Variables de Entorno y Permisos)**
  * **Display name**: `Generar archivo .env y Asegurar Permisos`
  * **Script**:
    ```bash
    # Crear archivo .env usando las variables asignadas por Azure DevOps al grupo
    echo "Inyectando variables de entorno del ambiente Desarrollo..."
    cat <<EOF > /var/www/html/desarrollo/.env
    DB_HOST=$(DB_HOST)
    DB_USER=$(DB_USER)
    DB_PASSWORD=$(DB_PASSWORD)
    API_ENV=$(API_ENV)
    EOF

    # Principio de Privilegio Mínimo (DevSecOps)
    # Restringir los permisos del archivo .env para que solo el propietario y grupo de Apache puedan leerlo
    chmod 640 /var/www/html/desarrollo/.env
    ```

* **Tarea 3: Command Line (Prueba de Humo / Smoke Test de Integridad)**
  * **Display name**: `Ejecutar Prueba de Humo HTTP`
  * **Script**:
    ```bash
    # Realiza una petición local para confirmar que Apache sirve el index sin errores 500
    echo "Validando accesibilidad..."
    sleep 3
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/desarrollo/index.php)
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "¡Smoke Test exitoso! Retorno código HTTP 200"
    else
        echo "¡Smoke Test Fallido! El servidor retornó HTTP $HTTP_CODE"
        exit 1
    fi
    ```

---

#### Tareas del Stage: **Producción**
1. Regrese a la vista del Pipeline y seleccione las tareas del Stage **Producción**.
2. Configure la misma secuencia de tareas que Desarrollo, adaptando los directorios para producción:

* **Tarea 1: Extract Files**
  * **Destination folder**: `/var/www/html/produccion`
  * **Clean destination folder**: Marcado.

* **Tarea 2: Command Line (Configuración y Seguridad en Prod)**
  * **Script**:
    ```bash
    echo "Inyectando variables de entorno del ambiente Producción..."
    cat <<EOF > /var/www/html/produccion/.env
    DB_HOST=$(DB_HOST)
    DB_USER=$(DB_USER)
    DB_PASSWORD=$(DB_PASSWORD)
    API_ENV=$(API_ENV)
    EOF

    chmod 640 /var/www/html/produccion/.env
    ```

* **Tarea 3: Command Line (Prueba de Humo de Producción)**
  * **Script**:
    ```bash
    echo "Validando accesibilidad de Producción..."
    sleep 3
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/produccion/index.php)
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "¡Despliegue a producción verificado y operativo!"
    else
        echo "Error en producción: Retorno HTTP $HTTP_CODE"
        exit 1
    fi
    ```

3. Haga clic en **Save** en la esquina superior derecha para guardar el Release Pipeline.

---

### Paso 6: Prueba del Ciclo Completo (End-to-End)
1. Vaya a su Pipeline CI clásico y ejecute una nueva ejecución de compilación.
2. Espere a que termine y valide en el log la correcta instalación de dependencias, la ejecución de las pruebas unitarias con PHPUnit y los escaneos de seguridad.
3. Una vez finalizado el build, vaya a **Releases** y haga clic en **Create release**.
4. Ingrese el despliegue. Verá que la etapa **Desarrollo** se ejecuta de manera automatizada y finaliza correctamente.
5. Ingrese a la web local: `http://<IP-DE-SU-AGENTE>/desarrollo/index.php`. Seleccione una ciudad y observe cómo recupera los datos dinámicos y muestra la etiqueta `Entorno: Desarrollo`.
6. En Azure DevOps, verá que la etapa **Producción** queda en estado de espera ("Pending approval"). Proceda a aprobar el despliegue manual.
7. Finalizada la ejecución de Producción, acceda a `http://<IP-DE-SU-AGENTE>/produccion/index.php` para verificar el cambio de variables al entorno productivo y la inyección exitosa de contraseñas de forma confidencial.

---

## 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Pruebas y Linter CI** | Validar que PHPUnit y PHP_CodeSniffer se ejecuten dentro del Build y reporten logs detallados. |
| 🔲 | **Escaneo DevSecOps** | Confirmar la descarga y ejecución exitosa de `local-php-security-checker` en el log de compilación. |
| 🔲 | **Desacoplamiento de Variables** | Validar la existencia de los dos Variable Groups con scopes restringidos por ambiente. |
| 🔲 | **Comprobación de Permisos `.env`** | Inspeccionar por consola de comandos en el servidor que los archivos `.env` posean permisos `640` (lectura compartida con el grupo www-data, sin lectura libre a otros usuarios). |
| 🔲 | **Control de Aprobaciones** | Probar que el stage de Producción no se inicie de forma directa hasta que el aprobador asignado lo autorice. |
