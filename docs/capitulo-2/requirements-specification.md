<div align="justify">

# 2.4. Requirements specification

## 2.4.1. User Stories

Las historias de usuario de ANITEC describen las necesidades de los ganaderos y veterinarios y el valor que esperan obtener de la solución. Se organizan en siete épicas y se acompañan de criterios de aceptación para comprobar su cumplimiento. También se incluyen historias técnicas y de investigación para abordar las integraciones y las decisiones necesarias para su desarrollo.

### Epics

| Epic ID | Nombre                  | Objetivo                                                                |
| ------- | ----------------------- | ----------------------------------------------------------------------- |
| EP01    | Gestión del ganado      | Mantener el inventario, las fichas y las observaciones de los animales. |
| EP02    | Atención veterinaria    | Organizar visitas y controles y conservar el historial de atenciones.   |
| EP03    | Vinculación veterinaria | Gestionar invitaciones y permisos entre ganaderos y veterinarios.       |
| EP04    | Indicaciones de cuidado | Compartir y consultar las indicaciones de las atenciones.               |
| EP05    | Suscripciones           | Gestionar planes, pagos, vigencia y límites por perfil.                 |
| EP06    | Identidad y acceso      | Gestionar cuentas, verificación y sesiones.                             |
| EP07    | Presentación de ANITEC  | Dar a conocer la solución y facilitar el acceso a sus descargas.        |

Las épicas agrupan necesidades del usuario y no corresponden necesariamente a contextos separados. EP02 y EP04 pertenecen a Atención veterinaria. La consulta sin conexión abarca información de varias épicas.

### EP01: Gestión del ganado

Reglas de datos del inventario

- El código, la especie y el sexo son obligatorios. El sexo admite macho, hembra o desconocido.
- El código es único dentro del inventario de cada ganadero, incluidos los animales dados de baja.
- El nombre, la raza y la fecha de nacimiento son opcionales; esta última no puede ser futura.
- El sistema asigna el propietario, la fecha de registro y el estado activo. Actualizar los datos no cambia el propietario ni reactiva un animal dado de baja.

#### US01: Registrar animal

| Campo       | Contenido                                                                                         |
| ----------- | ------------------------------------------------------------------------------------------------- |
| Story ID    | US01                                                                                              |
| User        | Ganadero                                                                                          |
| Priority    | Alta                                                                                              |
| Epic        | EP01 — Gestión del ganado                                                                         |
| Title       | Registrar animal                                                                                  |
| Description | Como ganadero, quiero registrar mis animales para mantener un inventario organizado de mi ganado. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que el ganadero tiene capacidad disponible según su plan y proporciona los datos obligatorios válidos, cuando solicita registrar un animal, entonces el sistema lo incorpora como activo a su inventario y lo asocia con su cuenta.

- Escenario 2: Límite alcanzado. Dado que la cantidad de animales activos alcanza o supera el límite vigente, cuando el ganadero solicita registrar otro animal, entonces el sistema rechaza el registro e informa que no dispone de capacidad.

- Escenario 3: Datos inválidos. Dado que la solicitud contiene datos obligatorios ausentes o inválidos, o un código ya utilizado en el inventario, cuando el ganadero solicita registrar el animal, entonces el sistema informa los datos que requieren corrección y no crea el registro.

#### US02: Consultar inventario de animales

| Campo       | Contenido                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------------ |
| Story ID    | US02                                                                                             |
| User        | Ganadero                                                                                         |
| Priority    | Alta                                                                                             |
| Epic        | EP01 — Gestión del ganado                                                                        |
| Title       | Consultar inventario de animales                                                                 |
| Description | Como ganadero, quiero consultar mi inventario para conocer los animales registrados y su estado. |

Acceptance Criteria

- Escenario 1: Inventario con registros. Dado que el ganadero tiene animales registrados, cuando consulta su inventario, entonces el sistema devuelve sus animales e identifica cuáles están activos y cuáles están dados de baja.

- Escenario 2: Inventario vacío. Dado que el ganadero no tiene animales registrados, cuando consulta su inventario, entonces el sistema informa que no existen registros.

- Escenario 3: Protección del inventario. Dado que un animal pertenece a otro ganadero, cuando el ganadero consulta su inventario, entonces el sistema excluye ese animal de los resultados.

#### US03: Consultar ficha del animal

| Campo       | Contenido                                                                                                              |
| ----------- | ---------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US03                                                                                                                   |
| User        | Ganadero                                                                                                               |
| Priority    | Alta                                                                                                                   |
| Epic        | EP01 — Gestión del ganado                                                                                              |
| Title       | Consultar ficha del animal                                                                                             |
| Description | Como ganadero, quiero consultar la ficha de un animal para revisar sus datos y las observaciones registradas sobre él. |

Acceptance Criteria

- Escenario 1: Consulta autorizada. Dado que el animal pertenece al ganadero, cuando solicita su ficha, entonces el sistema devuelve sus datos, su estado y las observaciones registradas.

- Escenario 2: Animal dado de baja. Dado que el animal pertenece al ganadero y está dado de baja, cuando solicita su ficha, entonces el sistema permite consultar la información conservada e indica su estado inactivo.

- Escenario 3: Consulta no autorizada. Dado que el animal pertenece a otro ganadero, cuando el usuario solicita su ficha sin autorización, entonces el sistema rechaza la consulta y no revela sus datos.

#### US04: Actualizar datos del animal

| Campo       | Contenido                                                                                                       |
| ----------- | --------------------------------------------------------------------------------------------------------------- |
| Story ID    | US04                                                                                                            |
| User        | Ganadero                                                                                                        |
| Priority    | Alta                                                                                                            |
| Epic        | EP01 — Gestión del ganado                                                                                       |
| Title       | Actualizar datos del animal                                                                                     |
| Description | Como ganadero, quiero actualizar los datos de mis animales para mantener información correcta en el inventario. |

Acceptance Criteria

- Escenario 1: Actualización válida. Dado que el animal pertenece al ganadero y los cambios cumplen las validaciones establecidas, cuando solicita actualizar sus datos, entonces el sistema guarda los cambios y conserva su asociación con el historial existente.

- Escenario 2: Datos inválidos. Dado que la actualización contiene datos inválidos, cuando el ganadero solicita guardarla, entonces el sistema rechaza la operación, informa el motivo y conserva los datos anteriores.

- Escenario 3: Modificación no autorizada. Dado que el animal pertenece a otro ganadero, cuando el usuario solicita modificar sus datos, entonces el sistema rechaza la operación y mantiene el registro sin cambios.

#### US05: Dar de baja a un animal

