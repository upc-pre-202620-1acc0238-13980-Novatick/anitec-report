<div align="justify">

### 2.3.5. Big Picture EventStorming

El Big Picture EventSotrming nos permitio representar los pincipales acontecimientos de ANITEC y comprender las relaciones entre la gestión del ganado, la vinculación con veterinarios, las atenciones presenciales y las suscripciones. El modelado se desarrolló progresivamente mediante la exploración de eventos, su organización temporal, la identificación de dificultades y la selección de eventos. Todo este proceso se desarrollo en la plataforma Miro. [Ver Tablero](https://miro.com/welcomeonboard/MGhKZFJHcWZRaDA1VEhPeGVueUZlS2V2TUVJZnhVZUk0Rkx3TjVYWExHckNCclZmSisyaVZSN2M4SjNVdnRROFdSV21YNENhb2hQdkNBb0RHNkV1dVJvbnFnQU8rTlpiUVBxaGNNSE5WZzhnQ3BZYTBVWGtDejhNWUUxQW5xQ1lBS2NFMDFkcUNFSnM0d3FEN050ekl3PT0hdjE=?share_link_id=603558770825)

#### Exploración sin estructura

![Exploración sin estructura](../../assets/images/event-storming/big-picture/01-unstructured-exploration.jpg)

En esta primera etapa se identificaron acontecimientos relevantes para ANITEC, representados mediante notas naranjas y redactados en pasado. Se incluyeron eventos relacionados con las cuentas, el registro de animales, las invitaciones de vinculación, las atenciones veterinarias y las suscripciones. Su distribución inicial permitió explorar el alcance del proyecto sin establecer todavía una secuencia temporal ni límites definitivos entre sus procesos.

#### Lineas de tiempo

![Líneas de tiempo](../../assets/images/event-storming/big-picture/02-timelines.jpg)

Los eventos se organizaron en secuencias para mostrar el desarrollo de los principales procesos y sus alternativas, como la aceptación o el rechazo de una invitación y la confirmación o el rechazo de un pago. En la atención veterinaria se relacionaron las observaciones del ganadero, la programación de una visita, el registro de la atención y la posible programación de controles posteriores.

Las flechas representan recorridos posibles y no implican que todos los pasos sean obligatorios o automáticos. Una observación puede motivar una visita, pero esta requiere coordinación. Los tratamientos y las vacunaciones son registros opcionales de una atención. Asimismo, revocar una vinculación o cancelar la renovación de una suscripción corresponde a decisiones posteriores, no a resultados obligatorios del proceso.

La cancelación de la renovación mantiene los beneficios premium hasta finalizar el período pagado. Por otro lado, programar un control no significa que este ya se haya realizado: cuando ocurre, se registra una nueva atención veterinaria. Este ciclo puede repetirse y se omite gráficamente para facilitar la lectura.

#### Pain Points

![Pain Points](../../assets/images/event-storming/big-picture/03-pain-points.jpg)

Sobre las secuencias se incorporaron notas rojas para señalar riesgos y preguntas surgidas durante el modelado. Entre ellas se encuentran los posibles registros duplicados de animales, las dificultades con la verificación del correo, la conservación del historial al dar de baja un animal y el tratamiento de los registros cuando vence una suscripción premium.

También se identificaron dudas sobre la revocación del acceso veterinario, la cancelación o reprogramación de visitas, la distinción entre indicaciones vigentes y anteriores, y el posible olvido de controles. Estas notas representan aspectos que requieren validación o definición de reglas de negocio; no constituyen, por sí mismas, problemas comprobados mediante entrevistas.

#### Pivotal Events

![Pivotal Events](../../assets/images/event-storming/big-picture/04-pivotal-events.jpg)

Finalmente, se destacaron cuatro eventos mediante bordes morados discontinuos, debido a los cambios significativos que representan dentro de los procesos:

- **Animal registrado:** incorpora un animal al inventario y permite asociarle información y registros posteriores.
- **Invitación de vinculación aceptada:** establece la relación autorizada entre el ganadero y el veterinario.
- **Atención veterinaria registrada:** deja constancia de una atención realizada y sirve como referencia para sus indicaciones y seguimiento.
- **Suscripción premium activada:** habilita los beneficios y el límite de animales correspondientes al plan contratado.

Estos eventos permiten reconocer momentos clave del negocio y sirven como referencia para profundizar posteriormente en las responsabilidades y relaciones del modelo.

#### 2.3.6. Ubiquitous Language

El lenguaje ubicuo de ANITEC reúne los términos utilizados para describir sus procesos y reglas de negocio. Estas definiciones permiten mantener un vocabulario común en los requerimientos, los diagramas y el desarrollo. Se incluye el equivalente en inglés como referencia para la implementación.

##### Identidad y acceso - Identity and Access Bounded Context

| Término                | Equivalente en inglés | Definición                                                                                      |
| ---------------------- | --------------------- | ----------------------------------------------------------------------------------------------- |
| Cuenta                 | Account               | Registro que identifica a un usuario de ANITEC y permite gestionar su acceso.                   |
| Perfil de usuario      | User Role             | Rol de ganadero o veterinario que determina las funciones y los planes aplicables al usuario.   |
| Correo verificado      | Verified Email        | Dirección de correo cuya pertenencia al usuario se comprobó mediante un código de verificación. |
| Código de verificación | Verification Code     | Código temporal asociado a una cuenta que permite comprobar el acceso al correo registrado.     |

##### Gestión del ganado - Livestock Management Bounded Context

| Término                  | Equivalente en inglés       | Definición                                                                                                    |
| ------------------------ | --------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Ganadero                 | Livestock Owner             | Usuario que administra sus animales, registra observaciones y autoriza el acceso de veterinarios.             |
| Animal                   | Animal                      | Individuo del ganado registrado en el inventario de un ganadero.                                              |
| Animal activo            | Active Animal               | Animal que permanece en el inventario activo y cuenta para el límite permitido por el plan.                   |
| Capacidad del inventario | Inventory Capacity          | Cantidad máxima de animales activos permitida para un ganadero según su plan vigente.                         |
| Baja del inventario      | Inventory Deactivation      | Cambio que retira un animal del inventario activo, conservando sus datos y el historial asociado.             |
| Observación del ganadero | Livestock Owner Observation | Información descriptiva registrada por el ganadero sobre un animal; no constituye un diagnóstico veterinario. |

##### Vinculación veterinaria - Veterinary Linking Bounded Context

| Término                        | Equivalente en inglés         | Definición                                                                                                                                            |
| ------------------------------ | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Veterinario                    | Veterinarian                  | Usuario que programa visitas y controles y registra atenciones e indicaciones para animales de ganaderos con quienes mantiene una vinculación activa. |
| Invitación de vinculación      | Linking Invitation            | Solicitud enviada por un ganadero para autorizar la vinculación con un veterinario.                                                                   |
| Vinculación activa             | Active Veterinary Link        | Relación vigente que autoriza al veterinario a acceder a la información y realizar las operaciones permitidas sobre los animales del ganadero.        |
| Revocación de acceso           | Access Revocation             | Acción del ganadero que retira la autorización concedida a un veterinario mediante la vinculación.                                                    |
| Límite de ganaderos vinculados | Linked Livestock Owners Limit | Cantidad máxima de ganaderos con los que un veterinario puede mantener vinculaciones activas según su plan.                                           |

##### Atención veterinaria - Veterinary Care Bounded Context

| Término                 | Equivalente en inglés | Definición                                                                                                                   |
| ----------------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Visita veterinaria      | Veterinary Visit      | Encuentro programado para atender presencialmente a un animal. Su programación no implica que la atención se haya realizado. |
| Control veterinario     | Veterinary Follow-up  | Revisión programada posterior a una atención para evaluar la evolución del animal.                                           |
| Atención veterinaria    | Veterinary Care       | Atención presencial realizada a un animal, cuyo registro identifica al animal, al veterinario y la fecha correspondiente.    |
| Tratamiento realizado   | Performed Treatment   | Intervención aplicada al animal y registrada como parte de una atención veterinaria.                                         |
| Vacunación registrada   | Vaccination Record    | Constancia de una vacuna aplicada al animal durante una atención veterinaria.                                                |
| Indicaciones de cuidado | Care Instructions     | Recomendaciones del veterinario para el cuidado del animal, registradas como parte de una atención.                          |
| Historial veterinario   | Veterinary History    | Conjunto de atenciones registradas de un animal, incluidos los tratamientos, las vacunaciones y las indicaciones asociadas.  |

##### Suscripciones - Subscriptions Bounded Context

| Término          | Equivalente en inglés   | Definición                                                                                                                             |
| ---------------- | ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Plan             | Plan                    | Conjunto de condiciones, precio y límites aplicables al perfil del usuario. Puede ser gratuito o premium.                              |
| Suscripción      | Subscription            | Asociación de un usuario con un plan y su período de vigencia.                                                                         |
| Vigencia premium | Premium Validity Period | Período durante el cual el usuario dispone de los beneficios del plan premium. Cancelar su renovación no elimina el período ya pagado. |

</div>
