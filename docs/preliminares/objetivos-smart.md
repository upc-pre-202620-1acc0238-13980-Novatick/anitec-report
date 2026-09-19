<div align="justify">

## Objetivos SMART

### Objetivo general

Desarrollar, durante el ciclo académico, una aplicación móvil denominada ANITEC que permita a pequeños y medianos ganaderos gestionar la información de sus animales y realizar el seguimiento de atenciones veterinarias, integrando funcionalidades de registro del ganado, atención veterinaria, agenda de actividades y gestión de suscripciones, con el fin de centralizar la información necesaria para el cuidado de los animales.

### Objetivo SMART 1 - Gestión del ganado

Implementar antes de la entrega final del proyecto un módulo de gestión del ganado que permita registrar, consultar, actualizar y visualizar la información de cada animal, incluyendo sus datos principales, observaciones e historial relacionado con sus atenciones. El funcionamiento del módulo será verificado mediante pruebas de los flujos principales de registro y consulta de animales.

### Objetivo SMART 2 - Atención y seguimiento veterinario

Implementar antes de la entrega final un módulo de atención veterinaria que permita registrar visitas, diagnósticos, tratamientos e indicaciones asociadas a un animal, validando previamente que exista una vinculación activa entre el ganadero y el veterinario. Como resultado, cada atención registrada deberá quedar relacionada con el animal y disponible para su posterior consulta.

### Objetivo SMART 3 - Agenda y recordatorios

Implementar durante el desarrollo del proyecto un sistema de agenda y recordatorios que permita programar al menos tres tipos de actividades relacionadas con el cuidado del ganado: vacunas, controles veterinarios y tratamientos. El sistema deberá permitir consultar las actividades programadas y generar una notificación cuando corresponda realizar una de ellas.

### Objetivo SMART 4 - Suscripciones y límite de animales

Implementar antes de la entrega final un esquema de suscripciones que permita diferenciar entre un plan gratuito y un plan premium, aplicando un límite de animales de acuerdo con el plan activo del ganadero. La funcionalidad será validada mediante escenarios de activación de una suscripción, actualización del límite permitido y vencimiento del plan sin eliminar los animales registrados previamente.

### Objetivo SMART 5 - Funcionamiento con conectividad limitada

Implementar durante el ciclo académico almacenamiento local mediante SQLite para permitir que el usuario consulte información previamente descargada de sus animales cuando no disponga de conexión a internet. Una vez recuperada la conectividad, la aplicación deberá poder volver a comunicarse con los servicios principales de ANITEC para continuar con las operaciones que requieran acceso al backend.