| Campo       | Contenido                                                                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US05                                                                                                                                          |
| User        | Ganadero                                                                                                                                      |
| Priority    | Alta                                                                                                                                          |
| Epic        | EP01 — Gestión del ganado                                                                                                                     |
| Title       | Dar de baja a un animal                                                                                                                       |
| Description | Como ganadero, quiero retirar un animal de mi inventario activo para mantener actualizado el ganado que administro sin perder su información. |

Acceptance Criteria

- Escenario 1: Baja válida y conservación de información. Dado que el animal está activo y pertenece al ganadero, cuando solicita darlo de baja, entonces el sistema lo marca como inactivo, deja de contabilizarlo para el límite y conserva sus datos, observaciones e historial veterinario.

- Escenario 2: Baja repetida. Dado que el animal ya está inactivo, cuando el ganadero vuelve a solicitar su baja, entonces el sistema informa su estado y no vuelve a reducir la cantidad de animales activos.

- Escenario 3: Baja no autorizada. Dado que el animal pertenece a otro ganadero, cuando el usuario solicita darlo de baja, entonces el sistema rechaza la operación y conserva su estado.

#### US06: Registrar observación sobre un animal

| Campo       | Contenido                                                                                                                                       |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US06                                                                                                                                            |
| User        | Ganadero                                                                                                                                        |
| Priority    | Alta                                                                                                                                            |
| Epic        | EP01 — Gestión del ganado                                                                                                                       |
| Title       | Registrar observación sobre un animal                                                                                                           |
| Description | Como ganadero, quiero registrar observaciones sobre mis animales para conservar información que apoye su seguimiento y la atención veterinaria. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que el animal pertenece al ganadero y la observación contiene una descripción, cuando solicita registrarla, entonces el sistema la guarda como observación del ganadero, asociada al animal, al autor y a la fecha de registro.

- Escenario 2: Observación vacía. Dado que la descripción está vacía o contiene solo espacios, cuando el ganadero solicita registrar la observación, entonces el sistema rechaza la operación e informa que debe proporcionar su contenido.

- Escenario 3: Registro no autorizado. Dado que el animal pertenece a otro ganadero, cuando el usuario solicita registrar una observación, entonces el sistema rechaza la operación y no crea el registro.

Reglas de negocio

- Una observación del ganadero no genera automáticamente una visita ni una atención veterinaria.

### EP02: Atención veterinaria

#### US07: Programar visita veterinaria

| Campo       | Contenido                                                                                                          |
| ----------- | ------------------------------------------------------------------------------------------------------------------ |
| Story ID    | US07                                                                                                               |
| User        | Veterinario                                                                                                        |
| Priority    | Alta                                                                                                               |
| Epic        | EP02 — Atención veterinaria                                                                                        |
| Title       | Programar visita veterinaria                                                                                       |
| Description | Como veterinario, quiero programar visitas para organizar la atención de los animales de los ganaderos vinculados. |

Acceptance Criteria

- Escenario 1: Programación válida. Dado que el veterinario tiene una vinculación activa con el ganadero y el animal pertenece a este, cuando solicita una visita con fecha y hora futuras, entonces el sistema registra la cita asociada al animal, al ganadero y al veterinario.

- Escenario 2: Vinculación inactiva. Dado que el veterinario no tiene una vinculación activa con el ganadero, cuando solicita programar una visita, entonces el sistema rechaza la operación y no crea la cita.

- Escenario 3: Datos de programación inválidos. Dado que el animal no pertenece al ganadero indicado o la fecha y hora no son posteriores al momento actual, cuando el veterinario solicita programar la visita, entonces el sistema rechaza la operación e informa el motivo.

#### US08: Consultar agenda de visitas y controles

| Campo       | Contenido                                                                                         |
| ----------- | ------------------------------------------------------------------------------------------------- |
| Story ID    | US08                                                                                              |
| User        | Veterinario                                                                                       |
| Priority    | Alta                                                                                              |
| Epic        | EP02 — Atención veterinaria                                                                       |
| Title       | Consultar agenda de visitas y controles                                                           |
| Description | Como veterinario, quiero consultar mis visitas y controles programados para organizar mi trabajo. |

Acceptance Criteria

- Escenario 1: Agenda con citas. Dado que el veterinario tiene visitas o controles programados, cuando consulta su agenda para un período, entonces el sistema devuelve las citas de ese período ordenadas por fecha y hora, identificando el animal, el ganadero y el tipo de cita.

- Escenario 2: Período sin citas. Dado que no existen citas del veterinario en el período solicitado, cuando consulta su agenda, entonces el sistema informa que no tiene visitas ni controles programados para esas fechas.

- Escenario 3: Protección de la agenda. Dado que existen citas asignadas a otros veterinarios, cuando el veterinario consulta su agenda, entonces el sistema excluye esas citas.

#### US09: Registrar atención veterinaria

| Campo       | Contenido                                                                                                                   |
| ----------- | --------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US09                                                                                                                        |
| User        | Veterinario                                                                                                                 |
| Priority    | Alta                                                                                                                        |
| Epic        | EP02 — Atención veterinaria                                                                                                 |
| Title       | Registrar atención veterinaria                                                                                              |
| Description | Como veterinario, quiero registrar las atenciones realizadas para conservar información sobre la evaluación de cada animal. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que el veterinario mantiene una vinculación activa con el ganadero y el animal pertenece a este, cuando registra una atención con descripción y fecha no futura, entonces el sistema la guarda en el historial del animal e identifica al veterinario responsable.

- Escenario 2: Datos incompletos o fecha futura. Dado que falta la fecha o la descripción, o que la fecha corresponde a un momento futuro, cuando el veterinario solicita guardar la atención, entonces el sistema rechaza el registro e informa los datos que requieren corrección.

- Escenario 3: Registro sin autorización. Dado que el veterinario no mantiene una vinculación activa con el ganadero, cuando solicita registrar una atención para uno de sus animales, entonces el sistema rechaza la operación.

Reglas de negocio

- Los tratamientos, las vacunaciones y las indicaciones son registros complementarios opcionales; su ausencia no impide registrar una atención válida.
- Una visita o un control programado solo cuenta como atención realizada cuando el veterinario registra la atención correspondiente.
- El registro de la atención de un control genera una nueva atención vinculada a ese control y conserva la atención anterior.

#### US10: Registrar tratamiento realizado

| Campo       | Contenido                                                                                                                           |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US10                                                                                                                                |
| User        | Veterinario                                                                                                                         |
| Priority    | Alta                                                                                                                                |
| Epic        | EP02 — Atención veterinaria                                                                                                         |
| Title       | Registrar tratamiento realizado                                                                                                     |
| Description | Como veterinario, quiero registrar los tratamientos que aplico para conservar evidencia de las intervenciones realizadas al animal. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que existe una atención registrada por el veterinario y este mantiene una vinculación activa con el ganadero, cuando registra la descripción del tratamiento aplicado y su fecha no futura, entonces el sistema guarda el tratamiento asociado a esa atención y al animal correspondiente.

