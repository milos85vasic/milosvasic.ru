---
title: Helix-Flow Platform
slug: helix-flow-platform
repo: https://github.com/Helix-Flow/Platform
tech: Go, gRPC, HTTP, TLS 1.3, mTLS, PostgreSQL, SQLite, JWT
teaser: "One OpenAI-compatible gateway for all your AI inference — TLS 1.3, mutual-auth service mesh, predictable costs, drop-in API."
---

## Uvod

„Jedna platforma za sve vaše potrebe za AI inferencijom – pokrećite moćne AI modele brže, pametnije, na bilo kojoj skali, uz predvidive troškove." Helix-Flow Platform je enterprise AI inferencijski gateway koji podržava OpenAI API, tako da vaši postojeći klijenti jednostavno rade, ali ispod površine funkcioniše kao otporna, uzajamno autentifikovana mreža mikroservisa sa TLS 1.3 enkripcijom od kraja do kraja.

## Zašto je fascinantno

Obećanje AI inferencije jednostavno je za izreći, ali surovo za ostvariti: pružite timovima jedan konzistentan, brz i siguran način za pozivanje modela, bez vezivanja za cene ili runtime jednog dobavljača. Helix-Flow pristupa ovome kao **enterprise-grade arhitekturi mikroservisa** – API gateway koji stoji ispred nezavisnih servisa za autentifikaciju, inferencijski pool i monitoring – dostupan istovremeno i preko HTTP-a i preko gRPC-a.

Ključno je da cilja **usklađenost sa OpenAI API specifikacijom**. To znači da je poznata površina tu – `/v1/models`, `/v1/chat/completions`, Bearer-token autentifikacija – tako da sve što je već izgrađeno za OpenAI API može jednostavno da se preusmeri na Helix-Flow. Dobijate endpoint koji se direktno uklapa, ali sa vašom autentifikacijom, vašim monitoringom i vašom kontrolom troškova iza njega.

## Teški problemi

Centralni izazov je **sigurnost na nivou servisne mreže, a ne samo na ivici**. Lako je postaviti TLS na javni endpoint; mnogo je teže enkriptovati i autentifikovati svaki skok *između* internih servisa. Helix-Flow gradi kompletnu PKI infrastrukturu i koristi TLS 1.3 sa **uzajamnim TLS-om (mTLS)** u svojoj gRPC servisnoj mreži, tako da servisi dokazuju svoj identitet jedni drugima, a ne samo prema spoljašnjem svetu. To zahteva automatizovano upravljanje sertifikatima – generisanje, distribuciju i rotaciju – jer mreža osigurana ručno ne preživi kontakt sa produkcijom.

Drugi težak problem je **paritet dvostrukog protokola**. Ponuda i HTTP gatewaya i gRPC gatewaya znači da iste mogućnosti moraju biti ispravne preko dva veoma različita transportna protokola, sa konzistentnom autentifikacijom i ponašanjem na oba. Timovi koji preferiraju REST i oni koji preferiraju high-performance gRPC trebalo bi da dobiju istu platformu.

Treći je **predvidivi troškovi i operativnost**. „Predvidivi troškovi" su proizvodno obećanje koje važi samo ako platforma ima pravi monitoring, rate limiting i audit logovanje – tako da su troškovi i ponašanje vidljivi i ograničeni, umesto da budu iznenađenje na kraju meseca.

## Šta ga čini revolucionarnim

Opklada Helix-Flow-a je da AI inferencija treba da bude **infrastruktura**, a ne integracija po aplikaciji. Pružanjem OpenAI-kompatibilnog API-ja ispred inference pool-a koji nije vezan za dobavljača, omogućava organizaciji da centralizuje način na koji poziva modele: jedan gateway, jedan autentifikacioni model, jedno mesto za nametanje rate limita, jedan audit trag. Prebacivanje ili dodavanje modela u pozadini postaje infrastrukturna odluka, a ne promena koda rasuta po svim aplikacijama koje ga koriste.

I sve to radi bez kompromisa na enterprise osnovama – validacija JWT tokena, rate limiting, audit logovanje, graciozna obrada grešaka i multi-bazni backend (SQLite za razvoj, PostgreSQL za produkciju) – tako da može da se preseli sa laptopa na klaster bez menjanja ugovora na koji se klijenti oslanjaju.

## Kako sam rešio najteže delove

Sigurnost sam ugradio od temelja, umesto da je nakalemim naknadno. Platforma isporučuje **kompletnu PKI infrastrukturu sa TLS 1.3 i mTLS-om**, a izdavanje sertifikata je automatizovano tako da servisna mreža može da autentifikuje sebe bez ručnog upravljanja sertifikatima. Svaki interni gRPC skok je uzajamno autentifikovan; gateway prekida spoljašnji saobraćaj preko TLS-a i validira JWT tokene pre nego što bilo šta stigne do inference pool-a. Sigurnost je svojstvo mreže, a ne omotač oko nje.

Za podršku dvostrukom protokolu, dizajnirao sam **API gateway tako da služi HTTP i gRPC istovremeno**, pri čemu su zahtevniji servisi – autentifikacija i inference pool – izloženi preko gRPC-a radi performansi, a javna površina preko HTTP-a radi kompatibilnosti. Ovo razdvajanje omogućava da interni pozivi osetljivi na latenciju koriste gRPC, dok spoljašnji klijenti zadržavaju jednostavan OpenAI-style REST interfejs.

Za operativnost i obećanje „predvidivih troškova", učinio sam **monitoring servis prvoklasnom komponentom** pored autentifikacije i inferencije, dodajući health check-ove, prikupljanje metrika, rate limiting i audit logovanje tako da su upotreba i zdravlje sistema vidljivi i ograničeni po defaultu. Dizajn sa više baza – SQLite za lokalni razvoj bez trenja, PostgreSQL za produkciju – znači da ista platforma može da se testira na jednoj mašini, a zatim da se skaluje, što je upravo ono što „inference platforma na bilo kojoj skali" mora da može.
