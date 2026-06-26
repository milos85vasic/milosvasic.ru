---
title: Mail Server Factory
slug: mail-server-factory
repo: https://github.com/Server-Factory/Mail-Server-Factory
tech: Shell/Go
teaser: "Describe your mail server in one JSON file; it provisions a hardened, Dockerized stack on 25 Linux distros across 12 connection types."
---

## Der Haken

Einen eigenen Mailserver zu betreiben, gilt zu Recht als eine der undankbarsten Aufgaben in der Systemadministration: SMTP, IMAP, POP3, TLS, DKIM, SPF, Firewalls, Zertifikate, SELinux und ein Dutzend Daemons, die sich alle einig sein müssen – oder nichts wird zugestellt. *Mail Server Factory* wirbt mit einer glorios direkten Botschaft: *„Betreibe deinen Mailserver wie ein Boss."* Man schreibt eine einfache JSON-Datei, die beschreibt, was man möchte, und die Factory interpretiert sie und baut den gesamten gehärteten, Docker-basierten Stack auf dem Zielsystem für einen auf.

## Warum es fasziniert

Die faszinierende Idee besteht darin, die Bereitstellung eines Mailservers als *Kompilierungsproblem* zu behandeln. Die JSON-Konfiguration ist der Quellcode; die Factory der Compiler; ein laufender, lose gekoppelter, Docker-basierter Mail-Stack auf dem Zielbetriebssystem das Ergebnis. Da jede Komponente des Stacks lose gekoppelt und containerisiert ist, entsteht eine saubere Basis für spätere Skalierung – statt eines Gewirrs handeditierter Konfigurationsdateien, das niemand anzurühren wagt.

Was es von *„nett"* zu *„ernsthaft"* erhebt, ist die Reichweite. Die Factory kann diesen Stack über 12 verschiedene Verbindungstypen ausliefern: SSH, Docker, Kubernetes, AWS SSM, Azure Serial Console, GCP OS Login, Libvirt, ein eigenes Protokoll, Datenbank, Dateisystem, Cloud-Anbieter und Container-Runtime. Und sie unterstützt 25 Linux-Distributionen, darunter auch solche, die die meisten Tools komplett ignorieren: westliche Standarddistributionen (Ubuntu, Debian, CentOS, Fedora, AlmaLinux, Rocky, openSUSE), russische Distributionen (ALT, Astra, ROSA) und chinesische (openEuler, openKylin, Deepin). Diese Bandbreite ist eine bewusste Aussage: *Dein Mailserver, deine Hardware, deine Jurisdiktion.*

## Die harten Probleme

Das erste harte Problem ist, dass *„dieselbe Installation"* nie dieselbe ist. Paketnamen, Init-Systeme, Firewall-Frontends und das SELinux-Verhalten unterscheiden sich über 25 Distributionen hinweg. Die Factory bringt ein echtes Sicherheitsframework mit – einen `CertificateValidator`, `DockerCredentialsManager`, `SELinuxChecker`, `PasswordValidator` und einen `ConnectionPool` – genau weil sich jede dieser Komponenten je nach Plattform anders verhält und nichts als gegeben vorausgesetzt werden kann.

Das zweite Problem ist die Verbindungsschicht selbst. Ein Zielsystem über SSH zu erreichen, ist etwas völlig anderes, als es über AWS SSM, Azure Serial Console oder Libvirt anzusteuern. Jeder Transport hat seine eigene Authentifizierung, seine eigene Latenz und seine eigenen Fehlermodi. All diese 12 Methoden hinter einer einzigen Installationspipeline zu abstrahieren – sodass die Installationsschritte sich nicht darum kümmern müssen, wie die Bytes zum System gelangen – ist das architektonische Rückgrat des Projekts.

