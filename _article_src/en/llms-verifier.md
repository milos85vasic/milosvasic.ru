---
title: LLMs Verifier
slug: llms-verifier
repo: https://github.com/vasic-digital/LLMsVerifier
tech: Go
teaser: "Before any LLM touches production, it has to prove it can actually see your code — across 12 providers, in real time."
---

## The hook

Every team plugging into "the latest model" is quietly trusting a config file. The model name in your YAML says `gpt-4o` or `claude-sonnet`, the endpoint returns 200, and you assume the thing on the other end is real, healthy, and capable of the task you're about to throw at it. LLMs Verifier exists because that assumption is wrong often enough to hurt. It is an enterprise-grade Go platform that refuses to let an unverified model into your pipeline — every model must first pass a literal "Do you see my code?" check before it is allowed to be used.

## Why it's fascinating

The interesting part is that "verifying an LLM" is not one test — it's a whole battery of them, and they each fail in different, sneaky ways. LLMs Verifier runs existence checks, responsiveness, latency, streaming, function calling, vision, and embeddings as distinct verification tests. A model can exist but not stream. It can stream but choke on tool calls. It can claim vision support and silently ignore the image. By treating each capability as a first-class, independently-verifiable property, the platform turns "is this model good?" from a vibe into a measurable, repeatable result.

On top of that, it speaks to 12 provider adapters — OpenAI, Anthropic, Cohere, Groq, Together AI, Mistral, xAI, Replicate, DeepSeek, Cerebras, Cloudflare Workers AI, and SiliconFlow — through one normalized interface. The same verification suite, the same scoring, run against wildly different APIs. That normalization is where most of the engineering blood is spilled, because no two providers agree on what streaming, function calling, or embeddings even look like on the wire.

## The hard problems

The first hard problem is heterogeneity. A capability-detection layer has to know that streaming might arrive as Server-Sent Events, WebSocket frames, an async generator, JSONL, or a raw event stream — and it has to detect which one a given provider actually delivers, not which one the docs promise. It tracks compression support (gzip, brotli, and semantic/chat-level compression), caching behavior (Anthropic and DashScope prompt caching), and HTTP/3 availability per provider. None of that is uniform; all of it has to be discovered empirically.

The second is trust under failure. In production, providers throttle, degrade, and disappear. The platform layers real-time health checking with intelligent failover and a circuit-breaker pattern so a flapping provider doesn't take the whole verification run — or the consuming application — down with it.

The third is long-horizon context. The system supports 24+ hour sessions with LLM-powered summarization and RAG optimization, plus a supervisor/worker pattern that uses an LLM to break large verification jobs into distributed work. Keeping state coherent across a full day of agent activity, without blowing the context window, is a genuinely hard distributed-systems problem dressed up as an LLM feature.

## What makes it game-changing

The game-changer is the move from "configured" to "proven." Most stacks export a list of model names and hope. LLMs Verifier produces a verified configuration export where only models that actually passed verification are included — and it brands every generated provider and model with a mandatory `(llmsvd)` suffix so there is never ambiguity about what was machine-verified versus hand-edited. That single discipline kills an entire class of incidents: the "we shipped against a model that can't do the thing we needed" failure mode simply can't survive an export gate.

It is also built like infrastructure, not a script. Docker and Kubernetes deployment, Prometheus metrics with Grafana dashboards, LDAP/SSO with SAML/OIDC, SQLCipher database encryption, and integrations with Splunk, DataDog, New Relic, and ELK. It ships Python and JavaScript SDKs and an OpenAPI/Swagger surface. This is a platform you can hand to a security team and a platform team and have both nod.

## How I solved the hardest parts

I made verification the contract, not an afterthought. The core decision was that nothing — no model, no provider — earns the right to be used until it has passed the suite, and the "Do you see my code?" check is the non-negotiable entry gate. That framing forced a clean separation: provider adapters are dumb transports, and the verification engine owns truth.

To tame 12 incompatible providers, I built capability detection as an empirical probe rather than a static capability table. The system asks each provider what it can do by actually doing it — opening a stream and classifying the framing (SSE vs WebSocket vs JSONL vs async generator), attempting a function call, sending an image — and records the observed reality, including compression and caching quirks. Adding a 13th provider becomes "write a transport and let the prober characterize it," not "re-audit the whole matrix."

For resilience I leaned on patterns I trust: circuit breakers around every outbound provider call, health checks driving automatic failover, and cloud-backed checkpoints (S3, Google Cloud, Azure) so a 24-hour supervised run can survive a restart. And I wrote it in Go on purpose — the concurrency model maps naturally onto "run many independent verification probes against many flaky remote services at once," which is exactly the workload. The result is a verifier that is itself production-grade, because a tool that gates production has no business being flaky.
