# 🧪 Laboratorio 4: Instalación y Configuración del Agente Auto-Hospedado (Self-hosted Agent) de Azure Pipelines en Linux Ubuntu

Este laboratorio práctico guía al participante paso a paso en la instalación, configuración e inicialización de un **Agente Auto-Hospedado (Self-hosted Agent)** de Azure Pipelines en un servidor local (on-premises) o virtualizado con **Linux Ubuntu** (versiones 20.04 o 22.04 LTS). Al finalizar, la máquina estará completamente registrada y configurada como agente de compilación y despliegue seguro, con los permisos de sistema optimizados para interactuar con el servidor web **Apache**.

---

## 🎯 Objetivos del Laboratorio
1. Preparar el sistema operativo Ubuntu e instalar los prerrequisitos de compilación y ejecución de software (Apache, PHP, Composer, Git).
2. Crear un Pool de Agentes y generar credenciales seguras (PAT) en Azure DevOps.
3. Descargar, registrar e iniciar el agente de Azure Pipelines como servicio systemd bajo un usuario del sistema dedicado (`azdevops`).
4. Configurar las directrices de red corporativas (proxy y certificados SSL corporativos autofirmados).
5. Implementar un esquema seguro de permisos de carpetas web en Apache (`www-data`) para despliegues automatizados sin privilegios de root.

---

## ⏳ Tiempo Estimado: 60 Minutos

---

## 📋 Pasos Detallados

### Paso 1: Preparación del Servidor Ubuntu (Instalación de Prerrequisitos)
Antes de instalar el agente, debemos asegurar que la máquina cuente con las herramientas necesarias para compilar la aplicación del cliente (PHP y dependencias) y servir el contenido en la web.

1. Conéctese a su servidor Linux Ubuntu por SSH.
2. Actualice los índices de paquetes e instale el servidor web Apache, utilidades de compresión y Git:
   ```bash
   sudo apt update
   sudo apt install -y apache2 git unzip curl ca-certificates
   ```
3. Instale PHP (soporta PHP 7.4 y 8.x) y las extensiones necesarias para conectarse a bases de datos, APIs REST (cURL) y servicios SOAP (XML):
   ```bash
   # Para propósitos de este laboratorio y compatibilidad híbrida de proyectos:
   sudo apt install -y php php-cli php-common php-curl php-xml php-mbstring php-zip php-soap
   ```
4. Instale **Composer** (gestor de dependencias de PHP) globalmente en el sistema:
   ```bash
   curl -sS https://getcomposer.org/installer | php
   sudo mv composer.phar /usr/local/bin/composer
   sudo chmod +x /usr/local/bin/composer
   ```
5. Verifique que las herramientas estén disponibles ejecutando:
   ```bash
   php -v
   composer --version
   apache2 -v
   ```

---

### Paso 2: Crear el Pool de Agentes y Token PAT en Azure DevOps
Para vincular de forma segura la máquina Linux a su organización de Azure DevOps:

1. **Crear el Pool de Agentes**:
   * En la esquina inferior izquierda de Azure DevOps, haga clic en **Organization Settings** (Configuración de la Organización).
   * Vaya a **Pipelines > Agent pools**.
   * Haga clic en **Add pool** en la esquina superior derecha.
   * Configure los datos:
     * **Pool type**: Seleccione **Self-hosted**.
     * **Name**: Ingrese exactamente `Pool-OnPremise`.
     * **Auto-provision**: Marque la opción *Grant access permission to all pipelines* (para permitir que cualquier pipeline pueda solicitar este agente).
   * Haga clic en **Create**.
2. **Generar un Personal Access Token (PAT)**:
   * Haga clic en el icono de su perfil de usuario en la esquina superior derecha y seleccione **Personal access tokens**.
   * Haga clic en **+ New Token**.
   * Configure el token:
     * **Name**: `agente-ubuntu-token`.
     * **Expiration**: Defina la duración que requiera (ej. 30 días).
     * **Scopes**: Seleccione *Custom defined* y, en la lista de abajo, localice **Agent Pools** y marque el permiso de **Read & Manage** (Lectura y Gestión).
   * Haga clic en **Create**.
   * **IMPORTANTE**: Copie el token temporal que se muestra en pantalla y guárdelo en un lugar seguro. No se volverá a mostrar por razones de seguridad.

