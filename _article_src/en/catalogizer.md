---
title: Catalogizer
slug: catalogizer
repo: https://github.com/vasic-digital/Catalogizer
tech: Go, Gin, React, TypeScript, SQLCipher, WebSocket, SMB/FTP/NFS/WebDAV
teaser: "Point it at your SMB, FTP, NFS, WebDAV and local shares — it auto-detects 50+ media types, survives disconnects, and stays encrypted."
---

## The hook

Your media lives everywhere — an SMB share on the NAS, an FTP box, an NFS mount, a WebDAV server, a local drive — and nothing understands all of it at once. Catalogizer does. It is an advanced multi-protocol media collection management system that automatically detects, categorizes, and organizes media across every one of those protocols, monitors them in real time, enriches everything with external metadata, and keeps the whole catalog in an encrypted database.

## Why it's fascinating

Catalogizer treats "your collection" as a single logical library spread across heterogeneous storage. It identifies **50+ media types** — movies, TV shows, music, games, software, documentaries, and more — and continuously monitors each source for changes, updating metadata automatically. It enriches entries from a wide set of external providers (TMDB, IMDB, TVDB, MusicBrainz, Spotify, Steam, and others), analyzes quality, tracks versions, and surfaces analytics like growth trends.

The stack is a clean split: a high-performance Go REST API on Gin, a modern React/TypeScript front end with Tailwind, and WebSocket integration so the UI updates live as the catalog changes. Underneath, the data sits in a **SQLCipher-encrypted** store. It even goes beyond cataloging with practical extras — a PDF conversion service, favorites export/import in JSON and CSV, cloud sync to S3 and Google Cloud Storage, and professional PDF reporting with charts.

## The hard problems

The hardest problem is **unreliable network storage**. SMB and friends drop. Mounts vanish. A naive cataloger throws errors and corrupts its view of the world the moment a share goes offline. Catalogizer is built for **protocol resilience**: it handles temporary disconnections gracefully, reconnects automatically, and caches for offline operation, so a flaky NAS does not derail the whole system. Designing for the failure case as the normal case — rather than an exception — is the defining engineering decision here.

The second problem is **a single abstraction over very different protocols**. SMB, FTP, NFS, WebDAV, and the local filesystem each have their own semantics, quirks, and failure modes. Presenting them through one consistent file-system client interface — including full NFS mounting and file operations on macOS — so the detection engine and monitor can treat them uniformly is a substantial integration effort.

The third is **detection at scale with security**. Recognizing 50+ media types reliably, enriching from many external APIs, and doing it all over an encrypted database with JWT-based role access — without the encryption or the API calls becoming a bottleneck — takes deliberate architecture.

## What makes it game-changing

Most media managers assume your files are local and your network is perfect. Catalogizer assumes the opposite and still works. The combination of **multi-protocol reach plus resilience plus real-time monitoring** means it manages a distributed, partially-available collection as if it were one tidy library — and keeps it current automatically rather than on a manual rescan.

Layer on encryption by default, role-based access control, external metadata enrichment, and genuinely useful output features (reports, exports, cloud sync, PDF conversion), and it stops being a catalog and becomes a management platform for a media estate that happens to be scattered across protocols and machines.

## How I solved the hardest parts

I made **resilience a property of the storage layer**, not something each feature has to handle. The multi-protocol file-system clients are responsible for detecting disconnections, reconnecting automatically, and serving from an offline cache when a source is unavailable. Because that behavior lives in the client abstraction, the monitoring engine and detection engine above it can assume a source is always reachable — the messy reality of a dropped SMB mount is absorbed below them.

To tame protocol diversity, I unified SMB, FTP, NFS, WebDAV, and local access behind one **file-system client interface** with per-protocol monitoring, including real NFS mounting and file operations for macOS. The media-detection engine sits on top of that single interface, so adding a protocol or fixing one protocol's quirks does not ripple into detection logic.

For live behavior, the Go API runs a **WebSocket server** that pushes updates to the React front end the instant the catalog changes, so what users see reflects the monitored sources in real time rather than a stale snapshot. And I kept security non-optional: the database is SQLCipher-encrypted and the API is gated by JWT with role-based access control, so a system that reaches into many remote shares and external APIs does not become the weakest link. The result is a media manager designed around the world as it actually is — distributed, intermittent, and in need of being kept honest and secure.
