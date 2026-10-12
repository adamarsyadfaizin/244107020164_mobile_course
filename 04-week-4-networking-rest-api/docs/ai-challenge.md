# Dokumentasi AI Challenge — Week 4

## Prompt yang digunakan

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error,
  404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

## Output awal AI

AI menghasilkan tiga bagian utama:

1. `Comment` dengan factory `fromJson`.
2. `CommentRepository.fetchComments(postId)` yang memanggil `/comments` melalui Dio.
3. `CommentsNotifier` dan `AsyncNotifierProvider.family` untuk mengekspos `AsyncValue<List<Comment>>`.

Pola awal provider:

```dart
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}
```

Exception dari repository tidak ditelan sehingga Riverpod dapat mengubahnya menjadi `AsyncError`.

## Verifikasi dan perbaikan

| Pemeriksaan | Temuan | Perbaikan |
| --- | --- | --- |
| Akses Dio | Repository sudah menjadi pintu akses data | Dipertahankan |
| Null safety | Cast langsung berisiko saat field hilang | Semua field memakai `as num?`, `as String?`, dan nilai default |
| Error mapping | Pesan awal masih umum | Menggunakan `friendlyErrorMessage` untuk timeout, connection error, 404, 401/403, dan response server termasuk 500 |
| Konfigurasi client | Timeout berpotensi tersebar | Base URL dan timeout utama dipusatkan di `api_client.dart`; request comments menegaskan batas 10 detik |
| Provider | Retry otomatis dapat membuat test menggantung | Retry otomatis provider dinonaktifkan agar error final dan test deterministik |
| Test | Hanya kasus field hilang | Ditambah edge case ID bertipe `double` yang tetap dipetakan menjadi `int` |

## Hasil testing

```text
flutter analyze
No issues found!

flutter test
00:01 +8: All tests passed!
```

Test provider menggunakan `FakePostRepository`; tidak ada request HTTP sungguhan selama unit test.
