# Dokumentasi AI Challenge — Week 5

## Prompt yang digunakan

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## Output awal AI

AI merekomendasikan SharedPreferences untuk preferensi sederhana dan Drift untuk catatan karena query type-safe serta stream reaktif. Hive disebut sebagai pilihan ringan untuk model tanpa relasi, sedangkan sqflite direkomendasikan ketika kontrol SQL dan kompatibilitas luas lebih penting daripada reaktivitas otomatis.

Rekomendasi awal tidak langsung diterima. Untuk project codelab ini, manfaat Drift belum sebanding dengan tambahan generator kode dan migrasi, sehingga keputusan akhir menggunakan sqflite.

## Tabel perbandingan final

| Pilihan | Kompleksitas query | Relasi | Reaktivitas | Type-safety | Boilerplate | Testing | Keputusan |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SharedPreferences | Hanya key-value | Tidak ada | Tidak menyediakan stream database | Tipe dasar melalui getter khusus | Sangat kecil | Mudah dengan mock initial values | Dipilih untuk tema dan waktu terakhir dibuka |
| Hive | Query/filter koleksi di Dart; sederhana | Relasi harus dikelola manual | `box.watch()` tersedia | TypeAdapter membantu, tetapi perubahan model perlu dikelola | Kecil–sedang | Box dapat dibuka pada direktori test | Ditolak untuk catatan karena query dirty dan pengurutan lebih cocok SQL |
| sqflite | SQL lengkap: filter, sort, agregasi, transaksi | Mendukung tabel dan foreign key | Tidak reaktif otomatis; provider harus di-invalidasi | Mapping `Map<String, Object?>` manual | Sedang | Repository menerima pembuka DB sehingga mudah dipalsukan | **Dipilih untuk catatan** |
| Drift | Query relasional kompleks | Sangat baik | Query `watch()` menghasilkan stream | Compile-time type-safe | Besar; perlu code generation dan migrasi | Sangat baik dengan database in-memory | Cocok untuk versi aplikasi yang lebih besar, belum diperlukan sekarang |

## Skema untuk 1000+ catatan

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);

CREATE TABLE cached_posts(
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

Indeks `updated_at` mempercepat daftar terbaru dan indeks `dirty` mempercepat antrean sinkronisasi ketika jumlah catatan bertambah.

## Verifikasi rekomendasi

- Menolak penyimpanan daftar catatan di SharedPreferences karena koleksi harus diserialisasi ulang seluruhnya.
- Menambahkan `dirty` dan `updated_at`; output awal hanya berfokus pada CRUD.
- Memastikan klaim real-time Drift merujuk pada stream dari query `watch()`.
- Mempertimbangkan instalasi Drift yang membutuhkan dependency runtime, generator, `build_runner`, generated file, dan strategi migrasi.
- Memilih SharedPreferences + sqflite karena paling proporsional untuk ruang lingkup Week 5.

## Hasil testing

```text
flutter analyze
No issues found!

flutter test
00:01 +6: All tests passed!
```

Test provider memakai repository palsu sehingga tidak mengakses SQLite sungguhan.
