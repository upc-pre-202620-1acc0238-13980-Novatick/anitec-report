<div align="justify">

## Conclusiones

- El desarrollo de ANITEC permitió definir una solución digital orientada a mejorar la gestión de información ganadera y veterinaria, centralizando datos de los animales, observaciones, atenciones, tratamientos, vacunaciones e indicaciones que normalmente pueden encontrarse dispersos o ser difíciles de consultar.

- El proceso de investigación y diseño permitió identificar las principales necesidades de ganaderos y veterinarios, utilizando entrevistas, User Personas, User Task Matrix, Journey Maps y otros artefactos de UX para orientar las funcionalidades de la solución hacia situaciones reales de ambos segmentos.

- La aplicación de Domain-Driven Design permitió dividir el sistema en los bounded contexts **Livestock Management, Veterinary Care, Veterinary Linking, Subscriptions e Identity and Access**, estableciendo responsabilidades específicas y reduciendo el acoplamiento entre las distintas funcionalidades de ANITEC.

- La arquitectura propuesta diferencia las responsabilidades del backend desarrollado con Java y Spring Boot y de la aplicación móvil desarrollada con Flutter, incorporando además mecanismos de persistencia, autenticación, consulta sin conexión e integración con servicios externos según las necesidades de cada bounded context.

- En conjunto, el diseño de ANITEC establece una base organizada y escalable para una plataforma que facilite el seguimiento de los animales y la coordinación entre ganaderos y veterinarios, manteniendo separadas las responsabilidades del negocio y permitiendo ampliar progresivamente sus funcionalidades.