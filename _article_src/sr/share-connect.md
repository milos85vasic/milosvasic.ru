---
title: ShareConnect
slug: share-connect
repo: https://github.com/vasic-digital/ShareConnect
tech: Kotlin
teaser: "Share any media link from your phone straight to your own download stack — 20 production-ready apps, eight things kept in sync across all of them."
---

## Kukica

Nađete video, torent, fajl vredan čuvanja — na telefonu, u pretraživaču, u ćaskanju. Zatim dolazi trenje: kopirate link, menjate uređaj, pronalazite pravi klijent, nalepljujete, podešavate, nadate se. ShareConnect to briše. Integriše se u Android-ov izvorni meni za deljenje, tako da svaki URL koji se može preuzeti ide pravo na *vašu* infrastrukturu — MeTube, YT-DLP, qBittorrent, Transmission, jDownloader i još mnogo toga — povezujući otkrivanje sadržaja sa vašim uslugama za preuzimanje. Ime je teza: **share** (deljenje) susreće **connect** (povezivanje).

## Zašto je fascinantno

ShareConnect nije jedna aplikacija; to je ekosistem od 20 Android aplikacija spremnih za produkciju, izgrađen kroz pažljivo osmišljen trofazni plan. Prva faza je jezgro: glavni ShareConnector plus namenski klijenti za qBittorrent, Transmission i uTorrent. Druga faza dodaje osam cloud usluga — JDownloader (preko MyJDownloader API-ja), MeTube, YT-DLP (koji podržava preko 1800 streaming sajtova), Nextcloud, FileBrowser, Plex, Jellyfin i Emby. Treća faza zaokružuje celinu sa osam specijalizovanih usluga, uključujući Seafile, Syncthing, Matrix, Paperless-NG, Duplicati, WireGuard, kontroler Minecraft servera i OnlyOffice.

Ipak, najzanimljiviji inženjering krije se u sinhronizacionoj osnovi. ShareConnect održava osam različitih stvari sinhronizovanim u svakoj aplikaciji ekosistema: temu, profile, istoriju, RSS feedove, obeleživače, podešavanja, jezik i stanje deljenja torenta. Tako vaša tema u glavnoj aplikaciji postaje tema i u qBitConnect-u; vaša istorija preuzimanja prati vas; vaši profili su svuda konzistentni. Dvadeset aplikacija koje se ponašaju kao jedan proizvod.

## Teški problemi

Prvi veliki problem je širina integracija. Svaki backend — qBittorrent, Transmission, jDownloader, Plex, Jellyfin, Nextcloud, Matrix, Syncthing — ima svoj API, model autentifikacije i specifičnosti. Izgradnja 20 klijenata koji svaki ispravno komuniciraju sa svojim ciljnim protokolom, a istovremeno dele dovoljno zajedničke strukture da ostanu održivi, podjednako je problem discipline koliko i programiranja.

Drugi je sama sinhronizacija između aplikacija. Sinhronizacija osam kategorija stanja između više zasebno instaliranih Android aplikacija zahteva rešavanje pravih pitanja distribuiranih sistema na jednom uređaju i šire: kako nezavisne aplikacije otkrivaju jedna drugu, dogovaraju se oko zajedničkog stanja i usklađuju promene bez međusobnog ometanja? Tema, profili, istorija, RSS, obeleživači, podešavanja, jezik i deljenje torenta imaju različite obrasce ažuriranja i semantiku sukoba.

Treći je dokazivanje da sve funkcioniše. Sa 20 aplikacija i zajedničkim slojem za sinhronizaciju, površina za testiranje je ogromna — a projekat ne uzmiče: izvestava o 100% uspešnosti na jediničnim, instrumentalnim i automatizovanim testovima, uz dodatni prolazak kroz QA vođen veštačkom inteligencijom, A+ ocenu na SonarQube-u, bez kritičnih ranjivosti u Snyk-u, oko 95% pokrivenosti koda i odnos tehničkog duga od 0,2%. Održavanje te mere kvaliteta u celom ekosistemu je ono što većina projekata tiho preskače.

## Šta ga čini revolucionarnim

Revolucionarno je udobnost samostalnog hostovanja bez kompromisa. Komercijalne funkcije „pošalji na moje uređaje" vežu vas za tuđi cloud. ShareConnect usmerava istu tu jednostavnost jednim dodirom na infrastrukturu *koju vi posedujete* — vaš klijent za torente, vaš medija server, vaš Nextcloud — i čini da sve izgleda kao da je deo samog Androida. Pretvara raštrkanu zbirku samostalno hostovanih usluga u jedinstvenu, koherentnu, deljivu površinu.

A pošto je sinhronizacioni sloj vezivno tkivo, ekosistem se elegantno širi: prateći klijent poput qBitConnect-a ili TransmissionConnect-a nije izolovan, već automatski nasleđuje zajedničku temu, profile i istoriju. Ceo sistem je izgrađen na modernom Android steku — Kotlin 2.0, Java 17, Android API 26+ — tako da nije samo koncept; to je 20 aplikacija označeno kao spremno za produkciju.

## Kako sam rešio najteže delove

Sinhronizacionu osnovu tretirao sam kao srž proizvoda, a ne kao dodatnu funkciju. Umesto da sinhronizaciju nakalemim na svaku aplikaciju, izgradio sam je kao namenske, deljene module za sinhronizaciju — ThemeSync, ProfileSync, HistorySync, RSSSync, BookmarkSync, PreferencesSync, LanguageSync i TorrentSharingSync — u koje se svaka aplikacija u ekosistemu uključi. To je razlog zašto novi klijent dobija konzistentnost „besplatno": usvaja module umesto da ih iznova izmišlja.

Za rasprostranjenost integracija koristio sam obrazac konektora: svaki backend (qBittorrent, Transmission, MeTube, YT-DLP, JDownloader, Plex i ostali) je samostalni modul-konektor iza zajedničkog ugovora, što je omogućilo da 20 klijenata ostane pojedinačno ispravno, a ipak kolektivno održivo. Fazni pristup — prvo jezgarni klijenti, zatim cloud usluge, pa specijalizovane — omogućio je da se svaki sloj stabilizuje pre nego što se na njega nadogradi sledeći.

Na kraju, odbio sam da kvalitet opadne kako se površina širila. 100% uspešni jedinični, instrumentalni i automatizovani testovi, uz QA fazu vođenu veštačkom inteligencijom, nisu samo ukrasi; to je jedini način da ekosistem od 20 aplikacija sa zajedničkim sinhronizacionim slojem ne propadne pod sopstvenom težinom regresije. Održavanje oko 95% pokrivenosti koda i odnosa tehničkog duga od 0,2% u celom sistemu omogućilo je projektu da svaku od tih 20 aplikacija označi kao spremnu za produkciju.
