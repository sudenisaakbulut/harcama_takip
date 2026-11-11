# Harcama Takip (Flutter)

Günlük gelir ve giderlerimi pratik bir şekilde kaydedip toplam bakiyemi anlık görebilmek için geliştirdiğim mini harcama takip uygulaması.

Arayüzde toplam bakiye, toplam gelir ve toplam gider kartları yer alıyor. Sayfa yenilendiğinde verilerin kaybolmaması için tarayıcı/cihaz hafızasını kullanıyor.

## Ekran Görüntüsü

![Uygulama Ekranı](screenshot.png)

## Neler Kullandım?

* **Flutter & Dart**
* **shared_preferences:** Eklenen gelir-gider verilerinin kalıcı olarak saklanması için
* **intl:** Tutarların Türkiye para formatına uygun (örn. `153.740,00 ₺`) görünmesi için

## Özellikler

* Gelir veya gider türünde harcama ekleme
* Tek tıkla kayıt silme
* Toplam bakiye, gelir ve giderin anlık hesaplanması
* Local storage desteği (sayfa yenilense de veriler silinmez)

## Nasıl Çalıştırılır?

1. Projeyi klonlayın:
   ```bash
   git clone [https://github.com/sudenisaakbulut/harcama_takip.git](https://github.com/sudenisaakbulut/harcama_takip.git)
