---
title: GrabTube
slug: grab-tube
repo: https://github.com/vasic-digital/GrabTube
tech: Dart/Flutter
teaser: "One yt-dlp backend, five native clients — download from 1000+ sites on web, Android, iOS, Windows, macOS and Linux, even by scanning a QR code."
---

## Der Haken

`yt-dlp` ist der leistungsfähigste Video-Downloader der Welt und er läuft in der Kommandozeile. Für die meisten Menschen ist das ein Hindernis. GrabTube reißt diese Barriere nieder: Es hüllt den Backend-Code in eine polierte, plattformübergreifende App, so dass jeder von YouTube und über tausend anderen Seiten herunterladen kann, mit Qualitätsauswahl, Formatchoice und Live-Fortschritt – und auf mobilen Geräten kann man sogar mit der Kamera auf einen QR-Code zeigen und der Download beginnt. Es ist ein universeller Tube-Downloader mit modernem UI/UX, von vorne bis hinten.

## Warum es faszinierend ist

Die Architektur ist der Haken. GrabTube ist ein leistungsfähiger Backend-Code, der viele Clients bedient. Die ursprüngliche Web-Oberfläche ist Python (aiohttp) mit Angular 19. Dann gibt es einen Flutter-3.24+-Client, der in Dart geschrieben ist und *nativ* auf Android, iOS, Windows, macOS und Linux läuft, aus einer einzigen Codebasis. Jeder Client – Web und Flutter – spricht mit dem gleichen yt-dlp-Engine. So lebt die schwierige Download-Logik an genau einer Stelle, und die Benutzeroberfläche ist das, was für das Gerät in der Hand am natürlichsten ist.

Der Flutter-Client ist der Teil, der wirklich Spaß macht. Er ermöglicht Hintergrund-Downloads mit Benachrichtigungen, eine Offline-Warteschlange, Material Design 3 mit adaptiver Thematisierung, native Leistung auf jedem Zielgerät und QR-Code-Scanning mit Kamera-Integration, so dass ein Link auf einem Bildschirm zu einem Download in einer Bewegung wird. Er verfügt über eine CI/CD-Pipeline und über 80% Testabdeckung mit AI-Validierung – eine seltene Feinabstimmung für einen Downloader. Und er integriert sich in das ShareConnect-Ökosystem für universelle Link-Teilung und synchronisierte Warteschlangen und Historie über Geräte hinweg.

## Die harten Probleme

Das erste harte Problem ist, dass das Herunterladen von "über 1000 Seiten" ein sich bewegendes Ziel ist. Die Layouts der Seiten ändern sich, Formate vermehren sich, die Extraktion bricht zusammen. GrabTubes Antwort ist architektonische Bescheidenheit: Es implementiert die Extraktion nicht neu, sondern stützt sich auf yt-dlp und konzentriert sich auf alles *um* den Download herum – Warteschlangen, Fortschritt, Formatauswahl und Präsentation.

Das zweite ist die wahre Multi-Plattform-Fähigkeit aus einer einzigen Dart-Codebasis. "Schreibe einmal, laufe überall" ist leicht zu sagen und brutal in den Details: Hintergrund-Ausführung und Benachrichtigungen funktionieren völlig anders auf Android, iOS und jedem Desktop-Betriebssystem; Kamera/QR-Zugriff hat plattformspezifische Berechtigungsmodelle; Dateispeicherung und Download-Semantik weichen überall ab. Die Lieferung von nativer Leistung mit einer einzigen Flutter-Codebasis über fünf Plattformen hinweg bedeutet, all dies unter einer sauberen Benutzeroberfläche zu absorbieren.

Das dritte ist der Backend-Vertrag. Mit mehreren heterogenen Clients (einer Angular-Web-App und einer Flutter-App), die einen aiohttp-Service ansprechen, muss die API die stabile Nahtstelle sein – Echtzeit-Fortschritt, Warteschlangen-Zustand und Historie müssen sauber an jeden Client streamen, unabhängig davon, wie dieser Client sie darstellt.

## Was es zum Spiel-Changer macht

Der Spiel-Changer ist die Reichweite ohne Neuschreiben. Die meisten Download-Tools wählen eine Spur – eine Web-Oberfläche, oder eine Desktop-App, oder eine Mobile-App. GrabTube weigert sich, zu wählen: Die gleiche Fähigkeit erscheint als Web-Oberfläche, native Mobile-App und native Desktop-App, alle von dem gleichen Engine unterstützt. Fügen Sie den QR-Scan-Fluss und die Geräte-übergreifende Synchronisierung über ShareConnect hinzu, und das Herunterladen hört auf, eine gerätegebundene Pflicht zu sein, und wird zu etwas Flüssigem, das Ihnen von einem Laptop-Bildschirm zum Telefon in Ihrer Tasche folgt.

Es hält auch einen Standard, den die meisten Utility-Tools nie erreichen. Ein produktionsreifer Flutter-Client mit >80% Testabdeckung, AI-gestützter Validierung und einer automatisierten CI/CD-Pipeline bedeutet, dass GrabTube wie gewartete Software und nicht wie ein Wochenend-Script funktioniert, das beim nächsten Seiten-Wechsel verrottet.

## Wie ich die härtesten Teile gelöst habe

Die grundlegende Entscheidung war, yt-dlp zur einzigen Quelle der Download-Wahrheit zu machen und nie dagegen anzukämpfen. Indem ich die Extraktion als gelöstes Problem behandelte, das dem Backend gehört, befreite ich jeden Client, sich rein auf die Erfahrung zu konzentrieren – und machte das Projekt widerstandsfähig, weil wenn eine Seite sich ändert, die Korrektur upstream und nicht über fünf Benutzeroberflächen verstreut lebt.

Für die Multi-Plattform-Fähigkeit verpflichtete ich mich zu Flutter und Dart, so dass eine Codebasis nativ auf Android, iOS, Windows, macOS und Linux laufen konnte, und dann behandelte ich die wirklich plattformspezifischen Bedenken – Hintergrund-Downloads mit Benachrichtigungen, die Offline-Warteschlange, kamera-basiertes QR-Scanning, adaptives Material Design 3 – als bewusste native Integrationen und nicht als Vorwand, die Plattformen seien gleich. Das ist der Unterschied zwischen einer Flutter-App, die *läuft* überall, und einer, die *sich* überall nativ anfühlt.

Ich hielt den aiohttp-Backend-Code als saubere, client-agnostische API, so dass die Angular-Web-Client und der Flutter-Client unabhängig voneinander evolvieren konnten, während sie identisches Download-Verhalten, Echtzeit-Fortschritt und Historie teilten. Und ich verband GrabTube mit dem ShareConnect-Ökosystem, so dass ein Link, der auf einem Gerät geteilt wird, in eine synchronisierte Warteschlange auf einem anderen Gerät fließt – und aus einem Downloader einen Teil eines vernetzten, geräteübergreifenden Workflows machte. Schließlich hielt ich den Flutter-Client auf >80% Abdeckung mit AI-Validierung und einer CI/CD-Pipeline, weil ein Tool, auf das Menschen sich verlassen, um ihre Medien herunterzuladen, wie eines getestet werden sollte.
