# Bukti lifecycle token FCM

Pengujian dilakukan pada perangkat Android dengan mengamati halaman **Debug FCM**, menghapus data aplikasi, membuka aplikasi kembali, memberikan izin notifikasi, lalu membuka halaman Debug FCM sekali lagi.

## Urutan pengujian

1. Sebelum data aplikasi dihapus, halaman Debug FCM menampilkan prefix token `evFOrdgTQ-aV...`.
2. Data aplikasi dihapus melalui pengaturan Android.
3. Saat aplikasi dibuka kembali, Android meminta izin notifikasi ulang.
4. Setelah izin diberikan dan halaman Debug FCM dibuka, prefix token menjadi `fNcdsB7dSyes...`.

## Bukti

### 1. Token sebelum clear data

![Token sebelum clear data](../screenshots/05-token-before-clear-data.png)

### 2. Permission diminta kembali

![Permission setelah clear data](../screenshots/06-permission-after-clear-data.png)

### 3. Token setelah clear data

![Token setelah clear data](../screenshots/07-token-after-clear-data.png)

## Kesimpulan

Prefix token berubah dari `evFOrdgTQ-aV...` menjadi `fNcdsB7dSyes...`. Ini membuktikan token perangkat yang diperoleh aplikasi berubah setelah clear data. Token lengkap tidak ditampilkan pada UI maupun dokumentasi.

Ketiga screenshot ini tidak memperlihatkan request atau data pada server. Karena itu, pembaruan token melalui `POST /devices` dan pemrosesan `onTokenRefresh` oleh backend masih perlu dibuktikan terpisah menggunakan log backend atau daftar perangkat pada endpoint uji.
