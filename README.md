# 🇺🇿 O'zbek Lug'at — So'zlarni yodlash ilovasi

## Ilova imkoniyatlari

- 📂 **JSON / CSV** fayl orqali so'z yuklash
- ✅ **Yodlandi / Yodlanmadi** status belgisi
- 📊 **Dashboard** — progress, statistika, haftalik faollik
- 🔍 **Qidirish** va kategoriya bo'yicha filtrlash
- ✍️ **Qo'lda so'z qo'shish**
- 🗑️ **Swipe** qilib so'z o'chirish

---

## APK yasash uchun

### Talablar
- Flutter SDK (3.0.0+)  https://flutter.dev/docs/get-started/install
- Android Studio yoki VS Code
- Android SDK (API 21+)

### Qadamlar

```bash
# 1. Papkaga kiring
cd lugat_app

# 2. Paketlarni yuklab oling
flutter pub get

# 3. APK build qiling
flutter build apk --release

# APK manzili:
# build/app/outputs/flutter-apk/app-release.apk
```

### Debug APK (tezroq)
```bash
flutter build apk --debug
```

---

## JSON format namunasi

```json
[
  {
    "word": "apple",
    "meaning": "olma",
    "example": "I eat an apple every day",
    "category": "meva"
  },
  {
    "word": "book",
    "meaning": "kitob",
    "category": "ta'lim"
  }
]
```

## CSV format namunasi

```csv
word,meaning,example,category
apple,olma,I eat an apple,meva
book,kitob,I read this book,ta'lim
water,suv,,tabiiy
```

> O'zbek ustun nomlarini ham qabul qiladi: `so'z`, `manosi`, `misol`, `kategoriya`

---

## Loyiha tuzilmasi

```
lib/
  main.dart              # App entry point
  models/
    word.dart            # So'z modeli
    word_service.dart    # JSON/CSV parser, storage
  screens/
    home_screen.dart     # Bottom nav
    words_screen.dart    # So'zlar ro'yxati
    dashboard_screen.dart # Statistika
    import_screen.dart   # Yuklash ekrani
    word_detail_screen.dart # So'z tafsiloti
assets/
  sample.json            # Namuna so'zlar
```
