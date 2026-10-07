<div align="justify">

### 4.1. Software Configuration Management

La configuración del proyecto establece las herramientas y convenciones que utilizará el equipo para desarrollar la aplicación móvil, los servicios del backend y la landing page.

ANITEC contempla Kotlin Multiplatform y Jetpack Compose para la aplicación móvil, Java con Spring Boot para el backend y PostgreSQL para la base de datos central. SQLite se utiliza para conservar información de consulta en el dispositivo. La landing page se publica en GitHub Pages y el backend se aloja en Render. PostgreSQL también se aloja en Render. Swagger UI permite consultar y probar los servicios del backend.

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
| Kotlin Multiplatform     | Compartir lógica de la aplicación entre Android e iOS.                                            | [Documentación](https://kotlinlang.org/docs/home.html)  |
| Android Studio           | Desarrollar la aplicación en Kotlin y probarla en dispositivos o emuladores Android.              | [Descarga](https://developer.android.com/studio)        |
| IntelliJ IDEA            | Desarrollar, ejecutar y depurar el backend de ANITEC con Java y Spring Boot.                      | [Sitio oficial](https://www.jetbrains.com/idea/)        |
| Java Development Kit     | Proporcionar las herramientas necesarias para compilar y ejecutar el backend en Java.             | [Descarga de Eclipse Temurin](https://adoptium.net/)    |
| Spring Boot              | Desarrollar los servicios del backend y aplicar las reglas de negocio.                            | [Sitio oficial](https://spring.io/projects/spring-boot) |
| Spring Initializr        | Generar la estructura inicial del proyecto Spring Boot con sus dependencias.                      | [Generador de proyectos](https://start.spring.io/)      |
| PostgreSQL               | Almacenar la información central de cuentas, animales, vinculaciones, atenciones y suscripciones. | [Descargas](https://www.postgresql.org/download/)       |
| SQLite                   | Conservar en el dispositivo los datos descargados para su consulta sin conexión.                  | [Documentación](https://www.sqlite.org/docs.html)       |
| Jetpack Compose          | Construir la interfaz de Android mediante funciones de interfaz.                                  | [Documentación](https://developer.android.com/compose)  |
| Xcode                    | Compilar y probar el destino iOS en macOS.                                                        | [Sitio oficial](https://developer.apple.com/xcode/)     |

##### Pruebas, seguimiento y publicación

Se propone utilizar las siguientes herramientas durante la implementación.

| Herramienta     | Propósito en ANITEC                                                                       | Enlace                                                                                 |
| --------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| GitHub Projects | Organizar las historias de usuario, las tareas del sprint y sus estados.                  | [Documentación](https://docs.github.com/en/issues/planning-and-tracking-with-projects) |
| Postman         | Enviar solicitudes al backend y revisar sus respuestas durante las pruebas.               | [Descarga](https://www.postman.com/downloads/)                                         |
| JUnit           | Automatizar pruebas de los comportamientos del backend desarrollado en Java.              | [Sitio oficial](https://junit.org/)                                                    |
| GitHub Pages    | Publicar la landing page estática.                                                        | [Documentación](https://docs.github.com/en/pages)                                      |
| Render          | Alojar el backend desarrollado con Java y Spring Boot.                                    | [Documentación](https://render.com/docs)                                               |
| Swagger UI      | Consultar los servicios, sus parámetros y respuestas, y ejecutar solicitudes de prueba.   | [Documentación](https://swagger.io/tools/swagger-ui/)                                  |
| GitHub Actions  | Ejecutar tareas automatizadas del repositorio, incluida la generación del informe en PDF. | [Documentación](https://docs.github.com/en/actions)                                    |

##### Configuración compartida

Cada repositorio incluirá en su README las versiones utilizadas, los requisitos de instalación y los pasos para ejecutar el proyecto. El equipo mantendrá versiones compatibles para facilitar el trabajo conjunto.

Las credenciales de la base de datos y las claves de los servicios externos se configurarán fuera del código publicado. Se incluirán ejemplos de configuración sin datos privados.

El desarrollo y las pruebas de Android se realizan con Android Studio. Kotlin Multiplatform permite compartir lógica con iOS. La compilación y las pruebas de iOS requieren macOS y Xcode. La interfaz compartida, si se utiliza, corresponde a Compose Multiplatform.

#### 4.1.2. Source Code Management

El equipo utiliza Git para registrar los cambios y GitHub para alojar los repositorios y revisar las contribuciones. Los productos de ANITEC se organizan en repositorios separados dentro de la organización NOVATICK.

##### Organización de repositorios

| Producto         | Contenido                                                                              | Repositorio                                                                              |
| ---------------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Informe          | Documentación, diagramas y diseños del proyecto.                                       | [anitec-report](https://github.com/upc-pre-202620-1acc0238-13980-Novatick/anitec-report) |
| Landing page     | Código del sitio de presentación de ANITEC.                                            | Pendiente de incorporar.                                                                 |
| Backend          | Servicios desarrollados con Java y Spring Boot, configuración y pruebas automatizadas. | Pendiente de incorporar.                                                                 |
| Aplicación móvil | Código Kotlin, recursos visuales y pruebas de la aplicación.                           | Pendiente de incorporar.                                                                 |

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

El equipo establece convenciones para mantener el código legible y consistente. Los nombres de clases, métodos, variables, archivos y otros elementos se redactan en inglés y utilizan los términos definidos en el lenguaje del dominio. Los textos visibles para los usuarios se presentan en español.

##### Convenciones generales

- Utilizar nombres descriptivos que indiquen la responsabilidad de cada elemento.
- Mantener el código organizado por contexto y por las capas definidas en el diseño táctico.
- Escribir funciones con una responsabilidad clara.
- Evitar código duplicado, archivos sin uso y bloques de código comentado.
- Agregar comentarios cuando sea necesario explicar una decisión o una regla de negocio.
- Aplicar el formato acordado antes de enviar los cambios a revisión.

##### Backend: Java y Spring Boot

Se toma como referencia Google Java Style Guide.

| Elemento            | Convención                                                 | Ejemplo                    |
| ------------------- | ---------------------------------------------------------- | -------------------------- |
| Clases e interfaces | UpperCamelCase: cada palabra comienza con mayúscula.       | AnimalController           |
| Métodos y variables | lowerCamelCase: la primera palabra comienza con minúscula. | registerAnimal, animalCode |
| Constantes          | Mayúsculas con guiones bajos.                              | DEFAULT_ANIMAL_LIMIT       |
| Paquetes            | Minúsculas, sin guiones ni guiones bajos.                  | livestockmanagement        |
| Archivos Java       | Mismo nombre de la clase principal.                        | AnimalController.java      |

Se utilizan espacios para la indentación, con dos espacios por nivel según la guía adoptada. Los imports se declaran de forma explícita y se eliminan los que no se utilizan.

La organización del backend conserva las responsabilidades de las capas Domain, Application, Interface e Infrastructure. Las reglas del dominio se mantienen separadas de la recepción de solicitudes y del acceso a la base de datos.

##### Aplicación móvil: Kotlin

Se toma como referencia la guía oficial de convenciones de Kotlin.

| Elemento                | Convención                                            | Ejemplo                     |
| ----------------------- | ----------------------------------------------------- | --------------------------- |
| Clases e interfaces     | UpperCamelCase.                                       | AnimalViewModel             |
| Funciones y propiedades | lowerCamelCase.                                       | loadAnimals, selectedAnimal |
| Constantes              | Mayúsculas con guiones bajos.                         | DEFAULT_PAGE_SIZE           |
| Archivos Kotlin         | Nombre descriptivo en UpperCamelCase y extensión .kt. | AnimalViewModel.kt          |
| Paquetes                | Nombres en minúsculas.                                | livestockmanagement         |
| Miembros privados       | Modificador private.                                  | private val repository      |

Se utilizan cuatro espacios por nivel de indentación y el formato de Kotlin de Android Studio. Las funciones de interfaz de Jetpack Compose marcadas con @Composable y que devuelven Unit usan nombres en UpperCamelCase. Kotlin Multiplatform organiza el código compartido y las implementaciones específicas de Android e iOS. Compose Multiplatform permite compartir la interfaz cuando el repositorio incorpora esa configuración.

Los colores y estilos se centralizan para mantener la identidad visual de ANITEC. Las solicitudes al backend y el acceso a SQLite se gestionan fuera de los componentes visuales. Los nombres de las operaciones del dominio se conservan según el diseño táctico y se ajustan sus tipos a Kotlin.

##### Landing page: HTML, CSS y JavaScript

Se toman como referencia las guías de estilo de Google para HTML, CSS y JavaScript.

| Elemento                               | Convención                                                 | Ejemplo        |
| -------------------------------------- | ---------------------------------------------------------- | -------------- |
| Archivos                               | Minúsculas y palabras separadas por guiones.               | main-menu.js   |
| Clases e identificadores de HTML y CSS | Nombres descriptivos en minúsculas, separados por guiones. | feature-card   |
| Variables y funciones de JavaScript    | lowerCamelCase.                                            | toggleMenu     |
| Clases de JavaScript                   | UpperCamelCase.                                            | NavigationMenu |

Se emplean etiquetas HTML que expresen la función del contenido, como header, nav, main y footer. Los estilos y scripts se organizan en archivos separados, y las imágenes informativas incluyen una descripción alternativa.

##### Pruebas de aceptación: Gherkin

Los archivos de pruebas de aceptación utilizan la extensión .feature y nombres descriptivos en inglés, como animal_registration.feature.

Los escenarios se redactan en inglés con la estructura Given, When y Then. Given establece la situación inicial, When describe la acción y Then indica el resultado esperado. And permite agregar condiciones o resultados relacionados.

Cada escenario comprueba un comportamiento concreto y se relaciona con una historia de usuario. Se evitan detalles internos del código para mantener el enfoque en las reglas y resultados del sistema.

##### Referencias

- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- [Google HTML/CSS Style Guide](https://google.github.io/styleguide/htmlcssguide.html)
- [Google JavaScript Style Guide](https://google.github.io/styleguide/jsguide.html)
- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)

#### 4.1.4. Software Deployment Configuration

La landing page de ANITEC se publica en GitHub Pages y el backend desarrollado con Java y Spring Boot se aloja en Render. PostgreSQL conserva la información central y SQLite los datos locales de consulta. La aplicación móvil accede al backend mediante una dirección pública con HTTPS.

##### Distribución de los productos

| Producto                   | Tecnología                     | Destino                                                    |
| -------------------------- | ------------------------------ | ---------------------------------------------------------- |
| Landing page               | HTML, CSS y JavaScript         | GitHub Pages.                                              |
| Backend                    | Java y Spring Boot             | Render.                                                    |
| Base de datos central      | PostgreSQL                     | Render.                                                    |
| Aplicación móvil           | Kotlin Multiplatform / Compose | Android e iOS, según el avance de cada plataforma.         |
| Almacenamiento local       | SQLite                         | Almacenamiento privado de la aplicación en el dispositivo. |
| Documentación de servicios | Swagger UI y OpenAPI           | Dirección configurada para la documentación del backend.   |

Se utiliza Kotlin Multiplatform para la estrategia Android e iOS y Jetpack Compose en Android. Las pruebas y el alcance completado por plataforma se documentan en el Sprint 1. Compartir lógica no implica que todas las pantallas o integraciones estén implementadas y probadas en ambas plataformas.

##### Configuración del despliegue

La landing page se publica mediante GitHub Pages desde su repositorio y se comprobará que sus páginas, imágenes y enlaces puedan consultarse desde el navegador.

El backend se aloja en Render y se compila desde su repositorio y se configurará con los datos de conexión a PostgreSQL y las credenciales de los servicios externos. Las contraseñas y claves se mantendrán fuera del código publicado.

La base de datos central permitirá el acceso del backend. La aplicación móvil realizará sus operaciones a través de los servicios del backend, sin conectarse directamente a PostgreSQL.

En la aplicación móvil se configurará la dirección del backend publicado. SQLite conservará los datos descargados para su consulta local.

##### Comprobaciones previstas

Antes de presentar el despliegue se comprobarán los siguientes aspectos:

- Acceso a la landing page y funcionamiento de sus enlaces.
- Disponibilidad del backend mediante HTTPS.
- Conexión del backend con PostgreSQL.
- Acceso a Swagger UI y correspondencia de su documentación con las operaciones implementadas.
- Ejecución de las operaciones implementadas desde la aplicación o una herramienta de pruebas.
- Configuración de los servicios externos incluidos en el alcance de la entrega.

Las direcciones públicas de GitHub Pages, Render y Swagger UI, el servicio PostgreSQL de Render y las evidencias de funcionamiento se registrarán en el Sprint 1. No se considera comprobado un servicio únicamente por haber elegido su plataforma de alojamiento.
