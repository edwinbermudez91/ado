# 📚 Sesión 2: Estrategia CI/CD e Integración Híbrida

Esta sesión de 4 horas aborda la automatización estratégica de compilaciones y entregas de software. Nos enfocamos en el diseño de Pipelines modernos en YAML, el uso de Feeds privados en **Azure Artifacts** y la arquitectura detallada para integrar de forma segura repositorios corporativos de **GitLab On-Premise** utilizando **Self-Hosted Agents** (Runners).

---

## 🕒 Cronograma de la Sesión

```
00:00 ────────────────── 01:15 ───────────── 02:30 ─────────────────── 03:15 ────────────────────── 04:00
  │ Conceptos Generales     │ Pipelines y     │ Integración Híbrida   │ Buenas Prácticas,           │
  │ de CI/CD: Flujos,       │ Artifacts       │ con GitLab On-Premise:│ Gobernanza y Plan de         │
  │ Ambientes y Aprobación  │ (Estructura)    │ Arquitectura y Red    │ Adopción Gradual            │
```

---

## 📂 Laboratorios de esta Sesión
*   [**Lab 4: Implementación de Pipeline CI/CD con YAML y Artifacts**](Laboratorios/Lab4_Pipelines_Artifacts.md)
*   [**Lab 5: Integración Híbrida con GitLab (Uso de Runners en KodeKloud)**](Laboratorios/Lab5_Integracion_GitLab_Hybrid.md)

---

## 📖 Contenido Teórico y Consultivo

### Módulo 1: Conceptos Generales de CI/CD (75 min)

#### 1. Ciclo de Vida CI/CD y Ambientes Lógicos
El ciclo de CI/CD busca automatizar el flujo desde que el código es modificado por un desarrollador hasta que está operando en Producción.

```
 Desarrollo      Integración Continua (CI)            Entrega Continua (CD)
  ┌──────┐       ┌────────┐    ┌────────┐       ┌────────┐    ┌───────┐    ┌───────┐
  │ Code ├──────►│ Build  ├───►│ Test   ├──────►│ Deploy ├───►│ UAT   ├───►│ Prod  │
  └──────┘       └────────┘    └────────┘       └────────┘    └───────┘    └───────┘
```

*   **Integración Continua (CI)**: Proceso automatizado de compilación, análisis estático de código (SonarQube) y ejecución de pruebas unitarias al hacer cambios en una rama.
*   **Entrega Continua (CD)**: Despliegue automatizado de los artefactos generados en la fase de CI hacia los distintos ambientes (Dev, QA, Stage, Prod).

#### 2. Estrategias de Aprobación y Gobernanza (Environments)
En entornos empresariales, el despliegue automático a producción sin supervisión suele ser riesgoso. Azure DevOps provee el concepto de **Environments** (Entornos):
*   **Aprobaciones Manuales**: Permite asignar a personas o grupos específicos (ej. Líder de QA, Administrador de Infraestructura) que deben validar y autorizar manualmente la ejecución antes de iniciar el despliegue a producción.
*   **Gates (Compuertas Automáticas)**: Ejecutan consultas de salud (ej. validar si hay alertas en Azure Monitor, o si hay incidentes activos en ServiceNow) antes de proceder con el despliegue.

---

### Módulo 2: Estructura de Pipelines y Artifacts (75 min)

#### 1. Anatomía de un Pipeline YAML
Azure DevOps recomienda declarar los pipelines como código en formato **YAML** (guardados en el repositorio) en lugar del modelo clásico visual.

*   **Trigger**: Evento que detona el pipeline (ej. commit en `main`).
*   **Stages**: Divisiones principales del pipeline (ej. Stage de Compilación, Stage de QA, Stage de Prod).
*   **Jobs**: Bloques lógicos de ejecución que corren dentro de un Agente.
*   **Steps/Tasks**: Las acciones secuenciales (ej. instalar SDK, compilar código, copiar archivos).

