# 📚 Sesión 2: Estrategia CI/CD, Integración Híbrida y Despliegues PHP en Ubuntu

Esta sesión de 4 horas aborda la automatización estratégica de compilaciones y entregas de software para aplicaciones en **PHP 7.4 y 8.x** desplegadas en servidores locales (on-premises) **Ubuntu**. Diseñamos una arquitectura híbrida integrada donde el código reside en **GitLab**, el pipeline se orquesta mediante **Azure Pipelines** y los despliegues se ejecutan automáticamente en servidores internos a través de **Agentes Auto-Hospedados (Self-hosted Agents)**.

---

## 🕒 Cronograma de la Sesión

```
00:00 ────────────────── 01:15 ───────────── 02:30 ─────────────────── 03:15 ────────────────────── 04:00
  │ Módulo 1: Ramificación, │ Módulo 2: Reuso │ Módulo 3: Agentes     │ Módulo 4: Ciclo PHP y       │ Módulo 5: DORA,     │
  │ Workflows y Ambientes   │ Variables/YAML  │ Híbridos en Ubuntu    │ Pruebas REST / SOAP         │ Gobernanza y Cierre │
```

---

## 📂 Laboratorios de esta Sesión
*   [**Lab 4: Instalación y Configuración del Agente Auto-Hospedado en Linux Ubuntu**](Laboratorios/Lab4_Pipelines_Artifacts.md)
*   [**Lab 5: Pipeline Híbrido en Azure Pipelines, Pruebas REST/SOAP y Despliegue en Apache**](Laboratorios/Lab5_Integracion_GitLab_Hybrid.md)
*   [**Lab 6: Pipeline Híbrido, Pruebas y Despliegue en Windows de una Aplicación Python**](Laboratorios/Lab6_Pipeline_Windows_Python.md)

---

## 📖 Contenido Teórico y Consultivo

### Módulo 1: Estrategia de Ramas, Workflows y Ambientes (75 min)

#### 1. Estrategias de Ramificación (Branching Strategies)
La estrategia de ramas define cómo los desarrolladores colaboran y cómo el código fluye hacia producción. Para el modelo híbrido del cliente, analizamos dos enfoques:

*   **GitFlow (Recomendado para lanzamientos estructurados)**:
    *   `develop`: Rama de integración de nuevas características. Detona el despliegue automático al ambiente de **Desarrollo**.
    *   `feature/*`: Ramas temporales de desarrollo. Requieren Pull Requests (PR) hacia `develop`.
    *   `release/*`: Preparación de versiones estables.
    *   `main` (o `master`): Código productivo. Cada fusión en esta rama detona el despliegue al ambiente de **Producción** (previo paso por aprobaciones manuales).
    *   `hotfix/*`: Parches rápidos para producción que se fusionan de inmediato en `main` y `develop`.
*   **Trunk-Based Development (Recomendado para alta frecuencia de entregas)**:
    *   Todos los desarrolladores trabajan sobre una única rama troncal (`main`).
    *   Se utilizan ramas de corta duración (< 2 días).
    *   Se mitiga el riesgo de despliegues mediante banderas de características (*Feature Flags*).

```
   [Feature branch]  ───┐ (Pull Request)
                        ▼
   [develop] ───────────────────────────► (CI/CD automático a Desarrollo)
                        │
                        ▼ (Fusión/Release)
   [main]    ───────────────────────────► (CD con Aprobación a Producción)
```

#### 2. Ciclo de Vida Multietapa y Ambientes de Despliegue
En este entorno híbrido, el flujo se divide en etapas claras con responsabilidades definidas:

*   **Ambiente de Desarrollo (Dev)**:
    *   *Objetivo*: Validación funcional rápida por el equipo de ingeniería.
    *   *Disparador*: Automático ante cambios en la rama `develop` (o equivalentes de integración).
    *   *Configuración*: Servidores de prueba con perfiles de depuración activos.
*   **Ambiente de Producción (Prod)**:
    *   *Objetivo*: Entrega de valor a los usuarios finales con alta disponibilidad.
    *   *Disparador*: Fusión en la rama `main`, sujeta a **Aprobación Manual (Manual Approvals)** y políticas de calidad automáticas (*Gates*).
    *   *Configuración*: Servidores endurecidos en seguridad, optimizados para rendimiento y con logs de depuración desactivados.

---

### Módulo 2: Anatomía de Pipelines, Grupos de Variables y Reutilización (75 min)

