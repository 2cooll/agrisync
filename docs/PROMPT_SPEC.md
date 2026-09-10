# Architectural Prompt Specification (SCI Pattern)
**Proyek**: AgriSync  
**Standar**: SCI (Structured, Clear, Impactful) Vibe Coding Guide  
**Lingkungan**: AI-Assisted IDE (Google Antigravity / Cursor / Copilot)

---

## 1. Structured Layer Architecture (SCI Structure)

Setiap implementasi kode pada AgriSync harus mematuhi pembagian layer *Clean Architecture* tanpa pencampuran dependensi:

```plaintext
lib/
├── core/             --> Aturan global, tema, konstanta, network handler & generic widgets
├── data/             --> Models (JSON serialization), Repositories (Contracts), Services (APIs/Storage)
├── state/            --> Business logic state management (Provider/ChangeNotifier)
└── ui/               --> Presentational Screens & Reusable Components (Stateless/Stateful)
```

---

## 2. SCI Prompting Template Rules

Saat meminta AI IDE mengenerate kode fitur baru, gunakan struktur template prompt berikut:

### 🧩 Template Prompt Standar SCI:

```markdown
### [CONTEXT & ROLE]
Bertindaklah sebagai Senior Flutter Mobile Software Engineer dengan spesialisasi Clean Architecture dan Offline-First mobile systems.

### [GOAL & TASK]
Implementasikan fitur: [Nama Fitur] untuk aktor [Petani/Pebisnis/Admin].

### [STRUCTURAL CONSTRAINTS]
1. Letakkan model data di `lib/data/models/[nama_fitur]_model.dart` dengan method `fromJson`, `toJson`, dan `copyWith`.
2. Letakkan abstraksi service di `lib/data/services/` dan repository di `lib/data/repositories/`.
3. Gunakan `AppState` di `lib/state/app_state.dart` untuk state management reaktif.
4. UI harus responsif (bebas layout overflow), menggunakan palet tema `AgriTheme` dan Material 3 design tokens.

### [IMPACT & VERIFICATION]
- Kode harus dilengkapi unit test di folder `test/` untuk memverifikasi kondisi: initial, loading, success, dan error.
- Tidak boleh ada hardcoded string atau raw colors; gunakan `AppColors` dan `intl` formatting.
```

---

## 3. Aturan State Lifecycle & Error Handling (Clear Guidance)

Setiap aksi asinkron (API/Database) wajib memiliki 4 status deterministik:
1. **Initial**: State default sebelum ada aksi pengguna.
2. **Loading**: Menampilkan Shimmer atau CircularProgressIndicator tanpa memblokir seluruh UI secara freeze.
3. **Success**: Memperbarui view state dan memicu snackbar/dialog keberhasilan jika relevan.
4. **Error/Failure**: Menampilkan pesan kesalahan ramah pengguna dan menyediakan tombol **Retry**.

---

## 4. Aturan Offline-First & Security (Impactful Rules)

1. **Offline Persistence**: Operasi tulis saat offline wajib disimpan ke dalam `LocalStorageService` / `offline_pending_queue` dan ditandai `isSynced = false`.
2. **Secrets Hygiene**: Dilarang meletakkan token API, secret key payment, atau URL backend secara hardcoded di file Dart. Gunakan `.env` compile-time injection.
3. **Immutability**: Gunakan properti `final` dan constructor `const` pada widget untuk performa render 60/120 FPS.
