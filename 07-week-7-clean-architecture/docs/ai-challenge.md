# Week 7 — AI Challenge

## Prompt yang digunakan

```text
Audit aplikasi Offline Notes Week 5 yang sudah ada. Usulkan refactor
Clean Architecture feature-first untuk notes, bacaan cache, dan pengaturan
tanpa menambah fitur. Bedakan entity vs model, interface repository vs
implementasi, use case, dan wiring Riverpod. Bandingkan use case untuk
setiap CRUD dengan use case hanya pada operasi yang punya aturan bisnis.
Tunjukkan arah dependensi, risiko perilaku berubah, serta cara menguji
GetNotes sukses dan gagal dengan repository palsu tanpa SQLite/jaringan.
```

## Output awal AI

Usulan awal memisahkan `features/notes`, `features/posts`, dan `features/settings` masing-masing ke `domain/data/presentation`; memindahkan `Note.toMap/fromMap` menjadi `NoteModel`; membuat kontrak repository di domain; dan menambah use case untuk setiap operasi CRUD. Usulan itu juga menempatkan state `forceOffline` pada provider bersama di `core/`.

## Verifikasi dan keputusan final

| Usulan awal | Keputusan final | Alasan |
| --- | --- | --- |
| Satu use case untuk tiap CRUD | `GetNotes`, `AddNote`, dan `SyncNotes` dibuat; update/delete satu langkah melalui repository. | Validasi judul dan sync memiliki aturan bisnis. Wrapper satu-baris untuk semua operasi menambah boilerplate tanpa mengubah perilaku. |
| State `forceOffline` di `core/` | Ditempatkan di `lib/app_providers.dart`. | Pemeriksaan domain dan core harus bebas dari import Flutter; Riverpod adalah bagian komposisi aplikasi. |
| Model dan entity boleh sama karena field identik | Dipisah menjadi `Note`/`NoteModel` dan `CachedPost`/`CachedPostModel`. | Mapping SQLite/JSON hanya di data; domain tetap murni Dart. |
| Repository konkret langsung dipakai notifier | Notifier menerima interface domain lewat provider. | Fake repository dapat menggantikan SQLite/Dio saat test. |
| Cache dan sync tetap di satu service | Cache dipindah ke fitur posts; sync notes menjadi use case domain. | Kedua operasi punya alasan berubah yang berbeda. |
| Semua exception bisa dilempar ke widget | Implementasi data mengubah kegagalan menjadi `Failure` dengan pesan; presentation menampilkan `message`. | Detail exception platform tidak bocor ke UI. |

## Hasil pengujian

- `GetNotes` sukses dan `LocalFailure` diuji dengan `FakeNoteRepository`; `AddNote` menolak judul kosong sebelum memanggil repository.
- Model SQLite dan payload cache diuji terpisah. Provider notes diuji dengan fake untuk kondisi sukses dan failure.
- Pemeriksaan import presentation dan domain dalam README masing-masing menghasilkan 0 temuan.
- `flutter analyze --no-pub` bersih; `flutter test --no-pub` lulus. Opsi `--no-pub` dipakai karena Windows Developer Mode belum mengizinkan pembuatan symlink plugin saat `flutter pub get`.
- Gambar before/after adalah hasil widget test dengan data palsu pada 390 × 844, bukan bukti SQLite/jaringan pada perangkat.
