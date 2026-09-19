<div align="justify">

### 2.6. Tactical-Level Domain-Driven Design

El diseño táctico de ANITEC documenta las clases y relaciones de Livestock Management, Veterinary Care, Veterinary Linking, Subscriptions e Identity and Access. Comprende Flutter y Java con Spring Boot, siguiendo las historias de usuario y el Event Storming.

#### 2.6.1. Bounded Context: Livestock Management

Gestión del ganado administra animales, observaciones y capacidad del inventario (US01-US06 y consulta local de US29). Recibe límites de Subscriptions y proporciona datos autorizados a Veterinary Care, que conserva las atenciones, tratamientos, vacunaciones e indicaciones vinculadas por el identificador del animal.

##### 2.6.1.1. Domain Layer

Las raíces de agregado `Animal` e `InventoryCapacity` controlan las modificaciones y sus reglas. Sus atributos son privados y se consultan mediante métodos de lectura.

Se proponen identificadores internos `UUID` (identificadores únicos generados por el sistema), distintos del código asignado por el ganadero.

###### API REST - Java

Diccionario de clases

| Elemento                      | Tipo                    | Responsabilidad                                                                              |
| ----------------------------- | ----------------------- | -------------------------------------------------------------------------------------------- |
| `Animal`                      | Raíz de agregado        | Mantener los datos, el propietario, el estado y las observaciones de un animal.              |
| `AnimalObservation`           | Entidad de `Animal`     | Conservar una observación del ganadero con su autor y fecha.                                 |
| `AnimalCode`                  | Objeto de valor         | Representar un código no vacío. Se compara por su contenido y no tiene identificador propio. |
| `AnimalStatus`                | Enumeración             | Representar los estados `ACTIVE` e `INACTIVE`.                                               |
| `AnimalSex`                   | Enumeración             | Representar los valores `MALE`, `FEMALE` y `UNKNOWN`.                                        |
| `InventoryCapacity`           | Raíz de agregado        | Controlar el límite permitido y la cantidad de animales activos de un ganadero.              |
| `AnimalRepository`            | Interfaz de repositorio | Definir cómo guardar y recuperar animales sin depender del motor de base de datos.           |
| `InventoryCapacityRepository` | Interfaz de repositorio | Definir cómo guardar y recuperar la capacidad de cada ganadero.                              |

Animal

| Atributo       | Tipo                      | Descripción                                                                  |
| -------------- | ------------------------- | ---------------------------------------------------------------------------- |
| `id`           | `UUID`                    | Identificador interno del animal.                                            |
| `ownerId`      | `UUID`                    | Identificador del ganadero propietario. No cambia al editar el animal.       |
| `code`         | `AnimalCode`              | Código obligatorio y único dentro del inventario del propietario.            |
| `species`      | `String`                  | Especie del animal. Obligatoria.                                             |
| `sex`          | `AnimalSex`               | Sexo del animal. Obligatorio, admite desconocido.                            |
| `name`         | `String`                  | Nombre opcional.                                                             |
| `breed`        | `String`                  | Raza opcional.                                                               |
| `birthDate`    | `LocalDate`               | Fecha de nacimiento opcional, sin hora. No puede ser futura.                 |
| `status`       | `AnimalStatus`            | Estado activo o inactivo.                                                    |
| `registeredAt` | `Instant`                 | Momento de registro asignado por el servidor.                                |
| `observations` | `List<AnimalObservation>` | Observaciones del animal, consultables sin permitir su modificación directa. |

| Operación pública | Responsabilidad                                                                                                                       |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `register`        | Crear un animal activo a partir del propietario y los datos válidos de registro. Funciona como método de creación de la clase.        |
| `updateDetails`   | Actualizar código, especie, sexo, nombre, raza y fecha de nacimiento, conservando identificador, propietario, estado y observaciones. |
| `deactivate`      | Cambiar de activo a inactivo e indicar si se produjo el cambio. Una segunda solicitud no vuelve a modificar el estado.                |
| `addObservation`  | Crear y asociar una observación con contenido, autor y fecha. Devuelve la observación registrada.                                     |
| `belongsTo`       | Comprobar si el identificador recibido corresponde al propietario.                                                                    |
| `isActive`        | Indicar si el animal está activo.                                                                                                     |

El servidor asigna propietario, autor y fechas. Application Layer verifica la propiedad antes de editar, dar de baja o agregar observaciones. `register` y `updateDetails` validan los datos obligatorios y la fecha de nacimiento.

AnimalObservation y AnimalCode

| Elemento            | Atributos privados                                                        | Operaciones y reglas                                                                                                                                                                        |
| ------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AnimalObservation` | `id: UUID`, `authorId: UUID`, `content: String`, `registeredAt: Instant`. | Se crea mediante `Animal.addObservation`. Rechaza contenido vacío o compuesto solo por espacios. Sus datos se consultan mediante métodos de lectura. No se modifica de forma independiente. |
| `AnimalCode`        | `value: String`.                                                          | `of(value)` crea el objeto a partir de un código no vacío. `getValue()` permite consultarlo. El valor no cambia después de su creación. Una edición del código reemplaza el objeto.         |

La unicidad por propietario y código se comprueba con el repositorio y una restricción en la base de datos. Incluye animales inactivos y excluye el propio animal al editar.

InventoryCapacity

| Atributo           | Tipo   | Descripción                                                                            |
| ------------------ | ------ | -------------------------------------------------------------------------------------- |
| `ownerId`          | `UUID` | Identificador del ganadero y de su registro de capacidad.                              |
| `allowedAnimals`   | `int`  | Cantidad máxima de animales activos permitida por el plan vigente.                     |
| `activeAnimals`    | `int`  | Cantidad actual de animales activos del ganadero.                                      |
| `lastPlanRevision` | `long` | Última revisión del límite aplicada. Permite reconocer cambios repetidos o anteriores. |

| Operación pública  | Responsabilidad                                                                                                                                                    |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `create`           | Crear la capacidad inicial con el límite gratuito recibido, cero animales activos y la revisión inicial.                                                           |
| `hasAvailableSlot` | Indicar si `activeAnimals` es menor que `allowedAnimals`.                                                                                                          |
| `occupySlot`       | Incrementar la cantidad activa únicamente si existe capacidad disponible.                                                                                          |
| `releaseSlot`      | Reducir la cantidad activa al confirmar una baja, sin permitir valores negativos.                                                                                  |
| `updateLimit`      | Aplicar un límite no negativo recibido con una revisión más reciente y conservar la cantidad activa. Las revisiones ya aplicadas o anteriores no producen cambios. |

Se propone que Subscriptions proporcione límites y revisiones crecientes por ganadero, también al regresar al plan gratuito. `lastPlanRevision` conserva la última revisión aplicada.

Reducir el límite conserva los animales existentes y bloquea nuevas altas sin capacidad. Las bajas conservan datos, observaciones y referencias al historial veterinario.

Contratos de repositorio

| Interfaz                      | Métodos públicos                                                                                                           | Responsabilidad                                                                                                                                                                                                                 |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AnimalRepository`            | `save(animal)`, `findById(animalId)`, `findByOwnerId(ownerId)`, `existsByOwnerIdAndCode(ownerId, code, excludedAnimalId)`. | Guardar el agregado con sus observaciones, recuperar un animal o el inventario del propietario y comprobar códigos duplicados. `excludedAnimalId` es nulo al registrar y contiene el identificador del animal actual al editar. |
| `InventoryCapacityRepository` | `save(capacity)`, `findByOwnerId(ownerId)`.                                                                                | Guardar y recuperar la capacidad del ganadero.                                                                                                                                                                                  |

Las interfaces no contienen atributos de conexión y se implementan en Infrastructure Layer. Las observaciones se guardan mediante `Animal`, sin repositorio independiente.

Relaciones y consistencia

| Relación                                             | Descripción                                                                                            |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `Animal` -> `AnimalObservation`                      | Composición: un animal contiene cero o más observaciones. Cada observación pertenece a un solo animal. |
| `Animal` -> `AnimalCode`                             | Cada animal contiene un código obligatorio.                                                            |
| `Animal` -> `AnimalStatus` / `AnimalSex`             | Cada animal mantiene un valor de cada enumeración.                                                     |
| `InventoryCapacity` y `Animal`                       | Se relacionan por `ownerId`. La capacidad no contiene una lista de animales.                           |
| `AnimalRepository` -> `Animal`                       | Recupera y guarda el agregado completo.                                                                |
| `InventoryCapacityRepository` -> `InventoryCapacity` | Recupera y guarda la capacidad del propietario.                                                        |

Application Layer coordina el alta o la baja con su cambio de cupo. Infrastructure Layer garantiza su guardado conjunto ante solicitudes simultáneas. Solo una transición de activo a inactivo libera cupo.

Se mantienen los eventos "Observación sobre un animal registrada" y "Límite de animales permitido actualizado". Las observaciones no generan automáticamente visitas ni atenciones.

Los usuarios se referencian por identificador. El acceso entre contextos requiere autorización y se realiza sin consultar directamente repositorios ajenos.

###### Aplicación móvil - Flutter

Flutter representa la información y solicita operaciones. El servidor conserva la validación final de propiedad, códigos duplicados y capacidad.

Los modelos móviles son inmutables (solo lectura). Usan `String` para identificadores, `DateTime` para fechas y `?` para datos opcionales. La fecha de nacimiento se interpreta sin hora.

| Elemento              | Atributos                                                                                                                                                                                                                                   | Operaciones y responsabilidad                                                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Animal`              | `id: String`, `ownerId: String`, `code: String`, `species: String`, `sex: AnimalSex`, `name: String?`, `breed: String?`, `birthDate: DateTime?`, `status: AnimalStatus`, `registeredAt: DateTime`, `observations: List<AnimalObservation>`. | Representar la ficha y el estado del animal. `isActive` permite consultar si está activo. La lista de observaciones es de solo lectura.           |
| `AnimalObservation`   | `id: String`, `authorId: String`, `content: String`, `registeredAt: DateTime`.                                                                                                                                                              | Representar una observación descargada. Sus datos se consultan sin modificarlos directamente.                                                     |
| `AnimalStatus`        | Valores `ACTIVE` e `INACTIVE`.                                                                                                                                                                                                              | Identificar el estado del animal.                                                                                                                 |
| `AnimalSex`           | Valores `MALE`, `FEMALE` y `UNKNOWN`.                                                                                                                                                                                                       | Representar el sexo registrado.                                                                                                                   |
| `InventoryCapacity`   | `ownerId: String`, `allowedAnimals: int`, `activeAnimals: int`.                                                                                                                                                                             | Mostrar el límite y su ocupación. `hasAvailableSlot` orienta al usuario con el último estado disponible. No sustituye la validación del servidor. |
| `LivestockRepository` | Sin atributos de implementación.                                                                                                                                                                                                            | Definir las consultas y solicitudes del módulo sin depender de llamadas de red ni de SQLite.                                                      |

Contrato del repositorio móvil

| Método público        | Responsabilidad                                                         |
| --------------------- | ----------------------------------------------------------------------- |
| `getInventory`        | Obtener los animales del ganadero desde información autorizada.         |
| `getAnimal`           | Obtener la ficha y las observaciones de un animal por su identificador. |
| `getCapacity`         | Consultar el límite y la cantidad activa del inventario.                |
| `registerAnimal`      | Solicitar al servidor el registro con los datos del formulario.         |
| `updateAnimal`        | Solicitar la actualización de los datos editables del animal.           |
| `deactivateAnimal`    | Solicitar la baja y recibir el estado confirmado.                       |
| `registerObservation` | Solicitar el registro del contenido de una observación para un animal.  |

Los métodos devuelven `Future`, resultados disponibles al terminar una operación. Inventario y fichas admiten consulta local. Los registros y modificaciones requieren conexión y no quedan pendientes.

El acceso al servidor y al almacenamiento local se coordina entre las capas de aplicación e infraestructura. Las copias incluyen fecha de descarga, se separan por cuenta y se eliminan al cerrar sesión. Al reconectar se revalidan permisos y se eliminan copias cuyo acceso fue revocado.

`Animal` contiene observaciones y utiliza ambas enumeraciones. `LivestockRepository` devuelve estos modelos y la capacidad. Pantallas, formularios y operaciones de SQLite pertenecen a otras capas.

##### 2.6.1.2. Interface Layer

Esta capa recibe las solicitudes del usuario y presenta sus resultados. En el servidor incluye controladores y objetos de solicitud y respuesta. En Flutter, pantallas, formularios y estado de presentación. Las operaciones se delegan a Application Layer, que coordina las reglas del dominio.

###### API REST - Java

Los controladores reciben la identidad de la sesión validada y comprueban el formato de las solicitudes. El propietario, el autor, el estado inicial y las fechas de registro se determinan en el servidor.

| Clase                         | Propósito                                                              | Atributos privados                                                                | Métodos públicos                                                                                                                                                               |
| ----------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `AnimalController`            | Recibir consultas y modificaciones del inventario y las observaciones. | `commandService: LivestockCommandService`, `queryService: LivestockQueryService`. | `getInventory()`, `getAnimal(animalId)`, `registerAnimal(request)`, `updateAnimal(animalId, request)`, `deactivateAnimal(animalId)`, `registerObservation(animalId, request)`. |
| `InventoryCapacityController` | Permitir consultar la capacidad del ganadero identificado.             | `queryService: LivestockQueryService`.                                            | `getCapacity()`.                                                                                                                                                               |

`LivestockCommandService` y `LivestockQueryService` pertenecen a Application Layer: el primero coordina modificaciones y el segundo consultas. Los controladores no acceden directamente a los repositorios. La actualización del límite llega desde Subscriptions. No se expone como una modificación libre del usuario.

Objetos de solicitud y respuesta

Estos objetos transportan datos entre la aplicación móvil y el servidor. Sus atributos permiten lectura. Las respuestas se construyen a partir de resultados autorizados.

| Clase                       | Propósito y atributos                                                                                                                                                                                                                                                                                      | Métodos                                         |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `AnimalDataRequest`         | Datos para registrar o editar: `code: String`, `species: String`, `sex: AnimalSex`, `name: String`, `breed: String`, `birthDate: LocalDate`. Los tres últimos son opcionales.                                                                                                                              | Constructor y métodos de lectura.               |
| `ObservationRequest`        | Contenido de una nueva observación: `content: String`.                                                                                                                                                                                                                                                     | Constructor y método de lectura.                |
| `AnimalResponse`            | Ficha del animal: `id: UUID`, `ownerId: UUID`, `code: String`, `species: String`, `sex: AnimalSex`, `name: String`, `breed: String`, `birthDate: LocalDate`, `status: AnimalStatus`, `registeredAt: Instant`, `observations: List<AnimalObservationResponse>`. Conserva los campos opcionales del dominio. | `fromDomain(animal)` y métodos de lectura.      |
| `AnimalObservationResponse` | Observación registrada: `id: UUID`, `authorId: UUID`, `content: String`, `registeredAt: Instant`.                                                                                                                                                                                                          | `fromDomain(observation)` y métodos de lectura. |
| `InventoryCapacityResponse` | Capacidad vigente: `ownerId: UUID`, `allowedAnimals: int`, `activeAnimals: int`.                                                                                                                                                                                                                           | `fromDomain(capacity)` y métodos de lectura.    |

`AnimalController` recibe `AnimalDataRequest` u `ObservationRequest` y devuelve `AnimalResponse` o `AnimalObservationResponse`. El inventario devuelve una lista de animales. Cada `AnimalResponse` contiene cero o más observaciones. `InventoryCapacityController` devuelve `InventoryCapacityResponse`. Los métodos `fromDomain` convierten datos sin modificar los agregados.

###### Aplicación móvil - Flutter

Las pantallas muestran los datos y recogen acciones. `LivestockViewModel` mantiene el estado de presentación y comunica esas acciones a `LivestockApplicationService`, de Application Layer. El término ViewModel identifica la clase que prepara los datos y resultados para la interfaz.

| Clase                    | Propósito                                                                                        | Atributos principales                                                                                                                                                                                                             | Métodos                                                                                                                                                                                      |
| ------------------------ | ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LivestockViewModel`     | Coordinar el estado visible del módulo: carga, resultados, errores y disponibilidad de conexión. | `applicationService: LivestockApplicationService`, `animals: List<Animal>`, `selectedAnimal: Animal?`, `capacity: InventoryCapacity?`, `isLoading: bool`, `errorMessage: String?`, `isOffline: bool`, `lastUpdatedAt: DateTime?`. | `loadInventory()`, `loadAnimal(animalId)`, `loadCapacity()`, `registerAnimal(data)`, `updateAnimal(animalId, data)`, `deactivateAnimal(animalId)`, `registerObservation(animalId, content)`. |
| `LivestockInventoryPage` | Mostrar animales activos e inactivos, capacidad y acceso al registro.                            | `viewModel: LivestockViewModel`.                                                                                                                                                                                                  | `build(context)`, `refreshInventory()`, `openAnimal(animalId)`, `openRegistration()`.                                                                                                        |
| `AnimalDetailPage`       | Mostrar la ficha y las observaciones. Permitir editar, dar de baja y agregar observaciones.      | `animalId: String`, `viewModel: LivestockViewModel`.                                                                                                                                                                              | `build(context)`, `openEdition()`, `confirmDeactivation()`, `openObservationForm()`.                                                                                                         |
| `AnimalFormPage`         | Recoger y validar los datos para registrar o editar.                                             | `initialAnimal: Animal?`, `viewModel: LivestockViewModel`. Estado del formulario: `code: String`, `species: String`, `sex: AnimalSex?`, `name: String?`, `breed: String?`, `birthDate: DateTime?`.                                | `build(context)`, `validateForm()`, `submit()`.                                                                                                                                              |
| `ObservationForm`        | Recoger el contenido de una observación del animal.                                              | `animalId: String`, `content: String`, `viewModel: LivestockViewModel`.                                                                                                                                                           | `build(context)`, `validateContent()`, `submit()`.                                                                                                                                           |

`build` construye la vista. Los campos editables se mantienen en el estado de cada formulario. Los métodos de envío delegan al ViewModel. `AnimalFormPage` usa `initialAnimal` para distinguir registro de edición y transmite sus seis datos editables. La validación local detecta campos vacíos y fechas inválidas. El servidor confirma las reglas de negocio.

Relaciones y comportamiento de presentación

| Relación o situación                                  | Comportamiento                                                                                                                                 |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Pantallas y formularios -> `LivestockViewModel`       | Consultan el estado y solicitan operaciones. Muestran los cambios del ViewModel.                                                               |
| `LivestockViewModel` -> `LivestockApplicationService` | Delega consultas y modificaciones, y muestra sus resultados o errores.                                                                         |
| Inventario vacío                                      | Muestra que no existen animales, diferenciándolo de un error o de información no descargada.                                                   |
| Operación en curso                                    | Muestra carga y evita repetir el envío desde el formulario. Confirma los cambios después de recibir una respuesta satisfactoria.               |
| Consulta sin conexión                                 | Muestra los datos descargados y su fecha de actualización. Los registros y modificaciones se deshabilitan y se informa que requieren conexión. |
| Capacidad o permiso insuficiente                      | Presenta el rechazo sin confirmar cambios. El control visual complementa la validación del servidor.                                           |

La presentación no accede directamente a SQLite ni a servicios externos. Las respuestas del servidor se convierten a los modelos móviles fuera de esta capa.

##### 2.6.1.3. Application Layer

Esta capa coordina las consultas y modificaciones del inventario. Comprueba quién solicita la operación, utiliza las reglas del dominio y delega la persistencia a los repositorios. Sus dependencias son atributos privados y sus operaciones de entrada son públicas.

###### API REST - Java

Un comando contiene los datos de una modificación solicitada. Su manejador organiza los pasos necesarios para ejecutarla. En este diseño, `LivestockCommandService` reúne los manejadores de los cuatro comandos del inventario.

| Clase                             | Propósito                                                                     | Atributos principales                                                                                | Métodos                                                                                                                                  |
| --------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `LivestockCommandService`         | Procesar registros, ediciones, bajas y observaciones.                         | `animalRepository: AnimalRepository`, `capacityService: InventoryCapacityService`, `clock: Clock`.   | `handle(RegisterAnimalCommand)`, `handle(UpdateAnimalCommand)`, `handle(DeactivateAnimalCommand)`, `handle(RegisterObservationCommand)`. |
| `LivestockQueryService`           | Consultar inventario, ficha y capacidad.                                      | `animalRepository: AnimalRepository`, `capacityService: InventoryCapacityService`.                   | `getInventory(ownerId)`, `getAnimal(ownerId, animalId)`, `getCapacity(ownerId)`, `getAnimalForCare(ownerId, animalId)`.                  |
| `InventoryCapacityService`        | Inicializar la capacidad y coordinar su persistencia y los cambios de límite. | `capacityRepository: InventoryCapacityRepository`, `subscriptionGateway: SubscriptionLimitsGateway`. | `getOrCreate(ownerId)`, `save(capacity)`, `applyLimit(ownerId, allowedAnimals, revision)`.                                               |
| `SubscriptionLimitChangedHandler` | Manejar los eventos de activación y vencimiento premium del ganadero.         | `capacityService: InventoryCapacityService`.                                                         | `onPremiumActivated(event)`, `onPremiumExpired(event)`.                                                                                  |
| `SubscriptionLimitsGateway`       | Contrato para consultar los límites definidos en Subscriptions.               | Sin atributos de implementación.                                                                     | `getLimits(ownerId)`.                                                                                                                    |
| `SubscriptionLimits`              | Resultado inmutable de la consulta de límites.                                | `ownerId: UUID`, `freeLimit: int`, `allowedAnimals: int`, `revision: long`.                          | Constructor y métodos de lectura.                                                                                                        |

