---
title: Mail Server Factory
slug: mail-server-factory
repo: https://github.com/Server-Factory/Mail-Server-Factory
tech: Shell/Go
teaser: "Describe your mail server in one JSON file; it provisions a hardened, Dockerized stack on 25 Linux distros across 12 connection types."
---

## Kanca

Kendi posta sunucunuzu çalıştırmak, sistem yönetiminin en çekilmez işlerinden biri olarak haklı bir üne sahiptir: SMTP, IMAP, POP3, TLS, DKIM, SPF, güvenlik duvarları, sertifikalar, SELinux ve birbirleriyle anlaşmak zorunda olan bir düzine servis — yoksa hiçbir şey teslim edilmez. **Mail Server Factory**, bu konudaki yaklaşımıyla göz kamaştırıyor: *"Posta Sunucunuzu Patron Gibi Yönetin."* Ne istediğinizi basit bir JSON dosyasıyla tanımlarsınız, Factory de bu dosyayı yorumlayıp hedef makinede tüm sertleştirilmiş, Docker tabanlı yığını sizin için kurar.

## Neden büyüleyici?

Asıl büyüleyici fikir, posta sunucusu dağıtımını bir *derleme* problemi olarak ele alması. JSON yapılandırması kaynak kod; Factory derleyici; hedef işletim sisteminde çalışan, gevşek bağlı, Docker tabanlı posta yığını ise çıktı. Her bileşen gevşek bağlı ve konteynerleştirildiği için, sonuç ileride ölçeklendirme için temiz bir temel sunar — elle düzenlenmiş, kimsenin dokunmaya cesaret edemediği karmaşık yapılandırma dosyaları yerine.

Bunu "ilginç"ten "ciddi"ye taşıyan şey ise erişim alanı. Factory, bu yığını 12 farklı bağlantı türü üzerinden teslim edebiliyor: SSH, Docker, Kubernetes, AWS SSM, Azure Serial Console, GCP OS Login, Libvirt, özel bir protokol, veritabanı, dosya sistemi, bulut sağlayıcıları ve konteyner çalışma ortamları. Hedeflediği 25 Linux dağıtımı arasında çoğu araç tarafından göz ardı edilenler de var: Batı’nın önde gelenleri (Ubuntu, Debian, CentOS, Fedora, AlmaLinux, Rocky, openSUSE), Rus dağıtımları (ALT, Astra, ROSA) ve Çin menşeli olanlar (openEuler, openKylin, Deepin). Bu genişlik kasıtlı bir duruş: posta sunucunuz, donanımınız, yetki alanınız.

## Zorlu sorunlar

İlk zorluk, "aynı kurulum"un asla aynı olmaması. Paket adları, başlatma sistemleri, güvenlik duvarı arayüzleri ve SELinux davranışları 25 dağıtımda birbirinden farklı. Factory, tam da bu nedenle gerçek bir güvenlik altyapısı taşıyor: `CertificateValidator`, `DockerCredentialsManager`, `SELinuxChecker`, `PasswordValidator` ve `ConnectionPool` — çünkü bu endişelerin her biri platforma göre farklı davranıyor ve varsayılan olarak kabul edilemez.

İkinci zorluk, bağlantı katmanının kendisi. Hedefe SSH üzerinden ulaşmak, AWS SSM, Azure Serial Console ya da Libvirt üzerinden ulaşmaktan tamamen farklı. Her taşıma yönteminin kendine özgü kimlik doğrulaması, gecikme süresi ve hata modları var. Tüm bu 12 bağlantı türünü tek bir kurulum hattının arkasına gizleyerek — kurulum adımlarının baytların kutuya nasıl ulaştığıyla ilgilenmemesini sağlayarak — projenin mimari omurgası oluşturulmuş.

