---
title: Catalogizer
slug: catalogizer
repo: https://github.com/vasic-digital/Catalogizer
tech: Go, Gin, React, TypeScript, SQLCipher, WebSocket, SMB/FTP/NFS/WebDAV
teaser: "Point it at your SMB, FTP, NFS, WebDAV and local shares — it auto-detects 50+ media types, survives disconnects, and stays encrypted."
---

## El anzuelo

Tu contenido multimedia vive en todas partes: un recurso compartido SMB en el NAS, un servidor FTP, un montaje NFS, un servidor WebDAV, una unidad local… y nada lo entiende todo a la vez. *Catalogizer*, sí. Es un sistema avanzado de gestión de colecciones multimedia multiprotocolo que detecta, categoriza y organiza automáticamente los archivos en todos esos protocolos, los supervisa en tiempo real, enriquece todo con metadatos externos y mantiene el catálogo completo en una base de datos cifrada.

## Por qué es fascinante

*Catalogizer* trata "tu colección" como una única biblioteca lógica distribuida en almacenamientos heterogéneos. Identifica **más de 50 tipos de medios** —películas, series, música, videojuegos, software, documentales y más— y supervisa continuamente cada fuente en busca de cambios, actualizando los metadatos de forma automática. Enriquece las entradas con datos de múltiples proveedores externos (TMDB, IMDB, TVDB, MusicBrainz, Spotify, Steam y otros), analiza la calidad, rastrea versiones y ofrece estadísticas como tendencias de crecimiento.

La arquitectura está claramente dividida: una API REST de alto rendimiento en Go con Gin, un frontend moderno en React/TypeScript con Tailwind y una integración WebSocket para que la interfaz se actualice en vivo a medida que cambia el catálogo. Bajo el capó, los datos residen en un almacén **cifrado con SQLCipher**. Además, va más allá de la catalogación con funciones prácticas: un servicio de conversión a PDF, exportación e importación de favoritos en JSON y CSV, sincronización en la nube con S3 y Google Cloud Storage, e informes profesionales en PDF con gráficos.

## Los problemas difíciles

El mayor desafío es el **almacenamiento en red poco fiable**. Las conexiones SMB y similares se caen. Los montajes desaparecen. Un catalogador ingenuo arroja errores y corrompe su visión del sistema en cuanto un recurso compartido se desconecta. *Catalogizer* está diseñado para **resiliencia de protocolos**: maneja las desconexiones temporales con elegancia, se reconecta automáticamente y mantiene una caché para operar sin conexión, de modo que un NAS inestable no descarrile todo el sistema. Diseñar asumiendo que el fallo es el caso normal —y no una excepción— es la decisión de ingeniería que define este proyecto.

El segundo problema es **una única abstracción sobre protocolos muy distintos**. SMB, FTP, NFS, WebDAV y el sistema de archivos local tienen cada uno sus propias semánticas, peculiaridades y modos de fallo. Presentarlos a través de una interfaz cliente de sistema de archivos coherente —incluyendo el montaje NFS completo y operaciones de archivos en macOS— para que el motor de detección y el monitor puedan tratarlos de manera uniforme requiere un esfuerzo de integración considerable.

El tercero es la **detección a escala con seguridad**. Reconocer de forma fiable más de 50 tipos de medios, enriquecerlos con múltiples APIs externas y hacerlo todo sobre una base de datos cifrada con control de acceso basado en roles mediante JWT —sin que el cifrado o las llamadas a las APIs se conviertan en un cuello de botella— exige una arquitectura deliberada.

## Lo que lo hace revolucionario

La mayoría de los gestores de medios asumen que tus archivos son locales y que tu red es perfecta. *Catalogizer* parte de lo contrario y, aun así, funciona. La combinación de **alcance multiprotocolo, resiliencia y supervisión en tiempo real** le permite gestionar una colección distribuida y parcialmente disponible como si fuera una biblioteca ordenada, manteniéndola actualizada de forma automática en lugar de requerir un reescaneo manual.

Añade cifrado por defecto, control de acceso basado en roles, enriquecimiento con metadatos externos y funciones de salida realmente útiles (informes, exportaciones, sincronización en la nube, conversión a PDF), y deja de ser un simple catálogo para convertirse en una plataforma de gestión de un patrimonio multimedia disperso en protocolos y máquinas.

## Cómo resolví los aspectos más complejos

Convertí la **resiliencia en una propiedad de la capa de almacenamiento**, no en algo que cada función deba manejar por separado. Los clientes de sistema de archivos multiprotocolo son responsables de detectar desconexiones, reconectarse automáticamente y servir desde una caché offline cuando una fuente no está disponible. Como ese comportamiento reside en la abstracción del cliente, el motor de supervisión y el motor de detección que operan por encima pueden asumir que una fuente siempre es accesible: la cruda realidad de un montaje SMB caído se absorbe por debajo de ellos.

Para domar la diversidad de protocolos, unifiqué SMB, FTP, NFS, WebDAV y el acceso local tras una **única interfaz cliente de sistema de archivos**, con supervisión específica para cada protocolo, incluyendo el montaje NFS real y operaciones de archivos en macOS. El motor de detección de medios se sitúa sobre esa interfaz única, de modo que añadir un protocolo o corregir las peculiaridades de uno no afecta a la lógica de detección.

Para el comportamiento en tiempo real, la API en Go ejecuta un **servidor WebSocket** que envía actualizaciones al frontend en React en el instante en que cambia el catálogo, de manera que lo que ven los usuarios refleja las fuentes supervisadas en tiempo real, no una instantánea obsoleta. Además, mantuve la seguridad como requisito no negociable: la base de datos está cifrada con SQLCipher y la API está protegida por JWT con control de acceso basado en roles, de modo que un sistema que accede a múltiples recursos compartidos remotos y APIs externas no se convierta en el eslabón más débil. El resultado es un gestor de medios diseñado para el mundo tal como es: distribuido, intermitente y necesitado de transparencia y seguridad.