`Clock` proporciona la fecha y hora del servidor. Los eventos recibidos desde Subscriptions deben identificar al ganadero, el límite aplicable y su revisión. El manejador ignora los cambios del perfil veterinario y delega los demás a `applyLimit`.

Datos de los comandos

| Clase                        | Propósito y atributos                                                                                                                                                                              | Métodos                           |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `AnimalInput`                | Datos editables independientes del formulario HTTP: `code: String`, `species: String`, `sex: AnimalSex`, `name: String`, `breed: String`, `birthDate: LocalDate`. Los tres últimos son opcionales. | Constructor y métodos de lectura. |
| `RegisterAnimalCommand`      | Solicitar un alta: `ownerId: UUID`, `data: AnimalInput`.                                                                                                                                           | Constructor y métodos de lectura. |
| `UpdateAnimalCommand`        | Solicitar una edición: `ownerId: UUID`, `animalId: UUID`, `data: AnimalInput`.                                                                                                                     | Constructor y métodos de lectura. |
| `DeactivateAnimalCommand`    | Solicitar una baja: `ownerId: UUID`, `animalId: UUID`.                                                                                                                                             | Constructor y métodos de lectura. |
| `RegisterObservationCommand` | Solicitar una observación: `ownerId: UUID`, `animalId: UUID`, `content: String`.                                                                                                                   | Constructor y métodos de lectura. |

Los controladores construyen estos objetos con la identidad validada del ganadero. Todos los manejadores obtienen primero la capacidad dentro de su transacción y comprueban la pertenencia del animal cuando corresponde. `getAnimalForCare` es una operación interna para Veterinary Care, que valida la identidad y la vinculación antes de solicitar los datos. La consulta comprueba además que el animal corresponda al propietario indicado.

| Flujo            | Coordinación                                                                                                                                                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Registro         | Obtiene la capacidad, comprueba el código, crea `Animal`, ocupa un cupo y guarda ambos cambios juntos.                                                                                                                                                             |
| Edición          | Comprueba propietario y código, ejecuta `updateDetails` y guarda el animal.                                                                                                                                                                                        |
| Baja             | Obtiene la capacidad y el animal. Ejecuta `deactivate` y libera el cupo solo si el estado cambió. Guarda ambos cambios juntos.                                                                                                                                     |
| Observación      | Comprueba la propiedad, ejecuta `addObservation` con autor y fecha del servidor y guarda el agregado.                                                                                                                                                              |
| Inicialización   | Antes del primer registro, crea la capacidad con el límite gratuito y cero animales. Aplica después el límite y revisión vigentes de Subscriptions, si corresponde. Si ya existe, conserva el conteo y contrasta la revisión vigente antes de comprobar los cupos. |
| Cambio de límite | Ejecuta `updateLimit` y guarda únicamente una revisión más reciente. Conserva la cantidad de animales activos.                                                                                                                                                     |

`AnimalController` delega al servicio de comandos o al de consultas. `InventoryCapacityController` utiliza el de consultas. `InventoryCapacityService` accede a su repositorio y al contrato de Subscriptions. Las operaciones de escritura se delimitan como transacciones, es decir, se confirman completas o se deshacen si fallan.

###### Aplicación móvil - Flutter

`LivestockApplicationService` coordina las acciones del ViewModel. Utiliza la sesión de la cuenta, el repositorio y las copias locales. Las operaciones de acceso devuelven `Future`.

| Clase o interfaz              | Propósito                                                                                                | Atributos principales                                                                                                                   | Métodos                                                                                                                                                                                                                                                                                          |
| ----------------------------- | -------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LivestockApplicationService` | Coordinar consultas y modificaciones del módulo.                                                         | `repository: LivestockRepository`, `cache: LivestockCacheGateway`, `session: LivestockSessionGateway`, `connection: ConnectionGateway`. | `getInventory()`, `getAnimal(animalId)`, `getCapacity()`, `registerAnimal(data)`, `updateAnimal(animalId, data)`, `deactivateAnimal(animalId)`, `registerObservation(animalId, content)`, `onSessionClosed(accountId)`, `onConnectionRestored()`.                                                |
| `AnimalInput`                 | Reunir los seis datos editables del formulario.                                                          | `code: String`, `species: String`, `sex: AnimalSex`, `name: String?`, `breed: String?`, `birthDate: DateTime?`.                         | Constructor y lectura de atributos.                                                                                                                                                                                                                                                              |
| `LivestockReadResult<T>`      | Entregar datos de consulta y su procedencia. `T` representa el tipo de dato, como un animal o una lista. | `data: T`, `fromCache: bool`, `updatedAt: DateTime`.                                                                                    | Constructor y lectura de atributos.                                                                                                                                                                                                                                                              |
| `LivestockSessionGateway`     | Consultar la sesión administrada por Identity and Access.                                                | Sin atributos de implementación.                                                                                                        | `requireValidSession()`, `getAccountId()`.                                                                                                                                                                                                                                                       |
| `ConnectionGateway`           | Consultar la disponibilidad de conexión.                                                                 | Sin atributos de implementación.                                                                                                        | `isOnline()`.                                                                                                                                                                                                                                                                                    |
| `LivestockCacheGateway`       | Definir el acceso a copias locales por cuenta.                                                           | Sin atributos de implementación.                                                                                                        | `readInventory(accountId)`, `readAnimal(accountId, animalId)`, `listCachedAnimalIds(accountId)`, `storeInventory(accountId, animals, updatedAt)`, `storeAnimal(accountId, animal, updatedAt)`, `invalidateInventory(accountId)`, `removeAnimal(accountId, animalId)`, `clearAccount(accountId)`. |

`LivestockViewModel` llama a `LivestockApplicationService`. Este descompone `AnimalInput` en sus seis campos al invocar las operaciones del repositorio. Las consultas de inventario y ficha devuelven `LivestockReadResult`, cuyos datos completan la vista, el indicador de consulta local y la fecha de actualización. La capacidad se consulta en línea para orientar el registro. El servidor comprueba el límite al procesar el alta.

| Situación             | Comportamiento                                                                                                                                                                                       |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Consulta con conexión | Usa el repositorio y guarda la respuesta autorizada con su fecha.                                                                                                                                    |
| Consulta sin conexión | Exige una sesión local válida y busca la copia de esa cuenta. Distingue una copia vacía de una copia inexistente.                                                                                    |
| Modificación          | Exige conexión y espera la confirmación del servidor. No guarda operaciones pendientes.                                                                                                              |
| Cierre de sesión      | `onSessionClosed` elimina las copias de la cuenta. Identity and Access elimina los datos de sesión.                                                                                                  |
| Reconexión            | Revalida la sesión, obtiene los identificadores locales con `listCachedAnimalIds` y consulta su acceso antes de reutilizar las copias. Elimina los recursos inexistentes o cuyo acceso fue revocado. |

Un fallo de red puede permitir una consulta local. Una respuesta de sesión inválida o acceso denegado no se sustituye por datos locales. Sin conexión no se puede detectar una revocación ocurrida en el servidor.

##### 2.6.1.4. Infrastructure Layer

Esta capa implementa los contratos de persistencia e integración. El servidor utiliza MySQL y la aplicación móvil utiliza la API y SQLite. Las dependencias de las clases son privadas y las operaciones de sus contratos son públicas.

###### API REST - Java

Se propone utilizar JPA con Hibernate, herramientas que relacionan los objetos Java con las tablas de MySQL. Los objetos de persistencia se mantienen separados de los agregados del dominio.

| Clase                            | Propósito                                                                                  | Atributos principales                                                 | Métodos                                                                                                                                                        |
| -------------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `JpaAnimalRepository`            | Implementar `AnimalRepository` y guardar el animal con sus observaciones.                  | `entityManager: EntityManager`, `mapper: LivestockPersistenceMapper`. | `save(animal)`, `findById(animalId)`, `findByOwnerId(ownerId)`, `existsByOwnerIdAndCode(ownerId, code, excludedAnimalId)`.                                     |
| `JpaInventoryCapacityRepository` | Implementar `InventoryCapacityRepository`.                                                 | `entityManager: EntityManager`, `mapper: LivestockPersistenceMapper`. | `save(capacity)`, `findByOwnerId(ownerId)`.                                                                                                                    |
| `LivestockPersistenceMapper`     | Convertir entre objetos de persistencia y agregados, conservando identificadores y estado. | Sin estado propio.                                                    | `toAnimal(entity)`, `toAnimalEntity(animal)`, `toObservation(entity)`, `toObservationEntity(observation)`, `toCapacity(entity)`, `toCapacityEntity(capacity)`. |
| `SubscriptionsLimitsAdapter`     | Implementar `SubscriptionLimitsGateway` mediante el contrato público de Subscriptions.     | `subscriptionsFacade`, referencia al contrato del contexto proveedor. | `getLimits(ownerId)`.                                                                                                                                          |
| `SubscriptionEventsAdapter`      | Recibir los eventos internos de activación y vencimiento y entregarlos al manejador.       | `handler: SubscriptionLimitChangedHandler`.                           | `onPremiumActivated(event)`, `onPremiumExpired(event)`.                                                                                                        |
| `LivestockContextAdapter`        | Proporcionar datos a Veterinary Care mediante el contrato interno autorizado.              | `queryService: LivestockQueryService`.                                | `getAnimalForCare(ownerId, animalId)`.                                                                                                                         |

`EntityManager` es el componente de persistencia que ejecuta las operaciones sobre MySQL. `LivestockContextAdapter` convierte el resultado autorizado a `AnimalResponse`, sin exponer repositorios ni agregados modificables al otro contexto. Las integraciones se realizan dentro del servidor modular y no requieren un servicio independiente por contexto.

Objetos de persistencia

| Clase                                | Atributos                                                                                                                                                                                                                                             | Métodos y relaciones                                                                                                    |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `AnimalPersistenceEntity`            | `id: UUID`, `ownerId: UUID`, `code: String`, `species: String`, `sex: AnimalSex`, `name: String`, `breed: String`, `birthDate: LocalDate`, `status: AnimalStatus`, `registeredAt: Instant`, `observations: List<AnimalObservationPersistenceEntity>`. | Constructor y accesores de persistencia. Contiene cero o más observaciones. Mantiene los campos opcionales del dominio. |
| `AnimalObservationPersistenceEntity` | `id: UUID`, `animalId: UUID`, `authorId: UUID`, `content: String`, `registeredAt: Instant`.                                                                                                                                                           | Constructor y accesores de persistencia. Cada observación referencia un animal.                                         |
| `InventoryCapacityPersistenceEntity` | `ownerId: UUID`, `allowedAnimals: int`, `activeAnimals: int`, `lastPlanRevision: long`.                                                                                                                                                               | Constructor y accesores de persistencia. Existe un registro por ganadero.                                               |

Se conserva una restricción única para propietario y código, incluidos los animales inactivos. Las bajas actualizan el estado sin borrar filas. Las referencias a usuarios y a información de otros contextos se manejan por identificador.

Al registrar, editar, dar de baja o agregar observaciones, se bloquea primero la fila de capacidad del propietario dentro de la transacción y luego se lee el animal. `JpaInventoryCapacityRepository.findByOwnerId` aplica este bloqueo durante las transacciones de escritura. Los cambios de límite usan el mismo bloqueo. Esto ordena las escrituras por ganadero y evita cupos excedidos, bajas duplicadas y pérdida de actualizaciones. La creación inicial de capacidad utiliza la unicidad de `ownerId` y reintenta la transacción si otra solicitud creó la fila primero.

Spring administra las transacciones. Si falla el guardado del animal o del cupo, se deshacen ambos cambios. Los eventos se entregan después de confirmar la transacción de origen. Las revisiones permiten repetir la aplicación de un límite sin duplicar efectos. Si falla la entrega de un cambio de límite, `getOrCreate` recupera la revisión vigente de Subscriptions al consultar la capacidad o iniciar otra operación. Si no puede verificarla, informa el fallo sin autorizar nuevas altas.

###### Aplicación móvil - Flutter

La implementación del repositorio comunica Flutter con la API. SQLite conserva únicamente las copias de consulta. Los datos de sesión permanecen en el almacenamiento seguro administrado por Identity and Access.

| Clase                       | Propósito                                                                                          | Atributos principales                                               | Métodos                                                                                                                                                                                                                                                                                          |
| --------------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LivestockRepositoryImpl`   | Implementar `LivestockRepository` mediante la API.                                                 | `remote: LivestockRemoteDataSource`, `mapper: LivestockDataMapper`. | `getInventory()`, `getAnimal(animalId)`, `getCapacity()`, `registerAnimal(code, species, sex, name, breed, birthDate)`, `updateAnimal(animalId, code, species, sex, name, breed, birthDate)`, `deactivateAnimal(animalId)`, `registerObservation(animalId, content)`.                            |
| `LivestockRemoteDataSource` | Ejecutar solicitudes y recibir respuestas del servidor.                                            | `httpClient`, cliente con sesión autenticada, y `baseUrl: String`.  | `fetchInventory()`, `fetchAnimal(animalId)`, `fetchCapacity()`, `createAnimal(data)`, `updateAnimal(animalId, data)`, `deactivateAnimal(animalId)`, `createObservation(animalId, content)`.                                                                                                      |
| `SqliteLivestockCache`      | Implementar `LivestockCacheGateway`.                                                               | `database`, conexión a SQLite, y `mapper: LivestockDataMapper`.     | `readInventory(accountId)`, `readAnimal(accountId, animalId)`, `listCachedAnimalIds(accountId)`, `storeInventory(accountId, animals, updatedAt)`, `storeAnimal(accountId, animal, updatedAt)`, `invalidateInventory(accountId)`, `removeAnimal(accountId, animalId)`, `clearAccount(accountId)`. |
| `LivestockDataMapper`       | Convertir respuestas y filas locales a modelos móviles, y preparar datos para su envío o guardado. | Sin estado propio.                                                  | `animalFromJson(data)`, `observationFromJson(data)`, `capacityFromJson(data)`, `animalFromRow(row)`, `observationFromRow(row)`, `animalToRow(animal, accountId)`, `observationToRow(observation, animalId, accountId)`, `inputToJson(data)`.                                                     |
| `IdentitySessionAdapter`    | Implementar `LivestockSessionGateway` utilizando la sesión de Identity and Access.                 | `sessionService`, servicio de sesión del contexto proveedor.        | `requireValidSession()`, `getAccountId()`.                                                                                                                                                                                                                                                       |
| `DeviceConnectionAdapter`   | Implementar `ConnectionGateway` con el estado de conexión del dispositivo.                         | `connectionMonitor`, monitor de conectividad.                       | `isOnline()`.                                                                                                                                                                                                                                                                                    |

JSON es el formato de datos intercambiado con el servidor. El repositorio transforma sus respuestas mediante `LivestockDataMapper`. El servicio de aplicación coordina el guardado de las copias y el acceso sin conexión mediante `SqliteLivestockCache`.

| Aspecto                 | Implementación propuesta                                                                                                                                                                                           |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Separación por cuenta   | Cada copia se identifica con la cuenta que la descargó y el identificador del recurso. `accountId` identifica esa cuenta y puede diferir de `ownerId` en una consulta veterinaria autorizada.                      |
| Inventario y ficha      | Conserva animales, observaciones y fecha de descarga. Registra si el inventario fue descargado, incluso cuando está vacío. Actualizar una ficha invalida cualquier lista anterior que haya quedado desactualizada. |
| Integridad local        | Guarda cada copia y su fecha en una transacción de SQLite. Antes de guardarla comprueba que siga activa la misma cuenta que inició la solicitud.                                                                   |
| Modificación confirmada | Actualiza o invalida las copias afectadas y vuelve a consultar la capacidad después de un alta o una baja. Un fallo local no convierte una modificación ya confirmada en una operación rechazada.                  |
| Acceso denegado         | Elimina la copia del recurso afectado. Una sesión inválida bloquea la consulta y limpia las copias de esa cuenta.                                                                                                  |
| Cierre de sesión        | `clearAccount` borra animales, observaciones y metadatos locales de la cuenta. No elimina registros de MySQL.                                                                                                      |

El indicador de conexión no garantiza que la API responda. Los errores de comunicación se distinguen de los rechazos de autorización. Los intentos de escritura sin respuesta concluyente se informan sin asumir que fallaron ni repetirlos automáticamente.

##### 2.6.1.5. Bounded Context Software Architecture Component Level Diagrams

###### Aplicación móvil - Flutter

El diagrama de componentes del frontend muestra la descomposición de Livestock Management Context en Presentation, Application, Infrastructure y Domain. Presentation gestiona las pantallas y formularios relacionados con el inventario de animales; Application coordina las operaciones del módulo; Domain contiene los modelos y contratos principales; e Infrastructure implementa la comunicación con la REST API y el almacenamiento local en SQLite. El módulo también utiliza Shared para navegación, sesión y elementos comunes de la aplicación móvil.

![Frontend - Livestock Management](<../../assets/images/componets-level-diagrams/Frontend - Livestock Management.png>)

###### API REST - Java

El diagrama de componentes del backend representa Livestock Management Context mediante Interfaces, Application, Infrastructure y Domain. Interfaces expone los endpoints relacionados con animales, observaciones y capacidad del inventario; Application coordina los casos de uso; Domain concentra las reglas y modelos del dominio; e Infrastructure implementa la persistencia mediante JPA e Hibernate sobre MySQL. El backend utiliza además un Shared Kernel para los elementos comunes entre bounded contexts.

![Backend - Livestock Management](<../../assets/images/componets-level-diagrams/Backend - Livestock Management.png>)


##### 2.6.1.6. Bounded Context Software Architecture Code Level Diagrams

###### 2.6.1.6.1. Bounded Context Domain Layer Class Diagrams

Aplicación móvil - Flutter

API REST - Java

###### 2.6.1.6.2. Bounded Context Database Diagram

Base de datos central - MySQL

Base de datos local - SQLite

#### 2.6.2. Bounded Context: Veterinary Care

Atención veterinaria organiza visitas y controles y conserva las atenciones, tratamientos, vacunaciones e indicaciones de cada animal. Comprende US07-US13, US19-US21 y la consulta sin conexión de US29. Consulta los animales en Livestock Management y la autorización en Veterinary Linking. Solicita los avisos mediante Firebase Cloud Messaging.

##### 2.6.2.1. Domain Layer

Se proponen dos agregados: `VeterinaryAppointment` para la programación y `CareRecord` para la atención realizada. El historial se obtiene consultando las atenciones del animal. Los atributos son privados y las operaciones indicadas son públicas. Se mantienen los identificadores `UUID` y las fechas de registro asignadas por el servidor.

###### API REST - Java

Diccionario de clases

| Elemento                | Tipo                    | Responsabilidad                                                                      |
| ----------------------- | ----------------------- | ------------------------------------------------------------------------------------ |
| `VeterinaryAppointment` | Raíz de agregado        | Registrar una visita o un control programado y su estado.                            |
| `CareRecord`            | Raíz de agregado        | Conservar una atención realizada y controlar sus registros complementarios.          |
| `TreatmentRecord`       | Entidad de `CareRecord` | Registrar la descripción y fecha de un tratamiento realizado.                        |
| `VaccinationRecord`     | Entidad de `CareRecord` | Registrar una vacuna aplicada y su fecha.                                            |
| `CareInstructions`      | Entidad de `CareRecord` | Mantener las indicaciones y sus versiones.                                           |
| `InstructionRevision`   | Objeto de valor         | Conservar una versión inmutable con contenido, autor y fecha.                        |
| `CareText`              | Objeto de valor         | Representar un texto obligatorio que no puede estar vacío ni contener solo espacios. |
| `AppointmentType`       | Enumeración             | Distinguir `VISIT`, visita, de `FOLLOW_UP`, control posterior.                       |
| `AppointmentStatus`     | Enumeración             | Distinguir `SCHEDULED`, programada, de `COMPLETED`, con atención registrada.         |

VeterinaryAppointment

| Atributo             | Tipo                | Descripción                                                          |
| -------------------- | ------------------- | -------------------------------------------------------------------- |
| `id`                 | `UUID`              | Identificador de la cita.                                            |
| `animalId`           | `UUID`              | Animal que será atendido.                                            |
| `ownerId`            | `UUID`              | Ganadero propietario del animal.                                     |
| `veterinarianId`     | `UUID`              | Veterinario que programa y realizará la atención.                    |
| `type`               | `AppointmentType`   | Visita o control.                                                    |
| `scheduledAt`        | `Instant`           | Fecha y hora previstas. Deben ser futuras al programar.              |
| `originCareRecordId` | `UUID`              | Atención de origen. Obligatoria para controles y ausente en visitas. |
| `status`             | `AppointmentStatus` | Estado de la cita.                                                   |
| `createdAt`          | `Instant`           | Momento de registro en el servidor.                                  |

| Método             | Responsabilidad                                                       |
| ------------------ | --------------------------------------------------------------------- |
| `scheduleVisit`    | Crear una visita con fecha futura y estado programado.                |
| `scheduleFollowUp` | Crear un control con fecha futura y referencia a una atención previa. |
| `complete`         | Marcar la cita como realizada al confirmar su atención.               |
| `isAssignedTo`     | Comprobar si la cita corresponde al veterinario indicado.             |