- Escenario 2: Datos inválidos. Dado que falta la descripción o la fecha del tratamiento, o que la fecha es futura, cuando el veterinario solicita registrarlo, entonces el sistema rechaza la operación e informa los datos que requieren corrección.

- Escenario 3: Asociación no autorizada. Dado que la atención pertenece a otro veterinario o no existe una vinculación activa con el ganadero, cuando el usuario solicita agregar un tratamiento, entonces el sistema rechaza la operación.

#### US11: Registrar vacunación aplicada

| Campo       | Contenido                                                                                                                    |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US11                                                                                                                         |
| User        | Veterinario                                                                                                                  |
| Priority    | Alta                                                                                                                         |
| Epic        | EP02 — Atención veterinaria                                                                                                  |
| Title       | Registrar vacunación aplicada                                                                                                |
| Description | Como veterinario, quiero registrar las vacunas que aplico para mantener actualizado el historial de vacunaciones del animal. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que existe una atención registrada por el veterinario y este mantiene una vinculación activa con el ganadero, cuando registra el nombre de la vacuna y su fecha de aplicación no futura, entonces el sistema guarda la vacunación asociada a esa atención y al animal correspondiente.

- Escenario 2: Datos inválidos. Dado que falta el nombre de la vacuna o la fecha de aplicación, o que la fecha es futura, cuando el veterinario solicita registrar la vacunación, entonces el sistema rechaza la operación e informa los datos que requieren corrección.

- Escenario 3: Asociación no autorizada. Dado que la atención pertenece a otro veterinario o no existe una vinculación activa con el ganadero, cuando el usuario solicita agregar una vacunación, entonces el sistema rechaza la operación.

#### US12: Programar control veterinario

| Campo       | Contenido                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------- |
| Story ID    | US12                                                                                                          |
| User        | Veterinario                                                                                                   |
| Priority    | Alta                                                                                                          |
| Epic        | EP02 — Atención veterinaria                                                                                   |
| Title       | Programar control veterinario                                                                                 |
| Description | Como veterinario, quiero programar controles posteriores a una atención para revisar la evolución del animal. |

Acceptance Criteria

- Escenario 1: Programación válida. Dado que existe una atención registrada del animal y el veterinario mantiene una vinculación activa con su ganadero, cuando solicita programar un control con fecha y hora futuras, entonces el sistema guarda la cita relacionada con la atención de origen.

- Escenario 2: Datos de programación inválidos. Dado que la atención indicada no existe, corresponde a otro animal o la fecha y hora solicitadas no son futuras, cuando el veterinario solicita programar el control, entonces el sistema rechaza la operación e informa el motivo.

- Escenario 3: Vinculación inactiva. Dado que el veterinario no mantiene una vinculación activa con el ganadero, cuando solicita programar un control para uno de sus animales, entonces el sistema rechaza la operación.

#### US13: Consultar historial veterinario del animal

| Campo       | Contenido                                                                                                                                                         |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US13                                                                                                                                                              |
| User        | Ganadero y veterinario                                                                                                                                            |
| Priority    | Alta                                                                                                                                                              |
| Epic        | EP02 — Atención veterinaria                                                                                                                                       |
| Title       | Consultar historial veterinario del animal                                                                                                                        |
| Description | Como ganadero o veterinario autorizado, quiero consultar el historial veterinario de un animal para conocer sus atenciones y apoyar la continuidad de su cuidado. |

Acceptance Criteria

- Escenario 1: Consulta autorizada. Dado que el usuario es el ganadero propietario o un veterinario con vinculación activa con este, y el animal tiene atenciones registradas, cuando consulta su historial, entonces el sistema devuelve las atenciones ordenadas por fecha con sus tratamientos, vacunaciones e indicaciones asociados, incluso si el animal está dado de baja.

- Escenario 2: Historial vacío. Dado que el usuario tiene autorización y el animal no tiene atenciones registradas, cuando consulta su historial, entonces el sistema informa que todavía no existen atenciones.

- Escenario 3: Consulta no autorizada. Dado que el usuario no es el propietario ni un veterinario con vinculación activa, cuando solicita el historial, entonces el sistema rechaza la consulta y no revela su contenido.

### EP03: Vinculación veterinaria

#### US14: Enviar invitación de vinculación

| Campo       | Contenido                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------- |
| Story ID    | US14                                                                                                          |
| User        | Ganadero                                                                                                      |
| Priority    | Alta                                                                                                          |
| Epic        | EP03 — Vinculación veterinaria                                                                                |
| Title       | Enviar invitación de vinculación                                                                              |
| Description | Como ganadero, quiero invitar a un veterinario para autorizar su participación en el cuidado de mis animales. |

Acceptance Criteria

- Escenario 1: Invitación válida. Dado que el correo corresponde a un veterinario registrado y no existe una invitación pendiente ni una vinculación activa entre ambos, cuando el ganadero envía la invitación, entonces el sistema la registra como pendiente y solicita su envío por correo.

- Escenario 2: Solicitud inválida. Dado que el destinatario no es un veterinario registrado o ya existe una invitación pendiente o vinculación activa entre ambos, cuando el ganadero intenta invitarlo, entonces el sistema rechaza la solicitud e informa el motivo.

- Escenario 3: Fallo en el correo. Dado que la invitación queda registrada pero el servicio de correo rechaza el envío, cuando el sistema recibe ese resultado, entonces conserva la invitación pendiente e informa que no se confirma el envío del correo.

#### US15: Responder invitación de vinculación

| Campo       | Contenido                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------- |
| Story ID    | US15                                                                                               |
| User        | Veterinario                                                                                        |
| Priority    | Alta                                                                                               |
| Epic        | EP03 — Vinculación veterinaria                                                                     |
| Title       | Responder invitación de vinculación                                                                |
| Description | Como veterinario, quiero aceptar o rechazar una invitación para decidir con qué ganaderos trabajo. |

Acceptance Criteria

- Escenario 1: Aceptación válida. Dado que la invitación está pendiente, el veterinario es su destinatario y dispone de capacidad según su plan, cuando la acepta, entonces el sistema la marca como aceptada y crea una única vinculación activa con el ganadero.

- Escenario 2: Rechazo voluntario. Dado que la invitación está pendiente y el veterinario es su destinatario, cuando la rechaza, entonces el sistema la marca como rechazada y no concede acceso a los animales.

