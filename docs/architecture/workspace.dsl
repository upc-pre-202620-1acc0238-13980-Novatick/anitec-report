workspace "ANITEC - Arquitectura de software" "Diagramas de contexto y contenedores de ANITEC." {

    !impliedRelationships false

    model {
        ganadero = person "Ganadero" "Administra sus animales, autoriza veterinarios y consulta atenciones e indicaciones."
        veterinario = person "Veterinario" "Gestiona visitas y controles y registra atenciones de animales de ganaderos vinculados."
        anitec = softwareSystem "ANITEC" "Aplicación de gestión ganadera y apoyo veterinario." {
            tags "ANITEC"

            mobile = container "Aplicación móvil" "Aplicación para Android e iOS que permite gestionar animales, vinculaciones, visitas, atenciones y suscripciones según el perfil del usuario." "Flutter / Dart" {
                tags "Mobile"
            }
            localDb = container "Base de datos local del dispositivo" "Conserva por cuenta el inventario, las fichas consultadas, las últimas atenciones e indicaciones y la agenda descargada, con su fecha de actualización, para consulta sin conexión." "SQLite" {
                tags "Database"
            }
            api = container "API REST" "Organiza identidad, ganado, vinculaciones, atención veterinaria y suscripciones en módulos. Aplica reglas de negocio, permisos e integraciones externas." "Java / Spring Boot" {
                tags "API"
            }
            database = container "Base de datos central" "Almacena cuentas, animales, vinculaciones, citas, atenciones, indicaciones y suscripciones." "MySQL" {
                tags "Database"
            }
        }

        stripe = softwareSystem "Stripe" "Servicio externo de pagos y suscripciones utilizado en modo de prueba." {
            tags "External"
        }
        resend = softwareSystem "Resend" "Servicio externo de envío de correos electrónicos." {
            tags "External"
        }
        fcm = softwareSystem "Firebase Cloud Messaging" "Servicio externo de notificaciones push." {
            tags "External"
        }

        // Relaciones del diagrama de contexto
        ganadero -> anitec "Gestiona animales, observaciones y vinculaciones, consulta atenciones y administra su plan"
        veterinario -> anitec "Gestiona vinculaciones, visitas, atenciones y administra su plan"
        anitec -> stripe "Gestiona pagos y suscripciones, recibe resultados y cambios de estado"
        anitec -> resend "Solicita correos de verificación e invitaciones"
        anitec -> fcm "Solicita el envío y recibe en los dispositivos notificaciones de indicaciones"

        // Relaciones del diagrama de contenedores
        ganadero -> mobile "Gestiona su ganado, vinculaciones, consulta atenciones y administra su plan"
        veterinario -> mobile "Gestiona visitas, atenciones, vinculaciones y su plan"
        mobile -> localDb "Actualiza y consulta datos descargados del usuario para su uso sin conexión"
        mobile -> api "Solicita operaciones y recibe información y resultados" "HTTPS / JSON"
        api -> database "Consulta y persiste información mediante Spring Data JPA / Hibernate" "JDBC"
        api -> stripe "Gestiona pagos y suscripciones; recibe confirmaciones y cambios de estado" "HTTPS / API y webhooks"
        api -> resend "Solicita el envío de códigos de verificación e invitaciones" "HTTPS"
        api -> fcm "Solicita el envío de notificaciones de nuevas indicaciones y sus actualizaciones" "HTTPS"
        mobile -> fcm "Registra el dispositivo para notificaciones y recibe mensajes push" "SDK de FCM para Flutter"
    }

    views {
        systemContext anitec "AnitecSystemContext" {
            include *
            autoLayout tb

            title "ANITEC - Diagrama de contexto del sistema"
            description "Usuarios y servicios externos que interactúan con ANITEC."
        }

        container anitec "AnitecContainers" {
            include *
            autoLayout tb

            title "ANITEC - Diagrama de contenedores"
            description "Aplicación Flutter para Android e iOS, almacenamiento local, API REST con Spring Boot, base de datos central e integraciones externas."
        }

        styles {
            element "Person" {
                shape Person
                background #107EA1
                color #FFFFFF
            }

            element "Software System" {
                shape RoundedBox
                background #3F8434
                color #FFFFFF
            }

            element "Container" {
                shape RoundedBox
                background #DCEFE5
                color #163D2B
            }

            element "ANITEC" {
                background #3F8434
                color #FFFFFF
            }

            element "Mobile" {
                shape MobileDevicePortrait
                background #3F8434
                color #FFFFFF
            }

            element "API" {
                shape RoundedBox
                background #1E3A5F
                color #FFFFFF
            }

            element "Database" {
                shape Cylinder
                background #DCEFE5
                color #163D2B
            }

            element "External" {
                shape RoundedBox
                background #E2E8F0
                color #1E293B
            }

            relationship "Relationship" {
                color #475569
                thickness 2
                fontSize 22
            }
        }
    }
}