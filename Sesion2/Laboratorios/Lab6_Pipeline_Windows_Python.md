# 🧪 Laboratorio 6: Pipeline Híbrido, Pruebas y Despliegue en Windows de una Aplicación Python con Simulación Analítica

Este laboratorio práctico guía al participante en la configuración de un Pipeline de Integración y Entrega Continua (CI/CD) en **Azure Pipelines** utilizando un repositorio de **GitLab** como origen de código, con el objetivo de compilar, probar y desplegar una aplicación de **Python** en un servidor de destino **Windows** utilizando un **Agente Auto-Hospedado (Self-hosted Agent)**. 

La aplicación simula la adquisición de datos de un sensor meteorológico periférico, realiza análisis estadístico y genera un **dashboard visual e interactivo en HTML** que muestra los datos procesados en tiempo real.

---

## 🎯 Objetivos del Laboratorio
1. Escribir una aplicación Python structured con simulación de sensor periférico, cálculo de estadísticas y generación de visualización interactiva.
2. Instalar y configurar un **Agente de Azure Pipelines en Windows** ejecutándose como un servicio del sistema.
3. Escribir un pipeline de Azure Pipelines (`azure-pipelines.yml`) que ejecute pruebas unitarias, empaquetate la aplicación y la despliegue en Windows.
4. Automatizar el aprovisionamiento de un entorno virtual de Python (`venv`) en Windows y la ejecución de tareas.
5. Visualizar los datos recolectados y analizados en el navegador web de la máquina Windows.

---

## ⏳ Tiempo Estimado: 60 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Estructurar la Aplicación Python en GitLab
1. En su repositorio de GitLab, cree un nuevo proyecto llamado `adquisicion-datos-python`.
2. Cree los siguientes archivos en la raíz del repositorio:

#### `requirements.txt`
```text
jinja2>=3.0.0
```

