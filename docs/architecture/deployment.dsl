workspace "ANITEC - Deployment" "Despliegue propuesto de ANITEC." {

    !impliedRelationships false

    model {
        stripe = softwareSystem "Stripe" "Procesa pagos y suscripciones en modo de prueba." {
            tags "External"
        }

        resend = softwareSystem "Resend" "Envía correos de verificación e invitaciones." {
            tags "External"
        }

        fcm = softwareSystem "Firebase Cloud Messaging" "Gestiona la entrega de notificaciones push." {
            tags "External"
        }

        anitec = softwareSystem "ANITEC" "Aplicación de gestión ganadera y apoyo veterinario." {

            mobile = container "Aplicación móvil" "Gestiona animales, vinculaciones, atenciones y suscripciones según el perfil del usuario." "Flutter / Dart" {
                tags "Mobile"
            }

            localDb = container "Base de datos local" "Conserva inventario, fichas, atenciones, indicaciones y agenda descargados para consulta sin conexión." "SQLite" {
                tags "Database"
            }

            api = container "API REST" "Aplica las reglas de negocio, controla los permisos y gestiona las integraciones externas." "Java / Spring Boot" {
                tags "API"
            }

            database = container "Base de datos central" "Almacena cuentas, animales, vinculaciones, citas, atenciones, indicaciones y suscripciones." "MySQL" {
                tags "Database"
            }

            landing = container "Landing page" "Presenta ANITEC, sus funcionalidades y enlaces de descarga." "HTML5 / CSS3 / JavaScript" {
                tags "Web"
            }
        }

        // Relaciones entre los elementos de software
        mobile -> localDb "Guarda y consulta los datos descargados de la cuenta" "Acceso local"
        mobile -> api "Solicita operaciones y recibe información y resultados" "HTTPS / JSON"
        api -> database "Consulta y persiste información mediante JPA / Hibernate" "JDBC"
        api -> stripe "Gestiona pagos y suscripciones; recibe confirmaciones y cambios de estado" "HTTPS / API y webhooks"
        api -> resend "Solicita correos de verificación e invitaciones" "HTTPS"
        api -> fcm "Solicita el envío de notificaciones de indicaciones" "HTTPS"
        mobile -> fcm "Registra el dispositivo y recibe notificaciones push" "SDK de FCM"
        
        // Distribución propuesta en dispositivos y servidores
        deploymentEnvironment "Propuesto" {
            mobileDevice = deploymentNode "Dispositivo móvil del usuario" "Representa cada teléfono donde se instala ANITEC. Cada instalación mantiene sus propios datos locales." "Android o iOS" {
                mobileInstance = containerInstance mobile
                deviceStorage = deploymentNode "Almacenamiento privado de la aplicación" "Conserva los datos descargados de la cuenta en este teléfono." "Almacenamiento local del dispositivo" {
                    localDbInstance = containerInstance localDb
                }
            }

            applicationServer = deploymentNode "Servidor de aplicación" "Aloja el backend de ANITEC. Proveedor por definir." "Entorno de servidor compatible con Java" {
                jvm = deploymentNode "Entorno de ejecución Java" "Ejecuta la API REST desarrollada con Spring Boot." "JVM" {
                    apiInstance = containerInstance api
                }
            }

            databaseServer = deploymentNode "Servidor de base de datos" "Aloja la información central de ANITEC. Proveedor por definir." "Servicio de base de datos" {
                mysql = deploymentNode "Motor MySQL" "Gestiona la persistencia central del sistema." "MySQL" {
                    databaseInstance = containerInstance database
                }
            }

            visitorDevice = deploymentNode "Dispositivo del visitante" "Computadora o teléfono desde el que se consulta la landing page." "Dispositivo con acceso a Internet" {
                browser = infrastructureNode "Navegador web" "Solicita y muestra la landing page." "Navegador compatible con HTML5"
            }

            webHosting = deploymentNode "Hosting de la landing page" "Publica los archivos del sitio. Proveedor por definir." "Hosting estático con HTTPS" {
                landingInstance = containerInstance landing
            }

            stripeCloud = deploymentNode "Servicio externo de pagos" "Infraestructura administrada por Stripe." "Stripe - modo de prueba" {
                stripeInstance = softwareSystemInstance stripe
            }

            resendCloud = deploymentNode "Servicio externo de correo" "Infraestructura administrada por Resend." "Resend" {
                resendInstance = softwareSystemInstance resend
            }

            fcmCloud = deploymentNode "Servicio externo de notificaciones" "Infraestructura administrada por Google." "Firebase Cloud Messaging" {
                fcmInstance = softwareSystemInstance fcm
            }

            browser -> landingInstance "Solicita y recibe el sitio estático" "HTTPS"
        }
    }

    views {
        deployment * "Propuesto" "AnitecDeployment" {
            include *
            autoLayout tb

            title "ANITEC - Diagrama de despliegue propuesto"
            description "Instalación móvil representativa de Android o iOS, backend, almacenamiento central, landing page y servicios externos."
        }

        styles {
            element "Deployment Node" {
                background #F1F5F9
                color #1E293B
                stroke #94A3B8
            }

            element "Infrastructure Node" {
                shape WebBrowser
                background #E2E8F0
                color #1E293B
            }

            element "Container" {
                shape RoundedBox
                background #237A57
                color #FFFFFF
            }

            element "Software System" {
                shape RoundedBox
                background #E2E8F0
                color #1E293B
            }

            element "Mobile" {
                shape MobileDevicePortrait
                background #237A57
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

            element "Web" {
                shape RoundedBox
                background #398A78
                color #FFFFFF
            }

            element "External" {
                shape RoundedBox
                background #E2E8F0
                color #1E293B
            }

            relationship "Relationship" {
                color #475569
                thickness 2
                fontSize 20
            }
        }
    }
}