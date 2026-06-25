---
title: GrabTube
slug: grab-tube
repo: https://github.com/vasic-digital/GrabTube
tech: Dart/Flutter
teaser: "One yt-dlp backend, five native clients — download from 1000+ sites on web, Android, iOS, Windows, macOS and Linux, even by scanning a QR code."
---

## Mamac

`yt-dlp` je najsposobniji program za preuzimanje videa na svetu, ali je komandna linija. Za većinu ljudi to je prepreka. GrabTube srušava tu prepreku: obavija taj backend u dotjeranu, multiplatformsku aplikaciju tako da svako može da preuzima sa YouTube-a i preko hiljadu drugih sajtova uz izbor kvaliteta, formata i praćenje napretka uživo – a na mobilnom, dovoljno je usmeriti kameru na QR kod i preuzimanje počinje. To je univerzalni program za preuzimanje sa servisa poput Tube-a, sa modernim korisničkim interfejsom i iskustvom, od početka do kraja.

## Zašto je fascinantno

Arhitektura je ono što privlači. GrabTube je jedan moćan backend koji napaja više klijenata. Originalni veb interfejs je u Pythonu (aiohttp) uparen sa Angular 19. Zatim postoji Flutter 3.24+ klijent napisan u Dartu koji se *nativno* isporučuje za Android, iOS, Windows, macOS i Linux iz jednog izvornog koda. Svaki klijent – i veb i Flutter – komunicira sa istim yt-dlp pogonom. Tako se složena logika preuzimanja nalazi na tačno jednom mestu, a korisničko iskustvo prilagođava se uređaju koji držite u ruci.

Flutter klijent je ono gde stvar postaje zaista zanimljiva. Omogućava preuzimanje u pozadini sa obaveštenjima, oflajn red, Material Design 3 sa adaptivnim temama, nativne performanse na svakoj platformi i skeniranje QR kodova uz integraciju kamere – tako da link sa ekrana postaje preuzimanje u jednom potezu. Ima CI/CD pipeline i preko 80% pokrivenosti testovima uz validaciju pomoću veštačke inteligencije – retka doteranost za program za preuzimanje. Takođe se integriše sa ekosistemom ShareConnect za univerzalno deljenje linkova i sinhronizovane redove i istoriju na svim uređajima.

## Teški problemi

Prvi težak problem je što preuzimanje sa „preko 1000 sajtova" po prirodi stvari predstavlja pokretnu metu. Izgled sajtova se menja, formati se množe, ekstrahovanje otkazuje. GrabTubeovo rešenje je arhitektonska skromnost: ne implementira ekstrahovanje ponovo, već se oslanja na yt-dlp i usredsređuje svoj trud na sve *oko* preuzimanja – redanje, praćenje napretka, pregovaranje o formatu i prezentaciju.

Drugi problem je pravi multiplatformski pristup iz jednog Dart koda. „Piši jednom, pokreni svuda" je lako reći, ali brutalno u detaljima: izvršavanje u pozadini i obaveštenja funkcionišu potpuno drugačije na Androidu, iOS-u i svakom desktop OS-u; pristup kameri/QR-u ima različite modele dozvola na svakoj platformi; skladištenje fajlova i semantika preuzimanja se razlikuju svuda. Dostizanje nativnih performansi sa jednim Flutter kodom na pet platformi znači apsorbovati sve to ispod čistog korisničkog interfejsa.

Treći problem je ugovor sa backendom. Sa više heterogenih klijenata (Angular veb aplikacija i Flutter aplikacija) koji pristupaju jednom aiohttp servisu, API mora biti stabilna spojnica – napredak u realnom vremenu, stanje reda i istorija moraju da teku čisto do svakog klijenta, bez obzira na to kako ih taj klijent prikazuje.

## Šta ga čini revolucionarnim

Revolucionarno je doseg bez prepravki. Većina alata za preuzimanje bira jednu stazu – veb interfejs, desktop aplikaciju ili mobilnu aplikaciju. GrabTube odbija da bira: ista funkcionalnost pojavljuje se kao veb interfejs, nativna mobilna aplikacija i nativna desktop aplikacija, sve podržano istim pogonom. Dodajte tok skeniranja QR kodova i sinhronizaciju između uređaja preko ShareConnect-a, i preuzimanje prestaje da bude zadatak vezan za uređaj i postaje nešto fluidno što vas prati sa ekrana laptopa do telefona u džepu.

Takođe je podignut na standard koji većina alata nikada ne dosegne. Flutter klijent spreman za produkciju sa preko 80% pokrivenosti testovima, validacijom uz pomoć veštačke inteligencije i automatizovanim CI/CD pipeline-om znači da se GrabTube ponaša kao održavan softver, a ne kao skripta za vikend koja truli sledeći put kada se sajt promeni.

## Kako sam rešio najteže delove

Osnovna odluka bila je da yt-dlp bude jedini izvor istine za preuzimanje i da se nikada ne borim protiv njega. Tretirajući ekstrahovanje kao rešen problem koji pripada backendu, oslobodio sam svaki klijent da se usredsredi isključivo na iskustvo – i učinio projekat otpornim, jer kada se sajt promeni, rešenje dolazi iz izvora, a ne je rasuto po pet korisničkih interfejsa.

Za multiplatformski pristup, opredelio sam se za Flutter i Dart kako bi jedan kod mogao da se nativno pokreće na Androidu, iOS-u, Windowsu, macOS-u i Linuxu, a zatim rešavao zaista platformski specifične stvari – preuzimanje u pozadini sa obaveštenjima, oflajn red, skeniranje QR kodova preko kamere, adaptivne teme Material Design 3 – kao namerno nativne integracije, umesto da pretvaram da su platforme iste. To je razlika između Flutter aplikacije koja *radi* svuda i one koja se *oseća* nativno svuda.

Zadržao sam aiohttp backend kao čist, klijent-agnostički API kako bi Angular veb klijent i Flutter klijent mogli da se razvijaju nezavisno, a da dele identično ponašanje pri preuzimanju, napredak u realnom vremenu i istoriju. Takođe sam povezao GrabTube sa ekosistemom ShareConnect tako da link podeljen na jednom uređaju ulazi u sinhronizovani red na drugom – pretvarajući program za preuzimanje u deo povezanog, multiuređajskog toka rada. Na kraju, zadržao sam Flutter klijent na preko 80% pokrivenosti testovima uz validaciju pomoću veštačke inteligencije i CI/CD pipeline, jer alat na koji se ljudi oslanjaju da preuzmu svoje medije treba da bude testiran kao takav.