Programar una cita no crea una atención. El paso a `COMPLETED` ocurre junto con el guardado de un nuevo `CareRecord`. La relación entre un control y su atención de origen no modifica la atención anterior.

CareRecord

| Atributo         | Tipo                      | Descripción                                                |
| ---------------- | ------------------------- | ---------------------------------------------------------- |
| `id`             | `UUID`                    | Identificador de la atención.                              |
| `animalId`       | `UUID`                    | Animal atendido.                                           |
| `ownerId`        | `UUID`                    | Propietario del animal.                                    |
| `veterinarianId` | `UUID`                    | Autor de la atención.                                      |
| `attendedAt`     | `Instant`                 | Fecha de la atención realizada. No puede ser futura.       |
| `description`    | `CareText`                | Descripción obligatoria de la atención.                    |
| `appointmentId`  | `UUID`                    | Cita asociada, si la atención fue programada. Es opcional. |
| `registeredAt`   | `Instant`                 | Momento en que se registra la atención.                    |
| `treatments`     | `List<TreatmentRecord>`   | Tratamientos asociados, inicialmente vacíos.               |
| `vaccinations`   | `List<VaccinationRecord>` | Vacunaciones asociadas, inicialmente vacías.               |
| `instructions`   | `CareInstructions`        | Indicaciones opcionales.                                   |

| Método                 | Responsabilidad                                                                                                 |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- |
| `register`             | Crear una atención con descripción y fecha válidas.                                                             |
| `addTreatment`         | Añadir un tratamiento con descripción y fecha no futura.                                                        |
| `addVaccination`       | Añadir una vacuna con nombre y fecha de aplicación no futura.                                                   |
| `registerInstructions` | Crear las indicaciones con su primera versión. Si ya existen, corresponde modificarlas.                         |
| `updateInstructions`   | Incorporar una nueva versión sin eliminar las anteriores. Comprueba la revisión que el usuario estaba editando. |
| `isAuthoredBy`         | Comprobar si el veterinario indicado es el autor de la atención.                                                |

El autor puede agregar tratamientos, vacunas e indicaciones mientras conserve una vinculación activa. La ausencia de estos registros no impide guardar una atención válida. La edición de indicaciones no cambia los demás datos de la atención.

Registros complementarios

| Clase                 | Atributos privados                                                          | Métodos y reglas                                                                                                                                                     |
| --------------------- | --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `TreatmentRecord`     | `id: UUID`, `description: CareText`, `performedAt: Instant`.                | Creación mediante `CareRecord.addTreatment` y métodos de lectura. Su autor y animal se obtienen de la atención.                                                      |
| `VaccinationRecord`   | `id: UUID`, `vaccineName: String`, `appliedAt: Instant`.                    | Creación mediante `CareRecord.addVaccination` y métodos de lectura. Rechaza nombres vacíos.                                                                          |
| `CareInstructions`    | `id: UUID`, `authorId: UUID`, `revisions: List<InstructionRevision>`.       | `create`, `revise(content, expectedRevision, authorId, now)`, `getCurrentRevision`, `isAuthoredBy`. Solo su autor puede incorporar versiones, mediante `CareRecord`. |
| `InstructionRevision` | `number: int`, `content: CareText`, `authorId: UUID`, `createdAt: Instant`. | Constructor y métodos de lectura. La numeración empieza en 1 y aumenta al modificar.                                                                                 |
| `CareText`            | `value: String`.                                                            | `of(value)` valida el texto y `getValue()` permite consultarlo.                                                                                                      |

Las colecciones solo permiten lectura desde fuera del agregado. `expectedRevision` identifica la versión que se editó. Si otra solicitud ya la modificó, se rechaza el cambio y se solicita cargar la versión vigente.

Repositorios y eventos

| Elemento                     | Atributos                                                                                             | Métodos o responsabilidad                                                                                                                                    |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `AppointmentRepository`      | Sin atributos de implementación.                                                                      | `save(appointment)`, `findById(appointmentId)`, `findByVeterinarianAndPeriod(veterinarianId, from, to)`. Guarda citas y consulta la agenda.                  |
| `CareRecordRepository`       | Sin atributos de implementación.                                                                      | `save(record)`, `findById(recordId)`, `findByAnimalId(animalId)`, `findByAppointmentId(appointmentId)`. Guarda el agregado completo y consulta el historial. |
| `CareInstructionsRegistered` | `eventId: UUID`, `careRecordId: UUID`, `ownerId: UUID`, `revisionNumber: int`, `occurredAt: Instant`. | Hecho inmutable que identifica el registro de indicaciones. Constructor y métodos de lectura.                                                                |
| `CareInstructionsUpdated`    | `eventId: UUID`, `careRecordId: UUID`, `ownerId: UUID`, `revisionNumber: int`, `occurredAt: Instant`. | Hecho inmutable que identifica una nueva versión. Constructor y métodos de lectura.                                                                          |

| Relación                                                | Descripción                                                                                                              |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `CareRecord` -> `TreatmentRecord` / `VaccinationRecord` | Cada atención contiene cero o más tratamientos y vacunaciones. Cada registro pertenece a una atención.                   |
| `CareRecord` -> `CareInstructions`                      | Cada atención contiene cero o un conjunto de indicaciones.                                                               |
| `CareInstructions` -> `InstructionRevision`             | Contiene una o más versiones. La última es la vigente.                                                                   |
| `VeterinaryAppointment` -> `CareRecord`                 | Un control referencia una atención de origen. Cada cita puede producir una nueva atención, asociada por `appointmentId`. |
| Repositorios -> agregados                               | Las entidades complementarias se guardan mediante `CareRecordRepository`, sin repositorios independientes.               |

Los identificadores de animales y usuarios son referencias a otros contextos. Dar de baja a un animal no elimina sus atenciones ni impide consultar el historial con autorización. Una observación del ganadero tampoco crea automáticamente una cita o atención.

###### Aplicación móvil - Flutter

Los modelos móviles son de solo lectura. Usan `String` para identificadores, `DateTime` para fechas y `?` para campos opcionales. El texto clínico se representa como `String` y el servidor valida las operaciones.

| Clase                                   | Atributos                                                                                                                                                                                                                                                                                          | Métodos y propósito                                                                                               |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `VeterinaryAppointment`                 | `id: String`, `animalId: String`, `ownerId: String`, `veterinarianId: String`, `type: AppointmentType`, `scheduledAt: DateTime`, `originCareRecordId: String?`, `status: AppointmentStatus`, `createdAt: DateTime`.                                                                                | Lectura de la cita y `isCompleted` para consultar su estado.                                                      |
| `CareRecord`                            | `id: String`, `animalId: String`, `ownerId: String`, `veterinarianId: String`, `attendedAt: DateTime`, `description: String`, `appointmentId: String?`, `registeredAt: DateTime`, `treatments: List<TreatmentRecord>`, `vaccinations: List<VaccinationRecord>`, `instructions: CareInstructions?`. | Lectura de la atención. `isAuthoredBy(userId)` identifica a su autor, sin sustituir la autorización del servidor. |
| `TreatmentRecord`                       | `id: String`, `description: String`, `performedAt: DateTime`.                                                                                                                                                                                                                                      | Constructor y lectura del tratamiento.                                                                            |
| `VaccinationRecord`                     | `id: String`, `vaccineName: String`, `appliedAt: DateTime`.                                                                                                                                                                                                                                        | Constructor y lectura de la vacunación.                                                                           |
| `CareInstructions`                      | `id: String`, `authorId: String`, `revisions: List<InstructionRevision>`.                                                                                                                                                                                                                          | Lectura de las indicaciones y `getCurrentRevision()`.                                                             |
| `InstructionRevision`                   | `number: int`, `content: String`, `authorId: String`, `createdAt: DateTime`.                                                                                                                                                                                                                       | Constructor y lectura de una versión.                                                                             |
| `AppointmentType` / `AppointmentStatus` | Los mismos valores definidos para Java.                                                                                                                                                                                                                                                            | Identificar el tipo y el estado de una cita.                                                                      |
| `CareRepository`                        | Sin atributos de implementación.                                                                                                                                                                                                                                                                   | Contrato de consultas y modificaciones descrito a continuación.                                                   |

| Métodos de `CareRepository`                                   | Propósito                                                   |
| ------------------------------------------------------------- | ----------------------------------------------------------- |
| `getAgenda`, `getHistory`, `getCareRecord`, `getInstructions` | Consultar citas propias, historial y registros autorizados. |
| `scheduleVisit`, `scheduleFollowUp`                           | Solicitar la programación de una visita o un control.       |
| `registerCareRecord`, `addTreatment`, `addVaccination`        | Solicitar registros realizados.                             |
| `registerInstructions`, `updateInstructions`                  | Solicitar la creación o modificación de indicaciones.       |

Los métodos devuelven `Future`. Las relaciones entre modelos reproducen las del servidor. Las pantallas no modifican directamente sus colecciones ni construyen atenciones realizadas a partir de citas programadas.

##### 2.6.2.2. Interface Layer

Esta capa recibe solicitudes y muestra sus resultados. La identidad se obtiene de la sesión validada. Los identificadores recibidos en formularios se contrastan con los datos y permisos del servidor.

###### API REST - Java

| Clase                        | Propósito                                                       | Atributos privados                                           | Métodos públicos                                                                                                                                                   |
| ---------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `AppointmentController`      | Recibir solicitudes de programación y consulta de agenda.       | `commands: CareCommandService`, `queries: CareQueryService`. | `scheduleVisit(request)`, `scheduleFollowUp(request)`, `getAgenda(from, to)`.                                                                                      |
| `CareRecordController`       | Recibir registros y consultas de atenciones y sus complementos. | `commands: CareCommandService`, `queries: CareQueryService`. | `registerCareRecord(request)`, `getHistory(ownerId, animalId)`, `getCareRecord(recordId)`, `addTreatment(recordId, request)`, `addVaccination(recordId, request)`. |
| `CareInstructionsController` | Recibir consultas y cambios de indicaciones.                    | `commands: CareCommandService`, `queries: CareQueryService`. | `getInstructions(recordId)`, `registerInstructions(recordId, request)`, `updateInstructions(recordId, request)`.                                                   |

Datos de entrada

| Clase                        | Atributos y propósito                                                                                                                                         | Métodos                |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `ScheduleAppointmentRequest` | `animalId: UUID`, `ownerId: UUID`, `scheduledAt: Instant`, `originCareRecordId: UUID`. La atención de origen solo se utiliza y exige al programar un control. | Constructor y lectura. |
| `RegisterCareRecordRequest`  | `animalId: UUID`, `ownerId: UUID`, `attendedAt: Instant`, `description: String`, `appointmentId: UUID` opcional.                                              | Constructor y lectura. |
| `TreatmentRequest`           | `description: String`, `performedAt: Instant`.                                                                                                                | Constructor y lectura. |
| `VaccinationRequest`         | `vaccineName: String`, `appliedAt: Instant`.                                                                                                                  | Constructor y lectura. |
| `InstructionsRequest`        | `content: String`, `expectedRevision: Integer`. La revisión es obligatoria al editar y se omite al registrar.                                                 | Constructor y lectura. |

Datos de salida

Las respuestas copian los atributos de las clases indicadas en Domain Layer. Los textos `CareText` se convierten a `String` y las colecciones contienen las respuestas complementarias de esta tabla. Todas incluyen `fromDomain` y métodos de lectura, sin modificar los agregados.

| Clase                         | Atributos de referencia                                                                                                            | Propósito                                             |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `AppointmentResponse`         | Los nueve atributos de `VeterinaryAppointment`.                                                                                    | Mostrar una cita y su estado.                         |
| `CareRecordResponse`          | Los once atributos de `CareRecord`. Usa `TreatmentResponse`, `VaccinationResponse` e `InstructionsResponse` para los complementos. | Mostrar una atención con sus registros asociados.     |
| `TreatmentResponse`           | `id`, `description`, `performedAt`, definidos en `TreatmentRecord`.                                                                | Mostrar un tratamiento.                               |
| `VaccinationResponse`         | `id`, `vaccineName`, `appliedAt`, definidos en `VaccinationRecord`.                                                                | Mostrar una vacunación.                               |
| `InstructionsResponse`        | `id`, `authorId`, `revisions`, definidos en `CareInstructions`. La lista contiene `InstructionRevisionResponse`.                   | Mostrar las indicaciones y las versiones conservadas. |
| `InstructionRevisionResponse` | `number`, `content`, `authorId`, `createdAt`, definidos en `InstructionRevision`.                                                  | Mostrar una versión y su autor.                       |

Los controladores delegan a los servicios de aplicación y transforman sus resultados autorizados. Agenda e historial devuelven listas. La confirmación de un registro no afirma que una notificación haya sido entregada al teléfono.

###### Aplicación móvil - Flutter

