---
title: ShareConnect
slug: share-connect
repo: https://github.com/vasic-digital/ShareConnect
tech: Kotlin
teaser: "Share any media link from your phone straight to your own download stack — 20 production-ready apps, eight things kept in sync across all of them."
---

## Der Haken

Du findest ein Video, einen Torrent, eine Datei, die es wert ist, behalten zu werden – auf deinem Handy, im Browser, in einem Chat. Doch dann kommt die Reibung: Link kopieren, Gerät wechseln, den richtigen Client finden, einfügen, konfigurieren, hoffen. ShareConnect macht das überflüssig. Es integriert sich in das native Android-Teilen-Menü, sodass jeder herunterladbare Link direkt in *deine* Infrastruktur gelangt – MeTube, YT-DLP, qBittorrent, Transmission, jDownloader und mehr – und verbindet Inhaltsentdeckung nahtlos mit deinen eigenen Download-Diensten. Der Name ist Programm: **Share** trifft auf **Connect**.

## Warum es fasziniert

ShareConnect ist keine einzelne App; es ist ein Ökosystem aus 20 produktionsreifen Android-Anwendungen, das in einem durchdachten Dreiphasen-Plan aufgebaut wurde. Phase eins bildet den Kern: der Haupt-ShareConnector sowie dedizierte Clients für qBittorrent, Transmission und uTorrent. Phase zwei fügt acht Cloud-Dienste hinzu – JDownloader (über die MyJDownloader-API), MeTube, YT-DLP (mit Unterstützung für über 1800 Streaming-Seiten), Nextcloud, FileBrowser, Plex, Jellyfin und Emby. Phase drei rundet das Ganze mit acht spezialisierten Diensten ab, darunter Seafile, Syncthing, Matrix, Paperless-NG, Duplicati, WireGuard, ein Minecraft-Server-Controller und OnlyOffice.

Das wirklich spannende Engineering steckt jedoch im Synchronisationsgeflecht darunter. ShareConnect hält acht verschiedene Elemente über alle Apps des Ökosystems hinweg synchron: Design, Profile, Verlauf, RSS-Feeds, Lesezeichen, Einstellungen, Sprache und den Status der Torrent-Freigabe. So ist dein Design in der Haupt-App auch dein Design in qBitConnect; dein Download-Verlauf begleitet dich; deine Profile sind überall konsistent. Zwanzig Apps, die sich wie ein einziges Produkt anfühlen.

## Die schwierigen Probleme

Das erste große Problem ist die schiere Vielfalt der Integrationen. Jeder Backend-Dienst – qBittorrent, Transmission, jDownloader, Plex, Jellyfin, Nextcloud, Matrix, Syncthing – hat seine eigene API, sein Authentifizierungsmodell und seine Eigenheiten. Zwanzig Clients zu entwickeln, die jeweils das Protokoll ihres Zielsystems korrekt beherrschen und gleichzeitig genug gemeinsame Struktur teilen, um wartbar zu bleiben, ist ebenso eine Frage der Disziplin wie des Programmierens.

Das zweite Problem ist die plattformübergreifende Synchronisation selbst. Acht Kategorien von Zuständen über viele separat installierte Android-Apps hinweg zu synchronisieren, bedeutet, echte Fragen verteilter Systeme auf einem einzigen Gerät und darüber hinaus zu lösen: Wie finden unabhängige Apps zueinander, einigen sich auf einen gemeinsamen Zustand und gleichen Änderungen ab, ohne sich gegenseitig in die Quere zu kommen? Design, Profile, Verlauf, RSS, Lesezeichen, Einstellungen, Sprache und Torrent-Freigabe haben jeweils unterschiedliche Aktualisierungsmuster und Konfliktlogiken.

Das dritte Problem ist der Nachweis, dass alles funktioniert. Bei zwanzig Apps und einer gemeinsamen Synchronisationsebene ist die Testoberfläche enorm – und das Projekt weicht nicht zurück: Es erreicht 100 % bei Unit-, Instrumentierungs- und Automatisierungstests, durchläuft zusätzlich eine KI-gestützte QA-Prüfung und weist ein A+-Rating bei SonarQube auf, keine kritischen Snyk-Schwachstellen, etwa 95 % Testabdeckung und ein technisches Schuldenverhältnis von 0,2 %. Diese Messlatte über ein ganzes Ökosystem hinweg zu halten, ist der schwierige Teil, den die meisten Projekte stillschweigend auslassen.

## Was es zum Game-Changer macht

Der Game-Changer ist selbstgehosteter Komfort ohne Kompromisse. Kommerzielle „Sende-an-meine-Geräte"-Funktionen binden dich an die Cloud eines anderen. ShareConnect richtet denselben Ein-Klick-Komfort auf Infrastruktur aus, *die dir gehört* – dein Torrent-Client, dein Mediaserver, deine Nextcloud – und lässt es auf Android wie eine native Funktion wirken. Es verwandelt eine verstreute Sammlung selbstgehosteter Dienste in eine einzige, kohärente, teilbare Oberfläche.

Und weil die Synchronisationsebene das verbindende Gewebe ist, skaliert das Ökosystem elegant: Ein Begleit-Client wie qBitConnect oder TransmissionConnect ist kein isoliertes Silo, sondern erbt automatisch das gemeinsame Design, die Profile und den Verlauf. Das gesamte System basiert auf einem modernen Android-Stack – Kotlin 2.0, Java 17, Android API 26+ – und ist damit kein Proof of Concept, sondern zwanzig als produktionsreif gekennzeichnete Apps.

## Wie ich die schwierigsten Teile gelöst habe

Ich habe das Synchronisationsgeflecht als Kern des Produkts behandelt, nicht als Feature. Statt die Synchronisation in jede App nachzurüsten, habe ich sie als dedizierte, gemeinsame Synchronisationsmodule aufgebaut – ThemeSync, ProfileSync, HistorySync, RSSSync, BookmarkSync, PreferencesSync, LanguageSync und TorrentSharingSync –, in die sich jede Anwendung des Ökosystems einhängt. Diese Entscheidung ist der Grund, warum ein neuer Client Konsistenz „umsonst" erhält: Er übernimmt die Module, statt sie neu zu erfinden.

Für die Vielzahl der Integrationen setzte ich auf ein Connector-Muster: Jeder Backend-Dienst (qBittorrent, Transmission, MeTube, YT-DLP, JDownloader, Plex und die anderen) ist ein in sich geschlossenes Connector-Modul hinter einem gemeinsamen Vertrag, wodurch zwanzig Clients individuell korrekt bleiben und gleichzeitig kollektiv wartbar sind. Die schrittweise Einführung – erst die Kern-Clients, dann die Cloud-Dienste, schließlich die spezialisierten – ließ jede Ebene stabil werden, bevor die nächste darauf aufbaute.

Zuletzt weigerte ich mich, die Qualität mit wachsender Komplexität zu opfern. Die zu 100 % bestandenen Unit-, Instrumentierungs- und Automatisierungstests sowie die KI-gestützte QA-Phase sind keine Eitelkeitsmetriken; sie sind die einzige Möglichkeit, ein Ökosystem aus zwanzig Apps mit gemeinsamer Synchronisationsebene vor dem Kollaps unter seinem eigenen Regressionsgewicht zu bewahren. Eine Testabdeckung von etwa 95 % und ein technisches Schuldenverhältnis von 0,2 % über das gesamte Projekt hinweg zu halten, ist es, was es dem Projekt ermöglicht, jede dieser zwanzig Apps glaubwürdig als produktionsreif zu bezeichnen.