Üçüncü zorluk ise temiz bir makineye ulaşmak. Factory, bu dağıtımların tamamında otomatik ve insansız işletim sistemi kurulumunu preseed, kickstart, cloud-init ve autoyast aracılığıyla gerçekleştiriyor; `scripts/qemu_manager.sh` ile QEMU sanal makinelerini yönetiyor ve ISO dosyalarını checksum doğrulamasıyla birlikte, kurumsal bir dokunuşla ele alıyor: Eksik görüntüleri ağ paylaşımından çeken, eksik olanları geri yükleyen ve son çare olarak internetten indirme yapan çift yönlü bir SMB önbelleği. Böylece aynı görüntü 25 kez yeniden indirilmek zorunda kalmıyor.

## Oyunu değiştiren özellik

Asıl oyun değiştirici, kendi barındırdığınız postayı *tekrarlanabilir ve denetlenebilir* hale getirmesi. E-posta altyapısı, tam da veri olarak tanımlanıp aynı şekilde yeniden oluşturulmasını istediğiniz türden bir şey — gece yarısı 2’de hafızaya dayanarak bir araya getirilen bir yapı değil. Yığın JSON ile tanımlandığında ve güvenlik duruşu kodla zorunlu kılındığında — AES-256-GCM şifreleme, en az 12 karakterlik zorunlu SSH anahtar parolaları, 25/587/465/993/995 portları için otomatik güvenlik duvarı kuralları, sertifika doğrulamalı TLS ve HSTS, denetim günlükleri ve RBAC — "üretim seviyesinde posta sunucusu" haftalar süren bir proje olmaktan çıkıp, inceleyebileceğiniz, sürümleyebileceğiniz ve yeniden çalıştırabileceğiniz bir yapılandırmaya dönüşüyor.

Ayrıca bu araç, sadece iddialı değil, titizlikle doğrulanmış: Proje, 439 testin %100 başarıyla geçtiğini, SonarQube kalite kapısının %100 sağlandığını ve dağıtımlar arasında gerçek SMTP/IMAP/POP3 davranışlarını, verim ve gecikme ölçümlerini içeren eksiksiz bir test çerçevesini raporluyor. Tüm işi e-postanıza güvenmek olan bir araç için, bu kanıtlar en önemli özellik.

## En zor kısımları nasıl çözdüm?

*Ne inşa edileceğini*, *hedefe nasıl ulaşılacağını* ve *hangi işletim sistemi üzerinde çalışıldığını* birbirinden ayırdım. JSON yapılandırması niyeti tanımlar; taşıma soyutlaması, 12 bağlantı türünü tek bir arayüzün arkasına gizleyerek kurulum adımlarının, ister SSH ister AWS SSM üzerinden olsun, aynı mantıksal işlemleri gerçekleştirmesini sağlar; dağıtıma özel mantık ise 25 dağıtım matrisinin tek bir yerde toplanmasını ve her adıma sızmamasını garanti eder. Bu katmanlı yapı sayesinde yeni bir dağıtım veya bağlantı türü eklemek, tüm kod tabanını etkilemez.

Güvenlik konusunda operatörün iyi niyetine hiçbir şey bırakmadım. Çerçeve, zor kısımları zorunlu kılıyor — SELinux’u *kontrol ediyor*, sertifikaları *doğruluyor*, Docker kimlik bilgilerini *yönetiyor* ve zayıf parolaları ya da parola korumasız SSH anahtarlarını *reddediyor* — böylece doğru bir dağıtım varsayılan haline geliyor, özenli bir başarı değil. Ağır sağlama işlemleri için kabuk betikleri doğru araç olarak kullanılırken, orkestrasyon ve güvenlik çerçevesi için Kotlin/JVM mantığı devreye giriyor; Docker ise her bileşeni gevşek bağlı tutuyor.

En çok göz ardı edilen "temiz makine" önyükleme sorununu da çözdüm: Desteklenen her dağıtım için otomatik kurulumlar, test hedefleri için QEMU otomasyonu ve aynı görüntünün 25 kez yeniden indirilmesini önleyen çift yönlü SMB ISO önbelleği — her ISO, nereden gelirse gelsin checksum doğrulamasıyla kontrol ediliyor. Sonuç, tek bir dosyadan çıplak metal (ya da boş bir sanal makine) üzerinden sertleştirilmiş, test edilmiş ve çalışır durumda bir posta sunucusuna kadar uzanan bir araç.
