---
title: HelixTranslate
slug: helix-translate
repo: https://github.com/HelixDevelopment/HelixTranslate
tech: Go, HTTP/3, WebSocket, REST, SSH, LLM providers
teaser: "Translate an entire ebook into any language — over a verified-best LLM, streamed live over WebSocket, with no silent local fallbacks."
---

## Kanca

Elinizdeki kitabı hangi formatta olursa olsun verin, hedef dili söyleyin; HelixTranslate tümünü çevirecek — metninizi mevcut en güçlü *doğrulanmış* LLM'ye yönlendirecek, ilerlemeyi canlı bir gösterge paneline aktaracak ve kaliteyi arkanıza bakmadan sessizce düşürmeyecek. REST API, HTTP/3 desteği ve gerçek zamanlı WebSocket olaylarıyla donatılmış, yüksek performanslı, kurumsal düzeyde evrensel bir e-kitap çeviri araç setidir.

## Neden büyüleyici?

Çeviri araçları genellikle bir sağlayıcı seçmenizi ve bugün yeterince iyi olmasını ummanızı ister. HelixTranslate bu yaklaşımı tersine çevirir. Varsayılan yolu **köprü tarafından seçilir**: En güçlü doğrulanmış API modelini — artı puan sıralı bir yedek zinciri — otomatik olarak, LLMsVerifier projesiyle entegrasyonu sayesinde temin eder. Bir sağlayıcı seçmezsiniz; sistem, şu anda çalıştığı kanıtlanmış en iyisini seçer ve en üst seçenek başarısız olursa sıralı bir liste üzerinden geri çekilir.

Bu çekirdeğin etrafında eksiksiz bir **gerçek zamanlı izleme sistemi** yer alır: Bir WebSocket merkezi, canlı ilerleme, olaylar ve hataları bir web paneline aktarır, benzersiz kimliklere sahip birden fazla eşzamanlı çeviri oturumunu destekler ve çoklu istemci bağlantılarını otomatik yeniden bağlanma ile yönetir. Uzun bir kitabın paragraf paragraf çevrildiğini izleyebilirsiniz, bloke olmuş bir terminale bakmak yerine. OpenAI, Anthropic, DeepSeek, Zhipu, Qwen, Gemini ve daha fazlası dahil birçok sağlayıcıyla konuşur — hepsi doğrulanmış keşif yoluyla erişilebilir.

## Zorlu sorunlar

İlk zorlu sorun **başarısızlıkta dürüstlük**. Bir API anahtarı eksik olduğunda ya da bir sağlayıcı başarısız olduğunda kolay olan, sessizce zayıf bir yerel modele geri çekilip her şeyin yolunda olduğunu varsaymaktır. Bu, başarılı görünen ama aslında çöp çeviriler üretir. Ben bunun tam tersini katı bir kural haline getirdim: Hiçbir sağlayıcı API anahtarı ayarlanmamışsa, köprü dürüst bir hata döndürür — asla sessiz bir yerel yedekleme olmaz. Bunu tüm iş akışında tutarlı bir şekilde uygulamak, tek satırlık bir kontrol değil, bir tasarım kısıtıdır.

İkincisi **SSH üzerinden dağıtık çeviri**. Büyük kitaplar seri olarak çevrildiğinde yavaş olur, bu yüzden sistem uzak SSH çalışanlarını destekler — güvenli bağlantı kurar, çeviri işini dağıtır, uzak taraftan ilerlemeyi takip eder ve hataları ile yedeklemeleri yönetir. Gösterge paneline tutarlı gerçek zamanlı olaylar gönderirken uzak çalışanları koordine etmek, yüzlerce küçük şekilde bozulabilecek türden bir entegrasyondur.

Üçüncüsü **gerçek zamanlı olay bildiriminin doğru yapılması**. Birden fazla eşzamanlı oturumun canlı ilerlemesini birden fazla gösterge paneli istemcisine aktarmak — yeniden bağlanma, oturum geçmişi ve oturum başına takip ile — gerçek bir WebSocket mimarisi sorunudur, sıradan bir ilerleme çubuğu değil.

## Oyunu değiştiren ne?

Doğrulanmış en iyi model stratejisi, çalınmaya değer fikir. Statik bir sağlayıcı seçimine güvenmek yerine, HelixTranslate sürekli olarak dış doğrulamaya dayanarak *gerçekten* performans gösteren modele yönlendirir ve performans göstermezse belirlenmiş bir yedek zinciriyle geri çekilir. Bu, "Çeviri için hangi LLM'yi kullanmalıyım?" sorusunu bir tahminden ölçülebilir, otomatik bir karara dönüştürür — ve araç, altta yatan model ortamı değişirken, kod değişikliği olmadan daha da iyileşir.

Aynı zamanda bilinçli olarak kapsamı daraltılmış bir proje. Bir dönem yerel çalışma zamanı sağlayıcıları ve SSH-yerel yolu destekliyordu; daha sonraki bir köprü aşamasında **yerel çalışma zamanı sağlayıcılarını (Ollama, LlamaCpp) ve SSH-yerel çeviri yolunu tamamen kaldırdım**. Artık bunları seçmek, sessizce daha zayıf bir yerel model çalıştırmak yerine dürüst bir "artık desteklenmiyor" hatası döndürüyor. Bu, yol haritasına uygulanan aynı dürüstlük ilkesi: Bir yolu kesmeyi, sessizce daha kötü çıktı üretmesine yeğlerim.

## En zor kısımları nasıl çözdüm?

Mimari kilit taşı, çeviriyi LLMsVerifier ile bağlayan **köprü paketi** (`pkg/bridge`). Sağlayıcı tercihlerini sabit kodlamak yerine, çevirmen köprüden en güçlü doğrulanmış modeli ve sıralı bir yedek zinciri talep eder, ardından bununla çeviri yapar. "Bir sağlayıcı seçmek zorunda değilsiniz" ifadesini pratikte doğru kılan da budur ve sessiz yedekleme yapılmamasını sağlayan kural da burada uygulanır — köprü, yerel bir model yerine açık bir hata döndürür.

Gerçek zamanlı izleme için endişeleri ayrı paketlere böldüm: Bağlantı ve yayın yönetimini üstlenen bir `websocket` merkezi, olay akışını tanımlayan ve ileten bir `events` sistemi ve uzak yürütme için bir `sshworker` paketi. Bağımsız bir izleme sunucusu WebSocket akışını tüketir ve gösterge panelini sürer, böylece çeviri çalışmaları ve izleme birbirinden ayrılır — CLI olayları yayar, sunucu bunları dağıtır ve herhangi sayıda gösterge paneli istemcisi otomatik yeniden bağlanma ile abone olur.

Dağıtım için SSH çalışan katmanı, güvenli bağlantı yönetimi ve uzak yürütmeyi üstlenirken, ilerlemeyi aynı olay sistemi üzerinden geri bildirir; böylece uzak bir çeviri, gösterge paneli açısından yerel bir çeviriyle aynı görünür. Tüm sistem, HTTP/3 desteğine sahip bir REST API üzerinden sunulur ve kapsamlı bir WebSocket izleme test paketiyle desteklenir — çünkü gözlemleyemediğiniz bir çeviri sistemi, güvenemeyeceğiniz bir çeviri sistemidir.