- Escenario 3: Respuesta no permitida. Dado que el usuario no es el destinatario, la invitación ya fue respondida o la aceptación supera el límite del plan, cuando intenta responder, entonces el sistema rechaza la operación, conserva el estado previo e informa el motivo.

Reglas y alcance

- El límite se comprueba al aceptar, no al recibir una invitación. Alcanzarlo no impide rechazar invitaciones pendientes.

#### US16: Consultar invitaciones pendientes

| Campo       | Contenido                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------- |
| Story ID    | US16                                                                                          |
| User        | Veterinario                                                                                   |
| Priority    | Media                                                                                         |
| Epic        | EP03 — Vinculación veterinaria                                                                |
| Title       | Consultar invitaciones pendientes                                                             |
| Description | Como veterinario, quiero consultar mis invitaciones pendientes para decidir cuáles responder. |

Acceptance Criteria

- Escenario 1: Invitaciones disponibles. Dado que el veterinario tiene invitaciones pendientes, cuando las consulta, entonces el sistema devuelve únicamente las dirigidas a su cuenta e identifica al ganadero remitente y la fecha de envío.

- Escenario 2: Sin invitaciones. Dado que el veterinario no tiene invitaciones pendientes, cuando las consulta, entonces el sistema informa que no existen invitaciones por responder.

#### US17: Consultar vinculaciones activas

| Campo       | Contenido                                                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Story ID    | US17                                                                                                                           |
| User        | Ganadero y veterinario                                                                                                         |
| Priority    | Media                                                                                                                          |
| Epic        | EP03 — Vinculación veterinaria                                                                                                 |
| Title       | Consultar vinculaciones activas                                                                                                |
| Description | Como ganadero o veterinario, quiero consultar mis vinculaciones activas para conocer con quién comparto información o trabajo. |

Acceptance Criteria

- Escenario 1: Vinculaciones disponibles. Dado que el usuario tiene vinculaciones activas, cuando las consulta, entonces el sistema devuelve solo aquellas en las que participa e identifica a la otra persona.

- Escenario 2: Sin vinculaciones activas. Dado que el usuario no tiene vinculaciones activas, cuando las consulta, entonces el sistema informa que no existen relaciones activas.

#### US18: Revocar acceso del veterinario

| Campo       | Contenido                                                                                                               |
| ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US18                                                                                                                    |
| User        | Ganadero                                                                                                                |
| Priority    | Alta                                                                                                                    |
| Epic        | EP03 — Vinculación veterinaria                                                                                          |
| Title       | Revocar acceso del veterinario                                                                                          |
| Description | Como ganadero, quiero revocar la vinculación de un veterinario para retirar su acceso a la información de mis animales. |

Acceptance Criteria

- Escenario 1: Revocación válida. Dado que existe una vinculación activa del ganadero con el veterinario, cuando el ganadero revoca el acceso, entonces el sistema desactiva la vinculación y rechaza las nuevas consultas y registros del veterinario que dependan de ella, conservando el historial existente.

- Escenario 2: Revocación no autorizada. Dado que la vinculación pertenece a otro ganadero, cuando el usuario intenta revocarla, entonces el sistema rechaza la operación y conserva su estado.

- Escenario 3: Revocación repetida. Dado que la vinculación ya está inactiva, cuando el ganadero vuelve a revocarla, entonces el sistema informa su estado y no vuelve a disminuir el número de vinculaciones activas.

Reglas y alcance

- La revocación libera capacidad de vinculaciones activas del veterinario. El tratamiento de las copias locales se especifica en US29 y TS03.

### EP04: Indicaciones de cuidado

#### US19: Registrar indicaciones de cuidado

| Campo       | Contenido                                                                                                           |
| ----------- | ------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US19                                                                                                                |
| User        | Veterinario                                                                                                         |
| Priority    | Alta                                                                                                                |
| Epic        | EP04 — Indicaciones de cuidado                                                                                      |
| Title       | Registrar indicaciones de cuidado                                                                                   |
| Description | Como veterinario, quiero registrar indicaciones y avisar al ganadero para orientar el cuidado posterior del animal. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que la atención pertenece al veterinario y mantiene una vinculación activa con el ganadero, cuando registra indicaciones con contenido no vacío, entonces el sistema las guarda asociadas a la atención y solicita notificar al propietario del animal.

- Escenario 2: Registro rechazado. Dado que el contenido está vacío, la atención no existe o el veterinario no tiene autorización, cuando solicita registrar las indicaciones, entonces el sistema rechaza la operación y no solicita una notificación.

- Escenario 3: Fallo de notificación. Dado que las indicaciones se guardan pero el servicio de notificaciones rechaza la solicitud, cuando el sistema recibe ese resultado, entonces conserva las indicaciones para su consulta y no informa que el aviso fue entregado.

#### US20: Modificar indicaciones de cuidado

| Campo       | Contenido                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------- |
| Story ID    | US20                                                                                               |
| User        | Veterinario                                                                                        |
| Priority    | Alta                                                                                               |
| Epic        | EP04 — Indicaciones de cuidado                                                                     |
| Title       | Modificar indicaciones de cuidado                                                                  |
| Description | Como veterinario, quiero actualizar mis indicaciones para comunicar ajustes al cuidado del animal. |

Acceptance Criteria

- Escenario 1: Actualización válida. Dado que el veterinario registró las indicaciones y mantiene una vinculación activa con el ganadero, cuando guarda un contenido actualizado no vacío, entonces el sistema conserva la nueva versión como vigente, registra la fecha de modificación y solicita notificar al propietario.

- Escenario 2: Actualización rechazada. Dado que el contenido está vacío o el veterinario no es el autor o no tiene vinculación activa, cuando solicita modificar las indicaciones, entonces el sistema rechaza la operación y conserva el contenido anterior.

- Escenario 3: Fallo de notificación. Dado que el cambio se guarda pero el servicio de notificaciones rechaza la solicitud, cuando el sistema recibe ese resultado, entonces conserva el cambio para su consulta y no informa que el aviso fue entregado.

Reglas y alcance

- Se conserva el contenido anterior con su autor y fecha para poder revisar los cambios. Esta historia no permite modificar los demás datos de la atención.

#### US21: Consultar indicaciones de cuidado

| Campo       | Contenido                                                                                                                     |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US21                                                                                                                          |
| User        | Ganadero y veterinario                                                                                                        |
| Priority    | Alta                                                                                                                          |
| Epic        | EP04 — Indicaciones de cuidado                                                                                                |
| Title       | Consultar indicaciones de cuidado                                                                                             |
| Description | Como ganadero o veterinario autorizado, quiero consultar las indicaciones para conocer el cuidado recomendado para un animal. |

Acceptance Criteria