Das dritte Problem ist, überhaupt erst an eine saubere Maschine zu kommen. Die Factory automatisiert unbeaufsichtigte Betriebssysteminstallationen via Preseed, Kickstart, Cloud-Init und AutoYaST über all diese Distributionen hinweg, steuert QEMU-Virtualisierungen mit `scripts/qemu_manager.sh` und verwaltet ISO-Images mit Prüfsummenverifizierung und einem unternehmensreifen Dreh: einem bidirektionalen SMB-Cache, der fehlende Images von einem Netzwerkshare bezieht, fehlende hochlädt und erst als letzten Ausweg auf Internet-Downloads zurückgreift.

## Was es zum Game-Changer macht

Der Game-Changer ist, dass es selbstgehostete Mail-Infrastruktur *reproduzierbar und auditierbar* macht. E-Mail-Infrastruktur ist genau die Art von System, die man als Daten beschreiben und identisch neu aufbauen möchte – nicht um 2 Uhr morgens aus dem Gedächtnis zusammenstoppeln. Mit dem in JSON definierten Stack und der durch Code erzwungenen Sicherheitshaltung – AES-256-GCM-Verschlüsselung, obligatorische SSH-Schlüssel-Passphrasen mit mindestens 12 Zeichen, automatisierte Firewall-Regeln für die Ports 25/587/465/993/995, TLS mit Zertifikatsvalidierung und HSTS, Audit-Logging und RBAC – hört *„produktionsreifer Mailserver"* auf, ein mehrwöchiges Projekt zu sein, und wird zu einer Konfiguration, die man prüfen, versionieren und erneut ausführen kann.

Es ist zudem rigoros validiert, nicht nur ein frommer Wunsch: Das Projekt weist 439 Tests mit 100 % Erfolgsquote aus, ein 100 %iges SonarQube-Qualitätsgate und ein vollständiges Testframework, das echtes SMTP/IMAP/POP3-Verhalten über Distributionen hinweg prüft – inklusive Durchsatz- und Latenzmessungen. Für ein Tool, dessen einzige Aufgabe darin besteht, mit den eigenen E-Mails vertraut zu werden, ist dieser Nachweis das entscheidende Feature.

## Wie ich die härtesten Teile gelöst habe

Ich habe *was gebaut werden soll* von *wie das Ziel erreicht wird* und *auf welchem Betriebssystem* getrennt. Die JSON-Konfiguration beschreibt die Absicht; eine Transportabstraktion verbirgt die 12 Verbindungstypen hinter einer einzigen Schnittstelle, sodass Installationsschritte dieselben logischen Operationen ausführen – egal, ob sie über SSH oder AWS SSM laufen. Und die distributionsspezifische Logik ist isoliert, sodass die 25-Distro-Matrix an einer Stelle lebt, statt sich in jeden Schritt einzuschleichen. Diese Schichtung ist der Grund, warum das Hinzufügen einer Distribution oder eines Verbindungstyps nicht durch den gesamten Code hallt.

Bei der Sicherheit habe ich nichts dem guten Willen des Betreibers überlassen. Das Framework erzwingt die schwierigen Teile – es *prüft* SELinux, *validiert* Zertifikate, *verwaltet* Docker-Anmeldedaten und *lehnt* schwache Passwörter sowie SSH-Schlüssel ohne Passphrase ab – sodass eine korrekte Bereitstellung der Standard ist, nicht ein mühsam erreichtes Ziel. Shell-Skripte übernehmen die schwere Provisionierung, wo sie das richtige Werkzeug sind, Kotlin/JVM-Logik die Orchestrierung und das Sicherheitsframework, und Docker hält jede Komponente lose gekoppelt.

Und ich habe das *„saubere Maschine"*-Bootstrapping gelöst, das die meisten Installer einfach ignorieren: unbeaufsichtigte Installationen für jede unterstützte Distribution, QEMU-Automatisierung zum Hochfahren von Testzielen und den bidirektionalen SMB-ISO-Cache, damit eine Flottenbereitstellung dasselbe Image nicht fünfundzwanzigmal herunterlädt – wobei jedes ISO unabhängig von seiner Herkunft prüfsummengeprüft wird. Das Ergebnis ist ein Tool, das einen von blankem Metall (oder einer leeren VM) bis hin zu einem gehärteten, getesteten, laufenden Mailserver bringt – gesteuert von einer einzigen Datei.