---

### Paso 3: Descarga, Registro e Instalación del Agente
Por razones de seguridad informática, los agentes nunca deben ser instalados ni ejecutados bajo el usuario `root`. Crearemos un usuario del sistema dedicado con privilegios mínimos.

1. **Crear el usuario del sistema**:
   ```bash
   sudo useradd -m -s /bin/bash azdevops
   sudo passwd azdevops # Defina una contraseña segura para este usuario
   ```
2. **Descargar el agente de Azure Pipelines**:
   Inicie sesión como el usuario `azdevops` y cree un directorio de trabajo:
   ```bash
   sudo su - azdevops
   mkdir myagent && cd myagent
   ```
   Descargue el paquete de instalación oficial (reemplazando el link por la versión más reciente en caso de requerirse):
   ```bash
   wget https://download.agent.dev.azure.com/agent/4.274.1/vsts-agent-linux-x64-4.274.1.tar.gz
   tar zxvf vsts-agent-linux-x64-4.274.1.tar.gz
   ```
3. **Registrar el Agente de forma No Interactiva**:
   Ejecute el script de configuración proporcionando los parámetros configurados en el Paso 2 (reemplace `<URL_DE_SU_ORGANIZACION>` con la URL de su organización, ej. `https://dev.azure.com/mi-empresa-coem` y `<PAT_TOKEN>` con el token guardado):
   ```bash
   ./config.sh --unattended \
     --url "https://dev.azure.com/<URL_DE_SU_ORGANIZACION>" \
     --auth pat \
     --token "<PAT_TOKEN>" \
     --pool "Pool-OnPremise" \
     --agent "Agente-Ubuntu-poc" \
     --work "_work" \
     --acceptTeeAcceptance
   ```
4. **Instalar el Agente como Servicio de Systemd**:
   Para asegurar que el agente se inicie automáticamente si el servidor se reinicia, debemos instalarlo como un servicio daemon.
   Salga del usuario `azdevops` de vuelta a su usuario original con privilegios `sudo`:
   ```bash
   exit
   ```
   Navegue al directorio de instalación del agente y ejecute el instalador del servicio:
   ```bash
   cd /home/azdevops/myagent
   sudo ./svc.sh install azdevops
   ```
   *(Este comando creará de forma automática un archivo de servicio en systemd bajo el formato `vsts.agent.<organizacion>.<pool>.<nombre-agente>.service`).*
5. **Iniciar el servicio del agente**:
   ```bash
   sudo ./svc.sh start
   ```
6. **Verificar el estado del servicio**:
   Puede verificar que esté corriendo de forma exitosa usando el script del agente:
   ```bash
   sudo ./svc.sh status
   ```
   O de forma alternativa utilizando comandos directos de `systemctl`:
   ```bash
   systemctl status vsts.agent.*
   ```
   *(Debería ver el estado como `active (running)` y habilitado para encenderse junto con el sistema).*
7. **Comandos de Administración del Servicio (Opcional)**:
   * **Detener el servicio**: `sudo ./svc.sh stop`
   * **Reiniciar el servicio**: `systemctl restart vsts.agent.*`
   * **Desinstalar el servicio**: `sudo ./svc.sh uninstall`
8. En la consola web de Azure DevOps, vaya a **Organization Settings > Agent pools > Pool-OnPremise > Agents**. Verá el agente `Agente-Ubuntu-poc` en verde y con estado **Online**.

---

### Paso 4: Configuración de Red en Entornos Restringidos (Proxy y Certificados)
Si el servidor del cliente requiere pasar por un proxy corporativo para salir a internet o si el GitLab local usa certificados SSL firmados por una entidad certificadora interna (Enterprise CA):