#### `src/sensor_acquisition.py`
Este script simula lecturas de un sensor meteorológico periférico (temperatura, humedad y presión), calcula promedios y anomalías, y genera un reporte analítico en HTML interactivo usando Jinja2 y Chart.js.
```python
import os
import random
import json
from datetime import datetime, timedelta
from jinja2 import Template

# Lógica de simulación del sensor periférico
def read_sensor_data(records_count=24):
    data = []
    base_time = datetime.now() - timedelta(hours=records_count)
    
    # Generar lecturas horarias simuladas
    for i in range(records_count):
        timestamp = (base_time + timedelta(hours=i)).strftime("%Y-%m-%d %H:%M:%S")
        # Simulación de curvas de temperatura con ruido aleatorio
        hour = (base_time + timedelta(hours=i)).hour
        temp_base = 14.0 if hour < 6 or hour > 20 else 22.0
        temperature = round(temp_base + random.uniform(-3.0, 3.0), 1)
        humidity = round(random.uniform(40.0, 90.0), 1)
        pressure = round(random.uniform(1008.0, 1018.0), 1)
        
        data.append({
            "timestamp": timestamp,
            "temperature": temperature,
            "humidity": humidity,
            "pressure": pressure
        })
    return data

# Procesar y analizar los datos recolectados
def analyze_data(data):
    temperatures = [r["temperature"] for r in data]
    humidities = [r["humidity"] for r in data]
    pressures = [r["pressure"] for r in data]
    
    avg_temp = round(sum(temperatures) / len(temperatures), 2)
    max_temp = max(temperatures)
    min_temp = min(temperatures)
    
    avg_hum = round(sum(humidities) / len(humidities), 2)
    avg_pres = round(sum(pressures) / len(pressures), 2)
    
    # Identificar anomalías (temperaturas fuera de rango estándar para el cliente)
    anomalies = [r for r in data if r["temperature"] > 24.5 or r["temperature"] < 11.5]
    
    return {
        "avg_temp": avg_temp,
        "max_temp": max_temp,
        "min_temp": min_temp,
        "avg_hum": avg_hum,
        "avg_pres": avg_pres,
        "anomalies_count": len(anomalies),
        "anomalies": anomalies
    }

# Generar el Dashboard Analítico en HTML
def generate_dashboard(data, analysis, output_path="dashboard.html"):
    html_template = """
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Dashboard Analítico - Sensor Periférico</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-900 text-gray-100 min-h-screen p-8">
        <div class="max-w-7xl mx-auto">
            <!-- Encabezado -->
            <header class="mb-8 border-b border-gray-800 pb-6 flex justify-between items-center">
                <div>
                    <h1 class="text-3xl font-extrabold text-blue-400">Administración de Servicios Meteorológicos</h1>
                    <p class="text-gray-400">Análisis y adquisición de datos de sensores locales</p>
                </div>
                <div class="text-right">
                    <span class="px-3 py-1 bg-green-500/20 text-green-400 rounded-full border border-green-500/30 font-semibold">Dispositivo Activo</span>
                    <p class="text-xs text-gray-500 mt-2">Última lectura: {{ last_reading_time }}</p>
                </div>
            </header>

            <!-- Tarjetas de KPIs -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <div class="bg-gray-800 p-6 rounded-lg border border-gray-700">
                    <p class="text-gray-400 text-sm">Temperatura Promedio</p>
                    <p class="text-3xl font-bold text-white mt-2">{{ analysis.avg_temp }} °C</p>
                    <p class="text-xs text-gray-500 mt-1">Min: {{ analysis.min_temp }}°C | Max: {{ analysis.max_temp }}°C</p>
                </div>
                <div class="bg-gray-800 p-6 rounded-lg border border-gray-700">
                    <p class="text-gray-400 text-sm">Humedad Promedio</p>
                    <p class="text-3xl font-bold text-blue-400 mt-2">{{ analysis.avg_hum }} %</p>
                </div>
                <div class="bg-gray-800 p-6 rounded-lg border border-gray-700">
                    <p class="text-gray-400 text-sm">Presión Barométrica</p>
                    <p class="text-3xl font-bold text-yellow-500 mt-2">{{ analysis.avg_pres }} hPa</p>
                </div>
                <div class="bg-gray-800 p-6 rounded-lg border border-gray-700">
                    <p class="text-gray-400 text-sm">Alertas / Anomalías</p>
                    <p class="text-3xl font-bold mt-2 {% if analysis.anomalies_count > 0 %}text-red-500{% else %}text-green-500{% endif %}">
                        {{ analysis.anomalies_count }}
                    </p>
                    <p class="text-xs text-gray-500 mt-1">T > 24.5°C o T < 11.5°C</p>
                </div>
            </div>

            <!-- Gráfico Interactivo -->
            <div class="bg-gray-800 p-6 rounded-lg border border-gray-700 mb-8">
                <h2 class="text-xl font-bold mb-4 text-white">Curva de Lectura de Temperatura (Últimas 24 Horas)</h2>
                <div class="h-96 relative">
                    <canvas id="tempChart"></canvas>
                </div>
            </div>

            <!-- Tabla de Historial y Alertas -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div class="bg-gray-800 p-6 rounded-lg border border-gray-700">
                    <h2 class="text-xl font-bold mb-4 text-white">Últimas Lecturas</h2>
                    <table class="w-full text-left text-sm text-gray-400">
                        <thead>
                            <tr class="border-b border-gray-700 text-gray-300">
                                <th class="pb-2">Hora</th>
                                <th class="pb-2">Temp</th>
                                <th class="pb-2">Humedad</th>
                                <th class="pb-2">Presión</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for r in data[-5:] %}
                            <tr class="border-b border-gray-800 last:border-0 hover:bg-gray-800/50">
                                <td class="py-2">{{ r.timestamp }}</td>
                                <td class="py-2 text-white">{{ r.temperature }} °C</td>
                                <td class="py-2">{{ r.humidity }} %</td>
                                <td class="py-2">{{ r.pressure }} hPa</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>

                <div class="bg-gray-800 p-6 rounded-lg border border-gray-700">
                    <h2 class="text-xl font-bold mb-4 text-red-400">Registro de Alertas Detectadas</h2>
                    {% if analysis.anomalies_count == 0 %}
                    <p class="text-gray-500">No se detectaron desviaciones en las últimas 24 horas.</p>
                    {% else %}
                    <ul class="space-y-2 max-h-60 overflow-y-auto pr-2">
                        {% for a in analysis.anomalies %}
                        <li class="bg-red-500/10 border border-red-500/20 text-red-400 px-4 py-2 rounded text-sm">
                            <strong>{{ a.timestamp }}</strong>: Lectura anómala de temperatura ({{ a.temperature }} °C).
                        </li>
                        {% endfor %}
                    </ul>
                    {% endif %}
                </div>
            </div>
        </div>

        <script>
            const rawData = {{ chart_data_json }};
            const labels = rawData.map(r => r.timestamp.substring(11, 16));
            const temperatures = rawData.map(r => r.temperature);
            const humidities = rawData.map(r => r.humidity);

            const ctx = document.getElementById('tempChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Temperatura (°C)',
                            data: temperatures,
                            borderColor: '#3b82f6',
                            backgroundColor: 'rgba(59, 130, 246, 0.1)',
                            fill: true,
                            tension: 0.3
                        },
                        {
                            label: 'Humedad (%)',
                            data: humidities,
                            borderColor: '#10b981',
                            backgroundColor: 'transparent',
                            fill: false,
                            tension: 0.3
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            grid: { color: '#374151' },
                            ticks: { color: '#9ca3af' }
                        },
                        x: {
                            grid: { color: '#374151' },
                            ticks: { color: '#9ca3af' }
                        }
                    },
                    plugins: {
                        legend: { labels: { color: '#9ca3af' } }
                    }
                }
            });
        </script>
    </body>
    </html>
    """
    
    t = Template(html_template)
    rendered_html = t.render(
        data=data,
        analysis=analysis,
        last_reading_time=data[-1]["timestamp"],
        chart_data_json=json.dumps(data)
    )
    
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(rendered_html)
    print(f"Dashboard generado con éxito en: {os.path.abspath(output_path)}")

if __name__ == "__main__":
    records = read_sensor_data()
    metrics = analyze_data(records)
    generate_dashboard(records, metrics, output_path="dashboard.html")
```

