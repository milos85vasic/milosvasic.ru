---
title: LLMs Verifier
slug: llms-verifier
repo: https://github.com/vasic-digital/LLMsVerifier
tech: Go
teaser: "Before any LLM touches production, it has to prove it can actually see your code — across 12 providers, in real time."
---

## El anzuelo

Cada equipo que se conecta al "último modelo" confía en silencio en un archivo de configuración. El nombre del modelo en tu YAML dice `gpt-4o` o `claude-sonnet`, el endpoint devuelve 200, y das por sentado que lo que hay al otro lado es real, está operativo y es capaz de realizar la tarea que estás a punto de encomendarle. LLMs Verifier existe porque esa suposición falla con la frecuencia suficiente como para doler. Es una plataforma empresarial en Go que se niega a permitir que un modelo no verificado entre en tu pipeline: cada modelo debe superar primero una comprobación literal de "¿ves mi código?" antes de que se le permita ser utilizado.

## Por qué resulta fascinante

Lo interesante es que "verificar un LLM" no es una sola prueba, sino toda una batería de ellas, y cada una falla de maneras distintas y engañosas. LLMs Verifier ejecuta comprobaciones de existencia, capacidad de respuesta, latencia, transmisión en streaming, llamadas a funciones, visión y *embeddings* como pruebas de verificación independientes. Un modelo puede existir pero no transmitir en streaming. Puede transmitir pero atragantarse con las llamadas a herramientas. Puede afirmar que soporta visión y, sin embargo, ignorar silenciosamente la imagen. Al tratar cada capacidad como una propiedad de primera clase, verificable de forma independiente, la plataforma convierte la pregunta "¿es bueno este modelo?" de una corazonada en un resultado medible y repetible.

Además, se comunica con 12 adaptadores de proveedores —OpenAI, Anthropic, Cohere, Groq, Together AI, Mistral, xAI, Replicate, DeepSeek, Cerebras, Cloudflare Workers AI y SiliconFlow— a través de una única interfaz normalizada. La misma suite de verificación, la misma puntuación, ejecutada contra APIs radicalmente distintas. Esa normalización es donde se derrama la mayor parte de la sangre ingenieril, porque ningún proveedor coincide en cómo se ven el streaming, las llamadas a funciones o los *embeddings* en la capa de transporte.

## Los problemas difíciles

El primer problema difícil es la heterogeneidad. Una capa de detección de capacidades debe saber que el streaming puede llegar como *Server-Sent Events*, marcos de WebSocket, un generador asíncrono, JSONL o un flujo de eventos en bruto, y debe detectar cuál entrega realmente un proveedor dado, no cuál prometen los documentos. Registra el soporte de compresión (gzip, brotli y compresión semántica a nivel de chat), el comportamiento de caché (caché de prompts de Anthropic y DashScope) y la disponibilidad de HTTP/3 por proveedor. Nada de esto es uniforme; todo debe descubrirse empíricamente.

El segundo es la confianza bajo fallos. En producción, los proveedores limitan el tráfico, degradan el servicio y desaparecen. La plataforma implementa comprobaciones de salud en tiempo real con conmutación por error inteligente y un patrón de *circuit breaker* para que un proveedor inestable no arrastre consigo toda la ejecución de verificación —ni la aplicación que la consume—.

El tercero es el contexto de largo alcance. El sistema admite sesiones de más de 24 horas con resúmenes generados por LLM y optimización de RAG, además de un patrón supervisor/trabajador que utiliza un LLM para dividir grandes trabajos de verificación en tareas distribuidas. Mantener la coherencia del estado durante un día completo de actividad de agentes, sin desbordar la ventana de contexto, es un problema genuino de sistemas distribuidos disfrazado de funcionalidad de LLM.

## Lo que lo hace revolucionario

El cambio de juego está en pasar de "configurado" a "comprobado". La mayoría de las pilas tecnológicas exportan una lista de nombres de modelos y cruzan los dedos. LLMs Verifier genera una exportación de configuración verificada que solo incluye los modelos que realmente superaron la verificación, y marca cada proveedor y modelo generado con el sufijo obligatorio `(llmsvd)`, de modo que nunca haya ambigüedad sobre qué fue verificado por máquina y qué fue editado manualmente. Esa única disciplina elimina toda una clase de incidentes: el modo de fallo "implementamos contra un modelo que no podía hacer lo que necesitábamos" simplemente no sobrevive a una puerta de exportación.

Además, está construido como infraestructura, no como un script. Despliegue en Docker y Kubernetes, métricas con Prometheus y paneles de Grafana, LDAP/SSO con SAML/OIDC, cifrado de bases de datos con SQLCipher e integraciones con Splunk, DataDog, New Relic y ELK. Ofrece SDKs para Python y JavaScript, y una superficie OpenAPI/Swagger. Es una plataforma que puedes entregar a un equipo de seguridad y a un equipo de infraestructura y que ambos asientan con la cabeza.

## Cómo resolví las partes más difíciles

Convertí la verificación en el contrato, no en un añadido. La decisión central fue que nada —ningún modelo, ningún proveedor— tiene derecho a ser utilizado hasta que no haya superado la suite, y la comprobación "¿ves mi código?" es la puerta de entrada innegociable. Ese enfoque impuso una separación clara: los adaptadores de proveedores son meros transportes, y el motor de verificación es el que dicta la verdad.

Para domar a 12 proveedores incompatibles, construí la detección de capacidades como una sonda empírica en lugar de una tabla estática de capacidades. El sistema pregunta a cada proveedor qué puede hacer probándolo realmente: abre un flujo de streaming y clasifica el marco (SSE frente a WebSocket frente a JSONL frente a generador asíncrono), intenta una llamada a función, envía una imagen, y registra la realidad observada, incluyendo peculiaridades de compresión y caché. Añadir un decimotercer proveedor se convierte en "escribe un transporte y deja que la sonda lo caracterice", no en "vuelve a auditar toda la matriz".

Para la resiliencia, recurrí a patrones en los que confío: *circuit breakers* alrededor de cada llamada saliente a proveedores, comprobaciones de salud que impulsan la conmutación por error automática y puntos de control respaldados en la nube (S3, Google Cloud, Azure) para que una ejecución supervisada de 24 horas pueda sobrevivir a un reinicio. Y lo escribí en Go a propósito: el modelo de concurrencia se adapta de forma natural a "ejecutar muchas sondas de verificación independientes contra múltiples servicios remotos poco fiables a la vez", que es exactamente la carga de trabajo. El resultado es un verificador que es en sí mismo de grado producción, porque una herramienta que controla la producción no tiene cabida si es inestable.
