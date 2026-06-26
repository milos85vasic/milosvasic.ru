---
title: HelixCode
slug: helix-code
repo: https://github.com/HelixDevelopment/HelixCode
tech: Go, PostgreSQL, Redis, SSH, MCP, WebSocket, Gin
teaser: "A distributed AI coding agent that splits work across an SSH worker network, checkpoints everything, and never loses progress on a crash."
---

## Der Haken

Was wäre, wenn dein KI-Coding-Agent nicht auf einem einzigen Rechner laufen würde, sondern über ein Netzwerk von Arbeitsknoten, die er selbst bereitstellt – große Aufgaben in Teile zerlegt, sie verteilt und unterwegs Checkpoints setzt, sodass ein Absturz nie Arbeit verliert? Das ist HelixCode: eine unternehmensreife, verteilte KI-Entwicklungsplattform in Go, mit SSH-basierten Worker-Pools, automatischer Checkpoint-Erstellung, Rollback-Funktion und Integration mehrerer LLM-Anbieter.

## Warum es fasziniert

Die meisten „KI-Coding-Agenten" sind ein einzelner Prozess, der mit einem einzigen Modell kommuniziert. HelixCode hingegen basiert auf der Idee, dass echte Entwicklungsarbeit teilbar und verteilbar ist. Es führt **intelligente Aufgabenaufteilung** mit Abhängigkeitsmanagement durch und sichert Fortschritte durch automatische Checkpoints, sodass langlaufende Jobs Unterbrechungen überstehen. Die Plattform bietet vier Client-Schnittstellen – REST-API, CLI, ein Terminal-UI und WebSocket – und implementiert das **Model Context Protocol (MCP)** mit Multi-Transport-Unterstützung, sodass sie sich nahtlos in das Ökosystem der Agenten-Tools einfügt.

HelixCode ist zudem in einem ungewöhnlich breiten Sinne plattformübergreifend: Linux, macOS, Windows sowie Aurora OS und SymphonyOS, mit Frameworks für iOS und Android in Vorbereitung. Das Repository besteht im Kern aus Go, umgeben von Shell, Kotlin, Swift und Web-Assets – die Architektur einer Plattform, die von überall gesteuert werden kann.

## Die schwierigen Probleme

Die zentrale Herausforderung lautet: **Verteilung ohne Brüchigkeit**. Sobald man eine Coding-Aufgabe auf entfernte Worker verteilt, übernimmt man alle harten Probleme verteilter Systeme: Wie teilt man Arbeit entlang echter Abhängigkeitsgrenzen auf? Wie verfolgt man, welcher Worker welchen Teil bearbeitet? Wie stellt man sicher, dass ein Worker, der mitten in der Aufgabe verschwindet, keine Daten verliert? Und wie führt man Ergebnisse kohärent zusammen?

Das Worker-Management ist ein eigenes Problem. HelixCode geht nicht von einem vorgefertigten Cluster aus – es bietet einen **SSH-Worker-Pool mit automatischer Installation**, was bedeutet, dass es einen Remote-Host erreichen, sich dort einrichten, den Worker registrieren und dessen Zustand überwachen muss – alles sicher über SSH. Diese Bootstrap-Phase zuverlässig auf heterogenen Maschinen umzusetzen, ist weitaus schwieriger, als es klingt.

Dann gibt es noch die LLM-Ebene. Die Unterstützung mehrerer Anbieter hinter einer einheitlichen Schnittstelle, die Hardware-Erkennung (CPU/GPU/Speicher), um Modelle intelligent auszuwählen, und die Implementierung fortschrittlicher Reasoning-Methoden – Chain-of-Thought und Tree-of-Thoughts – bedeuten, dass der Agent nicht nur *was* generiert wird, sondern auch *wo* und *womit* es ausgeführt wird, berücksichtigen muss.

## Was es zum Game-Changer macht

Die Kombination aus **Arbeitserhaltung und Rollback** ist der entscheidende Unterschied. Ein KI-Agent, der genau dort weitermachen kann, wo er aufgehört hat, und schlechte Änderungen rückgängig machen kann, verwandelt lange autonome Durchläufe von einem Glücksspiel in etwas Handhabbares. HelixCode verbindet dies mit vollständigen Entwicklungsworkflows – Planung, Bau, Testen und Refactoring –, gestützt auf datenbankgespeicherte Projekte und Multi-Session-Kontextverfolgung. Es geht nicht nur um „Code generieren", sondern um einen vollständigen Lebenszyklus.

Die MCP-Implementierung ist ebenfalls wichtig. Durch die Unterstützung des Model Context Protocol mit mehreren Transportwegen kann HelixCode sowohl als Verbraucher als auch als Teilnehmer im Agenten-Tooling-Ökosystem agieren. Dank der Multi-Channel-Benachrichtigungen (Slack, Discord, E-Mail, Telegram) kann ein verteilter Durchlauf Fortschritte dorthin melden, wo Menschen tatsächlich zuschauen.

## Wie ich die schwierigsten Teile gelöst habe

Ich habe das System in klare interne Module unterteilt – Authentifizierung und Sitzungsverwaltung, Worker-Pool-Management, Aufgabenverwaltung und Checkpointing, Projekt- und Workflow-Management sowie LLM-Anbieter-Integration –, die jeweils in eigenen Paketen untergebracht sind. Diese Trennung macht das verteilte Verhalten handhabbar: Aufgabenaufteilung und Checkpointing sind Aspekte, die ich unabhängig vom verwendeten LLM-Anbieter oder Transportweg betrachten kann.

Für das Worker-Netzwerk habe ich den **SSH-Worker-Pool mit Selbstinstallation** entwickelt. Statt von Betreibern zu verlangen, jeden Knoten vorab einzurichten, verbindet sich die Plattform per SSH, installiert die benötigten Komponenten, registriert den Worker und überwacht kontinuierlich dessen Zustand. Die Zustandsüberwachung fließt zurück in die Aufgabenverwaltung, sodass Arbeit neu zugewiesen werden kann, wenn ein Knoten ausfällt.

Für die Ausfallsicherheit ist das **Checkpointing das Rückgrat**. Die Aufgabenverwaltung schreibt während der Arbeit Checkpoints, sodass ein unterbrochener Job nicht von vorne beginnt, sondern vom letzten stabilen Zustand aus fortfährt. Schlechte Schritte können per Rollback rückgängig gemacht werden. Dieser Mechanismus macht lange, verteilte, autonome Durchläufe erst sicher durchführbar.

Für die Modellebene habe ich jeden Anbieter hinter einer **einheitlichen Anbieter-Schnittstelle** versteckt und Hardware-Erkennung integriert, damit der Agent das Modell passend zur verfügbaren Maschine auswählt. Über dieser Schnittstelle habe ich Tool-Calling und die Chain-of-Thought-/Tree-of-Thoughts-Reasoning-Methoden implementiert, sodass Verbesserungen der Reasoning-Strategie keine Änderungen an der Anbieter-Infrastruktur erfordern. Die Persistenzschicht basiert auf PostgreSQL mit optionalem Redis, was Projekte, Sitzungen und Workflow-Zustände über die gesamte verteilte Infrastruktur hinweg dauerhaft speichert – der Unterschied zwischen einer cleveren Demo und einer Plattform, die man tatsächlich nutzen kann.
