---
title: Mail Server Factory
slug: mail-server-factory
repo: https://github.com/Server-Factory/Mail-Server-Factory
tech: Shell/Go
teaser: "Describe your mail server in one JSON file; it provisions a hardened, Dockerized stack on 25 Linux distros across 12 connection types."
---

## The hook

Running your own mail server has a deserved reputation as one of the most miserable jobs in systems administration: SMTP, IMAP, POP3, TLS, DKIM, SPF, firewalls, certificates, SELinux, and a dozen daemons that all have to agree with each other or nothing delivers. Mail Server Factory's pitch is gloriously blunt — "Run Your Mail Server Like The Boss." You write a simple JSON file describing what you want, and the Factory interprets it and builds the entire hardened, Dockerized stack on the target machine for you.

## Why it's fascinating

The fascinating idea is treating mail-server deployment as a *compilation* problem. The JSON configuration is the source; the Factory is the compiler; a running, loosely-coupled, Docker-based mail stack on the target OS is the output. Because each stack component is loosely coupled and containerized, the result is a clean base for scaling later rather than a tangle of hand-edited config files nobody dares touch.

What pushes it from "neat" to "serious" is reach. The Factory can deliver that stack over 12 distinct connection types — SSH, Docker, Kubernetes, AWS SSM, Azure Serial Console, GCP OS Login, Libvirt, a custom protocol, database, file system, cloud provider, and container runtime. And it targets 25 Linux distributions, including ones most tools ignore entirely: Western mainstays (Ubuntu, Debian, CentOS, Fedora, AlmaLinux, Rocky, openSUSE), Russian distros (ALT, Astra, ROSA), and Chinese ones (openEuler, openKylin, Deepin). That breadth is a deliberate statement: your mail server, your hardware, your jurisdiction.

## The hard problems

The first hard problem is that "the same install" is never the same. Package names, init systems, firewall front-ends, and SELinux behavior diverge across 25 distributions. The Factory carries a real security framework — a `CertificateValidator`, `DockerCredentialsManager`, `SELinuxChecker`, `PasswordValidator`, and a `ConnectionPool` — precisely because each of those concerns behaves differently per platform and cannot be assumed.

The second is the connection layer itself. Reaching a target over SSH is nothing like reaching it over AWS SSM, Azure Serial Console, or Libvirt. Each transport has its own authentication, its own latency, its own failure modes. Abstracting all 12 behind a single installation pipeline — so the install steps don't care how bytes get to the box — is the architectural spine of the project.

The third is getting to a clean machine in the first place. The Factory automates unattended OS installation via preseed, kickstart, cloud-init, and autoyast across all those distributions, drives QEMU virtual machines through `scripts/qemu_manager.sh`, and manages ISOs with checksum verification and an enterprise twist: a bidirectional SMB cache that pulls missing images from a network share, uploads missing ones back, and falls through to internet download only as a last resort.

## What makes it game-changing

The game-changer is that it makes self-hosted mail *reproducible and auditable*. Email infrastructure is exactly the kind of thing you want described as data and rebuilt identically, not assembled by memory at 2am. With the stack defined in JSON and the security posture enforced by code — AES-256-GCM encryption, mandatory SSH-key passphrases of at least 12 characters, automated firewall rules for ports 25/587/465/993/995, TLS with certificate validation and HSTS, audit logging, and RBAC — "production-grade mail server" stops being a multi-week project and becomes a config you can review, version, and re-run.

It is also rigorously validated, not aspirational: the project reports 439 tests at 100% passing, a 100% SonarQube quality gate, and a full testing framework that exercises real SMTP/IMAP/POP3 behavior across distributions plus throughput and latency measurements. For a tool whose entire job is to be trusted with your email, that evidence is the feature.

## How I solved the hardest parts

I separated *what to build* from *how to reach the target* and *which OS we're on*. The JSON config describes intent; a transport abstraction hides the 12 connection types behind one interface so installation steps issue the same logical operations whether they're flowing over SSH or AWS SSM; and per-distribution logic is isolated so the 25-distro matrix lives in one place instead of leaking into every step. That layering is why adding a distribution or a connection type doesn't ripple through the whole codebase.

For security I refused to leave anything to the operator's good intentions. The framework enforces the hard parts — it *checks* SELinux, *validates* certificates, *manages* Docker credentials, and *rejects* weak passwords and passphraseless SSH keys — so a correct deployment is the default, not a careful achievement. Shell does the heavy provisioning where it's the right tool, with Kotlin/JVM logic for the orchestration and security framework, and Docker keeps every component loosely coupled.

And I solved the "clean machine" bootstrapping that most installers punt on: unattended installs for every supported distro, QEMU automation to spin up test targets, and the bidirectional SMB ISO cache so a fleet deployment doesn't re-download the same image twenty-five times — with every ISO checksum-verified no matter where it came from. The result is a tool that takes you from bare metal (or a bare VM) all the way to a hardened, tested, running mail server from a single file.
