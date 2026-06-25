---
title: Android Toolkit
slug: android-toolkit
repo: https://github.com/vasic-digital/Android-Toolkit
tech: Kotlin
teaser: "The reusable foundation under my Android apps — drop-in modules from root shells to interprocess comms, added as one git submodule."
---
## Kuka

Svaki ozbiljan Android developer nakupi isti komad "već sam ovo napisao" koda: razuman okvir za testiranje, fasada za logovanje, pomoćnici za pristup root-u, cevovod za međuprostor, kružni ImageView, brzi alfabetski prečicač. Android Toolkit je taj komad, rafiniran u čistu, modularnu biblioteku — zajednički korišćeni set apstrakcija, implementacija i alata koje možete dodati u projekt pomoću `git submodule add` i odmah početi koristiti. To je neglamurozna osnova koja omogućava stvaranje glamuroznih aplikacija.

## Zašto je fascinirajuće

Fascinirajući deo je arhitektura *uzdržanosti*. Toolkit je podeljen u usmerene, nezavisno-uključive module — `Main`, `Test`, `Echo`, `Access`, `JCommons`, `RootTools`, `RootShell`, `Interprocess`, `CircleImageView`, `ConnectionIndicator`, `FastscrollerAlphabet` — i vi uključujete samo one koje vam trebaju preko `settings.gradle` i `build.gradle`. Nema monolita, nema vučenja cele kuhinje da biste dobili jedan pomoćnik. Ta granularnost je stvarni dizajnerski izbor: svaki modul zauzima svoje mesto na svoj način.

Takođe je isporučen kao git submodule umesto objavljenog artefakta, što vam govori šta je to za. Ovo je zajednički kičma preko portfolio-a Android radova jedne osobe — konzistentna osnovna sloj koji čuva više aplikacija da se ponašaju isto, evoluiraju u zaključavanju, bez copy-paste drift-a između projekata. Moduli obuhvataju neobično širok raspon, od niskonivelnog pristupa sistemu (root shell-i i alati) do međuprostorne komunikacije do gotovih UI vidžeta, što znači da isti Toolkit može služiti i kao sistem aplikacija za moćne korisnike i kao polirana potrošačka UI.

## Teški problemi

Prvi teški problem je ugovor o modularnosti. Da bi sistem modula à-la-kart funkcionišao, granice moraju biti iskrene — `RootShell` i `RootTools` ne mogu tajno zavisiti od UI vidžeta; `Interprocess` ne može vući testni okvir. Dizajniranje modula koji su stvarno nezavisni, a komponuju se čisto preko Gradlea, je teže nego izgradnja jedne velike biblioteke, jer svaka šav je obaveza.

Drugi je opasni ugao Android-a. Pristup root-u (`RootShell`, `RootTools`) i međuprostorna komunikacija (`Interprocess`) su tačno one oblasti gde se greške pretvaraju u sigurnosne rupe ili prekidakaju aplikacije. Omotavanje privilegovanih shell-ova i IPC-a u apstrakcije koje su bezbedne i ergonomične — lako koristiti ispravno, teško koristiti katastrofalno — je vrsta rada koja se ne vidi na screenshot-u, ali određuje da li su aplikacije iznad pouzdane.

Treći je biti osnova preko više projekata istovremeno. Toolkit koji se konzumira od strane više aplikacija preko submodule-a mora da evoluira pažljivo: promena u zajedničkoj apstrakciji se širi svuda. Zato Toolkit isporučuje posvećeni `Test` modul i žice test zavisnosti (`testImplementation`, `androidTestImplementation`) kao prvu brigu — osnova mora biti testirana, a aplikacije izgrađene na njoj moraju biti testirane kroz nju.

## Šta ga čini revolucionarnim

Revolucionarni deo je poluga. Ponovno upotrebljiva infrastruktura kao ova je ono što omogućava jednom inženjeru da održava celu porodicu Android aplikacija — ShareConnect ekosistem, Yole i više — bez ponovnog izgradnje osnova svaki put. Toolkit pretvara "zajedničke Android probleme" u rešene, zajedničke, verzije-kontrolirane module, tako da svaka nova aplikacija počinje sa višeg sprata i nasleđuje konzistentnost u logovanju, testiranju, pristupu sistemu i UI primitivima po default-u.

Model isporuke submodule-a pojačava to: poboljšanja napravljena tokom izgradnje jedne aplikacije se vraćaju u Toolkit i odmah koriste ostale. To je kompozitna investicija — osnova postaje jača svaki put kada se koristi.

## Kako sam rešio najteže delove

Dizajnirao sam za opt-in od prve linije. Podelivši Toolkit u usko-obuhvaćene Gradle module i dokumentovao da uključujete *samo* ono što vam treba, učinio sam biblioteku aditivnom umesto nameću — projekt vuče `RootShell` i `Interprocess` bez nasleđivanja UI vidžeta koji će se nikad renderovati. Čuvanje liste modula eksplicitno u `settings.gradle` čini površinu zavisnosti vidljivom i namerno umesto magije.

Za opasne uglove, izolovao sam privilegije i IPC u svoje module — `RootShell`/`RootTools` za pristup root-u, `Interprocess` za međuprostornu komunikaciju — tako da rizik cod živio iza namernog granice koje morate preći, a ne nečega što curi u svaki potrošač po default-u. Ta izolacija je ono što čini ostatak Toolkit-a bezbednim za zavisnost u širim granicama.

I tretirao sam testiranje kao deo osnove, a ne kao naknadno dodato: isporučivanje `Test` modula i standard `testImplementation`/`androidTestImplementation` žica znači da svaka aplikacija izgrađena na Toolkit-u dobija konzistentan testni setup iz kutije, a promene u zajedničkim apstrakcijama mogu biti validirane pre nego što se šire preko portfolio-a. Celina stvar se isporučuje kao submodule tačno zato što osnova i aplikacije koje stoje na njoj mogu napredovati zajedno — jedna osnova, više proizvoda, bez drift-a.