- Escenario 1: Consulta autorizada. Dado que el usuario es el propietario o un veterinario con vinculación activa, cuando consulta las indicaciones de una atención, entonces el sistema devuelve el contenido vigente, el autor y la fecha de registro o última modificación.

- Escenario 2: Sin indicaciones. Dado que el usuario tiene autorización y la atención no tiene indicaciones, cuando las consulta, entonces el sistema informa que no hay indicaciones registradas.

- Escenario 3: Consulta no autorizada. Dado que el usuario no es el propietario ni un veterinario con vinculación activa, cuando solicita las indicaciones, entonces el sistema rechaza la consulta y no revela su contenido.

### EP05: Suscripciones

#### US22: Consultar planes y suscripción vigente

| Campo       | Contenido                                                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Story ID    | US22                                                                                                                           |
| User        | Ganadero y veterinario                                                                                                         |
| Priority    | Alta                                                                                                                           |
| Epic        | EP05 — Suscripciones                                                                                                           |
| Title       | Consultar planes y suscripción vigente                                                                                         |
| Description | Como ganadero o veterinario, quiero consultar los planes y mi suscripción para conocer mis límites y las opciones disponibles. |

Acceptance Criteria

- Escenario 1: Consulta de planes. Dado que el usuario tiene un perfil registrado, cuando consulta los planes, entonces el sistema devuelve los compatibles con su perfil e indica precio, período y límite de animales activos o de ganaderos vinculados, según corresponda.

- Escenario 2: Consulta de suscripción. Dado que el usuario tiene un plan gratuito o premium, cuando consulta su suscripción, entonces el sistema informa el plan, el límite vigente y, si es premium, el fin del período pagado y el estado de renovación.

- Escenario 3: Protección de la suscripción. Dado que la suscripción pertenece a otra cuenta, cuando el usuario intenta consultarla, entonces el sistema rechaza la solicitud y no revela sus datos.

Reglas y alcance

- Cada perfil dispone de un plan gratuito inicial y una opción premium. Los precios y las capacidades quedan sujetos a validación con los usuarios; no se fijan cifras en estas historias.

#### US23: Contratar suscripción premium

| Campo       | Contenido                                                                                                |
| ----------- | -------------------------------------------------------------------------------------------------------- |
| Story ID    | US23                                                                                                     |
| User        | Ganadero y veterinario                                                                                   |
| Priority    | Alta                                                                                                     |
| Epic        | EP05 — Suscripciones                                                                                     |
| Title       | Contratar suscripción premium                                                                            |
| Description | Como ganadero o veterinario, quiero contratar premium para ampliar la capacidad disponible en mi perfil. |

Acceptance Criteria

- Escenario 1: Pago confirmado. Dado que el usuario selecciona un plan compatible con su perfil, cuando se confirma un pago inicial válido, entonces el sistema activa premium, registra su vigencia y comunica el nuevo límite al contexto correspondiente.

- Escenario 2: Pago rechazado o pendiente. Dado que el pago inicial se rechaza o permanece sin confirmar, cuando se consulta el resultado de la contratación, entonces el sistema informa ese estado y mantiene el plan previo sin conceder capacidad premium.

- Escenario 3: Plan incompatible. Dado que el plan seleccionado corresponde a otro perfil, cuando el usuario solicita contratarlo, entonces el sistema rechaza la solicitud antes de pedir el procesamiento del pago.

Reglas y alcance

- Los pagos se realizan en modo de prueba durante el desarrollo académico. Los cambios de plan durante una vigencia activa quedan fuera de esta historia.

#### US24: Cancelar renovación de suscripción

| Campo       | Contenido                                                                                                               |
| ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US24                                                                                                                    |
| User        | Ganadero y veterinario                                                                                                  |
| Priority    | Alta                                                                                                                    |
| Epic        | EP05 — Suscripciones                                                                                                    |
| Title       | Cancelar renovación de suscripción                                                                                      |
| Description | Como ganadero o veterinario, quiero cancelar la renovación para evitar nuevos cobros al terminar el período contratado. |

Acceptance Criteria

- Escenario 1: Cancelación confirmada. Dado que el usuario tiene una suscripción premium con renovación activa, cuando se confirma la cancelación de renovación, entonces el sistema registra ese estado y mantiene premium hasta el fin del período pagado.

- Escenario 2: Cancelación repetida. Dado que la renovación ya está cancelada, cuando el usuario vuelve a solicitarlo, entonces el sistema informa el estado y conserva la vigencia pagada.

- Escenario 3: Cancelación sin confirmar. Dado que existe una solicitud de cancelación, cuando el proveedor no confirma el cambio, entonces el sistema informa que la cancelación no está confirmada y no la registra como completada.

Reglas y alcance

- Al finalizar el período sin una nueva vigencia válida, se aplica el límite gratuito. Se conservan los animales, sus historiales y las vinculaciones existentes; se bloquean nuevas altas o aceptaciones mientras se alcance o supere el límite correspondiente.

### EP06: Identidad y acceso

#### US25: Registrar cuenta

| Campo       | Contenido                                                                                                                 |
| ----------- | ------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US25                                                                                                                      |
| User        | Ganadero y veterinario                                                                                                    |
| Priority    | Alta                                                                                                                      |
| Epic        | EP06 — Identidad y acceso                                                                                                 |
| Title       | Registrar cuenta                                                                                                          |
| Description | Como ganadero o veterinario, quiero crear una cuenta para acceder a las funciones de ANITEC correspondientes a mi perfil. |

Acceptance Criteria

- Escenario 1: Registro válido. Dado que el correo no está registrado y los datos son válidos, cuando el usuario registra su correo, contraseña y perfil, entonces el sistema crea una cuenta pendiente de verificación y solicita el envío de un código al correo indicado.

- Escenario 2: Registro inválido. Dado que el correo ya está registrado, tiene formato inválido o falta un dato obligatorio, cuando el usuario solicita crear la cuenta, entonces el sistema rechaza el registro e informa el motivo sin crear otra cuenta.

- Escenario 3: Fallo de envío. Dado que la cuenta se crea pero el servicio de correo rechaza el envío, cuando se recibe ese resultado, entonces el sistema mantiene la cuenta pendiente e informa que el envío no se confirma.

Reglas y alcance

- Para esta versión cada cuenta tiene un único perfil: ganadero o veterinario. La cuenta utiliza correo y contraseña para identificarse; no se incluye cambio de perfil.

#### US26: Verificar correo electrónico

| Campo       | Contenido                                                                                                                     |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US26                                                                                                                          |
| User        | Ganadero y veterinario                                                                                                        |
| Priority    | Alta                                                                                                                          |
| Epic        | EP06 — Identidad y acceso                                                                                                     |
| Title       | Verificar correo electrónico                                                                                                  |
| Description | Como ganadero o veterinario, quiero verificar mi correo para confirmar que puedo acceder a la dirección asociada a mi cuenta. |

