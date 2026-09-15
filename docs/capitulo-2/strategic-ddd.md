<div align="justify">

### 2.5.1. EventStorming

A partir del Big Picture EventStorming, se profundizó en los procesos de ANITEC mediante la incorporación de comandos, actores, políticas, modelos de lectura, sistemas externos y agregados. Estos elementos permitieron identificar responsabilidades y proponer límites entre los modelos del dominio.

#### 2.5.1.1. Candidate Context Discovery

La identificación de contextos candidatos se desarrolló progresivamente, considerando las operaciones realizadas por los usuarios, las reglas que intervienen y la información necesaria para cada proceso.

##### Comandos y actores

![Comandos y actores](../../assets/images/event-storming/strategic/05-commands-and-actors.jpg)

Se incorporaron comandos, representados mediante notas azules, para identificar las acciones que pueden producir los eventos del dominio. Las notas de actores permiten distinguir quién inicia cada operación.

El ganadero administra sus animales, registra observaciones, gestiona las vinculaciones y solicita cambios en su suscripción. El veterinario acepta o rechaza invitaciones, programa visitas y controles, y registra las atenciones realizadas, sus tratamientos, vacunaciones e indicaciones. Esta distribución diferencia las responsabilidades de ambos segmentos objetivo.

Los tratamientos y las vacunaciones se presentan como registros opcionales asociados a una atención. La programación de controles posteriores depende de la evaluación del veterinario y no implica que estos ya se hayan realizado.

##### Políticas

![Políticas](../../assets/images/event-storming/strategic/06-policies.jpg)

Se añadieron políticas mediante notas lilas para expresar las reacciones automáticas que corresponden ante determinados acontecimientos. Entre ellas se encuentran el envío de un código de verificación después del registro de una cuenta, el envío del correo de invitación y la notificación de nuevas indicaciones o sus modificaciones.

En las suscripciones, la confirmación de un pago inicial válido permite activar los beneficios premium. La cancelación de la renovación conserva dichos beneficios hasta finalizar el período pagado; el vencimiento se aplica cuando termina esa vigencia y no existe una nueva que la sustituya.

Estas políticas permiten diferenciar las acciones automáticas de las decisiones que requieren la intervención del ganadero o del veterinario.

##### Modelos de lectura

![Modelos de lectura](../../assets/images/event-storming/strategic/07-read-models.jpg)

Se incorporaron modelos de lectura, representados mediante notas verdes, para identificar la información que los usuarios necesitan consultar antes de realizar una operación.

Para la gestión del ganado se consideraron el inventario y la ficha del animal. En la vinculación veterinaria se incluyeron las invitaciones pendientes y las vinculaciones activas. Para las atenciones se definieron la agenda de visitas y controles, el historial veterinario del animal y las indicaciones de la atención. Finalmente, los planes disponibles y el estado de suscripción apoyan las decisiones relacionadas con el servicio premium.

Estas vistas presentan información para la consulta y la toma de decisiones. Su aparición en distintos puntos del tablero no implica que sean modelos independientes en cada ubicación.

##### Sistemas externos

![Sistemas externos](../../assets/images/event-storming/strategic/08-external-systems.jpg)

Se identificaron tres servicios externos previstos para apoyar las funcionalidades de ANITEC. Resend participa en el envío de códigos de verificación e invitaciones por correo electrónico. Stripe interviene en el procesamiento de pagos y la gestión de suscripciones. Firebase Cloud Messaging permite enviar notificaciones sobre el registro o la modificación de indicaciones.

Su representación distingue los servicios externos de las responsabilidades propias del dominio. ANITEC mantiene las reglas de autorización, registro y vigencia de beneficios, mientras utiliza estas integraciones para ejecutar operaciones específicas. Un envío aceptado por un proveedor no garantiza que el usuario haya recibido o leído el mensaje.

##### Agregados

