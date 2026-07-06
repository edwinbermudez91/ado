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
   Inicie sesión como el usuario `azdevops`:
   ```bash
   sudo su - azdevops
   ```
   Cree un directorio de trabajo para el agente y acceda a él:
   ```bash
   mkdir myagent && cd myagent
   ```
   Descargue el paquete de instalación oficial y descomprímalo:
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
   *(Deberías ver una salida en la consola que indica que el servicio fue creado y habilitado exitosamente).*
5. **Iniciar el servicio del agente**:
   Una vez instalado, arranca el agente:
   ```bash
   sudo ./svc.sh start
   ```
6. **Verificar el estado del servicio**:
   Confirma que ahora figure como instalado y corriendo:
   ```bash
   sudo ./svc.sh status
   ```
   O de forma alternativa utilizando comandos directos de `systemctl`:
   ```bash
   systemctl status vsts.agent.*
   ```
   *(Debería ver el estado como `active (running)` y habilitado para encenderse junto con el sistema).*
7. En la consola web de Azure DevOps, vaya a **Organization Settings > Agent pools > Pool-OnPremise > Agents**. Verá el agente `Agente-Ubuntu-poc` en verde y con estado **Online**.

---

### Paso 4: Confianza de Certificados SSL Corporativos Autofirmados (Self-Signed Certificates) (Opcional / Si Aplica)
Este paso únicamente es necesario si su servidor de GitLab On-Premise utiliza un certificado SSL firmado por una CA privada (entidad certificadora interna). Si está utilizando HTTP o un certificado público de confianza (como el de KodeKloud), puede omitir esta sección.

Si aplica, copie el archivo de certificado de su CA (ej. `ca.crt`) al directorio de almacenamiento del servidor Ubuntu e incorpórelo al llavero de confianza del sistema operativo:
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

### Paso 6: Prueba de Conectividad y Primer Pipeline Híbrido (Opcional)
Para validar que el agente auto-hospedado está operativo, tiene comunicación con su instancia de GitLab y puede procesar tareas enviadas por Azure DevOps, crearemos un pipeline básico de prueba de conectividad.

Dado que GitLab es una instancia local/on-premise en los laboratorios, utilizaremos el editor clásico y la conexión genérica **Other Git**.

#### 1. Prerrequisito: Habilitar la Creación de Pipelines Clásicos (Classic Pipelines)
En organizaciones nuevas de Azure DevOps, la creación de pipelines clásicos visuales viene desactivada por defecto. Debe habilitarse para usar "Other Git":
1. En Azure DevOps, vaya a **Project Settings** (en la esquina inferior izquierda de la pantalla).
2. Bajo la sección **Pipelines**, seleccione **Settings**.
3. Desplácese hacia abajo hasta la sección **General**.
4. Apague (coloque en **Off**) las siguientes dos opciones:
   * **Disable creation of classic build pipelines** (Deshabilitar la creación de pipelines de compilación clásicos).
   * **Disable creation of classic release pipelines** (Deshabilitar la creación de pipelines de liberación clásicos).
5. Recargue la pestaña de su navegador para aplicar los cambios.

#### 2. Crear una Conexión de Servicio hacia GitLab
Antes de que Azure DevOps pueda clonar el repositorio, debe autenticarse frente a GitLab:
1. En Azure DevOps, vaya a **Project Settings > Service connections**.
2. Haga clic en **New service connection**, busque y seleccione **Other Git** en la lista y haga clic en **Next**.
3. Configure los campos de conexión:
   * **Connection name**: Ingrese `GitLab-Connection`.
   * **Git/Clone URL**: Ingrese la URL de clonación de su repositorio de GitLab (ej: `http://gitlab.kodekloud.com/root/poc-inm.git`).
   * **User name**: Escriba su usuario de GitLab (ej: `root`).
   * **Password/Token**: Ingrese un token de acceso personal (PAT) de GitLab con alcances de lectura (`read_repository` y `api`) que puede generar en GitLab desde su perfil de usuario (*Preferences > Access Tokens*).
4. Haga clic en **Save** para registrar la conexión.

