import 'package:flutter/material.dart';

/// Konfigurasi warna tombol dan kartu (card) untuk setiap halaman.
@immutable
class AppUiColors {
  const AppUiColors({
    required this.berandaCekHargaBg,
    required this.berandaCekHargaText,
    required this.berandaMenuCardBg,
    required this.berandaRiwayatCardBg,
    required this.detailKonversiCardBg,
    required this.detailVarianCardBg,
    required this.detailCekHargaBg,
    required this.detailCekHargaText,
    required this.cekHargaSubmitBg,
    required this.cekHargaSubmitText,
    required this.hasilVerdictCardBg,
    required this.hasilRingkasanCardBg,
    required this.hasilSimpanWishlistBg,
    required this.hasilSimpanWishlistText,
    required this.hasilTokoTerdekatBg,
    required this.hasilTokoTerdekatText,
    required this.hasilSelesaiBg,
    required this.hasilSelesaiText,
    required this.wishlistCardBg,
    required this.tokoCardBg,
    required this.profilTemaCardBg,
    required this.profilPengingatCardBg,
    required this.profilInfoCardBg,
    required this.profilUjiNotifBg,
    required this.profilUjiNotifText,
    required this.profilKeluarBg,
    required this.profilKeluarText,
    required this.loginMasukBg,
    required this.loginMasukText,
    required this.registerDaftarBg,
    required this.registerDaftarText,
  });

  final Color berandaCekHargaBg;
  final Color berandaCekHargaText;
  final Color berandaMenuCardBg;
  final Color berandaRiwayatCardBg;

  final Color detailKonversiCardBg;
  final Color detailVarianCardBg;
  final Color detailCekHargaBg;
  final Color detailCekHargaText;

  final Color cekHargaSubmitBg;
  final Color cekHargaSubmitText;

  final Color hasilVerdictCardBg;
  final Color hasilRingkasanCardBg;
  final Color hasilSimpanWishlistBg;
  final Color hasilSimpanWishlistText;
  final Color hasilTokoTerdekatBg;
  final Color hasilTokoTerdekatText;
  final Color hasilSelesaiBg;
  final Color hasilSelesaiText;

  final Color wishlistCardBg;
  final Color tokoCardBg;

  final Color profilTemaCardBg;
  final Color profilPengingatCardBg;
  final Color profilInfoCardBg;
  final Color profilUjiNotifBg;
  final Color profilUjiNotifText;
  final Color profilKeluarBg;
  final Color profilKeluarText;

  final Color loginMasukBg;
  final Color loginMasukText;
  final Color registerDaftarBg;
  final Color registerDaftarText;

  static AppUiColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  // MODE GELAP
  static const AppUiColors dark = AppUiColors(
    // 1. Halaman Beranda
    berandaCekHargaBg: Color(0xFFACEF34), // Tombol besar "Cek Harga"
    berandaCekHargaText: Color(0xFF0F140A), // Teks & ikon tombol besar
    berandaMenuCardBg: Color(0xFF1B202C), // 4 kartu menu fitur
    berandaRiwayatCardBg: Color(0xFF1B202C), // Kartu riwayat cek terbaru
    // 2. Halaman Detail Produk
    detailKonversiCardBg: Color(0xFF1B202C), // Kartu konversi mata uang
    detailVarianCardBg: Color(0xFF1B202C), // Kartu daftar varian
    detailCekHargaBg: Color(0xFFACEF34), // Tombol bawah "Cek Harga"
    detailCekHargaText: Color(0xFF0F140A), // Teks tombol bawah
    // 3. Halaman Cek Harga
    cekHargaSubmitBg: Color(0xFFACEF34), // Tombol "Cek Kelayakan"
    cekHargaSubmitText: Color(0xFF0F140A), // Teks tombol "Cek Kelayakan"
    // 4. Halaman Hasil Analisis
    hasilVerdictCardBg: Color(0xFF1B202C), // Kartu skor & verdict
    hasilRingkasanCardBg: Color(0xFF1B202C), // Kartu ringkasan harga
    hasilSimpanWishlistBg: Color(0xFFACEF34), // Tombol "Simpan ke Wishlist"
    hasilSimpanWishlistText: Color(0xFF0F140A),
    hasilTokoTerdekatBg: Colors.transparent, // Tombol "Lihat Toko Terdekat"
    hasilTokoTerdekatText: Color(0xFFF4F6FA),
    hasilSelesaiBg: Colors.transparent, // Tombol "Selesai"
    hasilSelesaiText: Color(0xFFF4F6FA),
    // 5. Halaman Wishlist & Toko Terdekat
    wishlistCardBg: Color(0xFF1B202C), // Kartu item wishlist
    tokoCardBg: Color(0xFF1B202C), // Kartu daftar toko
    // 6. Halaman Profil
    profilTemaCardBg: Color(0xFF1B202C), // Kartu ubah tema
    profilPengingatCardBg: Color(0xFF1B202C), // Kartu pengingat harian
    profilInfoCardBg: Color(0xFF1B202C), // Kartu info penyimpanan lokal
    profilUjiNotifBg: Colors.transparent, // Tombol "Uji Notifikasi Sekarang"
    profilUjiNotifText: Color(0xFFF4F6FA),
    profilKeluarBg: Colors.transparent, // Tombol "Keluar dari akun"
    profilKeluarText: Color(0xFFF4F6FA),
    // 7. Halaman Login & Register
    loginMasukBg: Color(0xFFACEF34), // Tombol "Masuk"
    loginMasukText: Color(0xFF0F140A),
    registerDaftarBg: Color(0xFFACEF34), // Tombol "Daftar dan Masuk"
    registerDaftarText: Color(0xFF0F140A),
  );