![Agregados](../../assets/images/event-storming/strategic/09-aggregates.jpg)

Se propusieron agregados para agrupar información y reglas que deben mantenerse consistentes al procesar los comandos. En esta etapa se identificaron Cuenta, Animal, Vinculación veterinaria, Cita veterinaria, Atención veterinaria y Suscripción.

Cuenta concentra el registro y la verificación del usuario. Animal reúne sus datos y observaciones. Vinculación veterinaria representa el estado de la relación autorizada entre ganadero y veterinario. Cita veterinaria organiza la programación de visitas y controles, mientras que Atención veterinaria agrupa los registros de la atención realizada y sus indicaciones. Suscripción administra el estado y la vigencia del plan contratado.

Las apariciones repetidas de un agregado muestran su participación en distintas operaciones. Estos agregados constituyen una propuesta inicial que se refina al definir las reglas y los límites del modelo.

##### Bounded contexts candidatos

![Bounded contexts candidatos](../../assets/images/event-storming/strategic/10-candidate-bounded-contexts.jpg)

Los elementos del tablero se organizaron en cinco contextos candidatos según sus responsabilidades y conceptos del dominio:

| Bounded context         | Responsabilidad                                                                                       | Agregados candidatos                    |
| ----------------------- | ----------------------------------------------------------------------------------------------------- | --------------------------------------- |
| Identidad y acceso      | Gestionar las cuentas y la verificación del correo electrónico.                                       | Cuenta                                  |
| Gestión del ganado      | Administrar los animales, sus observaciones y el límite de animales activos permitido al ganadero.    | Animal y Capacidad del inventario       |
| Vinculación veterinaria | Gestionar las invitaciones y el estado de la autorización entre ganaderos y veterinarios.             | Vinculación veterinaria                 |
| Atención veterinaria    | Organizar visitas y controles, y registrar las atenciones, tratamientos, vacunaciones e indicaciones. | Cita veterinaria y Atención veterinaria |
| Suscripciones           | Administrar los planes, los resultados de pago y la vigencia de los beneficios premium.               | Suscripción                             |

Durante esta delimitación se incorporó el agregado candidato Capacidad del inventario. Su responsabilidad es representar el límite permitido para el inventario de un ganadero, diferenciándolo de los datos de un animal individual.

Los límites propuestos permiten separar responsabilidades sin perder las relaciones entre los procesos. Representan límites de modelos del dominio y no implican, por sí mismos, un despliegue en servicios independientes.

#### 2.5.1.2. Domain Message Flows Modeling

El tablero de contextos candidatos presentado en el apartado anterior también muestra interacciones entre etiquetas pertenecientes a distintos contextos. Estas conexiones permiten identificar el acontecimiento de origen, la reacción esperada y la responsabilidad del contexto receptor.

##### Actualización del límite de animales

Suscripciones comunica los cambios que afectan al límite permitido en Gestión del ganado. Se identificaron los siguientes flujos:

| Evento de origen en Suscripciones | Política en Gestión del ganado                                                            | Comando receptor                        | Evento resultante                        |
| --------------------------------- | ----------------------------------------------------------------------------------------- | --------------------------------------- | ---------------------------------------- |
| Suscripción premium activada      | Al activar premium, aplicar el límite del plan contratado.                                | Actualizar límite de animales permitido | Límite de animales permitido actualizado |
| Suscripción premium vencida       | Al vencer premium, aplicar el límite del plan gratuito sin eliminar registros existentes. | Actualizar límite de animales permitido | Límite de animales permitido actualizado |

Ambos flujos utilizan el mismo comando, procesado por Capacidad del inventario. La información comunicada debe permitir identificar al ganadero y el límite que corresponde aplicar.

Cada ganadero comienza con el límite del plan gratuito. Antes de registrar un nuevo animal, se comprueba que la cantidad de animales activos sea menor que el límite vigente. Si este disminuye, se conservan los animales existentes y su historial; las nuevas altas se impiden mientras la cantidad de animales activos alcance o supere dicho límite.