1. **Configurar Salida a través de Proxy**:
   Navegue al directorio de configuración y cree el archivo oculto `.proxy`:
   ```bash
   sudo -u azdevops nano /home/azdevops/myagent/.proxy
   ```
   Agregue la dirección del proxy en una sola línea:
   ```text
   http://proxy.miempresa.com:8080
   ```
   Si el proxy requiere autenticación:
   ```text
   http://usuario:contraseña@proxy.miempresa.com:8080
   ```
   Reinicie el servicio para aplicar los cambios de red:
   ```bash
   sudo ./svc.sh stop
   sudo ./svc.sh start
   ```
2. **Confianza de Certificados SSL Corporativos Autofirmados (Self-Signed Certificates)**:
   Si el servidor de GitLab On-Premise tiene un certificado SSL firmado por una CA privada, el agente dará un error de conexión HTTPS.
   Copie el archivo de certificado de su CA (ej. `ca.crt`) al directorio de almacenamiento del servidor Ubuntu e incorpórelo al llavero del sistema:
   ```bash
   sudo cp ca.crt /usr/local/share/ca-certificates/enterprise-ca.crt
   sudo update-ca-certificates
   ```
   El agente heredará de manera automática este llavero de confianza del sistema operativo.

---

### Paso 5: Configurar la Estrategia de Permisos para Despliegues en Apache
Para permitir despliegues automáticos seguros, el usuario del agente (`azdevops`) debe tener la capacidad de escribir en el directorio web `/var/www/html/` sin usar el comando `sudo` (lo cual comprometería la seguridad de la máquina al darle acceso total de root al pipeline).

1. **Crear carpetas separadas para los ambientes lógicos**:
   ```bash
   sudo mkdir -p /var/www/html/desarrollo
   sudo mkdir -p /var/www/html/produccion
   ```
2. **Vincular usuarios al grupo de Apache**:
   El grupo del servidor web Apache en Ubuntu es `www-data`. Añadiremos al usuario `azdevops` a este grupo:
   ```bash
   sudo usermod -aG www-data azdevops
   ```
3. **Establecer la pertenencia de las carpetas**:
   Haremos que el usuario `azdevops` sea el propietario de las carpetas de despliegue, y el grupo de Apache (`www-data`) sea el grupo propietario:
   ```bash
   sudo chown -R azdevops:www-data /var/www/html/desarrollo
   sudo chown -R azdevops:www-data /var/www/html/produccion
   ```
4. **Asignar permisos y activar el bit setgid**:
   * Permisos de Lectura, Escritura y Ejecución (7) para el propietario y el grupo, y Lectura y Ejecución (5) para otros:
     ```bash
     sudo chmod -R 775 /var/www/html/desarrollo
     sudo chmod -R 775 /var/www/html/produccion
     ```
   * **Activar el bit setgid (g+s)**: Esto asegura que cualquier nuevo archivo o subdirectorio creado dentro de estas carpetas (por ejemplo, al descomprimir código desde el pipeline) herede de forma automática el grupo propietario `www-data`, previniendo errores de permisos en Apache en futuras ejecuciones:
     ```bash
     sudo chmod g+s /var/www/html/desarrollo
     sudo chmod g+s /var/www/html/produccion
     ```

---

### 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Prerrequisitos Instalados** | Ejecutar `php -v`, `composer --version` y validar que están operativos en la terminal. |
| 🔲 | **Agente en Azure DevOps** | Verificar en *Organization Settings > Agent pools* que `Agente-Ubuntu-Meteo` esté activo e indicado en color verde (Online). |
| 🔲 | **Servicio Systemd Activo** | Ejecutar `sudo ./svc.sh status` y comprobar que el servicio está en ejecución (`active (running)`). |
| 🔲 | **Gobernanza de Permisos** | Comprobar que los archivos creados en `/var/www/html/desarrollo` por el usuario `azdevops` hereden de manera automática el grupo `www-data`. |

Proceda al [**Lab 5**](Lab5_Integracion_GitLab_Hybrid.md) para configurar el pipeline de integración continua, pruebas REST/SOAP y despliegue automatizado hacia el servidor web Apache haciendo uso del agente configurado.