#### 2. Azure Artifacts
Sirve como gestor de paquetes privado e integrado (npm, NuGet, Maven, Python). Permite almacenar artefactos reutilizables en lugar de guardarlos en el repositorio Git, acelerando sustancialmente el proceso de compilación y asegurando que las librerías compartidas mantengan control de versiones estricto.

---

### Módulo 3: Estrategia de Integración con GitLab On-Premise (45 min)

Cuando el cliente mantiene su código fuente en un servidor **GitLab On-Premise** (dentro de su propio centro de datos o red corporativa privada), se requiere una arquitectura híbrida para compilar y desplegar de manera segura.

#### 1. Arquitectura de Red con Agentes Auto-Hospedados (Self-hosted Runners)
Un error común es creer que para integrar GitLab On-Premise con Azure DevOps o herramientas Cloud se deben abrir puertos entrantes (*Inbound Ports*) en el Firewall corporativo para recibir peticiones externas.

> [!IMPORTANT]
> **Modelo de Comunicación Saliente (Outbound-only)**:
> Los agentes de compilación (GitLab Runners o Azure Pipelines Agents) instalados internamente en la red del cliente **no requieren puertos abiertos de entrada**.
> Los Runners inician la comunicación hacia GitLab mediante peticiones HTTPS salientes periódicas (Long Polling) por el puerto **443**.

```
  ┌──────────────────────────────────────────────┐              ┌────────────────────────┐
  │         Red Interna del Cliente (LAN)        │              │  Nube Pública (Cloud)  │
  │                                              │              │                        │
  │  ┌───────────────┐        ┌───────────────┐  │  Port 443    │  ┌──────────────────┐  │
  │  │ GitLab Server │◄───────┤ GitLab Runner │──┼─────────────►│  │ Azure DevOps /   │  │
  │  │  (On-Premise) │  Local │ (Self-hosted) │  │  Outbound    │  │ GitLab SaaS      │  │
  │  └───────────────┘        └───────────────┘  │              │  └──────────────────┘  │
  └──────────────────────────────────────────────┘              └────────────────────────┘
```

#### 2. Consideraciones de Seguridad y Red Corporativa
Al implementar Runners auto-hospedados dentro de la infraestructura corporativa, se deben aplicar las siguientes medidas de gobernanza:
*   **Aislamiento de Recursos**: Los Runners deben ejecutarse en máquinas virtuales dedicadas, no en servidores compartidos con bases de datos u otros servicios de negocio.
*   **Uso de Docker en Runners (Docker-in-Docker)**: Si los pipelines compilan imágenes de contenedores Docker, restrinja el acceso a `/var/run/docker.sock` ya que da privilegios de root sobre el sistema anfitrión.
*   **Servidores Proxy y DNS**: Si la red corporativa utiliza servidores proxy para salir a internet, el Runner debe ser configurado con las variables de entorno `http_proxy`, `https_proxy` y `no_proxy` para permitir la salida segura y el tráfico local sin intermediación.

---

### Módulo 4: Buenas Prácticas de Administración y Adopción (45 min)

1.  **Secretos y Variables**: Nunca almacene contraseñas, llaves de API o firmas digitales en texto plano dentro de su código o archivos YAML. Utilice variables secretas integradas, o integre **Azure Key Vault** / **HashiCorp Vault**.
2.  **Plantillas Reutilizables (Templates)**: Cree pipelines base definidos por el equipo de seguridad y fuércese a que los equipos de desarrollo los incluyan (ej. plantilla para análisis de SonarQube obligatorio).
3.  **Plan de Adopción Progresivo**:
    *   *Fase 1*: Estandarizar el uso de Git y flujos de trabajo (GitFlow).
    *   *Fase 2*: Implementar Builds automatizados (CI) para validar código.
    *   *Fase 3*: Habilitar despliegues automatizados (CD) en ambientes no productivos.
    *   *Fase 4*: Automatizar Producción con gobernanza estricta (Aprobaciones manuales y métricas de calidad).

---

> [!TIP]
> Proceda ahora al [**Lab 4**](Laboratorios/Lab4_Pipelines_Artifacts.md) para configurar su primer Pipeline multi-stage en YAML.
