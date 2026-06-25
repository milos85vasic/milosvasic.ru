---
title: HelixTranslate
slug: helix-translate
repo: https://github.com/HelixDevelopment/HelixTranslate
tech: Go, HTTP/3, WebSocket, REST, SSH, LLM providers
teaser: "Translate an entire ebook into any language — over a verified-best LLM, streamed live over WebSocket, with no silent local fallbacks."
---

## The hook

Hand it a book in any format, name a target language, and HelixTranslate will translate the whole thing — routing your text to the strongest *verified* LLM available, streaming progress to a live dashboard, and refusing to quietly degrade quality behind your back. It is a high-performance, enterprise-grade universal ebook translation toolkit with a REST API, HTTP/3 support, and real-time WebSocket events.

## Why it's fascinating

Translation tools usually make you pick a provider and hope it is good enough today. HelixTranslate inverts that. Its default path is **bridge-selected**: it sources the strongest verified API model — plus a score-ordered fallback chain — automatically, via an integration with my LLMsVerifier project. You do not choose a provider; the system chooses the best one that is currently proven to work, and falls back down a ranked list if the top choice fails.

Around that core sits a full **real-time monitoring system**: a WebSocket hub streams live progress, events, and errors to a web dashboard, supports multiple simultaneous translation sessions with unique IDs, and handles multi-client connections with automatic reconnection. You can watch a long book translate paragraph by paragraph instead of staring at a blocked terminal. It speaks to many providers — OpenAI, Anthropic, DeepSeek, Zhipu, Qwen, Gemini, and more — all reachable through verified discovery.

## The hard problems

The first hard problem is **honesty under failure**. The easy thing to do when an API key is missing or a provider fails is to silently fall back to a weak local model and pretend everything is fine. That produces garbage translations that look successful. I made the opposite a hard rule: with no provider API key set, the bridge returns an honest error — there is never a silent local fallback. Enforcing that consistently across the whole pipeline is a design constraint, not a one-line check.

The second is **distributed translation over SSH**. Large books are slow to translate serially, so the system supports remote SSH workers — connecting securely, dispatching translation work, tracking progress from the remote side, and handling errors and fallback. Coordinating remote workers while still emitting coherent real-time events to the dashboard is the kind of integration that breaks in a hundred small ways.

The third is **real-time eventing done right**. Streaming live progress for multiple concurrent sessions to multiple dashboard clients — with reconnection, session history, and per-session tracking — is a genuine WebSocket-architecture problem, not a progress bar.

## What makes it game-changing

The verified-best-model strategy is the idea worth stealing. Instead of trusting a static provider choice, HelixTranslate continuously leans on external verification to route to whatever is *actually* performing, with a deterministic fallback chain when it is not. That turns "which LLM should I use for translation?" from a guess into a measured, automatic decision — and it means the tool gets better as the underlying model landscape shifts, without code changes.

It is also deliberately scoped. At one point the project supported local-runtime providers and an SSH-local path; in a later bridge phase I **removed** the local-runtime providers (Ollama, LlamaCpp) and the SSH-local translation path entirely. Selecting them now returns an honest "no longer supported" error rather than running a degraded local model. That is the same honesty principle applied to the roadmap: I would rather cut a path than let it produce quietly worse output.

## How I solved the hardest parts

The architectural keystone is the **bridge package** (`pkg/bridge`) that connects translation to LLMsVerifier. Rather than hardcoding provider preferences, the translator asks the bridge for the strongest verified model and a ranked fallback chain, then translates against that. This is what makes "you don't have to pick a provider" true in practice, and it is where the no-silent-fallback rule is enforced — the bridge returns an explicit error instead of substituting a local model.

For real-time monitoring I separated concerns into dedicated packages: a `websocket` hub that owns connection and broadcast management, an `events` system that defines and emits the event stream, and an `sshworker` package for remote execution. A standalone monitor server consumes the WebSocket stream and drives the dashboard, so translation runs and monitoring are decoupled — the CLI emits events, the server fans them out, and any number of dashboard clients subscribe with automatic reconnection.

For distribution, the SSH worker layer handles secure connection management and remote execution while reporting progress back through the same event system, so a remote translation looks identical to a local one from the dashboard's point of view. The whole thing is exposed over a REST API with HTTP/3 support and backed by a comprehensive WebSocket monitoring test suite — because a translation system you cannot observe is a translation system you cannot trust.
