# Week 5 — Local Storage & Offline-first

## Tujuan

Membangun aplikasi **Offline Notes** yang tetap dapat membaca dan menulis catatan tanpa internet, menyimpan preferensi pengguna, menampilkan cache bacaan, dan menyinkronkan perubahan lokal saat koneksi kembali tersedia.

## Fitur

- Tema gelap/terang dan waktu terakhir dibuka melalui SharedPreferences.
- CRUD catatan persisten melalui SQLite dan repository lokal.
- Catatan diurutkan berdasarkan `updated_at` terbaru.
- Dirty flag dan badge **Belum tersinkron**.
- Simulasi antrean sinkronisasi dengan delay, lalu `dirty = 0`.
- Toggle `forceOffline` untuk demo yang deterministik.
- Cache-first data bacaan dari JSONPlaceholder.
- Detail dan edit catatan melalui GoRouter `/note/:id`.
- `NoteTile` terpisah agar daftar mudah diuji.
- State loading, error, empty, dan success melalui Riverpod.

## Stack teknologi

- Flutter dan Dart
- flutter_riverpod
- shared_preferences
- sqflite dan path
- Dio
- go_router

## Arsitektur

```text
UI (ConsumerWidget)
        ↓ watch / read
Riverpod Provider (AsyncValue)
        ↓
PrefsRepository / NoteRepository / SyncService
        ↓
SharedPreferences / SQLite / REST API
```

Widget tidak mengakses SharedPreferences, SQLite, atau Dio secara langsung.

## Struktur

```text
lib/
├── main.dart
├── router.dart
├── data/
│   ├── prefs.dart
│   ├── providers.dart
│   ├── sync.dart
│   ├── local/
│   │   ├── cached_post.dart
│   │   ├── db.dart
│   │   └── note.dart
│   └── repositories/
│       └── note_repository.dart
├── pages/
│   ├── cached_posts_page.dart
│   ├── home_page.dart
│   ├── note_detail_page.dart
│   ├── notes_page.dart
│   └── settings_page.dart
└── widgets/
    └── note_tile.dart
```

## Cara menjalankan

Project Flutter lengkap tersedia lokal di `week5_offline_notes/`.

```bash
cd 05-week-5-local-storage-offline-first/week5_offline_notes
flutter pub get
flutter run
```

Gunakan emulator Android atau perangkat fisik. Project ini sengaja memakai `sqflite` sesuai tugas; Chrome tidak dipakai untuk runtime database karena dukungan web memerlukan adapter tambahan yang tidak diminta codelab.

## Testing

```bash
flutter analyze
flutter test
```

Hasil verifikasi:

- `flutter analyze`: **No issues found**.
- `flutter test`: **6 tests passed**.
- Test provider menggunakan `FakeNoteRepository` dan tidak membuka SQLite sungguhan.

## Screenshot simulasi sementara

Gambar berikut memakai data simulasi untuk memperlihatkan tampilan UI pada ukuran layar ponsel. Gambar ini **bukan** bukti bahwa SQLite, mode pesawat, cache jaringan, atau proses sinkronisasi telah berjalan pada perangkat Android.

1. [Daftar catatan dengan badge `3 dirty`](screenshots/01-offline-dirty.png) — simulasi keadaan sebelum sync.
2. [Daftar catatan dengan badge `0 dirty`](screenshots/02-after-sync.png) — simulasi keadaan setelah sync.
3. [Halaman bacaan saat `forceOffline` aktif](screenshots/03-cache-offline.png) — simulasi tampilan cache; isi pada gambar adalah data contoh, bukan hasil pengambilan API dan penyimpanan SQLite yang diverifikasi.

## Rencana uji pada perangkat Android

1. Tambahkan catatan saat `forceOffline` aktif.
2. Catatan langsung tampil dari SQLite dan memperoleh badge **Belum tersinkron**.
3. Badge jumlah dirty tetap akurat walaupun jaringan tidak tersedia.
4. Nonaktifkan `forceOffline`, lalu tekan tombol sync.
5. Setelah simulasi upload berhasil, repository menjalankan `markAllSynced()` dan badge kembali ke 0.

Pengujian UI di perangkat untuk langkah-langkah ini **belum dilakukan**. Saat pemeriksaan terakhir tidak ada perangkat Android atau emulator yang terdeteksi. Ketiga screenshot simulasi di atas hanya menunjukkan rancangan tampilan; bukti fitur pada perangkat masih perlu diambil.

Saat perangkat tersedia, ambil bukti berikut secara berurutan di `screenshots/`:

1. Halaman Settings: tema terang/gelap dan waktu terakhir dibuka.
2. Catatan setelah tambah, edit melalui `/note/:id`, dan hapus.
3. Aktifkan `forceOffline` serta mode pesawat; ambil daftar catatan dengan badge dirty dan halaman cache yang tetap terbaca.
4. Matikan mode pesawat dan `forceOffline`; jalankan sync dan ambil badge dirty setelah kembali 0.

## Aturan konflik

Aturan konflik yang dipilih adalah **last-write-wins** berdasarkan `updated_at`: perubahan terbaru dianggap berlaku. Backend tulis dan sinkronisasi dua arah belum ada pada codelab ini, sehingga aturan tersebut baru didokumentasikan, belum dapat diuji sebagai resolusi konflik antarperangkat. Untuk sistem produksi, waktu server atau nomor versi lebih aman daripada hanya mengandalkan jam perangkat.

## AI Verification Checklist

- Daftar catatan tidak disimpan di SharedPreferences.
- Skema catatan memuat `dirty` dan `updated_at` untuk antrean sync dan resolusi konflik.
- Klaim reaktif Drift didasarkan pada query `watch()`/stream; sqflite membutuhkan invalidasi provider manual.
- Perbandingan mempertimbangkan tambahan boilerplate code generation dan migrasi Drift.
- Keputusan final: SharedPreferences untuk preferensi dan SQLite melalui sqflite untuk catatan.

Prompt, output awal, tabel perbandingan, dan keputusan teknis tersedia di [`docs/ai-challenge.md`](docs/ai-challenge.md).

## Refleksi

### Mengapa catatan tidak disimpan di SharedPreferences?

SharedPreferences dirancang untuk nilai konfigurasi kecil, bukan koleksi terstruktur. Menyimpan seluruh daftar sebagai satu JSON membuat pencarian, pengurutan, update sebagian, migrasi, dan pemulihan data rapuh serta menulis ulang seluruh koleksi setiap kali satu catatan berubah.

### Kapan cache-first cukup?

Cache-first cocok untuk data bacaan yang masih berguna walaupun sedikit lama, seperti artikel. Data harga atau stok real-time lebih tepat memakai network-first dengan batas usia cache karena data lama dapat menyebabkan keputusan yang salah.

### Bagaimana dirty flag menjadi antrean sync?

Setiap create atau update menetapkan `dirty = 1`. Proses sync menghitung dan mengirim data dirty tanpa memblokir UI, kemudian menandainya bersih setelah sukses. Tabel outbox terpisah diperlukan saat operasi harus mempertahankan urutan, mencatat retry, atau membedakan create/update/delete.

### Rekomendasi AI yang ditolak

Hive tidak dipilih untuk catatan karena kebutuhan pengurutan, query dirty, dan perkembangan relasi lebih alami di SQLite. Drift juga belum dipilih karena code generation dan boilerplate migrasinya belum sebanding dengan kompleksitas project codelab ini.