Acceptance Criteria

- Escenario 1: Verificación válida. Dado que la cuenta está pendiente y el código corresponde a ella y sigue vigente, cuando el usuario solicita verificar su correo con ese código, entonces el sistema marca el correo como verificado e invalida el código utilizado.

- Escenario 2: Código no válido. Dado que el código es incorrecto, está vencido o pertenece a otra cuenta, cuando el usuario intenta verificar su correo, entonces el sistema rechaza la solicitud y mantiene la cuenta pendiente.

- Escenario 3: Nuevo código. Dado que la cuenta sigue pendiente, cuando el usuario solicita otro código dentro del límite permitido de solicitudes, entonces el sistema genera uno nuevo, invalida el anterior y solicita enviarlo al correo registrado.

Reglas y alcance

- La duración del código y los límites de intentos y reenvíos se definen antes de implementar la historia. El envío de un correo no equivale a su verificación.

#### US27: Iniciar sesión

| Campo       | Contenido                                                                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US27                                                                                                                                               |
| User        | Ganadero y veterinario                                                                                                                             |
| Priority    | Alta                                                                                                                                               |
| Epic        | EP06 — Identidad y acceso                                                                                                                          |
| Title       | Iniciar sesión                                                                                                                                     |
| Description | Como ganadero o veterinario, quiero iniciar sesión y mantener el acceso en mi dispositivo para utilizar ANITEC sin identificarme en cada apertura. |

Acceptance Criteria

- Escenario 1: Acceso válido. Dado que el correo está verificado y las credenciales son correctas, cuando el usuario inicia sesión, entonces el sistema establece una sesión asociada a su cuenta y perfil.

- Escenario 2: Acceso rechazado. Dado que las credenciales son incorrectas o el correo no está verificado, cuando el usuario intenta iniciar sesión, entonces el sistema no concede acceso a las funciones protegidas e informa que no puede completar el inicio de sesión.

- Escenario 3: Reapertura de la aplicación. Dado que el usuario conserva una sesión válida en el dispositivo, cuando vuelve a abrir la aplicación, entonces mantiene el acceso a su cuenta; si la sesión ya no es válida, el sistema solicita una nueva identificación.

Reglas y alcance

- Sin conexión solo se permite la consulta local definida en US29. La sesión no tiene una vigencia ilimitada y no habilita registros o modificaciones sin conexión.

#### US28: Cerrar sesión

| Campo       | Contenido                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------- |
| Story ID    | US28                                                                                                          |
| User        | Ganadero y veterinario                                                                                        |
| Priority    | Alta                                                                                                          |
| Epic        | EP06 — Identidad y acceso                                                                                     |
| Title       | Cerrar sesión                                                                                                 |
| Description | Como ganadero o veterinario, quiero cerrar mi sesión para retirar el acceso a mi cuenta desde el dispositivo. |

Acceptance Criteria

- Escenario 1: Cierre de sesión. Dado que el usuario mantiene una sesión en el dispositivo, cuando solicita cerrarla, entonces la aplicación elimina los datos de acceso y las copias locales de esa cuenta y exige identificación para volver a consultar información protegida.

- Escenario 2: Cierre sin conexión. Dado que el dispositivo no tiene conexión, cuando el usuario solicita cerrar sesión, entonces la aplicación completa el cierre local sin esperar una respuesta del servidor.

- Escenario 3: Cuenta diferente. Dado que un usuario cierra sesión, cuando otra cuenta inicia sesión en el mismo dispositivo, entonces no puede consultar los datos locales de la cuenta anterior.

Reglas y alcance

- El cierre local no elimina los registros de la cuenta en el servidor. Los avisos push no incluyen contenido clínico y su apertura requiere una sesión autorizada.

##### Consulta sin conexión

#### US29: Consultar información sin conexión

| Campo       | Contenido                                                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Story ID    | US29                                                                                                                                                   |
| User        | Ganadero y veterinario                                                                                                                                 |
| Priority    | Media                                                                                                                                                  |
| Epic        | EP02 — Atención veterinaria                                                                                                                            |
| Title       | Consultar información sin conexión                                                                                                                     |
| Description | Como ganadero o veterinario, quiero consultar información previamente descargada para disponer de referencias durante una interrupción de la conexión. |

Acceptance Criteria

- Escenario 1: Datos disponibles. Dado que el usuario mantiene una sesión local válida y tiene datos descargados de su cuenta, cuando consulta sin conexión, entonces la aplicación permite leerlos e indica la fecha de la última actualización.

- Escenario 2: Datos no disponibles. Dado que la información solicitada no está descargada, cuando el usuario intenta consultarla sin conexión, entonces la aplicación informa que necesita conectarse para obtenerla.

- Escenario 3: Operación que requiere conexión. Dado que el dispositivo está sin conexión, cuando el usuario intenta registrar o modificar información, entonces la aplicación informa que la operación requiere conexión y no confirma ni deja pendiente el cambio.

Reglas y alcance

- La consulta incluye inventario, fichas, historial e indicaciones previamente descargados con autorización; para el veterinario también incluye su agenda.
- Las copias se separan por cuenta y se eliminan al cerrar sesión. Al recuperar la conexión, se revalidan los permisos antes de actualizar datos y se eliminan las copias cuyo acceso fue revocado.
- Sin conexión no se puede detectar una revocación ocurrida en el servidor. La copia local conserva el último estado descargado hasta la siguiente validación o el cierre de sesión.

### EP07: Presentación de ANITEC

#### US30: Consultar presentación de ANITEC

| Campo       | Contenido                                                                                                              |
| ----------- | ---------------------------------------------------------------------------------------------------------------------- |
| Story ID    | US30                                                                                                                   |
| User        | Visitante                                                                                                              |
| Priority    | Media                                                                                                                  |
| Epic        | EP07 — Presentación de ANITEC                                                                                          |
| Title       | Consultar presentación de ANITEC                                                                                       |
| Description | Como visitante, quiero conocer las funciones de ANITEC y dónde descargarla para evaluar si responde a mis necesidades. |

Acceptance Criteria

- Escenario 1: Consulta de la solución. Dado que el visitante accede al sitio público, cuando consulta su contenido, entonces obtiene una descripción de ANITEC, sus perfiles y sus funciones principales sin necesitar una cuenta.

- Escenario 2: Acceso a descargas. Dado que existe una versión publicada para una plataforma, cuando el visitante utiliza su enlace de descarga, entonces accede al destino correspondiente; si aún no está publicada, el sitio informa su disponibilidad pendiente sin ofrecer un enlace inválido.

