# 🧪 Laboratorio 5: Pipeline Híbrido en Azure Pipelines, Pruebas REST/SOAP y Despliegue en Apache

Este laboratorio práctico guía al participante en la configuración de un Pipeline de Integración y Entrega Continua (CI/CD) en **Azure Pipelines** utilizando un repositorio de **GitLab** como origen de código. Aprenderá a estructurar una aplicación **PHP** de servicios meteorológicos, gestionar configuraciones mediante **Variable Groups**, reutilizar lógica con **YAML Templates**, automatizar pruebas (REST y SOAP) y realizar el despliegue físico automatizado en el servidor web **Apache** utilizando el **Agente Auto-Hospedado** configurado en el Lab 4.

---

## 🎯 Objetivos del Laboratorio
1. Estructurar una aplicación PHP con lógica de negocio y pruebas automáticas REST/SOAP en GitLab.
2. Configurar una conexión de servicio (Service Connection) en Azure DevOps hacia GitLab.
3. Crear y configurar **Variable Groups** para los ambientes de Desarrollo y Producción.
4. Escribir un **YAML Template** reutilizable para ejecutar las pruebas unitarias y funcionales.
5. Diseñar un pipeline multi-etapa en Azure Pipelines que compile, pruebe, empaquete y despliegue automáticamente en la carpeta de Apache utilizando el Agente Auto-Hospedado.

---

## ⏳ Tiempo Estimado: 60 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Estructurar la Aplicación PHP en GitLab
1. En su repositorio de GitLab, cree un nuevo proyecto llamado `servicios-meteorologicos`.
2. Cree la siguiente estructura de archivos en la raíz del repositorio:

#### `composer.json`
Define las dependencias del proyecto. Usamos `guzzlehttp/guzzle` para llamadas REST y delimitamos `phpunit` únicamente para el ambiente de desarrollo.
```json
{
  "name": "inm/servicios-meteorologicos",
  "description": "API y Clientes de Servicios Meteorológicos del INM",
  "type": "project",
  "require": {
    "php": ">=7.4",
    "guzzlehttp/guzzle": "^7.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^9.5"
  },
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  }
}
```

#### `src/MeteoService.php`
Lógica de negocio simulada que atiende llamadas REST y SOAP.
```php
<?php
namespace App;

class MeteoService {
    // Simula una respuesta de API REST
    public function getTemperaturaREST($ciudad) {
        $ciudades = ['Bogota' => 14.5, 'Medellin' => 22.0, 'Cali' => 28.0];
        if (array_key_exists($ciudad, $ciudades)) {
            return [
                "status" => "success",
                "data" => ["ciudad" => $ciudad, "temperatura" => $ciudades[$ciudad], "unidad" => "C"]
            ];
        }
        return ["status" => "error", "message" => "Ciudad no encontrada"];
    }

    // Simula una respuesta de Servicio SOAP (XML)
    public function getTemperaturaSOAP($xmlPayload) {
        // Validación básica de la estructura XML SOAP
        if (strpos($xmlPayload, 'Envelope') === false || strpos($xmlPayload, 'getTemperaturaRequest') === false) {
            return "SoapFault: Request XML no cumple con el esquema WSDL.";
        }
        
        // Extracción simple de la ciudad en el payload XML
        preg_match('/<ciudad>(.*)<\/ciudad>/', $xmlPayload, $matches);
        $ciudad = $matches[1] ?? 'Bogota';
        
        $temp = ($ciudad === 'Bogota') ? 14.5 : 20.0;
        
        // Respuesta en estructura XML SOAP
        return '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <getTemperaturaResponse xmlns="http://inm.gob.co/meteo">
      <temperatura>' . $temp . '</temperatura>
      <unidad>C</unidad>
    </getTemperaturaResponse>
  </soap:Body>
</soap:Envelope>';
    }
}
```

#### `tests/MeteoTest.php`
Pruebas automáticas (REST y SOAP simuladas) usando PHPUnit.
```php
<?php
use PHPUnit\Framework\TestCase;
use App\MeteoService;

class MeteoTest extends TestCase {
    public function testRESTService() {
        $service = new MeteoService();
        $response = $service->getTemperaturaREST('Bogota');
        $this->assertEquals('success', $response['status']);
        $this->assertEquals(14.5, $response['data']['temperatura']);
    }

    public function testSOAPService() {
        $service = new MeteoService();
        $xmlPayload = '<soap:Envelope><soap:Body><getTemperaturaRequest><ciudad>Bogota</ciudad></getTemperaturaRequest></soap:Body></soap:Envelope>';
        $responseXml = $service->getTemperaturaSOAP($xmlPayload);
        $this->assertStringContainsString('getTemperaturaResponse', $responseXml);
        $this->assertStringContainsString('<temperatura>14.5</temperatura>', $responseXml);
    }
}
```

