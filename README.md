# 🎵 Offline Music Player (Flutter)

Ứng dụng **nghe nhạc offline** được xây dựng bằng **Flutter**, cho phép phát nhạc từ thiết bị, quản lý playlist và lưu trạng thái phát nhạc.

Video demo: https://drive.google.com/file/d/19Qhs53m-U1B4enLV2a2pWtdMA2n0zdun/view?usp=drive_link
---

## 📌 Mục tiêu dự án
- Xây dựng ứng dụng nghe nhạc **offline**
- Áp dụng **Flutter + Provider**
- Thực hành quản lý audio, permission và local storage
- Hoàn thành đầy đủ các bước theo đề bài môn học

---

## 🚀 Tính năng chính

### 🎶 Phát nhạc
- ▶️ Play / ⏸ Pause
- ⏭ Next / ⏮ Previous
- ⏩ Seek (tua nhạc)
- 🔊 Điều chỉnh âm lượng
- ⚡ Điều chỉnh tốc độ phát
- 🎧 Phát nhạc nền (background)

### 🔀 Điều khiển nâng cao
- 🔀 Shuffle (phát ngẫu nhiên)
- 🔁 Repeat:
  - Tắt lặp
  - Lặp toàn bộ playlist
  - Lặp một bài

### 📂 Thư viện nhạc
- Quét nhạc từ thiết bị
- Sắp xếp theo:
  - Tên bài hát
  - Nghệ sĩ
  - Album
  - Ngày thêm
- 🔍 Tìm kiếm bài hát

### 📑 Playlist
- ➕ Tạo playlist
- ✏️ Đổi tên playlist
- ❌ Xoá playlist
- ➕➖ Thêm / xoá bài hát khỏi playlist
- 🕒 Danh sách **Recently Played**

### 💾 Lưu trạng thái
- Nhớ bài hát phát gần nhất
- Nhớ vị trí đang nghe
- Lưu shuffle / repeat
- Lưu âm lượng

---

## 🧱 Cấu trúc thư mục

```text
lib/
├── main.dart
├── models/
│   ├── song_model.dart
│   ├── playlist_model.dart
│   └── playback_state_model.dart
├── services/
│   ├── audio_player_service.dart
│   ├── storage_service.dart
│   ├── permission_service.dart
│   └── playlist_service.dart
├── providers/
│   ├── audio_provider.dart
│   ├── playlist_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── now_playing_screen.dart
│   ├── playlist_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── song_tile.dart
│   ├── mini_player.dart
│   ├── player_controls.dart
│   └── progress_bar.dart
└── utils/
    ├── duration_formatter.dart
    └── color_extractor.dart

assets/
├── audio/
│   └── sample_songs/
└── images/
    └── default_album_art.png

```

---

### 🛠 Công nghệ sử dụng ###

- Flutter (SDK >= 3.0.0)
- Provider – quản lý state
- just_audio – phát nhạc
- audio_session – audio focus
- on_audio_query_forked – truy vấn nhạc thiết bị
- shared_preferences – lưu dữ liệu
- permission_handler – xin quyền truy cập bộ nhớ

---

### ▶️ Cách chạy dự án
## 1️⃣ Cài dependency
```
flutter pub get
```

## 2️⃣ Chạy ứng dụng
```
flutter run
```

---

### 👨‍🎓 Thông tin sinh viên

Tên: Trần Phước Yên

MSSV: 2224802010093
