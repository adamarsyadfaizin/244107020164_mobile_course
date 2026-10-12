# Week 7 — Clean Architecture

Project ini merefactor aplikasi **Offline Notes Week 5** yang sudah ada. Sumber Week 5 tetap tersimpan di `05-week-5-local-storage-offline-first/week5_offline_notes/`; salinan yang direfactor dan bisa dijalankan ada di `week5_offline_notes/` dalam folder ini. Fitur pengguna tetap: catatan lokal, bacaan cache-first, tema, dan toggle `forceOffline`.

## Tujuan dan stack

Tujuannya memisahkan logika bisnis dari Flutter, SQLite, Dio, dan SharedPreferences agar use case dapat diuji tanpa database atau internet. Stack tetap Flutter, Riverpod, GoRouter, sqflite, Dio, dan SharedPreferences. Tidak ada fitur baru.

## Arah dependensi

```text
presentation (halaman + provider Riverpod) ───> domain (entity, kontrak, use case)
             │                                      ▲
             └── wiring DI ──> data (implementasi) ┘
                                  │
                       SQLite / Dio / SharedPreferences
```

Domain tidak mengimpor paket platform. Model yang memiliki `fromMap`/`toMap` atau JSON hidup di data; entity bisnis hanya menyimpan field. UI membaca provider; provider menyuntikkan repository melalui interface domain.

Struktur utama:

```text
lib/
├── core/                         # Failure dan fungsi murni format/rute
├── data/local/db.dart            # pembuka SQLite bersama
├── features/
│   ├── notes/
│   │   ├── domain/               # Note, NoteRepository, GetNotes, AddNote, SyncNotes
│   │   ├── data/                 # NoteModel, NoteRepositoryImpl
│   │   └── presentation/         # provider, NotesPage, NoteDetailPage, NoteTile
│   ├── posts/
│   │   ├── domain/               # CachedPost, PostRepository, GetCachedPosts
│   │   ├── data/                 # CachedPostModel, PostRepositoryImpl
│   │   └── presentation/         # provider dan halaman cache
│   └── settings/
│       ├── domain/               # PrefsRepository, GetTheme
│       ├── data/                 # PrefsRepositoryImpl
│       └── presentation/         # provider dan halaman pengaturan
├── app_providers.dart            # state forceOffline lintas fitur
├── main.dart
└── router.dart
```

## Audit sebelum refactor

| File Week 5 | Posisi awal | Temuan dan hasil refactor |
| --- | --- | --- |
| `data/local/note.dart` | data | Entity bercampur `toMap/fromMap`; dipisah menjadi entity domain dan `NoteModel` di data. |
| `data/repositories/note_repository.dart` | data | Kontrak dan SQL berada dalam satu kelas; dipisah menjadi interface domain dan implementasi data. |
| `data/providers.dart` | data | State UI, DI, cache, dan sync tergabung; dipindah ke provider per fitur dan use case domain. |
| `data/sync.dart` | data | Cache bacaan dan aturan sync catatan tercampur; cache masuk fitur posts, sync catatan masuk use case notes. |
| `data/prefs.dart` | data | Akses SharedPreferences langsung di kelas konkret; kini ada kontrak domain dan implementasi data. |
| `pages/*.dart` | presentation | Tidak ada pemanggilan Dio/SQLite langsung. Import provider lama diganti dengan provider per fitur. |

## Pemeriksaan dependency rule

Dijalankan di `week5_offline_notes/` setelah refactor:

```powershell
rg -n 'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode' lib/features/notes/presentation lib/features/posts/presentation lib/features/settings/presentation lib/pages
rg -n "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/notes/domain lib/features/posts/domain lib/features/settings/domain lib/core
```

Kedua pemeriksaan menghasilkan **0 temuan**. Pembuka database bersama tetap di `lib/data/local/db.dart`, di luar domain dan presentation.

## Bukti tampilan before/after

Gambar berikut dibuat dari widget test pada layar **390 × 844** dengan repository dan preferensi palsu. Pasangan before/after memakai data yang sama; ketiganya cocok **piksel demi piksel**. Ini membuktikan tampilan statis pada kondisi simulasi, belum membuktikan SQLite atau jaringan di perangkat.

| Fitur | Sebelum | Sesudah |
| --- | --- | --- |
| Catatan | [before](screenshots/before-notes-simulated.png) | [after](screenshots/after-notes-simulated.png) |
| Bacaan cache | [before](screenshots/before-posts-simulated.png) | [after](screenshots/after-posts-simulated.png) |
| Pengaturan | [before](screenshots/before-settings-simulated.png) | [after](screenshots/after-settings-simulated.png) |

Uji manual CRUD, persistensi SQLite, dan mode pesawat pada Android masih perlu dilakukan saat perangkat tersedia. Folder Week 5 tetap dapat digunakan untuk membandingkan kode sebelum refactor.

## Cara menjalankan dan hasil

```powershell
cd 07-week-7-clean-architecture/week5_offline_notes
flutter pub get
flutter run
flutter analyze
flutter test
```

Pada mesin ini `flutter pub get` mengunduh dependency tetapi berhenti di tahap pembuatan symlink plugin Windows karena Developer Mode belum aktif. Dengan dependency yang telah terpasang, `flutter analyze --no-pub` menghasilkan **No issues found** dan `flutter test --no-pub` meluluskan **14 test**. Test domain memakai repository palsu tanpa SQLite, Dio, atau Firebase.

`flutter build apk --debug --no-pub` berhasil. APK ada di `week5_offline_notes/build/app/outputs/flutter-apk/app-debug.apk`. `flutter devices` saat verifikasi hanya menemukan Windows, Chrome, dan Edge; belum ada Android untuk uji manual.

## AI Challenge

Prompt, usulan awal, keputusan final, dan alasannya dicatat di [`docs/ai-challenge.md`](docs/ai-challenge.md).

## Refleksi

- Interface repository berada di domain agar use case bergantung pada kebutuhan bisnis. Bila interface berada di data, domain harus mengimpor data dan tidak bisa diuji tanpa lapisan luar.
- Use case dipakai untuk pembacaan catatan, validasi judul, sync, dan cache-first karena ada aturan atau alur bisnis. Operasi update/delete satu langkah tetap dipanggil melalui repository dari notifier.
- Use case untuk setiap CRUD satu-baris akan menambah file dan wiring tanpa manfaat yang sebanding bagi project kecil; pola itu menjadi sepadan bila aturan bisnis, otorisasi, atau beberapa sumber data tumbuh.
- Usulan AI untuk membungkus setiap operasi satu-baris dalam use case tidak dipakai. Pemisahan entity/model dan kontrak/implementasi tetap dipertahankan karena itulah batas dependensi yang perlu diuji.
