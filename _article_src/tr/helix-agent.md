---
title: HelixAgent
slug: helix-agent
repo: https://github.com/HelixDevelopment/HelixAgent
tech: Go, Gin, PostgreSQL, Redis, Neo4j, ClickHouse, Kafka, gRPC, OpenTelemetry
teaser: "An ensemble LLM service that makes models debate each other, scores them in real time, and votes on the most reliable answer."
---

## Kanca

Ya bir dil modeline güvenmek yerine, birden fazlasını *tartışmaya* — öneri sunmaya, eleştirmeye, gözden geçirmeye ve sentezlemeye — sokup ardından en güçlü fikir birliğine sahip yanıta yönlendirseniz? HelixAgent tam olarak bu: Birden fazla modelin yanıtlarını akıllıca birleştiren, sağlayıcıları gerçek zamanlı olarak puanlayan ve en doğru ve güvenilir çıktıya ulaşmak için yapılandırılmış çok turlu tartışmalar yürüten, üretime hazır bir topluluk LLM hizmeti.

## Neden büyüleyici?

Tek model yanıtları, kalite konusunda yazı tura atmak gibi. HelixAgent ise güvenilirliği bir topluluk problemi olarak ele alıyor. Claude, DeepSeek, Gemini, Mistral, OpenRouter, Qwen, xAI/Grok, Cohere, Perplexity, Groq ve daha pek çoğunu içeren geniş bir LLM sağlayıcı filosunu destekliyor ve bunlar arasından gerçek zamanlı doğrulama puanlarıyla (LLMsVerifier entegrasyonu sayesinde) dinamik olarak seçim yapıyor. Yani sağlayıcı seçimi statik bir yapılandırma değil; şu anda gerçekten hangi modellerin iyi performans gösterdiğini yansıtıyor.

Öne çıkan yetenek, **Yapay Zeka Tartışma Sistemi**. Birden fazla sağlayıcı, birden fazla tur boyunca fikir birliğine varmak için tartışıyor; bu süreç farklı topolojiler (ağ, yıldız, zincir) üzerinden, belirlenmiş bir aşama protokolüyle — Öneri, Eleştiri, Gözden Geçirme, Sentez — ve hatta çapraz tartışma öğrenimiyle koordine ediliyor. Yönlendirme stratejileri arasında güven ağırlıklı puanlama, çoğunluk oyu ve anlamsal niyet tespiti yer alıyor. Bu, LLM’leri kullanmanın anlamlı biçimde farklı bir yolu: "Tek bir modele sormak" yerine "bir panel toplamak ve hakemlik yapmak".

## Zorlu sorunlar

Bağımsız, hataya açık sağlayıcılar arasında bir tartışma düzenlemek zor. Her model yavaş olabilir, başarısız olabilir ya da anlaşmazlığa düşebilir; üstelik tartışmanın turlar boyunca tutarlı kalması ve katılımcıların herhangi birinin devre dışı kalmasına rağmen devam etmesi gerekir. HelixAgent’in tartışma düzenleyicisi, çoklu topoloji koordinasyonunu ve katı bir aşama protokolünü yönetirken, tartışma mekanizması ilerleyemediğinde **otomatik olarak eski yola geri dönüş** sağlıyor — karmaşık özelliklerde dahi sorunsuz bir düşüş (graceful degradation) entegre edilmiş durumda.

Herhangi bir anda *hangi* modele güvenileceğini bilmek de ayrı bir sorun. Statik kıyaslamalar hızla eskimeye mahkûm. HelixAgent, dinamik ve gerçek zamanlı doğrulama puanlarıyla sağlayıcı seçimini ve sorunsuz geri dönüşü sağlayarak, sistemi sürekli en iyi performans gösteren sağlayıcıya yönlendiriyor ve hataları kategorize edilmiş şekilde raporluyor; böylece şeffaf olmayan hatalara yer kalmıyor.