#### 1. Integración de Repositorios GitLab en Azure Pipelines
Azure Pipelines puede conectarse a repositorios alojados en servidores de GitLab (tanto SaaS como auto-hospedados GitLab Self-Managed) a través de una **Service Connection**.
*   **Triggering**: Azure DevOps instala webhooks en GitLab para recibir notificaciones cuando se realiza un `push` o se crea un Merge Request, desencadenando la ejecución del pipeline YAML en Azure DevOps.

#### 2. Variable Groups (Grupos de Variables) y Secretos
Los secretos y variables de entorno nunca deben almacenarse en texto plano en el repositorio.
*   **Variable Groups (Library)**: Permiten agrupar variables reutilizables a nivel de todo el proyecto de Azure DevOps.
*   **Seguridad y Scoping**:
    *   Es posible enlazar un grupo de variables con **Azure Key Vault** para recuperar secretos dinámicamente en tiempo de ejecución.
    *   Se definen permisos de acceso a nivel de pipeline y restricciones de uso para entornos específicos (ej. el grupo `prod-secrets` solo puede ser consumido por ejecuciones destinadas a `Prod-Environment`).

#### 3. Reutilización: De Task Groups (Clásicos) a YAML Templates (Modernos)
En la interfaz visual clásica de Azure DevOps se utilizaban los *Task Groups* para reutilizar pasos comunes. En pipelines basados en YAML, la mejor práctica de ingeniería es usar **YAML Templates**:

*   **Modularidad**: Los templates permiten empaquetar tareas repetitivas (como instalar dependencias con Composer o ejecutar suites de pruebas unitarias).
*   **Ejemplo de llamada a un Template**:
    ```yaml
    steps:
    - template: templates/php-test-template.yml
      parameters:
        phpVersion: '8.1'
        testType: 'REST'
    ```
*   **Gobernanza**: Los equipos de seguridad pueden crear repositorios dedicados a almacenar templates y forzar a que todos los pipelines consuman dichas plantillas aprobadas.

---

### Módulo 3: Arquitectura Híbrida y Agentes Heterogéneos (Ubuntu y Windows) (45 min)

Cuando los servidores destino son on-premises (locales) o virtuales bajo arquitecturas heterogéneas, se requiere el uso de **Agentes Auto-Hospedados (Self-hosted Agents)** tanto en **Linux Ubuntu** como en **Microsoft Windows**. Ambos agentes permiten ejecutar tareas locales interactuando con la infraestructura del cliente.

```
┌──────────────────────────────────────────────┐              ┌────────────────────────┐
│         Red Interna del Cliente (LAN)        │              │  Nube Pública (Cloud)  │
│                                              │              │                        │
│  ┌───────────────┐        ┌───────────────┐  │  Port 443    │  ┌──────────────────┐  │
│  │ Servidor Web  │◄───────┤ Self-hosted   │──┼─────────────►│  │ Azure DevOps /   │  │
│  │ Apache (PHP)  │  Local │ Agent (Ubuntu)│  │  Outbound    │  │ GitLab SaaS      │  │
│  └───────────────┘        └───────────────┘  │              │  └──────────────────┘  │
└──────────────────────────────────────────────┘              └────────────────────────┘
```

#### 1. Comunicación Saliente Unidireccional (Outbound-only)
*   El agente corre como un servicio daemon en el servidor Ubuntu del cliente.
*   **No requiere puertos de entrada abiertos** en el firewall. Solo requiere conexión saliente HTTPS por el puerto **443** hacia la URL de Azure DevOps (`dev.azure.com`).
*   Utiliza un mecanismo de *Long Polling* para consultar si hay trabajos pendientes de ejecución en la cola del pool de agentes.

#### 2. Configuración Detrás de Proxy Corporativo
Si el servidor del cliente requiere salir por un servidor proxy, configure las variables de entorno correspondientes en el archivo `.env` del agente (`http_proxy`, `https_proxy`, `no_proxy`) o cree archivos de configuración del servicio systemd. Esto asegura que la comunicación HTTPS se enrute correctamente y las direcciones de red locales no pasen por el proxy.

#### 3. Manejo de Certificados de CA Corporativa
Si la red interna utiliza interceptación SSL/TLS o si el GitLab local tiene un certificado SSL privado:
*   El agente debe ser configurado con la variable `SSLCERT` apuntando al llavero de certificados de la entidad certificadora de la empresa (`/etc/ssl/certs`).
*   Esto previene el error común de rechazo de certificados TLS autofirmados.

---

### Módulo 4: Ciclo de Vida de Despliegue PHP y Automatización de Pruebas (45 min)

