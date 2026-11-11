# PLAN.md — WorthBang Lite

> **Status:** `PHASE MINUS SELESAI` — kerangka `app/` sudah dibuat (scaffold, dependency, manifest, aset, tema Monex, shell 4 tab). Fitur bisnis belum diimplementasikan.
>
> **Revisi:** 4 tab (Beranda · Cari/Etalase · Wishlist · Profil), `flutter_map` dipertahankan, blockchain/hash chain dipangkas.
>
> **Baseline audit:** `reference/` (clone dari `WildaGhoniyuJiddan/WorthGaBang-AndroidVer`)
>
> **Target implementasi:** `app/` — proyek Flutter baru yang bersih, mengambil inti bisnis + design system dari baseline.
>
> **Spesifikasi acuan:** `D:\Kuliah\Prak Mobile\materi\Materi_Modul_2-7_dan_OOP.md`

---

## 0. Ringkasan Eksekutif

### 0.1 Verdict audit

Baseline **belum 100%** memenuhi checklist modul. Yang sudah kuat: widget/layout (Modul 2), state dasar (Modul 3), abstraksi service, LBS + peta, dan immediate notification. Yang belum: `http` package, Hive, scheduled notification, notification permission Android 13+, `Navigator.pushReplacement`, `Navigator.pushAndRemoveUntil`, `BottomNavigationBar` indexed, **tab etalase produk**, redirecting constructor, enkapsulasi model dengan validasi, serta inheritance/polymorphism business-level.

### 0.2 Keputusan arsitektur

**Clean-room rebuild di `app/`, bukan menambal `reference/`.**

Alasan:

1. Baseline mengandung 156 MB aset 3D, 11.060 baris Dart, dan banyak fitur yang tidak relevan dengan checklist.
2. Menambal baseline akan menghasilkan dua stack berdampingan (Dio + `http`, Drift + Hive, go_router + Navigator 1.0) — melanggar prinsip *zero dead-code* dan *cohesive integration*.
3. Rebuild memungkinkan setiap persyaratan modul ditempatkan tepat di alur bisnis, bukan halaman dummy.
4. `reference/` tetap utuh sebagai sumber aset, katalog, tema, dan perilaku yang sudah teruji.

### 0.3 Scope produk final

**WorthBang Lite** — aplikasi cek kelayakan harga komponen PC yang offline-first, dengan fitur pendukung yang benar-benar dipakai:

| Fitur | Nilai bisnis | Modul yang dilayani |
|---|---|---|
| Login/Register lokal | Personalisasi & sesi | OOP, Modul 2/3/4/6 |
| Beranda | Dashboard & pintu masuk fitur | Modul 2/3/4 |
| **Cari / Etalase** | **Satu kartu per seri produk, pencarian, filter kategori** | **OOP, Modul 2/3/4** |
| **Detail Produk** | **Spesifikasi seri, daftar varian + harga, aksi cek harga/wishlist** | **OOP, Modul 2/3/4** |
| Cek Harga | Fitur inti: skor, verdict, harga referensi | OOP, Modul 2/3/4/5 |
| Hasil + simpan riwayat ringan | Keputusan pembelian; tanpa hash chain | OOP, Modul 2/3/4/6/7 |
| Wishlist CRUD | Simpan target harga | OOP, Modul 2/3/4/6/7 |
| **Toko Terdekat + Peta** | **Peta OSM, marker, LBS, notifikasi** | **Modul 2/3/4/7** |
| Konverter Mata Uang | HTTP publik | Modul 2/3/4/5 |
| Profil & Pengaturan | Tema, izin, reminder, logout | Modul 2/3/4/6/7 |

**Tab utama (4):** Beranda · Cari/Etalase · Wishlist · Profil.

### 0.4 Non-goals (dibuang dari baseline)

Blockchain/hash chain/verifikasi tamper, 3D/GLB, shake/tilt/sensor, GPS tracking background, chatbot, game, tren, bundle multi-komponen, price alert WorkManager, offline sync queue, biometric, upload foto, feedback, ganti nama, halaman About, backend FastAPI, Dio, Drift, Riverpod, go_router, `workmanager`, `fl_chart`, `glbview`, `sensors_plus`, `local_auth`, `image_picker`, `flutter_secure_storage`.

### 0.5 Status Phase Minus (kerangka)

Sudah ada di `app/`:

- Proyek Flutter `worthbang_lite` + dependency final.
- `AndroidManifest.xml` dengan izin Internet, lokasi, notifikasi, dan receiver scheduled notification.
- `build.gradle.kts` dengan desugaring + `minSdk 23`; `gradle.properties` menonaktifkan Kotlin incremental (workaround drive C:/D:).
- Aset: icon, font Plus Jakarta Sans, `retail_catalog.json`, `stores.json`, 5 ilustrasi kategori etalase.
- Tema Monex + widget dasar (diporting dari baseline).
- Shell 4 tab (`Beranda`, `Cari`, `Wishlist`, `Profil`) dengan `BottomNavigationBar`.
- Kerangka layar: Beranda, Cari/Etalase kategori, Wishlist empty state, Profil + toggle tema, Cek Harga (form + validator).
- `flutter analyze` bersih; `flutter test` 2 test lulus; `flutter build apk --debug` sukses.

Belum ada: model OOP final, Hive/SP session, analyzer katalog, etalase seri nyata, detail produk, peta, HTTP kurs, notifikasi, LBS.

---

## 1. Prinsip Kerja

1. **Zero dead-code** — setiap screen harus bisa dicapai dari `RootScreen` (4 tab), `HomeScreen`, `CatalogScreen`, `ProductDetailScreen`, `ResultScreen`, atau `ProfileScreen`.
2. **Cohesive integration** — fitur modul menempel pada alur nyata: cek harga → hasil → wishlist/toko/notifikasi.
3. **Strict lifecycle** — semua `TextEditingController`, `ScrollController`, `Timer`, dan listener di-`dispose()`.
4. **Strict async** — setiap `await` punya `loading`, `error`, `empty`, dan `mounted` check.
5. **Permission-safe** — lokasi & notifikasi diminta saat dibutuhkan, dengan jalur `denied`, `deniedForever`, dan service disabled.
6. **No placeholder** — tidak ada `// TODO`, `throw UnimplementedError()`, atau halaman kosong.
7. **Traceable** — setiap checkbox di RTM menunjuk file + class + method yang benar-benar ada.

---

## 2. Gap Analysis — Baseline vs Checklist

Legenda: `[✅ Sudah Ada]` — memenuhi; `[⚠️ Perlu Refactor]` — ada tetapi belum tepat; `[❌ Belum Ada]` — tidak ditemukan.

### 2.1 OOP

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| Class & Object | ✅ | `lib/models/price_check_models.dart` → `AnalysisResult`, `PriceComparison` | Dipertahankan, dipindah ke model baru |
| Generative constructor | ✅ | `AnalysisResult(...)`, `AppUser(...)` | Dipertahankan |
| Named constructor | ✅ | `factory AnalysisResult.fromJson(...)`, `AppUser.fromJson(...)` | Dipertahankan, ditambah `.fromMap()` |
| Redirecting constructor | ❌ | Tidak ditemukan `.empty()` / `.defaultData()` | Tambah `PriceCheckRequest.empty()`, `WishlistItem.empty()`, `ProductSeries.empty()`, `PriceAnalysis.empty()` |
| Encapsulation + validasi getter/setter | ❌ | Model memakai field `final` publik; validasi hanya di form | Buat `_query`, `_price`, `_condition`, `_targetPrice` privat + getter/setter yang memvalidasi |
| Inheritance `extends` + `super` | ❌ | Tidak ada hierarki bisnis parent→child | Buat `PriceVerdict` → 4 subclass; `CatalogItem` → 5 subclass |
| Polymorphism + `@override` | ❌ | Hanya `implements` pada service, bukan perilaku subclass | `PriceVerdict.label/color/icon/advice` dan `CatalogItem.referencePrice()` di-override |
| Abstraction `abstract class` / `implements` | ✅ | `ApiClient`, `PriceAlertNotifier`, `SecureKv`, `AlertDedupStore` | Dipertahankan sebagai pola; buat `PriceAnalyzer`, `NotificationService`, `LocationService` |

### 2.2 Modul 2 — Widget & Layouting

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| `MaterialApp` | ✅ | `lib/utils/app.dart` → `WorthBangApp.build` | Dipertahankan |
| `Scaffold` + `AppBar` + `body` | ✅ | `lib/screens/home_screen.dart`, `price_check_screen.dart` | Dipertahankan |
| `AppBar` dengan `leading`, `title`, `actions` lengkap | ⚠️ | Home punya leading+title; PriceCheck punya title+actions; tidak ada satu AppBar dengan ketiganya | `PriceCheckScreen`/`HomeScreen` baru memakai ketiganya |
| `Container`, `SizedBox`, `Center`/`Align` | ✅ | `lib/core/widgets/monex_widgets.dart` | Dipertahankan |
| `Column`, `Row`, alignment | ✅ | `home_screen.dart`, `profile_screen.dart` | Dipertahankan |
| `Stack` | ✅ | `profile_screen.dart` (badge avatar), `stores_screen.dart` (overlay peta) | Dipertahankan di avatar, result badge, dan overlay peta |
| `Text`, `Icon` | ✅ | Hampir semua screen | Dipertahankan |
| `Image.asset()` | ✅ | `lib/widgets/app_logo.dart` → `AppLogo.build` | Dipertahankan |
| `Image.network()` | ❌ | Profile memakai `NetworkImage` di `CircleAvatar`, bukan `Image.network()` | Avatar profil baru memakai `Image.network` + `errorBuilder` |
| `TextButton` | ✅ | `login_screen.dart`, `register_screen.dart` | Dipertahankan |
| `OutlinedButton` | ✅ | `MonexSecondaryButton` | Dipertahankan |
| `ElevatedButton` | ❌ | `MonexPrimaryButton` memakai `FilledButton`; tidak ada `ElevatedButton` | Refactor `MonexPrimaryButton` → `ElevatedButton` |
| `TextField` | ✅ | `search_screen.dart`, `tools_screen.dart` | Dipertahankan |
| `TextFormField` + `validator` | ✅ | `price_check_screen.dart`, `login_screen.dart` | Dipertahankan |
| `SingleChildScrollView` | ✅ | `price_check_screen.dart`, `login_screen.dart` | Dipertahankan |
| `ListView.builder` | ✅ | `history_screen.dart`, `wishlist_screen.dart` | Dipertahankan |
| `ListTile` | ✅ | Popup menu `price_check_screen.dart`, `profile_screen.dart` | Dipertahankan |
| `GridView.builder` | ✅ | `home_screen.dart` | Dipertahankan + dipakai untuk grid Etalase |
| Tab Cari / Etalase produk | ❌ | Baseline hanya punya pencarian listing (`search_screen.dart`) | Tambah `CatalogScreen` + `ProductDetailScreen`: satu kartu per seri, spesifikasi, varian |

### 2.3 Modul 3 — State & Data

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| `StatelessWidget` vs `StatefulWidget` | ✅ | `HomeScreen` (Stateless), `PriceCheckScreen` (ConsumerStateful), `VerdictBadge` (Stateless) | Dipertahankan; screen dinamis baru memakai `StatefulWidget` murni |
| `setState()` | ✅ | `price_check_screen.dart`, `search_screen.dart`, `wishlist_screen.dart` | Dipertahankan |
| `TextEditingController` + dispose | ⚠️ | Sebagian besar sudah dispose; dialog `_editName` di `profile_screen.dart` membuat controller tanpa dispose | Semua controller di-dispose, termasuk dialog |
| Conditional rendering | ✅ | Loading/error/empty di `price_check_screen.dart`, `search_screen.dart`, `history_screen.dart` | Dipertahankan, distandarkan |
| Class model | ✅ | `lib/models/*.dart` | Dipertahankan, diperkuat enkapsulasi |

