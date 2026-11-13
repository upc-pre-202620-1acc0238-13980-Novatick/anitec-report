<div align="justify">

## Conclusiones

- La investigación de usuarios y el análisis de requisitos permitieron orientar ANITEC hacia la gestión de información ganadera y la coordinación con veterinarios. Las historias de usuario y el Product Backlog organizaron estas necesidades para su desarrollo progresivo.

- El modelado del dominio permitió definir cinco contextos con responsabilidades diferenciadas: gestión del ganado, atención veterinaria, vinculación veterinaria, suscripciones e identidad y acceso. Este diseño sirve como referencia para revisar y mejorar la implementación.

- Durante TB1 se elaboraron wireframes, mock-ups, diagramas de navegación y un prototipo interactivo en Figma. Estos recursos permiten representar los recorridos de ganaderos y veterinarios antes de completar su implementación en la aplicación móvil.

- La landing page se implementó y publicó en GitHub Pages. Las pruebas manuales comprobaron su navegación y adaptación a distintas pantallas. Los contenidos definitivos de los avisos legales y de contacto permanecen pendientes.

- El backend incorpora operaciones de cuentas, sesiones y gestión del ganado mediante Java, Spring Boot y PostgreSQL. Las evidencias locales muestran resultados satisfactorios en el inicio de sesión, la consulta y actualización de animales y el rechazo de solicitudes sin autenticación.

- En el avance AV2, la aplicación Android incorpora acceso, gestión del ganado, vinculación y visitas mediante los servicios de ANITEC. Las pruebas contra staging comprobaron el registro y la verificación de ambos perfiles, las operaciones de animales, la aceptación de invitaciones y la consulta de una misma visita desde las cuentas de veterinario y ganadero.

- La información del animal se conservó al volver a iniciar sesión, y la baja lógica cambió su estado a inactivo. Estas comprobaciones respaldan las operaciones evaluadas de la API; la compilación y la navegación visual de la aplicación requieren su propia verificación en Android.

- El siguiente incremento debe completar las funciones clínicas y las capacidades previstas de suscripción y consulta sin conexión en la aplicación. También quedan pendientes la investigación de notificaciones en Android e iOS, la revisión integral de la interfaz y las entrevistas de validación con usuarios. La existencia de código o de pruebas automatizadas no reemplaza la evidencia de ejecución de cada recorrido.

</div>
