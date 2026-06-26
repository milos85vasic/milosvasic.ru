---
title: LLMs Verifier
slug: llms-verifier
repo: https://github.com/vasic-digital/LLMsVerifier
tech: Go
teaser: "Before any LLM touches production, it has to prove it can actually see your code — across 12 providers, in real time."
---

## Kanca

Her ekip "en yeni model"e bağlanırken sessizce bir yapılandırma dosyasına güveniyor. YAML dosyanızdaki model adı `gpt-4o` ya da `claude-sonnet` diyor, uç nokta 200 yanıtı döndürüyor ve siz de diğer uçtaki şeyin gerçek, sağlıklı ve üstüne yıkmak üzere olduğunuz görevi yerine getirebilecek durumda olduğunu varsayıyorsunuz. LLMs Verifier, bu varsayımın yeterince sık yanlış çıkıp zarar vermesi nedeniyle var. Kurumsal düzeyde bir Go platformu olan LLMs Verifier, doğrulanmamış bir modelin iş akışınıza girmesine asla izin vermez — her model, kullanılmadan önce kelimenin tam anlamıyla bir "Kodumu görüyor musun?" kontrolünden geçmek zorundadır.

## Neden büyüleyici?

İlginç olan, "bir LLM'yi doğrulamak"ın tek bir test olmadığı — bir dizi testten oluştuğu ve her birinin farklı, sinsice başarısız olduğudur. LLMs Verifier, varlık kontrolü, yanıt verme hızı, gecikme süresi, akış, fonksiyon çağırma, görüntü işleme ve gömme (embedding) gibi ayrı doğrulama testleri gerçekleştirir. Bir model var olabilir ama akış desteği vermeyebilir. Akış desteği olabilir ama araç çağrılarında tıkanabilir. Görüntü işleme desteği olduğunu iddia edebilir ama görseli sessizce yok sayabilir. Her yeteneği bağımsız olarak doğrulanabilir bir özellik olarak ele alarak, platform "bu model iyi mi?" sorusunu bir his olmaktan çıkarır ve ölçülebilir, tekrarlanabilir bir sonuca dönüştürür.

Bunun üzerine, platform tek bir standartlaştırılmış arayüz üzerinden 12 sağlayıcı adaptörüyle — OpenAI, Anthropic, Cohere, Groq, Together AI, Mistral, xAI, Replicate, DeepSeek, Cerebras, Cloudflare Workers AI ve SiliconFlow — iletişim kurar. Aynı doğrulama paketi, aynı puanlama sistemi, birbirinden tamamen farklı API'ler üzerinde çalıştırılır. Bu standartlaştırmanın sağlanması, mühendislik açısından en çok kan dökülen noktadır, çünkü hiçbir sağlayıcı akış, fonksiyon çağırma ya da gömme işlemlerinin kabloda nasıl göründüğü konusunda hemfikir değildir.

## Zorlu sorunlar

İlk zorlu sorun heterojenliktir. Bir yetenek tespit katmanı, akışın Sunucu Tarafından Gönderilen Olaylar (SSE), WebSocket çerçeveleri, asenkron bir üretici, JSONL ya da ham bir olay akışı olarak gelebileceğini bilmek zorundadır — ve bir sağlayıcının gerçekte hangisini sunduğunu, belgelerin vadettiği değil, tespit etmelidir. Sıkıştırma desteğini (gzip, brotli ve anlamsal/sohbet düzeyinde sıkıştırma), önbellekleme davranışlarını (Anthropic ve DashScope istem önbellekleme) ve sağlayıcı başına HTTP/3 kullanılabilirliğini izler. Bunların hiçbiri standart değildir; hepsi deneysel olarak keşfedilmelidir.

İkinci sorun, başarısızlık durumunda güvenilirliktir. Üretim ortamında sağlayıcılar kısıtlama uygular, performans düşürür ya da tamamen devre dışı kalır. Platform, gerçek zamanlı sağlık kontrolü, akıllı yük devretme ve devre kesici desenini bir araya getirerek, sorunlu bir sağlayıcının tüm doğrulama sürecini — ya da onu kullanan uygulamayı — çökertmesini engeller.

