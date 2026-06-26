---
title: ShareConnect
slug: share-connect
repo: https://github.com/vasic-digital/ShareConnect
tech: Kotlin
teaser: "Share any media link from your phone straight to your own download stack — 20 production-ready apps, eight things kept in sync across all of them."
---

## Kanca

Elinize bir video, bir torrent, saklamaya değer bir dosya geçer — telefonda, tarayıcıda, bir sohbette. Sonra sürtünme başlar: bağlantıyı kopyala, cihaz değiştir, doğru istemciyi bul, yapıştır, ayarla, umut et. ShareConnect bunu ortadan kaldırır. Android’in yerel paylaşım menüsüne entegre olur; böylece indirilebilir her URL doğrudan *sizin* altyapınıza — MeTube, YT-DLP, qBittorrent, Transmission, jDownloader ve daha fazlasına — gider, içerik keşfini kendi indirme hizmetlerinize bağlar. İsim, tezdir: **paylaş** ile **bağlan** buluşur.

## Neden büyüleyici?

ShareConnect tek bir uygulama değil; kasıtlı bir üç aşamalı planla hayata geçirilmiş, 20 üretime hazır Android uygulamasından oluşan bir ekosistem. Birinci aşama çekirdek: ana ShareConnector artı qBittorrent, Transmission ve uTorrent için özel istemciler. İkinci aşama sekiz bulut hizmetini ekler — JDownloader (MyJDownloader API üzerinden), MeTube, YT-DLP (1800’den fazla yayın sitesini destekleyen), Nextcloud, FileBrowser, Plex, Jellyfin ve Emby. Üçüncü aşama, Seafile, Syncthing, Matrix, Paperless-NG, Duplicati, WireGuard, bir Minecraft sunucu denetleyicisi ve OnlyOffice dahil olmak üzere sekiz uzmanlaşmış hizmetle tamamlanır.

Asıl ilginç mühendislik ise altında yatan senkronizasyon dokusu. ShareConnect, ekosistemdeki her uygulamada sekiz farklı unsuru senkronize halde tutar: tema, profiller, geçmiş, RSS beslemeleri, yer imleri, tercihler, dil ve torrent paylaşım durumu. Böylece ana uygulamadaki temanız qBitConnect’teki temanız olur; indirme geçmişiniz sizinle birlikte hareket eder; profilleriniz her yerde tutarlıdır. Yirmi uygulama tek bir ürün gibi hissettirir.

## Zorlu sorunlar

İlk zorlu sorun, entegrasyonların genişliği. Her arka uç — qBittorrent, Transmission, jDownloader, Plex, Jellyfin, Nextcloud, Matrix, Syncthing — kendi API’sine, kimlik doğrulama modeline ve tuhaflıklarına sahip. Hedef protokollerini doğru konuşan, aynı zamanda bakımını sürdürülebilir kılacak kadar ortak bir iskeleti paylaşan 20 istemci oluşturmak, kodlamadan çok bir disiplin meselesi.

İkincisi, uygulamalar arası senkronizasyonun kendisi. Birçok ayrı yüklü Android uygulaması arasında sekiz farklı durum kategorisini senkronize etmek, tek bir cihazda ve ötesinde gerçek dağıtık sistem sorularını çözmeyi gerektirir: bağımsız uygulamalar birbirlerini nasıl keşfeder, ortak durumu nasıl kabul eder ve birbirlerinin ayaklarına basmadan değişiklikleri nasıl uzlaştırır? Tema, profiller, geçmiş, RSS, yer imleri, tercihler, dil ve torrent paylaşımı, her biri farklı güncelleme kalıplarına ve çakışma anlamsallıklarına sahip.

Üçüncüsü, her şeyin çalıştığını kanıtlamak. Yirmi uygulama ve ortak bir senkronizasyon katmanıyla test yüzeyi devasa — ve proje bundan kaçınmaz: birim, enstrümantasyon ve otomasyon test paketlerinde %100 başarı oranı, yapay zeka destekli bir kalite güvence geçişi, A+ SonarQube notu, kritik Snyk güvenlik açığı yok, ~%95 kod kapsamı ve %0,2 teknik borç oranı raporlar. Tüm bir ekosistemde bu çıtayı korumak, çoğu projenin sessizce atladığı zor kısımdır.

## Oyunu değiştiren ne?

Oyunu değiştiren, ödünsüz bir şekilde kendi sunucunuzda kolaylık sağlaması. Ticari "cihazlarıma gönder" özellikleri sizi başkasının bulutuna kilitler. ShareConnect, aynı tek dokunuşluk kolaylığı *sizin* sahip olduğunuz altyapıya — torrent istemcinize, medya sunucunuza, Nextcloud’unuza — yönlendirir ve Android’de yerel hissettirir. Dağınık bir kendi sunucunuzdaki hizmetler koleksiyonunu, tek, tutarlı, paylaşılabilir bir yüzeye dönüştürür.

Ve senkronizasyon katmanı bağ dokusu olduğundan, ekosistem zarifçe ölçeklenir: qBitConnect veya TransmissionConnect gibi bir eşlikçi istemci, bir silo değil, paylaşılan temayı, profilleri ve geçmişi otomatik olarak devralır. Tüm sistem modern bir Android yığını üzerine inşa edilmiştir — Kotlin 2.0, Java 17, Android API 26+ — yani bu bir kavram kanıtı değil; 20 uygulama üretime hazır olarak işaretlenmiştir.

## En zor kısımları nasıl çözdüm?

Senkronizasyon dokusunu bir özellik değil, ürünün çekirdeği olarak ele aldım. Her uygulamaya senkronizasyonu sonradan eklemek yerine, her uygulamanın ekosisteme bağlandığı ayrı, paylaşılan senkronizasyon modülleri — ThemeSync, ProfileSync, HistorySync, RSSSync, BookmarkSync, PreferencesSync, LanguageSync ve TorrentSharingSync — olarak inşa ettim. Bu karar, yeni bir istemcinin tutarlılığı "bedavaya" elde etmesinin nedenidir: modülleri yeniden icat etmek yerine benimser.

Entegrasyon çeşitliliği için ise bir bağlayıcı deseni kullandım: her arka uç (qBittorrent, Transmission, MeTube, YT-DLP, JDownloader, Plex ve diğerleri), ortak bir sözleşme arkasında kendi içinde tutarlı bir bağlayıcı modülüdür; böylece 20 istemci hem bireysel olarak doğru hem de toplu olarak bakımı yapılabilir kalır. Yayınlamayı aşamalandırmak — önce çekirdek istemciler, sonra bulut hizmetleri, ardından uzmanlaşmış olanlar — her katmanın bir sonrakine dayanmadan önce istikrara kavuşmasını sağladı.

Son olarak, kalitenin yüzey büyüdükçe aşınmasına izin vermedim. %100 geçen birim, enstrümantasyon ve otomasyon paketleri artı yapay zeka destekli kalite güvence aşaması, gösteriş için değil; 20 uygulamalı bir ekosistemin, ortak bir senkronizasyon katmanıyla kendi regresyon ağırlığı altında çökmesini önlemenin tek yoludur. Tümünde ~%95 kapsama ve %0,2 teknik borç oranını korumak, projenin bu 20 uygulamadan her birini güvenle üretime hazır ilan etmesini sağladı.
