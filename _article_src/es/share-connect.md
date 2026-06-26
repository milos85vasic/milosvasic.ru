---
title: ShareConnect
slug: share-connect
repo: https://github.com/vasic-digital/ShareConnect
tech: Kotlin
teaser: "Share any media link from your phone straight to your own download stack — 20 production-ready apps, eight things kept in sync across all of them."
---

## El anzuelo

Encuentras un vídeo, un torrent, un archivo que vale la pena guardar —en tu teléfono, en un navegador, en un chat—. Luego llega la fricción: copiar el enlace, cambiar de dispositivo, buscar el cliente adecuado, pegar, configurar, cruzar los dedos. ShareConnect elimina todo eso. Se integra en la hoja de compartir nativa de Android para que cualquier URL descargable vaya directamente a *tu* infraestructura —MeTube, YT-DLP, qBittorrent, Transmission, jDownloader y más—, conectando el descubrimiento de contenido con tus propios servicios de descarga. El nombre lo dice todo: **compartir** se encuentra con **conectar**.

## Por qué es fascinante

ShareConnect no es una sola app; es un ecosistema de 20 aplicaciones para Android listas para producción, desarrolladas en un plan deliberado de tres fases. La fase uno es el núcleo: el ShareConnector principal más clientes dedicados para qBittorrent, Transmission y uTorrent. La fase dos añade ocho servicios en la nube: JDownloader (a través de la API de MyJDownloader), MeTube, YT-DLP (que soporta más de 1800 sitios de *streaming*), Nextcloud, FileBrowser, Plex, Jellyfin y Emby. La fase tres completa el conjunto con ocho servicios especializados, entre ellos Seafile, Syncthing, Matrix, Paperless-NG, Duplicati, WireGuard, un controlador de servidores de Minecraft y OnlyOffice.

Pero lo realmente interesante es la capa de sincronización subyacente. ShareConnect mantiene ocho elementos distintos sincronizados en todas las apps del ecosistema: tema, perfiles, historial, fuentes RSS, marcadores, preferencias, idioma y estado de compartición de torrents. Así, el tema de la app principal es el mismo en qBitConnect; tu historial de descargas te sigue; tus perfiles son consistentes en todas partes. Veinte apps que funcionan como un solo producto.

## Los problemas difíciles

El primer desafío es la amplitud de las integraciones. Cada *backend* —qBittorrent, Transmission, jDownloader, Plex, Jellyfin, Nextcloud, Matrix, Syncthing— tiene su propia API, modelo de autenticación y peculiaridades. Construir 20 clientes que hablen correctamente el protocolo de su objetivo, compartiendo suficiente estructura común para mantenerse manejables, es tanto un problema de disciplina como de código.

El segundo es la sincronización entre apps. Sincronizar ocho categorías de estado en múltiples aplicaciones de Android instaladas por separado implica resolver preguntas reales de sistemas distribuidos en un solo dispositivo y más allá: ¿cómo descubren las apps independientes unas a otras, acuerdan un estado compartido y resuelven cambios sin pisarse? Tema, perfiles, historial, RSS, marcadores, preferencias, idioma y compartición de torrents tienen patrones de actualización y semánticas de conflicto distintos.

El tercero es demostrar que todo funciona. Con 20 apps y una capa de sincronización compartida, la superficie de pruebas es enorme, y el proyecto no retrocede: reporta un 100 % en suites de pruebas unitarias, de instrumentación y automatizadas, además de una pasada de QA impulsada por IA, junto con una calificación A+ en SonarQube, cero vulnerabilidades críticas en Snyk, una cobertura de código del ~95 % y un ratio de deuda técnica del 0,2 %. Mantener ese listón en todo un ecosistema es la parte difícil que la mayoría de los proyectos evitan en silencio.

## Lo que lo hace revolucionario

El cambio de juego es la comodidad del autoalojamiento sin concesiones. Las funciones comerciales de "enviar a mis dispositivos" te encierran en la nube de otro. ShareConnect dirige esa misma comodidad de un solo toque hacia la infraestructura *que tú controlas* —tu cliente de torrents, tu servidor multimedia, tu Nextcloud— y la hace sentir nativa en Android. Convierte una colección dispersa de servicios autoalojados en una superficie única, coherente y compartible.

Y como la capa de sincronización es el tejido conectivo, el ecosistema escala con elegancia: un cliente complementario como qBitConnect o TransmissionConnect no es un silo, sino que hereda automáticamente el tema, los perfiles y el historial compartidos. Todo está construido sobre una pila moderna de Android —Kotlin 2.0, Java 17, API de Android 26+—, así que no es un prototipo; son 20 apps marcadas como listas para producción.

## Cómo resolví las partes más difíciles

Traté la capa de sincronización como el núcleo del producto, no como una funcionalidad. En lugar de añadir sincronización a cada app, la construí como módulos de sincronización dedicados y compartidos —ThemeSync, ProfileSync, HistorySync, RSSSync, BookmarkSync, PreferencesSync, LanguageSync y TorrentSharingSync— a los que se conecta cada aplicación del ecosistema. Esa decisión es la razón por la que un nuevo cliente obtiene consistencia "gratis": adopta los módulos en lugar de reinventarlos.

Para la expansión de integraciones, usé un patrón de conector: cada *backend* (qBittorrent, Transmission, MeTube, YT-DLP, JDownloader, Plex y los demás) es un módulo conector autónomo detrás de un contrato común, lo que permite que 20 clientes sean individualmente correctos y colectivamente mantenibles. La implementación por fases —clientes principales, luego servicios en la nube y finalmente los especializados— permitió que cada capa se estabilizara antes de que la siguiente se construyera sobre ella.

Por último, me negué a que la calidad decayera a medida que crecía la superficie. Las suites de pruebas unitarias, de instrumentación y automatizadas con un 100 % de aprobación, junto con una fase de QA impulsada por IA, no son medallas de vanidad; son la única forma de evitar que un ecosistema de 20 apps con una capa de sincronización compartida colapse bajo el peso de sus propias regresiones. Mantener una cobertura del ~95 % y un ratio de deuda técnica del 0,2 % en todo el proyecto es lo que permitió afirmar con credibilidad que cada una de esas 20 apps estaba lista para producción.
