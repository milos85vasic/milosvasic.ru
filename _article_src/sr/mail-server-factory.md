---
title: Mail Server Factory
slug: mail-server-factory
repo: https://github.com/Server-Factory/Mail-Server-Factory
tech: Shell/Go
teaser: "Describe your mail server in one JSON file; it provisions a hardened, Dockerized stack on 25 Linux distros across 12 connection types."
---

## Mamac

Vođenje sopstvenog mail servera ima zasluženu reputaciju kao jedan od najmučnijih poslova u sistemskoj administraciji: SMTP, IMAP, POP3, TLS, DKIM, SPF, firewall-ovi, sertifikati, SELinux i desetak demona koji svi moraju da se slože ili ništa neće biti dostavljeno. *Mail Server Factory* nudi rešenje sa izuzetno direktnim pristupom — *„Vođi svoj mail server kao šef"*. Napišete jednostavan JSON fajl koji opisuje šta želite, a *Factory* ga interpretira i gradi vam čitav otporan, Dockerizovan stack na ciljnoj mašini.

## Zašto je to fascinantno

Fascinantna ideja je tretiranje deployovanja mail servera kao *problema kompajliranja*. JSON konfiguracija je izvorni kod; *Factory* je kompajler; a pokrenut, labavo povezan, Docker-baziran mail stack na ciljnom OS-u je rezultat. Pošto je svaka komponenta stacka labavo povezana i kontejnerizovana, dobija se čista osnova za kasnije skaliranje, umesto klupka ručno editovanih config fajlova koje se niko ne usuđuje da dodirne.

Ono što ovo premešta iz kategorije *„zanimljivo"* u *„ozbiljno"* jeste doseg. *Factory* može da isporuči taj stack preko 12 različitih vrsta konekcija — SSH, Docker, Kubernetes, AWS SSM, Azure Serial Console, GCP OS Login, Libvirt, custom protokol, baza podataka, fajl sistem, cloud provajder i container runtime. A cilja na 25 Linux distribucija, uključujući one koje većina alata potpuno ignoriše: zapadne standardne (Ubuntu, Debian, CentOS, Fedora, AlmaLinux, Rocky, openSUSE), ruske distribucije (ALT, Astra, ROSA) i kineske (openEuler, openKylin, Deepin). Taj opseg je namerna izjava: tvoj mail server, tvoj hardver, tvoja nadležnost.

## Teški problemi

Prvi težak problem je taj što *„ista instalacija"* nikada nije ista. Nazivi paketa, init sistemi, firewall interfejsi i ponašanje SELinux-a razlikuju se na 25 distribucija. *Factory* sadrži pravi sigurnosni okvir — `CertificateValidator`, `DockerCredentialsManager`, `SELinuxChecker`, `PasswordValidator` i `ConnectionPool` — upravo zato što svaki od tih aspekata ponaša se drugačije na svakoj platformi i ne može se pretpostaviti.

Drugi problem je sam sloj konekcije. Povezivanje sa ciljem preko SSH-a potpuno se razlikuje od povezivanja preko AWS SSM, Azure Serial Console ili Libvirt. Svaki transport ima svoj način autentifikacije, svoju latenciju i svoje načine otkaza. Apstrakcija svih 12 iza jedinstvenog instalacionog pipeline-a — tako da instalacioni koraci ne mare kako bajtovi stižu do mašine — predstavlja arhitektonsku kičmu projekta.

Treći problem je dobijanje čiste mašine na prvom mestu. *Factory* automatizuje neinteraktivnu instalaciju OS-a preko preseed, kickstart, cloud-init i autoyast na svim tim distribucijama, pokreće QEMU virtuelne mašine preko `scripts/qemu_manager.sh` i upravlja ISO slikama sa proverom checksum-a i preduzetničkim dodatkom: dvosmernim SMB kešom koji preuzima nedostajuće slike sa mrežnog dela, otprema nedostajuće nazad i pribegava internetskom preuzimanju samo kao poslednjem rešenju.

## Šta ga čini revolucionarnim

Revolucionarno je to što čini samostalno hostovanje maila *reproducibilnim i proverljivim*. Infrastruktura za e-poštu je upravo ona stvar koju želite da opišete kao podatke i ponovo izgradite identično, a ne da je sastavljate po sećanju u 2 ujutro. Sa stackom definisanim u JSON-u i sigurnosnim stavom koji nameće kod — AES-256-GCM enkripcija, obavezne SSH ključne fraze od najmanje 12 karaktera, automatska pravila firewall-a za portove 25/587/465/993/995, TLS sa validacijom sertifikata i HSTS, audit logovanje i RBAC — *„mail server za produkciju"* prestaje da bude višenedeljni projekat i postaje konfiguracija koju možete pregledati, verzionisati i ponovo pokrenuti.

Takođe je rigorozno validiran, a ne samo ambiciozan: projekat beleži 439 testova sa 100% prolaznosti, 100% SonarQube kvalitetni prag i kompletan testing framework koji proverava stvarno SMTP/IMAP/POP3 ponašanje na distribucijama, kao i merenja protoka i latencije. Za alat čiji je jedini posao da mu poverite svoj mail, te dokaze su zapravo funkcija.

## Kako sam rešio najteže delove

Razdvojio sam *šta izgraditi* od *kako doći do cilja* i *na kom OS-u smo*. JSON konfiguracija opisuje nameru; apstrakcija transporta skriva 12 vrsta konekcija iza jednog interfejsa tako da instalacioni koraci izvršavaju iste logičke operacije bez obzira da li teku preko SSH-a ili AWS SSM; a logika za svaku distribuciju je izolovana tako da matrica od 25 distribucija postoji na jednom mestu umesto da se prosipa kroz svaki korak. Ta slojevitost je razlog zašto dodavanje nove distribucije ili vrste konekcije ne izaziva talase kroz ceo kod.

Za sigurnost nisam ostavio ništa na dobroj volji operatera. Okvir nameće teške delove — *proverava* SELinux, *validira* sertifikate, *upravlja* Docker kredencijalima i *odbacuje* slabe lozinke i SSH ključeve bez fraze — tako da ispravna deployacija bude podrazumevana, a ne pažljivo postignut rezultat. Shell obavlja teško provisioniranje tamo gde je to pravi alat, sa Kotlin/JVM logikom za orkestraciju i sigurnosni okvir, dok Docker drži svaku komponentu labavo povezanu.

I rešio sam problem *„čiste mašine"* koji većina instalera ignoriše: neinteraktivne instalacije za svaku podržanu distribuciju, automatizacija QEMU-a za pokretanje testnih ciljeva i dvosmerni SMB keš za ISO slike tako da deployovanje na čitavom klasteru ne preuzima istu sliku dvadeset pet puta — sa proverom checksum-a za svaku sliku, bez obzira odakle je stigla. Rezultat je alat koji vas vodi od golog metala (ili prazne VM) sve do otpornog, testiranog, pokrenutog mail servera iz jednog fajla.
