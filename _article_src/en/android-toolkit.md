---
title: Android Toolkit
slug: android-toolkit
repo: https://github.com/vasic-digital/Android-Toolkit
tech: Kotlin
teaser: "The reusable foundation under my Android apps — drop-in modules from root shells to interprocess comms, added as one git submodule."
---

## The hook

Every serious Android developer accumulates the same pile of "I've written this before" code: a sane testing harness, a logging facade, root access helpers, interprocess plumbing, a circle ImageView, an alphabet fast-scroller. Android Toolkit is that pile, refined into a clean, modular library — a commonly-used set of abstractions, implementations, and tools that you `git submodule add` into a project and start using immediately. It's the unglamorous foundation that makes the glamorous apps possible.

## Why it's fascinating

The fascinating part is the architecture of *restraint*. The Toolkit is split into focused, independently-includable modules — `Main`, `Test`, `Echo`, `Access`, `JCommons`, `RootTools`, `RootShell`, `Interprocess`, `CircleImageView`, `ConnectionIndicator`, `FastscrollerAlphabet` — and you wire in only the ones you need via `settings.gradle` and `build.gradle`. No monolith, no dragging in a kitchen sink to get a single helper. That granularity is a real design decision: each module earns its place on its own.

It's also delivered as a git submodule rather than a published artifact, which tells you what it's for. This is the shared spine across a developer's own portfolio of Android work — the consistent base layer that keeps multiple apps behaving the same way, evolving in lockstep, without copy-paste drift between projects. The modules span an unusually wide range, from low-level system access (root shells and tools) to interprocess communication to ready-made UI widgets, which means the same Toolkit can serve both a power-user system app and a polished consumer UI.

## The hard problems

The first hard problem is the modularity contract. For an à-la-carte module system to actually work, the boundaries have to be honest — `RootShell` and `RootTools` can't secretly depend on a UI widget; `Interprocess` can't drag in test scaffolding. Designing modules that are genuinely independent yet compose cleanly through Gradle is harder than building one big library, because every seam is a commitment.

The second is the dangerous corners of Android. Root access (`RootShell`, `RootTools`) and interprocess communication (`Interprocess`) are exactly the areas where bugs become security holes or cross-app crashes. Wrapping privileged shells and IPC in abstractions that are safe and ergonomic — easy to use correctly, hard to use catastrophically — is the kind of work that doesn't show in a screenshot but determines whether the apps on top are trustworthy.

The third is being a foundation across many projects at once. A toolkit consumed by multiple apps via submodule has to evolve carefully: a change to a shared abstraction ripples everywhere. That's why the Toolkit ships a dedicated `Test` module and wires test dependencies (`testImplementation`, `androidTestImplementation`) as a first-class concern — the foundation has to be testable, and the apps built on it have to be testable through it.

## What makes it game-changing

The game-changer is leverage. Reusable infrastructure like this is what lets one engineer credibly maintain a whole family of Android applications — the ShareConnect ecosystem, Yole, and more — without rebuilding the basics every time. The Toolkit turns "common Android problems" into solved, shared, version-controlled modules, so each new app starts from a higher floor and inherits consistency in logging, testing, system access, and UI primitives by default.

The submodule delivery model amplifies that: improvements made while building one app flow back into the Toolkit and immediately benefit the others. It's a compounding investment — the foundation gets stronger every time it's used.

## How I solved the hardest parts

I designed for opt-in from the first line. By splitting the Toolkit into narrowly-scoped Gradle modules and documenting that you include *only* what you need, I made the library additive rather than imposing — a project pulls in `RootShell` and `Interprocess` without inheriting a UI widget it'll never render. Keeping the module list explicit in `settings.gradle` makes the dependency surface visible and intentional instead of magic.

For the dangerous corners, I isolated privilege and IPC into their own modules — `RootShell`/`RootTools` for root access, `Interprocess` for cross-process communication — so the risky code lives behind a deliberate boundary you have to choose to cross, not something that leaks into every consumer by default. That isolation is what makes the rest of the Toolkit safe to depend on broadly.

And I treated testing as part of the foundation, not an afterthought: shipping a `Test` module and standard `testImplementation`/`androidTestImplementation` wiring means every app built on the Toolkit gets a consistent testing setup out of the box, and changes to shared abstractions can be validated before they ripple across the portfolio. The whole thing is delivered as a submodule precisely so the foundation and the apps that stand on it can move forward together — one base, many products, no drift.
