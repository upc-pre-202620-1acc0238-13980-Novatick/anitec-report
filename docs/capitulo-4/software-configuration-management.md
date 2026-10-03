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

#### 4.1.3. Source Code Style Guide & Conventions

#### 4.1.4. Software Deployment Configuration
