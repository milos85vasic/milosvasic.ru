---
title: Catalogizer
slug: catalogizer
repo: https://github.com/vasic-digital/Catalogizer
tech: Go, Gin, React, TypeScript, SQLCipher, WebSocket, SMB/FTP/NFS/WebDAV
teaser: "Point it at your SMB, FTP, NFS, WebDAV and local shares — it auto-detects 50+ media types, survives disconnects, and stays encrypted."
---

## Der Haken

Ihre Medien sind überall verfügbar — ein SMB-Share auf dem NAS, ein FTP-Box, ein NFS-Mount, ein WebDAV-Server, ein lokales Laufwerk — und nichts versteht all dies gleichzeitig. Catalogizer schon. Es ist ein fortschrittliches, multi-protokollfähiges Medien-Verwaltungssystem, das automatisch Medien über alle diese Protokolle hinweg erkennt, kategorisiert und organisiert, sie in Echtzeit überwacht, alles mit externen Metadaten anreichert und den gesamten Katalog in einer verschlüsselten Datenbank speichert.

## Warum es faszinierend ist

Catalogizer behandelt "Ihre Sammlung" als eine einzelne logische Bibliothek, die über heterogene Speicher verstreut ist. Es erkennt **50+ Medientypen** — Filme, TV-Sendungen, Musik, Spiele, Software, Dokumentationen und mehr — und überwacht jede Quelle kontinuierlich auf Änderungen, aktualisiert Metadaten automatisch. Es bereichert Einträge aus einer breiten Palette externer Anbieter (TMDB, IMDB, TVDB, MusicBrainz, Spotify, Steam und andere), analysiert die Qualität, verfolgt Versionen und zeigt Analysen wie Wachstumstrends an.

Der Stack ist ein sauberer Split: eine hochleistungsfähige Go-REST-API auf Gin, eine moderne React/TypeScript-Oberfläche mit Tailwind und WebSocket-Integration, so dass die Benutzeroberfläche live aktualisiert wird, wenn der Katalog geändert wird. Darunter liegt die Datenbank in einem **SQLCipher-verschlüsselten** Speicher. Es geht sogar über die Katalogisierung hinaus mit praktischen Extras — einem PDF-Konvertierungsdienst, Favoriten-Export/Import im JSON- und CSV-Format, Cloud-Synchronisation mit S3 und Google Cloud Storage und professionellen PDF-Berichten mit Diagrammen.

## Die harten Probleme

Das härteste Problem ist **unzuverlässiger Netzwerkspeicher**. SMB und Freunde fallen aus. Mounts verschwinden. Ein naiver Katalogisierer wirft Fehler aus und verdirbt seine Sicht der Welt, sobald ein Share offline geht. Catalogizer ist für **Protokollresilienz** konzipiert: es behandelt vorübergehende Verbindungsabbrüche elegant, verbindet sich automatisch wieder und cacht für den Offline-Betrieb, so dass ein fluktuierender NAS das gesamte System nicht aus dem Gleichgewicht bringt. Die Konzeption für den Fehlerfall als Normalfall — und nicht als Ausnahme — ist die bestimmende Ingenieursentscheidung hier.

Das zweite Problem ist **eine einzige Abstraktion über sehr unterschiedliche Protokolle**. SMB, FTP, NFS, WebDAV und das lokale Dateisystem haben jeweils ihre eigenen Semantiken, Eigenheiten und Fehlermodi. Die Darstellung durch eine konsistente Dateisystem-Client-Schnittstelle — einschließlich vollständiger NFS-Mounting und Dateioperationen auf macOS —, so dass die Erkennungsmaschine und der Monitor sie einheitlich behandeln können, ist ein erheblicher Integrationsaufwand.

Das dritte ist **Erkennung im großen Maßstab mit Sicherheit**. Die zuverlässige Erkennung von 50+ Medientypen, die Anreicherung mit externen APIs und die Durchführung all dessen über eine verschlüsselte Datenbank mit JWT-basierter Rollenzugriff — ohne dass die Verschlüsselung oder die API-Aufrufe zu einem Flaschenhals werden — erfordert eine bewusste Architektur.

## Was es zum Spieländerer macht

Die meisten Medien-Manager gehen davon aus, dass Ihre Dateien lokal sind und Ihr Netzwerk perfekt ist. Catalogizer geht davon aus, dass das Gegenteil der Fall ist, und funktioniert dennoch. Die Kombination aus **multi-protokollfähiger Reichweite plus Resilienz plus Echtzeit-Überwachung** bedeutet, dass es eine verteilte, teilweise verfügbare Sammlung wie eine einzelne, ordentliche Bibliothek verwaltet — und sie automatisch auf dem neuesten Stand hält, anstatt eine manuelle Neuerfassung durchzuführen.

Wenn man Verschlüsselung standardmäßig, rollenbasierten Zugriff, externe Metadaten-Anreicherung und wirklich nützliche Ausgabe-Features (Berichte, Exporte, Cloud-Synchronisation, PDF-Konvertierung) hinzufügt, hört es auf, ein Katalog zu sein, und wird zu einer Verwaltungsplattform für ein Medien-Vermögen, das zufällig über Protokolle und Maschinen verstreut ist.

## Wie ich die härtesten Teile gelöst habe

Ich habe **Resilienz als Eigenschaft der Speicherschicht** konzipiert, und nicht als etwas, das jede Funktion selbst handhaben muss. Die multi-protokollfähigen Dateisystem-Clients sind für die Erkennung von Verbindungsabbrüchen, die automatische Neuverbindung und die Bedienung aus einem Offline-Cache verantwortlich, wenn eine Quelle nicht verfügbar ist. Da dieses Verhalten in der Client-Abstraktion lebt, kann die Überwachungsmaschine und die Erkennungsmaschine darüber hinaus annehmen, dass eine Quelle immer erreichbar ist — die unsaubere Realität eines abgebrochenen SMB-Mounts wird unter ihnen absorbiert.

Um die Protokollvielfalt zu bändigen, habe ich SMB, FTP, NFS, WebDAV und lokalen Zugriff hinter einer **Dateisystem-Client-Schnittstelle** mit pro-protokollspezifischer Überwachung vereinigt, einschließlich echter NFS-Mounting und Dateioperationen für macOS. Die Medien-Erkennungsmaschine sitzt auf dieser einzigen Schnittstelle, so dass das Hinzufügen eines Protokolls oder die Korrektur der Eigenheiten eines Protokolls nicht in die Erkennungslogik einfließt.

Für das Live-Verhalten läuft die Go-API einen **WebSocket-Server**, der Updates an die React-Oberfläche pusht, sobald der Katalog geändert wird, so dass das, was die Benutzer sehen, die überwachten Quellen in Echtzeit widerspiegelt, anstatt ein veraltetes Snapshot. Und ich habe Sicherheit nicht optional gemacht: die Datenbank ist SQLCipher-verschlüsselt und die API ist durch JWT mit rollenbasierter Zugriffskontrolle gesichert, so dass ein System, das in viele Remote-Shares und externe APIs hineinreicht, nicht zum schwächsten Glied wird. Das Ergebnis ist ein Medien-Manager, der für die Welt konzipiert ist, wie sie tatsächlich ist — verteilt, intermittierend und bedürftig, ehrlich und sicher gehalten zu werden.