### 2.4 Modul 4 — Navigation

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| `Navigator.push()` | ✅ | `home_screen.dart` → `_openPage`, `price_check_screen.dart` → Result/Bundle | Dipertahankan |
| `Navigator.pop()` | ✅ | `result_screen.dart`, dialog | Dipertahankan |
| `Navigator.pushReplacement()` | ❌ | Tidak ditemukan | Splash → Login/Root; Login → Root |
| `Navigator.pushAndRemoveUntil()` | ❌ | Logout memakai state auth + redirect go_router | Logout → Login dengan `(route) => false` |
| Passing data via constructor (`required` + default) | ✅ | `ResultScreen({required result, required blockId})`; `TrendsScreenContent({initialQuery = 'RTX 4060'})` | Dipertahankan; `ResultScreen(analysis, sourceLabel = 'Cek Harga')` |
| `BottomNavigationBar` + `_selectedIndex` + `_pages[_selectedIndex]` | ❌ | `utils/router.dart` memakai `StatefulShellRoute.indexedStack` + `MonexBottomNavBar` | Ganti total dengan `RootScreen` memakai `BottomNavigationBar` 4 tab |
| Tab Cari terpisah (Etalase) | ❌ | Tidak ada; `search_screen.dart` adalah filter listing | `CatalogScreen` sebagai tab ke-2, `ProductDetailScreen` via `Navigator.push` |

### 2.5 Modul 5 — HTTP Request

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| `http.get(Uri.parse(...))` | ❌ | Semua network memakai Dio (`dio_api_client.dart`) | `CurrencyApi` baru memakai `package:http` |
| `Future` + `async` + `await` | ✅ | `PriceCheckApi`, `DioApiClient`, dll | Dipertahankan |
| `jsonDecode` → `Map`/`List` | ⚠️ | Dio mengembalikan Map otomatis; tidak ada `jsonDecode(response.body)` eksplisit | `CurrencyApi` decode manual dari `response.body` |
| Render `List<Model>` + loading | ⚠️ | `SearchScreen` merender `List<PriceComparison>` dengan loading; tetapi bukan dari `http` | `ConverterScreen` merender `List<CurrencyRate>` dari `http` |

### 2.6 Modul 6 — Local Storage

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| SharedPreferences key-value | ⚠️ | Dipakai untuk settings/game/sync (`profile_api.dart`, `game_api.dart`, `sync_service.dart`) | Tambah `SessionPreferences` untuk `is_logged_in`, `active_username`, `theme_mode` |
| Hive init + Box | ❌ | Tidak ada Hive | `Hive.initFlutter()`, box `wishlist`, `history`, `accounts` |
| TypeAdapter / HiveObject | ❌ | Tidak ada | `WishlistItem extends HiveObject` + `WishlistItemAdapter` |
| CRUD Create (`add`) | ❌ | Wishlist memakai Drift | `WishlistRepository.add()` |
| CRUD Read (`getAt`/`values`) | ❌ | Wishlist memakai Drift | `WishlistRepository.getAll()` / `getAt()` |
| CRUD Update (`putAt`) | ❌ | Wishlist memakai Drift | `WishlistRepository.updateAt()` |
| CRUD Delete (`deleteAt`) | ❌ | Wishlist memakai Drift | `WishlistRepository.deleteAt()` |

### 2.7 Modul 7 — Notification & LBS

| Syarat | Status | Bukti baseline | Gap / rencana |
|---|---|---|---|
| Immediate notification | ✅ | `notification_service.dart` → `showPriceAlert`, dipanggil `AlertCheckService` | Dipakai ulang untuk wishlist/cek harga/toko |
| Scheduled notification | ❌ | Hanya WorkManager periodik, bukan `zonedSchedule` | `NotificationService.scheduleDailyReminder()` + `zonedSchedule` |
| Notification permission Android 13+ | ❌ | Tidak ada `POST_NOTIFICATIONS` / `requestNotificationsPermission` | Tambah manifest + runtime request |
| Location permission handling | ✅ | `stores_screen.dart` → `_locateAndLoad` (`checkPermission`, `requestPermission`, `deniedForever`) | Dipertahankan, dipindah ke `LocationService` |
| Latitude/longitude real-time | ✅ | `Geolocator.getCurrentPosition` | Dipertahankan |
| Integrasi lokasi ke UI | ✅ | Peta + marker + jarak `stores_screen.dart` | Dipertahankan: `FlutterMap` + marker + daftar toko + jarak |
| Integrasi lokasi ke notifikasi | ❌ | Notifikasi tidak memakai lokasi | `NearbyStoresScreen` mengirim notifikasi “toko terdekat + jarak + koordinat” |

---

## 3. Architecture Mapping

### 3.1 Struktur target

```text
projek_akhir/
  reference/                         # baseline, read-only
  PLAN.md                            # dokumen ini
  tool/generate_category_images.py   # generator 5 ilustrasi etalase
  app/                               # target aplikasi Flutter baru
    pubspec.yaml
    android/
      app/src/main/AndroidManifest.xml
      app/build.gradle.kts
    assets/
      icon.png
      images/gpu.png
      images/cpu.png
      images/motherboard.png
      images/ram.png
      images/storage.png
      data/retail_catalog.json
      data/stores.json
      fonts/PlusJakartaSans-*.ttf
    lib/
      main.dart
      app.dart
      core/
        theme/monex_theme.dart
        widgets/monex_widgets.dart
        utils/formatters.dart
        utils/validators.dart
        utils/spec_parser.dart
      models/
        catalog_item.dart
        product_series.dart
        price_check_request.dart
        price_analysis.dart
        price_verdict.dart
        wishlist_item.dart
        user_account.dart
        currency_rate.dart
        store.dart
        location_snapshot.dart
      state/
        session_controller.dart
        theme_controller.dart
        app_dependencies.dart
        app_scope.dart
      services/
        auth_service.dart
        session_preferences.dart
        hive_service.dart
        catalog_service.dart
        price_analyzer.dart
        history_repository.dart
        wishlist_repository.dart
        currency_api.dart
        location_service.dart
        notification_service.dart
        store_service.dart
      screens/
        splash_screen.dart
        login_screen.dart
        register_screen.dart
        root_screen.dart
        home_screen.dart
        catalog_screen.dart
        product_detail_screen.dart
        price_check_screen.dart
        result_screen.dart
        wishlist_screen.dart
        nearby_stores_screen.dart
        converter_screen.dart
        profile_screen.dart
      widgets/
        app_logo.dart
        product_series_card.dart
        spec_chip.dart
        verdict_badge.dart
        permission_banner.dart
        empty_state.dart
        section_header.dart
        wishlist_tile.dart
    test/
      models/...
      services/...
      screens/...
      navigation/...
```

### 3.2 Layer & dependency direction

```text
screens/ (presentation, StatefulWidget/StatelessWidget)
   ↓ memakai
state/ (SessionController, ThemeController, AppScope)
   ↓ memakai
services/ (AuthService, CatalogService, PriceAnalyzer, WishlistRepository,
           CurrencyApi, LocationService, NotificationService, StoreService)
   ↓ memakai
models/ (entity + value object + hierarchy)
   ↓
platform/storage: Hive, SharedPreferences, http, geolocator, notifications
```

Aturan:

- `screens/` **tidak** mengakses Hive/SharedPreferences/HTTP langsung.
- `services/` **tidak** mengakses `BuildContext`.
- `models/` **tidak** mengimpor Flutter widget (kecuali `Color`/`IconData` untuk `PriceVerdict`; alternatif: simpan token warna di UI mapper).
- `AppScope` menyediakan dependency ke seluruh widget tree tanpa package state eksternal.

### 3.3 State strategy

- **App-wide:** `ChangeNotifier` (`SessionController`, `ThemeController`) + `ListenableBuilder`.
- **Screen-local:** `StatefulWidget` + `setState()`.
- **No Riverpod / no Provider** — mengurangi dependensi dan membuat `setState` benar-benar terlihat untuk audit Modul 3.
- **No go_router** — `Navigator` 1.0 agar keempat method Modul 4 terimplementasi eksplisit.

### 3.4 Peta navigasi

```text
main()
 └─ SplashScreen
     ├─ (belum login) ──pushReplacement──> LoginScreen
     │                                      ├─push──> RegisterScreen
     │                                      └─pushReplacement──> RootScreen
     └─ (sudah login) ──pushReplacement──> RootScreen
                                             ├─ tab 0: HomeScreen
                                             │    ├─push──> PriceCheckScreen
                                             │    │          └─push──> ResultScreen
                                             │    │                       ├─push──> NearbyStoresScreen
                                             │    │                       └─pindah tab ──> WishlistScreen
                                             │    ├─push──> NearbyStoresScreen
                                             │    └─push──> ConverterScreen
                                             ├─ tab 1: CatalogScreen (Etalase)
                                             │    └─push──> ProductDetailScreen
                                             │         ├─push──> PriceCheckScreen(initialQuery: series.name)
                                             │         ├─push──> NearbyStoresScreen(initialQuery: series.name)
                                             │         └─add──> WishlistRepository (Hive)
                                             ├─ tab 2: WishlistScreen
                                             │    └─push──> NearbyStoresScreen (dari item)
                                             └─ tab 3: ProfileScreen
                                                  └─pushAndRemoveUntil──> LoginScreen
```

### 3.5 Alur bisnis inti

```text
HomeScreen
  → Cek Harga (form query + harga + kondisi)
  → CatalogPriceAnalyzer.analyze()
  → PriceAnalysis (skor, verdict, referensi, pembanding)
  → ResultScreen
      → HistoryRepository.add()            (Hive, otomatis)
      → NotificationService.showImmediate() (opsional, jika diizinkan)
      → “Simpan ke Wishlist”
           → WishlistRepository.add()      (Hive)
           → NotificationService.showImmediate()
      → “Toko Terdekat”
           → NearbyStoresScreen(initialQuery: analysis.query)
           → LocationService.getCurrentLocation()
           → StoreService.nearest()
           → NotificationService.showImmediate(“Toko terdekat …”)

CatalogScreen (Etalase)
  → CatalogService.loadSeries()
  → GridView.builder satu kartu per seri produk
  → ProductDetailScreen(series)
      → Spesifikasi hasil SpecParser
      → ListView.builder varian + harga
      → “Cek Harga”    → PriceCheckScreen(initialQuery: series.name)
      → “Toko Terdekat”→ NearbyStoresScreen(initialQuery: series.name)
      → “Wishlist”     → WishlistRepository.add()
```

---

## 4. Dependency & Platform Setup

### 4.1 Perintah scaffold

```powershell
cd "D:\Kuliah\Prak Mobile\projek_akhir"
flutter create --org com.worthbang --project-name worthbang_lite app
```

### 4.2 `pubspec.yaml` final

```yaml
name: worthbang_lite
description: "WorthBang Lite — cek kelayakan harga komponen PC, offline-first."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.4

dependencies:
  flutter:
    sdk: flutter

  # Modul 5 — HTTP publik
  http: ^1.6.0

  # Modul 6 — local storage
  shared_preferences: ^2.5.6
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Modul 7 — LBS + notification + peta
  geolocator: ^14.1.2
  flutter_map: ^8.3.2
  latlong2: ^0.10.1
  flutter_local_notifications: ^22.3.1
  timezone: ^0.11.2
  flutter_timezone: ^5.1.1

  # Utility
  intl: ^0.20.3
  crypto: ^3.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/icon.png
    - assets/images/gpu.png
    - assets/images/cpu.png
    - assets/images/motherboard.png
    - assets/images/ram.png
    - assets/images/storage.png
    - assets/data/retail_catalog.json
    - assets/data/stores.json

  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
        - asset: assets/fonts/PlusJakartaSans-ExtraBold.ttf
          weight: 800
```

