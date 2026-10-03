<div align="justify">

### 4.1. Software Configuration Management

La configuración del proyecto establece las herramientas y convenciones que utilizará el equipo para desarrollar la aplicación móvil, los servicios del backend y la landing page.

ANITEC contempla Flutter y Dart para la aplicación móvil, Java con Spring Boot para el backend y MySQL para la base de datos central. SQLite se utiliza para conservar información de consulta en el dispositivo. La landing page se plantea como un sitio estático publicado mediante GitHub Pages.

#### 4.1.1. Software Development Environment Configuration

El entorno de desarrollo de ANITEC reúne las herramientas utilizadas para elaborar los diseños y la documentación, junto con las previstas para implementar y probar la solución.

##### Diseño, documentación y colaboración

| Herramienta        | Propósito en ANITEC                                                                                     | Enlace                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| Git                | Registrar los cambios del código y la documentación mediante commits y ramas.                           | [Sitio oficial](https://git-scm.com/)      |
| GitHub             | Alojar los repositorios, revisar cambios mediante Pull Requests y coordinar la integración del trabajo. | [Sitio oficial](https://github.com/)       |
| GitHub Desktop     | Facilitar las operaciones de control de versiones mediante una interfaz gráfica.                        | [Descarga](https://desktop.github.com/)    |
| Visual Studio Code | Editar los documentos Markdown y los archivos del proyecto.                                             | [Descarga](https://code.visualstudio.com/) |
| Figma              | Elaborar wireframes, mock-ups, diagramas de navegación y el prototipo interactivo.                      | [Sitio oficial](https://www.figma.com/)    |
| Miro               | Organizar el EventStorming y los modelos de análisis del dominio.                                       | [Sitio oficial](https://miro.com/)         |
| Structurizr        | Elaborar los diagramas de arquitectura de software.                                                     | [Sitio oficial](https://structurizr.com/)  |
| PlantUML           | Mantener los diagramas de clases y componentes definidos mediante texto.                                | [Sitio oficial](https://plantuml.com/)     |

##### Desarrollo de la solución

| Herramienta o tecnología | Propósito en ANITEC                                                                               | Enlace                                                  |
| ------------------------ | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Flutter y Dart           | Desarrollar la aplicación móvil para Android e iOS desde una base de código compartida.           | [Instalación](https://docs.flutter.dev/install)         |
| Android Studio           | Configurar las herramientas de Android y utilizar un emulador para ejecutar la aplicación.        | [Descarga](https://developer.android.com/studio)        |
| Xcode                    | Compilar y probar la versión de iOS en un equipo con macOS.                                       | [Sitio oficial](https://developer.apple.com/xcode/)     |
| Java Development Kit     | Proporcionar las herramientas necesarias para compilar y ejecutar el backend en Java.             | [Descarga de Eclipse Temurin](https://adoptium.net/)    |
| Spring Boot              | Desarrollar los servicios del backend y aplicar las reglas de negocio.                            | [Sitio oficial](https://spring.io/projects/spring-boot) |
| Spring Initializr        | Generar la estructura inicial del proyecto Spring Boot con sus dependencias.                      | [Generador de proyectos](https://start.spring.io/)      |
| MySQL                    | Almacenar la información central de cuentas, animales, vinculaciones, atenciones y suscripciones. | [Descargas](https://dev.mysql.com/downloads/)           |
| SQLite                   | Conservar en el dispositivo los datos descargados para su consulta sin conexión.                  | [Documentación](https://www.sqlite.org/docs.html)       |

##### Pruebas, seguimiento y publicación

Se propone utilizar las siguientes herramientas durante la implementación.

| Herramienta     | Propósito en ANITEC                                                                       | Enlace                                                                                 |
| --------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| GitHub Projects | Organizar las historias de usuario, las tareas del sprint y sus estados.                  | [Documentación](https://docs.github.com/en/issues/planning-and-tracking-with-projects) |
| Postman         | Enviar solicitudes al backend y revisar sus respuestas durante las pruebas.               | [Descarga](https://www.postman.com/downloads/)                                         |
| JUnit           | Automatizar pruebas de los comportamientos del backend desarrollado en Java.              | [Sitio oficial](https://junit.org/)                                                    |
| GitHub Pages    | Publicar la landing page estática.                                                        | [Documentación](https://docs.github.com/en/pages)                                      |
| GitHub Actions  | Ejecutar tareas automatizadas del repositorio, incluida la generación del informe en PDF. | [Documentación](https://docs.github.com/en/actions)                                    |

##### Configuración compartida

Cada repositorio incluirá en su README las versiones utilizadas, los requisitos de instalación y los pasos para ejecutar el proyecto. El equipo mantendrá versiones compatibles para facilitar el trabajo conjunto.

Las credenciales de la base de datos y las claves de los servicios externos se configurarán fuera del código publicado. Se incluirán ejemplos de configuración sin datos privados.

El desarrollo y las pruebas de Android podrán realizarse desde Windows. La compilación y las pruebas de iOS requerirán un equipo con macOS y Xcode.

#### 4.1.2. Source Code Management

El equipo utiliza Git para registrar los cambios y GitHub para alojar los repositorios y revisar las contribuciones. Los productos de ANITEC se organizan en repositorios separados dentro de la organización NOVATICK.

##### Organización de repositorios

| Producto         | Contenido                                                                              | Repositorio                                                                              |
| ---------------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Informe          | Documentación, diagramas y diseños del proyecto.                                       | [anitec-report](https://github.com/upc-pre-202620-1acc0238-13980-Novatick/anitec-report) |
| Landing page     | Código del sitio de presentación de ANITEC.                                            | Pendiente de incorporar.                                                                 |
| Backend          | Servicios desarrollados con Java y Spring Boot, configuración y pruebas automatizadas. | Pendiente de incorporar.                                                                 |
| Aplicación móvil | Código Flutter, recursos visuales y pruebas de la aplicación.                          | Pendiente de incorporar.                                                                 |

##### Organización de ramas

Se adopta un flujo de trabajo basado en GitFlow. Cada funcionalidad se desarrolla en una rama independiente y se integra mediante un Pull Request.

| Rama       | Propósito                                                                    | Ejemplo                     |
| ---------- | ---------------------------------------------------------------------------- | --------------------------- |
| main       | Mantener las versiones revisadas y preparadas para su entrega o publicación. | main                        |
| develop    | Integrar los avances del equipo antes de preparar una versión.               | develop                     |
| feature/\* | Desarrollar una funcionalidad o sección del informe.                         | feature/animal-registration |
| release/\* | Preparar una versión y realizar los ajustes necesarios para su entrega.      | release/0.1.0               |
| hotfix/\*  | Corregir un problema urgente de una versión publicada.                       | hotfix/login-error          |

Los nombres de las ramas se escriben en inglés, en minúsculas y con guiones para separar palabras.

Las ramas feature se crean desde develop y regresan a esa rama mediante un Pull Request. Las ramas release se crean desde develop y, al finalizar, se integran en main y develop. Las ramas hotfix parten de main y sus correcciones se incorporan también a develop.

##### Revisión e integración

Antes de abrir un Pull Request, cada integrante revisa sus cambios y ejecuta las comprobaciones correspondientes. En el código se comprueba la compilación y las pruebas relacionadas. En el informe se revisan el contenido, los enlaces y las imágenes.

Otro integrante revisa el Pull Request antes de su integración. Su descripción indica qué se modificó, por qué se realizó el cambio y cómo se comprobó su funcionamiento.

##### Convenciones de commits

Los mensajes siguen la estructura de Conventional Commits:

`tipo(alcance): descripción`

Se redactan en inglés y describen un cambio concreto.

| Tipo     | Uso                                               | Ejemplo                                               |
| -------- | ------------------------------------------------- | ----------------------------------------------------- |
| feat     | Incorporar una funcionalidad.                     | feat(livestock): add animal registration              |
| fix      | Corregir un error.                                | fix(identity): validate expired verification codes    |
| docs     | Actualizar documentación.                         | docs(report): add mobile application mockups          |
| test     | Agregar o actualizar pruebas.                     | test(livestock): cover inventory capacity limit       |
| refactor | Reorganizar código sin cambiar su comportamiento. | refactor(veterinary-care): simplify care registration |
| chore    | Realizar tareas de mantenimiento.                 | chore(project): configure development tools           |
| ci       | Modificar procesos automatizados.                 | ci(report): update PDF generation workflow            |

##### Versionado

Las versiones de cada producto siguen el formato MAJOR.MINOR.PATCH.

| Componente | Criterio                                                    |
| ---------- | ----------------------------------------------------------- |
| MAJOR      | Cambios incompatibles con la versión anterior.              |
| MINOR      | Nuevas funcionalidades compatibles con la versión anterior. |
| PATCH      | Correcciones compatibles con la versión anterior.           |

Durante el desarrollo inicial se utilizarán versiones 0.x.y. Las entregas se identificarán mediante etiquetas como v0.1.0, indicando las funcionalidades y limitaciones de cada versión.

##### Referencias

- [A successful Git branching model](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Versioning](https://semver.org/)

#### 4.1.3. Source Code Style Guide & Conventions

#### 4.1.4. Software Deployment Configuration