---

### Paso 2: Configurar Conexión de Servicio GitLab en Azure DevOps
Para que Azure Pipelines pueda descargar su código de GitLab:
1. En Azure DevOps, vaya a **Project Settings > Service Connections**.
2. Haga clic en **New service connection** y seleccione **Other Git** (conector recomendado para instancias locales/on-premise de GitLab).
3. Ingrese los detalles de conexión:
   * **Connection name**: `GitLab-Meteo-Repo`
   * **Git/Clone URL**: La URL de clonación de su repositorio de GitLab (ej: `http://<IP_O_DOMINIO_GITLAB>/root/servicios-meteorologicos.git`).
   * **User name**: Escriba su usuario de GitLab (ej: `root`).
   * **Password/Token**: Su token de acceso personal (PAT) de GitLab con alcances de lectura (`read_repository` y `api`).
4. Haga clic en **Save** y valide que la conexión sea correcta.

---

### Paso 3: Crear los Variable Groups (Grupos de Variables)
1. En Azure DevOps, navegue a **Pipelines > Library**.
2. Haga clic en **+ Variable group**.
3. Cree el grupo para Desarrollo:
   * **Variable group name**: `Meteo-Config-Dev`
   * Añada las variables:
     * `DB_HOST`: `127.0.0.1`
     * `DB_USER`: `db_meteo_dev`
     * `DB_PASSWORD`: `MeteoDev2026!` (haga clic en el candado para marcarla como **secreto**).
     * `API_ENV`: `development`
4. Guarde y cree un segundo grupo para Producción:
   * **Variable group name**: `Meteo-Config-Prod`
   * Añada las variables:
     * `DB_HOST`: `192.168.10.24`
     * `DB_USER`: `db_meteo_prod`
     * `DB_PASSWORD`: `MeteoProdSecurePassword2026!` (márquela como **secreto**).
     * `API_ENV`: `production`
5. Haga clic en **Save**.

---

### Paso 4: Crear la Plantilla Reutilizable (YAML Template)
Creamos una plantilla de tareas para ejecutar las pruebas. Esto encapsula la lógica (como los Task Groups tradicionales) en el pipeline basado en código.

1. En su repositorio de GitLab, cree una carpeta llamada `templates`.
2. Guarde el siguiente archivo como `templates/php-test-steps.yml`:
```yaml
parameters:
  - name: phpVersion
    type: string
    default: '7.4'

steps:
- script: |
    sudo update-alternatives --set php /usr/bin/php${{ parameters.phpVersion }}
    php -v
  displayName: 'Configurar Versión PHP a ${{ parameters.phpVersion }}'

- script: |
    composer install --no-interaction --prefer-dist
  displayName: 'Instalar Dependencias de Desarrollo (CI)'

- script: |
    vendor/bin/phpunit tests/MeteoTest.php
  displayName: 'Ejecutar Pruebas PHPUnit (REST/SOAP)'
```

---

### Paso 5: Escribir el Pipeline Multi-Etapa (`azure-pipelines.yml`)
Cree el archivo principal de orquestación en la raíz de su repositorio de GitLab:

