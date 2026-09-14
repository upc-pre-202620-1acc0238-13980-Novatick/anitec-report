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

#### Hallazgos y decisiones

El ejercicio permitió establecer una visión general de ANITEC centrada en el inventario de animales y el registro de atenciones veterinarias presenciales. También permitió reconocer la importancia de conservar el historial, controlar el acceso del veterinario y definir el comportamiento de los límites de registro según la suscripción.

Las dudas identificadas y los eventos destacados orientan el modelado posterior de comandos, políticas, agregados y bounded contexts.

</div>
