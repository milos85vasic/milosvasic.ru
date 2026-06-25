---
title: HelixCode
slug: helix-code
repo: https://github.com/HelixDevelopment/HelixCode
tech: Go, PostgreSQL, Redis, SSH, MCP, WebSocket, Gin
teaser: "A distributed AI coding agent that splits work across an SSH worker network, checkpoints everything, and never loses progress on a crash."
---

## Uvod

Šta ako vaš AI agent za kodiranje ne radi na jednom računaru, već preko mreže radnika koje sam obezbeđuje — deli veliki zadatak na delove, raspoređuje ih, i beleži napredak tokom puta tako da pad sistema nikada ne dovede do gubitka posla? To je HelixCode: preduzetnička platforma za distribuirani razvoj veštačke inteligencije pisana u Go-u, sa bazenom radnika zasnovanim na SSH-u, automatskim čuvanjem stanja, vraćanjem na prethodnu verziju i integracijom više provajdera LLM-a.

## Zašto je fascinantno

Većina „AI agenata za kodiranje" su pojedinačni procesi koji komuniciraju sa jednim modelom. HelixCode je izgrađen na ideji da je pravi razvojni posao deljiv i raspodeljiv. On sprovodi **inteligentnu podelu zadataka** uz upravljanje zavisnostima, a zatim čuva rad kroz automatsko beleženje stanja kako bi dugotrajni posao preživeo prekid. Platforma se izlaže kroz četiri klijentska interfejsa — REST API, CLI, terminalski interfejs i WebSocket — i implementira **Model Context Protocol (MCP)** sa podrškom za više transportnih protokola, čime se integriše u širi ekosistem alata za agente.

Takođe je zaista višeplatformski u neuobičajeno širokom smislu: Linux, macOS, Windows, plus Aurora OS i SymphonyOS, sa okvirima pripremljenim za iOS i Android. Repozitorijum obuhvata Go u svom jezgru, uz Shell, Kotlin, Swift i veb-resurse oko njega — oblik platforme namenjene da se upravlja sa bilo kog mesta.

## Teški problemi

Odlučujući izazov je **distribucija bez krhkosti**. Čim podelite koderski zadatak na udaljene radnike, nasleđujete sve teške probleme distribuiranih sistema: kako podeliti posao po stvarnim granicama zavisnosti, kako pratiti koji radnik poseduje koji deo, kako se oporaviti kada radnik nestane usred zadatka i kako spojiti rezultate na koherentan način.

Upravljanje radnicima je poseban problem. HelixCode ne pretpostavlja unapred izgrađen klaster — nudi **bazen radnika preko SSH-a sa automatskom instalacijom**, što znači da mora da pristupi udaljenom hostu, tamo se samostalno podesi, registruje radnika i prati njegovo stanje, sve sigurno preko SSH-a. Postizanje pouzdanog pokretanja na heterogenim mašinama mnogo je teže nego što zvuči.

Zatim dolazi sloj LLM-a. Podrška za više provajdera iza jednog interfejsa, detekcija hardvera (CPU/GPU/memorija) kako bi se inteligentno birali modeli, i dodavanje naprednog rezonovanja — lanac misli i stablo misli — znači da agent mora da razmišlja o *gde* i *sa čim* radi, a ne samo *šta* da generiše.

## Šta ga čini revolucionarnim

Kombinacija **očuvanja rada i vraćanja na prethodnu verziju** je ono što ga izdvaja. AI agent koji može da nastavi tačno od mesta gde je stao i da poništi lošu promenu pretvara duge autonomne izvršavanja iz kockanja u nešto što se može kontrolisati. HelixCode to spaja sa punim režimima razvojnog toka — planiranje, izgradnja, testiranje i refaktorisanje — podržanim bazama podataka i praćenjem konteksta kroz više sesija. Nije samo „generiši kod"; to je ceo životni ciklus.

Implementacija MCP-a takođe je važna. Govoreći Model Context Protocol sa više transportnih kanala, HelixCode može da deluje i kao potrošač i kao učesnik u svetu alata za agente, a višestruke obaveštenja (Slack, Discord, Email, Telegram) znače da distribuirano izvršavanje može da prijavljuje napredak tamo gde ljudi stvarno prate.

## Kako sam rešio najteže delove

Sistem sam strukturirao kao čiste unutrašnje module — autentifikaciju i upravljanje sesijama, upravljanje bazenom radnika, upravljanje zadacima i beleženje stanja, upravljanje projektima i tokovima rada, i integraciju provajdera LLM-a — pri čemu svaki živi u svom paketu. Ta podela je ono što čini distribuirano ponašanje razumljivim: podela zadataka i beleženje stanja su stvari o kojima mogu da razmišljam nezavisno od toga koji provajder LLM-a ili koji transportni protokol je u pitanju.

Za mrežu radnika, izgradio sam **bazen radnika preko SSH-a koji se samostalno instalira**. Umesto da zahteva od operatera da unapred pripreme svaki čvor, platforma se povezuje preko SSH-a, instalira ono što joj treba, registruje radnika, a zatim kontinuirano prati njegovo stanje. Praćenje stanja vraća se u upravljanje zadacima kako bi se posao mogao preusmeriti kada čvor počne da otkazuje.

Za otpornost, **beleženje stanja je kičma**. Upravljanje zadacima beleži kontrolne tačke kako posao napreduje, tako da prekinuti posao nastavlja od poslednjeg dobrog stanja umesto da se ponovo pokreće, a vraćanje na prethodnu verziju može da poništi loš korak. To je mehanizam koji duge, distribuirane, autonomne izvršavanja čini bezbednim za pokušaj.

Za sloj modela, svaki provajder sam stavio iza **ujednačenog interfejsa provajdera** i dodao detekciju hardvera kako bi agent prilagodio izbor modela mašini na kojoj stvarno radi. Povrh tog interfejsa složio sam pozivanje alata i rezonovanje u vidu lanca misli i stabla misli, tako da poboljšanje strategije rezonovanja ne zahteva menjanje infrastrukture provajdera. Sloj za perzistenciju je PostgreSQL sa opcionim Redisom, koji čuva projekte, sesije i stanje toka rada trajno kroz celu distribuiranu mrežu — razlika između pametne demonstracije i platforme koju stvarno možete da koristite.