```yaml
trigger:
- develop
- main

resources:
  repositories:
  - repository: gitlab-repo
    type: git
    name: servicios-meteorologicos
    endpoint: GitLab-Meteo-Repo

stages:
- stage: CI_Build
  displayName: 'Integración Continua'
  pool:
    name: 'Pool-OnPremise' # Corre en su pool local configurado en el Lab 4
    demands:
    - Agent.Name -equals Agente-Ubuntu-Meteo
  jobs:
  - job: RunTestsAndPack
    displayName: 'Pruebas y Empaquetado'
    steps:
    # 1. Ejecutar las pruebas usando el template
    - template: templates/php-test-steps.yml
      parameters:
        phpVersion: '7.4'

    # 2. Remover las dependencias de desarrollo para empaquetado limpio
    - script: |
        composer install --no-dev --optimize-autoloader --no-interaction
      displayName: 'Remover Dependencias de Desarrollo'

    # 3. Crear el archivo ZIP (Artefacto)
    - task: ArchiveFiles@2
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/meteo-app.zip'
        replaceExistingArchive: true
      displayName: 'Empaquetar Aplicación en ZIP'

    # 4. Publicar el artefacto en el Pipeline
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Build.ArtifactStagingDirectory)/meteo-app.zip'
        artifact: 'meteo-package'
        publishLocation: 'pipeline'
      displayName: 'Publicar Artefacto de Despliegue'

- stage: CD_Deploy_Dev
  displayName: 'Despliegue a Desarrollo (On-Premises)'
  dependsOn: CI_Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  variables:
  - group: Meteo-Config-Dev # Enlaza el grupo de variables de Dev
  jobs:
  - deployment: DeployDev
    displayName: 'Desplegar en Apache Desarrollo'
    pool:
      name: 'Pool-OnPremise'
      demands:
      - Agent.Name -equals Agente-Ubuntu-Meteo
    environment: 'Dev-Environment'
    strategy:
      runOnce:
        deploy:
          steps:
          # 1. Descargar el artefacto generado
          - task: DownloadPipelineArtifact@2
            inputs:
              buildType: 'current'
              artifactName: 'meteo-package'
              targetPath: '$(Pipeline.Workspace)/drop'
            displayName: 'Descargar Artefacto'

          # 2. Descomprimir en la carpeta web (El agente tiene permisos gracias al Lab 4)
          - task: ExtractFiles@1
            inputs:
              archiveFilePatterns: '$(Pipeline.Workspace)/drop/meteo-app.zip'
              destinationFolder: '/var/www/html/desarrollo'
              cleanDestinationFolder: true
            displayName: 'Descomprimir en /var/www/html/desarrollo'

          # 3. Generar el archivo .env de forma dinámica a partir de las variables del grupo
          - script: |
              echo "Creando archivo .env dinámico..."
              echo "DB_HOST=$(DB_HOST)" > /var/www/html/desarrollo/.env
              echo "DB_USER=$(DB_USER)" >> /var/www/html/desarrollo/.env
              echo "DB_PASSWORD=$(DB_PASSWORD)" >> /var/www/html/desarrollo/.env
              echo "API_ENV=$(API_ENV)" >> /var/www/html/desarrollo/.env
              chmod 660 /var/www/html/desarrollo/.env
            displayName: 'Generar e Inyectar Variables de Entorno'

          # 4. Pruebas de Humo (Smoke Test)
          - script: |
              echo "Validando accesibilidad de la aplicación..."
              sleep 2
              RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null http://localhost/desarrollo/src/MeteoService.php)
              if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 404 ]; then
                echo "Servidor Apache respondiendo correctamente (HTTP $RESPONSE)."
              else
                echo "Error de conectividad HTTP $RESPONSE"
                exit 1
              fi
            displayName: 'Ejecutar Pruebas de Humo en Servidor Web Apache'
```

---

### Paso 6: Validar la Ejecución Completa
1. Realice un push en la rama `develop` de GitLab.
2. Siga la ejecución del pipeline en la consola de Azure DevOps.
3. Compruebe que la etapa `CI_Build` corre en su agente de Ubuntu, ejecuta las pruebas y publica el paquete zip.
4. Verifique que la etapa `CD_Deploy_Dev` se detona y completa la extracción de archivos en `/var/www/html/desarrollo`.
5. En la máquina Linux Ubuntu, valide que el archivo `.env` fue generado con las variables del grupo `Meteo-Config-Dev` y que sus permisos de lectura y escritura son estrictos.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Conexión de GitLab** | Comprobar que Azure DevOps descarga correctamente el código del repositorio GitLab del cliente. |
| 🔲 | **Uso del Template YAML** | Confirmar en los logs de compilación que se ejecutó el template de pruebas `php-test-steps.yml` bajo la versión PHP requerida. |
| 🔲 | **Despliegue sin Root** | Validar que el agente ejecutó la descompresión y copia en Apache bajo el usuario `azdevops` (sin elevación de privilegios a sudo). |
| 🔲 | **Inyección de Secretos** | Comprobar que las contraseñas inyectadas en el archivo `.env` coinciden con las del Variable Group y se ocultaron en los logs del pipeline. |
| 🔲 | **Pruebas de Humo Exitosas** | Verificar que la tarea de Smoke Test dio estado exitoso comprobando la conectividad del Apache local en Ubuntu. |

