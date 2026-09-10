# Product Requirements Document (PRD) & Strategi Monetisasi
**Proyek**: AgriSync (Digital Agriculture Supply Chain & Direct Trading Platform)  
**Versi**: 1.0  
**Tema Utama**: Sustainable Development Goals (SDGs) — *High Impact, Applicable, High Novelty, and Clear Monetization Strategy*

---

## 1. Problem Statement & Latar Belakang (SDG Alignment)

### 1.1 Fokus Target SDGs
1. **SDG 12: Konsumsi dan Produksi yang Bertanggung Jawab (Target 12.3)**
   * Mengurangi *food loss* dan susut hasil panen pasca-panen melalui kepastian serapan pasar langsung dari petani ke pelaku usaha (B2B).
2. **SDG 8: Pekerjaan Layak dan Pertumbuhan Ekonomi (Target 8.2 & 8.3)**
   * Meningkatkan produktivitas ekonomi petani lokal dengan memotong rantai tengkulak non-transparan dan membuka akses pasar yang adil.

### 1.2 Masalah Nyata
* **Rantai Pasok Terlalu Panjang**: Komoditas hasil tani melewati 4–6 perantara sebelum sampai ke konsumen akhir, menekan harga jual petani hingga 40-60% di bawah harga pasar.
* **Tingginya Susut Panen (*Food Loss*)**: Ketiadaan estimasi serapan panen dan keterlambatan distribusi menyebabkan hasil tani segar membusuk sebelum terjual.
* **Keterbatasan Sinyal di Daerah Sentra Pertanian**: Petani di pedesaan seringkali terkendala jaringan internet saat ingin mendata komoditas panen.

---

## 2. Solution Novelty & Nilai Kebaharuan

AgriSync hadir sebagai solusi terintegrasi:
1. **Direct Multi-Role Trading Engine**: Platform menghubungkan secara langsung **Petani**, **Pebisnis/F&B**, dan **Admin Verifikator Mutu**.
2. **Quality Grading & Verification Matrix**: Sistem penentuan mutu panen (Grade A/B/C) yang diverifikasi oleh Admin/Auditor untuk transparansi kualitas dan harga.
3. **Offline-First Data Sync**: Petani dapat mendata produk panen dan pesanan tanpa koneksi internet; sistem akan melakukan sinkronisasi otomatis (*auto-sync*) saat jaringan kembali aktif.
4. **Escrow & Sandboxed Payment Gateway**: Pembayaran terintegrasi yang menjamin dana aman hingga komoditas diterima dan diverifikasi sesuai standar oleh pembeli.

---

## 3. User Persona

| Persona | Role | Kebutuhan Utama | Pain Point |
| :--- | :--- | :--- | :--- |
| **Pak Joko (45 thn)** | Petani Cabai & Sayur Organik | Menjual hasil panen dengan harga wajar, pendataan panen mudah saat di ladang | Sinyal tidak stabil, harga sering dipermainkan tengkulak |
| **Bu Sarah (34 thn)** | Pemilik Jaringan Restoran (Pebisnis) | Pasokan bahan baku segar langsung dari sumber pertama dengan mutu Grade A | Kualitas tidak konsisten, fluktuasi harga tiba-tiba |
| **Budi Santoso (29 thn)** | Quality Assurance & Admin AgriSync | Memvalidasi kualitas panen, memverifikasi akun petani, mengawasi transaksi | Validasi manual memakan waktu tanpa standarisasi |

---

## 4. Model Bisnis & Strategi Monetisasi (Monetization Strategy)

AgriSync menerapkan model pendapatan hibrida (*Hybrid Revenue Model*) yang realistis dan berkelanjutan:

```
                               ┌────────────────────────┐
                               │  AGRISYNC REVENUE FLOW │
                               └───────────┬────────────┘
                                           │
                ┌──────────────────────────┴──────────────────────────┐
                ▼                                                     ▼
     ┌────────────────────────┐                            ┌────────────────────────┐
     │  Marketplace Fee (B2B) │                            │  AgriSync PRO (SaaS)   │
     │  2.5% Komisi Transaksi │                            │  Langganan Bulanan/Thn │
     └────────────────────────┘                            └────────────────────────┘
```

### 4.1 Marketplace Transaction Fee (2.5%)
* Setiap pesanan berhasil yang ditransaksikan antara Pebisnis dan Petani dikenakan biaya platform sebesar **2.5%** dari subtotal komoditas.
* Memberikan kepastian garansi pengembalian dana (*refund guarantee*) dan audit mutu komoditas bagi pembeli.

### 4.2 Subscription Model (AgriSync PRO)
Model langganan untuk Petani & Pebisnis yang membutuhkan fitur komputasi tingkat lanjut:
* **Paket Petani Pro (Rp 49.000 / bulan)**:
  * Fitur *Market Price Forecast* (Prediksi harga pasar komoditas 14 hari ke depan).
  * Prioritas listing panen di halaman utama pebisnis (*Top Search Placement*).
  * Pengurangan komisi transaksi menjadi hanya **1.0%**.
  * Badge *Verified Premium Farmer* dengan sertifikasi mutu.
* **Paket Pebisnis Pro (Rp 149.000 / bulan)**:
  * Akses kontrak pasokan terjadwal (*Scheduled Procurement Contract*).
  * Laporan analitik susut bahan baku & *Supply Chain Carbon Footprint Tracker*.
  * Dukungan *Dedicated Account Manager*.

---

## 5. User Journey & Core Flow

1. **Onboarding & Multi-Role Authentication**: Pengguna memilih peran (Petani / Pebisnis) dan melengkapi verifikasi identitas.
2. **Katalog & Input Panen (Offline/Online)**: Petani mengunggah foto, estimasi panen, grade mutu, dan kuantitas.
3. **Pemesanan & Payment Gateway Sandbox**: Pebisnis memilih komoditas, memilih metode pembayaran (QRIS, VA Bank, E-Wallet), dan menyelesaikan transaksi.
4. **Fulfillment & Smart Tracking**: Pelacakan status pengiriman dari lahan tani hingga dapur restoran.
5. **Konfirmasi & Pencairan Dana**: Dana diteruskan ke saldo petani setelah verifikasi penerimaan barang selesai.
