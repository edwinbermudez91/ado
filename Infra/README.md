# Infraestructura de Servidores en Azure con Terraform

Este directorio contiene la configuración de Terraform para desplegar la infraestructura base necesaria para el ambiente POC. Despliega tres servidores virtuales Linux (Ubuntu 22.04 LTS) en Microsoft Azure:
1. **Servidor GitLab**: Para control de versiones y pipelines.
2. **Servidor Dev**: Entorno de Desarrollo.
3. **Servidor Prod**: Entorno de Producción.

---

## 🛠️ Requisitos Previos

Antes de ejecutar los archivos de Terraform, asegúrate de contar con las siguientes herramientas instaladas y configuradas:

1. **Azure CLI**: Instalado y configurado en tu máquina local. [Descargar Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).
2. **Terraform**: Versión `>= 1.0.0` instalada. [Descargar Terraform](https://developer.hashicorp.com/terraform/downloads).
3. **Acceso a Azure**: Una cuenta activa de Azure con permisos suficientes para crear Grupos de Recursos, Redes Virtuales y Máquinas Virtuales.

---

## 🚀 Pasos para la Ejecución

Sigue estos pasos desde esta carpeta (`/Infra`) en tu terminal:

### 1. Iniciar sesión en Azure
Autentícate con tu cuenta de Azure ejecutando:
```bash
az login
```
*Si tienes múltiples suscripciones, asegúrate de seleccionar la correcta:*
```bash
az account set --subscription "NOMBRE_O_ID_DE_TU_SUSCRIPCION"
```

### 2. Inicializar Terraform
Inicializa el directorio de trabajo para descargar el proveedor de Azure (`azurerm`) y configurar el entorno local:
```bash
terraform init
```

### 3. Modificar Variables y Contraseña (Opcional)
Puedes personalizar los valores predeterminados (como la contraseña del administrador, nombres de usuario, o tamaños de VM). 

Para cambiar la contraseña del administrador (`admin_password`), tienes tres opciones recomendadas:

* **Opción A: Usar un archivo `terraform.tfvars` (Recomendado y más seguro)**
  Crea un archivo llamado `terraform.tfvars` dentro del directorio `/Infra` y define la nueva contraseña (este archivo ya está ignorado en el `.gitignore` para no subir datos sensibles):
  ```hcl
  admin_password = "TuNuevaContraseñaSuperSegura123!"
  ```

* **Opción B: Pasar la variable por línea de comandos**
  Puedes especificar la contraseña al ejecutar el plan o el apply:
  ```bash
  terraform plan -var="admin_password=TuNuevaContraseñaSuperSegura123!"
  terraform apply -var="admin_password=TuNuevaContraseñaSuperSegura123!"
  ```

* **Opción C: Modificar directamente el archivo de variables**
  Edita el valor de `default` en la variable `admin_password` dentro de [variables.tf](file:///c:/Users/ebermudez/OneDrive%20-%20Controles%20Empresariales%20SAS/Documents/coem/Soporte/INM/Repositorio/ado/Infra/variables.tf).


### 4. Planificar el despliegue
Genera y revisa el plan de ejecución de Terraform para verificar qué recursos serán creados:
```bash
terraform plan
```

### 5. Aplicar la Infraestructura
Aplica los cambios en Azure. Se te solicitará una confirmación (`yes`):
```bash
terraform apply
```
*Nota: Si prefieres aplicar automáticamente sin confirmación manual:*
```bash
terraform apply -auto-approve
```

---

## 📋 Conectarse a los Servidores

Al finalizar el despliegue exitoso, Terraform mostrará en la terminal los `outputs` con las direcciones IP públicas y comandos de conexión directa SSH.

También puedes consultarlos en cualquier momento ejecutando:
```bash
terraform output
```

**Comandos útiles de conexión:**
* **GitLab VM**: 
  ```bash
  ssh azdevops@<gitlab_public_ip>
  ```
* **Dev VM**: 
  ```bash
  ssh azdevops@<dev_public_ip>
  ```
* **Prod VM**: 
  ```bash
  ssh azdevops@<prod_public_ip>
  ```

---

## 🦊 Instalación de GitLab en el Servidor Aprovisionado

Una vez que la máquina virtual de GitLab (`vm-gitlab`) esté encendida, puedes instalar **GitLab Community Edition (CE)** ejecutando los siguientes comandos en su terminal:

1. **Conéctate al servidor vía SSH:**
   ```bash
   ssh azdevops@<gitlab_public_ip>
   ```

2. **Actualiza los paquetes del sistema e instala dependencias:**
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y
   sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
   ```

3. **Añade el repositorio oficial de GitLab CE:**
   ```bash
   curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
   ```

4. **Instala GitLab CE** (Reemplaza `<gitlab_public_ip>` con la IP pública real de tu VM):
   ```bash
   sudo EXTERNAL_URL="http://<gitlab_public_ip>" apt-get install gitlab-ce
   ```

5. **Obtén la contraseña temporal de administrador (usuario `root`):**
   ```bash
   sudo cat /etc/gitlab/initial_root_password
   ```
   *Nota: Esta contraseña expira en 24 horas. Inicia sesión en `http://<gitlab_public_ip>` y cámbiala de inmediato.*

6. **Cambiar/Restablecer la contraseña de `root` por CLI (Opcional):**
   Si deseas cambiar o restablecer la contraseña del usuario administrador (`root`) directamente desde la consola del servidor en cualquier momento, ejecuta:
   ```bash
   sudo gitlab-rake "gitlab:password:reset[root]"
   ```
   La terminal te solicitará ingresar y confirmar la nueva contraseña.

---

## 🧹 Limpiar Recursos (Destruir)
Si necesitas eliminar por completo toda la infraestructura creada para evitar costos en Azure, ejecuta:
```bash
terraform destroy
```
*(Confirma escribiendo `yes` cuando lo solicite).*