#### `tests/test_acquisition.py`
Prueba de validación del cálculo matemático de las métricas de sensor.
```python
import unittest
from src.sensor_acquisition import analyze_data

class TestSensorAcquisition(unittest.TestCase):
    def test_analysis_math(self):
        # Datos de prueba controlados
        sample_data = [
            {"timestamp": "2026-07-03 12:00:00", "temperature": 10.0, "humidity": 50.0, "pressure": 1010.0},
            {"timestamp": "2026-07-03 13:00:00", "temperature": 20.0, "humidity": 60.0, "pressure": 1012.0},
            {"timestamp": "2026-07-03 14:00:00", "temperature": 30.0, "humidity": 70.0, "pressure": 1014.0}
        ]
        
        analysis = analyze_data(sample_data)
        
        # Validar cálculos promedio, max y min
        self.assertEqual(analysis["avg_temp"], 20.0)
        self.assertEqual(analysis["max_temp"], 30.0)
        self.assertEqual(analysis["min_temp"], 10.0)
        self.assertEqual(analysis["avg_hum"], 60.0)
        self.assertEqual(analysis["avg_pres"], 1012.0)
        
        # Validar alertas (10°C y 30°C están fuera del rango [11.5, 24.5])
        self.assertEqual(analysis["anomalies_count"], 2)

if __name__ == "__main__":
    unittest.main()
```

---

### Paso 2: Registrar un Agente Auto-Hospedado en Windows
Para ejecutar pipelines destinados a servidores Windows del cliente, debemos instalar un agente en una máquina Windows (puede ser su estación de trabajo o una VM en Azure):

1. **Prerrequisito en Windows**:
   * Descargue e instale **Python 3.x** de forma oficial. Asegúrese de marcar la casilla *"Add python.exe to PATH"* durante el asistente de instalación.
2. **Crear las Credenciales**:
   * Utilice el mismo Personal Access Token (PAT) con permisos de **Agent Pools (Read & Manage)** obtenido en el Lab 4.
3. **Instalación del Agente vía PowerShell**:
   * Abra una consola de **PowerShell como Administrador** en su máquina Windows.
   * Ejecute los siguientes comandos para crear la carpeta, descargar el agente de Windows y extraer el contenido:
     ```powershell
     # 1. Crear carpeta
     New-Item -Path "C:\agent" -ItemType Directory
     Set-Location -Path "C:\agent"

     # 2. Descargar el agente de Windows x64
     Invoke-WebRequest -Uri "https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-win-x64-3.220.5.zip" -OutFile "agent.zip"

     # 3. Descomprimir archivos
     Expand-Archive -Path "agent.zip" -DestinationPath "C:\agent"
     Remove-Item -Path "agent.zip"
     ```