##### Historias técnicas

#### TS01: Proveer operaciones de la API con control de acceso

| Campo       | Contenido                                                                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | TS01                                                                                                                                                    |
| User        | Developer                                                                                                                                               |
| Priority    | Alta                                                                                                                                                    |
| Epic        | EP06 — Identidad y acceso                                                                                                                               |
| Title       | Proveer operaciones de la API con control de acceso                                                                                                     |
| Description | Como desarrollador, quiero disponer de operaciones documentadas de la API REST para conectar la aplicación móvil con las reglas y permisos del sistema. |

Acceptance Criteria

- Escenario 1: Solicitud válida. Dado que la operación está documentada y la solicitud incluye una sesión válida, permisos y datos correctos, cuando la API procesa una consulta o registro, entonces responde con el resultado y un código de éxito acorde con la operación.

- Escenario 2: Solicitud no autorizada. Dado que falta una sesión válida o el usuario no tiene permiso sobre el recurso, cuando la API recibe la solicitud, entonces devuelve una respuesta de rechazo sin revelar datos protegidos ni modificar registros.

- Escenario 3: Datos rechazados. Dado que la solicitud incumple una validación o regla de negocio, cuando la API la procesa, entonces responde con un error que identifica el motivo y no aplica la modificación solicitada.

Reglas y alcance

- La documentación especifica para cada operación el método, la ruta, los datos de solicitud, las respuestas y los permisos. La cobertura comprende las operaciones en línea de US01–US28; la implementación se divide en tareas por contexto.

#### TS02: Procesar cambios de suscripción de forma consistente

| Campo       | Contenido                                                                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | TS02                                                                                                                                                    |
| User        | Developer                                                                                                                                               |
| Priority    | Alta                                                                                                                                                    |
| Epic        | EP05 — Suscripciones                                                                                                                                    |
| Title       | Procesar cambios de suscripción de forma consistente                                                                                                    |
| Description | Como desarrollador, quiero procesar las confirmaciones y la vigencia de las suscripciones para mantener correctos los estados y límites de cada perfil. |

Acceptance Criteria

- Escenario 1: Confirmación válida. Dado que una notificación de pago tiene origen verificado y corresponde a una suscripción conocida, cuando se procesa, entonces el sistema actualiza el estado y comunica el límite al inventario o a las vinculaciones según el perfil.

- Escenario 2: Mensaje duplicado o desactualizado. Dado que una notificación ya está procesada o contradice un estado más reciente confirmado, cuando vuelve a recibirse, entonces el sistema no duplica efectos ni sustituye el estado vigente; si el orden es incierto, consulta el estado actual al proveedor.

- Escenario 3: Fin de vigencia. Dado que termina el período pagado y no existe una nueva vigencia válida, cuando se comprueba el vencimiento, entonces el sistema aplica el límite gratuito y bloquea nuevas altas o aceptaciones que lo excedan, sin eliminar información ni revocar vinculaciones existentes.

Reglas y alcance

- Las notificaciones cuyo origen no se puede verificar se rechazan sin modificar suscripciones. Las respuestas al proveedor distinguen una recepción procesada de una solicitud inválida o un error de procesamiento.

#### TS03: Mantener copias locales separadas por cuenta

| Campo       | Contenido                                                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Story ID    | TS03                                                                                                                                                        |
| User        | Developer                                                                                                                                                   |
| Priority    | Alta                                                                                                                                                        |
| Epic        | EP02 — Atención veterinaria                                                                                                                                 |
| Title       | Mantener copias locales separadas por cuenta                                                                                                                |
| Description | Como desarrollador, quiero almacenar los datos de consulta por cuenta para ofrecer acceso sin conexión y evitar que se mezclen datos de distintos usuarios. |

Acceptance Criteria

- Escenario 1: Actualización autorizada. Dado que existe conexión y una sesión válida, cuando se descargan datos autorizados, entonces se guardan en la base local de la cuenta con su fecha de actualización.

- Escenario 2: Acceso revocado. Dado que el usuario recupera la conexión y la validación confirma que ya no tiene permiso sobre ciertos datos, cuando finaliza esa validación, entonces la aplicación elimina esas copias y bloquea su consulta.

- Escenario 3: Limpieza local. Dado que existen copias de una cuenta en el dispositivo, cuando se cierra su sesión, entonces se eliminan esas copias y los datos de acceso sin borrar la información del servidor.

Reglas y alcance

- SQLite almacena las copias de consulta. Los datos que permiten mantener la sesión se guardan mediante almacenamiento seguro del dispositivo, separados de esas copias.

##### Historias de investigación

#### SP01: Validar integración de pagos y suscripciones

| Campo       | Contenido                                                                                                                                  |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Story ID    | SP01                                                                                                                                       |
| User        | Developer                                                                                                                                  |
| Priority    | Alta                                                                                                                                       |
| Epic        | EP05 — Suscripciones                                                                                                                       |
| Title       | Validar integración de pagos y suscripciones                                                                                               |
| Description | Como desarrollador, quiero investigar la integración de pagos para definir cómo contratar, cancelar y comprobar la vigencia de los planes. |

Acceptance Criteria

- Escenario 1: Pruebas documentadas. Dado que existe un entorno de prueba, cuando se ejecutan pagos aprobados, rechazados y cancelaciones de renovación, entonces se registran solicitudes, resultados y efectos esperados en ANITEC.

- Escenario 2: Procesamiento de confirmaciones. Dado que el proveedor comunica cambios de estado, cuando se prueban mensajes válidos, inválidos, duplicados y desordenados, entonces se documenta cómo verificar su origen y evitar estados o límites incorrectos.

- Escenario 3: Conclusión de la investigación. Dado que concluyen las pruebas y la revisión de los requisitos de cobro de las plataformas móviles, cuando se presenta el informe, entonces incluye evidencias, restricciones, decisiones y tareas pendientes para la implementación.

Condiciones de cierre

- El objetivo es validar la viabilidad de Stripe en modo de prueba y documentar las condiciones de una publicación futura; no se presupone que la misma integración pueda usarse sin cambios en las tiendas móviles.

#### SP02: Validar notificaciones en Android e iOS

| Campo       | Contenido                                                                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Story ID    | SP02                                                                                                                                             |
| User        | Developer                                                                                                                                        |
| Priority    | Alta                                                                                                                                             |
| Epic        | EP04 — Indicaciones de cuidado                                                                                                                   |
| Title       | Validar notificaciones en Android e iOS                                                                                                          |
| Description | Como desarrollador, quiero comprobar el envío y la recepción de notificaciones para definir la integración de avisos de indicaciones de cuidado. |

Acceptance Criteria