| Clase                    | Propósito y atributos principales                                                                                                                                                                                                                                                   | Métodos                                                                                                                                                                                                                      |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CareViewModel`          | Estado de presentación: `service: CareApplicationService`, `appointments: List<VeterinaryAppointment>`, `history: List<CareRecord>`, `selectedRecord: CareRecord?`, `actor: CareActor?`, `isLoading: bool`, `isOffline: bool`, `errorMessage: String?`, `lastUpdatedAt: DateTime?`. | `loadSession`, `loadAgenda`, `loadHistory`, `loadCareRecord`, `loadInstructions`, `scheduleVisit`, `scheduleFollowUp`, `registerCareRecord`, `addTreatment`, `addVaccination`, `registerInstructions`, `updateInstructions`. |
| `CareAgendaPage`         | Agenda del veterinario: `viewModel: CareViewModel`, `from: DateTime`, `to: DateTime`.                                                                                                                                                                                               | `build`, `changePeriod`, `openAppointmentForm`.                                                                                                                                                                              |
| `AnimalCareHistoryPage`  | Historial del animal: `viewModel: CareViewModel`, `animalId: String`, `ownerId: String`.                                                                                                                                                                                            | `build`, `refreshHistory`, `openCareRecord`.                                                                                                                                                                                 |
| `CareRecordDetailPage`   | Atención y registros complementarios: `viewModel: CareViewModel`, `recordId: String`.                                                                                                                                                                                               | `build`, `openTreatmentForm`, `openVaccinationForm`, `openInstructionsForm`, `openRevisionHistory`.                                                                                                                          |
| `AppointmentFormPage`    | Datos de programación: `viewModel: CareViewModel`, `animalId: String`, `ownerId: String`, `type: AppointmentType`, `scheduledAt: DateTime?`, `originCareRecordId: String?`.                                                                                                         | `build`, `validateForm`, `submit`.                                                                                                                                                                                           |
| `CareRecordFormPage`     | Datos de atención: `viewModel: CareViewModel`, `animalId: String`, `ownerId: String`, `appointmentId: String?`, `attendedAt: DateTime?`, `description: String`.                                                                                                                     | `build`, `validateForm`, `submit`.                                                                                                                                                                                           |
| `TreatmentForm`          | Tratamiento: `viewModel: CareViewModel`, `recordId: String`, `description: String`, `performedAt: DateTime?`.                                                                                                                                                                       | `build`, `validateForm`, `submit`.                                                                                                                                                                                           |
| `VaccinationForm`        | Vacunación: `viewModel: CareViewModel`, `recordId: String`, `vaccineName: String`, `appliedAt: DateTime?`.                                                                                                                                                                          | `build`, `validateForm`, `submit`.                                                                                                                                                                                           |
| `CareInstructionsForm`   | Indicaciones: `viewModel: CareViewModel`, `recordId: String`, `content: String`, `expectedRevision: int?`.                                                                                                                                                                          | `build`, `validateForm`, `submit`.                                                                                                                                                                                           |
| `CareNotificationRouter` | Abrir una atención desde un aviso: `service: CareApplicationService`.                                                                                                                                                                                                               | `onNotificationOpened(recordId)`.                                                                                                                                                                                            |

Las pantallas y formularios usan `CareViewModel`. El ganadero dispone de consultas y el veterinario de las acciones permitidas por su autoría. El servidor vuelve a comprobar la vinculación. Sin conexión se muestran las copias con su fecha y se deshabilitan las modificaciones. Un conflicto de revisión solicita recargar las indicaciones antes de volver a editarlas.

##### 2.6.2.3. Application Layer

Esta capa coordina las reglas y los permisos. Las dependencias son privadas y las operaciones indicadas son públicas. Los servicios de comandos actúan como manejadores y delimitan las transacciones de escritura.

###### API REST - Java

| Clase o interfaz                 | Propósito                                                                       | Atributos principales                                                                                                                                            | Métodos                                                                                                                                     |
| -------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `CareCommandService`             | Coordinar programación, atenciones y complementos.                              | `appointments: AppointmentRepository`, `records: CareRecordRepository`, `authorization: CareAuthorizationService`, `events: CareEventPublisher`, `clock: Clock`. | `handle(command, actor)` para los siete comandos descritos a continuación.                                                                  |
| `CareQueryService`               | Consultar agenda propia e información clínica autorizada.                       | `appointments: AppointmentRepository`, `records: CareRecordRepository`, `authorization: CareAuthorizationService`.                                               | `getAgenda(actor, from, to)`, `getHistory(actor, ownerId, animalId)`, `getCareRecord(actor, recordId)`, `getInstructions(actor, recordId)`. |
| `CareAuthorizationService`       | Comprobar perfil, vinculación, propiedad del animal y autoría de los registros. | `animals: CareAnimalGateway`, `linking: CareLinkingGateway`.                                                                                                     | `requireVeterinarian(actor)`, `requireAnimalAccess(actor, ownerId, animalId)`, `requireRecordAuthor(actor, record)`.                        |
| `CareInstructionsChangedHandler` | Solicitar el aviso de indicaciones después de confirmar su guardado.            | `notifications: CareNotificationGateway`.                                                                                                                        | `handle(CareInstructionsRegistered)`, `handle(CareInstructionsUpdated)`.                                                                    |
| `CareActor`                      | Identidad obtenida de la sesión validada.                                       | `userId: UUID`, `profile: String`, con el perfil definido por Identity and Access.                                                                               | Constructor y lectura.                                                                                                                      |
| `CareAnimalGateway`              | Contrato para consultar un animal en Livestock Management.                      | Sin atributos de implementación.                                                                                                                                 | `getAnimalForCare(ownerId, animalId)`, que devuelve `CareAnimalData`.                                                                       |
| `CareAnimalData`                 | Datos del animal necesarios para comprobar la operación.                        | `animalId: UUID`, `ownerId: UUID`, `isActive: boolean`.                                                                                                          | Constructor y lectura.                                                                                                                      |
| `CareLinkingGateway`             | Contrato para consultar la autorización en Veterinary Linking.                  | Sin atributos de implementación.                                                                                                                                 | `isActive(veterinarianId, ownerId)`.                                                                                                        |
| `CareEventPublisher`             | Registrar el evento para su procesamiento después de confirmar la transacción.  | Sin atributos de implementación.                                                                                                                                 | `publish(event)`.                                                                                                                           |
| `CareNotificationGateway`        | Solicitar un aviso al propietario, sin incluir contenido clínico.               | Sin atributos de implementación.                                                                                                                                 | `notifyOwner(ownerId, recordId, eventId, revisionNumber)`.                                                                                  |
| `NotificationSubmission`         | Resultado de la solicitud al proveedor.                                         | `accepted: boolean`, `providerMessageId: String` opcional, `error: String` opcional.                                                                             | Constructor y lectura. No representa una entrega confirmada al dispositivo.                                                                 |

`CareAuthorizationService` acepta al propietario o a un veterinario con vinculación activa para las consultas clínicas. Primero valida el perfil y la relación con el `ownerId` recibido. Después contrasta el animal mediante el contrato de Livestock Management. El identificador enviado por el cliente no prueba la propiedad.

| Comando                       | Atributos                                                                                                        | Propósito                                                                         |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `ScheduleVisitCommand`        | `ownerId: UUID`, `animalId: UUID`, `scheduledAt: Instant`.                                                       | Programar una visita para el veterinario identificado.                            |
| `ScheduleFollowUpCommand`     | `ownerId: UUID`, `animalId: UUID`, `scheduledAt: Instant`, `originCareRecordId: UUID`.                           | Programar un control sobre una atención existente del mismo animal y propietario. |
| `RegisterCareRecordCommand`   | `ownerId: UUID`, `animalId: UUID`, `attendedAt: Instant`, `description: String`, `appointmentId: UUID` opcional. | Registrar una atención realizada.                                                 |
| `AddTreatmentCommand`         | `recordId: UUID`, `description: String`, `performedAt: Instant`.                                                 | Añadir un tratamiento a una atención propia.                                      |
| `AddVaccinationCommand`       | `recordId: UUID`, `vaccineName: String`, `appliedAt: Instant`.                                                   | Añadir una vacunación a una atención propia.                                      |
| `RegisterInstructionsCommand` | `recordId: UUID`, `content: String`.                                                                             | Registrar la primera versión de indicaciones.                                     |
| `UpdateInstructionsCommand`   | `recordId: UUID`, `content: String`, `expectedRevision: int`.                                                    | Registrar una nueva versión de indicaciones propias.                              |

Los comandos son inmutables y disponen de constructor y métodos de lectura. Los controladores los construyen junto con `CareActor`, cuya identidad no se toma del cuerpo de la solicitud.

| Flujo                              | Coordinación                                                                                                                                                                        |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Visita o control                   | Exige perfil veterinario, vinculación activa, animal correcto y fecha futura. Para un control verifica la atención de origen, que puede haber sido registrada por otro veterinario. |
| Atención con cita                  | Comprueba que la cita esté programada y corresponda al mismo animal, propietario y veterinario. Guarda una nueva atención y completa la cita en la misma transacción.               |
| Atención sin cita                  | Registra una atención válida sin exigir una programación anterior.                                                                                                                  |
| Tratamiento, vacuna o indicaciones | Exige autoría de la atención y vinculación activa. Aplica las validaciones del agregado y guarda los cambios.                                                                       |
| Actualización de indicaciones      | Además comprueba la autoría de las indicaciones y la revisión esperada. Conserva todas las versiones anteriores.                                                                    |
| Notificación                       | Publica el evento al registrar o actualizar indicaciones. El manejador solicita el aviso después del guardado. Un fallo del proveedor se registra sin deshacer las indicaciones.    |
| Historial e indicaciones           | Valida el acceso y devuelve atenciones ordenadas por fecha, incluso de animales inactivos. Las listas vacías son resultados válidos.                                                |
| Agenda                             | Exige perfil veterinario y filtra por el identificador de la sesión y el período solicitado. La cita no concede por sí sola acceso a información clínica.                           |

`CareCommandService` utiliza los agregados y repositorios. `CareQueryService` utiliza los repositorios y la autorización. `CareInstructionsChangedHandler` utiliza el contrato de notificaciones. La revocación de una vinculación impide nuevas operaciones clínicas, sin borrar ni cancelar automáticamente los registros existentes.

###### Aplicación móvil - Flutter

| Clase o interfaz         | Propósito y atributos                                                                                                                                          | Métodos                                                                                                                                                                                                                                                                                    |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `CareApplicationService` | Coordinar las acciones del ViewModel: `repository: CareRepository`, `cache: CareCacheGateway`, `session: CareSessionGateway`, `connection: ConnectionGateway`. | `getActor`, `getAgenda`, `getHistory`, `getCareRecord`, `getInstructions`, `scheduleVisit`, `scheduleFollowUp`, `registerCareRecord`, `addTreatment`, `addVaccination`, `registerInstructions`, `updateInstructions`, `openNotifiedCareRecord`, `onSessionClosed`, `onConnectionRestored`. |
| `CareActor`              | Identidad móvil de la sesión: `userId: String`, `profile: String`.                                                                                             | Constructor y lectura.                                                                                                                                                                                                                                                                     |
| `CareReadResult<T>`      | Resultado de consulta: `data: T`, `fromCache: bool`, `updatedAt: DateTime`.                                                                                    | Constructor y lectura. `T` identifica el tipo de dato devuelto.                                                                                                                                                                                                                            |
| `CareSessionGateway`     | Consultar la sesión de Identity and Access. Sin atributos de implementación.                                                                                   | `requireValidSession()`, `getActor()`.                                                                                                                                                                                                                                                     |
| `CareCacheGateway`       | Acceder a las copias por cuenta. Sin atributos de implementación.                                                                                              | Operaciones de consulta, guardado y limpieza descritas a continuación.                                                                                                                                                                                                                     |

Se reutilizan `ConnectionGateway` y `DeviceConnectionAdapter`, descritos en Gestión del ganado, como utilidades técnicas de conexión. Esta reutilización no comparte agregados ni crea otro bounded context.

| Métodos de `CareCacheGateway`                                                                     | Datos y finalidad                                                                       |
| ------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `readAgenda(accountId, from, to)`, `storeAgenda(accountId, from, to, appointments, updatedAt)`    | Consultar o guardar una agenda para un período.                                         |
| `readHistory(accountId, animalId)`, `storeHistory(accountId, animalId, records, updatedAt)`       | Consultar o guardar el historial del animal.                                            |
| `readCareRecord(accountId, recordId)`, `storeCareRecord(accountId, record, updatedAt)`            | Consultar o guardar una atención con todos sus complementos e indicaciones.             |
| `listCachedAnimals(accountId)`                                                                    | Obtener los identificadores de animales y propietarios presentes en las copias.         |
| `removeAnimalData(accountId, animalId)`, `invalidateAgenda(accountId)`, `clearAccount(accountId)` | Eliminar información revocada, invalidar una agenda desactualizada o limpiar la cuenta. |

El servicio utiliza los métodos del repositorio con identificadores, fechas y textos del dominio. Las consultas se presentan mediante `CareReadResult`. Las indicaciones sin conexión se obtienen de la atención descargada. Se distinguen las listas vacías de la ausencia de una copia.

Las escrituras requieren conexión y confirmación del servidor. Tras un cambio se actualizan o invalidan el historial, la atención y la agenda afectados. Si la solicitud queda sin respuesta, no se asume que falló ni se reenvía automáticamente.

Al cerrar sesión se eliminan las copias de la cuenta. Al reconectar se validan la sesión y los permisos de los animales descargados, retirando datos revocados e invalidando agendas afectadas. Una respuesta de acceso denegado no se sustituye por una copia local. Abrir un aviso exige sesión y la comprobación de acceso a la atención solicitada.

##### 2.6.2.4. Infrastructure Layer

Esta capa implementa los contratos de acceso a MySQL, SQLite, otros contextos y notificaciones. Los datos veterinarios se mantienen dentro de Veterinary Care, relacionados con animales y usuarios mediante sus identificadores.

###### API REST - Java

| Clase                        | Propósito                                                                         | Atributos principales                                                                                               | Métodos                                                                                                                                                             |
| ---------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `JpaAppointmentRepository`   | Implementar `AppointmentRepository`.                                              | `entityManager: EntityManager`, `mapper: CarePersistenceMapper`.                                                    | `save`, `findById`, `findByVeterinarianAndPeriod`, con los parámetros del contrato.                                                                                 |
| `JpaCareRecordRepository`    | Implementar `CareRecordRepository` y guardar sus entidades complementarias.       | `entityManager: EntityManager`, `mapper: CarePersistenceMapper`.                                                    | `save`, `findById`, `findByAnimalId`, `findByAppointmentId`, con los parámetros del contrato.                                                                       |
| `CarePersistenceMapper`      | Convertir los objetos de persistencia y dominio sin cambiar sus identificadores.  | Sin estado propio.                                                                                                  | `toAppointment`, `toAppointmentEntity`, `toCareRecord`, `toCareRecordEntity`. La conversión de la atención incluye tratamientos, vacunas, indicaciones y versiones. |
| `LivestockAnimalAdapter`     | Implementar `CareAnimalGateway` usando el contrato de Gestión del ganado.         | `livestockContext: LivestockContextAdapter`.                                                                        | `getAnimalForCare(ownerId, animalId)`.                                                                                                                              |
| `VeterinaryLinkingAdapter`   | Implementar `CareLinkingGateway` mediante el contrato de Vinculación veterinaria. | `linkingFacade`, referencia al contrato público del contexto proveedor.                                             | `isActive(veterinarianId, ownerId)`.                                                                                                                                |
| `SpringCareEventPublisher`   | Implementar `CareEventPublisher` utilizando los eventos internos del servidor.    | `eventPublisher`, publicador de eventos de Spring.                                                                  | `publish(event)`.                                                                                                                                                   |
| `CareEventsAdapter`          | Procesar eventos de indicaciones después de confirmar la transacción.             | `handler: CareInstructionsChangedHandler`.                                                                          | `onInstructionsRegistered(event)`, `onInstructionsUpdated(event)`.                                                                                                  |
| `FcmCareNotificationAdapter` | Implementar `CareNotificationGateway` mediante Firebase Cloud Messaging.          | `messagingClient`, cliente del proveedor, y `deviceRegistry`, registro técnico de dispositivos asociados a cuentas. | `notifyOwner(ownerId, recordId, eventId, revisionNumber)`.                                                                                                          |

`LivestockAnimalAdapter` convierte la respuesta de Gestión del ganado a `CareAnimalData`, sin incorporar sus entidades al dominio veterinario.

`JpaAppointmentRepository` y `JpaCareRecordRepository` utilizan JPA con Hibernate. Sus entidades de persistencia permiten construir y leer los siguientes campos. Los atributos referidos a otros contextos son identificadores, sin relaciones directas con sus entidades Java.

| Clase de persistencia                  | Atributos                                                                                                                                                                                                                                                                                                               | Relaciones                                                                                         |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `AppointmentPersistenceEntity`         | `id: UUID`, `animalId: UUID`, `ownerId: UUID`, `veterinarianId: UUID`, `type: AppointmentType`, `scheduledAt: Instant`, `originCareRecordId: UUID`, `status: AppointmentStatus`, `createdAt: Instant`.                                                                                                                  | La atención de origen es opcional en almacenamiento y obligatoria para controles según el dominio. |
| `CareRecordPersistenceEntity`          | `id: UUID`, `animalId: UUID`, `ownerId: UUID`, `veterinarianId: UUID`, `attendedAt: Instant`, `description: String`, `appointmentId: UUID`, `registeredAt: Instant`, `treatments: List<TreatmentPersistenceEntity>`, `vaccinations: List<VaccinationPersistenceEntity>`, `instructions: InstructionsPersistenceEntity`. | Cita e indicaciones opcionales. Contiene tratamientos y vacunaciones.                              |
| `TreatmentPersistenceEntity`           | `id: UUID`, `careRecordId: UUID`, `description: String`, `performedAt: Instant`.                                                                                                                                                                                                                                        | Referencia una atención.                                                                           |
| `VaccinationPersistenceEntity`         | `id: UUID`, `careRecordId: UUID`, `vaccineName: String`, `appliedAt: Instant`.                                                                                                                                                                                                                                          | Referencia una atención.                                                                           |
| `InstructionsPersistenceEntity`        | `id: UUID`, `careRecordId: UUID`, `authorId: UUID`, `revisions: List<InstructionRevisionPersistenceEntity>`.                                                                                                                                                                                                            | Existe como máximo un conjunto de indicaciones por atención.                                       |
| `InstructionRevisionPersistenceEntity` | `instructionsId: UUID`, `number: int`, `content: String`, `authorId: UUID`, `createdAt: Instant`.                                                                                                                                                                                                                       | Pertenece a un conjunto de indicaciones. La combinación de identificador y número es única.        |

Estos objetos disponen de constructor y accesores de persistencia. La base garantiza una sola atención por `appointmentId` no nulo y un solo conjunto de indicaciones por atención. Las versiones se insertan sin sobrescribir las anteriores.

El registro de una atención programada bloquea primero su cita y confirma ambos cambios juntos. Las modificaciones de complementos bloquean la atención antes de leerla y actualizarla. Así se evita que dos solicitudes completen la misma cita o pierdan versiones. Los rechazos deshacen la transacción completa.

Los eventos de indicaciones se procesan después del guardado. Los errores de notificación se capturan y registran sin convertir una atención guardada en un registro fallido. La aceptación de Firebase Cloud Messaging no acredita que el usuario recibió o leyó el aviso. Esta propuesta no incorpora una cola persistente de reintentos.

El aviso contiene una referencia a la atención y un mensaje general. No incluye contenido clínico. El registro de dispositivos respeta la cuenta activa y su cierre de sesión. La aplicación valida el acceso al abrir la referencia.

###### Aplicación móvil - Flutter

| Clase                        | Propósito                                                                               | Atributos principales                                        | Métodos                                                                                                                                                                                                                 |
| ---------------------------- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CareRepositoryImpl`         | Implementar las once operaciones de `CareRepository` mediante el servidor.              | `remote: CareRemoteDataSource`, `mapper: CareDataMapper`.    | `getAgenda`, `getHistory`, `getCareRecord`, `getInstructions`, `scheduleVisit`, `scheduleFollowUp`, `registerCareRecord`, `addTreatment`, `addVaccination`, `registerInstructions`, `updateInstructions`.               |
| `CareRemoteDataSource`       | Enviar solicitudes con la sesión y recibir respuestas.                                  | `httpClient`, cliente autenticado, y `baseUrl: String`.      | `fetchAgenda`, `fetchHistory`, `fetchCareRecord`, `fetchInstructions`, `createVisit`, `createFollowUp`, `createCareRecord`, `createTreatment`, `createVaccination`, `createInstructions`, `updateInstructions`.         |
| `CareDataMapper`             | Convertir las respuestas y las filas locales a modelos móviles.                         | Sin estado propio.                                           | `appointmentFromJson`, `recordFromJson`, `instructionsFromJson`, `appointmentFromRow`, `recordFromRows`, `appointmentToRow`, `recordToRows`. Incluye las conversiones de tratamientos, vacunas y versiones.             |
| `SqliteCareCache`            | Implementar el contrato de copias por cuenta.                                           | `database`, conexión a SQLite, y `mapper: CareDataMapper`.   | `readAgenda`, `storeAgenda`, `readHistory`, `storeHistory`, `readCareRecord`, `storeCareRecord`, `listCachedAnimals`, `removeAnimalData`, `invalidateAgenda`, `clearAccount`, con los parámetros de `CareCacheGateway`. |
| `IdentityCareSessionAdapter` | Implementar `CareSessionGateway` mediante Identity and Access.                          | `sessionService`, servicio de sesión del contexto proveedor. | `requireValidSession()`, `getActor()`.                                                                                                                                                                                  |
| `CarePushAdapter`            | Recibir la apertura de avisos de atención desde la integración móvil de notificaciones. | `notificationRouter: CareNotificationRouter`.                | `onNotificationOpened(message)`. Extrae la referencia y delega la consulta autorizada.                                                                                                                                  |

`CareApplicationService` utiliza el repositorio para las operaciones remotas y `SqliteCareCache` para las copias. `CareRepositoryImpl` usa el origen remoto y el conversor de datos. `CarePushAdapter` participa en la integración común de notificaciones, sin crear otra cuenta ni otra sesión.

| Aspecto local       | Implementación propuesta                                                                                                                                                                                          |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Identificación      | Cada copia incluye `accountId` y el identificador del recurso. La cuenta que descarga puede ser distinta del propietario del animal.                                                                              |
| Datos guardados     | Citas, atenciones, tratamientos, vacunas e indicaciones con sus versiones descargadas. Los rangos de agenda y los historiales incluyen fecha de descarga y constancia de copia completa, incluso si están vacíos. |
| Consistencia        | Cada respuesta completa y sus metadatos se guardan juntos en SQLite. Una consulta de indicaciones aislada no marca toda una atención o historial como descargado.                                                 |
| Cambios confirmados | Se actualizan o invalidan las copias relacionadas. Un fallo de SQLite no revierte el éxito de un registro confirmado por el servidor.                                                                             |
| Autorización        | Los rechazos eliminan las copias afectadas. Al perder acceso a un animal también se invalidan los historiales, indicaciones y agendas locales que lo incluyen.                                                    |
| Cambio de cuenta    | Antes de guardar una respuesta se comprueba que continúe activa la cuenta que inició la solicitud. El cierre elimina sus copias y metadatos.                                                                      |

SQLite no conserva credenciales ni funciona como una cola de modificaciones. Las fechas de agenda se intercambian con información de zona horaria y se muestran en la hora local del dispositivo. Sin conexión solo se consulta información previamente descargada.

##### 2.6.2.5. Bounded Context Software Architecture Component Level Diagrams

###### Aplicación móvil - Flutter

El diagrama de componentes del frontend de Veterinary Care Context se organiza en Presentation, Application, Infrastructure y Domain. Presentation gestiona la agenda, el historial y los formularios de atención veterinaria; Application coordina las consultas y registros del módulo; Domain representa citas, atenciones, tratamientos, vacunaciones e indicaciones; e Infrastructure implementa la comunicación con la REST API, el almacenamiento local en SQLite y la integración técnica con notificaciones. Shared proporciona los elementos comunes de la aplicación móvil.

![Frontend - Veterinary Care](<../../assets/images/componets-level-diagrams/Frontend - Veterinary Care.png>)

###### API REST - Java

El backend de Veterinary Care Context se descompone en Interfaces, Application, Infrastructure y Domain. Interfaces recibe las solicitudes relacionadas con visitas, controles y atenciones; Application coordina los casos de uso y las autorizaciones; Domain concentra las reglas de las citas y registros veterinarios; e Infrastructure gestiona la persistencia en MySQL y las integraciones con Livestock Management, Veterinary Linking y Firebase Cloud Messaging. También se utiliza el Shared Kernel para elementos comunes del backend.

![Backend - Veterinary Care](<../../assets/images/componets-level-diagrams/Backend - Veterinary Care.png>)

##### 2.6.2.6. Bounded Context Software Architecture Code Level Diagrams

###### 2.6.2.6.1. Bounded Context Domain Layer Class Diagrams

Aplicación móvil - Flutter

API REST - Java

###### 2.6.2.6.2. Bounded Context Database Diagram

Base de datos central - MySQL

Base de datos local - SQLite

#### 2.6.3. Bounded Context: Veterinary Linking

Vinculación veterinaria gestiona las invitaciones entre ganaderos y veterinarios, su aceptación o rechazo y la revocación del acceso. Comprende US14-US18 y aplica los límites comunicados por Suscripciones en US23-US24. Atención veterinaria consulta este contexto para comprobar si existe una vinculación activa.

##### 2.6.3.1. Domain Layer

Se proponen tres agregados: `LinkingInvitation`, `VeterinaryLink` y `LinkingCapacity`. Sus atributos son privados y sus operaciones son públicas. En Java se utiliza `UUID` para los identificadores y `Instant` para las fechas asignadas por el servidor.

###### API REST - Java

Diccionario de clases

| Elemento            | Tipo             | Responsabilidad                                                                 |
| ------------------- | ---------------- | ------------------------------------------------------------------------------- |
| `LinkingInvitation` | Raíz de agregado | Registrar la invitación y permitir una única respuesta de su destinatario.      |
| `VeterinaryLink`    | Raíz de agregado | Representar la autorización del ganadero al veterinario y su revocación.        |
| `LinkingCapacity`   | Raíz de agregado | Controlar cuántos ganaderos puede tener vinculados un veterinario.              |
| `InvitationStatus`  | Enumeración      | Distinguir `PENDING`, pendiente, `ACCEPTED`, aceptada, y `REJECTED`, rechazada. |
| `LinkStatus`        | Enumeración      | Distinguir `ACTIVE`, activa, de `REVOKED`, revocada.                            |

LinkingInvitation

| Atributo         | Tipo               | Descripción                                          |
| ---------------- | ------------------ | ---------------------------------------------------- |
| `id`             | `UUID`             | Identificador de la invitación.                      |
| `ownerId`        | `UUID`             | Ganadero que invita.                                 |
| `veterinarianId` | `UUID`             | Veterinario destinatario.                            |
| `status`         | `InvitationStatus` | Estado actual de la invitación.                      |
| `createdAt`      | `Instant`          | Fecha de creación.                                   |
| `respondedAt`    | `Instant`          | Fecha de respuesta. Ausente mientras esté pendiente. |

| Método                                 | Responsabilidad                                            |
| -------------------------------------- | ---------------------------------------------------------- |
| `create(ownerId, veterinarianId, now)` | Crear una invitación pendiente.                            |
| `accept(veterinarianId, now)`          | Aceptar solo si está pendiente y responde el destinatario. |
| `reject(veterinarianId, now)`          | Rechazar bajo las mismas condiciones, sin conceder acceso. |
| `isPending()`                          | Consultar si todavía admite respuesta.                     |
| `isAddressedTo(veterinarianId)`        | Comprobar el destinatario.                                 |

VeterinaryLink

| Atributo         | Tipo         | Descripción                                        |
| ---------------- | ------------ | -------------------------------------------------- |
| `id`             | `UUID`       | Identificador de la vinculación.                   |
| `invitationId`   | `UUID`       | Invitación aceptada que originó la vinculación.    |
| `ownerId`        | `UUID`       | Ganadero que autoriza el acceso.                   |
| `veterinarianId` | `UUID`       | Veterinario autorizado.                            |
| `status`         | `LinkStatus` | Estado de la autorización.                         |
| `activatedAt`    | `Instant`    | Fecha de activación.                               |
| `revokedAt`      | `Instant`    | Fecha de revocación. Ausente mientras esté activa. |

| Método                      | Responsabilidad                                                                                 |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| `activate(invitation, now)` | Crear una vinculación a partir de una invitación aceptada y copiar sus participantes.           |
| `revoke(ownerId, now)`      | Revocar solo por solicitud del ganadero propietario. Devuelve si hubo un cambio real de estado. |
| `isActive()`                | Consultar si concede autorización.                                                              |
| `belongsTo(ownerId)`        | Comprobar al ganadero propietario.                                                              |

Revocar conserva la vinculación y el historial de atenciones. Una solicitud repetida devuelve el estado existente y no vuelve a liberar capacidad. Una nueva invitación tras un rechazo o una revocación se registra por separado, siempre que no exista otra pendiente ni una vinculación activa entre las mismas personas.

LinkingCapacity

| Atributo           | Tipo   | Descripción                                   |
| ------------------ | ------ | --------------------------------------------- |
| `veterinarianId`   | `UUID` | Identificador del veterinario y del agregado. |
| `allowedRanchers`  | `int`  | Límite vigente de ganaderos vinculados.       |
| `activeLinks`      | `int`  | Cantidad de vinculaciones activas.            |
| `lastPlanRevision` | `long` | Última revisión de los límites aplicada.      |

