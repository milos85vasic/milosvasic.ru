---
title: Catalogizer
slug: catalogizer
repo: https://github.com/vasic-digital/Catalogizer
tech: Go, Gin, React, TypeScript, SQLCipher, WebSocket, SMB/FTP/NFS/WebDAV
teaser: "Point it at your SMB, FTP, NFS, WebDAV and local shares — it auto-detects 50+ media types, survives disconnects, and stays encrypted."
---

## Kanca

Medya içerikleriniz her yerde — NAS üzerindeki bir SMB paylaşımında, bir FTP sunucusunda, bir NFS bağlamında, bir WebDAV sunucusunda, yerel bir sürücüde — ve hiçbir şey bunların tümünü aynı anda anlamıyor. **Catalogizer** anlıyor. Gelişmiş bir çok protokollü medya koleksiyonu yönetim sistemi olan Catalogizer, bu protokollerin her birindeki medyayı otomatik olarak tespit eder, kategorilere ayırır, düzenler, gerçek zamanlı olarak izler, harici meta verilerle zenginleştirir ve tüm katalogu şifrelenmiş bir veritabanında saklar.

## Neden büyüleyici?

Catalogizer, "koleksiyonunuzu" heterojen depolama alanlarına yayılmış tek bir mantıksal kütüphane olarak ele alır. **50’den fazla medya türünü** — filmler, TV dizileri, müzik, oyunlar, yazılımlar, belgeseller ve daha fazlasını — tanımlar ve her kaynağı sürekli olarak değişiklikler açısından izler, meta verileri otomatik olarak günceller. Geniş bir harici sağlayıcı yelpazesinden (TMDB, IMDB, TVDB, MusicBrainz, Spotify, Steam ve diğerleri) girişleri zenginleştirir, kaliteyi analiz eder, sürümleri takip eder ve büyüme eğilimleri gibi analitik verileri sunar.

Yazılım mimarisi net bir şekilde ayrılmış: Gin üzerinde yüksek performanslı bir Go REST API, Tailwind ile modern bir React/TypeScript ön yüz ve katalogdaki değişiklikler anında kullanıcı arayüzüne yansıyan WebSocket entegrasyonu. Altında ise veriler **SQLCipher ile şifrelenmiş** bir depoda saklanır. Kataloglamanın ötesine geçerek pratik ek özellikler sunar — PDF dönüştürme hizmeti, JSON ve CSV formatlarında favorilerin dışa/içe aktarımı, S3 ve Google Cloud Storage’a bulut senkronizasyonu ve grafiklerle profesyonel PDF raporlama.

## Zorlu sorunlar

En zor sorun **güvenilmez ağ depolama**. SMB ve benzeri protokoller kopabiliyor. Bağlantılar kaybolabiliyor. Naif bir kataloglayıcı, paylaşım çevrimdışı olduğunda hatalar fırlatır ve dünyaya dair görüşünü bozar. Catalogizer ise **protokol dayanıklılığı** için tasarlandı: geçici bağlantı kesintilerini zarifçe yönetir, otomatik olarak yeniden bağlanır ve çevrimdışı çalışma için önbellek kullanır; böylece sorunlu bir NAS tüm sistemi çökertmez. Buradaki belirleyici mühendislik kararı, başarısızlık durumunu istisna değil, norm olarak ele almaktır.

İkinci sorun, **çok farklı protokoller üzerinde tek bir soyutlama**. SMB, FTP, NFS, WebDAV ve yerel dosya sistemi her birinin kendine özgü semantikleri, tuhaflıkları ve hata modları var. Bunları, algılama motoru ve izleme sisteminin hepsini tek tip olarak ele alabileceği, tutarlı bir dosya sistemi istemci arayüzü üzerinden sunmak — macOS’ta tam NFS bağlama ve dosya işlemleri dahil — önemli bir entegrasyon çabası gerektirir.

Üçüncü sorun ise **güvenli ve ölçeklenebilir algılama**. 50’den fazla medya türünü güvenilir şekilde tanımak, birçok harici API’den zenginleştirme yapmak ve tüm bunları şifrelenmiş bir veritabanı üzerinden JWT tabanlı rol erişimiyle gerçekleştirmek — şifreleme veya API çağrılarının darboğaz haline gelmemesi için — özenli bir mimari gerektirir.

## Oyunu değiştiren özellikler

Çoğu medya yöneticisi dosyalarınızın yerel olduğunu ve ağınızın mükemmel çalıştığını varsayar. Catalogizer ise tam tersini varsayar ve yine de çalışır. **Çok protokollü erişim, dayanıklılık ve gerçek zamanlı izleme** kombinasyonu sayesinde, dağıtık ve kısmen erişilebilir bir koleksiyonu tek bir düzenli kütüphane gibi yönetir — ve bunu otomatik olarak güncel tutar, manuel yeniden taramaya gerek bırakmaz.

Varsayılan şifreleme, rol tabanlı erişim kontrolü, harici meta veri zenginleştirmesi ve gerçekten işe yarayan çıktı özellikleri (raporlar, dışa aktarımlar, bulut senkronizasyonu, PDF dönüştürme) eklendiğinde, artık bir katalog olmaktan çıkar ve protokoller ve makineler arasında dağılmış bir medya varlığını yöneten bir platforma dönüşür.

## En zor kısımları nasıl çözdüm?

**Dayanıklılığı depolama katmanının bir özelliği haline getirdim**, her bir özelliğin ayrı ayrı ele alması gereken bir şey olmaktan çıkardım. Çok protokollü dosya sistemi istemcileri, bağlantı kesintilerini tespit etmek, otomatik olarak yeniden bağlanmak ve bir kaynak erişilemez olduğunda çevrimdışı önbellekten hizmet vermekten sorumlu. Bu davranış istemci soyutlamasında yer aldığı için, izleme motoru ve algılama motoru üstünde, bir kaynağın her zaman erişilebilir olduğunu varsayabilir — kopan bir SMB bağlantısının karmaşık gerçekliği onların altında emilir.

Protokol çeşitliliğini kontrol altına almak için SMB, FTP, NFS, WebDAV ve yerel erişimi, macOS için gerçek NFS bağlama ve dosya işlemleri dahil olmak üzere, **tek bir dosya sistemi istemci arayüzü** altında birleştirdim. Medya algılama motoru bu tek arayüzün üzerinde çalıştığı için, bir protokol eklemek veya bir protokolün tuhaflıklarını düzeltmek, algılama mantığını etkilemez.

Canlı davranış için Go API, katalogdaki değişiklikler anında React ön yüze güncellemeleri ileten bir **WebSocket sunucusu** çalıştırır; böylece kullanıcıların gördüğü, izlenen kaynakların gerçek zamanlı yansıması olur, eski bir anlık görüntü değil. Güvenliği ise opsiyonel tutmadım: Veritabanı SQLCipher ile şifrelenmiş, API ise JWT ve rol tabanlı erişim kontrolü ile korunuyor; böylece birçok uzak paylaşıma ve harici API’ye erişen bir sistem, en zayıf halka haline gelmez. Sonuç, gerçek dünyanın gereksinimlerine göre tasarlanmış bir medya yöneticisi — dağıtık, kesintili ve dürüst ve güvenli tutulması gereken.
