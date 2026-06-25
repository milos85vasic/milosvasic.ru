---
title: HelixTrack Core
slug: helix-track-core
repo: https://github.com/Helix-Track/Core
tech: Go, Gin, PostgreSQL, SQLite, SQLCipher, PLpgSQL, WebSocket
teaser: "The open-source JIRA alternative — extreme-performance issue tracking with military-grade encryption and a single action-routed API."
---

## The hook

Imagine rebuilding JIRA and Confluence from scratch, as one Go microservice, and making it fast enough to handle tens of thousands of requests per second with an encrypted database underneath. That is HelixTrack Core: "The Open-Source JIRA Alternative for the Free World." It is not a toy clone — it ships epics, subtasks, sprints, work logs, custom fields, dashboards, permission schemes, and a full Confluence-style documents engine, all behind a single REST API.

## Why it's fascinating

Most project-tracking tools grow into sprawling monoliths with dozens of endpoints that drift apart over years. I went the other way. HelixTrack Core exposes a unified `/do` endpoint with **action-based routing**: clients send a named action and a payload, and the server dispatches it through a consistent middleware and handler pipeline. That single design decision keeps the API surface coherent across hundreds of operations — issues, agile boards, voting, notification schemes, activity streams, comment mentions — without the endpoint sprawl that makes large APIs unmaintainable.

On top of that sits a real Confluence alternative. The Documents V2 extension implements spaces, rich pages in HTML/Markdown/plain text, full version history with diffs and rollback, inline comments, @mentions, reactions, templates, and analytics — backed by its own set of database tables and validated by hundreds of model tests. Building one of these systems is a project; building both as cooperating modules in one binary is the interesting part.

## The hard problems

Three things make this genuinely hard.

First, **security without a performance tax**. Enterprise issue trackers hold sensitive data, so the database is encrypted at rest with SQLCipher (AES-256). Encryption usually means a latency penalty — the engineering challenge was keeping that overhead minimal while still serving queries quickly under heavy concurrency.

Second, **multi-database reality**. Developers want SQLite for a frictionless local setup; production wants PostgreSQL with its concurrency and durability. Supporting both — including PLpgSQL-level optimizations and a schema that has evolved across multiple versioned migrations (V1 through V4, growing past ninety tables) — means every feature has to be correct on two very different engines.

Third, **real-time collaboration with correctness**. The moment multiple people edit the same ticket, you face the classic distributed-state problem: lost updates and conflicting writes. Solving that without locking users out of each other's work requires a deliberate concurrency model, not an afterthought.

## What makes it game-changing

HelixTrack Core treats permissions as a first-class, swappable engine. It implements **context-based hierarchical permissions** with inheritance, and the permissions implementation is pluggable — you can run it locally inside the service or delegate to an external HTTP authorization service. That separation lets organizations slot the tracker into an existing identity and policy infrastructure instead of fighting a built-in model.

It also does something most trackers ignore: **automatic service discovery**. Clients find Core servers on the local network via UDP broadcast, so the multi-platform clients (web, desktop, Android, iOS) can connect without manual configuration. Combined with JWT authentication, an extension system for Time Tracking, Documents, and Chat, and Git integration that maps commits to tickets, it behaves like a platform rather than a single app.

## How I solved the hardest parts

For the API, I committed to the **action-routing pattern** early. Every operation flows through the same `/do` lifecycle — authentication and permission middleware, then a handler keyed by action name. This is why the system can keep adding capabilities (Phase 1 priorities and resolutions, Phase 2 epics and work logs, Phase 3 voting and notification schemes, Phase 4 parallel editing) without the API fragmenting. New features register new actions; the transport and middleware stay constant.

For concurrent editing, I implemented **optimistic locking with version conflicts** plus a complete change-history layer. Each editable entity carries a version; a write that targets a stale version is rejected with a conflict the client can resolve, and history tables (added in the V4 schema) record the full trail of changes. I added explicit entity-locking management and conflict-resolution actions on top, and wired the whole thing into the existing WebSocket layer so collaborators see live updates. This gives real-time collaboration without silently clobbering someone else's edit.

For the encryption-versus-speed tension, the design leans on SQLCipher for transparent AES-256 at the storage layer while pushing hot paths through caching, so the common read patterns stay fast even with an encrypted store underneath. The codebase is backed by a large automated test suite — well over a thousand tests across the phases — which is what lets me make changes to a 90-plus-table schema and an encrypted, multi-database, concurrently-edited system and still trust that the behavior holds. Architecture diagrams, a user manual, and a deployment guide ship alongside the code, because a JIRA alternative that nobody can operate is not an alternative at all.
