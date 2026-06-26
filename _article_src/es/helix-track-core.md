---
title: HelixTrack Core
slug: helix-track-core
repo: https://github.com/Helix-Track/Core
tech: Go, Gin, PostgreSQL, SQLite, SQLCipher, PLpgSQL, WebSocket
teaser: "The open-source JIRA alternative — extreme-performance issue tracking with military-grade encryption and a single action-routed API."
---

## El anzuelo

Imagina reconstruir JIRA y Confluence desde cero, como un único microservicio en Go, y lograr que sea lo suficientemente rápido para manejar decenas de miles de solicitudes por segundo con una base de datos cifrada por debajo. Eso es HelixTrack Core: *"La alternativa de código abierto a JIRA para el mundo libre"*. No es un clon de juguete: incluye épicas, subtareas, sprints, registros de trabajo, campos personalizados, paneles de control, esquemas de permisos y un motor completo de documentos al estilo Confluence, todo detrás de una única API REST.

## Por qué resulta fascinante

La mayoría de las herramientas de seguimiento de proyectos se convierten en monstruosos monolitos con docenas de endpoints que, con los años, terminan desincronizados. Yo tomé el camino opuesto. HelixTrack Core expone un único endpoint `/do` con **enrutamiento basado en acciones**: los clientes envían una acción con nombre y una carga útil, y el servidor la distribuye a través de un pipeline consistente de middleware y manejadores. Esa única decisión de diseño mantiene la superficie de la API coherente en cientos de operaciones —incidencias, tableros ágiles, votaciones, esquemas de notificaciones, flujos de actividad, menciones en comentarios— sin la proliferación de endpoints que vuelve inmanejables las API grandes.

Sobre esa base se asienta una verdadera alternativa a Confluence. La extensión Documents V2 implementa espacios, páginas enriquecidas en HTML/Markdown/texto plano, historial completo de versiones con diferencias y retrocesos, comentarios en línea, @menciones, reacciones, plantillas y analíticas, respaldado por su propio conjunto de tablas en la base de datos y validado por cientos de pruebas de modelo. Construir uno de estos sistemas ya es un proyecto; construir ambos como módulos cooperativos en un único binario es lo realmente interesante.

## Los problemas difíciles

Tres aspectos hacen que esto sea genuinamente complicado.

Primero, **seguridad sin penalización en el rendimiento**. Los rastreadores de incidencias empresariales manejan datos sensibles, por lo que la base de datos está cifrada en reposo con SQLCipher (AES-256). El cifrado suele implicar una penalización en la latencia: el desafío de ingeniería fue mantener ese sobrecosto al mínimo mientras se servían consultas rápidamente bajo alta concurrencia.

Segundo, **la realidad de múltiples bases de datos**. Los desarrolladores prefieren SQLite para un entorno local sin fricciones; en producción, se opta por PostgreSQL por su concurrencia y durabilidad. Dar soporte a ambas —incluyendo optimizaciones a nivel de PLpgSQL y un esquema que ha evolucionado a través de múltiples migraciones versionadas (de la V1 a la V4, superando las noventa tablas)— significa que cada funcionalidad debe funcionar correctamente en dos motores muy distintos.

Tercero, **colaboración en tiempo real con corrección**. En el momento en que varias personas editan el mismo ticket, surge el clásico problema del estado distribuido: actualizaciones perdidas y conflictos de escritura. Resolverlo sin bloquear a los usuarios entre sí requiere un modelo de concurrencia deliberado, no un añadido posterior.

## Lo que lo hace revolucionario

HelixTrack Core trata los permisos como un motor de primera clase e intercambiable. Implementa **permisos jerárquicos basados en contexto** con herencia, y su implementación es conectable: puede ejecutarse localmente dentro del servicio o delegarse en un servicio externo de autorización HTTP. Esta separación permite a las organizaciones integrar el rastreador en una infraestructura de identidad y políticas existente, en lugar de luchar contra un modelo integrado.

Además, hace algo que la mayoría de los rastreadores ignoran: **descubrimiento automático de servicios**. Los clientes encuentran los servidores de Core en la red local mediante difusión UDP, de modo que las aplicaciones multiplataforma (web, escritorio, Android, iOS) pueden conectarse sin configuración manual. Combinado con autenticación JWT, un sistema de extensiones para seguimiento de tiempo, documentos y chat, e integración con Git que vincula commits a tickets, se comporta como una plataforma, no como una simple aplicación.

## Cómo resolví los aspectos más complejos

Para la API, me comprometí desde el principio con el **patrón de enrutamiento por acciones**. Cada operación fluye a través del mismo ciclo de vida en `/do`: middleware de autenticación y permisos, seguido de un manejador identificado por el nombre de la acción. Por eso el sistema puede añadir capacidades (prioridades y resoluciones en la Fase 1, épicas y registros de trabajo en la Fase 2, votaciones y esquemas de notificaciones en la Fase 3, edición en paralelo en la Fase 4) sin que la API se fragmente. Las nuevas funciones registran nuevas acciones; el transporte y el middleware permanecen invariables.

Para la edición concurrente, implementé **bloqueo optimista con conflictos de versión** junto con una capa completa de historial de cambios. Cada entidad editable lleva una versión; una escritura que apunte a una versión obsoleta es rechazada con un conflicto que el cliente puede resolver, y las tablas de historial (añadidas en el esquema V4) registran el rastro completo de modificaciones. Añadí gestión explícita de bloqueos de entidades y acciones de resolución de conflictos, e integré todo en la capa WebSocket existente para que los colaboradores vean actualizaciones en tiempo real. Esto permite la colaboración en directo sin sobrescribir silenciosamente los cambios de otros.

Para el dilema entre cifrado y velocidad, el diseño se apoya en SQLCipher para un AES-256 transparente en la capa de almacenamiento, mientras optimiza las rutas críticas mediante caché, de modo que los patrones de lectura comunes se mantienen rápidos incluso con un almacén cifrado por debajo. El código base está respaldado por una amplia suite de pruebas automatizadas —más de mil pruebas en todas las fases—, lo que me permite realizar cambios en un esquema de más de noventa tablas, en un sistema cifrado, con múltiples bases de datos y edición concurrente, y confiar en que el comportamiento se mantiene. Junto al código se incluyen diagramas de arquitectura, un manual de usuario y una guía de despliegue, porque una alternativa a JIRA que nadie puede operar no es alternativa en absoluto.
