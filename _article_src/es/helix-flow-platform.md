---
title: Helix-Flow Platform
slug: helix-flow-platform
repo: https://github.com/Helix-Flow/Platform
tech: Go, gRPC, HTTP, TLS 1.3, mTLS, PostgreSQL, SQLite, JWT
teaser: "One OpenAI-compatible gateway for all your AI inference — TLS 1.3, mutual-auth service mesh, predictable costs, drop-in API."
---

## El anzuelo

"Una plataforma para todas tus necesidades de inferencia de IA: ejecuta modelos de IA potentes más rápido, de forma más inteligente y a cualquier escala, con costos predecibles". Helix-Flow Platform es una pasarela de inferencia de IA empresarial que habla el API de OpenAI, de modo que tus clientes existentes funcionan sin cambios, pero opera como una malla de microservicios endurecida y con autenticación mutua bajo el capó, con TLS 1.3 de extremo a extremo.

## Por qué es fascinante

La promesa de la inferencia de IA es sencilla de enunciar y brutal de cumplir: ofrecer a los equipos una forma consistente, rápida y segura de invocar modelos sin encerrarlos en los precios o el entorno de ejecución de un único proveedor. Helix-Flow aborda este desafío como una **arquitectura de microservicios de grado empresarial**: una pasarela API que expone servicios independientes para autenticación, un pool de inferencia y monitoreo, accesibles tanto por HTTP como por gRPC de manera simultánea.

Lo crucial es que apunta a la **compatibilidad con la especificación del API de OpenAI**. Esto significa que la interfaz familiar —`/v1/models`, `/v1/chat/completions`, autenticación con Bearer-token— está presente, de modo que cualquier aplicación ya construida sobre el API de OpenAI puede redirigirse a Helix-Flow sin modificaciones. Obtienes un punto de conexión directo, pero con tu propia autenticación, tu propio monitoreo y tus propios controles de costos detrás.

## Los problemas difíciles

El desafío central es la **seguridad a nivel de malla de servicios, no solo en el perímetro**. Es fácil implementar TLS en un punto de acceso público; es mucho más difícil cifrar y autenticar cada salto *entre* servicios internos. Helix-Flow construye una PKI completa y ejecuta TLS 1.3 con **TLS mutuo (mTLS)** en toda su malla de servicios gRPC, de modo que los servicios se autentican entre sí, no solo ante el mundo exterior. Esto requiere gestión automatizada de certificados —generación, distribución y rotación—, porque una malla asegurada manualmente no sobrevive al contacto con la producción.

El segundo problema difícil es la **paridad entre protocolos duales**. Ofrecer tanto una pasarela HTTP como una gRPC implica que las mismas capacidades deben funcionar correctamente sobre dos transportes muy distintos, con autenticación y comportamiento consistentes en ambos. Los equipos que prefieren REST y aquellos que optan por gRPC de alto rendimiento deben obtener la misma plataforma.

El tercero es la **previsibilidad de costos y operatividad**. "Costos predecibles" es una promesa de producto que solo se cumple si la plataforma cuenta con monitoreo real, limitación de tasas y registro de auditoría, de modo que el gasto y el comportamiento sean observables y acotados, en lugar de una sorpresa al final del mes.

## Qué la hace revolucionaria

La apuesta de Helix-Flow es que la inferencia de IA debería ser **infraestructura**, no una integración por aplicación. Al presentar un API compatible con OpenAI frente a un pool de inferencia agnóstico a proveedores, permite a una organización centralizar cómo invoca los modelos: una única pasarela, un único modelo de autenticación, un único lugar para aplicar límites de tasa y un único registro de auditoría. Cambiar o añadir backends de modelos se convierte en una decisión de infraestructura, no en un cambio de código disperso en cada aplicación consumidora.

Y lo logra sin sacrificar los fundamentos empresariales: validación de JWT, limitación de tasas, registro de auditoría, manejo elegante de errores y un backend multi-base de datos (SQLite para desarrollo, PostgreSQL para producción), de modo que puede pasar de un portátil a un clúster sin alterar el contrato del que dependen los clientes.

## Cómo resolví las partes más difíciles

Construí la seguridad desde los cimientos, en lugar de añadirla después. La plataforma incluye una **PKI completa con TLS 1.3 y mTLS**, y el aprovisionamiento de certificados está automatizado para que la malla de servicios pueda autenticarse sin manipulación manual de certificados. Cada salto interno de gRPC está mutuamente autenticado; la pasarela termina el tráfico externo sobre TLS y valida los JWT antes de que nada llegue al pool de inferencia. La seguridad es una propiedad inherente de la malla, no un envoltorio alrededor de ella.

Para el soporte de protocolos duales, diseñé la **pasarela API para servir HTTP y gRPC en paralelo**, exponiendo los servicios más pesados —autenticación y el pool de inferencia— mediante gRPC para mejorar el rendimiento, mientras que la interfaz pública se mantiene sobre HTTP para garantizar compatibilidad. Esta división permite que las llamadas internas sensibles a la latencia usen gRPC, mientras que los clientes externos conservan la sencilla interfaz REST al estilo OpenAI.

Para garantizar la operatividad y la promesa de "costos predecibles", convertí el **servicio de monitoreo en un componente de primera clase**, junto a la autenticación y la inferencia, incorporando comprobaciones de estado, recolección de métricas, limitación de tasas y registro de auditoría para que el uso y la salud del sistema sean visibles y acotados por defecto. El diseño multi-base de datos —SQLite para ejecuciones locales sin fricción, PostgreSQL para producción— permite que la misma plataforma se valide en una sola máquina y luego escale, que es exactamente lo que debe poder hacer una plataforma de inferencia "a cualquier escala".
