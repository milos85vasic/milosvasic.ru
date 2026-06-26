---
title: Helix-Flow Platform
slug: helix-flow-platform
repo: https://github.com/Helix-Flow/Platform
tech: Go, gRPC, HTTP, TLS 1.3, mTLS, PostgreSQL, SQLite, JWT
teaser: "One OpenAI-compatible gateway for all your AI inference — TLS 1.3, mutual-auth service mesh, predictable costs, drop-in API."
---

## Kanca

"Tüm AI çıkarım ihtiyaçlarınız için tek bir platform — güçlü AI modellerini daha hızlı, daha akıllı ve her ölçekte, öngörülebilir maliyetlerle çalıştırın." Helix-Flow Platform, kurumsal bir AI çıkarım ağ geçididir ve OpenAI API'sini destekler; böylece mevcut istemcileriniz sorunsuz çalışır, ancak altında sertleştirilmiş, karşılıklı kimlik doğrulamalı bir mikro hizmet ağı ile TLS 1.3 uçtan uca güvenlik sağlar.

## Neden büyüleyici?

AI çıkarımının vaadi basitçe ifade edilir, ancak uygulaması acımasızdır: ekiplere, tek bir satıcıya bağımlı kalmadan, modelleri çağırmak için tutarlı, hızlı ve güvenli bir yol sunmak. Helix-Flow, bunu **kurumsal düzeyde bir mikro hizmet mimarisi** olarak ele alır — kimlik doğrulama, çıkarım havuzu ve izleme için bağımsız hizmetlerin önünde bir API ağ geçidi — hem HTTP hem de gRPC üzerinden eş zamanlı olarak sunulur.

Kritik nokta, **OpenAI API spesifikasyonuna uyumluluk** hedeflemesidir. Bu, tanıdık yüzey — `/v1/models`, `/v1/chat/completions`, Bearer-token kimlik doğrulaması — orada olduğu anlamına gelir; böylece OpenAI API'sine karşı geliştirilmiş herhangi bir uygulama, Helix-Flow'u işaret edebilir. Yerine geçen bir uç nokta elde edersiniz, ancak arkasında kendi kimlik doğrulamanız, kendi izlemeniz ve kendi maliyet kontrolleriniz olur.

## Zorlu sorunlar

Merkezdeki zorluk, **güvenliğin yalnızca uç noktada değil, hizmet ağı düzeyinde** sağlanmasıdır. Herkese açık bir uç noktaya TLS eklemek kolaydır; ancak iç hizmetler arasındaki her adımın şifrelenmesi ve kimlik doğrulanması çok daha zordur. Helix-Flow, tam bir PKI altyapısı kurar ve gRPC hizmet ağı boyunca **karşılıklı TLS (mTLS)** ile TLS 1.3 çalıştırır; böylece hizmetler, yalnızca dış dünyaya değil, birbirlerine de kimliklerini kanıtlar. Bu, otomatik sertifika yönetimini — sertifika oluşturma, dağıtma ve yenileme — gerektirir, çünkü elle yönetilen bir ağ, üretim ortamıyla karşılaştığında ayakta kalamaz.

İkinci zorlu sorun, **çift protokol uyumudur**. Hem HTTP hem de gRPC ağ geçidi sunmak, aynı yeteneklerin iki çok farklı taşıma protokolü üzerinden doğru çalışmasını ve her ikisinde de tutarlı kimlik doğrulama ve davranış sağlanmasını gerektirir. REST tercih eden ekipler ile yüksek performanslı gRPC tercih eden ekipler aynı platformu kullanabilmelidir.

Üçüncü sorun, **öngörülebilir maliyet ve işletilebilirliktir**. "Öngörülebilir maliyetler" vaadi, platformun gerçek zamanlı izleme, hız sınırlama ve denetim kaydı gibi özelliklere sahip olmasıyla geçerlilik kazanır — böylece harcamalar ve davranışlar gözlemlenebilir ve sınırlandırılabilir, aylık sürprizlerle karşılaşılmaz.

## Oyunu değiştiren özellik

Helix-Flow'un iddiası, AI çıkarımının **bir uygulama entegrasyonu değil, altyapı** olması gerektiğidir. Satıcıdan bağımsız bir çıkarım havuzunun önünde OpenAI uyumlu bir API sunarak, bir kuruluşun modelleri çağırmasını merkezileştirir: tek bir ağ geçidi, tek bir kimlik doğrulama modeli, hız sınırlarını uygulamanın tek bir yeri, tek bir denetim izi. Model arka uçlarını değiştirmek veya eklemek, her uygulamaya dağılmış bir kod değişikliği yerine bir altyapı kararı haline gelir.

Bunu yaparken kurumsal temellerden ödün vermez — JWT doğrulama, hız sınırlama, denetim kaydı, hataların zarif yönetimi ve çoklu veritabanı desteği (geliştirme için SQLite, üretim için PostgreSQL) — böylece istemcilerin bağlı olduğu sözleşme değişmeden, dizüstü bilgisayardan kümeye geçiş yapılabilir.

## En zor kısımları nasıl çözdüm?

Güvenliği sonradan eklemek yerine temelden inşa ettim. Platform, **TLS 1.3 ve mTLS içeren eksiksiz bir PKI** ile birlikte gelir ve sertifika sağlama işlemi otomatikleştirilmiştir; böylece hizmet ağı, elle sertifika yönetimine gerek kalmadan kendini doğrulayabilir. Her iç gRPC bağlantısı karşılıklı olarak kimlik doğrulanır; ağ geçidi, dış trafiği TLS üzerinden sonlandırır ve çıkarım havuzuna ulaşmadan önce JWT'leri doğrular. Güvenlik, ağın bir özelliğidir, etrafına sarılmış bir katman değil.

Çift protokol desteği için **API ağ geçidini HTTP ve gRPC'yi yan yana sunacak şekilde tasarladım**; kimlik doğrulama ve çıkarım havuzu gibi daha yoğun hizmetler performans için gRPC üzerinden sunulurken, halka açık yüzey HTTP üzerinden uyumluluk için açılır. Bu ayrım, gecikmeye duyarlı iç çağrıların gRPC kullanmasını sağlarken, dış istemcilerin basit OpenAI tarzı REST arayüzünü korumasını sağlar.

İşletilebilirlik ve "öngörülebilir maliyetler" vaadi için **izleme hizmetini kimlik doğrulama ve çıkarımla aynı düzeyde birincil bileşen olarak ele aldım**; sağlık kontrolleri, metrik toplama, hız sınırlama ve denetim kaydı ekleyerek kullanım ve sistem sağlığını varsayılan olarak görünür ve sınırlandırılmış hale getirdim. Çoklu veritabanı tasarımı — yerel çalıştırmalar için SQLite, üretim için PostgreSQL — aynı platformun tek bir makinede doğrulanmasını ve ardından ölçeklenmesini sağlar; bu da "her ölçekte" bir çıkarım platformunun yapması gereken tam olarak budur.
