# 🌾 AgriSync — Digital Agriculture Supply Chain & Direct Trading Platform

[![Flutter Version](https://img.shields.io/badge/Flutter-3.5%2B-02569B?logo=flutter)](https://flutter.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Code%20%26%20Provider-success)](https://flutter.dev)
[![SDG 12](https://img.shields.io/badge/SDG%2012-Responsible%20Consumption-orange)](https://sdgs.un.org/goals/goal12)
[![SDG 8](https://img.shields.io/badge/SDG%208-Decent%20Work%20%26%20Economic%20Growth-red)](https://sdgs.un.org/goals/goal8)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**AgriSync** adalah platform inovasi mobile terintegrasi (*Project-Based Learning - Rekayasa Perangkat Lunak Mobile*) yang dirancang untuk merevolusi rantai pasok pertanian hulu-ke-hilir melalui pemotongan rantai tengkulak non-transparan, penekanan angka *food loss* pasca-panen, serta pemberdayaan ekonomi petani lokal.

---

## 🌟 Fitur Utama & Keunggulan (Novelty)

1. **Multi-Role Seamless Experience**: Antarmuka terdedikasi untuk 3 persona:
   * **Petani**: Manajemen stok panen, penentuan grade mutu (A/B/C), analitik penjualan, dan penarikan saldo.
   * **Pebisnis / F&B**: Pencarian komoditas hasil tani terverifikasi, sistem filter grade/wilayah, dan pemesanan batch besar.
   * **Admin & Quality Verifier**: Verifikasi identitas petani, audit mutu panen, dan pengawasan transaksi.
2. **Offline-First Resilience**: Dukungan pendataan produk panen dan transaksi secara lokal saat berada di daerah blank-spot/minim sinyal, dengan auto-sync instan saat online.
3. **Escrow & Sandboxed Payment Gateway**: Pembayaran aman melalui QRIS, Virtual Account, dan E-Wallet dengan perhitungan komisi otomatis 2.5%.
4. **Monetisasi Realistis (AgriSync PRO)**: Model langganan bulanan/tahunan untuk analitik prediksi harga pasar harian dan prioritas katalog.

---

## 🏗️ Arsitektur Proyek (Clean Architecture)

```plaintext
lib/
├── core/             # Konstanta, tema warna Material 3, utilitas & generic reusable widgets
├── data/             # Layer Data: Models (JSON), Repositories, Services (Storage & Payment)
├── state/            # State Management terpusat (AppState via Provider)
└── ui/               # Presentation Layer: Screens per Role (Petani, Pebisnis, Admin) & Components
```

---

## 🚀 Panduan Menjalankan Proyek (Getting Started)

### Prasyarat:
* Flutter SDK $\ge$ 3.5.0
* Dart SDK $\ge$ 3.5.0
* Android Studio / VS Code dengan plugin Flutter & Dart

### Langkah Instalasi:
1. **Clone Repositori**:
   ```bash
   git clone https://github.com/kelompok-agrisync/agrisync.git
   cd agrisync
   ```
2. **Instal Dependensi**:
   ```bash
   flutter pub get
   ```
3. **Setup Konfigurasi Environment**:
   ```bash
   cp .env.example .env
   ```
4. **Jalankan Pengujian Unit & Widget**:
   ```bash
   flutter test
   ```
5. **Jalankan Aplikasi di Emulator/Device**:
   ```bash
   flutter run
   ```

---

## 📑 Dokumentasi & Spesifikasi Lengkap
* [Dokumen PRD & Model Monetisasi](docs/PRD_AND_MONETIZATION.md)
* [Architectural Prompt Specification (SCI Pattern)](docs/PROMPT_SPEC.md)
* [Data Safety & Privacy Policy](docs/DATA_SAFETY_AND_PRIVACY.md)

---

## 👥 Kontribusi Kelompok (Peer Role Distribution)
* **Anggota A**: Lead State Management, Clean Architecture, Offline Storage Engine, & Unit Tests.
* **Anggota B**: UI/UX Design System Material 3, Component Architecture, & Paywall Flow.
* **Anggota C**: Payment Gateway Sandbox Integration, CI/CD GitHub Actions, Security & Release.