**Dihapus dari baseline:** `dio`, `drift`, `drift_dev`, `build_runner`, `flutter_riverpod`, `go_router`, `workmanager`, `local_auth`, `fl_chart`, `sensors_plus`, `connectivity_plus`, `glbview`, `image_picker`, `flutter_secure_storage`, `path`, `path_provider`, `flutter_launcher_icons`.

**Dipertahankan dari baseline:** `flutter_map` + `latlong2` untuk peta OpenStreetMap di Toko Terdekat.

### 4.3 Aset yang disalin dari baseline

| Aset | Sumber | Tujuan |
|---|---|---|
| `icon.png` | `reference/assets/icon.png` | `app/assets/icon.png` |
| `retail_catalog.json` | `reference/assets/data/retail_catalog.json` | `app/assets/data/retail_catalog.json` |
| Font Plus Jakarta Sans | `reference/assets/fonts/` | `app/assets/fonts/` |
| Toko Jakarta + Yogyakarta | `reference/assets/data/stores_jakarta.csv`, `reference/backend/app/data/stores_yogyakarta.csv` | Dikonversi sekali menjadi `app/assets/data/stores.json` |
| Ilustrasi kategori etalase | Dibuat baru dengan Pillow (`tool/generate_category_images.py`) | `app/assets/images/{gpu,cpu,motherboard,ram,storage}.png` |
| Tema Monex | `reference/lib/core/theme/monex_theme.dart` | `app/lib/core/theme/monex_theme.dart` |
| Widget Monex | `reference/lib/core/widgets/monex_widgets.dart` | `app/lib/core/widgets/monex_widgets.dart` (dipangkas widget yang dipakai) |

> Peta memakai tile OpenStreetMap. `INTERNET` sudah ada; `flutter_map` wajib diberi `userAgentPackageName: 'com.worthbang.worthbang_lite'` dan atribusi OSM.

### 4.4 `AndroidManifest.xml` final

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Modul 5: HTTP publik + Modul 7: tile OpenStreetMap -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Modul 7: LBS -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

    <!-- Modul 7: local notification -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <application
        android:label="WorthBang Lite"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- flutter_local_notifications: scheduled notification -->
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

Catatan:

- Kita memakai `AndroidScheduleMode.inexactAllowWhileIdle`, jadi **tidak** memerlukan `SCHEDULE_EXACT_ALARM`. Notifikasi tetap dijadwalkan dan bertahan setelah app ditutup; waktu bisa bergeser sedikit karena OS.
- Jika dosen mewajibkan waktu presisi, tambahkan `SCHEDULE_EXACT_ALARM` + `requestExactAlarmsPermission()`; ini akan menambah kompleksitas izin.
- `INTERNET` harus ada di **main** manifest, bukan hanya `debug`, agar release APK bisa HTTP.
- Tidak ada `usesCleartextTraffic`; semua endpoint memakai HTTPS.

### 4.5 `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.worthbang.worthbang_lite"
    compileSdk = flutter.compileSdkVersion // harus >= 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.worthbang.worthbang_lite"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### 4.6 Endpoint HTTP publik

- `GET https://open.er-api.com/v6/latest/IDR` (konverter)
- `GET https://tile.openstreetmap.org/{z}/{x}/{y}.png` (tile peta; wajib `userAgentPackageName` + atribusi OSM)
- Response: `{ "result": "success", "base_code": "IDR", "rates": { "USD": 0.000062, ... }, "time_last_update_utc": "..." }`
- Timeout: 10 detik.
- Status non-200 / `result != "success"` → `CurrencyApiException`.
- Parse `rates` → `List<CurrencyRate>`; filter `USD`, `SGD`, `MYR`, `EUR`, `JPY`.
- Jika offline: tampilkan error + tombol “Coba lagi”; **jangan** memalsukan data sebagai sukses.

### 4.7 Strategi izin

| Izin | Kapan diminta | Penanganan |
|---|---|---|
| `POST_NOTIFICATIONS` | Saat user mengaktifkan reminder / pertama kali menyimpan wishlist | Jika ditolak: tampilkan banner + tombol buka pengaturan; fitur tetap jalan tanpa notifikasi |
| `ACCESS_FINE_LOCATION` | Saat membuka Toko Terdekat | `denied` → request; `deniedForever` → tombol “Buka Pengaturan”; service mati → pesan aktifkan GPS |
| `INTERNET` | Install-time | Tidak ada runtime request |

---

## 5. OOP Implementation Blueprint

### 5.1 Class, Object, Constructors

**File:** `lib/models/price_check_request.dart`

```dart
class PriceCheckRequest {
  String _query;
  int _price;
  String _condition;

  /// Generative constructor + validasi awal.
  PriceCheckRequest({
    required String query,
    required int price,
    String condition = 'baru',
  })  : _query = _validateQuery(query),
        _price = _validatePrice(price),
        _condition = _validateCondition(condition);

  /// Named constructor: dari JSON (mis. payload API / Hive).
  factory PriceCheckRequest.fromJson(Map<String, dynamic> json) {
    return PriceCheckRequest(
      query: json['query'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      condition: json['condition'] as String? ?? 'baru',
    );
  }

  /// Redirecting constructor: data awal form.
  PriceCheckRequest.empty() : this(query: 'RTX 4060', price: 4500000);

  String get query => _query;
  int get price => _price;
  String get condition => _condition;

  set query(String value) => _query = _validateQuery(value);
  set price(int value) => _price = _validatePrice(value);
  set condition(String value) => _condition = _validateCondition(value);

  Map<String, dynamic> toJson() => {
        'query': _query,
        'price': _price,
        'condition': _condition,
      };

  static String _validateQuery(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Nama produk minimal 2 karakter.');
    }
    return trimmed;
  }

  static int _validatePrice(int value) {
    if (value <= 0) {
      throw ArgumentError('Harga harus lebih dari 0.');
    }
    return value;
  }

  static String _validateCondition(String value) {
    const allowed = {'baru', 'bekas', 'any'};
    if (!allowed.contains(value)) {
      throw ArgumentError('Kondisi tidak valid.');
    }
    return value;
  }
}
```

**File:** `lib/models/product_series.dart`

```dart
import 'dart:math';

import '../core/utils/spec_parser.dart';
import 'catalog_item.dart';

class ProductSeries {
  ProductSeries({
    required this.id,
    required this.name,
    required this.category,
    required List<CatalogItem> variants,
    required this.imageAsset,
  })  : _variants = List.unmodifiable(variants),
        _minPrice = variants.isEmpty
            ? 0
            : variants.map((e) => e.price).reduce(min),
        _maxPrice = variants.isEmpty
            ? 0
            : variants.map((e) => e.price).reduce(max),
        _specs = variants.isEmpty
            ? const {}
            : SpecParser.parse(category, variants.first.model);

  /// Redirecting constructor: template etalase saat data belum siap.
  ProductSeries.empty()
      : this(
          id: 'empty',
          name: 'Belum ada produk',
          category: 'gpu',
          variants: const [],
          imageAsset: 'assets/images/gpu.png',
        );

  final String id;
  final String name;
  final String category;
  final String imageAsset;
  final List<CatalogItem> _variants;
  final int _minPrice;
  final int _maxPrice;
  final Map<String, String> _specs;

  List<CatalogItem> get variants => _variants;
  int get minPrice => _minPrice;
  int get maxPrice => _maxPrice;
  int get variantCount => _variants.length;
  Map<String, String> get specs => _specs;

  String get priceRangeLabel => _minPrice == _maxPrice
      ? 'Rp $_minPrice'
      : 'Rp $_minPrice – Rp $_maxPrice';

  /// Named constructor: agregasi item katalog menjadi satu seri.
  factory ProductSeries.fromItems({
    required String id,
    required String name,
    required String category,
    required String imageAsset,
    required List<CatalogItem> variants,
  }) {
    if (variants.isEmpty) {
      throw ArgumentError('Seri $name tidak punya varian.');
    }
    return ProductSeries(
      id: id,
      name: name,
      category: category,
      variants: variants,
      imageAsset: imageAsset,
    );
  }
}
```

**File:** `lib/models/wishlist_item.dart` — lihat §6.6 untuk `HiveObject` + adapter.

### 5.2 Encapsulation

- `PriceCheckRequest` di atas: semua field privat, getter/setter memvalidasi.
- `WishlistItem`:

```dart
class WishlistItem extends HiveObject {
  String _query;
  int _targetPrice;
  String _condition;

  WishlistItem({
    required String query,
    required int targetPrice,
    String condition = 'baru',
  })  : _query = _validateQuery(query),
        _targetPrice = _validateTargetPrice(targetPrice),
        _condition = _validateCondition(condition);

  WishlistItem.empty() : this(query: 'Produk baru', targetPrice: 1000000);

  String get query => _query;
  int get targetPrice => _targetPrice;
  String get condition => _condition;

  set targetPrice(int value) => _targetPrice = _validateTargetPrice(value);
  set query(String value) => _query = _validateQuery(value);

  static String _validateQuery(String value) { ... }
  static int _validateTargetPrice(int value) { ... }
  static String _validateCondition(String value) { ... }
}
```

Validasi tidak boleh hanya di `TextFormField.validator`; model harus menolak state ilegal walaupun dipanggil dari service/test.

### 5.3 Inheritance & Polymorphism

**File:** `lib/models/price_verdict.dart`

```dart
import 'package:flutter/material.dart';

abstract class PriceVerdict {
  const PriceVerdict();

  String get label;
  Color get color;
  IconData get icon;
  String get advice;

  /// Hook polimorfik: bobot tampilan badge.
  double get emphasis => 1.0;
}

class WorthItVerdict extends PriceVerdict {
  const WorthItVerdict();

  @override
  String get label => 'Worth It';

  @override
  Color get color => const Color(0xFF4ADE80);

  @override
  IconData get icon => Icons.thumb_up_alt_rounded;

  @override
  String get advice => 'Harga di bawah median pasar. Layak dipertimbangkan.';
}

class FairVerdict extends PriceVerdict {
  const FairVerdict();

  @override
  String get label => 'Wajar';

  @override
  Color get color => const Color(0xFFFBBF24);

  @override
  IconData get icon => Icons.balance_rounded;

  @override
  String get advice => 'Harga masih dalam rentang wajar pasar.';
}

class OverpricedVerdict extends PriceVerdict {
  const OverpricedVerdict();

  @override
  String get label => 'Kemahalan';

  @override
  Color get color => const Color(0xFFF87171);

  @override
  IconData get icon => Icons.trending_up_rounded;

  @override
  String get advice => 'Harga di atas median. Coba negosiasi atau cari opsi lain.';

  @override
  double get emphasis => 1.2;
}

class LimitedDataVerdict extends PriceVerdict {
  const LimitedDataVerdict();

  @override
  String get label => 'Data Terbatas';

  @override
  Color get color => const Color(0xFF94A3B8);

  @override
  IconData get icon => Icons.help_outline_rounded;

  @override
  String get advice => 'Belum cukup pembanding untuk verdict kuat.';
}
```

`VerdictBadge` menerima `PriceVerdict` dan memanggil `verdict.label`, `verdict.color`, `verdict.icon` — bukti polymorphism dipakai di UI.

**File:** `lib/models/catalog_item.dart`