| Método                                   | Responsabilidad                                                                |
| ---------------------------------------- | ------------------------------------------------------------------------------ |
| `create(veterinarianId, freeLimit)`      | Iniciar la capacidad gratuita sin vinculaciones activas.                       |
| `hasAvailableSlot()`                     | Comprobar que `activeLinks` sea menor que `allowedRanchers`.                   |
| `occupySlot()`                           | Incrementar el contador si existe capacidad.                                   |
| `releaseSlot()`                          | Disminuirlo al revocar una vinculación activa, sin permitir valores negativos. |
| `updateLimit(allowedRanchers, revision)` | Aplicar un límite no negativo únicamente si la revisión es más reciente.       |

El límite se comprueba al aceptar, no al recibir invitaciones. Rechazar no consume capacidad. Al vencer premium se mantienen las vinculaciones existentes y se bloquean nuevas aceptaciones mientras se alcance o supere el límite gratuito. La revisión del plan permite descartar mensajes repetidos o antiguos.

Repositorios del dominio

| Interfaz                    | Propósito                                   | Métodos                                                                                                                                                    |
| --------------------------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `InvitationRepository`      | Recuperar y guardar invitaciones.           | `save(invitation)`, `findById(id)`, `findPendingByVeterinarianId(veterinarianId)`, `existsPendingByPair(ownerId, veterinarianId)`.                         |
| `VeterinaryLinkRepository`  | Recuperar y guardar vinculaciones.          | `save(link)`, `findById(id)`, `findActiveByOwnerId(ownerId)`, `findActiveByVeterinarianId(veterinarianId)`, `existsActiveByPair(ownerId, veterinarianId)`. |
| `LinkingCapacityRepository` | Conservar la capacidad de cada veterinario. | `save(capacity)`, `findByVeterinarianId(veterinarianId)`.                                                                                                  |

Estas interfaces no tienen atributos. La aplicación coordina los repositorios para guardar la aceptación, la vinculación y el incremento de capacidad en una sola operación de base de datos.

Relaciones principales

| Relación                 | Descripción                                                                                           |
| ------------------------ | ----------------------------------------------------------------------------------------------------- |
| Invitación y vinculación | Una invitación origina cero o una vinculación. Cada vinculación procede de una invitación aceptada.   |
| Participantes            | Cada invitación y vinculación identifica a un ganadero y un veterinario mediante sus identificadores. |
| Veterinario y capacidad  | Cada veterinario tiene un registro de capacidad que contabiliza sus vinculaciones activas.            |
| Estados                  | `LinkingInvitation` utiliza `InvitationStatus` y `VeterinaryLink` utiliza `LinkStatus`.               |

No se incorporan vencimiento de invitaciones ni cancelación automática de citas. La revocación cambia la autorización consultada por Atención veterinaria, sin modificar directamente sus registros.

###### Aplicación móvil - Flutter

El móvil utiliza modelos de lectura. Los identificadores se representan con `String`, las fechas con `DateTime` y los valores opcionales con `?`. Las reglas de autorización y capacidad se aplican en el servidor.

| Elemento               | Atributos                                                                                                                                                 | Métodos y propósito                                                                                                                                                                |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LinkingInvitation`    | `id: String`, `ownerId: String`, `veterinarianId: String`, `status: InvitationStatus`, `createdAt: DateTime`, `respondedAt: DateTime?`.                   | Constructor, lectura e `isPending()`. Mostrar una invitación.                                                                                                                      |
| `VeterinaryLink`       | `id: String`, `invitationId: String`, `ownerId: String`, `veterinarianId: String`, `status: LinkStatus`, `activatedAt: DateTime`, `revokedAt: DateTime?`. | Constructor, lectura e `isActive()`. Mostrar la autorización.                                                                                                                      |
| `LinkingCapacity`      | `veterinarianId: String`, `allowedRanchers: int`, `activeLinks: int`.                                                                                     | Constructor, lectura y `hasAvailableSlot()`. Mostrar la capacidad informada por el servidor.                                                                                       |
| `InvitationStatus`     | Valores `pending`, `accepted`, `rejected`.                                                                                                                | Representar el estado de la invitación.                                                                                                                                            |
| `LinkStatus`           | Valores `active`, `revoked`.                                                                                                                              | Representar el estado de la vinculación.                                                                                                                                           |
| `InvitationSubmission` | `invitation: LinkingInvitation`, `emailAccepted: bool`.                                                                                                   | Constructor y lectura. Distinguir el registro de la invitación de la aceptación del envío de correo.                                                                               |
| `LinkingRepository`    | Sin atributos por ser una interfaz.                                                                                                                       | `sendInvitation(email)`, `acceptInvitation(invitationId)`, `rejectInvitation(invitationId)`, `getPendingInvitations()`, `getActiveLinks()`, `revokeLink(linkId)`, `getCapacity()`. |

Las operaciones del repositorio devuelven resultados mediante `Future`, que representa una respuesta que llegará después de la solicitud. La aplicación puede mostrar los identificadores de los participantes sin descargar sus cuentas completas.

##### 2.6.3.2. Interface Layer

La identidad y el perfil proceden de la sesión validada. El cliente no puede elegir quién actúa como remitente o quién responde una invitación.

###### API REST - Java

| Clase                       | Propósito                                         | Atributos privados                                                                                                | Métodos públicos                                                                                                          |
| --------------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `InvitationController`      | Recibir solicitudes y respuestas de invitaciones. | `commands: LinkingCommandService`, `queries: LinkingQueryService`, `submission: InvitationSubmissionCoordinator`. | `sendInvitation(request)`, `acceptInvitation(invitationId)`, `rejectInvitation(invitationId)`, `getPendingInvitations()`. |
| `VeterinaryLinkController`  | Consultar vinculaciones y revocar acceso.         | `commands: LinkingCommandService`, `queries: LinkingQueryService`.                                                | `getActiveLinks()`, `revokeLink(linkId)`.                                                                                 |
| `LinkingCapacityController` | Mostrar la capacidad del veterinario autenticado. | `queries: LinkingQueryService`.                                                                                   | `getCapacity()`.                                                                                                          |

Datos de entrada y salida

| Clase                          | Atributos                                                           | Propósito y métodos                                                                   |
| ------------------------------ | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `SendInvitationRequest`        | `email: String`.                                                    | Correo del destinatario. Constructor y lectura.                                       |
| `InvitationResponse`           | Los seis atributos de `LinkingInvitation`.                          | Mostrar una invitación. `fromDomain` y lectura.                                       |
| `VeterinaryLinkResponse`       | Los siete atributos de `VeterinaryLink`.                            | Mostrar una vinculación. `fromDomain` y lectura.                                      |
| `LinkingCapacityResponse`      | `veterinarianId: UUID`, `allowedRanchers: int`, `activeLinks: int`. | Mostrar capacidad y uso. `fromDomain` y lectura.                                      |
| `InvitationSubmissionResponse` | `invitation: InvitationResponse`, `emailAccepted: boolean`.         | Informar el registro y el resultado de la solicitud de correo. Constructor y lectura. |

Aceptar, rechazar y revocar requieren el identificador del recurso, sin datos de autor enviados en el formulario. Las consultas devuelven únicamente recursos del usuario autenticado. `emailAccepted` no confirma que el destinatario haya recibido o leído el correo.

###### Aplicación móvil - Flutter

| Clase                    | Propósito y atributos                                                                                                                                                                                                                                          | Métodos                                                                                                                                              |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LinkingViewModel`       | Estado de presentación: `service: LinkingApplicationService`, `invitations: List<LinkingInvitation>`, `links: List<VeterinaryLink>`, `capacity: LinkingCapacity?`, `actor: LinkingActor?`, `isLoading: bool`, `errorMessage: String?`, `emailAccepted: bool?`. | `loadSession`, `loadInvitations`, `loadLinks`, `loadCapacity`, `sendInvitation`, `acceptInvitation`, `rejectInvitation`, `revokeLink`, `clearState`. |
| `InvitationFormPage`     | Formulario del ganadero: `viewModel: LinkingViewModel`, `email: String`.                                                                                                                                                                                       | `build`, `validateForm`, `submit`.                                                                                                                   |
| `PendingInvitationsPage` | Invitaciones del veterinario: `viewModel: LinkingViewModel`.                                                                                                                                                                                                   | `build`, `refreshInvitations`, `acceptInvitation`, `rejectInvitation`.                                                                               |
| `ActiveLinksPage`        | Vinculaciones del usuario: `viewModel: LinkingViewModel`.                                                                                                                                                                                                      | `build`, `refreshLinks`, `confirmRevocation`.                                                                                                        |

El ganadero puede invitar y revocar. El veterinario puede responder y consultar su capacidad. Alcanzar el límite no deshabilita el rechazo de invitaciones. Después de una aceptación se actualizan las listas y el contador. Si falla el correo, se informa que la invitación existe y que su envío no está confirmado.

##### 2.6.3.3. Application Layer

Esta capa coordina identidad, invitaciones, vinculaciones, capacidad y correo. Los servicios reciben un `LinkingActor` obtenido de la sesión, no del contenido de la solicitud.

###### API REST - Java

Servicios y contratos

| Clase o interfaz                  | Propósito y atributos                                                                                                                                                                       | Métodos                                                                                                                             |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `LinkingCommandService`           | Coordinar cambios: `invitations: InvitationRepository`, `links: VeterinaryLinkRepository`, `capacities: LinkingCapacityService`, `directory: VeterinarianDirectoryGateway`, `clock: Clock`. | `handle(command, actor)` para los cuatro comandos.                                                                                  |
| `LinkingQueryService`             | Consultar datos autorizados: los dos repositorios de invitaciones y vinculaciones y `capacities: LinkingCapacityService`.                                                                   | `getPendingInvitations(actor)`, `getActiveLinks(actor)`, `getCapacity(actor)`, `isActive(veterinarianId, ownerId)`.                 |
| `LinkingCapacityService`          | Inicializar y actualizar capacidad: `repository: LinkingCapacityRepository`, `limits: VeterinaryPlanLimitsGateway`.                                                                         | `getOrCreate(veterinarianId)`, `refreshLimit(capacity)`, `save(capacity)`, `applyLimit(veterinarianId, allowedRanchers, revision)`. |
| `VeterinaryPlanChangedHandler`    | Aplicar cambios del plan veterinario: `capacities: LinkingCapacityService`.                                                                                                                 | `onPremiumActivated(message)`, `onPremiumExpired(message)`.                                                                         |
| `InvitationSubmissionCoordinator` | Separar guardado y correo: `commands: LinkingCommandService`, `directory: VeterinarianDirectoryGateway`, `delivery: InvitationDeliveryService`.                                             | `submit(command, actor)`. Coordina el registro confirmado y devuelve invitación más resultado del correo.                           |
| `InvitationDeliveryService`       | Solicitar correo después de guardar la invitación: `mail: InvitationMailGateway`.                                                                                                           | `send(invitation, recipientEmail)`.                                                                                                 |
| `LinkingActor`                    | Identidad validada: `userId: UUID`, `profile: String`.                                                                                                                                      | Constructor y lectura.                                                                                                              |
| `VeterinarianDirectoryGateway`    | Consultar un veterinario registrado, sin atributos por ser interfaz.                                                                                                                        | `findByEmail(email)`.                                                                                                               |
| `VeterinarianContact`             | Resultado de la consulta: `userId: UUID`, `email: String`.                                                                                                                                  | Constructor y lectura. Solo representa cuentas con perfil veterinario.                                                              |
| `VeterinaryPlanLimitsGateway`     | Consultar el límite vigente en Suscripciones, sin atributos.                                                                                                                                | `getLimits(veterinarianId)`.                                                                                                        |
| `VeterinaryPlanLimits`            | Datos del plan: `veterinarianId: UUID`, `freeLimit: int`, `allowedRanchers: int`, `revision: long`.                                                                                         | Constructor y lectura.                                                                                                              |
| `InvitationMailGateway`           | Solicitar correo de invitación, sin atributos.                                                                                                                                              | `sendInvitation(recipientEmail, invitationId, ownerId)`.                                                                            |
| `InvitationMailResult`            | Resultado del envío: `accepted: boolean`, `providerMessageId: String` opcional, `error: String` opcional.                                                                                   | Constructor y lectura.                                                                                                              |

Comandos

| Clase                     | Atributos             | Propósito                            |
| ------------------------- | --------------------- | ------------------------------------ |
| `SendInvitationCommand`   | `email: String`.      | Invitar a un veterinario registrado. |
| `AcceptInvitationCommand` | `invitationId: UUID`. | Aceptar una invitación pendiente.    |
| `RejectInvitationCommand` | `invitationId: UUID`. | Rechazar una invitación pendiente.   |
| `RevokeLinkCommand`       | `linkId: UUID`.       | Retirar la autorización concedida.   |

Los comandos son inmutables y disponen de constructor y métodos de lectura. El servicio comprueba el perfil antes de ejecutar la operación y utiliza el reloj del servidor para registrar las fechas.

Flujos de aplicación

| Operación               | Validaciones y resultado                                                                                                                                                                                                                              |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Enviar invitación       | Exigir perfil ganadero, resolver el correo de un veterinario registrado y comprobar que no existan invitación pendiente ni vinculación activa entre ambos. Guardar la invitación pendiente y después solicitar el correo.                             |
| Aceptar                 | Exigir que responda el veterinario destinatario y que la invitación siga pendiente. Consultar el límite vigente, comprobar capacidad y ausencia de vinculación activa. Guardar aceptación, nueva vinculación e incremento del contador conjuntamente. |
| Rechazar                | Comprobar destinatario y estado pendiente. Registrar el rechazo sin consultar disponibilidad del plan ni cambiar el contador.                                                                                                                         |
| Revocar                 | Comprobar que el actor sea el ganadero de la vinculación. Revocar y liberar un cupo únicamente cuando estaba activa. Guardar ambos cambios conjuntamente.                                                                                             |
| Consultar pendientes    | Devolver solo invitaciones pendientes del veterinario autenticado. Una lista vacía es válida.                                                                                                                                                         |
| Consultar vinculaciones | Filtrar por ganadero o veterinario según la sesión. No permitir consultar la cartera de otra cuenta.                                                                                                                                                  |
| Actualizar límite       | Procesar únicamente cambios del perfil veterinario y revisiones más recientes. Conservar las vinculaciones y el contador aunque superen el nuevo límite.                                                                                              |
| Consultar autorización  | Responder si existe una vinculación activa para el par indicado. Es un contrato interno utilizado por Atención veterinaria después de validar la identidad del usuario.                                                                               |

`getOrCreate` recupera el registro existente o consulta el límite gratuito de Suscripciones para crearlo con contador cero. `refreshLimit` obtiene la revisión vigente antes de aceptar nuevas vinculaciones. Si no se puede verificar el límite, no se confirma la aceptación. Rechazar y revocar no dependen de la disponibilidad de Suscripciones.

El envío de correo se realiza después de confirmar el guardado. Si Resend rechaza la solicitud o no responde, la invitación permanece pendiente y la operación informa que el correo no está confirmado. El correo no activa la vinculación.

###### Aplicación móvil - Flutter