#### 1. Empaquetado y Artefactos en PHP
PHP es un lenguaje interpretado, por lo que su despliegue consiste en la transferencia y configuración de archivos de código fuente, no en una compilación binaria.
*   **Optimización de Dependencias**: Durante el pipeline de integración (CI), es mandatorio instalar las dependencias con:
    ```bash
    composer install --no-dev --optimize-autoloader
    ```
    Esto excluye librerías de prueba (como PHPUnit) y optimiza el mapa de clases para ejecución rápida en producción.
*   **Generación del Artefacto**: Los archivos de la aplicación y dependencias de producción se empaquetan en un archivo comprimido (`.zip` o `.tar.gz`) que se publica como artefacto del pipeline, garantizando la inmutabilidad de la entrega.

#### 2. Estructura de Directorios y Permisos en Apache (Ubuntu)
Un error crítico en despliegues automatizados es dar permisos de superusuario (`sudo`) al pipeline para escribir en `/var/www/html/` o dejar los permisos abiertos (`777`). La mejor práctica recomendada es:
*   Crear directorios de aplicaciones independientes: `/var/www/html/desarrollo` y `/var/www/html/produccion`.
*   El servicio del agente auto-hospedado debe ejecutarse bajo un usuario local dedicado (ej. `azdevops`).
*   Configurar la pertenencia del grupo al grupo de Apache (`www-data`):
    ```bash
    sudo chown -R azdevops:www-data /var/www/html/desarrollo
    sudo chmod -R 775 /var/www/html/desarrollo
    sudo chmod g+s /var/www/html/desarrollo # Mantiene el grupo en nuevos archivos
    ```
*   Configurar PHP-FPM o Apache para leer los directorios correspondientes.

#### 3. Inyección Dinámica de Configuraciones (`.env`)
Los archivos `.env` o archivos de configuración específicos de la aplicación (ej. bases de datos, llaves de API) no se suben al control de versiones.
*   El pipeline de despliegue (CD) lee las variables del **Variable Group** y escribe de forma dinámica el archivo de configuración en el servidor objetivo justo antes del despliegue final.

#### 4. Estrategia de Pruebas: REST y SOAP
Dado que el cliente cuenta con aplicaciones de servicios meteorológicos que consumen y exponen APIs:

*   **Pruebas REST**:
    *   Se ejecutan llamadas automatizadas utilizando herramientas basadas en Node como **Newman** (ejecutor CLI de colecciones Postman) o scripts PHP usando la biblioteca cURL.
    *   Validan códigos de estado HTTP (200, 201), cabeceras de respuesta y la estructura del payload JSON devuelto.
*   **Pruebas SOAP (Web Services XML)**:
    *   Dado que SOAP depende fuertemente de esquemas XML (WSDL), se estructuran payloads XML usando plantillas y se envían peticiones POST HTTP mediante cURL o mediante el componente nativo de PHP **`SoapClient`**.
    *   Se valida la integridad del XML, la estructura del *Envelope* y la ausencia de *SoapFaults* en la respuesta del servidor.

---

### Módulo 5: Métricas de Despliegue y Gobernanza (DORA) (45 min)

Para medir la madurez DevOps de la organización, se implementa el marco de métricas de **DORA** (DevOps Research and Assessment):

| Métrica DORA | Definición | Aplicación en el Entorno del Cliente |
| :--- | :--- | :--- |
| **Deployment Frequency (DF)** | Qué tan seguido se despliega código con éxito a Producción. | Medido mediante el registro automático de ejecuciones exitosas de la etapa de Producción en Azure Pipelines. Objetivo: Semanal/Diario. |
| **Lead Time for Changes (LT)** | Tiempo total que toma a un commit pasar desde su push inicial hasta estar corriendo en producción. | Calculado a través de la integración de commits de GitLab y la fecha de ejecución del despliegue en Azure DevOps. Objetivo: < 1 día. |
| **Mean Time to Recover (MTTR)** | Tiempo promedio requerido para restaurar el servicio ante una degradación o falla en producción. | Integrado con sistemas de alertas de salud (ej. HTTP Healthcheck). Se mide el tiempo transcurrido hasta un hotfix exitoso. Objetivo: < 1 hora. |
| **Change Failure Rate (CFR)** | El porcentaje de despliegues en producción que resultan en fallas del servicio o requieren corrección inmediata (rollbacks). | Se registra cuántas veces un pipeline de producción requiere un hotfix o rollback directo tras un despliegue. Objetivo: < 15%. |

---

> [!TIP]
> Proceda ahora al [**Lab 4**](Laboratorios/Lab4_Pipelines_Artifacts.md) para iniciar con la instalación y configuración del Agente Auto-Hospedado en su servidor Linux Ubuntu.

