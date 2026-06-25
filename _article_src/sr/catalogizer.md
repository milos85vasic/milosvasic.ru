---
title: Catalogizer
slug: catalogizer
repo: https://github.com/vasic-digital/Catalogizer
tech: Go, Gin, React, TypeScript, SQLCipher, WebSocket, SMB/FTP/NFS/WebDAV
teaser: "Point it at your SMB, FTP, NFS, WebDAV and local shares — it auto-detects 50+ media types, survives disconnects, and stays encrypted."
---
## Kuka

Vaša medija živi svuda — na SMB deljenoj mrežnoj jedinici, na FTP kutiji, na NFS montaži, na WebDAV serveru, na lokalnom disku — i ništa ne razume sve to odjednom. Catalogizer razume. To je napredni multi-protokolni sistem za upravljanje kolekcijom medija koji automatski detektuje, kategorizuje i organizuje mediju preko svih tih protokola, prati ih u stvarnom vremenu, obogati sve sa spoljnim metapodacima i čuva ceo katalog u šifrovanoj bazi podataka.

## Zašto je fascinirajuće

Catalogizer tretira "vašu kolekciju" kao jedan logički biblioteku koji se prostire preko heterogenog skladišta. Identifikuje **50+ tipova medija** — filmove, TV emisije, muziku, igre, softver, dokumentarce i još mnogo toga — i kontinualno prati svaki izvor za promene, ažurira metapodatke automatski. Obogati unos iz širokog skupa spoljnih pružalaca (TMDB, IMDB, TVDB, MusicBrainz, Spotify, Steam i drugi), analizira kvalitet, prati verzije i prikazuje analitiku kao trendove rasta.

Stack je čist razdvojen: visoko-performansni Go REST API na Gin-u, moderni React/TypeScript front-end sa Tailwind-om i WebSocket integracijom tako da se korisnički interfejs ažurira u stvarnom vremenu kako se katalog menja. Ispod, podaci se nalaze u **SQLCipher-šifrovanoj** trgovini. Čak ide dalje od katalogizacije sa praktičnim dodacima — servisom za konverziju u PDF, izvozom i uvozom favorita u JSON i CSV, sinhronizacijom sa oblakom na S3 i Google Cloud Storage i profesionalnim izveštajima u PDF-u sa grafikonima.

## Teški problemi

Najteži problem je **nepouzdana mrežna skladišta**. SMB i prijatelji padaju. Montaže nestaju. Naivni kataloger baca greške i kvari svoj pogled na svet u trenutku kada deljena mrežna jedinica ode van mreže. Catalogizer je izgrađen za **protokolnu otpornost**: rukuje privremenim prekidima veze elegantno, ponovno se spaja automatski i kešira za rad u vanmrežnom režimu, tako da nestabilna mrežna jedinica ne uništi ceo sistem. Dizajniranje za slučaj neuspeha kao normalan slučaj — umesto izuzetka — je definisanje inženjerske odluke ovde.

Drugi problem je **jedan apstrakt iznad veoma različitih protokola**. SMB, FTP, NFS, WebDAV i lokalni fajl sistem svaki imaju svoje sopstvene semantike, manje i režime neuspeha. Prezentovanje njih kroz jedan konzistentan fajl-sistem klijent interfejs — uključujući i potpuno NFS montažu i fajl operacije na macOS-u — tako da detekcioni engine i monitor mogu tretirati njih uniformno je znatan integritetski napor.

Treći je **detekcija u velikom obimu sa bezbednošću**. Prepoznavanje 50+ tipova medija pouzdano, obogati iz mnogih spoljnih API-ja i činjenje svega toga preko šifrovane baze podataka sa JWT-temeljnim pristupom uloga — bez šifrovanja ili API poziva postaju bottleneck — zahteva namerno arhitekturu.

## Šta ga čini revolucionarnim

Većina menadžera medija pretpostavlja da su vaši fajlovi lokalni i da je vaša mreža savršena. Catalogizer pretpostavlja suprotno i još uvek funkcionira. Kombinacija **multi-protokolskog dosega plus otpornosti plus praćenja u stvarnom vremenu** znači da upravlja distribuiranom, delimično dostupnom kolekcijom kao da je to jedna uredna biblioteka — i održava je aktuelnom automatski umesto ručnog pretraživanja.

Složi na to šifrovanje po defaultu, kontrolu pristupa ulogama, obogaćivanje spoljnim metapodacima i stvarno korisne izlazne funkcije (izveštaji, izvoz, sinhronizacija sa oblakom, konverzija u PDF), i prestaje biti katalog i postaje platforma za upravljanje medijom koji se događa da bude rasut preko protokola i mašina.

## Kako sam rešio najteže delove

Učinio sam **otpornost svojstvom sloja za skladištenje**, a ne nečim što svaka funkcija mora da rukuje. Multi-protokolski fajl-sistem klijenti su odgovorni za detekciju prekida veze, ponovno spajanje automatski i služenje iz keša kada je izvor nedostupan. Zbog toga što se to ponašanje nalazi u klijent apstrakciji, engine za praćenje i detekciju iznad njega može pretpostaviti da je izvor uvek dostupan — grimy stvarnost padajuće SMB montaže je apsorbovana ispod njih.

Da bih ukrotio raznolikost protokola, ujedinio sam SMB, FTP, NFS, WebDAV i lokalni pristup iza jedne **fajl-sistem klijent interfejsa** sa monitoringom po protokolu, uključujući i stvarno NFS montažu i fajl operacije za macOS. Engine za detekciju medija sedi na vrhu tog jedinog interfejsa, tako da dodavanje protokola ili popravka jedne protokolne manje ne utiče na logiku detekcije.

Za live ponašanje, Go API pokreće **WebSocket server** koji šalje ažuriranja React front-end-u u trenutku kada se katalog menja, tako da ono što korisnici vide odražava praćene izvore u stvarnom vremenu umesto zastarelog snimka. I zadržao sam bezbednost kao neophodnu: baza podataka je SQLCipher-šifrovana i API je kontrolisan JWT-om sa kontrolom pristupa ulogama, tako da sistem koji doseže u mnoge udaljene deljene mrežne jedinice i spoljne API-je ne postane najslabija karika. Rezultat je menadžer medija dizajniran oko sveta kao što on zaista jeste — distribuiran, prekidni i u potrebi da bude održan iskrenim i bezbednim.
