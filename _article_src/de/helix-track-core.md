---
title: HelixTrack Core
slug: helix-track-core
repo: https://github.com/Helix-Track/Core
tech: Go, Gin, PostgreSQL, SQLite, SQLCipher, PLpgSQL, WebSocket
teaser: "The open-source JIRA alternative — extreme-performance issue tracking with military-grade encryption and a single action-routed API."
---

## Der Haken

Stellen Sie sich vor, Sie bauen JIRA und Confluence von Grund auf neu – als eine einzige Go-Microservice – und machen es so schnell, dass es Zehntausende Anfragen pro Sekunde verarbeitet, während darunter eine verschlüsselte Datenbank läuft. Das ist HelixTrack Core: *„Die Open-Source-Alternative zu JIRA für die freie Welt."* Es ist kein Spielzeug-Klon – es bietet Epics, Unteraufgaben, Sprints, Arbeitsprotokolle, benutzerdefinierte Felder, Dashboards, Berechtigungsschemata und eine vollständige Confluence-ähnliche Dokumenten-Engine, alles hinter einer einzigen REST-API.

## Warum es fasziniert

Die meisten Projektmanagement-Tools wachsen zu ausufernden Monolithen mit Dutzenden Endpunkten heran, die sich über die Jahre auseinanderentwickeln. Ich bin den umgekehrten Weg gegangen. HelixTrack Core stellt einen einheitlichen `/do`-Endpunkt mit **aktionsbasiertem Routing** bereit: Clients senden eine benannte Aktion und eine Payload, und der Server leitet sie durch eine konsistente Middleware- und Handler-Pipeline weiter. Diese eine Designentscheidung hält die API-Oberfläche über Hunderte von Operationen hinweg kohärent – von Issues über Agile Boards, Abstimmungen, Benachrichtigungsschemata und Aktivitätsströme bis hin zu Kommentaren mit Erwähnungen – ohne das Endpunkt-Wirrwarr, das große APIs unwartbar macht.

Darüber liegt eine echte Confluence-Alternative. Die Documents-V2-Erweiterung implementiert Bereiche, Rich Pages in HTML/Markdown/Plain Text, vollständige Versionshistorie mit Diffs und Rollback, Inline-Kommentare, @Erwähnungen, Reaktionen, Vorlagen und Analysen – gestützt auf eigene Datenbanktabellen und validiert durch Hunderte von Modelltests. Ein solches System zu bauen, ist schon ein Projekt; beide als kooperierende Module in einem einzigen Binary zu realisieren, ist der spannende Teil.

## Die harten Probleme

Drei Dinge machen das wirklich schwierig.

Erstens: **Sicherheit ohne Performance-Einbußen**. Enterprise-Issue-Tracker speichern sensible Daten, daher ist die Datenbank mit SQLCipher (AES-256) verschlüsselt. Verschlüsselung bedeutet normalerweise einen Latenz-Nachteil – die technische Herausforderung bestand darin, diesen Overhead minimal zu halten und gleichzeitig Abfragen unter hoher Parallelität schnell zu bedienen.

Zweitens: **Multi-Datenbank-Realität**. Entwickler wollen SQLite für eine unkomplizierte lokale Einrichtung; im Produktivbetrieb wird PostgreSQL mit seiner Parallelität und Ausfallsicherheit bevorzugt. Beide zu unterstützen – inklusive PLpgSQL-Optimierungen und einem Schema, das sich über mehrere versionierte Migrationen (V1 bis V4, mit inzwischen über neunzig Tabellen) weiterentwickelt hat – bedeutet, dass jedes Feature auf zwei sehr unterschiedlichen Engines korrekt funktionieren muss.

Drittens: **Echtzeit-Kollaboration mit Korrektheit**. Sobald mehrere Personen dasselbe Ticket bearbeiten, steht man vor dem klassischen Problem verteilter Zustände: verlorene Aktualisierungen und widersprüchliche Schreibvorgänge. Das ohne gegenseitige Blockaden zu lösen, erfordert ein durchdachtes Nebenläufigkeitsmodell – kein nachträglicher Gedanke.

