---
title: Mail Server Factory
slug: mail-server-factory
repo: https://github.com/Server-Factory/Mail-Server-Factory
tech: Shell/Go
teaser: "Describe your mail server in one JSON file; it provisions a hardened, Dockerized stack on 25 Linux distros across 12 connection types."
---

## El anzuelo

Gestionar tu propio servidor de correo tiene merecida fama de ser uno de los trabajos más ingratos en la administración de sistemas: SMTP, IMAP, POP3, TLS, DKIM, SPF, firewalls, certificados, SELinux y una docena de demonios que deben ponerse de acuerdo o nada se entrega. El discurso de Mail Server Factory es gloriosamente directo: *"Gestiona tu servidor de correo como un jefe"*. Escribes un simple archivo JSON que describe lo que quieres, y la Factory lo interpreta y construye por ti toda la pila endurecida y dockerizada en la máquina de destino.

## Por qué resulta fascinante

La idea fascinante es tratar el despliegue de un servidor de correo como un problema de *compilación*. La configuración en JSON es el código fuente; la Factory, el compilador; y el resultado, una pila de correo en ejecución, desacoplada y basada en Docker, sobre el sistema operativo de destino. Al estar cada componente de la pila desacoplado y contenerizado, el resultado es una base limpia para escalar más adelante, en lugar de un laberinto de archivos de configuración editados a mano que nadie se atreve a tocar.

Lo que eleva este enfoque de "interesante" a "serio" es su alcance. La Factory puede desplegar esa pila a través de 12 tipos distintos de conexión: SSH, Docker, Kubernetes, AWS SSM, Azure Serial Console, GCP OS Login, Libvirt, un protocolo personalizado, base de datos, sistema de archivos, proveedor en la nube y entorno de ejecución de contenedores. Además, soporta 25 distribuciones Linux, incluyendo algunas que la mayoría de herramientas ignoran por completo: las principales occidentales (Ubuntu, Debian, CentOS, Fedora, AlmaLinux, Rocky, openSUSE), distribuciones rusas (ALT, Astra, ROSA) y chinas (openEuler, openKylin, Deepin). Esa amplitud es una declaración intencional: tu servidor de correo, tu hardware, tu jurisdicción.

## Los problemas difíciles

El primer problema difícil es que "la misma instalación" nunca es igual. Los nombres de los paquetes, los sistemas de inicio, los frontales de firewall y el comportamiento de SELinux varían entre las 25 distribuciones. La Factory incorpora un marco de seguridad real —un `CertificateValidator`, un `DockerCredentialsManager`, un `SELinuxChecker`, un `PasswordValidator` y un `ConnectionPool`— precisamente porque cada uno de esos aspectos se comporta de manera distinta según la plataforma y no puede darse por sentado.

El segundo es la propia capa de conexión. Acceder a un destino mediante SSH no se parece en nada a hacerlo a través de AWS SSM, Azure Serial Console o Libvirt. Cada método de transporte tiene su propio sistema de autenticación, su latencia y sus modos de fallo. Abstraer los 12 tras una única canalización de instalación —de modo que los pasos de instalación no dependan de cómo llegan los bytes a la máquina— es la columna vertebral arquitectónica del proyecto.

El tercero es conseguir una máquina limpia desde cero. La Factory automatiza la instalación desatendida del sistema operativo mediante preseed, kickstart, cloud-init y autoyast en todas esas distribuciones, gestiona máquinas virtuales QEMU a través de `scripts/qemu_manager.sh` y maneja las ISO con verificación de sumas de control y un giro empresarial: una caché SMB bidireccional que descarga imágenes faltantes desde un recurso compartido en red, sube las que no estén disponibles y recurre a la descarga por internet solo como último recurso.

## Lo que lo convierte en un cambio de juego

El verdadero cambio de juego es que hace que el correo autohospedado sea *reproducible y auditable*. La infraestructura de correo electrónico es justo el tipo de cosa que uno quiere describir como datos y reconstruir de forma idéntica, no ensamblar de memoria a las 2 de la madrugada. Con la pila definida en JSON y la postura de seguridad aplicada por código —cifrado AES-256-GCM, frases de contraseña obligatorias para claves SSH de al menos 12 caracteres, reglas automatizadas de firewall para los puertos 25/587/465/993/995, TLS con validación de certificados y HSTS, registro de auditoría y RBAC—, "servidor de correo de nivel producción" deja de ser un proyecto de varias semanas para convertirse en una configuración que puedes revisar, versionar y volver a ejecutar.

Además, está rigurosamente validado, no es solo una aspiración: el proyecto informa de 439 pruebas superadas al 100%, un 100% en la puerta de calidad de SonarQube y un marco de pruebas completo que verifica el comportamiento real de SMTP/IMAP/POP3 en distintas distribuciones, junto con mediciones de rendimiento y latencia. Para una herramienta cuya función es ganarse tu confianza con tu correo, esa evidencia es la característica principal.

## Cómo resolví las partes más difíciles

Separé *qué construir* de *cómo llegar al destino* y de *en qué sistema operativo estamos*. La configuración en JSON describe la intención; una abstracción de transporte oculta los 12 tipos de conexión tras una única interfaz, de modo que los pasos de instalación emiten las mismas operaciones lógicas ya sea que fluyan por SSH o por AWS SSM; y la lógica específica de cada distribución está aislada, de manera que la matriz de 25 distribuciones reside en un solo lugar en lugar de filtrarse en cada paso. Esa estratificación es la razón por la que añadir una distribución o un tipo de conexión no genera ondas en todo el código base.

En cuanto a seguridad, me negué a dejar nada al buen criterio del operador. El marco impone los aspectos más críticos: *verifica* SELinux, *valida* certificados, *gestiona* las credenciales de Docker y *rechaza* contraseñas débiles y claves SSH sin frase de contraseña, de modo que un despliegue correcto es lo predeterminado, no un logro cuidadoso. Shell se encarga del aprovisionamiento pesado donde es la herramienta adecuada, con lógica en Kotlin/JVM para la orquestación y el marco de seguridad, y Docker mantiene cada componente desacoplado.

Y resolví el problema del "arranque en máquina limpia" que la mayoría de los instaladores evitan: instalaciones desatendidas para cada distribución soportada, automatización de QEMU para lanzar objetivos de prueba y la caché SMB bidireccional de ISO, de modo que un despliegue en flota no descarga la misma imagen veinticinco veces —con verificación de sumas de control para cada ISO, sin importar su origen—. El resultado es una herramienta que te lleva desde el metal desnudo (o una máquina virtual vacía) hasta un servidor de correo endurecido, probado y en funcionamiento, todo a partir de un solo archivo.