| Clase o interfaz            | Propósito y atributos                                                                                                                | Métodos                                                                                                                                                          |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LinkingApplicationService` | Coordinar operaciones del móvil: `repository: LinkingRepository`, `session: LinkingSessionGateway`, `connection: ConnectionGateway`. | `getActor`, `getPendingInvitations`, `getActiveLinks`, `getCapacity`, `sendInvitation`, `acceptInvitation`, `rejectInvitation`, `revokeLink`, `onSessionClosed`. |
| `LinkingSessionGateway`     | Obtener la sesión actual, sin atributos.                                                                                             | `requireValidSession()`, `getActor()`.                                                                                                                           |
| `LinkingActor`              | Identidad de la sesión: `userId: String`, `profile: String`.                                                                         | Constructor y lectura.                                                                                                                                           |

Se reutiliza `ConnectionGateway` como contrato técnico para comprobar conexión. Estas operaciones requieren acceso al servidor. La información mostrada en memoria no se utiliza para autorizar atenciones ni confirmar aceptaciones sin conexión.

El servicio devuelve modelos del dominio y `InvitationSubmission` al invitar. La presentación limpia su estado al cerrar o cambiar de cuenta y descarta respuestas que correspondan a una sesión anterior. Si se pierde la respuesta de una operación, se consultan las listas antes de repetirla.

##### 2.6.3.4. Infrastructure Layer

Esta capa implementa la persistencia en MySQL y la comunicación con Identidad y acceso, Suscripciones y Resend. Las vinculaciones se consultan en el servidor y no se almacenan como permisos permanentes del dispositivo.

###### API REST - Java

Repositorios e integraciones

| Clase                                  | Propósito y atributos                                                                        | Métodos                                                                                           |
| -------------------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `JpaInvitationRepository`              | Persistir invitaciones: `entityManager: EntityManager`, `mapper: LinkingPersistenceMapper`.  | Implementa los cuatro métodos de `InvitationRepository`.                                          |
| `JpaVeterinaryLinkRepository`          | Persistir vinculaciones: `entityManager: EntityManager`, `mapper: LinkingPersistenceMapper`. | Implementa los cinco métodos de `VeterinaryLinkRepository`.                                       |
| `JpaLinkingCapacityRepository`         | Persistir capacidad: `entityManager: EntityManager`, `mapper: LinkingPersistenceMapper`.     | `save`, `findByVeterinarianId`.                                                                   |
| `LinkingPersistenceMapper`             | Convertir agregados y registros de persistencia, sin estado propio.                          | `toInvitation`, `toInvitationEntity`, `toLink`, `toLinkEntity`, `toCapacity`, `toCapacityEntity`. |
| `IdentityVeterinarianAdapter`          | Consultar destinatarios: `identityFacade`, contrato interno de Identidad y acceso.           | `findByEmail(email)`. Devuelve `VeterinarianContact` si el perfil corresponde.                    |
| `SubscriptionsVeterinaryLimitsAdapter` | Obtener límites: `subscriptionsFacade`, contrato interno de Suscripciones.                   | `getLimits(veterinarianId)`. Devuelve `VeterinaryPlanLimits`.                                     |
| `VeterinaryPlanEventsAdapter`          | Recibir cambios del plan: `handler: VeterinaryPlanChangedHandler`.                           | `onPremiumActivated`, `onPremiumExpired`.                                                         |
| `VeterinaryLinkingFacade`              | Exponer autorización a otros contextos: `queries: LinkingQueryService`.                      | `isActive(veterinarianId, ownerId)`.                                                              |
| `ResendInvitationMailAdapter`          | Implementar correo: `resendClient`, cliente del servicio, y `senderEmail: String`.           | `sendInvitation(recipientEmail, invitationId, ownerId)`. Devuelve `InvitationMailResult`.         |

El controlador utiliza `InvitationSubmissionCoordinator` para el envío completo. Sus demás operaciones delegan directamente a los servicios de aplicación. La transacción de `LinkingCommandService` termina antes de que el coordinador llame a Resend. El destinatario resuelto debe coincidir con `veterinarianId` de la invitación guardada.

JPA, la interfaz de persistencia de Java, se utiliza con Hibernate para guardar los registros. `EntityManager` administra las consultas y los cambios dentro de la transacción de Spring Boot.

Clases de persistencia

| Clase                              | Atributos                                                                                                                                               | Métodos                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `InvitationPersistenceEntity`      | `id: UUID`, `ownerId: UUID`, `veterinarianId: UUID`, `status: InvitationStatus`, `createdAt: Instant`, `respondedAt: Instant` opcional.                 | Constructor y acceso a los campos para persistencia. |
| `VeterinaryLinkPersistenceEntity`  | `id: UUID`, `invitationId: UUID`, `ownerId: UUID`, `veterinarianId: UUID`, `status: LinkStatus`, `activatedAt: Instant`, `revokedAt: Instant` opcional. | Constructor y acceso a los campos para persistencia. |
| `LinkingCapacityPersistenceEntity` | `veterinarianId: UUID`, `allowedRanchers: int`, `activeLinks: int`, `lastPlanRevision: long`.                                                           | Constructor y acceso a los campos para persistencia. |

Se utiliza una clave única por `invitationId` en las vinculaciones y por `veterinarianId` en capacidad. Los participantes de otros contextos se guardan como identificadores, sin incorporar sus entidades Java a estos agregados.

Para evitar aceptaciones simultáneas que superen el límite, los cambios bloquean primero la fila de capacidad del veterinario y después la invitación o vinculación correspondiente. El mismo orden se usa al enviar invitaciones para comprobar duplicados, al responder y al revocar. Rechazar y revocar usan la fila ya existente, sin consultar el plan. Si dos solicitudes intentan crearla a la vez, la operación afectada se reintenta desde el inicio.

Así, solo una solicitud puede validar y modificar a la vez las relaciones de un veterinario. Las comprobaciones de invitación pendiente y vinculación activa se realizan dentro de esa transacción. Los cambios de límite también respetan el bloqueo y nunca reemplazan el contador de vinculaciones.

Atención veterinaria utiliza `VeterinaryLinkingFacade.isActive`, compatible con `CareLinkingGateway` del apartado anterior. Una revocación confirmada hace que las nuevas comprobaciones devuelvan acceso inactivo. No se eliminan atenciones ni se cancelan citas automáticamente.

###### Aplicación móvil - Flutter

| Clase                           | Propósito y atributos                                                                           | Métodos                                                                                                                                   |
| ------------------------------- | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `LinkingRepositoryImpl`         | Implementar el repositorio: `remote: LinkingRemoteDataSource`, `mapper: LinkingDataMapper`.     | Los siete métodos definidos en `LinkingRepository`.                                                                                       |
| `LinkingRemoteDataSource`       | Comunicarse con el servidor: `httpClient`, cliente autenticado compartido, y `baseUrl: String`. | `createInvitation`, `acceptInvitation`, `rejectInvitation`, `fetchPendingInvitations`, `fetchActiveLinks`, `revokeLink`, `fetchCapacity`. |
| `LinkingDataMapper`             | Convertir respuestas del servidor, sin estado propio.                                           | `invitationFromJson`, `linkFromJson`, `capacityFromJson`, `submissionFromJson`.                                                           |
| `IdentityLinkingSessionAdapter` | Implementar la consulta de sesión: `sessionService`, servicio compartido de Identidad y acceso. | `requireValidSession`, `getActor`.                                                                                                        |

Se reutiliza `DeviceConnectionAdapter` para conocer la disponibilidad de conexión. No se propone una base SQLite para este contexto, porque las historias de consulta sin conexión no incluyen invitaciones o vinculaciones. Las listas se mantienen en memoria durante la sesión y se actualizan desde el servidor.

Los contextos que conservan historiales o indicaciones descargadas comprueban nuevamente sus permisos al recuperar conexión. Si se revocó el acceso, eliminan las copias afectadas según US29 y TS03. El dispositivo no puede detectar una revocación nueva mientras permanece sin conexión.

##### 2.6.3.5. Bounded Context Software Architecture Component Level Diagrams

##### 2.6.3.5. Bounded Context Software Architecture Component Level Diagrams

###### Aplicación móvil - Flutter

El frontend de Veterinary Linking Context se divide en Presentation, Application, Infrastructure y Domain. Presentation muestra los formularios de invitación, invitaciones pendientes y vinculaciones activas; Application coordina el envío, aceptación, rechazo y revocación de vinculaciones; Domain representa las invitaciones, vinculaciones y capacidad; e Infrastructure implementa la comunicación con la REST API y los servicios técnicos requeridos. Este contexto no utiliza SQLite, debido a que sus datos se consultan directamente al servidor y se mantienen durante la sesión.

![Frontend - Veterinary Linking](<../../assets/images/componets-level-diagrams/Frontend - Veterinary Linking.png>)

###### API REST - Java

El backend de Veterinary Linking Context está compuesto por Interfaces, Application, Infrastructure y Domain. Interfaces expone las operaciones relacionadas con invitaciones y vinculaciones; Application coordina los casos de uso y el control de capacidad; Domain contiene las reglas correspondientes a invitaciones, vínculos y límites; e Infrastructure implementa la persistencia en MySQL y las integraciones con Identity and Access, Subscriptions y Resend. Asimismo, el contexto expone la autorización de vinculaciones para Veterinary Care y utiliza el Shared Kernel del backend.

![Backend - Veterinary Linking](<../../assets/images/componets-level-diagrams/Backend - Veterinary Linking.png>)

##### 2.6.3.6. Bounded Context Software Architecture Code Level Diagrams

###### 2.6.3.6.1. Bounded Context Domain Layer Class Diagram

API REST - Java

Aplicación móvil - Flutter

###### 2.6.3.6.2. Bounded Context Database Diagram

Base de datos central - MySQL

Este contexto no requiere persistencia local en SQLite para el alcance definido.

#### 2.6.4. Bounded Context: Subscriptions

Suscripciones administra los planes gratuitos y premium de ganaderos y veterinarios, sus pagos y su vigencia. Comprende US22-US24 y el procesamiento de pagos definido en TS02. Comunica a Livestock Management el límite de animales y a Veterinary Linking el límite de ganaderos vinculados. Los pagos se realizan en modo de prueba.

##### 2.6.4.1. Domain Layer

Se proponen los agregados `Plan` y `Subscription`. Este contexto define los límites, pero no cuenta animales ni vinculaciones. Esos controles pertenecen a los contextos que administran dichos registros. Los atributos son privados y las operaciones son públicas.

###### API REST - Java

Diccionario de clases

| Elemento             | Tipo             | Responsabilidad                                                                                                                          |
| -------------------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `Plan`               | Raíz de agregado | Definir precio, período, perfil y capacidad de un plan.                                                                                  |
| `Subscription`       | Raíz de agregado | Mantener el plan efectivo, su vigencia y el estado de renovación de una cuenta.                                                          |
| `Money`              | Objeto de valor  | Representar un importe y su moneda.                                                                                                      |
| `PaidPeriod`         | Objeto de valor  | Representar el intervalo cubierto por un pago confirmado.                                                                                |
| `SubscriberProfile`  | Enumeración      | Distinguir `RANCHER`, ganadero, de `VETERINARIAN`, veterinario.                                                                          |
| `PlanType`           | Enumeración      | Distinguir `FREE`, gratuito, de `PREMIUM`.                                                                                               |
| `BillingPeriod`      | Enumeración      | Representar `NONE`, sin cobro, `MONTHLY`, mensual, o `YEARLY`, anual.                                                                    |
| `SubscriptionStatus` | Enumeración      | Distinguir `FREE`, acceso gratuito inicial, `PREMIUM_ACTIVE`, premium vigente, y `PREMIUM_EXPIRED`, premium vencido con acceso gratuito. |

Los identificadores utilizan `UUID`, las fechas `Instant` y los importes `BigDecimal`, que permite trabajar con cantidades decimales. El catálogo habilitará únicamente los períodos y precios que el equipo valide. Definir la enumeración no implica ofrecer todas las opciones desde la primera versión.

Plan

| Atributo        | Tipo                | Descripción                                                                  |
| --------------- | ------------------- | ---------------------------------------------------------------------------- |
| `id`            | `UUID`              | Identificador del plan.                                                      |
| `name`          | `String`            | Nombre mostrado al usuario.                                                  |
| `profile`       | `SubscriberProfile` | Perfil compatible.                                                           |
| `type`          | `PlanType`          | Gratuito o premium.                                                          |
| `price`         | `Money`             | Precio y moneda. El gratuito tiene importe cero.                             |
| `billingPeriod` | `BillingPeriod`     | Período de cobro. El gratuito utiliza `NONE`.                                |
| `capacityLimit` | `int`               | Cantidad máxima de animales activos o ganaderos vinculados, según el perfil. |

| Método              | Responsabilidad                                             |
| ------------------- | ----------------------------------------------------------- |
| `create(...)`       | Crear un plan con nombre, precio, período y límite válidos. |
| `supports(profile)` | Comprobar que el plan corresponda al perfil.                |
| `isPremium()`       | Indicar si requiere pago.                                   |

Los planes se cargan como configuración del catálogo. No se incluyen pantallas de administración ni cambios de precio sobre planes ya contratados. Cada perfil dispone de un plan gratuito inicial y una opción premium para el alcance actual.

Subscription

| Atributo          | Tipo                 | Descripción                                                       |
| ----------------- | -------------------- | ----------------------------------------------------------------- |
| `id`              | `UUID`               | Identificador de la suscripción.                                  |
| `accountId`       | `UUID`               | Cuenta titular.                                                   |
| `profile`         | `SubscriberProfile`  | Perfil de esa cuenta.                                             |
| `currentPlanId`   | `UUID`               | Plan efectivo, gratuito o premium.                                |
| `status`          | `SubscriptionStatus` | Estado de los beneficios.                                         |
| `paidPeriod`      | `PaidPeriod`         | Último período pagado confirmado. Opcional antes del primer pago. |
| `renewalEnabled`  | `boolean`            | Indica si la renovación está confirmada como activa.              |
| `allowedCapacity` | `int`                | Límite efectivo comunicado a otros contextos.                     |
| `revision`        | `long`               | Revisión creciente del estado efectivo de beneficios.             |
| `createdAt`       | `Instant`            | Fecha de creación.                                                |
| `updatedAt`       | `Instant`            | Fecha del último cambio.                                          |

| Método                                                   | Responsabilidad                                                                      |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `startFree(accountId, freePlan, now)`                    | Crear la suscripción con el plan gratuito de su perfil y revisión inicial cero.      |
| `activatePremium(plan, paidPeriod, renewalEnabled, now)` | Aplicar un plan compatible tras verificar un pago válido.                            |
| `extendPaidPeriod(paidPeriod, renewalEnabled, now)`      | Incorporar una renovación pagada sin reducir la vigencia ya confirmada.              |
| `confirmRenewalCancellation(now)`                        | Desactivar la renovación sin recortar el período pagado.                             |
| `expire(freePlan, now)`                                  | Aplicar el plan gratuito al terminar la vigencia sin una nueva cobertura confirmada. |
| `isPremiumAt(now)`                                       | Comprobar si existe un período premium vigente.                                      |
| `belongsTo(accountId)`                                   | Comprobar al titular.                                                                |

Cancelar la renovación no equivale a vencer. Un pago inicial pendiente o rechazado no cambia el plan efectivo. Al vencer premium se conservan animales, historiales y vinculaciones. La revisión aumenta al confirmar una nueva vigencia o cambiar los beneficios, sin incrementarse por mensajes repetidos o por una cancelación que conserva esos beneficios.

Objetos de valor y eventos

| Clase              | Atributos                                                                                                                          | Métodos y reglas                                                                                                           |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `Money`            | `amount: BigDecimal`, `currency: String`.                                                                                          | Constructor validado y lectura. Rechaza importes negativos o moneda vacía.                                                 |
| `PaidPeriod`       | `startsAt: Instant`, `endsAt: Instant`.                                                                                            | Constructor, lectura y `contains(now)`. El inicio debe ser anterior al fin. El instante de fin ya no pertenece al período. |
| `PremiumActivated` | `eventId: UUID`, `accountId: UUID`, `profile: SubscriberProfile`, `allowedCapacity: int`, `revision: long`, `occurredAt: Instant`. | Constructor y lectura. Comunicar activación o nueva vigencia pagada.                                                       |
| `PremiumExpired`   | Los mismos seis atributos de `PremiumActivated`.                                                                                   | Constructor y lectura. Comunicar el retorno al límite gratuito.                                                            |

Repositorios y relaciones

| Interfaz                 | Propósito                                         | Métodos                                                                          |
| ------------------------ | ------------------------------------------------- | -------------------------------------------------------------------------------- |
| `PlanRepository`         | Consultar el catálogo configurado.                | `findById(planId)`, `findByProfile(profile)`, `findFreeByProfile(profile)`.      |
| `SubscriptionRepository` | Recuperar y guardar la suscripción de una cuenta. | `save(subscription)`, `findByAccountId(accountId)`, `findDueForExpiration(now)`. |

Las interfaces no tienen atributos de implementación. Cada cuenta tiene una suscripción para su único perfil. Muchas suscripciones pueden referenciar un mismo plan. `Plan` contiene un `Money` y `Subscription` contiene cero o un `PaidPeriod`. Las cuentas de Identidad y acceso se referencian por identificador, sin incorporar sus entidades al agregado.

###### Aplicación móvil - Flutter

El móvil presenta los resultados del servidor. Los identificadores utilizan `String`, las fechas `DateTime` y los campos opcionales `?`. No calcula una activación a partir de la pantalla del proveedor de pago.

| Elemento                 | Atributos                                                                                                                                           | Métodos y propósito                                                                                     |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `Plan`                   | `id: String`, `name: String`, `profile: SubscriberProfile`, `type: PlanType`, `price: Money`, `billingPeriod: BillingPeriod`, `capacityLimit: int`. | Constructor, lectura y `supports(profile)`. Mostrar el catálogo compatible.                             |
| `Money`                  | `amount: String`, `currency: String`.                                                                                                               | Constructor y lectura. Conservar la representación decimal recibida, sin calcular cobros en el móvil.   |
| `PaidPeriod`             | `startsAt: DateTime`, `endsAt: DateTime`.                                                                                                           | Constructor y lectura. Mostrar la vigencia confirmada.                                                  |
| `Subscription`           | Los once atributos de la suscripción Java, usando `String`, `DateTime`, `int` y `bool` según corresponda. `paidPeriod: PaidPeriod?`.                | Constructor y lectura. Mostrar plan, límite y renovación.                                               |
| `CheckoutSession`        | `operationId: String`, `url: String`.                                                                                                               | Constructor y lectura. Abrir el proceso de pago de prueba.                                              |
| `CancellationResult`     | `confirmed: bool`, `subscription: Subscription`.                                                                                                    | Constructor y lectura. Distinguir cancelación confirmada de solicitud sin confirmar.                    |
| `SubscriptionRepository` | Sin atributos por ser interfaz.                                                                                                                     | `getPlans()`, `getSubscription()`, `requestPremium(planId, operationId)`, `cancelRenewal(operationId)`. |

Se utilizan las mismas enumeraciones de perfil, tipo de plan, período y estado, con nombres adaptados a Dart. Los métodos del repositorio devuelven `Future`, una respuesta disponible cuando termina la operación.

##### 2.6.4.2. Interface Layer

Las solicitudes se vinculan a la cuenta y perfil de la sesión. Solo se muestran o modifican sus propios datos. El cliente selecciona el plan, pero no decide el importe, el límite ni la vigencia.

###### API REST - Java

| Clase                     | Propósito y atributos                                                                                            | Métodos                                                                   |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `PlanController`          | Consultar planes compatibles: `queries: SubscriptionQueryService`.                                               | `getPlans()`.                                                             |
| `SubscriptionController`  | Consultar y gestionar la suscripción: `queries: SubscriptionQueryService`, `billing: BillingApplicationService`. | `getSubscription()`, `requestPremium(request)`, `cancelRenewal(request)`. |
| `StripeWebhookController` | Recibir avisos del proveedor: `verifier: PaymentNotificationVerifier`, `handler: PaymentNotificationHandler`.    | `receive(rawBody, signature)`.                                            |

Un webhook es un aviso enviado por el proveedor al servidor. Este controlador comprueba su autenticidad antes de procesarlo. No utiliza una sesión del móvil ni acepta como prueba de pago los datos enviados por el usuario.

Datos de entrada y salida

| Clase                   | Atributos                                                                                | Propósito y métodos                                                                            |
| ----------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `RequestPremiumRequest` | `planId: UUID`, `operationId: UUID`.                                                     | Solicitar contratación e identificar el intento para evitar duplicarlo. Constructor y lectura. |
| `CancelRenewalRequest`  | `operationId: UUID`.                                                                     | Identificar una solicitud de cancelación. Constructor y lectura.                               |
| `PlanResponse`          | Los siete atributos de `Plan`. El importe se transmite como texto decimal con su moneda. | `fromDomain` y lectura. Mostrar el plan.                                                       |
| `SubscriptionResponse`  | Los once atributos de `Subscription`, con fechas y período opcional.                     | `fromDomain` y lectura. Mostrar el estado efectivo.                                            |
| `CheckoutResponse`      | `operationId: UUID`, `url: String`.                                                      | Constructor y lectura. Entregar el acceso al pago de prueba.                                   |
| `CancellationResponse`  | `confirmed: boolean`, `subscription: SubscriptionResponse`.                              | Constructor y lectura. Informar si se confirmó la cancelación.                                 |

El resultado del navegador o la pantalla de pago solo provoca una nueva consulta al servidor. No activa premium. Los fallos internos al procesar un aviso no se confirman al proveedor como si el cambio ya estuviera guardado.

###### Aplicación móvil - Flutter

| Clase                   | Propósito y atributos                                                                                                                                                                              | Métodos                                                                                                   |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `SubscriptionViewModel` | Estado de presentación: `service: SubscriptionApplicationService`, `plans: List<Plan>`, `subscription: Subscription?`, `isLoading: bool`, `errorMessage: String?`, `cancellationConfirmed: bool?`. | `loadPlans`, `loadSubscription`, `requestPremium`, `cancelRenewal`, `refreshAfterCheckout`, `clearState`. |
| `PlansPage`             | Catálogo: `viewModel: SubscriptionViewModel`.                                                                                                                                                      | `build`, `selectPlan`, `confirmSelection`.                                                                |
| `SubscriptionPage`      | Plan actual: `viewModel: SubscriptionViewModel`.                                                                                                                                                   | `build`, `refreshSubscription`, `confirmCancellation`.                                                    |

Las pantallas muestran precio, período, capacidad y fin de vigencia cuando corresponde. Durante un pago sin confirmación mantienen el plan anterior. Una cancelación confirmada muestra hasta cuándo se conservan los beneficios.

##### 2.6.4.3. Application Layer

Esta capa valida el perfil, coordina los pagos y publica los cambios efectivos. Los contratos de integración utilizan datos propios de ANITEC para que el dominio no dependa de objetos de Stripe.

###### API REST - Java

Servicios

| Clase                           | Propósito y atributos                                                                                                                                                                                       | Métodos                                                                                                  |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `SubscriptionQueryService`      | Consultar planes, suscripción y límites: `plans: PlanRepository`, `subscriptions: SubscriptionRepository`, `state: SubscriptionStateService`.                                                               | `getPlans(actor)`, `getSubscription(actor)`, `getLimits(accountId, profile)`.                            |
| `BillingApplicationService`     | Solicitar pagos y cancelaciones: `plans: PlanRepository`, `subscriptions: SubscriptionRepository`, `payments: PaymentGateway`, `operations: BillingOperationStore`, `state: SubscriptionStateService`.      | `requestPremium(command, actor)`, `cancelRenewal(command, actor)`.                                       |
| `SubscriptionStateService`      | Crear el acceso gratuito y aplicar estados verificados: `plans: PlanRepository`, `subscriptions: SubscriptionRepository`, `payments: PaymentGateway`, `events: SubscriptionEventPublisher`, `clock: Clock`. | `getOrCreate(accountId, profile)`, `refreshFromProvider(accountId)`, `ensureCurrentValidity(accountId)`. |
| `PaymentNotificationHandler`    | Procesar avisos autenticados: `state: SubscriptionStateService`, `notifications: ProcessedPaymentNotificationStore`.                                                                                        | `handle(notification)`.                                                                                  |
| `SubscriptionExpirationHandler` | Revisar vigencias finalizadas: `subscriptions: SubscriptionRepository`, `state: SubscriptionStateService`, `clock: Clock`.                                                                                  | `checkDueSubscriptions()`.                                                                               |
| `SubscriptionActor`             | Identidad validada: `accountId: UUID`, `profile: SubscriberProfile`.                                                                                                                                        | Constructor y lectura.                                                                                   |

Comandos y datos de integración

| Clase                         | Atributos y propósito                                                                                                                                                                                                                                                           | Métodos                                                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `RequestPremiumCommand`       | `planId: UUID`, `operationId: UUID`. Seleccionar el plan que se desea contratar.                                                                                                                                                                                                | Constructor y lectura.                                      |
| `CancelRenewalCommand`        | `operationId: UUID`. Solicitar el fin de la renovación automática.                                                                                                                                                                                                              | Constructor y lectura.                                      |
| `EffectiveSubscriptionLimits` | `accountId: UUID`, `profile: SubscriberProfile`, `freeLimit: int`, `allowedCapacity: int`, `revision: long`. Entregar los límites efectivos a otros contextos.                                                                                                                  | Constructor y lectura.                                      |
| `BillingOperation`            | `operationId: UUID`, `accountId: UUID`, `type: String`, `planId: UUID` opcional, `status: String`, `checkoutUrl: String` opcional, `createdAt: Instant`, `updatedAt: Instant`. Registrar un intento de contratación o cancelación con estado `PENDING`, `CONFIRMED` o `FAILED`. | Constructor, lectura, `confirm(result, now)` y `fail(now)`. |
| `CheckoutSessionData`         | `operationId: UUID`, `url: String`. Resultado del inicio del pago.                                                                                                                                                                                                              | Constructor y lectura.                                      |
| `VerifiedPaymentNotification` | `providerEventId: String`, `accountId: UUID`, `providerSubscriptionId: String`. Aviso autenticado y asociado a una cuenta conocida.                                                                                                                                             | Constructor y lectura.                                      |
| `BillingSnapshot`             | `accountId: UUID`, `planId: UUID`, `providerSubscriptionId: String`, `paidPeriod: PaidPeriod` opcional, `paymentConfirmed: boolean`, `renewalEnabled: boolean`. Estado consultado al proveedor y validado por el adaptador.                                                     | Constructor y lectura.                                      |

Contratos de integración

| Interfaz                            | Propósito                                                            | Métodos                                                                                                                |
| ----------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `PaymentGateway`                    | Solicitar pagos y consultar su estado sin exponer objetos de Stripe. | `createCheckout(accountId, plan, operationId)`, `cancelRenewal(accountId, operationId)`, `getCurrentState(accountId)`. |
| `PaymentNotificationVerifier`       | Comprobar autenticidad y correspondencia de un aviso.                | `verify(rawBody, signature)`. Devuelve `VerifiedPaymentNotification`.                                                  |
| `BillingOperationStore`             | Registrar intentos y recuperar un resultado ante una repetición.     | `find(accountId, operationId)`, `save(operation)`.                                                                     |
| `ProcessedPaymentNotificationStore` | Identificar avisos que ya se aplicaron.                              | `exists(providerEventId)`, `save(providerEventId, processedAt)`.                                                       |
| `SubscriptionEventPublisher`        | Comunicar cambios efectivos después de confirmar el guardado.        | `publish(event)`.                                                                                                      |

Las interfaces no tienen atributos de implementación. `Clock` proporciona la hora del servidor. Las operaciones del usuario no reciben una cuenta distinta de la sesión. `getLimits` es un contrato interno y contrasta el perfil con la suscripción registrada.

Flujos principales

| Operación               | Validaciones y resultado                                                                                                                                                                           |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Consultar planes        | Devolver solo el catálogo compatible con el perfil autenticado, con precio, período y capacidad.                                                                                                   |
| Iniciar suscripción     | Crear un único registro gratuito por cuenta cuando todavía no exista. No iniciar cobros.                                                                                                           |
| Solicitar premium       | Comprobar que el plan sea premium y compatible. Rechazar cambios durante una vigencia premium activa. Registrar el intento y pedir el procesamiento con precio y moneda definidos por el servidor. |
| Confirmar pago          | Consultar el estado del proveedor y validar cuenta, plan, pago y período. Aplicar una vigencia confirmada y comunicar su límite. Una solicitud pendiente o rechazada conserva el plan anterior.    |
| Renovar                 | Incorporar un nuevo período pagado válido. Un fallo de renovación no elimina el tiempo que todavía está pagado.                                                                                    |
| Cancelar renovación     | Pedir la cancelación y verificar el resultado. Registrar el cambio solo si está confirmado. Conservar los beneficios hasta el fin pagado. Si ya estaba cancelada, devolver ese estado.             |
| Vencer premium          | Comprobar si existe una renovación pagada. En ausencia de una nueva vigencia confirmada, aplicar el plan gratuito y comunicar el límite sin eliminar registros de otros contextos.                 |
| Procesar aviso repetido | Si su identificador ya fue procesado, no repetir cambios ni aumentar la revisión.                                                                                                                  |

Los avisos pueden llegar desordenados. Por eso, el manejador consulta el estado actual del proveedor y no sustituye la suscripción únicamente con el contenido de un aviso antiguo. La aplicación serializa la consulta y aplicación por cuenta, es decir, procesa una actualización a la vez. Un resultado que no cambia los beneficios no genera otra revisión.

Al llegar al fin del período, una renovación no confirmada no extiende premium. Si no se puede consultar al proveedor, se utiliza únicamente la vigencia ya confirmada. Una confirmación posterior permite recuperar los beneficios que correspondan. Las consultas de suscripción y límites también verifican el vencimiento para no depender solo de una tarea programada.

Los eventos se publican después del guardado. Los adaptadores de Livestock Management y Veterinary Linking convierten `allowedCapacity` en `allowedAnimals` o `allowedRanchers`, respectivamente, y conservan la revisión. Ambos contextos pueden consultar `EffectiveSubscriptionLimits` si necesitan contrastar el estado vigente.

###### Aplicación móvil - Flutter

| Clase o interfaz                 | Propósito y atributos                                                                                                                                                        | Métodos                                                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `SubscriptionApplicationService` | Coordinar la suscripción: `repository: SubscriptionRepository`, `session: SubscriptionSessionGateway`, `connection: ConnectionGateway`, `checkout: CheckoutLauncherGateway`. | `getPlans`, `getSubscription`, `requestPremium`, `cancelRenewal`, `refreshAfterCheckout`, `onSessionClosed`. |
| `SubscriptionSessionGateway`     | Obtener la identidad actual, sin atributos.                                                                                                                                  | `requireValidSession`, `getAccountId`.                                                                       |
| `CheckoutLauncherGateway`        | Abrir el pago de prueba, sin atributos.                                                                                                                                      | `open(url)`.                                                                                                 |

Se reutiliza el contrato técnico `ConnectionGateway`. Consultar o modificar la suscripción requiere conexión. El servicio crea un identificador por intento y lo reutiliza si necesita recuperar el resultado de ese mismo intento. Al regresar del pago consulta la suscripción, sin interpretar el regreso como aprobación.

El cierre o cambio de cuenta limpia el estado de presentación. Las respuestas de la cuenta anterior se descartan. Una solicitud sin resultado conocido no se repite con otro identificador para intentar forzar una confirmación.

##### 2.6.4.4. Infrastructure Layer

El servidor utiliza MySQL y un adaptador para Stripe en modo de prueba. Este adaptador actúa como capa de traducción entre el proveedor de pagos y los conceptos de ANITEC.

###### API REST - Java

| Clase                                  | Propósito y atributos                                                                                      | Métodos                                                                        |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `JpaPlanRepository`                    | Consultar planes: `entityManager: EntityManager`, `mapper: SubscriptionPersistenceMapper`.                 | Los tres métodos de `PlanRepository`.                                          |
| `JpaSubscriptionRepository`            | Persistir suscripciones: `entityManager: EntityManager`, `mapper: SubscriptionPersistenceMapper`.          | `save`, `findByAccountId`, `findDueForExpiration`.                             |
| `SubscriptionPersistenceMapper`        | Convertir dominio y persistencia, sin estado.                                                              | `toPlan`, `toPlanEntity`, `toSubscription`, `toSubscriptionEntity`.            |
| `StripePaymentAdapter`                 | Implementar pagos: `stripeClient`, cliente del proveedor, y `bindings: BillingProviderBindingStore`.       | `createCheckout`, `cancelRenewal`, `getCurrentState`.                          |
| `StripeNotificationVerifier`           | Validar avisos: `signatureVerifier`, verificador del proveedor, y `bindings: BillingProviderBindingStore`. | `verify(rawBody, signature)`.                                                  |
| `JpaBillingOperationStore`             | Conservar intentos: `entityManager: EntityManager`.                                                        | `find`, `save`. Convierte entre `BillingOperation` y `BillingOperationRecord`. |
| `JpaProcessedPaymentNotificationStore` | Conservar avisos procesados: `entityManager: EntityManager`.                                               | `exists`, `save`.                                                              |
| `BillingProviderBindingStore`          | Mantener correspondencias con el proveedor: `entityManager: EntityManager`.                                | `findByAccountId`, `findByProviderSubscriptionId`, `save`.                     |
| `SpringSubscriptionEventPublisher`     | Publicar cambios tras el guardado: `eventPublisher`, mecanismo de eventos de Spring.                       | `publish`.                                                                     |
| `SubscriptionExpirationJob`            | Ejecutar revisiones periódicas: `handler: SubscriptionExpirationHandler`.                                  | `run`.                                                                         |
| `SubscriptionsFacade`                  | Exponer límites a otros contextos: `queries: SubscriptionQueryService`.                                    | `getLimits(accountId, profile)`.                                               |

JPA es la interfaz de persistencia de Java y se utiliza con Hibernate para relacionar los objetos con las tablas. `EntityManager` ejecuta las consultas y administra los cambios. Las credenciales de Stripe permanecen en la configuración del servidor y no se incorporan a Flutter.

Clases de persistencia

| Clase                                | Atributos                                                                                                                                                                                                                                                                                            | Métodos y propósito                                                                                               |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `PlanPersistenceEntity`              | `id: UUID`, `name: String`, `profile: SubscriberProfile`, `type: PlanType`, `priceAmount: BigDecimal`, `currency: String`, `billingPeriod: BillingPeriod`, `capacityLimit: int`.                                                                                                                     | Constructor y acceso a campos. Guardar el catálogo.                                                               |
| `SubscriptionPersistenceEntity`      | `id: UUID`, `accountId: UUID`, `profile: SubscriberProfile`, `currentPlanId: UUID`, `status: SubscriptionStatus`, `paidStartsAt: Instant` opcional, `paidEndsAt: Instant` opcional, `renewalEnabled: boolean`, `allowedCapacity: int`, `revision: long`, `createdAt: Instant`, `updatedAt: Instant`. | Constructor y acceso a campos. Guardar la suscripción y su vigencia.                                              |
| `BillingOperationRecord`             | `operationId: UUID`, `accountId: UUID`, `type: String`, `planId: UUID` opcional, `status: String`, `checkoutUrl: String` opcional, `createdAt: Instant`, `updatedAt: Instant`.                                                                                                                       | Constructor y acceso a campos. Registrar contratación o cancelación con estado `PENDING`, `CONFIRMED` o `FAILED`. |
| `ProcessedPaymentNotificationRecord` | `providerEventId: String`, `processedAt: Instant`.                                                                                                                                                                                                                                                   | Constructor y lectura. Evitar aplicar dos veces un mismo aviso.                                                   |
| `BillingProviderBinding`             | `accountId: UUID`, `providerCustomerId: String`, `providerSubscriptionId: String` opcional.                                                                                                                                                                                                          | Constructor y acceso a campos. Asociar la cuenta con su suscripción externa actual.                               |

Se establecen claves únicas para la cuenta de la suscripción, el identificador de aviso y el par cuenta e identificador de operación. El plan efectivo referencia al catálogo. Los datos de tarjeta no se guardan en estas tablas.

El adaptador obtiene el precio externo asociado al plan desde la configuración del servidor y comprueba importe, moneda, titular y período antes de entregar un `BillingSnapshot`. La autenticidad del aviso no reemplaza esas comprobaciones. Los avisos de suscripciones externas anteriores no pueden sustituir la vinculación externa actual de la cuenta.

Los intentos se registran antes de pedir el pago. El identificador de operación también se utiliza con el proveedor para evitar duplicar una solicitud ante fallos de comunicación. Reutilizarlo con un plan o una operación diferente se rechaza. Confirmar una operación de contratación significa que se creó el proceso de pago, no que premium esté activo.

El cambio de la suscripción y el registro del aviso procesado se guardan en una misma transacción. Para una cuenta, la consulta al proveedor y la aplicación del estado se coordinan bajo un bloqueo por cuenta con tiempo de espera limitado. Así se evita que una consulta antigua sobrescriba otra más reciente. Un fallo libera el bloqueo y deja el aviso disponible para reintento.

Los eventos hacia otros contextos se procesan después de confirmar la transacción. Si su entrega interna falla, las consultas de límites permiten recuperar la revisión vigente. Los consumidores no modifican la suscripción ni sus datos de pago.

###### Aplicación móvil - Flutter

| Clase                                | Propósito y atributos                                                                                       | Métodos                                                                             |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `SubscriptionRepositoryImpl`         | Implementar el repositorio móvil: `remote: SubscriptionRemoteDataSource`, `mapper: SubscriptionDataMapper`. | `getPlans`, `getSubscription`, `requestPremium`, `cancelRenewal`.                   |
| `SubscriptionRemoteDataSource`       | Acceder al servidor: `httpClient`, cliente autenticado compartido, y `baseUrl: String`.                     | `fetchPlans`, `fetchSubscription`, `createCheckout`, `cancelRenewal`.               |
| `SubscriptionDataMapper`             | Convertir respuestas, sin estado.                                                                           | `planFromJson`, `subscriptionFromJson`, `checkoutFromJson`, `cancellationFromJson`. |
| `IdentitySubscriptionSessionAdapter` | Obtener sesión: `sessionService`, servicio compartido de Identidad y acceso.                                | `requireValidSession`, `getAccountId`.                                              |
| `DeviceCheckoutLauncher`             | Abrir el acceso al pago: `urlLauncher`, mecanismo de apertura de enlaces del dispositivo.                   | `open(url)`.                                                                        |

Se reutiliza `DeviceConnectionAdapter` para comprobar conexión. No se propone persistencia SQLite para este contexto. Los planes y estados se consultan al servidor y se mantienen en memoria durante la sesión. Un dato conservado en pantalla no autoriza capacidad premium.

La integración utiliza el entorno de prueba durante el desarrollo académico. La viabilidad de cobros reales y las condiciones de publicación móvil se revisan mediante SP01 antes de ofrecer una contratación real.

##### 2.6.4.5. Bounded Context Software Architecture Component Level Diagrams

##### 2.6.4.5. Bounded Context Software Architecture Component Level Diagrams

###### Aplicación móvil - Flutter

El frontend de Subscriptions Context se estructura mediante Presentation, Application, Infrastructure y Domain. Presentation muestra los planes disponibles, la suscripción actual y su vigencia; Application coordina las consultas, contratación premium y cancelación de renovación; Domain contiene los modelos de planes, precios y suscripciones; e Infrastructure implementa la comunicación con la REST API y la apertura del proceso de pago. Este contexto no requiere SQLite y utiliza Stripe en modo de prueba para el proceso de checkout.

![Frontend - Subscriptions](<../../assets/images/componets-level-diagrams/Frontend - Subscriptions.png>)

###### API REST - Java

El backend de Subscriptions Context está conformado por Interfaces, Application, Infrastructure y Domain. Interfaces expone la consulta de planes, gestión de suscripciones y recepción de webhooks; Application coordina pagos, cancelaciones, vigencias y cambios de beneficios; Domain contiene las reglas de planes y suscripciones; e Infrastructure implementa la persistencia en MySQL y la integración con Stripe. El contexto también comunica los límites vigentes a Livestock Management y Veterinary Linking y utiliza el Shared Kernel del backend.

![Backend - Subscriptions](<../../assets/images/componets-level-diagrams/Backend - Subscriptions.png>)

##### 2.6.4.6. Bounded Context Software Architecture Code Level Diagrams

###### 2.6.4.6.1. Bounded Context Domain Layer Class Diagram

API REST - Java

Aplicación móvil - Flutter

###### 2.6.4.6.2. Bounded Context Database Diagram

Base de datos central - MySQL

Este contexto no requiere persistencia local en SQLite para el alcance definido.

#### 2.6.5. Bounded Context: Identity and Access

Identidad y acceso administra cuentas, verificación de correo y sesiones de ganaderos y veterinarios. Comprende US25-US28 y proporciona la identidad utilizada en las operaciones protegidas. Coordina el cierre de sesión con la eliminación de las copias locales de US29 y TS03. Cada contexto conserva la responsabilidad de comprobar sus permisos de negocio.

##### 2.6.5.1. Domain Layer

Se proponen los agregados `Account` y `UserSession`. La cuenta contiene su verificación de correo. La sesión representa un acceso con vencimiento, independiente de las sesiones de otros dispositivos. Los atributos son privados y las operaciones indicadas son públicas.

###### API REST - Java

Diccionario de clases

| Elemento            | Tipo                 | Responsabilidad                                                                    |
| ------------------- | -------------------- | ---------------------------------------------------------------------------------- |
| `Account`           | Raíz de agregado     | Conservar correo, perfil y estado de verificación.                                 |
| `EmailVerification` | Entidad de `Account` | Controlar el código vigente, su vencimiento y los intentos.                        |
| `UserSession`       | Raíz de agregado     | Registrar la vigencia y revocación de una sesión.                                  |
| `EmailAddress`      | Objeto de valor      | Validar y normalizar el correo según una regla única del sistema.                  |
| `PasswordHash`      | Objeto de valor      | Representar la huella protegida de la contraseña, sin conservar el texto original. |
| `AccountProfile`    | Enumeración          | Distinguir `RANCHER`, ganadero, de `VETERINARIAN`, veterinario.                    |
| `AccountStatus`     | Enumeración          | Distinguir `PENDING_VERIFICATION` de `VERIFIED`.                                   |

Los identificadores utilizan `UUID` y las fechas `Instant`. Los valores opcionales se indican en las tablas. Las contraseñas y los códigos se transforman mediante servicios técnicos antes de persistirlos. Las entidades no implementan algoritmos de protección propios.

Account

| Atributo       | Tipo                | Descripción                                             |
| -------------- | ------------------- | ------------------------------------------------------- |
| `id`           | `UUID`              | Identificador de la cuenta.                             |
| `email`        | `EmailAddress`      | Correo único registrado.                                |
| `passwordHash` | `PasswordHash`      | Representación protegida de la contraseña.              |
| `profile`      | `AccountProfile`    | Único perfil de la cuenta.                              |
| `status`       | `AccountStatus`     | Estado de verificación.                                 |
| `verification` | `EmailVerification` | Verificación vigente o ya consumida.                    |
| `createdAt`    | `Instant`           | Fecha de registro.                                      |
| `verifiedAt`   | `Instant`           | Fecha de verificación. Ausente mientras esté pendiente. |

| Método                                                      | Responsabilidad                                                                                                         |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `register(email, passwordHash, profile, verification, now)` | Crear una cuenta pendiente de verificación.                                                                             |
| `replaceVerification(verification)`                         | Sustituir el código de una cuenta pendiente, invalidando el anterior.                                                   |
| `recordFailedVerification(now)`                             | Contabilizar un intento incorrecto mediante la entidad de verificación.                                                 |
| `verifyEmail(now)`                                          | Consumir una verificación disponible y marcar el correo como verificado. La aplicación comprueba previamente el código. |
| `canSignIn()`                                               | Indicar si el correo está verificado.                                                                                   |

No se incluyen cambio de correo, cambio de perfil ni recuperación de contraseña, porque no forman parte de las historias definidas para este alcance.

EmailVerification y objetos de valor

| Clase               | Atributos                                                                                                                                                | Métodos y reglas                                                                                                                  |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `EmailVerification` | `id: UUID`, `codeDigest: String`, `createdAt: Instant`, `expiresAt: Instant`, `failedAttempts: int`, `maxAttempts: int`, `consumedAt: Instant` opcional. | `issue`, `isUsable(now)`, `recordFailure(now)`, `consume(now)`. Rechaza códigos vencidos, consumidos o que agotaron los intentos. |
| `EmailAddress`      | `value: String`.                                                                                                                                         | `of(value)`, `getValue`. Valida el formato y aplica la normalización utilizada también al iniciar sesión.                         |
| `PasswordHash`      | `value: String`.                                                                                                                                         | Constructor y lectura interna. No se devuelve en respuestas ni se incorpora a registros de diagnóstico.                           |

`codeDigest` es una representación protegida del código, vinculada a la cuenta y al identificador de verificación. Al reenviar se genera un identificador nuevo y se reemplaza la verificación anterior. El código original solo se utiliza para solicitar el correo.

UserSession

| Atributo      | Tipo      | Descripción                                                          |
| ------------- | --------- | -------------------------------------------------------------------- |
| `id`          | `UUID`    | Identificador de la sesión.                                          |
| `accountId`   | `UUID`    | Cuenta autenticada.                                                  |
| `tokenDigest` | `String`  | Huella del token de sesión. El token original no se guarda en MySQL. |
| `createdAt`   | `Instant` | Fecha de inicio.                                                     |
| `expiresAt`   | `Instant` | Fin de vigencia.                                                     |
| `revokedAt`   | `Instant` | Fecha de cierre remoto. Ausente mientras no se haya revocado.        |

| Método                                           | Responsabilidad                                                    |
| ------------------------------------------------ | ------------------------------------------------------------------ |
| `create(accountId, tokenDigest, now, expiresAt)` | Crear una sesión con vigencia limitada.                            |
| `isValidAt(now)`                                 | Comprobar que no esté vencida ni revocada.                         |
| `revoke(now)`                                    | Revocar la sesión. Repetir la operación conserva el primer cierre. |

Se propone un token aleatorio de sesión, una credencial que permite identificar cada acceso ante el servidor. El usuario mantiene la sesión entre aperturas mientras siga vigente. Al vencer, debe identificarse nuevamente. No se propone renovación automática de sesiones en esta versión.

Repositorios y relaciones

| Interfaz                | Propósito                     | Métodos                                                                               |
| ----------------------- | ----------------------------- | ------------------------------------------------------------------------------------- |
| `AccountRepository`     | Recuperar y guardar cuentas.  | `save(account)`, `findById(accountId)`, `findByEmail(email)`, `existsByEmail(email)`. |
| `UserSessionRepository` | Recuperar y guardar sesiones. | `save(session)`, `findByTokenDigest(tokenDigest)`.                                    |

Las interfaces no tienen atributos. Una cuenta contiene una verificación actual y puede tener varias sesiones. Cada sesión pertenece a una cuenta. Reenviar un código reemplaza la verificación, pero no crea otra cuenta. Verificar el correo no inicia una sesión automáticamente.

###### Aplicación móvil - Flutter

| Elemento                | Atributos                                                                                    | Métodos y propósito                                                                                                                                                                    |
| ----------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AccountIdentity`       | `accountId: String`, `email: String`, `profile: AccountProfile`.                             | Constructor y lectura. Representar la cuenta autenticada sin datos secretos del servidor.                                                                                              |
| `SessionCredentials`    | `sessionId: String`, `token: String`, `expiresAt: DateTime`, `identity: AccountIdentity`.    | Constructor, lectura restringida e `isLocallyValidAt(now)`. Conservar los datos necesarios para reabrir la sesión.                                                                     |
| `VerificationReference` | `accountId: String`, `verificationId: String`, `expiresAt: DateTime`, `emailAccepted: bool`. | Constructor y lectura. Identificar el proceso pendiente y el resultado de la solicitud de correo.                                                                                      |
| `AccountProfile`        | Valores `rancher`, `veterinarian`.                                                           | Representar los dos perfiles.                                                                                                                                                          |
| `IdentityRepository`    | Sin atributos por ser interfaz.                                                              | `register(email, password, profile)`, `verifyEmail(accountId, verificationId, code)`, `resendVerification(accountId)`, `signIn(email, password)`, `getCurrentIdentity()`, `signOut()`. |