#### 3. Crear y Ejecutar el Pipeline de Prueba Clásico
1. Vaya a **Pipelines > Pipelines** en el menú izquierdo de Azure DevOps.
2. Haga clic en **New Pipeline** (o *Create Pipeline*).
3. En la parte inferior de la pantalla "¿Dónde está su código?", haga clic en el enlace **`Use the classic editor`** (Usar el editor clásico).
4. En la pantalla "Select a source", seleccione **Other Git**.
5. Configure la conexión:
   * **Connection**: Seleccione la conexión **`GitLab-Connection`** que creó en el paso anterior.
   * **Default branch...**: Seleccione la rama por defecto de su proyecto (generalmente `main` o `master`).
   * Haga clic en **Continue**.
6. En la pantalla de selección de plantillas ("Select a template"), seleccione **Empty job** (Trabajo vacío) y haga clic en **Apply**.
7. En la pestaña **Tasks**, haga clic en **Pipeline** (arriba a la izquierda de la lista de tareas) para definir dónde se ejecutará el pipeline:
   * **Agent pool**: Seleccione **`Pool-OnPremise`**.
   * **Demands**: Añada una regla haciendo clic en *Add* y configure `Agent.Name` - `equals` - `Agente-Ubuntu-poc`.
8. Haga clic sobre **Agent job 1**, presione el icono **`+`** (Añadir tarea) a la derecha, busque la tarea **Command line** (Línea de comandos) y presione **Add**.
9. Haga clic sobre la tarea **Command Line Script** recién añadida y reemplace el script en la caja de texto con lo siguiente:
   ```bash
   echo "========================================="
   echo "¡Conexión Exitosa con el Agente Local!"
   echo "========================================="
   echo "Usuario que ejecuta las tareas:"
   whoami
   echo "Directorios de trabajo del agente:"
   pwd
   echo "Contenido del repositorio clonado de GitLab:"
   ls -la
   echo "========================================="
   ```
10. Haga clic en el botón desplegable **Save & queue** (Guardar y encolar) en la barra superior, seleccione **Save & queue** y presione **Save and run**.
11. Ingrese a la ejecución y confirme que el trabajo sea tomado por su agente local (`Agente-Ubuntu-poc`) y termine de forma exitosa (en verde). En los logs del pipeline, la salida del script deberá mostrar que el agente clonó con éxito el repositorio de GitLab y se está ejecutando bajo el usuario `azdevops`.

---

## 🎯 Lista de Verificación (Checklist) de Finalización

| Estado | Hito / Tarea a Confirmar | Detalle y Validación Práctica |
| :---: | :--- | :--- |
| 🔲 | **Prerrequisitos Instalados** | Ejecutar `php -v`, `composer --version` y validar que están operativos en la terminal. |
| 🔲 | **Agente en Azure DevOps** | Verificar en *Organization Settings > Agent pools* que `Agente-Ubuntu-poc` esté activo e indicado en color verde (Online). |
| 🔲 | **Servicio Systemd Activo** | Ejecutar `sudo ./svc.sh status` y comprobar que el servicio está en ejecución (`active (running)`). |
| 🔲 | **Gobernanza de Permisos** | Comprobar que los archivos creados en `/var/www/html/desarrollo` por el usuario `azdevops` hereden de manera automática el grupo `www-data`. |

Proceda al [**Lab 5**](Lab5_Integracion_GitLab_Hybrid.md) para configurar el pipeline de integración continua, pruebas REST/SOAP y despliegue automatizado hacia el servidor web Apache haciendo uso del agente configurado.

---

### 🧹 Desmantelamiento y Limpieza (Opcional)
Si al finalizar todos los laboratorios de la sesión desea remover el agente y limpiar los recursos creados tanto en el servidor Linux como en la consola de Azure DevOps, siga estos pasos opcionales:

1. **Detener y desinstalar el servicio de Systemd**:
   Salga de la sesión de `azdevops` si está en ella (`exit`) y, desde su usuario administrador con privilegios `sudo`, ejecute:
   ```bash
   cd /home/azdevops/myagent
   sudo ./svc.sh stop
   sudo ./svc.sh uninstall
   ```
2. **Eliminar el registro en Azure DevOps**:
   * En la consola web de Azure DevOps, vaya a **Organization Settings > Agent pools**.
   * Seleccione el pool **`Pool-OnPremise`** y haga clic en la pestaña **Agents**.
   * Localice su agente `Agente-Ubuntu-poc`, haga clic en los tres puntos (`...`) a la derecha de la fila y seleccione **Delete** (Eliminar).

