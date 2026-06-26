---
title: Android Toolkit
slug: android-toolkit
repo: https://github.com/vasic-digital/Android-Toolkit
tech: Kotlin
teaser: "The reusable foundation under my Android apps — drop-in modules from root shells to interprocess comms, added as one git submodule."
---

## Kanca

Her ciddi Android geliştiricisi, zamanla aynı "bunu daha önce yazmıştım" kod yığınını biriktirir: makul bir test altyapısı, bir loglama arayüzü, root erişim yardımcıları, süreçler arası iletişim altyapısı, daire şeklinde ImageView, alfabetik hızlı kaydırıcı. Android Toolkit, bu yığını temiz, modüler bir kütüphaneye dönüştürür — hemen kullanmaya başlayabileceğiniz, sıkça ihtiyaç duyulan soyutlamalar, uygulamalar ve araçlardan oluşan bir set. Göz alıcı uygulamaların arkasında yatan, gözden uzak ama vazgeçilmez temeldir.

## Neden büyüleyici?

Büyüleyici olan, *sınırlama* mimarisidir. Toolkit, odaklanmış ve bağımsız olarak dahil edilebilen modüllere ayrılmıştır — `Main`, `Test`, `Echo`, `Access`, `JCommons`, `RootTools`, `RootShell`, `Interprocess`, `CircleImageView`, `ConnectionIndicator`, `FastscrollerAlphabet` — ve ihtiyacınız olanları `settings.gradle` ve `build.gradle` üzerinden bağlarsınız. Tek parça bir kütüphane yok, tek bir yardımcı için bütün bir mutfak lavabosunu sürüklemenize gerek yok. Bu ayrıntı düzeyi, gerçek bir tasarım kararıdır: her modül, kendi başına yerini hak eder.

Ayrıca bir yayınlanmış kütüphane yerine git alt modülü olarak sunulması, ne için tasarlandığını gösterir. Bu, bir geliştiricinin kendi Android çalışmaları portföyündeki ortak omurgadır — birden fazla uygulamanın aynı şekilde davranmasını, senkronize olarak gelişmesini sağlayan, projeler arasında kopyala-yapıştır sapmalarını önleyen tutarlı temel katman. Modüller, düşük seviyeli sistem erişiminden (root kabukları ve araçları) süreçler arası iletişime, hazır UI bileşenlerine kadar alışılmadık derecede geniş bir yelpazeyi kapsar. Bu da Toolkit’in hem güç kullanıcılarına yönelik bir sistem uygulamasına hem de şık bir tüketici arayüzüne hizmet edebileceği anlamına gelir.

## Zorlu sorunlar

İlk zorlu sorun, modülerlik sözleşmesidir. Seçmeli bir modül sisteminin gerçekten işe yaraması için sınırların dürüst olması gerekir — `RootShell` ve `RootTools`, gizlice bir UI bileşenine bağımlı olamaz; `Interprocess`, test altyapısını sürükleyemez. Gradle aracılığıyla gerçekten bağımsız ama temiz bir şekilde birleşen modüller tasarlamak, tek parça büyük bir kütüphane oluşturmaktan daha zordur, çünkü her birleşim noktası bir taahhüttür.

İkincisi, Android’in tehlikeli köşeleridir. Root erişimi (`RootShell`, `RootTools`) ve süreçler arası iletişim (`Interprocess`), hataların güvenlik açıklarına ya da uygulamalar arası çökmelere dönüştüğü alanlardır. Ayrıcalıklı kabukları ve IPC’yi güvenli ve ergonomik — doğru kullanımı kolay, felaketle sonuçlanacak kullanımı zor — soyutlamalarla sarmak, ekran görüntüsünde görünmeyen ama üstündeki uygulamaların güvenilir olup olmadığını belirleyen türden bir iştir.

Üçüncüsü, aynı anda birçok proje için temel olmaktır. Alt modül aracılığıyla birden fazla uygulama tarafından tüketilen bir araç setinin evrimi dikkatli olmalıdır: paylaşılan bir soyutlamadaki bir değişiklik her yere yansır. Bu yüzden Toolkit, özel bir `Test` modülü sunar ve test bağımlılıklarını (`testImplementation`, `androidTestImplementation`) birinci sınıf bir endişe olarak ele alır — temel, test edilebilir olmalı ve onun üzerine inşa edilen uygulamalar da onun aracılığıyla test edilebilir olmalıdır.

## Oyunu değiştiren ne?

Oyunu değiştiren, kaldıraç etkisidir. Bu tür yeniden kullanılabilir altyapı, bir mühendisin ShareConnect ekosistemi, Yole ve daha fazlası gibi bir bütün Android uygulama ailesini inandırıcı bir şekilde sürdürebilmesini sağlar — her seferinde temelleri yeniden inşa etmeden. Toolkit, "yaygın Android sorunlarını" çözülmüş, paylaşılan, sürüm kontrolü altında modüllere dönüştürür. Böylece her yeni uygulama daha yüksek bir zeminden başlar ve varsayılan olarak loglama, test, sistem erişimi ve UI ilkellerinde tutarlılık miras alır.

Alt modül dağıtım modeli bu etkiyi daha da artırır: bir uygulama geliştirilirken yapılan iyileştirmeler Toolkit’e geri akar ve diğer uygulamalara anında fayda sağlar. Bu, bileşik bir yatırımdır — temel, her kullanıldığında daha da güçlenir.

## En zor kısımları nasıl çözdüm?

İlk satırdan itibaren seçime dayalı bir tasarım yaptım. Toolkit’i dar kapsamlı Gradle modüllerine ayırıp *yalnızca ihtiyacınız olanları* dahil etmenizi belgeleyerek, kütüphaneyi dayatmacı değil, eklemeli hale getirdim — bir proje `RootShell` ve `Interprocess`’i çekerken asla kullanmayacağı bir UI bileşenini miras almaz. Modül listesini `settings.gradle`’de açıkça tutmak, bağımlılık yüzeyini görünür ve bilinçli kılar, sihirli değil.

Tehlikeli köşeler için ayrıcalığı ve IPC’yi kendi modüllerine ayırdım — root erişimi için `RootShell`/`RootTools`, süreçler arası iletişim için `Interprocess` — böylece riskli kod, bilinçli olarak geçilmesi gereken bir sınırın arkasında kalır, varsayılan olarak her tüketiciye sızmaz. Bu izolasyon, Toolkit’in geri kalanının geniş çapta güvenle bağımlı olunabilecek şekilde kalmasını sağlar.

Ve testi bir sonradan akıl değil, temelin bir parçası olarak ele aldım: bir `Test` modülü sunmak ve standart `testImplementation`/`androidTestImplementation` bağlantılarını sağlamak, Toolkit üzerine inşa edilen her uygulamanın kutudan çıktığı gibi tutarlı bir test kurulumuna sahip olmasını sağlar. Paylaşılan soyutlamalardaki değişiklikler, portföy genelinde yansımalarından önce doğrulanabilir. Bütün bunlar, tam da temel ve onun üzerine kurulan uygulamaların birlikte ilerleyebilmesi için alt modül olarak sunulur — tek bir temel, birçok ürün, hiçbir sapma olmadan.
