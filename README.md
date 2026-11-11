# projekakhirprakmobile

**WorthBang Lite** — aplikasi Flutter untuk cek kelayakan harga komponen PC, dengan etalase produk, wishlist lokal, konverter mata uang, dan toko terdekat.

## Status

Kerangka aplikasi (Phase Minus) sudah berjalan:

- 4 tab: Beranda, Cari/Etalase, Wishlist, Profil
- Form Cek Harga dengan validasi
- Tema Monex (terang/gelap)
- Aset katalog retail, data toko, dan ilustrasi kategori
- `flutter analyze` bersih, `flutter test` lulus, APK debug berhasil dibangun

Fitur bisnis (analyzer katalog, Hive, HTTP kurs, peta, notifikasi, LBS) menyusul pada phase berikutnya.

## Struktur

```text
app/        Proyek Flutter WorthBang Lite
tool/       Generator ilustrasi kategori etalase
PLAN.md     Rencana implementasi dan RTM
```

## Menjalankan

```powershell
cd app
flutter pub get
flutter run
```

Build APK debug:

```powershell
flutter build apk --debug
```