```dart
abstract class CatalogItem {
  const CatalogItem({required this.model, required this.price});

  final String model;
  final int price;

  String get section;
  String get sectionLabel;

  /// Setiap subclass menentukan cara menghitung harga referensi.
  int referencePrice(List<CatalogItem> pool);

  factory CatalogItem.fromJson(String section, Map<String, dynamic> json) {
    return switch (section) {
      'cpu' => CpuItem(model: json['model'] as String, price: (json['price'] as num).toInt()),
      'gpu' => GpuItem(...),
      'motherboard' => MotherboardItem(...),
      'ram' => RamItem(...),
      'storage' => StorageItem(...),
      _ => throw ArgumentError('Section tidak dikenal: $section'),
    };
  }
}

class CpuItem extends CatalogItem {
  const CpuItem({required super.model, required super.price});

  @override
  String get section => 'cpu';

  @override
  String get sectionLabel => 'CPU';

  @override
  int referencePrice(List<CatalogItem> pool) => price;
}

class GpuItem extends CatalogItem { ... }

class MotherboardItem extends CatalogItem {
  ...
  @override
  int referencePrice(List<CatalogItem> pool) {
    // median motherboard dengan socket/chipset yang sama
  }
}

class RamItem extends CatalogItem {
  ...
  @override
  int referencePrice(List<CatalogItem> pool) {
    // median RAM dengan kapasitas yang sama (16GB, 32GB, dst.)
  }
}

class StorageItem extends CatalogItem {
  ...
  @override
  int referencePrice(List<CatalogItem> pool) {
    // median storage dengan kapasitas yang sama (512GB, 1TB, dst.)
  }
}
```

`CatalogPriceAnalyzer` memanggil `item.referencePrice(pool)` tanpa `switch` berdasarkan tipe — bukti polymorphism di business logic.

### 5.4 Abstraction

**File:** `lib/services/price_analyzer.dart`

```dart
abstract class PriceAnalyzer {
  Future<PriceAnalysis> analyze(PriceCheckRequest request);
}

class CatalogPriceAnalyzer implements PriceAnalyzer {
  CatalogPriceAnalyzer(this._catalog);

  final CatalogService _catalog;

  @override
  Future<PriceAnalysis> analyze(PriceCheckRequest request) async {
    final items = await _catalog.load();
    // ... filter, hitung reference, score, verdict
  }
}
```

**File:** `lib/services/notification_service.dart`

```dart
abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> showImmediate({required String title, required String body});
  Future<void> scheduleDailyReminder({required int hour, required int minute});
  Future<void> cancelDailyReminder();
  Future<bool> areNotificationsEnabled();
}
```

**File:** `lib/services/location_service.dart`

```dart
abstract class LocationService {
  Future<LocationSnapshot> getCurrentLocation();
  Future<bool> isServiceEnabled();
  Future<void> openAppSettings();
}
```

Implementasi konkret: `LocalNotificationService`, `GeolocatorLocationService`.

---

## 6. Module Implementation Blueprint

### 6.1 Modul 2 — Widget & Layouting

| Persyaratan | Implementasi konkret |
|---|---|
| `MaterialApp` | `lib/app.dart` → `WorthBangApp.build` |
| `Scaffold` + `AppBar` + `body` | `lib/screens/home_screen.dart`, `price_check_screen.dart`, `profile_screen.dart` |
| `AppBar` lengkap | `PriceCheckScreen`: `leading` back, `title` “Cek Harga”, `actions` info + reset form |
| `Container`, `SizedBox`, `Center`/`Align` | `lib/core/widgets/monex_widgets.dart` (`MonexSurfaceCard`, `MonexPrimaryButton`, `MonexEmptyState`) |
| `Column` + `Row` + alignment | `home_screen.dart` (hero card), `result_screen.dart` (stat row), `profile_screen.dart` |
| `Stack` | `profile_screen.dart` avatar + badge; `result_screen.dart` verdict badge; `nearby_stores_screen.dart` peta + FAB “lokasi saya” + atribusi |
| `Text`, `Icon` | Semua screen |
| `Image.asset` | `lib/widgets/app_logo.dart` → `AppLogo.build`; `product_series_card.dart` → ilustrasi kategori etalase |
| `Image.network` | `lib/screens/profile_screen.dart` → `Image.network(user.avatarUrl, errorBuilder: ...)` |
| `TextButton` | `lib/screens/login_screen.dart` → “Belum punya akun? Daftar” |
| `OutlinedButton` | `lib/core/widgets/monex_widgets.dart` → `MonexSecondaryButton` |
| `ElevatedButton` | `lib/core/widgets/monex_widgets.dart` → `MonexPrimaryButton` (refactor dari `FilledButton`) |
| `TextField` | `catalog_screen.dart` pencarian seri, `converter_screen.dart` nominal, `nearby_stores_screen.dart` pencarian toko |
| `TextFormField` + validator | `lib/screens/price_check_screen.dart` query/harga, `login_screen.dart`/`register_screen.dart` |
| `SingleChildScrollView` | `price_check_screen.dart`, `login_screen.dart`, `product_detail_screen.dart` |
| `ListView.builder` | `wishlist_screen.dart`, `converter_screen.dart`, `product_detail_screen.dart` daftar varian, `home_screen.dart` riwayat |
| `ListTile` | `profile_screen.dart` menu, `wishlist_tile.dart`, `product_detail_screen.dart` varian |
| `GridView.builder` | `home_screen.dart` menu fitur + `catalog_screen.dart` grid seri produk |
| `FlutterMap` + `MarkerLayer` | `lib/screens/nearby_stores_screen.dart` → peta OSM, marker toko, marker lokasi user |

### 6.2 Modul 3 — State & Data

- **Stateless:** `AppLogo`, `VerdictBadge`, `PermissionBanner`, `SectionHeader`, `EmptyState`, `ProductSeriesCard`.
- **Stateful:** `SplashScreen`, `LoginScreen`, `RegisterScreen`, `RootScreen`, `HomeScreen` (memuat riwayat), `CatalogScreen` (pencarian/filter), `ProductDetailScreen` (aksi wishlist), `PriceCheckScreen`, `ResultScreen` (aksi async), `WishlistScreen`, `NearbyStoresScreen`, `ConverterScreen`, `ProfileScreen`.
- **`setState`:** perubahan `_selectedIndex`, `_isLoading`, `_error`, `_analysis`, `_items`, `_location`, `_query`, `_selectedCategory`, `_themeMode`.
- **`TextEditingController`:** login email/password, register name/email/password, price query/harga, catalog search, converter nominal, dialog target wishlist. Semua di-`dispose()`.
- **Conditional rendering:** `if (_isLoading) ... else if (_error != null) ... else if (_items.isEmpty) ...`; etalase menampilkan `MonexEmptyState` saat filter tidak menghasilkan seri.
- **Model:** `PriceCheckRequest`, `PriceAnalysis`, `WishlistItem`, `UserAccount`, `Store`, `CurrencyRate`, `ProductSeries`.

### 6.3 Modul 4 — Navigation

**`RootScreen` dengan `BottomNavigationBar`:**

```dart
class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.initialIndex});
  final int initialIndex;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _selectedIndex = widget.initialIndex;

  late final List<Widget> _pages = [
    HomeScreen(onOpenTab: _selectTab),
    const CatalogScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

**Method navigasi:**

| Method | Lokasi | Kode |
|---|---|---|
| `Navigator.push` | `HomeScreen._openPriceCheck`, `CatalogScreen._openDetail`, `ResultScreen._openStores` | `Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(series: series)))` |
| `Navigator.pop` | `ResultScreen._done`, dialog | `Navigator.of(context).pop()` |
| `Navigator.pushReplacement` | `SplashScreen._route`, `LoginScreen._submit` | `Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RootScreen(...)))` |
| `Navigator.pushAndRemoveUntil` | `ProfileScreen._logout` | `Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false)` |

**Passing data:**

```dart
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.analysis,
    this.sourceLabel = 'Cek Harga',
  });

  final PriceAnalysis analysis;
  final String sourceLabel;
}
```

`required` + default value terbukti dalam satu constructor.

`CatalogScreen` → `ProductDetailScreen`:

```dart
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.series,
    this.sourceLabel = 'Etalase',
  });

  final ProductSeries series;
  final String sourceLabel;
}
```

`ProductDetailScreen` → `PriceCheckScreen`:

```dart
class PriceCheckScreen extends StatefulWidget {
  const PriceCheckScreen({super.key, this.initialQuery = ''});
  final String initialQuery; // diisi dari seri produk etalase
}
```

### 6.4 Etalase “Cari” & Detail Produk

**Tujuan UX:** tab Cari bukan form pencarian harga, tetapi **etalase katalog**: satu kartu = satu seri produk. User bisa melihat spesifikasi seri, daftar varian, lalu langsung cek harga atau menyimpan ke wishlist.

**`CatalogService` — grouping seri:**

```dart
class CatalogService {
  CatalogService(this._bundle);
  final AssetBundle _bundle;

  List<CatalogItem>? _items;
  List<ProductSeries>? _series;

  Future<List<CatalogItem>> loadItems() async {
    // baca assets/data/retail_catalog.json
    // CatalogItem.fromJson(section, json) untuk tiap item
  }

