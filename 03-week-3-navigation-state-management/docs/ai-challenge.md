# Dokumentasi AI Challenge

## Prompt yang digunakan

> Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod. Requirements: ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan pengambilan data statistik (delay 2 detik, kadang gagal 30%). UI harus menangani loading (spinner), error (pesan + tombol retry), dan success (ListView 3 item). Berikan unit test untuk notifier-nya. Jelaskan setiap bagian kode dalam komentar.

## Output awal AI

AI menghasilkan `StatsPage`, `StatsNotifier`, dan `statsProvider`. Implementasi awal sudah memakai `ConsumerWidget`, `AsyncNotifierProvider`, `AsyncValue.when`, delay dua detik, peluang gagal 30%, serta tiga item statistik.

## Verifikasi dan perbaikan

- State tidak dimutasi langsung; hasil baru selalu diberikan melalui `state = ...`.
- `ref.watch` hanya berada di `build`, sedangkan callback memakai `ref.read`.
- Loading, error, dan success ditangani secara eksplisit.
- Provider memiliki tipe eksplisit `AsyncNotifierProvider<StatsNotifier, List<String>>`.
- Tidak memakai `StateNotifierProvider`, `StateProvider`, atau `Consumer` bertingkat.
- Dependency `randomValue` dan `delay` dibuat dapat diinjeksi agar unit test tidak acak dan tidak perlu menunggu dua detik.
- Tombol retry memakai `AsyncValue.guard`.

## Keputusan teknis

Unit test memakai override provider dengan nilai random deterministik: `0.9` untuk sukses dan `0.1` untuk error. Pendekatan ini menguji kedua cabang tanpa flaky test.

## Hasil pengujian

`flutter analyze` dan `flutter test` dijalankan pada project lokal `week3_todo`. Hasil aktual dicatat di README utama setelah verifikasi.
