---
title: ShareConnect
slug: share-connect
repo: https://github.com/vasic-digital/ShareConnect
tech: Kotlin
teaser: "Share any media link from your phone straight to your own download stack — 20 production-ready apps, eight things kept in sync across all of them."
---

## The hook

You find a video, a torrent, a file worth keeping — on your phone, in a browser, in a chat. Then comes the friction: copy the link, switch devices, find the right client, paste, configure, hope. ShareConnect erases that. It hooks into Android's native share sheet so any downloadable URL goes straight to *your* infrastructure — MeTube, YT-DLP, qBittorrent, Transmission, jDownloader, and more — connecting content discovery to your own download services. The name is the thesis: **share** meets **connect**.

## Why it's fascinating

ShareConnect isn't one app; it's an ecosystem of 20 production-ready Android applications built out across a deliberate three-phase plan. Phase one is the core: the main ShareConnector plus dedicated clients for qBittorrent, Transmission, and uTorrent. Phase two adds eight cloud services — JDownloader (via the MyJDownloader API), MeTube, YT-DLP (supporting 1800+ streaming sites), Nextcloud, FileBrowser, Plex, Jellyfin, and Emby. Phase three rounds it out with eight specialized services including Seafile, Syncthing, Matrix, Paperless-NG, Duplicati, WireGuard, a Minecraft server controller, and OnlyOffice.

The truly interesting engineering, though, is the sync fabric underneath. ShareConnect keeps eight distinct things synchronized across every app in the ecosystem: theme, profiles, history, RSS feeds, bookmarks, preferences, language, and torrent-sharing state. So your theme on the main app is your theme on qBitConnect; your download history follows you; your profiles are consistent everywhere. Twenty apps that feel like one product.

## The hard problems

The first hard problem is the sheer breadth of integrations. Every backend — qBittorrent, Transmission, jDownloader, Plex, Jellyfin, Nextcloud, Matrix, Syncthing — has its own API, auth model, and quirks. Building 20 clients that each speak their target's protocol correctly, while sharing enough common scaffolding to stay maintainable, is a discipline problem as much as a coding one.

The second is the cross-app sync itself. Synchronizing eight categories of state across many separately-installed Android applications means solving real distributed-systems questions on a single device and beyond: how do independent apps discover each other, agree on shared state, and reconcile changes without stepping on one another? Theme, profiles, history, RSS, bookmarks, preferences, language, and torrent-sharing each have different update patterns and conflict semantics.

The third is proving it all works. With 20 apps and a shared sync layer, the test surface is enormous — and the project doesn't flinch: it reports 100% on unit, instrumentation, and automation test suites, plus an AI-driven QA pass, alongside an A+ SonarQube grade, no critical Snyk vulnerabilities, ~95% code coverage, and a technical-debt ratio of 0.2%. Maintaining that bar across an entire ecosystem is the hard part most projects quietly skip.

## What makes it game-changing

The game-changer is self-hosted convenience without compromise. Commercial "send to my devices" features lock you into someone else's cloud. ShareConnect points the same one-tap convenience at infrastructure *you* own — your torrent client, your media server, your Nextcloud — and makes it feel native on Android. It turns a scattered collection of self-hosted services into a single, coherent, shareable surface.

And because the sync layer is the connective tissue, the ecosystem scales gracefully: a companion client like qBitConnect or TransmissionConnect isn't a silo, it inherits the shared theme, profiles, and history automatically. The whole thing is built on a modern Android stack — Kotlin 2.0, Java 17, Android API 26+ — so it's not a proof of concept; it's 20 apps marked production-ready.

## How I solved the hardest parts

I treated the sync fabric as the product's core, not a feature. Rather than bolt synchronization onto each app, I built it as dedicated, shared sync modules — ThemeSync, ProfileSync, HistorySync, RSSSync, BookmarkSync, PreferencesSync, LanguageSync, and TorrentSharingSync — that every application in the ecosystem plugs into. That decision is why a new client gets consistency "for free": it adopts the modules instead of reinventing them.

For the integration sprawl, I used a connector pattern: each backend (qBittorrent, Transmission, MeTube, YT-DLP, JDownloader, Plex, and the rest) is a self-contained connector module behind a common contract, which is how 20 clients stay individually correct yet collectively maintainable. Phasing the rollout — core clients, then cloud services, then specialized ones — let each layer stabilize before the next built on it.

Finally, I refused to let quality erode as the surface grew. The 100%-passing unit, instrumentation, and automation suites plus an AI QA stage aren't vanity badges; they're the only way to keep a 20-app ecosystem with a shared sync layer from collapsing under its own regression weight. Holding ~95% coverage and a 0.2% technical-debt ratio across all of it is what let the project credibly call every one of those 20 apps production-ready.
