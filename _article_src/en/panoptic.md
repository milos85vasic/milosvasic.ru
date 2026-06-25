---
title: Panoptic
slug: panoptic
repo: https://github.com/vasic-digital/Panoptic
tech: Go
teaser: "One Go framework that drives, screenshots, and screen-records web, desktop, iOS and Android — the all-seeing eye for UI automation."
---

## The hook

UI automation is fractured. You learn Selenium or Playwright for the web, Appium and XCUITest for mobile, something else entirely for desktop, and a separate recorder if you want video of what happened. Every boundary is a new tool, a new abstraction, a new way to be flaky. Panoptic — named for the all-seeing eye — collapses that whole zoo into a single Go framework that automates, screenshots, and records sessions across web, desktop, and mobile with one programming model.

## Why it's fascinating

What makes Panoptic compelling is that it treats "watch what the software does" as a first-class capability alongside "drive the software." It doesn't just click buttons; it captures high-quality, timestamped screenshots and records full session video in multiple formats. That means a single test run can produce both the assertions and the visual evidence — the recording is not a bolt-on, it's part of the framework.

It is genuinely cross-everything. Web automation spans Chrome, Firefox, Safari, and Edge. Mobile covers both iOS and Android app automation with screen recording. Desktop gets UI automation and screen capture. And it's all exposed through a clean Go API — `web.NewBrowser()`, `browser.Navigate(...)`, `browser.Screenshot(...)`, custom CSS and XPath selectors, explicit wait strategies — plus a CLI for the common cases (`panoptic record --platform ios --device iPhone13 --output mobile_demo.mp4`). The fact that the same conceptual API reaches from a headless Chrome viewport to a recorded iPhone session is the whole point.

## The hard problems

The first hard problem is that "an element" means something different on every platform. A web button is a DOM node reachable by CSS or XPath. An iOS control lives in the accessibility tree. A desktop widget is an OS-native handle. Panoptic has to present a unified element-detection and interaction model while, underneath, speaking four completely different dialects of "find this thing and tap it."

The second is timing. UI is asynchronous everywhere, but it's asynchronous differently everywhere. Panoptic ships explicit wait strategies — `WaitForElement` with a timeout, and `WaitForCondition` that polls an arbitrary predicate until it's true — because hard sleeps are the number-one source of flaky automation. Designing wait primitives that behave identically whether they're waiting on a `div.loading` to vanish or a native view to render is subtle work.

The third is recording while driving. Capturing 30fps video at high quality, with a configurable viewport, without perturbing the timing of the automation you're recording, is a real performance and synchronization challenge — especially on mobile, where you're recording a device or simulator screen, not just a canvas you own.

## What makes it game-changing

The game-changer is consolidation with evidence. When automation lives in one framework across every platform, a team writes one mental model instead of four, and gets visual proof for free. A flaky test stops being a stack trace you squint at — it becomes a video you watch. That alone changes how teams triage failures.

It's also built to drop into pipelines: an extensible plugin architecture, before/after hooks for setup and teardown, a YAML config for browser, recording, and per-platform mobile settings, and explicit CI/CD integration. You can wire the same suite into CI that you ran locally, and the artifacts — screenshots and MP4s — are exactly what you want attached to a failing build.

## How I solved the hardest parts

I chose Go deliberately. Cross-platform automation is, under the hood, a lot of concurrent I/O — talking to browser drivers, device bridges (ADB for Android, Xcode tooling for iOS), and an encoder for the recording — all at once. Go's goroutines and channels make orchestrating "drive the UI on this goroutine, drain screen frames on that one, watch for a wait condition on a third" tractable and fast, and the single static binary makes the CLI trivial to ship into CI.

To unify four element models, I made platform drivers implement a common interaction interface and kept selectors expressive rather than lowest-common-denominator — CSS and XPath on the web, native locators on mobile and desktop — so the abstraction never costs you the precise selector you actually need. The wait primitives are built on top of that interface, which is why `WaitForCondition` works identically no matter what platform the predicate is inspecting.

For recording without distortion, I treated capture as a separate pipeline configured independently (format, quality, fps in `panoptic.yaml`) so the recorder runs alongside the automation rather than inside its critical path. And I made the whole thing extensible via hooks and a plugin system from the start, because the one certainty in automation is that someone will need to do something I didn't anticipate — and the framework should let them, instead of forcing a fork.
