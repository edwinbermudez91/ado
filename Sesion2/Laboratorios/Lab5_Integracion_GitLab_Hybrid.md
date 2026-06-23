# 🧪 Laboratorio 5: Integración Híbrida - Configuración de GitLab Runner (Self-hosted Agent)

Este laboratorio práctico guía al participante en la configuración de un **GitLab Runner auto-hospedado (Self-hosted Agent)** utilizando el entorno de pruebas provisto por **KodeKloud** (u otro entorno Linux local). Aprenderá a registrar el agente, ejecutar un pipeline híbrido y aplicar las directrices de red y seguridad corporativas necesarias para una implementación productiva interna.

---

## 🎯 Objetivos del Laboratorio
1.  Ingresar al KodeKloud GitLab Playground y obtener las credenciales de administración.
2.  Instalar y registrar un **GitLab Runner** en modo local (Shell/Docker) que emule la infraestructura interna (On-Premise) del cliente.
3.  Escribir un archivo `.gitlab-ci.yml` para ejecutar tareas de compilación usando el Runner auto-hospedado.
4.  Comprender y configurar directrices de seguridad de red (proxy, certificados SSL corporativos y puertos del firewall).

---

## ⏳ Tiempo Estimado: 45 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Configuración Inicial del Proyecto en GitLab
1.  Inicie el **GitLab Playground** en **KodeKloud**.
2.  Acceda a la URL de la consola web de GitLab provista por el playground e inicie sesión con las credenciales de Administrador que le indique la interfaz.
3.  Haga clic en el botón **New project** (Nuevo proyecto) > **Create blank project**.
4.  Asigne los siguientes datos:
    *   **Project name**: `gitlab-hybrid-demo`
    *   **Visibility Level**: **Private** (Privado).
5.  Desmarque la opción *Initialize repository with a README* (lo crearemos desde la consola).
6.  Haga clic en **Create project**.

---

### Paso 2: Descarga e Instalación del GitLab Runner (Agente)
En la terminal interactiva de Linux provista por el playground de KodeKloud, realice la instalación del agente de ejecución de GitLab:

1.  Descargue el binario oficial del GitLab Runner para la arquitectura de su sistema (ej. Linux x86-64):
    ```bash
    sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
    ```
2.  Asigne permisos de ejecución al binario:
    ```bash
    sudo chmod +x /usr/local/bin/gitlab-runner
    ```
3.  Cree un usuario del sistema dedicado exclusivamente para ejecutar las tareas del agente (medida de seguridad estándar):
    ```bash
    sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
    ```
4.  Instale el agente como un servicio del sistema:
    ```bash
    sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    sudo gitlab-runner start
    ```
5.  Verifique que el servicio esté corriendo correctamente:
    ```bash
    sudo gitlab-runner status
    ```

---

### Paso 3: Registro del Runner en su Proyecto de GitLab
Para que el Runner local pueda escuchar y ejecutar los pipelines del proyecto privado:

1.  En la interfaz web de GitLab de su proyecto, navegue a **Settings > CI/CD**.
2.  Busque la sección **Runners** y haga clic en **Expand** (Expandir).
3.  Desactive la opción *Enable shared runners for this project* (si está disponible) para forzar el uso exclusivo de su agente auto-hospedado.
4.  Localice la sección **Project runners** y copie la **URL de GitLab** y el **Registration Token** provistos.
5.  En la terminal de KodeKloud, ejecute el comando de registro (reemplace `<URL>` y `<TOKEN>` con los datos copiados de la interfaz):
    ```bash
    sudo gitlab-runner register \
      --non-interactive \
      --url "<URL>" \
      --registration-token "<TOKEN>" \
      --executor "shell" \
      --description "Agente-Hibrido-OnPremise" \
      --tag-list "hibrido,shell" \
      --run-untagged="true"
    ```
6.  Regrese a la interfaz web de GitLab y recargue la página. En la sección **Runners**, deberá ver el nuevo agente registrado con un círculo verde activo al lado de `Agente-Hibrido-OnPremise`.

---

### Paso 4: Ejecución del Pipeline Híbrido
Creamos un pipeline simple para verificar que el Runner local está procesando las tareas.

1.  En la consola web de GitLab del proyecto, haga clic en el icono **+** en la parte superior y seleccione **New file**.
2.  En **File name**, escriba exactamente: `.gitlab-ci.yml`.
3.  Escriba la estructura del pipeline de compilación:
    ```yaml
    stages:
      - build
      - test

    build_job:
      stage: build
      tags:
        - hibrido
      script:
        - echo "Iniciando compilacion de codigo en el agente auto-hospedado..."
        - hostname
        - pwd
        - echo "Compilacion completada con exito."

    test_job:
      stage: test
      tags:
        - hibrido
      script:
        - echo "Ejecutando pruebas de integracion..."
        - echo "Pruebas pasadas."
    ```
4.  Haga clic en **Commit changes** en la parte inferior.
5.  Navegue a **CI/CD > Pipelines** (o **Build > Pipelines**) en el menú izquierdo. Verá el pipeline ejecutándose.
6.  Haga clic en el pipeline y luego en el trabajo `build_job` para ver la consola de salida. Verifique que la salida muestre el nombre del host local (confirmando que se ejecutó en su máquina virtual del playground, no en la nube de GitLab).

---

### Paso 5: Pautas de Red y Seguridad para la Implementación Corporativa (On-Premise)
Cuando replique esta configuración en la infraestructura del cliente, considere las siguientes configuraciones clave:

#### 1. Configuración Detrás de un Servidor Proxy Corporativo
Si los servidores internos requieren un Proxy para comunicarse con el exterior, cree la carpeta de configuración y configure las variables de entorno de salida:
1.  Edite el servicio del runner ejecutando `sudo systemctl edit gitlab-runner` o modificando el archivo `/etc/systemd/system/gitlab-runner.service.d/http-proxy.conf`:
    ```ini
    [Service]
    Environment="HTTP_PROXY=http://proxy.miempresa.com:8080"
    Environment="HTTPS_PROXY=http://proxy.miempresa.com:8080"
    Environment="NO_PROXY=localhost,127.0.0.1,.miempresa.com"
    ```
2.  Reinicie el servicio:
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart gitlab-runner
    ```

#### 2. Gestión de Certificados SSL Corporativos Autofirmados (Self-Signed Certificates)
Si el GitLab On-Premise del cliente usa certificados SSL firmados por una entidad certificadora interna (Enterprise CA):
1.  Copie el archivo de certificado de la CA corporativa (ej. `ca.crt`) al servidor del runner en la ruta `/etc/gitlab-runner/certs/gitlab.miempresa.com.crt` (el nombre del archivo debe coincidir con el nombre de dominio del servidor de GitLab).
2.  El agente leerá automáticamente este certificado al iniciar la comunicación segura por HTTPS TLS, evitando el error *"x509: certificate signed by unknown authority"*.

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Instalación del Agente** | Confirmar que el binario de `gitlab-runner` está activo y corriendo como un servicio del sistema daemon. |
| 🔲 | **Registro en GitLab** | Validar en *Settings > CI/CD > Runners* que el agente aparece registrado con un indicador de estado verde. |
| 🔲 | **Ejecución Local Híbrida** | Asegurar que el pipeline `.gitlab-ci.yml` ejecutó las tareas exitosamente sobre el runner asignado. |
| 🔲 | **Gobernanza de Red/Seguridad** | Comprender la configuración de proxies corporativos y la inyección de la CA privada para el manejo de SSL/TLS. |