## Was es zum Game-Changer macht

HelixTrack Core behandelt Berechtigungen als erstklassiges, austauschbares Modul. Es implementiert **kontextbasierte hierarchische Berechtigungen** mit Vererbung, und die Berechtigungslogik ist pluggbar – sie kann lokal im Service laufen oder an einen externen HTTP-Autorisierungsdienst delegiert werden. Diese Trennung ermöglicht es Unternehmen, den Tracker nahtlos in bestehende Identitäts- und Richtlinieninfrastrukturen einzubinden, statt gegen ein fest eingebautes Modell ankämpfen zu müssen.

Darüber hinaus bietet es etwas, das die meisten Tracker ignorieren: **automatische Diensterkennung**. Clients finden Core-Server im lokalen Netzwerk per UDP-Broadcast, sodass die plattformübergreifenden Clients (Web, Desktop, Android, iOS) ohne manuelle Konfiguration eine Verbindung herstellen können. Kombiniert mit JWT-Authentifizierung, einem Erweiterungssystem für Zeiterfassung, Dokumente und Chat sowie einer Git-Integration, die Commits mit Tickets verknüpft, verhält es sich wie eine Plattform – nicht wie eine einzelne Anwendung.

## Wie ich die härtesten Probleme gelöst habe

Für die API habe ich mich früh für das **Aktions-Routing-Muster** entschieden. Jede Operation durchläuft denselben `/do`-Lebenszyklus – Authentifizierungs- und Berechtigungs-Middleware, gefolgt von einem Handler, der über den Aktionsnamen gesteuert wird. Deshalb kann das System neue Funktionen hinzufügen (Phase 1: Prioritäten und Resolutionen, Phase 2: Epics und Arbeitsprotokolle, Phase 3: Abstimmungen und Benachrichtigungsschemata, Phase 4: paralleles Bearbeiten), ohne dass die API fragmentiert. Neue Features registrieren neue Aktionen; Transport und Middleware bleiben unverändert.

Für die gleichzeitige Bearbeitung habe ich **optimistisches Locking mit Versionskonflikten** plus eine vollständige Änderungsverlaufsschicht implementiert. Jede bearbeitbare Entität trägt eine Versionsnummer; ein Schreibvorgang, der auf eine veraltete Version abzielt, wird mit einem Konflikt abgelehnt, den der Client auflösen kann. Verlaufstabellen (hinzugefügt im V4-Schema) zeichnen die gesamte Historie der Änderungen auf. Ich habe explizites Sperren von Entitäten und Konfliktlösungsaktionen darübergelegt und das Ganze in die bestehende WebSocket-Schicht integriert, sodass Mitarbeiter Live-Updates sehen. Das ermöglicht Echtzeit-Kollaboration, ohne dass Bearbeitungen anderer stillschweigend überschrieben werden.

Um den Zielkonflikt zwischen Verschlüsselung und Geschwindigkeit zu lösen, setzt das Design auf SQLCipher für transparente AES-256-Verschlüsselung auf Speicherebene, während häufig genutzte Pfade durch Caching beschleunigt werden. So bleiben gängige Leseoperationen auch mit einer verschlüsselten Datenbank schnell. Der Code wird durch eine umfangreiche automatisierte Testsuite gestützt – weit über tausend Tests in allen Phasen –, die es mir ermöglicht, Änderungen an einem Schema mit über neunzig Tabellen, einer verschlüsselten, multi-datenbankfähigen und nebenläufig bearbeiteten Umgebung vorzunehmen und trotzdem darauf zu vertrauen, dass das Verhalten stabil bleibt. Architekturdiagramme, ein Benutzerhandbuch und eine Bereitstellungsanleitung werden mit dem Code ausgeliefert, denn eine JIRA-Alternative, die niemand bedienen kann, ist keine Alternative.