- Escenario 1: Prueba por plataforma. Dado que existe un prototipo con Firebase Cloud Messaging, cuando se envía un aviso a Android y a iOS, entonces se documentan los resultados con la aplicación abierta y en segundo plano, diferenciando aceptación del envío y recepción en el dispositivo.

- Escenario 2: Permisos y destinatario. Dado que se prueban permisos denegados, cierre de sesión y cambio de cuenta, cuando se envían avisos, entonces se documenta cómo evitar contenido clínico en la notificación y exigir autorización al consultar la atención.

- Escenario 3: Conclusión de la investigación. Dado que concluyen las pruebas, cuando se presenta el informe, entonces incluye configuración necesaria, evidencias por plataforma, limitaciones y tareas pendientes; toda prueba no ejecutada se identifica expresamente.

## 2.4.2. Impact mapping

**Desarrollo del impact mapping**

## 2.4.3. Product Backlog

El Product Backlog de ANITEC ordena las 35 historias del proyecto (30 historias de usuario, 3 historias técnicas y 2 historias de investigación) según el valor que aportan al negocio. El orden inicia con la presentación pública de la solución (Landing Page), continúa con la gestión del ganado y avanza hacia la vinculación veterinaria, el registro de atenciones, las indicaciones de cuidado y, finalmente, la monetización y el acceso sin conexión. Las historias de identidad y acceso se incorporan como habilitadores del primer incremento, pero no encabezan el backlog, ya que por sí solas no entregan valor al usuario. El proyecto se planifica en 4 sprints.

La estimación emplea la escala de Story Points 1 / 2 / 3 / 5 / 8. El total estimado es de 123 puntos, distribuidos en una velocidad objetivo aproximada de 31 puntos por sprint.

| # Orden | Story Id | Título                                               | Story Points | Sprint |
| ------- | -------- | ---------------------------------------------------- | ------------ | ------ |
| 1       | US30     | Consultar presentación de ANITEC                     | 3            | 1      |
| 2       | US01     | Registrar animal                                     | 5            | 1      |
| 3       | US02     | Consultar inventario de animales                     | 3            | 1      |
| 4       | US03     | Consultar ficha del animal                           | 3            | 1      |
| 5       | US04     | Actualizar datos del animal                          | 3            | 1      |
| 6       | US25     | Registrar cuenta                                     | 3            | 1      |
| 7       | US26     | Verificar correo electrónico                         | 3            | 1      |
| 8       | US27     | Iniciar sesión                                       | 3            | 1      |
| 9       | US28     | Cerrar sesión                                        | 1            | 1      |
| 10      | TS01     | Proveer operaciones de la API con control de acceso  | 5            | 1      |
| 11      | US05     | Dar de baja a un animal                              | 3            | 2      |
| 12      | US06     | Registrar observación sobre un animal                | 2            | 2      |
| 13      | US14     | Enviar invitación de vinculación                     | 5            | 2      |
| 14      | US15     | Responder invitación de vinculación                  | 3            | 2      |
| 15      | US16     | Consultar invitaciones pendientes                    | 2            | 2      |
| 16      | US17     | Consultar vinculaciones activas                      | 2            | 2      |
| 17      | US18     | Revocar acceso del veterinario                       | 3            | 2      |
| 18      | US07     | Programar visita veterinaria                         | 3            | 2      |
| 19      | US08     | Consultar agenda de visitas y controles              | 3            | 2      |
| 20      | SP02     | Validar notificaciones en Android e iOS              | 3            | 2      |
| 21      | US09     | Registrar atención veterinaria                       | 5            | 3      |
| 22      | US10     | Registrar tratamiento realizado                      | 3            | 3      |
| 23      | US11     | Registrar vacunación aplicada                        | 3            | 3      |
| 24      | US12     | Programar control veterinario                        | 3            | 3      |
| 25      | US13     | Consultar historial veterinario del animal           | 5            | 3      |
| 26      | US19     | Registrar indicaciones de cuidado                    | 3            | 3      |
| 27      | US20     | Modificar indicaciones de cuidado                    | 3            | 3      |
| 28      | US21     | Consultar indicaciones de cuidado                    | 3            | 3      |
| 29      | SP01     | Validar integración de pagos y suscripciones         | 3            | 3      |
| 30      | US22     | Consultar planes y suscripción vigente               | 2            | 4      |
| 31      | US23     | Contratar suscripción premium                        | 8            | 4      |
| 32      | US24     | Cancelar renovación de suscripción                   | 3            | 4      |
| 33      | TS02     | Procesar cambios de suscripción de forma consistente | 5            | 4      |
| 34      | TS03     | Mantener copias locales separadas por cuenta         | 5            | 4      |
| 35      | US29     | Consultar información sin conexión                   | 8            | 4      |

##### Criterios de ordenamiento

- **Valor de negocio primero.** El backlog inicia con la Landing Page (US30), que da a conocer la solución y habilita la descarga de la aplicación, y continúa con la gestión del inventario de ganado (US01–US04), que resuelve el problema principal del ganadero.
- **Identidad y acceso como habilitador, no como cabecera.** Las historias de cuenta y sesión (US25–US28) y el control de acceso de la API (TS01) se ubican al cierre del primer sprint: son necesarias para liberar el incremento, pero no abren el backlog porque no entregan valor por sí mismas.
- **Dependencias funcionales respetadas.** La vinculación veterinaria (US14–US18) precede al registro de atenciones (US09–US13), ya que la autorización entre ganadero y veterinario condiciona esas operaciones. Las indicaciones de cuidado (US19–US21) se apoyan en la atención registrada.
- **Investigación antes de implementación.** SP02 se resuelve en el Sprint 2 para habilitar los avisos de indicaciones del Sprint 3, y SP01 se ejecuta en el Sprint 3 para sustentar la integración de pagos del Sprint 4.
- **Monetización y acceso sin conexión al final.** La suscripción (US22–US24, TS02) y la consulta sin conexión (TS03, US29) requieren un producto funcional previo, por lo que aportan valor una vez consolidadas las capacidades centrales.

##### Distribución por sprint

| Sprint    | Alcance principal                                                                                   | Story Points |
| --------- | --------------------------------------------------------------------------------------------------- | ------------ |
| 1         | Landing Page, gestión del inventario de ganado, cuentas, sesiones y base de la API                  | 32           |
| 2         | Bajas y observaciones, vinculación veterinaria, agenda de visitas e investigación de avisos         | 29           |
| 3         | Atenciones, tratamientos, vacunaciones, historial, indicaciones de cuidado e investigación de pagos | 31           |
| 4         | Planes y suscripciones, consistencia de estados y consulta sin conexión                             | 31           |
| **Total** |                                                                                                     | **123**      |

</div>
