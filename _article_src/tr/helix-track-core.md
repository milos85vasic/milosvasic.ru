---
title: HelixTrack Core
slug: helix-track-core
repo: https://github.com/Helix-Track/Core
tech: Go, Gin, PostgreSQL, SQLite, SQLCipher, PLpgSQL, WebSocket
teaser: "The open-source JIRA alternative — extreme-performance issue tracking with military-grade encryption and a single action-routed API."
---

## Kanca

JIRA ve Confluence’u sıfırdan, tek bir Go mikrohizmeti olarak yeniden inşa ettiğinizi, altında şifreli bir veritabanıyla saniyede on binlerce isteği işleyebilecek kadar hızlı hale getirdiğinizi düşünün. İşte HelixTrack Core bu: *"Özgür Dünyanın Açık Kaynaklı JIRA Alternatifi."* Basit bir taklit değil — epikler, alt görevler, sprintler, çalışma kayıtları, özel alanlar, kontrol panelleri, izin şemaları ve tek bir REST API’nin arkasında çalışan tam bir Confluence tarzı belgeler motoru sunuyor.

## Neden büyüleyici?

Çoğu proje takip aracı, yıllar içinde düzinelerce uç noktaya sahip, birbirinden kopuk devasa monolitlere dönüşür. Ben tam tersini yaptım. HelixTrack Core, **eylem tabanlı yönlendirme** sunan tek bir `/do` uç noktası sunuyor: İstemciler bir eylem adı ve yük gönderir, sunucu da bunu tutarlı bir ara katman ve işleyici hattından geçirir. Bu tek tasarım kararı, yüzlerce işlemi — sorunlar, çevik panolar, oylama, bildirim şemaları, etkinlik akışları, yorum bahsetmeleri — uç nokta karmaşası olmadan tutarlı bir API yüzeyi altında tutmayı sağlıyor. Büyük API’lerin bakımını imkansız hale getiren dağınıklığı önlüyor.

Bunun üzerine gerçek bir Confluence alternatifi geliyor. Belgeler V2 eklentisi, alanlar, HTML/Markdown/düz metin destekli zengin sayfalar, tam sürüm geçmişi (farklar ve geri alma dahil), satır içi yorumlar, @bahsetmeler, tepkiler, şablonlar ve analizler sunuyor — her biri kendi veritabanı tablolarıyla destekleniyor ve yüzlerce model testi ile doğrulanıyor. Böyle bir sistemi tek başına inşa etmek bir proje; ikisini de tek bir ikili dosya içinde işbirliği yapan modüller olarak kurmak ise asıl ilginç olan kısım.

## Zorlu sorunlar

Bu projeyi gerçekten zor kılan üç şey var.

Birincisi, **performans kaybı olmadan güvenlik**. Kurumsal sorun takip sistemleri hassas veriler barındırır, bu yüzden veritabanı SQLCipher (AES-256) ile dinlenme halinde şifrelenir. Şifreleme genellikle gecikme cezası anlamına gelir — mühendislik açısından zorluk, bu ek yükü minimumda tutarken aynı zamanda yoğun eşzamanlılık altında sorguları hızlı bir şekilde sunabilmekti.

İkincisi, **çoklu veritabanı gerçeği**. Geliştiriciler, yerel kurulumda sürtünmesiz bir deneyim için SQLite ister; üretim ortamı ise eşzamanlılık ve dayanıklılık için PostgreSQL talep eder. Her ikisini de desteklemek — PLpgSQL düzeyinde optimizasyonlar ve doksan tablonun üzerine çıkan, birden fazla sürümlü geçişle (V1’den V4’e) evrilen bir şema dahil — her özelliğin iki çok farklı motor üzerinde doğru çalışmasını gerektiriyor.

Üçüncüsü, **doğrulukla gerçek zamanlı işbirliği**. Aynı anda birden fazla kişi aynı bileti düzenlediğinde, klasik dağıtık durum sorunuyla karşılaşırsınız: kaybolan güncellemeler ve çakışan yazımlar. Kullanıcıları birbirlerinin işini engellemeden bu sorunu çözmek, sonradan akla gelen bir çözüm değil, bilinçli bir eşzamanlılık modeli gerektirir.

## Oyun değiştiren özellikler

HelixTrack Core, izinleri birinci sınıf, değiştirilebilir bir motor olarak ele alır. **Bağlamsal hiyerarşik izinler** ile miras alma özelliği sunar ve izin uygulaması takılabilir yapıdadır — hizmet içinde yerel olarak çalıştırabilir ya da harici bir HTTP yetkilendirme hizmetine devredebilirsiniz. Bu ayrım, kuruluşların izleyiciyi mevcut kimlik ve politika altyapısına entegre etmesini sağlar, yerleşik bir modelle mücadele etmek yerine.

Çoğu izleyicinin göz ardı ettiği bir şeyi daha yapar: **otomatik hizmet keşfi**. İstemciler, yerel ağda UDP yayını ile Core sunucularını bulur, böylece çok platformlu istemciler (web, masaüstü, Android, iOS) manuel yapılandırmaya gerek kalmadan bağlanabilir. JWT kimlik doğrulaması, Zaman Takibi, Belgeler ve Sohbet için eklenti sistemi ve commit’leri biletlere eşleyen Git entegrasyonu ile tek bir uygulama gibi değil, bir platform gibi davranır.

## En zor kısımları nasıl çözdüm?

API için erken aşamada **eylem yönlendirme modeline** bağlı kaldım. Her işlem aynı `/do` yaşam döngüsünden geçer — kimlik doğrulama ve izin ara katmanı, ardından eylem adına göre anahtarlandırılmış bir işleyici. İşte bu yüzden sistem, yeni yetenekler eklemeye devam edebiliyor (Faz 1 öncelikler ve çözümler, Faz 2 epikler ve çalışma kayıtları, Faz 3 oylama ve bildirim şemaları, Faz 4 paralel düzenleme) ve API parçalanmıyor. Yeni özellikler yeni eylemler kaydeder; taşıma katmanı ve ara katman sabit kalır.

Eşzamanlı düzenleme için **iyimser kilitleme ve sürüm çakışmaları** ile tam bir değişiklik geçmişi katmanı uyguladım. Her düzenlenebilir varlık bir sürüm taşır; eski bir sürümü hedefleyen bir yazım reddedilir ve istemcinin çözebileceği bir çakışmayla geri döner. V4 şemasında eklenen geçmiş tabloları, değişikliklerin tam izini kaydeder. Bunun üzerine açık varlık kilitleme yönetimi ve çakışma çözüm eylemleri ekledim, tüm bunları mevcut WebSocket katmanına bağladım, böylece işbirliği yapanlar canlı güncellemeleri görebilir. Bu, başkasının düzenlemesini sessizce ezmeden gerçek zamanlı işbirliği sağlar.

Şifreleme ve hız arasındaki gerilim için tasarım, depolama katmanında şeffaf AES-256 için SQLCipher’a dayanırken, sıcak yolları önbelleğe alarak yaygın okuma kalıplarının şifreli bir depolama altında bile hızlı kalmasını sağlar. Kod tabanı, fazlar boyunca binlerce otomatik testle desteklenir — bu da doksandan fazla tablolu bir şema, şifreli, çoklu veritabanlı ve eşzamanlı düzenlemeli bir sistemde değişiklik yaparken bile davranışın tutarlı kalacağına güvenmemi sağlar. Mimari diyagramları, kullanım kılavuzu ve dağıtım rehberi, kodla birlikte sunulur, çünkü kimsenin kullanamayacağı bir JIRA alternatifi, alternatif değildir.