El procesamiento debe evitar que un mensaje duplicado o anterior sustituya un límite más reciente. Este requisito se considera para el posterior diseño de la integración.

##### Observación del animal y programación de una visita

El evento «Observación sobre un animal registrada», perteneciente a Gestión del ganado, se relaciona con el comando «Programar visita veterinaria», perteneciente a Atención veterinaria.

Esta conexión representa una posible continuación del proceso mediante la intervención del veterinario. La observación puede motivar la coordinación de una visita, pero no la programa automáticamente ni constituye un requisito para todas las visitas.

La programación debe identificar al animal y al ganadero correspondiente, además de comprobar que el veterinario dispone de una vinculación activa que autorice la operación.

##### Alcance de las conexiones

Las conexiones representadas distinguen las reacciones automáticas, como la actualización del límite del inventario, de las decisiones humanas, como la programación de una visita.

La autorización de la vinculación y la consulta de los datos del animal constituyen dependencias adicionales que deben respetarse al ejecutar las operaciones. No se interpretan como nuevos eventos automáticos ni como acceso directo a los datos internos de otro contexto.

#### 2.5.1.3. Bounded Context Canvases

Los siguientes canvases describen las responsabilidades, comunicaciones y reglas de los cinco contextos candidatos de ANITEC. Las métricas representan objetivos para pruebas con datos simulados, mientras que las preguntas abiertas señalan decisiones pendientes.

##### Gestión del ganado

![Canvas de Gestión del ganado](../../assets/images/event-storming/bounded-context-canvases/01-livestock-management-canvas.jpg)

Administra el inventario del ganadero mediante el registro, actualización y baja de animales, además de sus observaciones. Recibe cambios de Suscripciones para actualizar el límite de animales activos y proporciona datos a Atención veterinaria mediante consultas autorizadas.

Sus reglas conservan los registros y el historial al dar de baja animales o vencer premium. Las nuevas altas requieren capacidad disponible y cada ganadero solo puede modificar su inventario. Las pruebas verificarán estas condiciones; quedan pendientes los límites por plan, los datos obligatorios y la identificación de los animales.

##### Atención veterinaria

![Canvas de Atención veterinaria](../../assets/images/event-storming/bounded-context-canvases/02-veterinary-care-canvas.jpg)

Organiza visitas y controles, y registra las atenciones presenciales con sus tratamientos, vacunaciones e indicaciones. Consulta los datos del animal en Gestión del ganado y la autorización en Vinculación veterinaria. Se propone como contexto central por su aporte a la continuidad de la atención.

Programar una cita no significa haberla realizado: cada control efectuado se registra como una nueva atención. Las indicaciones generan avisos mediante Firebase Cloud Messaging. Se verificarán la autorización y la asociación correcta de registros; quedan pendientes las cancelaciones, las correcciones del historial y el tratamiento de citas tras revocar el acceso.

##### Vinculación veterinaria

![Canvas de Vinculación veterinaria](../../assets/images/event-storming/bounded-context-canvases/03-veterinary-linking-canvas.jpg)

Gestiona las invitaciones y la autorización entre ganaderos y veterinarios. El ganadero invita y puede revocar el acceso; el veterinario destinatario acepta o rechaza. Utiliza Resend para enviar invitaciones y responde a Atención veterinaria sobre el estado de la vinculación.

Las pruebas comprobarán que solo el destinatario responda y que la aceptación o revocación actualice la autorización. Quedan pendientes la vigencia y duplicidad de invitaciones. Además, este canvas requiere incorporar los cambios de Suscripciones y el control del límite de ganaderos vinculados al veterinario.

##### Suscripciones

![Canvas de Suscripciones](../../assets/images/event-storming/bounded-context-canvases/04-subscriptions-canvas.jpg)

