---
title: LLMs Verifier
slug: llms-verifier
repo: https://github.com/vasic-digital/LLMsVerifier
tech: Go
teaser: "Before any LLM touches production, it has to prove it can actually see your code — across 12 providers, in real time."
---

## Uvod

Svaki tim koji se priključuje na „najnoviji model" tiho se oslanja na konfiguracionu datoteku. Naziv modela u vašem YAML fajlu kaže `gpt-4o` ili `claude-sonnet`, endpoint vraća status 200, i pretpostavljate da je ono s druge strane stvarno, funkcionalno i sposobno da obavi zadatak koji mu šaljete. *LLMs Verifier* postoji zato što je ta pretpostavka dovoljno često pogrešna da boli. To je platforma za preduzeća, napisana u Go-u, koja ne dozvoljava da neproveren model uđe u vaš pipeline – svaki model prvo mora da prođe bukvalnu proveru „Vidiš li moj kod?" pre nego što mu bude dozvoljeno da se koristi.

## Zašto je fascinantno

Zanimljivo je to što „verifikacija LLM-a" nije jedan test – to je čitava baterija testova, i svaki od njih otkazuje na različite, podmukle načine. *LLMs Verifier* izvršava provere postojanja, responsivnosti, latencije, striminga, poziva funkcija, vizuelne obrade i embedinga kao zasebne verifikacione testove. Model može da postoji, ali da ne podržava striming. Može da strimuje, ali da se zaglavi na pozivima alata. Može da tvrdi da podržava vizuelnu obradu, a da tiho ignoriše sliku. Tretirajući svaku sposobnost kao nezavisno proverljivu osobinu prvog reda, platforma pretvara pitanje „Da li je ovaj model dobar?" iz subjektivnog osećaja u merljiv, ponovljiv rezultat.

Pored toga, komunicira sa 12 adaptera provajdera – OpenAI, Anthropic, Cohere, Groq, Together AI, Mistral, xAI, Replicate, DeepSeek, Cerebras, Cloudflare Workers AI i SiliconFlow – preko jedinstvenog normalizovanog interfejsa. Ista verifikaciona baterija, isti sistem ocenjivanja, primenjuje se na potpuno različite API-je. Ta normalizacija je mesto gde se proliva najviše inženjerske krvi, jer nijedna dva provajdera se ne slažu oko toga kako izgledaju striming, pozivi funkcija ili embedding na mrežnom nivou.

## Teški problemi

Prvi težak problem je heterogenost. Sloj za detekciju sposobnosti mora da zna da striming može da stigne kao Server-Sent Events, WebSocket frejmovi, asinhroni generator, JSONL ili sirovi tok događaja – i mora da otkrije koji od njih određeni provajder stvarno isporučuje, a ne onaj koji dokumentacija obećava. Pratiti podršku za kompresiju (gzip, brotli i semantičku/chat kompresiju na nivou), ponašanje keširanja (keširanje prompta kod Anthropic-a i DashScope-a) i dostupnost HTTP/3 po provajderu. Ništa od toga nije uniformno; sve se mora empirijski otkriti.

Drugi problem je poverenje u uslovima otkaza. U produkciji, provajderi ograničavaju propusni opseg, degradiraju performanse i nestaju. Platforma koristi provere zdravlja u realnom vremenu sa inteligentnim prebacivanjem na rezervne resurse i šablon prekidača strujnog kola, tako da nestabilan provajder ne može da obori ceo proces verifikacije – ili aplikaciju koja ga koristi.

Treći problem je dugoročni kontekst. Sistem podržava sesije duže od 24 sata sa LLM-pokretanom sumarizacijom i optimizacijom RAG-a, plus šablon nadzornik/radnik koji koristi LLM da razbije velike verifikacione poslove na distribuiran rad. Održavanje koherentnog stanja tokom celodnevne aktivnosti agenata, bez preopterećenja kontekstnog prozora, pravi je problem distribuiranih sistema prerušen u funkcionalnost LLM-a.

## Šta ga čini revolucionarnim

Revolucionarna promena je prelazak sa „konfigurisanog" na „dokazano". Većina sistema izvozi spisak naziva modela i nada se najboljem. *LLMs Verifier* generiše verifikovanu konfiguracionu datoteku u kojoj su uključeni samo modeli koji su stvarno prošli proveru – i svaki generisani provajder i model obeležava obaveznim sufiksom `(llmsvd)`, tako da nikada ne postoji nejasnoća oko toga šta je provereno mašinski, a šta ručno izmenjeno. Ta jedina disciplina eliminiše čitavu klasu incidenata: način otkaza „isporučili smo rešenje koje se oslanja na model koji ne može da uradi ono što nam treba" jednostavno ne može da preživi kontrolnu tačku izvoza.

Takođe je izgrađen kao infrastruktura, a ne kao skripta. Raspoređuje se preko Docker-a i Kubernetes-a, ima Prometheus metrike sa Grafana kontrolnim tablama, LDAP/SSO sa SAML/OIDC, šifrovanu bazu podataka SQLCipher i integracije sa Splunk-om, DataDog-om, New Relic-om i ELK-om. Isporučuje SDK za Python i JavaScript, kao i OpenAPI/Swagger interfejs. Ovo je platforma koju možete da predate sigurnosnom i infrastrukturnom timu i da oboje klimnu glavom.

## Kako sam rešio najteže delove

Verifikaciju sam učinio ugovorom, a ne naknadnom mišlju. Ključna odluka bila je da ništa – ni model, ni provajder – nema pravo da se koristi dok ne prođe bateriju testova, a provera „Vidiš li moj kod?" je nepregovoriva ulazna tačka. Taj pristup nametnuo je jasnu podelu: adapteri provajdera su glupi transportni slojevi, a verifikacioni motor je vlasnik istine.

Da bih ukrotio 12 nekompatibilnih provajdera, izgradio sam detekciju sposobnosti kao empirijsku sondu, a ne statičku tabelu mogućnosti. Sistem pita svakog provajdera šta može da uradi tako što to stvarno i radi – otvara strim i klasifikuje okvire (SSE vs WebSocket vs JSONL vs asinhroni generator), pokušava poziv funkcije, šalje sliku – i beleži uočenu stvarnost, uključujući specifičnosti kompresije i keširanja. Dodavanje trinaestog provajdera svodi se na „napiši transport i pusti sondu da ga okarakteriše", a ne na „ponovo revidiraj celu matricu".

Za otpornost sam se oslanjao na šablone kojima verujem: prekidače strujnog kola oko svakog poziva provajdera, provere zdravlja koje pokreću automatsko prebacivanje na rezervne resurse i čekpoint-ove u oblaku (S3, Google Cloud, Azure), tako da 24-časovna nadgledana sesija može da preživi restart. Namerno sam ga pisao u Go-u – model konkurentnosti prirodno se mapira na „izvrši mnogo nezavisnih verifikacionih sondi protiv mnogo nestabilnih udaljenih servisa odjednom", što je upravo taj workload. Rezultat je verifikator koji je sam po sebi produkcijskog nivoa, jer alat koji kontroliše produkciju nema posla da bude nestabilan.
