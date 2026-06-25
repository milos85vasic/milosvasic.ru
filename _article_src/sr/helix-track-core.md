---
title: HelixTrack Core
slug: helix-track-core
repo: https://github.com/Helix-Track/Core
tech: Go, Gin, PostgreSQL, SQLite, SQLCipher, PLpgSQL, WebSocket
teaser: "The open-source JIRA alternative — extreme-performance issue tracking with military-grade encryption and a single action-routed API."
---
## Kuka

Zamisli da ponovo gradiš JIRA i Confluence od nule, kao jedan Go mikroservis, i da ga napraviš dovoljno brzim da može da obrađuje desetine hiljada zahteva u sekundi sa šifrovanom bazom podataka ispod. To je HelixTrack Core: "Otvoreni izvor JIRA alternativa za slobodni svet." Nije reč o igračkoj kopiji — isporučuje epike, potzadatke, sprintove, radne logove, prilagodljiva polja, kontrolne table, sheme dozvola i kompletni Confluence-stil dokumenata motor, sve iza jedne REST API-je.

## Zašto je zanimljivo

Većina alata za praćenje projekata raste u razgranate monolite sa desetinama endpoint-ova koji se razilaze tokom godina. Ja sam išao suprotnim putem. HelixTrack Core izlaže ujedinjeni `/do` endpoint sa **akcioni baziranim rutiranjem**: klijenti šalju naznačenu akciju i teret, a server ga upućuje kroz konzistentan middleware i handler pipeline. Ta jedina dizajnerska odluka čuva API površinu koherentnu preko stotina operacija — problema, agilnih tabla, glasanja, shema obaveštenja, aktivnih tokova, komentara pomena — bez endpoint razgrtanja koje čini velike API-je neoderživim.

Na vrhu toga sedi stvarna Confluence alternativa. Proširenje Dokumenata V2 implementira prostore, bogate stranice u HTML/Markdown/običnom tekstu, kompletnu istoriju verzija sa difovima i vraćanjem, komentare u tekstu, @pomena, reakcije, šablone i analitiku — podržano sopstvenim setom tabela baze podataka i validirano stotinama model testova. Izgradnja jednog od ovih sistema je projekt; izgradnja oba kao saradujućih modula u jednom binarnom fajlu je zanimljiv deo.

## Teški problemi

Tri stvari čine ovo stvarno teškim.

Prvo, **bezbednost bez performansi poreza**. Preduzeća za praćenje problema sadrže osetljive podatke, tako da je baza podataka šifrovana u mirovanju sa SQLCipher (AES-256). Šifrovanje obično znači kaznu za kašnjenje — inženjerski izazov bio je da se ova prepreka minimalizuje dok se upiti obrađuju brzo pod teškom konkurencijom.

Drugo, **multi-baza podataka realnost**. Razvijači žele SQLite za bezbolnu lokalnu podešavanja; proizvodnja želi PostgreSQL sa njegovom konkurencijom i izdržljivošću. Podrška za oba — uključujući PLpgSQL-nivo optimizacije i shemu koja je evoluirala tokom više verzija migracija (V1 do V4, raste preko devedeset tabela) — znači da svaka funkcija mora biti ispravna na dve veoma različite mašine.

Treće, **stvarno vremenska saradnja sa ispravnim**. U trenutku kada više ljudi uređuju isti tiket, suočavaš se sa klasičnim problemom distribuiranog stanja: izgubljeni ažuriranja i sukobljeni upisi. Rešavanje toga bez zaključavanja korisnika između sebe zahteva namerno model konkurencije, a ne naknadno.

## Šta ga čini revolucionarnim

HelixTrack Core tretira dozvole kao prvu klasu, zamenjiv motor. Implementira **kontekst bazirane hijerarhijske dozvole** sa nasleđivanjem, a implementacija dozvola je uključiva — možete je pokrenuti lokalno unutar servisa ili delegirati na spoljni HTTP autorizacioni servis. Ta separacija omogućava organizacijama da umetnu praćivač u postojeću infrastrukturu identiteta i politike umesto da se bore sa ugrađenim modelom.

Takođe čini nešto što većina praćivača ignoriše: **automatsko otkrivanje servisa**. Klijenti nalaze Core servere na lokalnoj mreži preko UDP broadcast-a, tako da multi-platform klijenti (web, desktop, Android, iOS) mogu da se konektuju bez ručne konfiguracije. Kombinovano sa JWT autentikacijom, proširenjem sistema za praćenje vremena, Dokumenta i Četa, i Git integracijom koja mapira komite na tikete, ponaša se kao platforma umesto kao jedan aplikacija.

## Kako sam rešio najteže delove

Za API, rano sam se obavezao na **akcioni rutirajući obrazac**. Svaka operacija teče kroz isti `/do` životni ciklus — autentikacija i middleware dozvola, zatim handler ključan po akciji. Zbog toga sistem može da nastavi dodavanje mogućnosti (Faza 1 prioriteti i rešavanja, Faza 2 epici i radni logovi, Faza 3 glasanje i sheme obaveštenja, Faza 4 paralelno uređivanje) bez fragmentacije API-ja. Nove funkcije registruju nove akcije; transport i middleware ostaju konstantni.

Za konkurentno uređivanje, implementirao sam **optimistično zaključavanje sa verzijom sukoba** plus kompletni sloj istorije promena. Svaka urediva entitet nosi verziju; upis koji cilja na zastarelu verziju je odbijen sa sukobom koji klijent može da reši, a istorija tabela (dodata u V4 shemi) snima kompletnu stazu promena. Dodao sam eksplicitno upravljanje zaključavanjem entiteta i akcije za rešavanje sukoba na vrhu, i spojio ceo sistem u postojeći WebSocket sloj tako da saradnici vide ažuriranja u realnom vremenu. Ovo daje stvarno vremensku saradnju bez tihih prekrivanja nekog drugog uređivanja.

Za tenziju između šifrovanja i brzine, dizajn se oslanja na SQLCipher za transparentno AES-256 na nivou skladištenja dok se vrući putevi šalju kroz keširanje, tako da se česti čitanja ostanu brza čak i sa šifrovanom trgovinom ispod. Kodna baza je podržana velikim automatskim testnim setom — više od hiljadu testova preko faza — što mi omogućava da napravim promene u shemi od preko devedeset tabela i šifrovanoj, multi-bazi podataka, konkurentno uređivanoj sistemu i još uvek da verujem da se ponašanje zadržava. Arhitektonske dijagrame, korisnički priručnik i vodič za implementaciju isporučuju se uz kod, jer JIRA alternativa koju niko ne može da operiše nije alternativa uopšte.