Administra los planes de ambos perfiles: el ganadero amplía su límite de animales y el veterinario su límite de vinculaciones activas. Integra Stripe para gestionar pagos y vigencias, y comunica la activación o el vencimiento al contexto responsable de aplicar cada límite.

Un pago inicial válido activa premium. Cancelar la renovación conserva los beneficios hasta finalizar el período pagado. Las pruebas verificarán estos comportamientos y sus comunicaciones; quedan por definir precios, límites, periodicidad y manejo de renovaciones fallidas. La integración del límite veterinario debe completarse en Vinculación veterinaria.

##### Identidad y acceso

![Canvas de Identidad y acceso](../../assets/images/event-storming/bounded-context-canvases/05-identity-and-access-canvas.jpg)

Gestiona las cuentas, sus perfiles y la verificación del correo mediante códigos enviados con Resend. También proporciona información para validar la identidad del usuario. Cada contexto mantiene sus propias comprobaciones de permisos, como la propiedad del inventario o la vinculación activa.

Enviar un código no equivale a verificar el correo: debe comprobarse su validez y asociación con la cuenta. Las pruebas evaluarán el registro y la verificación. Permanecen pendientes la duración y los intentos del código, el inicio de sesión, la recuperación de acceso y la posibilidad de utilizar ambos perfiles.

### 2.5.2. Context Mapping

El Context Map de ANITEC representa las dependencias entre los cinco bounded contexts y sus integraciones externas. La marca U identifica al proveedor de información o capacidades y D al contexto consumidor. Estas relaciones expresan dependencias del modelo, no el orden temporal de las operaciones.

![Context Map de ANITEC](../../assets/images/context-mapping/01-anitec-context-map.jpg)

#### Relaciones entre bounded contexts

| Proveedor (U) | Consumidor (D) | Relación |
| --- | --- | --- |
| Identidad y acceso | Gestión del ganado, Atención veterinaria, Vinculación veterinaria y Suscripciones | Proporciona información para validar la identidad y el perfil. Cada consumidor mantiene sus comprobaciones de permisos. |
| Gestión del ganado | Atención veterinaria | Proporciona datos del animal, su propietario y observaciones para apoyar las atenciones. |
| Vinculación veterinaria | Atención veterinaria | Proporciona el estado de la vinculación para comprobar el acceso del veterinario. |
| Suscripciones | Gestión del ganado | Comunica cambios del plan que determinan el límite de animales activos. |
| Suscripciones | Vinculación veterinaria | Comunica cambios del plan que determinan el límite de vinculaciones activas del veterinario. |

En las cuatro relaciones entre Suscripciones, Gestión del ganado, Vinculación veterinaria y Atención veterinaria se propone el patrón Customer–Supplier. Los responsables del contexto proveedor consideran las necesidades del consumidor al coordinar los contratos y sus cambios. Las relaciones de Identidad y acceso se representan como dependencias U/D, sin asignar un patrón adicional.

La conexión entre Suscripciones y Vinculación veterinaria aparece discontinua porque está pendiente de completar su representación en el canvas y los flujos correspondientes.

#### Integraciones externas

Stripe proporciona el procesamiento de pagos y la información de vigencia utilizada por Suscripciones. Se propone una Anti-Corruption Layer (ACL) del lado de ANITEC para traducir los conceptos y resultados de Stripe al modelo propio, reduciendo su dependencia del formato externo.

Resend permite enviar códigos de verificación e invitaciones desde Identidad y acceso y Vinculación veterinaria, respectivamente. Sus dos apariciones en el diagrama representan el mismo servicio. Firebase Cloud Messaging permite enviar las notificaciones de indicaciones desde Atención veterinaria.

Estas integraciones se muestran como dependencias U/D. El uso de sus servicios no implica una relación Customer–Supplier en el sentido de coordinación entre equipos. Los límites del mapa tampoco requieren que cada contexto se despliegue como un microservicio independiente.

</div>
