# 🎓 Plataforma de Capacitación: Azure DevOps & GitLab Hybrid Integration

Bienvenido al portal de documentación y laboratorios prácticos diseñado para la capacitación de **Azure DevOps & Integración Híbrida con GitLab**. 

Este espacio está estructurado como una guía completa tanto para el expositor como para los participantes, inspirada en las mejores prácticas de la industria y diseñada bajo la filosofía de "Zero to Hero" (de cero a experto) adaptada a entornos corporativos complejos.

---

## 🎯 Objetivo General
Habilitar a los equipos de ingeniería en el uso efectivo de **Azure DevOps** como plataforma centralizada de gestión, gobernanza y orquestación de entregas (CI/CD), integrando repositorios y runners de **GitLab On-Premise** bajo una arquitectura híbrida segura y eficiente.

---

## 📅 Estructura de la Capacitación

El programa de capacitación consta de dos sesiones de 4 horas cada una, organizadas de la siguiente manera:

### [Sesión 1: Fundamentos, Gobernanza y Navegación Guiada](Sesion1/README.md) (4 Horas)
> **Nivel de Profundidad:** Conocimiento general y navegación guiada.

| Horario | Módulo / Tema | Descripción | Laboratorios Asociados |
| :--- | :--- | :--- | :--- |
| **00:00 - 00:45** | Introducción a la Arquitectura y Licenciamiento | Vista general de Azure DevOps Services vs Server, SLAs, y revisión detallada del modelo de licenciamiento (Basic, Stakeholder, Visual Studio). | Conceptos Teóricos |
| **00:45 - 01:30** | Modelo Operativo Esperado | Estructura organizacional recomendada (Organizaciones, Proyectos, Equipos) y cómo convivir con herramientas externas. | Conceptos Teóricos |
| **01:30 - 02:30** | Validación de Prerrequisitos y Habilitación | Revisión de identidades (Entra ID), conectividad y navegación inicial en la configuración de la organización y proyectos. | [Lab 1: Habilitación y Navegación](Sesion1/Laboratorios/Lab1_Navegacion_Habilitacion.md) |
| **02:30 - 03:30** | Parametrización y Gestión de Proyectos | Gestión ágil con Boards, creación de grupos de seguridad, asignación de permisos (RBAC), herencia y aislamiento de entornos. | [Lab 2: Gestión Ágil con Azure Boards](Sesion1/Laboratorios/Lab2_Gestion_Agil_Azure_Boards.md) <br> [Lab 3: Usuarios, Permisos y Aislamiento](Sesion1/Laboratorios/Lab3_Parametrizacion_Usuarios_Roles.md) |
| **03:30 - 04:00** | Preguntas y Cierre de Sesión | Espacio de debate, aclaración de dudas puntuales y conclusiones de la Sesión 1. | Panel de Discusión |

---

### [Sesión 2: Estrategia CI/CD e Integración Híbrida](Sesion2/README.md) (4 Horas)
> **Nivel de Profundidad:** Estratégico/Consultivo y demostración práctica.

| Horario | Módulo / Tema | Descripción | Laboratorios Asociados |
| :--- | :--- | :--- | :--- |
| **00:00 - 01:15** | Conceptos Generales de CI/CD | Ciclo de vida del software, flujos de trabajo (GitFlow, Trunk-based), ambientes (Dev, QA, Prod) y aprobaciones manuales/Gates. | Conceptos Teóricos |
| **01:15 - 02:30** | Explicación de Pipelines y Artifacts | Pipelines como código (YAML vs Classic), etapas, trabajos, variables y almacenamiento/consumo de paquetes con Azure Artifacts. | [Lab 4: Pipelines YAML y Artifacts](Sesion2/Laboratorios/Lab4_Pipelines_Artifacts.md) |
| **02:30 - 03:15** | Integración Híbrida con GitLab On-Premise | Arquitectura requerida, uso de agentes auto-hospedados (Self-hosted Runners/Agents) en redes internas y consideraciones de seguridad/firewall. | [Lab 5: Integración GitLab con Runners Híbridos](Sesion2/Laboratorios/Lab5_Integracion_GitLab_Hybrid.md) |
| **03:15 - 04:00** | Buenas Prácticas y Adopción Gradual | Seguridad en la ejecución de tareas, plantillas reutilizables, gobernanza, plan de adopción progresivo y Q&A final. | Buenas Prácticas |

---

## 🛠️ Prerrequisitos de la Capacitación

Para participar activamente en las sesiones de laboratorio, asegúrese de cumplir con los siguientes requisitos:

### Para la Sesión 1:
1. **Acceso a un Azure DevOps Organization**: Puede crear una organización gratuita en [Azure DevOps Services](https://dev.azure.com).
2. **Cuenta de Azure / Microsoft Active Directory (Entra ID)**: Opcional, pero recomendado si se desea simular la integración de identidades corporativas.
3. **Navegador Web**: Chrome, Edge o Firefox actualizado.

### Para la Sesión 2:
1. **Instalación de Git y VS Code**: Localmente para editar y sincronizar repositorios.
2. **Cuenta en KodeKloud**: Específicamente acceso al **GitLab Playground** provisto por la plataforma para el desarrollo del [Lab 5](Sesion2/Laboratorios/Lab5_Integracion_GitLab_Hybrid.md).
3. **Docker local o máquina virtual Linux**: Recomendado si desea emular localmente el despliegue del agente auto-hospedado de GitLab o de Azure DevOps.

---

> [!NOTE]
> Toda la documentación está escrita con un enfoque claro en la práctica empresarial, permitiendo que las configuraciones realizadas sirvan de base para la infraestructura productiva final.

> [!TIP]
> Se recomienda leer detenidamente la introducción teórica de cada sesión antes de comenzar los laboratorios prácticos correspondientes.
