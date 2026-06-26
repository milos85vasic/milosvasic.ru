---
title: Panoptic
slug: panoptic
repo: https://github.com/vasic-digital/Panoptic
tech: Go
teaser: "One Go framework that drives, screenshots, and screen-records web, desktop, iOS and Android — the all-seeing eye for UI automation."
---

## Kanca

UI otomasyonu parçalanmış durumda. Web için Selenium ya da Playwright öğreniyorsunuz, mobil için Appium ve XCUITest, masaüstü için tamamen başka bir şey, video kaydı istiyorsanız da ayrı bir kayıt aracı. Her sınır yeni bir araç, yeni bir soyutlama, yeni bir kararsızlık kaynağı demek. **Panoptic** —her şeyi gören göz anlamına geliyor— bu karmaşayı tek bir Go çatısı altında topluyor; web, masaüstü ve mobilde otomasyon, ekran görüntüsü alma ve oturum kaydı işlemlerini tek bir programlama modeliyle gerçekleştiriyor.

## Neden büyüleyici?

Panoptic’i çekici kılan, "yazılımın ne yaptığını izlemek" yeteneğini "yazılımı kontrol etmek" kadar öncelikli bir özellik olarak ele alması. Sadece düğmelere tıklamakla kalmıyor; yüksek kaliteli, zaman damgalı ekran görüntüleri alıyor ve oturumun tamamını birden fazla formatta video olarak kaydediyor. Bu sayede tek bir test çalıştırması hem doğrulamaları hem de görsel kanıtları —kayıt, sonradan eklenen bir özellik değil, çerçevenin doğal bir parçası— üretebiliyor.

Gerçekten her şeyi kapsıyor. Web otomasyonu Chrome, Firefox, Safari ve Edge’i destekliyor. Mobil tarafında hem iOS hem de Android uygulamaları için ekran kaydıyla birlikte otomasyon sunuyor. Masaüstünde UI otomasyonu ve ekran yakalama özelliği var. Tüm bunlar temiz bir Go API’si üzerinden erişilebilir: `web.NewBrowser()`, `browser.Navigate(...)`, `browser.Screenshot(...)`, özel CSS ve XPath seçicileri, açık bekleme stratejileri — bir de yaygın kullanım senaryoları için CLI (`panoptic record --platform ios --device iPhone13 --output mobile_demo.mp4`). Aynı kavramsal API’nin hem headless Chrome görüntü alanından hem de kaydedilmiş bir iPhone oturumundan erişilebilir olması, tüm amacın özünü oluşturuyor.

## Zorlu sorunlar

İlk zorluk, "bir öğe" kavramının her platformda farklı anlam taşıması. Web’de bir düğme, CSS ya da XPath ile erişilebilen bir DOM düğümü. iOS’ta bir kontrol, erişilebilirlik ağacında yaşıyor. Masaüstü bileşeni ise işletim sistemine özgü bir handle. Panoptic, dört farklı "bu şeyi bul ve tıkla" lehçesini konuşurken bile tek bir öğe tespiti ve etkileşim modeli sunmak zorunda.

İkincisi zamanlama. UI her yerde asenkron, ama her yerde farklı şekilde asenkron. Panoptic, kararsız otomasyonun bir numaralı nedeni olan sabit beklemeler yerine açık bekleme stratejileri sunuyor: `WaitForElement` zaman aşımıyla birlikte, `WaitForCondition` ise bir koşulun doğru olmasını bekleyen keyfi bir predicate. Bir `div.loading` öğesinin kaybolmasını ya da yerel bir görünümün yüklenmesini bekleyen bekleme ilkellerinin her iki durumda da aynı şekilde davranmasını sağlamak, ince bir iş.

Üçüncüsü, otomasyonu sürerken kaydetmek. Yüksek kalitede 30 fps video kaydı almak, yapılandırılabilir bir görüntü alanıyla ve kaydedilen otomasyonun zamanlamasını bozmadan —özellikle de sadece sahip olduğunuz bir tuval değil, bir cihaz ya da simülatör ekranı kaydediyorsanız— gerçek bir performans ve senkronizasyon zorluğu.

## Oyunu değiştiren özellik

Oyunu değiştiren şey, kanıtlarla birlikte konsolidasyon. Otomasyon her platformda tek bir çerçeve altında yaşadığında, ekip dört farklı zihinsel model yerine tek bir model yazar ve görsel kanıtlara ücretsiz sahip olur. Kararsız bir test, artık gözlerinizi kısarak baktığınız bir yığın izi olmaktan çıkıp izleyebileceğiniz bir video haline gelir. Bu tek başına, ekiplerin hata ayıklama sürecini değiştirir.

Ayrıca pipeline’lara entegre olacak şekilde tasarlanmış: genişletilebilir eklenti mimarisi, kurulum ve temizlik için önce/sonra kancaları, tarayıcı, kayıt ve platforma özel mobil ayarlar için YAML yapılandırması, ayrıca açık CI/CD entegrasyonu. Aynı testi yerelde çalıştırdığınız gibi CI’a da bağlayabilirsiniz; ekran görüntüleri ve MP4 dosyaları, başarısız bir derlemeye eklenmesi gereken tam olarak istediğiniz türden çıktılar olur.

## En zor kısımları nasıl çözdüm?

Go’yu bilinçli olarak seçtim. Platformlar arası otomasyon, perde arkasında çok fazla eşzamanlı G/Ç işlemi demek —tarayıcı sürücüleriyle, cihaz köprüleriyle (Android için ADB, iOS için Xcode araçları) ve kayıt için bir kodlayıcıyla aynı anda iletişim kurmak. Go’nun gorutinleri ve kanalları, "bu gorutinde UI’ı sür, şu gorutinde ekran karelerini boşalt, bir diğerinde bekleme koşulunu izle" gibi işlemleri yönetilebilir ve hızlı hale getiriyor; tek bir statik ikili dosya da CLI’ı CI’a göndermeyi kolaylaştırıyor.

Dört farklı öğe modelini birleştirmek için platform sürücülerinin ortak bir etkileşim arayüzünü uygulamalarını sağladım ve seçicileri en düşük ortak payda yerine ifade gücü yüksek tutarak —web’de CSS ve XPath, mobil ve masaüstünde yerel konum belirleyiciler— soyutlamanın asla ihtiyacınız olan kesin seçiciyi kaybetmenize neden olmamasını garantiledim. Bekleme ilkeleri de bu arayüz üzerine inşa edildiği için `WaitForCondition`, predicate’in hangi platformu inceliyor olursa olsun aynı şekilde çalışıyor.

Kaydı bozulma olmadan gerçekleştirmek için yakalamayı, otomasyonun kritik yolunun dışında ayrı bir pipeline olarak ele aldım (format, kalite, fps ayarları `panoptic.yaml` üzerinden yapılandırılabiliyor). Böylece kayıt cihazı, otomasyonla birlikte çalışıyor, onun içinde değil. Ayrıca baştan itibaren kancalar ve eklenti sistemiyle genişletilebilir olmasını sağladım, çünkü otomasyonda kesin olan tek şey, birinin benim öngörmediğim bir şey yapmak isteyeceği —ve çerçevenin buna izin vermesi gerektiği, çatallamaya zorlamaması.
