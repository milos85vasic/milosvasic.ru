---
title: Panoptic
slug: panoptic
repo: https://github.com/vasic-digital/Panoptic
tech: Go
teaser: "One Go framework that drives, screenshots, and screen-records web, desktop, iOS and Android — the all-seeing eye for UI automation."
---

## Der Haken

UI-Automatisierung ist zersplittert. Man lernt Selenium oder Playwright fürs Web, Appium und XCUITest für Mobile, etwas völlig anderes für Desktop – und ein separates Aufzeichnungstool, wenn man ein Video des Geschehens braucht. Jede Plattformgrenze bedeutet ein neues Werkzeug, eine neue Abstraktion, eine neue Quelle für Instabilität. Panoptic – benannt nach dem allsehenden Auge – bündelt diesen ganzen Zoo in ein einziges Go-Framework, das Automatisierung, Screenshots und Sitzungsaufzeichnungen über Web, Desktop und Mobile hinweg mit einem einzigen Programmiermodell ermöglicht.

## Warum es fasziniert

Was Panoptic so überzeugend macht, ist die Tatsache, dass es „Beobachten, was die Software tut" als gleichwertige Kernfunktion neben „Steuern der Software" behandelt. Es klickt nicht nur Buttons an, sondern erfasst hochwertige, zeitgestempelte Screenshots und zeichnet vollständige Sitzungsvideos in mehreren Formaten auf. Das bedeutet, dass ein einziger Testlauf sowohl die Assertions als auch die visuellen Beweise liefert – die Aufzeichnung ist kein nachträglicher Zusatz, sondern fester Bestandteil des Frameworks.

Es ist wirklich plattformübergreifend. Web-Automatisierung umfasst Chrome, Firefox, Safari und Edge. Mobile deckt sowohl iOS- als auch Android-App-Automatisierung mit Bildschirmaufzeichnung ab. Desktop erhält UI-Automatisierung und Bildschirmaufnahme. Und das alles wird über eine saubere Go-API bereitgestellt – `web.NewBrowser()`, `browser.Navigate(...)`, `browser.Screenshot(...)`, benutzerdefinierte CSS- und XPath-Selektoren, explizite Warte-Strategien – plus eine CLI für gängige Anwendungsfälle (`panoptic record --platform ios --device iPhone13 --output mobile_demo.mp4`). Dass dieselbe konzeptionelle API von einem headless Chrome-Viewport bis zu einer aufgezeichneten iPhone-Sitzung reicht, ist der springende Punkt.

## Die schwierigen Probleme

Das erste schwierige Problem ist, dass „ein Element" auf jeder Plattform etwas anderes bedeutet. Ein Web-Button ist ein DOM-Knoten, der über CSS oder XPath erreichbar ist. Ein iOS-Steuerelement existiert im Accessibility-Baum. Ein Desktop-Widget ist ein natives OS-Handle. Panoptic muss ein einheitliches Modell für Elementerkennung und -interaktion bieten, während es im Hintergrund vier völlig unterschiedliche „Dialekte" von „Finde dieses Ding und tippe darauf" spricht.

Das zweite Problem ist das Timing. UI ist überall asynchron, aber überall auf andere Weise. Panoptic liefert explizite Warte-Strategien – `WaitForElement` mit Timeout und `WaitForCondition`, das ein beliebiges Prädikat so lange abfragt, bis es wahr wird – denn feste Wartezeiten sind die Hauptursache für instabile Automatisierung. Wartemechanismen zu entwerfen, die sich identisch verhalten, egal ob sie auf das Verschwinden eines `div.loading` oder das Rendern einer nativen Ansicht warten, ist eine anspruchsvolle Aufgabe.

Das dritte Problem ist die Aufzeichnung während der Steuerung. Hochwertiges Video mit 30 fps aufzunehmen, mit konfigurierbarem Viewport und ohne die Timing-Eigenschaften der aufgezeichneten Automatisierung zu beeinflussen, ist eine echte Herausforderung in Sachen Performance und Synchronisation – besonders auf Mobile, wo man den Bildschirm eines Geräts oder Simulators aufzeichnet, nicht nur eine selbst kontrollierte Leinwand.

## Was es zum Game-Changer macht

Der Game-Changer ist die Konsolidierung mit Beweismaterial. Wenn Automatisierung in einem einzigen Framework über alle Plattformen hinweg läuft, entwickelt ein Team ein einziges mentales Modell statt vier – und erhält visuelle Beweise gratis dazu. Ein instabiler Test ist nicht mehr nur ein Stacktrace, den man sich anschaut, sondern ein Video, das man sich ansieht. Allein das verändert, wie Teams Fehler analysieren.

Es ist auch dafür gemacht, nahtlos in Pipelines integriert zu werden: eine erweiterbare Plugin-Architektur, Before/After-Hooks für Setup und Teardown, eine YAML-Konfiguration für Browser, Aufzeichnung und plattformspezifische Mobile-Einstellungen sowie explizite CI/CD-Integration. Man kann dieselbe Testsuite in der CI ausführen, die man lokal genutzt hat, und die Artefakte – Screenshots und MP4s – sind genau das, was man an einen fehlgeschlagenen Build anhängen möchte.

## Wie ich die schwierigsten Teile gelöst habe

Ich habe Go bewusst gewählt. Plattformübergreifende Automatisierung besteht unter der Haube aus einer Menge nebenläufiger I/O – Kommunikation mit Browser-Treibern, Geräte-Brücken (ADB für Android, Xcode-Tooling für iOS) und einem Encoder für die Aufzeichnung – alles gleichzeitig. Go-Routinen und -Channels machen es machbar und schnell, „die UI auf dieser Goroutine zu steuern, Bildschirmframes auf jener zu verarbeiten und auf einer dritten auf eine Wartebedingung zu achten". Und die statische Binärdatei macht die CLI trivial in CI-Umgebungen einsetzbar.

Um vier Elementmodelle zu vereinen, habe ich Plattformtreiber eine gemeinsame Interaktionsschnittstelle implementieren lassen und die Selektoren ausdrucksstark statt nach dem kleinsten gemeinsamen Nenner gestaltet – CSS und XPath im Web, native Locators auf Mobile und Desktop – sodass die Abstraktion nie den präzisen Selektor kostet, den man tatsächlich braucht. Die Warteprimitive sind auf dieser Schnittstelle aufgebaut, weshalb `WaitForCondition` unabhängig davon funktioniert, welche Plattform das Prädikat gerade prüft.

Für die Aufzeichnung ohne Verzerrungen habe ich die Erfassung als separate Pipeline behandelt, die unabhängig konfiguriert wird (Format, Qualität, fps in `panoptic.yaml`), sodass der Recorder parallel zur Automatisierung läuft, statt in deren kritischem Pfad. Und von Anfang an habe ich das Ganze mit Hooks und einem Plugin-System erweiterbar gestaltet, denn die eine Gewissheit in der Automatisierung ist, dass jemand etwas brauchen wird, das ich nicht vorhergesehen habe – und das Framework sollte es ermöglichen, statt einen Fork zu erzwingen.