4. **Configuración del Agente**:
   Ejecute el comando de registro (reemplace `<URL_ORG>` y `<PAT_TOKEN>`):
   ```powershell
   .\config.cmd --unattended `
     --url "https://dev.azure.com/<URL_ORG>" `
     --auth pat `
     --token "<PAT_TOKEN>" `
     --pool "Pool-OnPremise" `
     --agent "Agente-Windows-Meteo" `
     --work "_work" `
     --runAsService
   ```
5. **Verificar el servicio en Windows**:
   El agente quedará configurado para iniciarse automáticamente como un servicio de Windows. Valide que esté corriendo:
   ```powershell
   Get-Service -Name "vstsagent.*"
   ```
6. En la pestaña **Agent Pools > Pool-OnPremise** en Azure DevOps, confirme que tiene dos agentes online: el de Ubuntu (Lab 4) y el de Windows.

---

### Paso 3: Escribir el Pipeline Multi-Etapa (`azure-pipelines.yml`)
En la raíz de su repositorio GitLab, configure el siguiente archivo `azure-pipelines.yml`:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest' # La etapa de validación inicial puede correr en agentes cloud

stages:
- stage: CI_Build_And_Test
  displayName: 'Integración Continua (Pruebas de Python)'
  jobs:
  - job: PythonCI
    displayName: 'Pruebas Unitarias y Empaquetado'
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '3.10'
      displayName: 'Configurar Python 3.10'

    - script: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
      displayName: 'Instalar Dependencias'

    - script: |
        python -m unittest tests/test_acquisition.py
      displayName: 'Ejecutar Pruebas Unitarias de Adquisición'

    - task: ArchiveFiles@2
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/meteo-python-app.zip'
        replaceExistingArchive: true
      displayName: 'Empaquetar Aplicación en ZIP'

    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Build.ArtifactStagingDirectory)/meteo-python-app.zip'
        artifact: 'python-package'
        publishLocation: 'pipeline'
      displayName: 'Publicar Artefacto Python'

- stage: CD_Deploy_Windows
  displayName: 'Despliegue a Producción (Windows On-Premises)'
  dependsOn: CI_Build_And_Test
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployWindows
    displayName: 'Instalar y Ejecutar en Servidor Windows'
    pool:
      name: 'Pool-OnPremise' # Ejecuta sobre el pool que tiene su agente Windows
      demands:
      - Agent.Name -equals Agente-Windows-Meteo
    environment: 'Windows-Prod-Environment'
    strategy:
      runOnce:
        deploy:
          steps:
          # 1. Descargar el artefacto ZIP generado
          - task: DownloadPipelineArtifact@2
            inputs:
              buildType: 'current'
              artifactName: 'python-package'
              targetPath: '$(Pipeline.Workspace)/drop'
            displayName: 'Descargar Artefacto ZIP'

          # 2. Descomprimir en directorio destino de Windows
          - task: ExtractFiles@1
            inputs:
              archiveFilePatterns: '$(Pipeline.Workspace)/drop/meteo-python-app.zip'
              destinationFolder: 'C:\meteorologia_app'
              cleanDestinationFolder: true
            displayName: 'Extraer en C:\meteorologia_app'

          # 3. Crear Entorno Virtual e Instalar Dependencias en Windows
          - powershell: |
              Set-Location -Path "C:\meteorologia_app"
              # Crear venv si no existe
              if (-not (Test-Path "venv")) {
                  python -m venv venv
              }
              # Instalar dependencias
              .\venv\Scripts\python -m pip install --upgrade pip
              .\venv\Scripts\pip install -r requirements.txt
            displayName: 'Aprovisionar Entorno Virtual Python (venv) en Windows'

          # 4. Ejecutar Simulación Analítica
          - powershell: |
              Set-Location -Path "C:\meteorologia_app"
              .\venv\Scripts\python src/sensor_acquisition.py
            displayName: 'Ejecutar Adquisición y Análisis de Datos del Sensor'
```

---

### Paso 4: Visualización del Análisis de Datos en Windows
Una vez completado el despliegue del pipeline:

1. Ingrese a la máquina Windows.
2. Navegue al directorio de instalación: `C:\meteorologia_app`.
3. Notará que se ha creado un archivo llamado `dashboard.html`.
4. Haga doble clic en el archivo `dashboard.html` para abrirlo en su navegador. Verá un portal con:
   * Tarjetas informativas de temperatura, humedad y presión.
   * Gráficas interactivas mostrando las lecturas del sensor en las últimas 24 horas.
   * Tablas de historial de lecturas y registro detallado de alertas/anomalías detectadas.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Agente Windows Registrado** | Confirmar que el agente de Windows se muestra activo y Online en Azure DevOps. |
| 🔲 | **Validación CI Exitosa** | Comprobar que las pruebas `unittest` de Python pasaron con éxito en la etapa de compilación. |
| 🔲 | **Aprovisionamiento Virtual (venv)** | Verificar en el servidor Windows que la carpeta `C:\meteorologia_app\venv` se creó y tiene Jinja2 instalado. |
| 🔲 | **Visualización de Reporte** | Confirmar que al abrir `dashboard.html` se renderiza el gráfico interactivo y los KPIs correctos calculados por Python. |