  Future<List<ProductSeries>> loadSeries() async {
    final items = await loadItems();
    final grouped = <String, List<CatalogItem>>{};
    for (final item in items) {
      final key = '${item.section}:${_seriesKey(item)}';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped.entries.map((e) {
      final variants = e.value..sort((a, b) => a.price.compareTo(b.price));
      return ProductSeries.fromItems(
        id: e.key,
        name: _displayName(variants.first),
        category: variants.first.section,
        imageAsset: _imageFor(variants.first.section),
        variants: variants,
      );
    }).toList()
      ..sort((a, b) => b.variantCount.compareTo(a.variantCount));
  }

  static String _seriesKey(CatalogItem item) {
    final model = item.model.toUpperCase();
    return switch (item.section) {
      'gpu' => _firstMatch(model, r'(RTX|GTX|RX|ARC)\s?\d{3,4}\s?(TI|XT|SUPER)?') ?? model,
      'cpu' => _firstMatch(model, r'(RYZEN\s?[3579]\s?\d{4}[A-Z0-9]*|CORE\s?I[3579][- ]?\d{4,5}[A-Z]*|ULTRA\s?[579]\s?\d{3}[A-Z]*)') ?? model,
      'motherboard' => _firstMatch(model, r'(A520|B550|B650|X570|X670|H610|B760|Z790|H81|B85|A620|B840)') ?? model,
      'ram' => _ramSeriesKey(model),
      'storage' => _storageSeriesKey(model),
      _ => model,
    };
  }

  static String _ramSeriesKey(String model) {
    final type = _firstMatch(model, r'(DDR[345])') ?? 'DDR';
    final capacity = _firstMatch(model, r'(\d{1,3})\s?GB') ?? '';
    final speed = _firstMatch(model, r'(\d{4,5})\s?MHZ') ?? '';
    return [type, capacity, speed].where((e) => e.isNotEmpty).join(' ');
  }

  static String _storageSeriesKey(String model) {
    final capacity = _firstMatch(model, r'(\d{3,4}\s?(GB|TB))') ?? '';
    final interface = _firstMatch(model, r'(NVME|SATA|M\.2)') ?? '';
    return [interface, capacity].where((e) => e.isNotEmpty).join(' ');
  }

  static String _imageFor(String section) => switch (section) {
        'cpu' => 'assets/images/cpu.png',
        'gpu' => 'assets/images/gpu.png',
        'motherboard' => 'assets/images/motherboard.png',
        'ram' => 'assets/images/ram.png',
        'storage' => 'assets/images/storage.png',
        _ => 'assets/images/gpu.png',
      };
}
```

**`SpecParser` — spesifikasi dari nama model:**

```dart
abstract final class SpecParser {
  static Map<String, String> parse(String category, String model) {
    final text = model.toUpperCase();
    final specs = <String, String>{};

    if (category == 'gpu') {
      _putMatch(specs, 'VRAM', text, r'(\d{1,2})\s?GB');
      _putMatch(specs, 'Memori', text, r'(GDDR\d[A-Z]?)');
      _putMatch(specs, 'Brand', text, r'^(ASUS|MSI|GIGABYTE|ASROCK|ZOTAC|GALAX|PALIT|SAPPHIRE|XFX|INTEL|NVIDIA|AMD)');
    }
    if (category == 'cpu') {
      _putMatch(specs, 'Socket', text, r'(AM4|AM5|LGA\s?\d{3,4})');
      _putMatch(specs, 'Core', text, r'(\d{1,2})\s?CORE');
      _putMatch(specs, 'Thread', text, r'(\d{1,3})\s?THREAD');
      _putMatch(specs, 'Boost', text, r'(\d\.\d)\s?GHZ');
    }
    if (category == 'motherboard') {
      _putMatch(specs, 'Socket', text, r'(AM4|AM5|LGA\s?\d{3,4})');
      _putMatch(specs, 'Chipset', text, r'(A520|B550|B650|X570|X670|H610|B760|Z790|A620|B840)');
    }
    if (category == 'ram') {
      _putMatch(specs, 'Kapasitas', text, r'(\d{1,3})\s?GB');
      _putMatch(specs, 'Kecepatan', text, r'(\d{4})\s?MHZ');
      _putMatch(specs, 'Tipe', text, r'(DDR[345])');
    }
    if (category == 'storage') {
      _putMatch(specs, 'Kapasitas', text, r'(\d{3,4}\s?(GB|TB))');
      _putMatch(specs, 'Interface', text, r'(NVME|SATA|M\.2)');
    }
    if (specs.isEmpty) {
      specs['Spesifikasi'] = 'Mengikuti model: ${model.split(' - ').first}';
    }
    return specs;
  }
}
```

> Helper `_putMatch` memakai `RegExp.firstMatch`; `_firstMatch`, `_displayName`, `_ramSeriesKey`, dan `_storageSeriesKey` adalah private helper di `CatalogService`. Jika regex tidak menemukan pola, seri memakai nama model apa adanya — tidak ada data yang hilang.

**`CatalogScreen` (tab Cari):**

- `HomeScreen` menampilkan kartu “Cari Produk” yang memanggil `onOpenTab(1)` agar etalase tidak tersembunyi.
- `StatefulWidget` dengan `_query`, `_selectedCategory`, `_series`, `_isLoading`, `_error`.
- `AppBar` title “Cari / Etalase”; `actions` ikon `Icons.tune` untuk reset filter.
- Search `TextField` + debounce 250 ms (opsional, atau filter langsung karena data lokal).
- Filter kategori memakai horizontal `ChoiceChip` (Semua, GPU, CPU, Motherboard, RAM, Storage) agar tidak overflow di layar 320dp.
- `GridView.builder` 2 kolom (`childAspectRatio` ±0.78) → `ProductSeriesCard`; kartu memakai `Image.asset` + teks yang di-ellipsis agar aman di 320dp.
- `ProductSeriesCard`: `Image.asset(series.imageAsset)`, badge kategori, nama seri, harga mulai, jumlah varian. `onTap` → `ProductDetailScreen(series: series)`.
- Empty state jika filter tidak menemukan seri.

**`ProductDetailScreen`:**

- `AppBar` dengan leading back, title `series.name`, actions wishlist.
- Header: `Stack` gambar kategori + gradient overlay + badge kategori.
- Spesifikasi: `Wrap` berisi `SpecChip` dari `series.specs`.
- Rentang harga + jumlah varian.
- `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` di dalam `SingleChildScrollView` untuk semua varian: model + harga.
- Tombol:
  - `MonexPrimaryButton` “Cek Harga” → `PriceCheckScreen(initialQuery: series.name)`.
  - `MonexSecondaryButton` “Toko Terdekat” → `NearbyStoresScreen(initialQuery: series.name)`.
  - `IconButton` wishlist → `WishlistRepository.add(WishlistItem(query: series.name, targetPrice: series.minPrice))` + notifikasi.

**Gambar kategori:**

- 5 ilustrasi lokal dibuat dengan Pillow: `tool/generate_category_images.py`.
- Ukuran 1200×800, background `#1B202C`, aksen lime, ikon/teks kategori.
- Tidak ada ketergantungan internet untuk etalase.

### 6.5 Modul 5 — HTTP Request

**File:** `lib/services/currency_api.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';

class CurrencyApi {
  CurrencyApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static final _uri = Uri.parse('https://open.er-api.com/v6/latest/IDR');

  Future<List<CurrencyRate>> fetchRates() async {
    final response = await _client.get(_uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw CurrencyApiException('Server kurs mengembalikan ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const CurrencyApiException('Format respons kurs tidak valid.');
    }
    if (decoded['result'] != 'success') {
      throw const CurrencyApiException('Layanan kurs sedang tidak tersedia.');
    }

    final rawRates = decoded['rates'];
    if (rawRates is! Map<String, dynamic>) {
      throw const CurrencyApiException('Data rates tidak ditemukan.');
    }

    const wanted = {'USD', 'SGD', 'MYR', 'EUR', 'JPY'};
    return rawRates.entries
        .where((e) => wanted.contains(e.key) && e.value is num)
        .map((e) => CurrencyRate(code: e.key, rate: (e.value as num).toDouble()))
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));
  }

  void dispose() => _client.close();
}
```

**File:** `lib/models/currency_rate.dart`

```dart
class CurrencyRate {
  const CurrencyRate({required this.code, required this.rate});
  final String code;
  final double rate;

  factory CurrencyRate.fromJson(Map<String, dynamic> json) => CurrencyRate(
        code: json['code'] as String,
        rate: (json['rate'] as num).toDouble(),
      );

  double convertFromIdr(double amount) => amount * rate;
}
```

**`ConverterScreen`:**

- `initState` → `_loadRates()`.
- `_isLoading` → `CircularProgressIndicator`.
- `_error` → `Text` + `ElevatedButton` “Coba lagi”.
- `_rates` → `ListView.builder` + `ListTile` kode/rate.
- Input nominal → `TextField` + `setState` → hasil konversi.
- `dispose` → controller + `CurrencyApi.dispose()`.

### 6.6 Modul 6 — Local Storage

#### SharedPreferences

**File:** `lib/services/session_preferences.dart`

```dart
class SessionPreferences {
  SessionPreferences(this._prefs);
  final SharedPreferences _prefs;

  static const _kLoggedIn = 'is_logged_in';
  static const _kUsername = 'active_username';
  static const _kTheme = 'theme_mode';

  bool get isLoggedIn => _prefs.getBool(_kLoggedIn) ?? false;
  String? get activeUsername => _prefs.getString(_kUsername);

  Future<void> saveSession({required String username}) async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kUsername, username);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_kLoggedIn, false);
    await _prefs.remove(_kUsername);
  }

  String get themeMode => _prefs.getString(_kTheme) ?? 'system';
  Future<void> saveThemeMode(String mode) => _prefs.setString(_kTheme, mode);
}
```

`ThemeController` membaca/menulis `theme_mode`; `AuthService` memakai `saveSession`/`clearSession`.

#### Hive

**File:** `lib/services/hive_service.dart`

```dart
class HiveService {
  static const wishlistBoxName = 'wishlist';
  static const historyBoxName = 'history';
  static const accountsBoxName = 'accounts';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WishlistItemAdapter());
    await Hive.openBox<WishlistItem>(wishlistBoxName);
    await Hive.openBox<dynamic>(historyBoxName);
    await Hive.openBox<dynamic>(accountsBoxName);
  }
}
```

**File:** `lib/models/wishlist_item.dart`

```dart
import 'package:hive/hive.dart';

class WishlistItem extends HiveObject {
  WishlistItem({required String query, required int targetPrice, String condition = 'baru'})
      : _query = _validateQuery(query),
        _targetPrice = _validateTargetPrice(targetPrice),
        _condition = _validateCondition(condition);

  WishlistItem.empty() : this(query: 'Produk baru', targetPrice: 1000000);

  String _query;
  int _targetPrice;
  String _condition;

  String get query => _query;
  int get targetPrice => _targetPrice;
  String get condition => _condition;

  set query(String value) => _query = _validateQuery(value);
  set targetPrice(int value) => _targetPrice = _validateTargetPrice(value);

  static String _validateQuery(String value) { ... }
  static int _validateTargetPrice(int value) { ... }
  static String _validateCondition(String value) { ... }
}

class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 0;

  @override
  WishlistItem read(BinaryReader reader) {
    final query = reader.readString();
    final targetPrice = reader.readInt();
    final condition = reader.readString();
    return WishlistItem(query: query, targetPrice: targetPrice, condition: condition);
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeString(obj.query)
      ..writeInt(obj.targetPrice)
      ..writeString(obj.condition);
  }
}
```

**File:** `lib/services/wishlist_repository.dart`

```dart
class WishlistRepository {
  WishlistRepository(this._box);
  final Box<WishlistItem> _box;

  // Create
  Future<void> add(WishlistItem item) => _box.add(item);

  // Read
  List<WishlistItem> getAll() => _box.values.toList();
  WishlistItem? getAt(int index) => _box.getAt(index);

  // Update
  Future<void> updateAt(int index, WishlistItem item) => _box.putAt(index, item);

  // Delete
  Future<void> deleteAt(int index) => _box.deleteAt(index);

  int get length => _box.length;
  Stream<BoxEvent> watch() => _box.watch();
}
```

**UI Wishlist:**

- `ListView.builder` menampilkan `_items[index]`.
- Tap item → dialog edit target harga → `updateAt(index, updated)`.
- Swipe/delete icon → `deleteAt(index)`.
- FAB “Tambah” → dialog query + target → `add()`.
- `ValueListenableBuilder`/`StreamBuilder` boleh dipakai untuk reaktif, tetapi `setState` + reload setelah CRUD lebih sederhana dan eksplisit.

**History Hive:**

- `HistoryRepository` memakai `Box<dynamic>`.
- `add(PriceAnalysis analysis)` → `box.add(analysis.toJson())`.
- `getAll()` → `box.values.map((e) => PriceAnalysis.fromJson(Map<String, dynamic>.from(e as Map)))`.
- `deleteAt(index)` → `box.deleteAt(index)`.
- Ditampilkan di `HomeScreen` (3 terbaru) dan `ResultScreen` (setelah simpan).
- **Ini riwayat ringan, bukan hash chain/blockchain.** Tidak ada `prevHash`, `hash`, atau layar verifikasi tamper.

### 6.7 Modul 7 — Notification & LBS + Peta

#### Notification service

**File:** `lib/services/notification_service.dart`

```dart
class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'worthbang_reminders';
  static const _channelName = 'WorthBang Reminder';
  static const _dailyReminderId = 1001;

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Pengingat cek harga dan info toko terdekat',
          importance: Importance.high,
        ));
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  @override
  Future<void> showImmediate({required String title, required String body}) async {
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  @override
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'Waktunya cek harga',
      body: 'Buka Wishlist dan cek apakah target harga kamu sudah tercapai.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDailyReminder() => _plugin.cancel(_dailyReminderId);

  @override
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? true;
  }
}
```

**Pemakaian immediat:**

| Aksi | Lokasi | Pesan |
|---|---|---|
| Cek harga selesai | `PriceCheckScreen._submit` | “Cek harga selesai: {query} — {verdict.label}” |
| Simpan wishlist | `WishlistScreen._add` / `_update` | “Wishlist tersimpan: {query} (target Rp…)” |
| Toko terdekat | `NearbyStoresScreen._notifyNearest` | “Toko terdekat: {name} ({distance} km) dari lokasi kamu ({lat}, {lng})” |

**Pemakaian scheduled:**

- `ProfileScreen` toggle “Pengingat harian” → `requestPermission()` → `scheduleDailyReminder(hour: 9, minute: 0)` → simpan `notifications_enabled=true` di SharedPreferences.
- Toggle off → `cancelDailyReminder()` → simpan `false`.

#### Location service

**File:** `lib/services/location_service.dart`

```dart
class GeolocatorLocationService implements LocationService {
  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationSnapshot> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('Aktifkan layanan lokasi/GPS terlebih dahulu.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Izin lokasi ditolak.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException('Izin lokasi diblokir permanen. Buka Pengaturan aplikasi.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(const Duration(seconds: 15));

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      capturedAt: DateTime.now(),
    );
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
```

**`NearbyStoresScreen` + `FlutterMap`:**

- `initState` → `_loadLocationAndStores()`.
- Jika izin ditolak: tampilkan `PermissionBanner` + tombol “Coba lagi” / “Buka Pengaturan”.
- Jika berhasil: tampilkan peta OSM setinggi ±240 px, lalu koordinat `Text('Latitude: ...')`, `Text('Longitude: ...')`, `Text('Akurasi: ... m')`.
- `StoreService.nearest(lat, lng, query)` → `List<Store>` sorted by distance.
- `ListView.builder` → `ListTile` nama, alamat, jarak; tap → `_mapController.move(LatLng(store.lat, store.lng), 15)`.
- Tombol “Notifikasi toko terdekat” → `_notifyNearest()`.
- `dispose` → controller pencarian + `MapController` tidak perlu dispose (flutter_map), tetapi pastikan tidak ada timer.

```dart
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _center,
    initialZoom: 13,
    onMapReady: () => _mapController.move(_center, 13),
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.worthbang.worthbang_lite',
      maxNativeZoom: 19,
    ),
    MarkerLayer(
      markers: [
        Marker(
          point: _center,
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
        for (final store in _stores)
          Marker(
            point: LatLng(store.lat, store.lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showStore(store),
              child: const Icon(Icons.location_on, color: Colors.red, size: 32),
            ),
          ),
      ],
    ),
    const RichAttributionWidget(
      attributions: [TextSourceAttribution('OpenStreetMap contributors')],
    ),
  ],
)
```

- Peta dibungkus `Stack` agar bisa menampilkan FAB “ke lokasi saya” dan banner error tile.
- Jika tile gagal dimuat (offline), daftar toko tetap tampil; beri catatan “Peta butuh internet”.
- `userAgentPackageName` wajib agar tile OSM tidak diblokir.

**`StoreService`:**

- Load `assets/data/stores.json` via `rootBundle.loadString`.
- Parse `List<dynamic>` → `List<Store>`.
- `haversineKm(lat1, lng1, lat2, lng2)`.
- Filter `radiusKm = 25`, sort ascending.
- `Store` model: `id`, `name`, `address`, `lat`, `lng`, `prices` (Map<String,int>).

---

## 7. File-by-File Work Plan

| File | Aksi | Isi utama |
|---|---|---|
| `tool/generate_category_images.py` | NEW | Generate 5 ilustrasi kategori etalase dengan Pillow |
| `app/pubspec.yaml` | NEW | Dependensi §4.2, aset, font |
| `app/android/app/src/main/AndroidManifest.xml` | NEW | Izin + receiver §4.4 |
| `app/android/app/build.gradle.kts` | EDIT | Desugaring + minSdk §4.5 |
| `lib/main.dart` | NEW | Bootstrap Hive, SharedPreferences, notification, dependencies, `runApp` |
| `lib/app.dart` | NEW | `WorthBangApp` + `AppScope` + `MaterialApp` |
| `lib/core/theme/monex_theme.dart` | PORT | Token warna/spacing/theme dari baseline |
| `lib/core/widgets/monex_widgets.dart` | PORT + REFACTOR | `MonexSurfaceCard`, `MonexPrimaryButton` (ElevatedButton), `MonexSecondaryButton`, `MonexEmptyState`, `MonexSectionHeader` |
| `lib/core/utils/formatters.dart` | NEW | `formatRupiah`, `formatDate`, `formatDistance` |
| `lib/core/utils/validators.dart` | NEW | `validateQuery`, `validatePrice`, `validateEmail`, `validatePassword` |
| `lib/core/utils/spec_parser.dart` | NEW | `SpecParser.parse` untuk spesifikasi seri (GPU/CPU/motherboard/RAM/storage) |
| `lib/models/price_check_request.dart` | NEW | Generative + `.fromJson` + `.empty`, private fields, getter/setter |
| `lib/models/price_analysis.dart` | NEW | `PriceAnalysis` + `.fromJson` + `.empty`, `toJson`, `comparisons` |
| `lib/models/price_verdict.dart` | NEW | `PriceVerdict` + 4 subclass, `@override` |
| `lib/models/catalog_item.dart` | NEW | `CatalogItem` + 5 subclass, `referencePrice` override |
| `lib/models/product_series.dart` | NEW | `ProductSeries` + `.fromItems` + `.empty`, agregasi varian + spesifikasi |
| `lib/models/wishlist_item.dart` | NEW | `WishlistItem extends HiveObject` + adapter |
| `lib/models/user_account.dart` | NEW | `UserAccount` + `.fromMap`, `toMap`, `avatarUrl` |
| `lib/models/currency_rate.dart` | NEW | `CurrencyRate` + `.fromJson`, `convertFromIdr` |
| `lib/models/store.dart` | NEW | `Store` + `.fromJson`, `distanceKm` |
| `lib/models/location_snapshot.dart` | NEW | `LocationSnapshot`, `LocationException` |
| `lib/state/session_controller.dart` | NEW | `ChangeNotifier`, `login/register/logout/restore` |
| `lib/state/theme_controller.dart` | NEW | `ChangeNotifier`, baca/tulis tema dari SharedPreferences |
| `lib/state/app_dependencies.dart` | NEW | Container service/repository |
| `lib/state/app_scope.dart` | NEW | `InheritedWidget` untuk akses dependencies |
| `lib/services/session_preferences.dart` | NEW | SharedPreferences session/theme |
| `lib/services/hive_service.dart` | NEW | `Hive.initFlutter`, register adapter, open boxes |
| `lib/services/auth_service.dart` | NEW | Register/login/hash/verify, Hive accounts |
| `lib/services/catalog_service.dart` | NEW | Load `retail_catalog.json` → `List<CatalogItem>` + grouping `List<ProductSeries>` |
| `lib/services/price_analyzer.dart` | NEW | `abstract PriceAnalyzer` + `CatalogPriceAnalyzer` + scoring |
| `lib/services/history_repository.dart` | NEW | Hive history CRUD |
| `lib/services/wishlist_repository.dart` | NEW | Hive wishlist full CRUD (`add`, `getAt`, `putAt`, `deleteAt`) |
| `lib/services/currency_api.dart` | NEW | `http.get`, `jsonDecode`, `List<CurrencyRate>` |
| `lib/services/location_service.dart` | NEW | `abstract LocationService` + `GeolocatorLocationService` |
| `lib/services/notification_service.dart` | NEW | `abstract NotificationService` + `LocalNotificationService` |
| `lib/services/store_service.dart` | NEW | Load `stores.json`, haversine, filter/sort |
| `lib/screens/splash_screen.dart` | NEW | Cek sesi → `pushReplacement` |
| `lib/screens/login_screen.dart` | NEW | Form login, validator, `pushReplacement` ke Root |
| `lib/screens/register_screen.dart` | NEW | Form register, `push`/`pop` |
| `lib/screens/root_screen.dart` | NEW | `BottomNavigationBar`, `_selectedIndex`, `_pages` |
| `lib/screens/home_screen.dart` | NEW | Greeting, hero Cek Harga, GridView menu, riwayat terbaru, AppBar lengkap |
| `lib/screens/catalog_screen.dart` | NEW | Tab Cari: pencarian + filter kategori + GridView seri produk |
| `lib/screens/product_detail_screen.dart` | NEW | Detail seri: gambar, spesifikasi, varian + harga, cek harga/wishlist/toko |
| `lib/screens/price_check_screen.dart` | NEW | Form + validator + loading/error + panggil analyzer |
| `lib/screens/result_screen.dart` | NEW | Verdict badge, skor, referensi, pembanding, simpan wishlist, toko, notifikasi |
| `lib/screens/wishlist_screen.dart` | NEW | List Hive, add/edit/delete, notifikasi |
| `lib/screens/nearby_stores_screen.dart` | NEW | Permission, koordinat, peta FlutterMap, list toko, notifikasi |
| `lib/screens/converter_screen.dart` | NEW | HTTP fetch, loading/error, ListView rates, konversi |
| `lib/screens/profile_screen.dart` | NEW | Avatar `Image.network`, tema, izin, reminder, logout `pushAndRemoveUntil` |
| `lib/widgets/app_logo.dart` | PORT | `Image.asset` |
| `lib/widgets/product_series_card.dart` | NEW | Kartu etalase: gambar kategori, nama seri, harga mulai, jumlah varian |
| `lib/widgets/spec_chip.dart` | NEW | Chip label + nilai spesifikasi |
| `lib/widgets/verdict_badge.dart` | NEW | `PriceVerdict` polymorphic badge |
| `lib/widgets/permission_banner.dart` | NEW | Banner izin + tombol pengaturan |
| `lib/widgets/empty_state.dart` | NEW | Empty state reusable |
| `lib/widgets/section_header.dart` | NEW | Judul seksi + aksi |
| `lib/widgets/wishlist_tile.dart` | NEW | `ListTile` + edit/delete |

---

## 8. Implementation Phases

### Phase 0 — Scaffold & Platform (foundation)

- `flutter create` proyek `app/`.
- Isi `pubspec.yaml`, salin aset/font/icon.
- Generate 5 ilustrasi kategori etalase dengan Pillow (`tool/generate_category_images.py`).
- Konfigurasi `AndroidManifest.xml`, `build.gradle.kts`.
- Port `monex_theme.dart` + widget dasar.
- **Acceptance:** `flutter pub get`, `flutter analyze` bersih, app menampilkan halaman kosong bertema Monex.

### Phase 1 — OOP Core & Models

- `PriceCheckRequest`, `PriceAnalysis`, `PriceVerdict` + subclasses, `CatalogItem` + subclasses, `ProductSeries`, `WishlistItem` + adapter, `UserAccount`, `CurrencyRate`, `Store`, `LocationSnapshot`.
- Unit test OOP: constructor, redirecting, getter/setter validation, polymorphism, `ProductSeries.fromItems`.
- **Acceptance:** test model lulus; `PriceCheckRequest.empty()`, `ProductSeries.empty()`, dan `.fromJson()` bekerja.

### Phase 2 — Storage & Auth

- `HiveService`, `SessionPreferences`, `AuthService`, `SessionController`, `ThemeController`.
- `WishlistRepository` full CRUD; `HistoryRepository`.
- Unit test Hive CRUD dan session.
- **Acceptance:** register → login → restart app → sesi pulih; wishlist add/read/update/delete bertahan setelah restart.

### Phase 3 — Catalog & Price Analyzer

- `CatalogService` load `retail_catalog.json` → `List<CatalogItem>` + grouping `List<ProductSeries>`.
- `SpecParser` mengekstrak spesifikasi dasar dari nama model.
- `CatalogPriceAnalyzer`: token matching, `referencePrice` polimorfik, median, scoring, verdict.
- Unit test: CPU/GPU/RAM/storage, data tidak ditemukan, harga murah/wajar/mahal, grouping seri.
- **Acceptance:** query “RTX 4060” menghasilkan skor/verdict dan pembanding; etalase menghasilkan satu kartu per seri.

### Phase 4 — UI Shell, Navigasi, Auth Screens

- `SplashScreen`, `LoginScreen`, `RegisterScreen`, `RootScreen`, `HomeScreen`.
- `CatalogScreen` (tab Cari/Etalase) + `ProductDetailScreen`.
- `BottomNavigationBar` indexed 4 tab, `pushReplacement`, `push`, `pop`.
- Widget test: 4 tab, login → root, logout → login, etalase → detail.
- **Acceptance:** seluruh alur navigasi Modul 4 lulus.

### Phase 5 — Price Check, Result, History, Wishlist

- `PriceCheckScreen`, `ResultScreen`, `WishlistScreen`, `WishlistTile`.
- Simpan riwayat otomatis; simpan wishlist; edit/delete.
- Immediate notification pada simpan.
- Widget test: validasi form, loading/error, hasil tampil.
- **Acceptance:** cek harga → hasil → wishlist → notifikasi; CRUD Hive terbukti.

### Phase 6 — HTTP Converter & LBS

- `CurrencyApi` + `ConverterScreen` (http, jsonDecode, ListView).
- `LocationService` + `NearbyStoresScreen` + `StoreService` + `FlutterMap` OSM.
- Permission flows, koordinat, peta, marker, jarak, notifikasi toko terdekat.
- Unit test parsing currency dengan `MockClient`; widget test permission state + map presence.
- **Acceptance:** konverter menampilkan rates dari internet; toko terdekat menampilkan peta, koordinat, jarak, dan notifikasi.

### Phase 7 — Notification Scheduling, QA, RTM

- `scheduleDailyReminder`, `cancelDailyReminder`, toggle di `ProfileScreen`.
- Permission Android 13+ dan status izin di profil.
- `flutter analyze`, `flutter test`, build APK.
- Isi RTM dengan bukti final; hapus semua kode mati.
- **Acceptance:** semua checkbox RTM tercentang; tidak ada `TODO`; APK debug/release bisa dibuka.

---

## 9. Error Handling & Lifecycle Checklist

### 9.1 Controller & resource

- [ ] Setiap `TextEditingController` di-`dispose()` di `State.dispose()`.
- [ ] Controller di dialog dibuat lokal dan di-`dispose()` setelah `showDialog` selesai (`try/finally`).
- [ ] `ScrollController` (jika ada) di-`dispose()`.
- [ ] `http.Client` di-`dispose()` saat service dihancurkan.
- [ ] Tidak ada `Timer` tanpa `cancel()`.
- [ ] Tidak ada listener `ChangeNotifier` tanpa `removeListener`.

### 9.2 Async UI

- [ ] Setiap operasi async memiliki `_isLoading` dan `_error`.
- [ ] Setelah `await`, cek `if (!mounted) return;` sebelum `setState`.
- [ ] Error ditampilkan sebagai pesan manusiawi, bukan `e.toString()` mentah.
- [ ] Tombol dinonaktifkan saat loading (`onPressed: _isLoading ? null : _submit`).
- [ ] Form memakai `GlobalKey<FormState>` + `validator`.

### 9.3 Permission

- [ ] Notifikasi: cek `areNotificationsEnabled()`, minta `requestNotificationsPermission()`, tangani `false`.
- [ ] Lokasi: cek service enabled → permission → `denied`/`deniedForever` → pesan + tombol pengaturan.
- [ ] Tidak meminta izin berulang otomatis saat app dibuka; minta saat user menekan aksi.
- [ ] Jika izin ditolak, fitur tetap bisa dipakai dengan fallback yang jelas (bukan crash).

### 9.4 Storage

- [ ] `Hive.initFlutter()` dan `openBox` dibungkus `try/catch` di `main`; jika gagal, tampilkan `BootstrapErrorApp`.
- [ ] `SharedPreferences.getInstance()` tidak dipanggil berulang di build; inject dari `AppDependencies`.
- [ ] Data korup di Hive ditangani (`try/catch` saat decode history).
- [ ] Hapus item memakai index yang valid; refresh list setelah CRUD.

---

## 10. Testing Strategy

### 10.1 Unit test

| Test | File | Fokus |
|---|---|---|
| Constructor & redirecting | `test/models/price_check_request_test.dart` | generative, `.fromJson`, `.empty`, setter validasi |
| Encapsulation | `test/models/wishlist_item_test.dart` | target price invalid ditolak, query trim |
| Polymorphism | `test/models/price_verdict_test.dart` | label/color/advice berbeda per subclass |
| Catalog polymorphism | `test/models/catalog_item_test.dart` | `referencePrice` RAM/CPU berbeda |
| Product series | `test/models/product_series_test.dart` | grouping varian, `.fromItems`, `.empty`, harga min/max |
| Spec parser | `test/core/spec_parser_test.dart` | GPU VRAM, CPU socket, RAM capacity, storage interface |
| Analyzer | `test/services/price_analyzer_test.dart` | skor, verdict, data terbatas, pembanding |
| Hive CRUD | `test/services/wishlist_repository_test.dart` | add/getAt/putAt/deleteAt + persist |
| Session | `test/services/session_preferences_test.dart` | save/read/clear |
| HTTP parse | `test/services/currency_api_test.dart` | `MockClient` 200/500/JSON rusak |
| Store distance | `test/services/store_service_test.dart` | haversine + sort |
| Notification (fake) | `test/services/notification_service_test.dart` | fake implementation dipanggil pada aksi |

### 10.2 Widget test

| Test | File | Fokus |
|---|---|---|
| Root indexed nav | `test/navigation/root_screen_test.dart` | 4 tab, `_selectedIndex` berubah |
| Login validation | `test/screens/login_screen_test.dart` | error validator, loading |
| Catalog/Etalase | `test/screens/catalog_screen_test.dart` | grid seri, filter kategori, pencarian, empty state |
| Product detail | `test/screens/product_detail_screen_test.dart` | spesifikasi, varian, tombol cek harga/wishlist |
| Price form | `test/screens/price_check_screen_test.dart` | validasi, conditional rendering |
| Result | `test/screens/result_screen_test.dart` | verdict badge, tombol |
| Wishlist | `test/screens/wishlist_screen_test.dart` | empty state, add/delete |
| Converter | `test/screens/converter_screen_test.dart` | loading/error/list |
| Profile | `test/screens/profile_screen_test.dart` | toggle tema, logout dialog |

### 10.3 Manual verification (device/emulator)

- [ ] Install APK, register, login, restart → sesi tetap.
- [ ] Buka tab Cari → etalase menampilkan satu kartu per seri; filter GPU/CPU/RAM/storage berfungsi.
- [ ] Klik seri “RTX 4060” → detail menampilkan spesifikasi + varian + harga.
- [ ] Dari detail → Cek Harga → form terisi otomatis; hasil + skor + pembanding.
- [ ] Simpan wishlist → notifikasi immediate muncul.
- [ ] Edit target wishlist → nilai berubah; hapus → hilang; restart → data konsisten.
- [ ] Aktifkan reminder harian → notifikasi terjadwal (uji dengan waktu 1–2 menit ke depan).
- [ ] Buka Toko Terdekat → izin lokasi → peta OSM + marker + koordinat + jarak → notifikasi toko terdekat.
- [ ] Matikan GPS → pesan jelas; tolak izin → banner + tombol pengaturan.
- [ ] Buka Konverter → data rates tampil; matikan internet → error + retry.
- [ ] Logout → kembali ke Login; back tidak bisa masuk Root.
- [ ] Rotasi/ukuran layar kecil (320dp) → tidak overflow.

### 10.4 Commands

```powershell
cd app
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

---

## 11. Requirements Traceability Matrix (RTM)

> Kolom “Bukti” menunjuk file/class/method yang **akan** dibuat. Setelah implementasi, kolom status diubah menjadi `[✅]` hanya jika sudah diverifikasi.

### 11.1 OOP

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| OOP-1 | Class & Object | [ ] | `lib/models/price_check_request.dart` | `PriceCheckRequest`, instance di `PriceCheckScreen` |
| OOP-2 | Generative constructor | [ ] | `lib/models/price_check_request.dart` | `PriceCheckRequest({required query, required price, condition})` |
| OOP-3 | Named constructor | [ ] | `lib/models/price_check_request.dart` | `PriceCheckRequest.fromJson` |
| OOP-4 | Redirecting constructor | [ ] | `lib/models/price_check_request.dart`, `wishlist_item.dart`, `product_series.dart` | `PriceCheckRequest.empty()`, `WishlistItem.empty()`, `ProductSeries.empty()` |
| OOP-5 | Encapsulation (private + getter) | [ ] | `lib/models/price_check_request.dart` | `_query`, `get query`, `get price`, `get condition` |
| OOP-6 | Encapsulation (setter validasi) | [ ] | `lib/models/price_check_request.dart` | `set query`, `set price`, `set condition` |
| OOP-7 | Inheritance (`extends` + `super`) | [ ] | `lib/models/price_verdict.dart`, `catalog_item.dart` | `WorthItVerdict extends PriceVerdict`; `CpuItem extends CatalogItem` |
| OOP-8 | Method overriding | [ ] | `lib/models/price_verdict.dart` | `@override label/color/icon/advice` di 4 subclass |
| OOP-9 | Polymorphism dipakai di UI | [ ] | `lib/widgets/verdict_badge.dart` | `VerdictBadge.build` memanggil `verdict.label/color/icon` |
| OOP-10 | Polymorphism dipakai di logic | [ ] | `lib/services/price_analyzer.dart` | `CatalogPriceAnalyzer` memanggil `item.referencePrice(pool)` |
| OOP-11 | Abstraction (`abstract class`) | [ ] | `lib/services/price_analyzer.dart` | `abstract class PriceAnalyzer` |
| OOP-12 | `implements` interface | [ ] | `lib/services/notification_service.dart`, `location_service.dart` | `LocalNotificationService implements NotificationService`; `GeolocatorLocationService implements LocationService` |
| OOP-13 | Named constructor agregasi + redirecting | [ ] | `lib/models/product_series.dart` | `ProductSeries.fromItems`, `ProductSeries.empty` |

### 11.2 Modul 2

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| M2-1 | `MaterialApp` | [ ] | `lib/app.dart` | `WorthBangApp.build` |
| M2-2 | `Scaffold` + `AppBar` + `body` | [ ] | `lib/screens/home_screen.dart`, `price_check_screen.dart` | `HomeScreen.build`, `PriceCheckScreen.build` |
| M2-3 | `AppBar leading/title/actions` | [ ] | `lib/screens/price_check_screen.dart` | `AppBar(leading:..., title:..., actions:...)` |
| M2-4 | `Container`, `SizedBox`, `Center`/`Align` | [ ] | `lib/core/widgets/monex_widgets.dart` | `MonexSurfaceCard.build`, `MonexEmptyState.build` |
| M2-5 | `Column`, `Row`, alignment | [ ] | `lib/screens/home_screen.dart`, `result_screen.dart` | `HomeScreen.build`, `ResultScreen._statRow` |
| M2-6 | `Stack` | [ ] | `lib/screens/profile_screen.dart`, `result_screen.dart`, `nearby_stores_screen.dart` | `ProfileScreen._avatar`, `ResultScreen._header`, peta + FAB overlay |
| M2-7 | `Text`, `Icon` | [ ] | Semua screen | — |
| M2-8 | `Image.asset` | [ ] | `lib/widgets/app_logo.dart`, `lib/widgets/product_series_card.dart` | `AppLogo.build`, `ProductSeriesCard.build` (ilustrasi kategori) |
| M2-9 | `Image.network` | [ ] | `lib/screens/profile_screen.dart` | `_avatar` memakai `Image.network(..., errorBuilder:)` |
| M2-10 | `TextButton` | [ ] | `lib/screens/login_screen.dart` | `TextButton` “Daftar di sini” |
| M2-11 | `OutlinedButton` | [ ] | `lib/core/widgets/monex_widgets.dart` | `MonexSecondaryButton.build` |
| M2-12 | `ElevatedButton` | [ ] | `lib/core/widgets/monex_widgets.dart` | `MonexPrimaryButton.build` |
| M2-13 | `TextField` | [ ] | `lib/screens/catalog_screen.dart`, `converter_screen.dart` | `TextField` pencarian seri + nominal |
| M2-14 | `TextFormField` + validator | [ ] | `lib/screens/price_check_screen.dart` | `TextFormField(validator: ...)` query & harga |
| M2-15 | `SingleChildScrollView` | [ ] | `lib/screens/price_check_screen.dart`, `product_detail_screen.dart` | `SingleChildScrollView` di `build` |
| M2-16 | `ListView.builder` | [ ] | `lib/screens/wishlist_screen.dart`, `product_detail_screen.dart` | `ListView.builder` wishlist + varian produk |
| M2-17 | `ListTile` | [ ] | `lib/screens/profile_screen.dart`, `product_detail_screen.dart` | `ListTile` menu + varian produk |
| M2-18 | `GridView.builder` | [ ] | `lib/screens/home_screen.dart`, `catalog_screen.dart` | `GridView.builder` menu fitur + grid seri etalase |
| M2-19 | `FlutterMap` + `MarkerLayer` + `Stack` | [ ] | `lib/screens/nearby_stores_screen.dart` | `NearbyStoresScreen._buildMap` |

### 11.3 Modul 3

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| M3-1 | `StatelessWidget` | [ ] | `lib/widgets/verdict_badge.dart` | `VerdictBadge extends StatelessWidget` |
| M3-2 | `StatefulWidget` | [ ] | `lib/screens/price_check_screen.dart` | `PriceCheckScreen extends StatefulWidget` |
| M3-3 | `setState()` | [ ] | `lib/screens/price_check_screen.dart` | `_submit`, `_onQueryChanged` |
| M3-4 | `TextEditingController` + dispose | [ ] | `lib/screens/price_check_screen.dart` | `_query`, `_price` di `dispose()` |
| M3-5 | Conditional rendering | [ ] | `lib/screens/price_check_screen.dart` | `if (_isLoading) ... else if (_error != null) ...` |
| M3-6 | Class model | [ ] | `lib/models/price_analysis.dart`, `product_series.dart` | `PriceAnalysis`, `ProductSeries` |
| M3-7 | Stateful etalase (search/filter) | [ ] | `lib/screens/catalog_screen.dart` | `_CatalogScreenState._query`, `_selectedCategory`, `setState` |

### 11.4 Modul 4

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| M4-1 | `Navigator.push()` | [ ] | `lib/screens/home_screen.dart`, `catalog_screen.dart` | `_openPriceCheck`, `_openDetail` |
| M4-2 | `Navigator.pop()` | [ ] | `lib/screens/result_screen.dart` | `_done` |
| M4-3 | `Navigator.pushReplacement()` | [ ] | `lib/screens/splash_screen.dart`, `login_screen.dart` | `_route`, `_submit` |
| M4-4 | `Navigator.pushAndRemoveUntil()` | [ ] | `lib/screens/profile_screen.dart` | `_logout` |
| M4-5 | Passing data `required` | [ ] | `lib/screens/result_screen.dart` | `ResultScreen({required this.analysis})` |
| M4-6 | Passing data default opsional | [ ] | `lib/screens/result_screen.dart`, `product_detail_screen.dart`, `nearby_stores_screen.dart` | `sourceLabel = 'Cek Harga'`, `sourceLabel = 'Etalase'`, `initialQuery = ''` |
| M4-7 | `BottomNavigationBar` | [ ] | `lib/screens/root_screen.dart` | `BottomNavigationBar` di `build` |
| M4-8 | `_selectedIndex` + `_pages[_selectedIndex]` | [ ] | `lib/screens/root_screen.dart` | `_RootScreenState._selectedIndex`, `_pages` (4 tab) |
| M4-9 | Passing model `ProductSeries` ke detail | [ ] | `lib/screens/product_detail_screen.dart` | `ProductDetailScreen({required this.series})` |

### 11.5 Modul 5

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| M5-1 | `http.get(Uri.parse(...))` | [ ] | `lib/services/currency_api.dart` | `fetchRates` |
| M5-2 | `Future` + `async` + `await` | [ ] | `lib/services/currency_api.dart` | `Future<List<CurrencyRate>> fetchRates() async` |
| M5-3 | `jsonDecode(response.body)` | [ ] | `lib/services/currency_api.dart` | `jsonDecode(response.body)` |
| M5-4 | Parse `Map`/`List` → model | [ ] | `lib/services/currency_api.dart`, `models/currency_rate.dart` | `CurrencyRate.fromJson` |
| M5-5 | Render `List<Model>` + loading | [ ] | `lib/screens/converter_screen.dart` | `ListView.builder` + `_isLoading`/`_error` |

### 11.6 Modul 6

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| M6-1 | SharedPreferences key-value | [ ] | `lib/services/session_preferences.dart` | `saveSession`, `readSession`, `clearSession` |
| M6-2 | SharedPreferences tema | [ ] | `lib/services/session_preferences.dart`, `state/theme_controller.dart` | `saveThemeMode`, `ThemeController.setThemeMode` |
| M6-3 | Hive init + Box | [ ] | `lib/services/hive_service.dart` | `HiveService.init` |
| M6-4 | TypeAdapter / HiveObject | [ ] | `lib/models/wishlist_item.dart` | `WishlistItem extends HiveObject`, `WishlistItemAdapter` |
| M6-5 | CRUD Create `add` | [ ] | `lib/services/wishlist_repository.dart` | `add` |
| M6-6 | CRUD Read `getAt`/`values` | [ ] | `lib/services/wishlist_repository.dart` | `getAll`, `getAt` |
| M6-7 | CRUD Update `putAt` | [ ] | `lib/services/wishlist_repository.dart` | `updateAt` |
| M6-8 | CRUD Delete `deleteAt` | [ ] | `lib/services/wishlist_repository.dart` | `deleteAt` |

### 11.7 Modul 7

| # | Persyaratan | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| M7-1 | Immediate notification | [ ] | `lib/services/notification_service.dart` | `showImmediate` |
| M7-2 | Immediate dipakai di aksi bisnis | [ ] | `lib/screens/wishlist_screen.dart`, `price_check_screen.dart`, `nearby_stores_screen.dart` | `_add`, `_submit`, `_notifyNearest` |
| M7-3 | Scheduled notification | [ ] | `lib/services/notification_service.dart` | `scheduleDailyReminder` (`zonedSchedule`) |
| M7-4 | Scheduled tetap aktif setelah app ditutup | [ ] | `android/app/src/main/AndroidManifest.xml`, `notification_service.dart` | `RECEIVE_BOOT_COMPLETED` + `ScheduledNotificationBootReceiver` |
| M7-5 | Permission notifikasi Android 13+ | [ ] | `lib/services/notification_service.dart`, `AndroidManifest.xml` | `requestNotificationsPermission`, `POST_NOTIFICATIONS` |
| M7-6 | Permission lokasi | [ ] | `lib/services/location_service.dart` | `getCurrentLocation` (`checkPermission`/`requestPermission`) |
| M7-7 | Latitude/longitude real-time | [ ] | `lib/services/location_service.dart` | `Geolocator.getCurrentPosition` |
| M7-8 | Lokasi tampil di UI + peta | [ ] | `lib/screens/nearby_stores_screen.dart` | `_location` + `Text('Latitude...')` + `FlutterMap`/`MarkerLayer` |
| M7-9 | Lokasi dipakai di notifikasi | [ ] | `lib/screens/nearby_stores_screen.dart` | `_notifyNearest` → `showImmediate` dengan jarak/koordinat |

### 11.8 Fitur produk (di luar checklist modul)

| # | Fitur | Status target | Bukti file | Class / Method |
|---|---|---|---|---|
| F-1 | Etalase satu kartu per seri | [ ] | `lib/screens/catalog_screen.dart`, `lib/widgets/product_series_card.dart` | `CatalogScreen._series`, `ProductSeriesCard.build` |
| F-2 | Grouping seri dari katalog | [ ] | `lib/services/catalog_service.dart` | `CatalogService.loadSeries`, `_seriesKey` |
| F-3 | Detail spesifikasi + varian | [ ] | `lib/screens/product_detail_screen.dart`, `lib/core/utils/spec_parser.dart` | `ProductDetailScreen.build`, `SpecParser.parse` |
| F-4 | Peta OSM + marker toko | [ ] | `lib/screens/nearby_stores_screen.dart` | `_buildMap` (`FlutterMap`, `TileLayer`, `MarkerLayer`) |
| F-5 | Notifikasi toko terdekat | [ ] | `lib/screens/nearby_stores_screen.dart` | `_notifyNearest` |

---

## 12. Risks & Open Decisions

| Risiko / keputusan | Dampak | Mitigasi |
|---|---|---|
| Clean rebuild vs trim `reference/` | Menentukan lokasi kerja | Default: `app/` baru; `reference/` read-only. Bisa diubah sebelum Phase 0. |
| Hive 2.2.3 sudah lama | Risiko kompatibilitas Dart 3.13 | Manual `TypeAdapter` (tanpa generator), test CRUD di CI; alternatif `hive_ce` jika blocking — tetapi requirement menyebut Hive, jadi tetap `hive`. |
| `Image.network` butuh internet | Avatar gagal saat offline | `errorBuilder` → inisial/`AppLogo`; bukan blocker fitur. |
| Tile OpenStreetMap butuh internet | Peta kosong saat offline | Daftar toko + koordinat tetap tampil; tampilkan catatan “peta butuh internet”; `userAgentPackageName` wajib diisi. |
| Grouping seri produk berbasis regex | Beberapa model bisa masuk seri yang kurang tepat | Fallback ke nama model apa adanya; unit test contoh nyata; series key bisa dirapikan bertahap. |
| API kurs publik punya rate limit | Konverter gagal saat demo | Timeout + error + retry; tidak memalsukan data. |
| Notifikasi terjadwal di OEM tertentu | Bisa tidak tepat waktu | Gunakan `inexactAllowWhileIdle`; dokumentasikan batasan; uji di perangkat nyata. |
| `flutter_local_notifications` 22.3.1 vs 23.0.1 | API bisa berubah | Pakai 22.3.1 (stabil, sesuai baseline) sampai upgrade diuji. |
| Package name / nama aplikasi | Naming final | Default `com.worthbang.worthbang_lite`, label “WorthBang Lite”; bisa diganti sebelum build. |
| Laptop mode | Dataset laptop tidak ada di katalog | Scope final **PC components only**; laptop tidak diklaim. |
| Target perangkat / minSdk | Perangkat dosen mungkin lama | `minSdk 23`; uji emulator API 33+ untuk notification permission. |

---

## 13. Definition of Done

- [ ] `PLAN.md` disetujui.
- [ ] Phase 0–7 selesai.
- [ ] `flutter analyze` → **No issues found**.
- [ ] `flutter test` → **all tests passed**.
- [ ] APK debug terpasang dan seluruh alur manual §10.3 lulus.
- [ ] Tab Cari/Etalase menampilkan satu kartu per seri + detail spesifikasi + varian.
- [ ] Peta OpenStreetMap tampil di Toko Terdekat beserta marker lokasi/toko.
- [ ] Setiap item RTM §11 tercentang dengan bukti file/class/method.
- [ ] Tidak ada `TODO`, `UnimplementedError`, halaman dummy, atau fitur yang tidak bisa diakses.
- [ ] Tidak ada dependency yang tidak dipakai.
- [ ] Semua `TextEditingController` di-dispose; semua async punya loading/error.
- [ ] Izin lokasi & notifikasi ditangani di device nyata/emulator.
- [ ] README aplikasi berisi cara menjalankan, izin, dan batasan.

---

## 14. Urutan Eksekusi Berikutnya

1. Setujui `PLAN.md` (terutama keputusan `app/` baru, scope PC-only, 4 tab, etalase, dan peta).
2. Saya jalankan **Phase 0** (scaffold + dependency + manifest + tema + ilustrasi kategori).
3. Lanjut **Phase 1–2** (OOP model + Hive/SP/auth) dengan unit test.
4. Lanjut **Phase 3–6** (analyzer + etalase/detail + UI + HTTP + LBS/peta/notification).
5. **Phase 7** QA + isi RTM final + build APK.

> **Catatan:** PLAN.md ini sengaja belum menulis seluruh isi file `lib/`. Kode lengkap akan ditulis pada fase implementasi sesuai tabel §7, sehingga setiap file bisa diuji dan tidak ada placeholder. Jika kamu ingin saya langsung mengeksekusi, cukup balas **“lanjut Phase 0”**.
