---
title: HelixCode
slug: helix-code
repo: https://github.com/HelixDevelopment/HelixCode
tech: Go, PostgreSQL, Redis, SSH, MCP, WebSocket, Gin
teaser: "A distributed AI coding agent that splits work across an SSH worker network, checkpoints everything, and never loses progress on a crash."
---

## Kanca

Ya AI kodlama aracınız tek bir makinede çalışmak yerine, kendisinin sağladığı bir çalışan ağı üzerinde çalışsaydı — büyük bir görevi parçalara ayırıp bunları dağıtsaydı ve yol boyunca kontrol noktaları oluşturarak bir çökmenin iş kaybına yol açmamasını sağlasaydı? İşte HelixCode bu: Go ile yazılmış, SSH tabanlı çalışan havuzlarına, otomatik kontrol noktası oluşturma, geri alma ve çoklu sağlayıcı LLM entegrasyonuna sahip, kurumsal düzeyde dağıtık bir AI geliştirme platformu.

## Neden büyüleyici?

Çoğu "AI kodlama aracı", tek bir süreçten tek bir modele konuşur. HelixCode ise gerçek geliştirme çalışmalarının bölünebilir ve dağıtılabilir olduğu fikri üzerine inşa edildi. **Akıllı görev bölümü** ile bağımlılık yönetimi yapar, ardından otomatik kontrol noktalarıyla uzun süren işlerin kesintiye uğramadan devam etmesini sağlar. Platform, dört farklı istemci arayüzü sunar — REST API, CLI, terminal arayüzü ve WebSocket — ve **Model Bağlam Protokolü (MCP)** ile çoklu taşıma desteği uygulayarak daha geniş AI aracı ekosistemine entegre olur.

Ayrıca alışılmadık derecede geniş bir platform desteğine sahip: Linux, macOS, Windows, Aurora OS ve SymphonyOS, yanı sıra iOS ve Android için hazırlıklar yapılmış. Depo, çekirdeğinde Go ile Shell, Kotlin, Swift ve web varlıklarını barındırıyor — her yerden yönetilmek üzere tasarlanmış bir platformun yapısı bu.

## Zorlu sorunlar

Tanımlayıcı zorluk, **kırılganlık olmadan dağıtım**dır. Bir kodlama görevini uzak çalışanlara bölmeye başladığınız anda, dağıtık sistemlerin tüm zorlu sorunlarını devralırsınız: işi gerçek bağımlılık sınırları boyunca nasıl böleceğiniz, hangi çalışanın hangi parçaya sahip olduğunu nasıl takip edeceğiniz, bir çalışan görevin ortasında kaybolduğunda nasıl kurtaracağınız ve sonuçları tutarlı bir şekilde nasıl birleştireceğiniz.

Çalışan yönetimi de kendi başına bir sorun. HelixCode önceden oluşturulmuş bir küme varsaymaz — **SSH çalışan havuzu ve otomatik kurulum** sunar, yani uzak bir makineye bağlanıp kendini oraya kurması, çalışanı kaydetmesi ve sağlığını SSH üzerinden güvenli bir şekilde izlemesi gerekir. Bu önyükleme sürecinin farklı makinelerde güvenilir olması, göründüğünden çok daha zordur.

Ardından LLM katmanı gelir. Tek bir arayüzün arkasında birden fazla sağlayıcıyı desteklemek, donanım tespiti (CPU/GPU/bellek) yaparak modelleri akıllıca seçmek ve üstüne ileri düzey akıl yürütme — zincirleme düşünme ve ağaç tabanlı düşünme — eklemek, aracın yalnızca *ne* üreteceğini değil, *nerede* ve *hangi kaynaklarla* çalışacağını da düşünmesini gerektirir.

## Oyunu değiştiren özellikler

**İşin korunması ve geri alma** kombinasyonu, fark yaratan özelliktir. Bir AI aracının tam olarak kaldığı yerden devam edebilmesi ve kötü bir değişikliği geri alabilmesi, uzun otonom çalışmaları bir kumardan operasyonel bir sürece dönüştürür. HelixCode bunu, veritabanında saklanan projeler ve çoklu oturum bağlamı takibiyle desteklenen tam bir geliştirme iş akışı modları — planlama, inşa etme, test etme ve yeniden yapılandırma — ile birleştirir. Bu sadece "kod üretmek" değil; bir yaşam döngüsüdür.

MCP uygulaması da önemlidir. Model Bağlam Protokolü’nü birden fazla taşıma yöntemiyle konuşarak HelixCode, hem AI araçları dünyasının bir tüketicisi hem de katılımcısı olabilir. Çok kanallı bildirimleri (Slack, Discord, E-posta, Telegram) sayesinde dağıtık bir çalışma, insanların gerçekten izlediği yerlere ilerleme raporu gönderebilir.

## En zor kısımları nasıl çözdüm?

Sistemi temiz iç modüller olarak tasarladım — kimlik doğrulama ve oturum yönetimi, çalışan havuzu yönetimi, görev yönetimi ve kontrol noktası oluşturma, proje ve iş akışı yönetimi, LLM sağlayıcı entegrasyonu — her biri kendi paketinde yer alıyor. Bu ayrım, dağıtık davranışları yönetilebilir kılıyor: Görev bölümü ve kontrol noktası oluşturma, hangi LLM sağlayıcısının veya hangi taşıma yönteminin kullanıldığından bağımsız olarak ele alınabiliyor.

Çalışan ağı için **SSH çalışan havuzunu kendi kendine kuracak** şekilde tasarladım. Operatörlerin her düğümü önceden hazırlamasını gerektirmek yerine, platform SSH üzerinden bağlanır, ihtiyacı olanları kurar, çalışanı kaydeder ve sürekli olarak sağlığını izler. Sağlık izleme, görev yönetimine geri bildirim sağlayarak bir düğüm performansı düştüğünde işin yeniden atanmasını mümkün kılar.

Dayanıklılık için **kontrol noktası oluşturma omurgadır**. Görev yönetimi, iş ilerledikçe kontrol noktaları yazar, böylece kesintiye uğrayan bir iş son iyi durumundan devam eder, baştan başlamaz ve geri alma, kötü bir adımı geri sarabilir. Uzun, dağıtık, otonom çalışmaları güvenli bir şekilde denemeyi mümkün kılan mekanizma budur.

Model katmanı için her sağlayıcıyı **birleşik bir sağlayıcı arayüzü** arkasına yerleştirdim ve donanım tespiti ekleyerek aracın model seçimini gerçekten çalıştıran makineye uygun hale getirdim. Bu arayüzün üzerine araç çağırma ve zincirleme düşünme/ağaç tabanlı düşünme akıl yürütmesini ekledim, böylece akıl yürütme stratejisini geliştirmek, sağlayıcı altyapısına dokunmayı gerektirmez. Kalıcılık katmanı PostgreSQL ve isteğe bağlı Redis’ten oluşur; bu da projeleri, oturumları ve iş akışı durumunu tüm dağıtık sistem boyunca kalıcı tutar — akıllı bir demo ile gerçekten çalıştırabileceğiniz bir platform arasındaki fark budur.
