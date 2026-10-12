# Week 6 — AI Challenge dan verifikasi FCM

## Prompt yang digunakan

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## Output awal AI yang diaudit

Draf awal `push_service.dart` sebelum revisi ini hanya memuat izin, inisialisasi local notification, token awal, listener refresh, dan subscribe topik. Bagian inti draf tersebut:

```dart
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  await _tokenRefreshSubscription?.cancel();
  _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
    onToken,
  );
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}
```

Draf itu belum memiliki background handler, `onMessage`, `onMessageOpenedApp`, `getInitialMessage`, unsubscribe, atau pengujian klik. Upload token berada di halaman Debug sehingga listener baru hidup setelah halaman itu dibuka dan callback menahan state widget. Ini tidak cukup untuk menerima pesan sepanjang lifecycle aplikasi.

## Perbaikan dan alasan

| Temuan | Perbaikan |
| --- | --- |
| Handler background tidak ada | Fungsi top-level ber-`@pragma('vm:entry-point')` didaftarkan sebelum `runApp`; tidak mengakses `BuildContext` atau Riverpod. |
| Foreground tidak menampilkan banner | `onMessage` memanggil local notification dengan payload route. |
| Klik background/terminated belum ditangani | `onMessageOpenedApp` dan `getInitialMessage` meneruskan `data.route` ke GoRouter. Launch dari local notification juga dibaca. |
| Token refresh hanya aktif setelah halaman Debug dibuka | Inisialisasi token dan listener dipindah ke startup. Halaman Debug hanya membaca 12 karakter awal token. |
| Route berbentuk string tersebar | Path dipusatkan di `routes.dart`; `routeFromMessage` diuji tanpa Firebase. |
| Sesi tidak berubah saat refresh 401 gagal | Interceptor membersihkan secure storage dan mengubah status auth; tujuan notifikasi menunggu login. |
| Belum ada unsubscribe | `unsubscribeFromCampusTopic()` disediakan untuk berhenti berlangganan. |

Android 13+ memerlukan izin notifikasi runtime. Di iOS, izin runtime juga diperlukan, serta konfigurasi APNs dan capability Push Notifications di Xcode sebelum pengiriman FCM dapat diuji. Background handler tidak boleh melakukan navigasi karena berjalan di isolate terpisah. Pesan personal harus dikirim ke token perangkat; topik hanya untuk broadcast.

## Hasil verifikasi

- `flutter analyze`: tidak ada issue.
- `flutter test`: 11 test lulus, termasuk parsing route, pesan error, retry 401 sekali, pembersihan sesi saat refresh gagal, dan route pengumuman yang dipulihkan setelah login. Test tidak memanggil Firebase atau backend sungguhan.
- Token awal dan token setelah clear data sudah didokumentasikan dalam bentuk terpotong. Prefix token berubah, sehingga rotasi token pada perangkat terbukti. Penerimaan pesan FCM, klik notifikasi, serta `POST /devices` sungguhan masih belum terverifikasi karena backend uji dan bukti pengiriman pesan belum tersedia.

## Matriks pengujian tiga app state

Gunakan payload gabungan `notification + data` dengan `data.route=/pengumuman/3` dan `data.id=3` untuk ketiga baris. Jalankan pada perangkat Android setelah backend/FCM siap.

| State | Yang diharapkan | Cara uji | Hasil saat ini |
| --- | --- | --- | --- |
| Foreground | Banner lokal muncul; klik membuka `/pengumuman/3` | Aplikasi terbuka, kirim payload, ketuk banner | Belum diuji di perangkat |
| Background | Banner sistem muncul; klik membuka `/pengumuman/3` | Tekan Home, kirim payload, ketuk banner | Belum diuji di perangkat |
| Terminated | Aplikasi dibuka ke `/pengumuman/3` | Tutup aplikasi, kirim payload, ketuk banner | Belum diuji di perangkat |

Widget test hanya membuktikan bahwa route `/pengumuman/3` dapat dipulihkan setelah login. Test itu **bukan** bukti banner atau klik notifikasi FCM.