Bir de üretim ortamının getirdiği zorluklar var. Her isteği birden fazla sağlayıcıya dağıtan bir topluluk, maliyeti, gecikmeyi ve hata yüzeyini katlıyor. Bunu kontrol altında tutmak ciddi bir altyapı gerektiriyor: yüksek erişilebilirlik, önbellekleme, gözlemlenebilirlik ve güvenlik — hiçbiri opsiyonel değil.

## Oyunu değiştiren özellikler

HelixAgent, bir istem paketleyicisi değil, gerçek bir platform olarak tasarlandı. Yaklaşık yirmi ayrıştırılmış modülden oluşuyor: EventBus, Concurrency, Observability, Auth, Storage, Streaming, Security, VectorDB, Embeddings, Database, Cache, Messaging, Formatters, MCP, RAG, Memory, Optimization, Plugins, Containers ve Challenges çerçevesi. Bu modülerlik, bir topluluk sisteminin sürdürülebilir kalmasını sağlıyor.

Ayrıca çoğu LLM hizmetinin hiç dokunmadığı Büyük Veri alanına da uzanıyor: sonsuz bağlam işleme, dağıtık bellek ve Neo4j, ClickHouse ve Kafka destekli bilgi grafiği akışı. Buna Redis tabanlı yanıt önbelleği, anlamsal önbellek, PII tespiti içeren bir güvenlik duvarı motoru, MCP adaptörleri, pek çok dil için kod biçimlendiriciler ve bir CLI ajanları kaydı eklendiğinde, bu sistemin gerçek bir yapay zeka yığınının merkezinde yer alması amaçlandığı açıkça görülüyor.

## En zor kısımları nasıl çözdüm?

Tartışmayı **açık bir aşama protokolü** olarak tasarladım — Öneri, ardından Eleştiri, ardından Gözden Geçirme, ardından Sentez — ve bu protokol seçilebilir bir topoloji (ağ, yıldız veya zincir) üzerinde çalışıyor. Konuşmayı adlandırılmış aşamalara bölmek, çok modelli bir tartışmayı yönetilebilir kılıyor: Her aşamanın net girdileri ve çıktıları var, böylece düzenleyici bağımsız sağlayıcıları koordine edebiliyor, çapraz tartışma öğrenimini entegre edebiliyor ve yine de tek bir sentezlenmiş sonuç üretebiliyor. Ayrıca herhangi bir karmaşık düzenleme sonunda başa çıkamayacağı bir duruma denk geleceği için, otomatik olarak eski yönlendirme yoluna geri dönüş sağlayarak hizmetin tamamen çökmek yerine sorunsuz bir şekilde düşmesini sağladım.

Güvenilir sağlayıcı seçimi için **LLMsVerifier entegrasyonu**ndan gelen dinamik puanlara dayandım, ardından yönlendirme stratejilerini — güven ağırlıklı, çoğunluk oyu veya anlamsal niyet tespiti — devreye sokarak, bir sağlayıcı başarısız olduğunda en yüksek puanlı sağlayıcıya sorunsuz geri dönüş ve kategorize edilmiş hata raporlaması sağladım. Sağlayıcı seçimi, sabit kodlanmış bir tercih değil, ölçümlenmiş bir karar haline geliyor.

Tüm bunları üretim kalitesinde tutmak için, çapraz kesimli endişeleri yaklaşık yirmi bağımsız modüle ayırdım; böylece topluluk mantığı, önbellekleme, gözlemlenebilirlik, kimlik doğrulama veya depolamanın nasıl uygulandığıyla ilgilenmek zorunda kalmıyor. Operasyonel olarak PostgreSQL ve Redis üzerinde otomatik yük devretme ile çalışıyor, her şeyi Prometheus, Grafana ve OpenTelemetry izleme araçlarıyla donatıyor ve kapsamlı bir doğrulama betiği ve testlerden oluşan Challenges çerçevesiyle doğrulanıyor. Bu endişelerin ayrıştırılması, iyi bir demo sunan bir topluluk ile gerçekten dağıtılabilir bir topluluk arasındaki farkı yaratıyor.