Las operaciones devuelven `Future`, una respuesta disponible cuando termina la solicitud. El móvil no recibe la contraseña protegida, el código guardado ni los intentos internos del servidor. La validez local permite consultar copias autorizadas, pero no demuestra que la sesión siga activa en el servidor cuando no hay conexión.

##### 2.6.5.2. Interface Layer

Esta capa recibe credenciales y solicitudes de verificación y entrega resultados sin exponer información secreta. La identidad de las operaciones protegidas se obtiene de la sesión validada.

###### API REST - Java

| Clase                    | Propósito y atributos                                                         | Métodos                                                 |
| ------------------------ | ----------------------------------------------------------------------------- | ------------------------------------------------------- |
| `RegistrationController` | Registrar cuentas: `registration: RegistrationApplicationService`.            | `register(request)`.                                    |
| `VerificationController` | Verificar y reenviar códigos: `verification: VerificationApplicationService`. | `verify(request)`, `resend(request)`.                   |
| `SessionController`      | Administrar acceso: `sessions: SessionApplicationService`.                    | `signIn(request)`, `getCurrentIdentity()`, `signOut()`. |

Datos de entrada y salida

| Clase                       | Atributos                                                                                      | Propósito y métodos                                                                     |
| --------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `RegisterAccountRequest`    | `email: String`, `password: String`, `profile: AccountProfile`.                                | Constructor y lectura restringida. Solicitar registro.                                  |
| `VerifyEmailRequest`        | `accountId: UUID`, `verificationId: UUID`, `code: String`.                                     | Constructor y lectura restringida. Presentar un código para la cuenta correspondiente.  |
| `ResendVerificationRequest` | `accountId: UUID`.                                                                             | Constructor y lectura. Solicitar otro código, sin permitir elegir otro correo.          |
| `SignInRequest`             | `email: String`, `password: String`.                                                           | Constructor y lectura restringida. Solicitar acceso.                                    |
| `VerificationResponse`      | `accountId: UUID`, `verificationId: UUID`, `expiresAt: Instant`, `emailAccepted: boolean`.     | Constructor y lectura. Informar la verificación pendiente.                              |
| `AccountIdentityResponse`   | `accountId: UUID`, `email: String`, `profile: AccountProfile`.                                 | Constructor y lectura. Mostrar la identidad autenticada.                                |
| `SessionResponse`           | `sessionId: UUID`, `token: String`, `expiresAt: Instant`, `identity: AccountIdentityResponse`. | Constructor y lectura restringida. Entregar la credencial únicamente al iniciar sesión. |

