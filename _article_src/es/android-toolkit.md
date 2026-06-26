---
title: Android Toolkit
slug: android-toolkit
repo: https://github.com/vasic-digital/Android-Toolkit
tech: Kotlin
teaser: "The reusable foundation under my Android apps — drop-in modules from root shells to interprocess comms, added as one git submodule."
---

## El gancho

Todo desarrollador serio de Android acumula el mismo montón de código "esto ya lo he escrito antes": un arnés de pruebas sensato, una fachada de registro, ayudantes de acceso root, tuberías entre procesos, un ImageView circular, un desplazador rápido alfabético. Android Toolkit es ese montón, refinado en una biblioteca limpia y modular: un conjunto de abstracciones, implementaciones y herramientas de uso común que añades a un proyecto con `git submodule add` y empiezas a usar al instante. Es la base poco glamurosa que hace posibles las aplicaciones glamurosas.

## Por qué es fascinante

Lo fascinante es la arquitectura de *contención*. El Toolkit está dividido en módulos enfocados e independientes que pueden incluirse por separado —`Main`, `Test`, `Echo`, `Access`, `JCommons`, `RootTools`, `RootShell`, `Interprocess`, `CircleImageView`, `ConnectionIndicator`, `FastscrollerAlphabet`— y solo integras los que necesitas mediante `settings.gradle` y `build.gradle`. Nada de monolito, nada de arrastrar un fregadero entero por un único ayudante. Esa granularidad es una decisión de diseño real: cada módulo se gana su lugar por méritos propios.

Además, se distribuye como submódulo de git en lugar de como artefacto publicado, lo que deja claro su propósito. Es la columna vertebral compartida en el portafolio de un desarrollador de Android: la capa base consistente que mantiene el mismo comportamiento en múltiples aplicaciones, evolucionando al unísono sin que surjan divergencias por copiar y pegar entre proyectos. Los módulos abarcan un rango inusualmente amplio, desde acceso al sistema de bajo nivel (herramientas y shells root) hasta comunicación entre procesos y widgets de UI listos para usar, lo que permite que el mismo Toolkit sirva tanto para una app de sistema para usuarios avanzados como para una interfaz de consumo pulida.

## Los problemas difíciles

El primer problema difícil es el contrato de modularidad. Para que un sistema de módulos *à la carte* funcione de verdad, los límites deben ser honestos: `RootShell` y `RootTools` no pueden depender en secreto de un widget de UI; `Interprocess` no puede arrastrar andamiaje de pruebas. Diseñar módulos que sean genuinamente independientes pero que se integren limpiamente a través de Gradle es más difícil que construir una gran biblioteca monolítica, porque cada costura es un compromiso.

El segundo son los rincones peligrosos de Android. El acceso root (`RootShell`, `RootTools`) y la comunicación entre procesos (`Interprocess`) son precisamente las áreas donde los errores se convierten en agujeros de seguridad o fallos entre aplicaciones. Envolver shells privilegiados e IPC en abstracciones seguras y ergonómicas —fáciles de usar correctamente, difíciles de usar de forma catastrófica— es el tipo de trabajo que no se ve en una captura de pantalla, pero que determina si las aplicaciones que se construyen sobre ellas son confiables.

El tercero es ser una base para muchos proyectos a la vez. Un toolkit consumido por múltiples aplicaciones mediante submódulo debe evolucionar con cuidado: un cambio en una abstracción compartida tiene repercusiones en todas partes. Por eso el Toolkit incluye un módulo `Test` dedicado y configura las dependencias de pruebas (`testImplementation`, `androidTestImplementation`) como una preocupación de primer orden: la base debe ser comprobable, y las aplicaciones construidas sobre ella deben ser comprobables a través de ella.

## Lo que lo hace revolucionario

El cambio de juego es el apalancamiento. Una infraestructura reutilizable como esta es lo que permite a un solo ingeniero mantener de manera creíble toda una familia de aplicaciones Android —el ecosistema ShareConnect, Yole y más— sin tener que reconstruir lo básico cada vez. El Toolkit convierte los "problemas comunes de Android" en módulos resueltos, compartidos y versionados, de modo que cada nueva aplicación parte de un nivel más alto e hereda, por defecto, consistencia en registro, pruebas, acceso al sistema y primitivas de UI.

El modelo de distribución por submódulo amplifica ese efecto: las mejoras realizadas al construir una aplicación fluyen de vuelta al Toolkit y benefician inmediatamente a las demás. Es una inversión que se acumula: la base se fortalece cada vez que se usa.

## Cómo resolví las partes más difíciles

Diseñé para la inclusión opcional desde la primera línea. Al dividir el Toolkit en módulos de Gradle de alcance reducido y documentar que solo incluyes *lo que necesitas*, convertí la biblioteca en algo aditivo en lugar de impositivo: un proyecto incorpora `RootShell` e `Interprocess` sin heredar un widget de UI que nunca renderizará. Mantener la lista de módulos explícita en `settings.gradle` hace que la superficie de dependencias sea visible e intencional, en lugar de mágica.

Para los rincones peligrosos, aislé los privilegios y la IPC en sus propios módulos —`RootShell`/`RootTools` para acceso root, `Interprocess` para comunicación entre procesos— de modo que el código arriesgado quede detrás de un límite deliberado que hay que cruzar por elección, no algo que se filtre a todos los consumidores por defecto. Ese aislamiento es lo que hace que el resto del Toolkit sea seguro para depender de él ampliamente.

Y traté las pruebas como parte de la base, no como un añadido: incluir un módulo `Test` y configurar el cableado estándar de `testImplementation`/`androidTestImplementation` significa que cada aplicación construida sobre el Toolkit obtiene una configuración de pruebas consistente desde el principio, y los cambios en abstracciones compartidas pueden validarse antes de que se propaguen por todo el portafolio. Todo se distribuye como submódulo precisamente para que la base y las aplicaciones que se apoyan en ella puedan avanzar juntas: una base, muchos productos, sin divergencias.