  // MODE TERANG
  static const AppUiColors light = AppUiColors(
    // 1. Halaman Beranda
    berandaCekHargaBg: Color(0xFFACEF34), // Tombol besar "Cek Harga"
    berandaCekHargaText: Color(0xFF0F172A), // Teks & ikon tombol besar
    berandaMenuCardBg: Color(0xFFFFFFFF), // 4 kartu menu fitur
    berandaRiwayatCardBg: Color(0xFFFFFFFF), // Kartu riwayat cek terbaru
    // 2. Halaman Detail Produk
    detailKonversiCardBg: Color(0xFFFFFFFF), // Kartu konversi mata uang
    detailVarianCardBg: Color(0xFFFFFFFF), // Kartu daftar varian
    detailCekHargaBg: Color(0xFFA3E635), // Tombol bawah "Cek Harga"
    detailCekHargaText: Color(0xFF0F172A), // Teks tombol bawah
    // 3. Halaman Cek Harga
    cekHargaSubmitBg: Color(0xFFA3E635), // Tombol "Cek Kelayakan"
    cekHargaSubmitText: Color(0xFF0F172A), // Teks tombol "Cek Kelayakan"
    // 4. Halaman Hasil Analisis
    hasilVerdictCardBg: Color(0xFFFFFFFF), // Kartu skor & verdict
    hasilRingkasanCardBg: Color(0xFFFFFFFF), // Kartu ringkasan harga
    hasilSimpanWishlistBg: Color(0xFFA3E635), // Tombol "Simpan ke Wishlist"
    hasilSimpanWishlistText: Color(0xFF0F172A),
    hasilTokoTerdekatBg: Color(0xFFFFFFFF), // Tombol "Lihat Toko Terdekat"
    hasilTokoTerdekatText: Color(0xFF0F172A),
    hasilSelesaiBg: Color(0xFFFFFFFF), // Tombol "Selesai"
    hasilSelesaiText: Color(0xFF0F172A),
    // 5. Halaman Wishlist & Toko Terdekat
    wishlistCardBg: Color(0xFFFFFFFF), // Kartu item wishlist
    tokoCardBg: Color(0xFFFFFFFF), // Kartu daftar toko
    // 6. Halaman Profil
    profilTemaCardBg: Color(0xFFFFFFFF), // Kartu ubah tema
    profilPengingatCardBg: Color(0xFFFFFFFF), // Kartu pengingat harian
    profilInfoCardBg: Color(0xFFFFFFFF), // Kartu info penyimpanan lokal
    profilUjiNotifBg: Color(0xFFFFFFFF), // Tombol "Uji Notifikasi Sekarang"
    profilUjiNotifText: Color(0xFF0F172A),
    profilKeluarBg: Color(0xFFFFFFFF), // Tombol "Keluar dari akun"
    profilKeluarText: Color(0xFF0F172A),
    // 7. Halaman Login & Register
    loginMasukBg: Color(0xFFA3E635), // Tombol "Masuk"
    loginMasukText: Color(0xFF0F172A),
    registerDaftarBg: Color(0xFFA3E635), // Tombol "Daftar dan Masuk"
    registerDaftarText: Color(0xFF0F172A),
  );
}
