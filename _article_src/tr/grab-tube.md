---
title: GrabTube
slug: grab-tube
repo: https://github.com/vasic-digital/GrabTube
tech: Dart/Flutter
teaser: "One yt-dlp backend, five native clients — download from 1000+ sites on web, Android, iOS, Windows, macOS and Linux, even by scanning a QR code."
---

## Kanca

`yt-dlp`, dünyanın en yetenekli video indiricisi ve bir komut satırı aracı. Çoğu insan için bu bir engel. GrabTube bu engeli yıkıyor: o arka ucu cilalı, çok platformlu bir uygulamaya dönüştürerek herkesin YouTube ve binden fazla başka siteden kalite seçimi, format tercihi ve canlı ilerleme ile indirme yapmasını sağlıyor. Mobilde ise kameranızı bir QR koduna doğrultmanız yeterli — indirme başlıyor. GrabTube, modern bir arayüz ve kullanıcı deneyimiyle baştan sona evrensel bir Tube hizmetleri indiricisi.

## Neden büyüleyici?

Mimari, asıl kanca. GrabTube, birçok istemciyi besleyen güçlü bir arka uç. Orijinal web arayüzü Python (aiohttp) ve Angular 19 ile geliştirilmiş. Ardından, tek bir kod tabanından Android, iOS, Windows, macOS ve Linux’a *yerel* olarak sunulan, Dart ile yazılmış bir Flutter 3.24+ istemcisi geliyor. Web ve Flutter istemcilerinin tümü aynı yt-dlp motoruyla konuşuyor. Böylece zorlu indirme mantığı tek bir yerde kalırken, kullanıcıya sunulan deneyim elinizdeki cihaza en doğal şekilde uyum sağlıyor.

Flutter istemcisi, işin gerçekten eğlenceli kısmı. Arka planda indirme yaparken bildirimler gönderiyor, çevrimdışı kuyruk sunuyor, uyarlanabilir temalı Material Design 3 kullanıyor, her platformda yerel performans sergiliyor ve kamera entegrasyonuyla QR kod tarama özelliği sayesinde ekrandaki bir bağlantı tek hareketle indirmeye dönüşüyor. Sürekli entegrasyon/sürekli teslimat (CI/CD) hattına sahip, %80’in üzerinde test kapsamı ve yapay zeka doğrulamasıyla — bir indirici için nadir görülen bir cilaya sahip. Ayrıca ShareConnect ekosistemiyle entegre çalışarak evrensel bağlantı paylaşımı, cihazlar arası senkronize kuyruklar ve geçmiş sunuyor.

## Zorlu sorunlar

İlk zorluk, "1000’den fazla siteden" indirme yapmanın doğası gereği hareketli bir hedef olması. Sitelerin düzenleri değişiyor, formatlar çoğalıyor, çıkarma işlemleri bozuluyor. GrabTube’un çözümü mimari alçakgönüllülük: çıkarma işlemini yeniden uygulamak yerine yt-dlp’ye güveniyor ve kendi çabasını indirme *çevresindeki* her şeye —kuyruklama, ilerleme takibi, format müzakeresi ve sunum— odaklıyor.

İkincisi, tek bir Dart kod tabanından gerçek çok platformluluk. "Bir kere yaz, her yerde çalıştır" kolay söylenir ama ayrıntılarda acımasızdır: arka planda çalışma ve bildirimler Android, iOS ve her masaüstü işletim sisteminde tamamen farklı işler; kamera/QR erişiminin her platformda ayrı izin modelleri vardır; dosya depolama ve indirme semantikleri her yerde farklılaşır. Beş platformda tek bir Flutter kod tabanıyla yerel performans sunmak, tüm bu farklılıkları temiz bir arayüzün altında eritmek anlamına geliyor.

Üçüncüsü, arka uç sözleşmesi. Bir Angular web uygulaması ve bir Flutter uygulaması gibi farklı istemcilerin aynı aiohttp servisine bağlanması durumunda, API’nin istikrarlı bir dikiş noktası olması gerekiyor — gerçek zamanlı ilerleme, kuyruk durumu ve geçmiş, her istemcinin bunları nasıl işlediğinden bağımsız olarak sorunsuz akmalı.

## Oyunu değiştiren ne?

Oyunu değiştiren, yeniden yazmaya gerek kalmadan erişim sağlaması. Çoğu indirme aracı bir yola girer — web arayüzü, masaüstü uygulaması ya da mobil uygulama. GrabTube ise seçim yapmayı reddediyor: aynı yetenek, web arayüzü, yerel mobil uygulama ve yerel masaüstü uygulaması olarak karşınıza çıkıyor, hepsi aynı motorla destekleniyor. QR tarama akışı ve ShareConnect aracılığıyla cihazlar arası senkronizasyon eklenince, indirme artık cihaza bağlı bir angarya olmaktan çıkıp, dizüstü bilgisayar ekranından cebinizdeki telefona kadar sizi takip eden akıcı bir deneyime dönüşüyor.

Ayrıca çoğu araçta asla ulaşılmayan bir standarda tabi tutulmuş. %80’in üzerinde test kapsamına sahip, yapay zeka destekli doğrulamalı, otomatik CI/CD hattına sahip üretime hazır bir Flutter istemcisi, GrabTube’un bir hafta sonu betiği gibi zamanla çürümek yerine, bakımı yapılmış bir yazılım gibi davranmasını sağlıyor.

## En zor kısımları nasıl çözdüm?

Temel karar, yt-dlp’yi indirme konusunda tek gerçek kaynak olarak kabul etmek ve onunla mücadele etmemek oldu. Çıkarma işlemini arka uç tarafından çözülmüş bir sorun olarak ele alarak, her istemcinin tamamen deneyime odaklanmasını sağladım — ve projeyi dayanıklı hale getirdim, çünkü bir site değiştiğinde çözüm yukarı akışta kalıyor, beş farklı arayüze dağılmıyor.

Çok platformluluk için Flutter ve Dart’a bağlandım, böylece tek bir kod tabanı Android, iOS, Windows, macOS ve Linux’a yerel olarak gidebildi. Ardından gerçekten platforma özgü konuları —bildirimli arka planda indirme, çevrimdışı kuyruk, kamera tabanlı QR tarama, uyarlanabilir Material Design 3 temalandırma— platformların aynı olduğunu varsaymak yerine bilinçli yerel entegrasyonlar olarak ele aldım. İşte bu, her yerde *çalışan* bir Flutter uygulaması ile her yerde *yerel hissettiren* bir uygulama arasındaki fark.

aiohttp arka ucunu temiz, istemciden bağımsız bir API olarak tutarak Angular web istemcisi ve Flutter istemcisinin bağımsız olarak gelişebilmesini sağladım, böylece aynı indirme davranışı, gerçek zamanlı ilerleme ve geçmiş paylaşılabildi. GrabTube’u ShareConnect ekosistemiyle entegre ederek, bir cihazda paylaşılan bir bağlantının başka bir cihazda senkronize bir kuyruğa akmasını sağladım — böylece bir indirici, bağlı ve cihazlar arası bir iş akışının parçası haline geldi. Son olarak, Flutter istemcisini %80’in üzerinde kapsama, yapay zeka doğrulaması ve CI/CD hattıyla tutarak, insanların medyalarını indirmek için güvendiği bir aracın da aynı şekilde test edilmesi gerektiğini düşündüm.