Üçüncü sorun, uzun vadeli bağlamdır. Sistem, LLM destekli özetleme ve RAG optimizasyonu ile 24 saatten uzun süren oturumları destekler; ayrıca büyük doğrulama işlerini dağıtık çalışmaya bölen bir denetleyici/işçi modeli kullanır. Ajan etkinliğinin tam bir gün boyunca tutarlı bir durumda kalmasını sağlamak, bağlam penceresini patlatmadan, aslında bir LLM özelliği kılığına girmiş gerçek bir dağıtık sistemler sorunudur.

## Oyunu değiştiren özellik

Oyunu değiştiren, "yapılandırılmış"tan "kanıtlanmış"a geçiştir. Çoğu sistem, model adlarının bir listesini dışa aktarır ve umut eder. LLMs Verifier ise yalnızca gerçekten doğrulama testlerini geçen modelleri içeren bir yapılandırma dosyası üretir — ve her oluşturulan sağlayıcı ve model, makine tarafından doğrulandığına dair hiçbir belirsizliğe yer bırakmayacak şekilde zorunlu olarak `(llmsvd)` son ekiyle işaretlenir. Bu tek disiplin, "ihtiyacımız olan şeyi yapamayan bir modele karşı teslimat yaptık" türündeki tüm olay sınıfını ortadan kaldırır; çünkü bu tür bir başarısızlık, dışa aktarma kapısından geçemez.

Ayrıca, bir betik gibi değil, altyapı gibi inşa edilmiştir. Docker ve Kubernetes dağıtımı, Grafana panelleriyle Prometheus metrikleri, LDAP/SSO ile SAML/OIDC entegrasyonu, SQLCipher veritabanı şifrelemesi ve Splunk, DataDog, New Relic ve ELK ile entegrasyonlar sunar. Python ve JavaScript SDK'ları ile OpenAPI/Swagger arayüzü de mevcuttur. Bu, güvenlik ekibine ve platform ekibine teslim edebileceğiniz ve her ikisinin de onaylayacağı bir platformdur.

## En zor kısımları nasıl çözdüm?

Doğrulamayı bir sözleşme olarak ele aldım, sonradan akla gelen bir düşünce olarak değil. Temel karar, hiçbir modelin, hiçbir sağlayıcının, doğrulama paketini geçmeden kullanıma hak kazanamayacağıydı — ve "Kodumu görüyor musun?" kontrolü, pazarlık kabul etmeyen giriş kapısıydı. Bu yaklaşım, net bir ayrım yarattı: Sağlayıcı adaptörleri aptal taşıyıcılardır, doğrulama motoru ise gerçeğin sahibidir.

12 uyumsuz sağlayıcıyı evcilleştirmek için, yetenek tespitini statik bir yetenek tablosu yerine deneysel bir sonda olarak tasarladım. Sistem, her sağlayıcıya ne yapabildiğini gerçekten yaparak sorar — bir akış açar ve çerçevelemeyi sınıflandırır (SSE mi, WebSocket mı, JSONL mi, asenkron üretici mi), bir fonksiyon çağrısı dener, bir görsel gönderir — ve gözlemlenen gerçeği, sıkıştırma ve önbellekleme tuhaflıkları dahil kaydeder. 13. bir sağlayıcı eklemek, "bir taşıyıcı yaz ve sondanın onu karakterize etmesine izin ver" haline gelir, "tüm matrisi yeniden denetle" değil.

Dayanıklılık için güvendiğim desenlere başvurdum: Her dışarıya yapılan sağlayıcı çağrısının etrafında devre kesiciler, otomatik yük devretmeyi yönlendiren sağlık kontrolleri ve 24 saatlik denetimli bir çalışmanın yeniden başlatma durumunda bile hayatta kalmasını sağlayan bulut destekli kontrol noktaları (S3, Google Cloud, Azure). Ayrıca kasıtlı olarak Go dilinde yazdım — eşzamanlılık modeli, "aynı anda birçok güvenilmez uzak hizmete karşı birçok bağımsız doğrulama sondası çalıştır" iş yüküne doğal olarak uyuyor. Sonuç, kendisi de üretim kalitesinde bir doğrulayıcıdır, çünkü üretimi kontrol eden bir aracın güvenilmez olmaya hakkı yoktur.
