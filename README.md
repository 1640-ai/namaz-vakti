# Namaz Vakti

macOS menü çubuğunda bir sonraki namaza kalan süreyi gösterir. Saat, dakika ve saniye olarak.

Vakitler Diyanet İşleri Başkanlığı verisine dayanır.

> Bu proje resmi değildir. Diyanet İşleri Başkanlığı ile bağlantısı yoktur.

## Amaç

Namaz vaktini takip etmek için telefona veya web sitesine bakmak gerekmez.
Bir sonraki vakte kalan süre her zaman menü çubuğunda görünür.
Proje açık kaynaktır. Reklam, hesap ve takip yoktur.

## Nasıl çalışır

1. Uygulama seçili ilçenin yaklaşık 30 günlük vakitlerini indirir ve cihazda saklar.
2. Her saniye şimdiki zamanı bir sonraki vakitle karşılaştırır. Farkı menü çubuğuna yazar.
3. Yatsıdan sonra bir sonraki vakit ertesi günün İmsak vaktidir.
4. Konum otomatik modda, IP adresinden şehir bulunur. Şehir Diyanet listesiyle eşleştirilir.
5. Seçimler `UserDefaults` içinde saklanır. Başka hiçbir veri kaydedilmez.

Kod: Swift, AppKit ve SwiftUI. Dış kütüphane yoktur.

## Özellikler

- Menü çubuğunda geri sayım: `İkindi 01:23:45`
- Tıklayınca açılır pencere: bugünün vakitleri
- Ülke, şehir ve ilçe seçimi
- İsteğe bağlı otomatik konum (internet bağlantısından, IP ile)
- Açılışta başlatma seçeneği
- Çevrimdışı çalışır (son indirilen vakitler saklanır)
- Ek kurulum yok. Tek `.app` dosyası.

## Kurulum

1. [Releases](../../releases) sayfasından `NamazVakti.zip` dosyasını indir.
2. Zip'i aç. `NamazVakti.app` dosyasını `Uygulamalar` klasörüne sürükle.
3. İlk açılışta `NamazVakti.app` üzerine sağ tıkla. `Aç` seç.

Uygulama imzasızdır. macOS ilk açılışta uyarı verir. Uyarı çıkarsa şu komutu çalıştır:

```sh
xattr -dr com.apple.quarantine /Applications/NamazVakti.app
```

Gereksinim: macOS 13 veya üstü.

## Kaynaktan derleme

Xcode veya Command Line Tools gerekir.

```sh
Scripts/build_app.sh
open dist/NamazVakti.app
```

## Gizlilik

Uygulama sadece iki servise bağlanır: vakit API'si ve (otomatik konum açıksa) `ipwho.is`.
Bu servisler IP adresini görür. Uygulama ad, e-posta veya başka kişisel veri toplamaz ve göndermez.

## Veri kaynağı

Uygulama vakitleri üçüncü kişinin işlettiği bir yansıma API'sinden alır: `ezanvakti.emushaf.net`.
Veri Diyanet İşleri Başkanlığı kaynaklıdır. Şehir ve ilçe kodları Diyanet ile aynıdır.
Bu servis resmi değildir. Kapanabilir veya değişebilir. Vakitler resmi siteden farklı çıkarsa resmi site geçerlidir: https://namazvakti.diyanet.gov.tr
Otomatik konum için `ipwho.is` servisi IP adresinden şehri bulur. Bu özellik kapalıyken konum istenmez.

## Kredi

Designed by [16:40](https://www.1640.com.tr/) | [Social](https://www.instagram.com/1640dijital/)

## Lisans

MIT
