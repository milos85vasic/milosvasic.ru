---
title: Panoptic
slug: panoptic
repo: https://github.com/vasic-digital/Panoptic
tech: Go
teaser: "One Go framework that drives, screenshots, and screen-records web, desktop, iOS and Android — the all-seeing eye for UI automation."
---

## Uvod

Automatizacija korisničkog interfejsa je rascepkana. Učiš Selenium ili Playwright za veb, Appium i XCUITest za mobilne uređaje, nešto sasvim drugo za desktop, a poseban snimač ako želiš video onoga što se dogodilo. Svaka granica je novi alat, nova apstrakcija, novi način da stvari budu nestabilne. Panoptic – nazvan po svevidećem oku – sve to sabija u jedan Go okvir koji automatizuje, pravi snimke ekrana i snima sesije na vebu, desktopu i mobilnim uređajima uz jedan programski model.

## Zašto je fascinantno

Ono što Panoptic čini ubedljivim jeste to što tretira „posmatranje šta softver radi" kao prvoklasnu mogućnost, ravnopravnu sa „upravljanjem softverom". Ne samo da klikće na dugmad; hvata visokokvalitetne snimke ekrana sa vremenskim žigovima i snima video cele sesije u više formata. To znači da jedan testni prolaz može da proizvede i tvrdnje i vizuelne dokaze – snimanje nije naknadno dodato, već je deo okvira.

Zaista je sveobuhvatan. Veb automatizacija pokriva Chrome, Firefox, Safari i Edge. Mobilni uređaji obuhvataju automatizaciju iOS i Android aplikacija sa snimanjem ekrana. Desktop dobija automatizaciju korisničkog interfejsa i snimanje ekrana. Sve je to izloženo kroz čist Go API – `web.NewBrowser()`, `browser.Navigate(...)`, `browser.Screenshot(...)`, prilagođeni CSS i XPath selektori, eksplicitne strategije čekanja – plus CLI za uobičajene slučajeve (`panoptic record --platform ios --device iPhone13 --output mobile_demo.mp4`). Činjenica da isti konceptualni API pokriva sve, od headless Chrome pregledača do snimljene iOS sesije, upravo je poenta.

## Teški problemi

Prvi težak problem je što „element" znači nešto drugo na svakoj platformi. Veb dugme je DOM čvor do kog se dolazi putem CSS-a ili XPath-a. iOS kontrola živi u stablu pristupačnosti. Desktop widget je OS-nativni handle. Panoptic mora da pruži ujedinjeni model otkrivanja i interakcije sa elementima, dok ispod haube govori četiri potpuno različita „dijalekta" za „pronađi ovu stvar i dodirni je".

Drugi problem je vremensko usklađivanje. Korisnički interfejs je svugde asinhron, ali na različite načine. Panoptic nudi eksplicitne strategije čekanja – `WaitForElement` sa vremenskim ograničenjem i `WaitForCondition` koji proverava proizvoljan predikat sve dok ne postane tačan – jer fiksno odlaganje je glavni izvor nestabilne automatizacije. Projektovanje primitiva za čekanje koji se ponašaju identično, bilo da čekaju da `div.loading` nestane ili da se prikaže nativni prikaz, zahteva fin rad.

Treći problem je snimanje tokom upravljanja. Hvatanje video zapisa od 30 fps visokog kvaliteta, sa prilagodljivim viewportom, a da se ne poremeti vremensko usklađivanje automatizacije koju snimate, pravi je izazov u performansama i sinhronizaciji – naročito na mobilnim uređajima, gde snimate ekran uređaja ili simulatora, a ne samo platno koje kontrolišete.

## Šta ga čini revolucionarnim

Revolucionarna stvar je konsolidacija sa dokazima. Kada automatizacija postoji u jednom okviru na svim platformama, tim piše jedan mentalni model umesto četiri, i dobija vizuelne dokaze besplatno. Nestabilan test prestaje da bude stek trejs u koji zurite – postaje video koji gledate. Samo to menja način na koji timovi razrešavaju greške.

Takođe je napravljen da se uklopi u pipeline-ove: proširiva arhitektura plugina, hook-ovi pre i posle za podešavanje i čišćenje, YAML konfiguracija za pregledač, snimanje i mobilne postavke po platformi, kao i eksplicitna integracija sa CI/CD. Isti set možete da povežete u CI kao i lokalno, a artefakti – snimci ekrana i MP4 fajlovi – upravo su ono što želite da prikačite uz neuspešnu izgradnju.

## Kako sam rešio najteže delove

Namerno sam izabrao Go. Automatizacija na više platformi je, ispod haube, mnogo konkurentnog I/O-a – komunikacija sa drajverima pregledača, mostovima za uređaje (ADB za Android, Xcode alati za iOS) i enkoderom za snimanje – sve odjednom. Go-ove gorutine i kanali čine orkestriranje „upravljaj UI-jem na ovoj gorutini, prikupljaj frejmove ekrana na onoj, prati uslov čekanja na trećoj" izvodljivim i brzim, a statički binarni fajl čini CLI jednostavnim za distribuciju u CI.

Da bih ujedinio četiri modela elemenata, naterao sam drajvere platformi da implementiraju zajednički interfejs za interakciju i zadržao selektore izražajnim, a ne na najnižem zajedničkom imenitelju – CSS i XPath na vebu, nativne lokatore na mobilnim i desktop platformama – tako da apstrakcija nikada ne košta preciznost selektora koji vam zaista treba. Primitivi za čekanje su izgrađeni na tom interfejsu, zbog čega `WaitForCondition` radi identično bez obzira na platformu koju predikat ispituje.

Za snimanje bez izobličenja, tretirao sam hvatanje kao zaseban pipeline nezavisno konfigurisan (format, kvalitet, fps u `panoptic.yaml`), tako da snimač radi paralelno sa automatizacijom, a ne unutar njenog kritičnog puta. I sve sam to učinio proširivim od samog početka putem hook-ova i sistema plugina, jer jedina sigurnost u automatizaciji jeste da će neko morati da uradi nešto što nisam predvideo – a okvir bi trebalo da im to omogući, umesto da ih primora na forkiranje.