La verificación responde con una confirmación sin crear una sesión. El reenvío solo dirige el código al correo ya registrado y respeta los límites de solicitudes. Un código correcto de otra cuenta o de una verificación reemplazada no se acepta.

###### Aplicación móvil - Flutter

| Clase                   | Propósito y atributos                                                                                                                                                            | Métodos                                                                                               |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `IdentityViewModel`     | Estado de presentación: `service: IdentityApplicationService`, `identity: AccountIdentity?`, `verification: VerificationReference?`, `isLoading: bool`, `errorMessage: String?`. | `register`, `verifyEmail`, `resendVerification`, `signIn`, `restoreSession`, `signOut`, `clearState`. |
| `RegisterPage`          | Formulario: `viewModel: IdentityViewModel`, `email: String`, `password: String`, `profile: AccountProfile?`.                                                                     | `build`, `validateForm`, `submit`.                                                                    |
| `EmailVerificationPage` | Verificación: `viewModel: IdentityViewModel`, `code: String`.                                                                                                                    | `build`, `submitCode`, `requestNewCode`.                                                              |
| `SignInPage`            | Acceso: `viewModel: IdentityViewModel`, `email: String`, `password: String`.                                                                                                     | `build`, `validateForm`, `submit`.                                                                    |
| `SessionGate`           | Resolver la pantalla inicial: `viewModel: IdentityViewModel`.                                                                                                                    | `build`, `restoreSession`.                                                                            |

Las contraseñas y códigos introducidos se eliminan de los formularios al terminar o abandonar el proceso. Si falla el correo, la pantalla conserva la referencia de la cuenta pendiente y permite solicitar otro código cuando corresponda. No presenta el envío como una verificación completada.

##### 2.6.5.3. Application Layer

Los servicios coordinan las reglas de cuenta y sesión con la protección de credenciales, los límites de solicitudes y el correo. Los valores concretos de duración e intentos se mantienen configurables y deben definirse antes de implementar las historias.

###### API REST - Java

Servicios

| Clase                            | Propósito y atributos                                                                                                                                                                                                                      | Métodos                                                     |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------- |
| `RegistrationApplicationService` | Registrar y solicitar verificación: `accounts: AccountRepository`, `passwords: PasswordGateway`, `codes: VerificationCodeGateway`, `mail: VerificationMailGateway`, `policy: IdentityPolicy`, `clock: Clock`.                              | `register(command)`.                                        |
| `VerificationApplicationService` | Validar y reemplazar códigos: `accounts: AccountRepository`, `codes: VerificationCodeGateway`, `mail: VerificationMailGateway`, `requests: IdentityRequestLimiter`, `policy: IdentityPolicy`, `clock: Clock`.                              | `verify(command)`, `resend(command)`.                       |
| `SessionApplicationService`      | Iniciar y comprobar sesiones: `accounts: AccountRepository`, `sessions: UserSessionRepository`, `passwords: PasswordGateway`, `tokens: SessionTokenGateway`, `requests: IdentityRequestLimiter`, `policy: IdentityPolicy`, `clock: Clock`. | `signIn(command)`, `authenticate(token)`, `signOut(token)`. |
| `IdentityQueryService`           | Exponer datos mínimos a otros contextos: `accounts: AccountRepository`.                                                                                                                                                                    | `getIdentity(accountId)`, `findVeterinarianByEmail(email)`. |
| `IdentityPolicy`                 | Configuración: `verificationLifetime: Duration`, `maxVerificationAttempts: int`, `resendCooldown: Duration`, `maxResendsPerWindow: int`, `requestWindow: Duration`, `maxSignInAttemptsPerWindow: int`, `sessionLifetime: Duration`.        | Constructor validado y lectura.                             |

`Duration` representa un intervalo de tiempo y `Clock` proporciona la hora del servidor. La política no concede permisos clínicos ni modifica los límites de suscripción.

Comandos y resultados

| Clase                       | Atributos y propósito                                                                                                        | Métodos                            |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `RegisterAccountCommand`    | `email: String`, `password: String`, `profile: AccountProfile`. Crear una cuenta.                                            | Constructor y lectura restringida. |
| `VerifyEmailCommand`        | `accountId: UUID`, `verificationId: UUID`, `code: String`. Verificar el correo.                                              | Constructor y lectura restringida. |
| `ResendVerificationCommand` | `accountId: UUID`. Reemplazar el código pendiente.                                                                           | Constructor y lectura.             |
| `SignInCommand`             | `email: String`, `password: String`. Solicitar sesión.                                                                       | Constructor y lectura restringida. |
| `AuthenticatedIdentity`     | `accountId: UUID`, `email: String`, `profile: AccountProfile`, `sessionId: UUID`. Identidad obtenida de una sesión validada. | Constructor y lectura.             |
| `IdentityData`              | `accountId: UUID`, `email: String`, `profile: AccountProfile`. Datos mínimos para consultas internas.                        | Constructor y lectura.             |
| `VerificationIssueResult`   | `accountId: UUID`, `verificationId: UUID`, `expiresAt: Instant`, `emailAccepted: boolean`. Resultado de registro o reenvío.  | Constructor y lectura.             |
| `SessionIssueResult`        | `sessionId: UUID`, `token: String`, `expiresAt: Instant`, `identity: IdentityData`. Resultado del inicio de sesión.          | Constructor y lectura restringida. |

Contratos técnicos

| Interfaz                  | Propósito                                                | Métodos                                                                                                            |
| ------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `PasswordGateway`         | Proteger y comprobar contraseñas.                        | `encode(password)`, `matches(password, passwordHash)`.                                                             |
| `VerificationCodeGateway` | Generar códigos y comprobar su representación protegida. | `generate()`, `digest(accountId, verificationId, code)`, `matches(accountId, verificationId, code, storedDigest)`. |
| `SessionTokenGateway`     | Generar tokens de sesión y obtener su huella.            | `generate()`, `digest(token)`.                                                                                     |
| `VerificationMailGateway` | Solicitar el correo de verificación.                     | `sendCode(email, code, expiresAt)`. Devuelve si el proveedor aceptó la solicitud.                                  |
| `IdentityRequestLimiter`  | Controlar reenvíos e intentos de acceso.                 | `checkAndRecordResend(accountId, now)`, `checkAndRecordSignIn(email, now)`.                                        |

Estas interfaces no tienen atributos. La contraseña sin transformar y el código original se mantienen únicamente el tiempo necesario para la operación. No forman parte de los eventos ni de las respuestas de consulta.

Flujos de aplicación

| Operación            | Validaciones y resultado                                                                                                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Registrar            | Validar datos y correo único, proteger la contraseña, generar código y guardar la cuenta pendiente. Después de confirmar el guardado, solicitar el correo. Un fallo de envío conserva la cuenta. |
| Verificar            | Recuperar la cuenta, comprobar identificador de verificación, vigencia e intentos y comparar el código. Si coincide, consumirlo y marcar la cuenta como verificada en una misma operación.       |
| Código incorrecto    | Registrar el intento fallido sin verificar la cuenta. El contador se conserva aunque la respuesta informe un error.                                                                              |
| Reenviar             | Exigir cuenta pendiente y disponibilidad según la política. Guardar una nueva verificación y después solicitar su correo. La anterior deja de ser válida incluso si el nuevo envío falla.        |
| Iniciar sesión       | Comprobar límite de intentos, contraseña y correo verificado. Crear una sesión con vencimiento y devolver el token original una sola vez.                                                        |
| Autenticar           | Buscar la sesión por la huella del token y comprobar vigencia, revocación y cuenta verificada. Entregar `AuthenticatedIdentity`.                                                                 |
| Cerrar sesión remota | Revocar la sesión utilizada. No eliminar la cuenta ni cerrar otras sesiones del usuario.                                                                                                         |
| Consultar identidad  | Entregar solo identificador, correo y perfil a los contextos autorizados. La consulta de destinatarios devuelve únicamente perfiles veterinarios.                                                |

Las operaciones de verificación bloquean la cuenta durante la comprobación y el guardado, evitando que dos solicitudes consuman el mismo código. Los intentos fallidos se confirman antes de responder el error. Las llamadas a Resend ocurren fuera de la transacción y no deshacen los cambios ya guardados.

`getIdentity` no autentica por sí solo a un usuario. Los controladores de otros contextos reciben la identidad validada por el control de acceso y comprueban después propiedad, vinculación o autoría, según corresponda.

###### Aplicación móvil - Flutter

| Clase o interfaz             | Propósito y atributos                                                                                                                                                                            | Métodos                                                                                                                                    |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `IdentityApplicationService` | Coordinar cuenta y sesión: `repository: IdentityRepository`, `storage: SecureSessionGateway`, `cleanup: AccountDataCleanupGateway`, `connection: ConnectionGateway`, `push: PushSessionGateway`. | `register`, `verifyEmail`, `resendVerification`, `signIn`, `restoreSession`, `signOut`, `requireValidSession`, `getAccountId`, `getActor`. |
| `SecureSessionGateway`       | Conservar credenciales protegidas, sin atributos de implementación.                                                                                                                              | `read()`, `save(credentials)`, `clear()`.                                                                                                  |
| `AccountDataCleanupGateway`  | Limpiar copias y estado de la cuenta, sin atributos de implementación.                                                                                                                           | `clearAccount(accountId)`.                                                                                                                 |
| `PushSessionGateway`         | Coordinar notificaciones con la sesión, sin atributos de implementación.                                                                                                                         | `attachCurrentDevice()`, `detachCurrentDevice()`, `clearLocalNotifications()`.                                                             |

`getActor` devuelve `AccountIdentity`. Los adaptadores de los demás contextos la convierten a su actor local. Se reutiliza `ConnectionGateway` para conocer la conexión. La contraseña nunca se guarda para iniciar sesión automáticamente.

| Situación               | Comportamiento                                                                                                                                                    |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Inicio confirmado       | Guardar `SessionCredentials` en almacenamiento seguro y asociar las notificaciones a la cuenta actual. Un fallo de notificaciones no invalida la sesión.          |
| Reapertura con conexión | Leer las credenciales y consultar la identidad al servidor. Si la sesión es inválida, retirar el acceso y limpiar los datos locales.                              |
| Reapertura sin conexión | Permitir solo las consultas descargadas si la credencial local no ha vencido. No habilitar cambios ni asumir que los permisos remotos siguen intactos.            |
| Cierre con conexión     | Bloquear nuevas operaciones de la cuenta e intentar desvincular las notificaciones y revocar la sesión. Completar siempre la limpieza local, aunque falle la red. |
| Cierre sin conexión     | Eliminar credenciales, copias y avisos locales sin esperar al servidor. No afirmar que la sesión remota quedó revocada.                                           |
| Cambio de cuenta        | Completar la limpieza anterior antes de presentar datos de la nueva sesión. Descartar respuestas de solicitudes iniciadas con otra cuenta.                        |

La aplicación deja de mostrar datos protegidos desde que comienza el cierre. Si falla la eliminación de una copia, mantiene bloqueado su acceso y vuelve a completar la limpieza antes de habilitar otra cuenta. Sin conexión no se puede detectar una revocación reciente del servidor.

##### 2.6.5.4. Infrastructure Layer

El servidor persiste cuentas y sesiones en MySQL. El móvil guarda la credencial en el almacenamiento seguro del dispositivo. SQLite se reserva para las copias de información de los contextos que requieren consulta sin conexión.

###### API REST - Java

| Clase                           | Propósito y atributos                                                                                              | Métodos                                                                                               |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `JpaAccountRepository`          | Persistir cuentas: `entityManager: EntityManager`, `mapper: IdentityPersistenceMapper`.                            | Los cuatro métodos de `AccountRepository`.                                                            |
| `JpaUserSessionRepository`      | Persistir sesiones: `entityManager: EntityManager`, `mapper: IdentityPersistenceMapper`.                           | `save`, `findByTokenDigest`.                                                                          |
| `IdentityPersistenceMapper`     | Convertir dominio y persistencia, sin estado.                                                                      | `toAccount`, `toAccountEntity`, `toSession`, `toSessionEntity`. Incluye la verificación de la cuenta. |
| `SpringPasswordAdapter`         | Implementar protección de contraseñas: `passwordEncoder`, componente de Spring Security configurado para este fin. | `encode`, `matches`.                                                                                  |
| `SecureVerificationCodeAdapter` | Generar y proteger códigos: `secureRandom`, generador seguro, y `digestKey`, secreto del servidor.                 | `generate`, `digest`, `matches`.                                                                      |
| `SecureSessionTokenAdapter`     | Generar y transformar tokens: `secureRandom`, generador seguro.                                                    | `generate`, `digest`.                                                                                 |
| `ResendVerificationMailAdapter` | Enviar códigos: `resendClient`, cliente del proveedor, y `senderEmail: String`.                                    | `sendCode`.                                                                                           |
| `JpaIdentityRequestLimiter`     | Registrar intentos y reenvíos: `entityManager: EntityManager`, `policy: IdentityPolicy`.                           | `checkAndRecordResend`, `checkAndRecordSignIn`.                                                       |
| `SessionAuthenticationFilter`   | Proteger solicitudes: `sessions: SessionApplicationService`.                                                       | `authenticateRequest`. Extrae el token y establece la identidad validada de la solicitud.             |
| `IdentityFacade`                | Exponer datos internos: `queries: IdentityQueryService`.                                                           | `getIdentity`, `findVeterinarianByEmail`.                                                             |

Spring Security proporciona el control de acceso de las solicitudes. Los algoritmos y sus parámetros se configuran mediante componentes existentes, sin diseñar métodos de cifrado propios. JPA, la interfaz de persistencia de Java, se utiliza con Hibernate para guardar los objetos en MySQL.

Clases de persistencia

| Clase                                | Atributos                                                                                                                                                                                                          | Métodos y propósito                                                                           |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| `AccountPersistenceEntity`           | `id: UUID`, `email: String`, `passwordHash: String`, `profile: AccountProfile`, `status: AccountStatus`, `verification: EmailVerificationPersistenceEntity`, `createdAt: Instant`, `verifiedAt: Instant` opcional. | Constructor y acceso a campos. Conservar la cuenta.                                           |
| `EmailVerificationPersistenceEntity` | `id: UUID`, `accountId: UUID`, `codeDigest: String`, `createdAt: Instant`, `expiresAt: Instant`, `failedAttempts: int`, `maxAttempts: int`, `consumedAt: Instant` opcional.                                        | Constructor y acceso a campos. Guardar la verificación actual.                                |
| `UserSessionPersistenceEntity`       | `id: UUID`, `accountId: UUID`, `tokenDigest: String`, `createdAt: Instant`, `expiresAt: Instant`, `revokedAt: Instant` opcional.                                                                                   | Constructor y acceso a campos. Conservar la sesión remota.                                    |
| `IdentityRequestCounter`             | `key: String`, `operation: String`, `windowStartedAt: Instant`, `attempts: int`, `lastRequestAt: Instant`.                                                                                                         | Constructor y acceso a campos. Controlar solicitudes por correo o cuenta y tipo de operación. |

El correo normalizado tiene una restricción única para evitar registros duplicados simultáneos. Las sesiones y verificaciones referencian a su cuenta. Se establece una verificación actual por cuenta y una huella única por token de sesión. Los contadores se actualizan de forma atómica, sin perder intentos ante solicitudes concurrentes.

Las rutas públicas de registro, verificación e inicio de sesión no requieren una sesión previa, pero validan entradas y límites. El resto utiliza `SessionAuthenticationFilter`. Ninguna respuesta expone huellas de contraseña, códigos protegidos ni tokens de otras sesiones.

`IdentityFacade.findVeterinarianByEmail` permite implementar `VeterinarianDirectoryGateway` de Veterinary Linking. El adaptador transforma `IdentityData` en `VeterinarianContact`. Los demás contextos reciben identidad y perfil, no entidades modificables de cuenta.

###### Aplicación móvil - Flutter

| Clase                       | Propósito y atributos                                                                                                                                   | Métodos                                                                                       |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `IdentityRepositoryImpl`    | Implementar acceso remoto: `remote: IdentityRemoteDataSource`, `mapper: IdentityDataMapper`.                                                            | Los seis métodos de `IdentityRepository`.                                                     |
| `IdentityRemoteDataSource`  | Enviar solicitudes: `httpClient`, cliente compartido, y `baseUrl: String`.                                                                              | `register`, `verifyEmail`, `resendVerification`, `signIn`, `fetchCurrentIdentity`, `signOut`. |
| `IdentityDataMapper`        | Convertir respuestas, sin estado.                                                                                                                       | `identityFromJson`, `sessionFromJson`, `verificationFromJson`.                                |
| `DeviceSecureSessionStore`  | Implementar almacenamiento seguro: `secureStorage`, acceso a la protección del dispositivo.                                                             | `read`, `save`, `clear`.                                                                      |
| `AccountDataCleanupAdapter` | Limpiar recursos: `livestockCache: LivestockCacheGateway`, `careCache: CareCacheGateway`, `presentationState`, estado compartido de la sesión.          | `clearAccount(accountId)`. Elimina copias, metadatos y estado de los módulos.                 |
| `FcmSessionAdapter`         | Coordinar notificaciones: `messagingClient`, cliente de Firebase Cloud Messaging, y `deviceRegistryClient`, acceso al registro técnico de dispositivos. | `attachCurrentDevice`, `detachCurrentDevice`, `clearLocalNotifications`.                      |
| `SessionHttpInterceptor`    | Incorporar la credencial a solicitudes protegidas: `storage: SecureSessionGateway`.                                                                     | `attachToken`, `handleUnauthorized`.                                                          |

`DeviceSecureSessionStore` utiliza la protección de Android o iOS mediante una integración de almacenamiento seguro de Flutter. Guarda el token y los datos mínimos de sesión, sin guardar la contraseña. No utiliza SQLite ni preferencias simples para la credencial.

`SessionHttpInterceptor` añade el token a las solicitudes protegidas. Una sesión rechazada invalida el acceso local y activa la limpieza. Un error de permiso sobre un animal concreto no se trata como un cierre de sesión de toda la cuenta.

El registro técnico de dispositivos pertenece a la integración compartida de notificaciones. Relaciona cada destino de notificación con la cuenta y sesión vigentes, sin constituir otro bounded context. Al cambiar de cuenta reemplaza la asociación anterior. Si el cierre ocurre sin conexión, no se promete una desvinculación remota inmediata. Por eso los avisos no contienen información clínica y abrirlos exige validar la sesión y los permisos del recurso.

Los adaptadores `IdentitySessionAdapter`, `IdentityCareSessionAdapter`, `IdentityLinkingSessionAdapter` e `IdentitySubscriptionSessionAdapter` de los apartados anteriores utilizan `IdentityApplicationService` como su servicio de sesión compartido. Cada uno entrega al contexto únicamente los identificadores y el perfil que necesita.

##### 2.6.5.5. Bounded Context Software Architecture Component Level Diagrams

###### API REST - Java / Spring Boot

###### Aplicación móvil - Flutter

##### 2.6.5.6. Bounded Context Software Architecture Code Level Diagrams

###### 2.6.5.6.1. Bounded Context Domain Layer Class Diagram

API REST - Java

Aplicación móvil - Flutter

###### 2.6.5.6.2. Bounded Context Database Diagram

Base de datos central - MySQL

Almacenamiento seguro del dispositivo

La aplicación conserva la credencial y los datos mínimos de sesión en almacenamiento seguro. No se propone una base SQLite para este contexto.
