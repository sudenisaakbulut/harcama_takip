# Harcama Takip (Flutter)

Günlük gelir ve giderlerimi pratik bir şekilde kaydedip toplam bakiyemi anlık görebilmek için geliştirdiğim mini harcama takip uygulaması.

Arayüzde toplam bakiye, toplam gelir ve toplam gider kartları yer alıyor. Sayfa yenilendiğinde verilerin kaybolmaması için tarayıcı/cihaz hafızasını kullanıyor.

## Ekran Görüntüsü
<img width="200"  alt="WhatsApp Image 2026-11-13 at 13 52 53" src="https://github.com/user-attachments/assets/9f0b719e-7cd1-4315-98f1-aed62593e8e3" /><img width="200"  alt="WhatsApp Image 2026-11-13 at 13 52 53 (1)" src="https://github.com/user-attachments/assets/ced86560-79f4-4df5-a645-e53bb22ce060" />
<img width="200" alt="WhatsApp Image 2026-11-13 at 13 52 53 (2)" src="https://github.com/user-attachments/assets/54bca33d-4540-4179-a146-1f1c07455766" />
<img width="200" alt="WhatsApp Image 2026-11-13 at 13 52 53 (3)" src="https://github.com/user-attachments/assets/564355c4-f72d-4e00-8166-468ba7847763" />



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
