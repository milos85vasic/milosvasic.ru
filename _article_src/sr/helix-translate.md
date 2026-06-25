---
title: HelixTranslate
slug: helix-translate
repo: https://github.com/HelixDevelopment/HelixTranslate
tech: Go, HTTP/3, WebSocket, REST, SSH, LLM providers
teaser: "Translate an entire ebook into any language — over a verified-best LLM, streamed live over WebSocket, with no silent local fallbacks."
---
## Kuka

Dajte mu knjigu u bilo kom formatu, nazovite ciljni jezik, i HelixTranslate će prevesti sve — usmeravajući vaš tekst na najjači *verifikovani* LLM dostupan, strimujući napredak na živo na dashboard, i odbijajući da ćuti degradira kvalitet iza vaših leđa. To je visokoperformansni, preduzećni univerzalni alat za prevod e-knjiga sa REST API-om, podrškom za HTTP/3 i real-time WebSocket događajima.

## Zašto je fascinirajuće

Alati za prevod obično vas prisiljavaju da izaberete pružaoca i nadate se da će biti dovoljno dobar danas. HelixTranslate okreće to. Njegova defaultna putanja je **bridge-izabrana**: on izvori najjači verifikovani API model — plus lanac za povratni poziv poređan po rezultatima — automatski, preko integracije sa mojim projektom LLMsVerifier. Vi ne biračete pružaoca; sistem bira najboljeg koji je trenutno dokazano da radi, i pada na rangiranu listu ako prvi izbor ne uspe.

Okolo tog jezgre se nalazi potpuni **sistem za praćenje u realnom vremenu**: WebSocket centar strimuje živo napredak, događaje i greške na web dashboard, podržava više simultanih sesija prevoda sa jedinstvenim ID-jevima, i rukuje multi-klijentskim vezama sa automatskom ponovnom vezom. Možete gledati kako se duga knjiga prevodi pasus po pasusu umesto da gledate blokiran terminal. On komunicira sa mnogim pružaocima — OpenAI, Anthropic, DeepSeek, Zhipu, Qwen, Gemini i više — svi su dosežni preko verifikovane otkrivanja.

## Teški problemi

Prvi teški problem je **iskrenost pod neuspehom**. Lako je reći da se, kada API ključ nedostaje ili pružalac ne uspe, tiho prebaciti na slab lokalni model i lažirati da sve funkcioniše. To proizvodi loše prevode koji izgledaju uspešno. Ja sam napravio suprotno kao tvrdi pravilo: bez postavljenog API ključa pružaoca, most vraća iskrenu grešku — nikada nema tihi lokalni povratni poziv. Namećući to konzistentno širom cijelog pipeline-a je dizajnerski zahtjev, a ne jedan linija provere.

Drugi je **distribuirani prevod preko SSH**. Velike knjige su spore za prevoditi serijski, pa sistem podržava remote SSH radnike — spajajući se sigurno, šaljući rad prevoda, praćenjem napretka sa remote strane, i rukujući greškama i povratnim pozivom. Koordinacija remote radnika, a još uvek emitovanje koherentnih događaja u realnom vremenu na dashboard, je vrsta integracije koja se lomi na stotinu mali načina.

Treći je **dogadjaji u realnom vremenu urađeni ispravno**. Strimovanje živog napretka za više konkurantnih sesija na više klijenata dashboard-a — sa ponovnom vezom, istorijom sesije i praćenjem po sesiji — je pravi WebSocket-arhitektonski problem, a ne samo progress bar.

## Šta ga čini revolucionarnim

Strategija verifikovanog najboljeg modela je ideja vrijedna krađe. Umjesto da se oslanja na statični izbor pružaoca, HelixTranslate kontinuirano se oslanja na vanjsku verifikaciju da se usmjeri na ono što je *zaista* funkcionisalo, sa determinističkim lancom povratnog poziva kada nije. To pretvara "koji LLM treba koristiti za prevod?" iz pitanja u mjereno, automatsko odluku — i znači da alat postaje bolji kako se podrazumeva model krajolika menja, bez promjena u kodu.

Također je namjerno ograničen. U jednom trenutku projekt je podržavao lokalne pružaoce i SSH-lokalni put; u kasnijoj fazi mosta sam **uklonio** lokalne pružaoce (Ollama, LlamaCpp) i SSH-lokalni put prevoda potpuno. Odabir njih sada vraća iskrenu "više nije podržano" grešku umesto da pokreće slabiji lokalni model. To je isti princip iskrenosti primijenjen na putu: ja bih radije prekinuo put nego da dopuštam da proizvodi tiho lošije izlazne podatke.

## Kako sam riješio najteže dijelove

Arhitektonska ključna komponenta je **bridge paket** (`pkg/bridge`) koji povezuje prevod sa LLMsVerifier. Umjesto da se hardkodiraju preferencije pružaoca, prevodilac pita most za najjači verifikovani model i rangiran lanac povratnog poziva, zatim prevodi protiv toga. To je ono što čini "ne morate birati pružaoca" istinitim u praksi, i to je gdje se primjenjuje pravilo bez tihih povratnih poziva — most vraća eksplicitnu grešku umjesto da zamjeni lokalni model.

Za praćenje u realnom vremenu sam razdvojio brige u posvećene pakete: `websocket` centar koji upravlja vezom i broadcastom, sistem `events` koji definira i emituje tok događaja, i paket `sshworker` za remote izvršenje. Samostalni monitor server konzumira WebSocket tok i upravlja dashboard-om, tako da su prevod i praćenje odvajeni — CLI emituje događaje, server ih širi, i bilo koji broj klijenata dashboard-a se pretplaćuje sa automatskom ponovnom vezom.

Za distribuciju, sloj SSH radnika upravlja sigurnom vezom i remote izvršenjem, prijavljujući napredak nazad kroz isti sistem događaja, tako da remote prevod izgleda identično kao lokalni sa stanovišta dashboard-a. Cela stvar je izložena preko REST API-ja sa podrškom za HTTP/3 i podržana sa sveobuhvataćim WebSocket testnim setom za praćenje — jer sistem prevoda koji se ne može promatrati je sistem prevoda koji se ne može vjerovati.
