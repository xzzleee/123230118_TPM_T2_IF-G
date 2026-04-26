# Smart Expense Tracker & Currency Converter
## Tugas 2 - Prak TPM IF-G

### 📱 Deskripsi
Aplikasi Flutter untuk mencatat pemasukan dan pengeluaran keuangan pribadi dengan fitur konversi mata uang real-time menggunakan Frankfurter API.

---

### ✅ Komponen yang Diimplementasikan

#### 1. Navigation (3 Halaman)
| Halaman | Keterangan |
|---|---|
| **Dashboard** | Total saldo, ringkasan pemasukan/pengeluaran, daftar transaksi terbaru |
| **Tambah Transaksi** | Form input nominal, kategori, tanggal, jenis transaksi, catatan |
| **Konversi Kurs** | Input IDR, pilih mata uang, hasil konversi real-time + tabel kurs |
| **Riwayat** | Akses dari icon History di Dashboard, detail transaksi via bottom sheet |

#### 2. State & Data Management
- Menggunakan **Provider** untuk state management global
- Saldo di Dashboard otomatis update ketika transaksi baru ditambahkan
- Validasi input: nominal tidak boleh kosong atau ≤ 0

#### 3. HTTP Request (Currency Converter)
- API: `https://api.frankfurter.app/latest?from=IDR`
- Mata uang didukung: **USD, EUR, JPY, GBP, SGD, MYR, AUD**
- Menampilkan tabel kurs lengkap dari IDR

#### 4. Local Storage (Persistence)
- Menggunakan **SharedPreferences** untuk persistensi data
- Data transaksi tetap tersimpan meski aplikasi ditutup/smartphone dimatikan

---

### 🗂️ Struktur Folder
```
lib/
├── main.dart
├── models/
│   └── transaction.dart        # Model data transaksi
├── providers/
│   └── transaction_provider.dart  # State management & local storage
├── services/
│   └── currency_service.dart   # HTTP request Frankfurter API
└── screens/
    ├── dashboard_screen.dart    # Halaman utama + BottomNavigationBar
    ├── add_transaction_screen.dart  # Form tambah transaksi
    ├── history_screen.dart      # Riwayat & detail transaksi
    └── currency_screen.dart     # Konversi mata uang
```

---

### 🚀 Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### 📦 Dependencies
```yaml
provider: ^6.1.2        # State management
shared_preferences: ^2.2.3  # Local storage
http: ^1.2.1            # HTTP requests
intl: ^0.19.0           # Formatting angka & tanggal
```

---

### 👤 Pengumpulan
- Nama repo: `[NIM]_TPM-T2-IFG`
- Upload ke GitHub
- Sertakan folder `Screenshoot` berisi tangkapan layar aplikasi
