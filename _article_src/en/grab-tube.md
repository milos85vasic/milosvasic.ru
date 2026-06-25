---
title: GrabTube
slug: grab-tube
repo: https://github.com/vasic-digital/GrabTube
tech: Dart/Flutter
teaser: "One yt-dlp backend, five native clients — download from 1000+ sites on web, Android, iOS, Windows, macOS and Linux, even by scanning a QR code."
---

## The hook

`yt-dlp` is the most capable video downloader on earth, and it's a command line. For most people that's a wall. GrabTube tears the wall down: it wraps that backend in a polished, multi-platform app so anyone can download from YouTube and over a thousand other sites with quality selection, format choice, and live progress — and on mobile, you can literally point your camera at a QR code and the download starts. It's a universal Tube-services downloader with modern UI/UX, front to back.

## Why it's fascinating

The architecture is the hook. GrabTube is one powerful backend feeding many clients. The original web GUI is Python (aiohttp) paired with Angular 19. Then there's a Flutter 3.24+ client written in Dart that ships *native* to Android, iOS, Windows, macOS, and Linux from a single codebase. Every client — web and Flutter alike — talks to the same yt-dlp engine. So the hard download logic lives in exactly one place, and the user-facing experience is whatever's most natural for the device in your hand.

The Flutter client is where it gets genuinely fun. It does background downloads with notifications, an offline queue, Material Design 3 with adaptive theming, native performance on every target, and QR-code scanning with camera integration so a link on a screen becomes a download in one motion. It carries a CI/CD pipeline and over 80% test coverage with AI validation — rare polish for a downloader. And it integrates with the ShareConnect ecosystem for universal link sharing and synchronized queues and history across devices.

## The hard problems

The first hard problem is that downloading from "1000+ sites" is inherently a moving target. Site layouts change, formats multiply, extraction breaks. GrabTube's answer is architectural humility: it doesn't reimplement extraction, it leans on yt-dlp and concentrates its own effort on everything *around* the download — queueing, progress, format negotiation, and presentation.

The second is true multi-platform from one Dart codebase. "Write once, run everywhere" is easy to say and brutal in the details: background execution and notifications work completely differently on Android, iOS, and each desktop OS; camera/QR access has per-platform permission models; file storage and download semantics diverge everywhere. Delivering native performance with a single Flutter codebase across five platforms means absorbing all of that beneath a clean UI.

The third is the backend contract. With multiple heterogeneous clients (an Angular web app and a Flutter app) hitting one aiohttp service, the API has to be the stable seam — real-time progress, queue state, and history have to stream cleanly to every client regardless of how that client renders them.

## What makes it game-changing

The game-changer is reach without rewrite. Most download tools pick a lane — a web UI, or a desktop app, or a mobile app. GrabTube refuses to choose: the same capability shows up as a web GUI, a native mobile app, and a native desktop app, all backed by the same engine. Add the QR-scan flow and cross-device sync via ShareConnect, and downloading stops being a device-bound chore and becomes something fluid that follows you from a laptop screen to the phone in your pocket.

It's also held to a standard most utilities never reach. A production-ready Flutter client with >80% test coverage, AI-assisted validation, and an automated CI/CD pipeline means GrabTube behaves like maintained software, not a weekend script that rots the next time a site changes.

## How I solved the hardest parts

The foundational decision was to make yt-dlp the single source of download truth and never fight it. By treating extraction as a solved problem owned by the backend, I freed every client to focus purely on experience — and made the project resilient, because when a site changes, the fix lives upstream, not scattered across five UIs.

For multi-platform, I committed to Flutter and Dart so one codebase could go native to Android, iOS, Windows, macOS, and Linux, then handled the genuinely platform-specific concerns — background downloads with notifications, the offline queue, camera-based QR scanning, adaptive Material Design 3 theming — as deliberate native integrations rather than pretending the platforms are the same. That's the difference between a Flutter app that *runs* everywhere and one that *feels* native everywhere.

I kept the aiohttp backend as a clean, client-agnostic API so the Angular web client and the Flutter client could evolve independently while sharing identical download behavior, real-time progress, and history. And I wired GrabTube into the ShareConnect ecosystem so a link shared on one device flows into a synchronized queue on another — turning a downloader into part of a connected, cross-device workflow. Finally, I held the Flutter client to >80% coverage with AI validation and a CI/CD pipeline, because a tool people rely on to grab their media should be tested like one.
