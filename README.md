# FixMyLife (Froggy) 🐸

**FixMyLife** (trước đây là RedoLife) là ứng dụng macOS giúp bạn xây dựng lại nề nếp sinh hoạt, quản lý thói quen và đạt được các mục tiêu trong cuộc sống. Với giao diện dễ thương, thân thiện và các tính năng "chữa lành", ứng dụng sẽ đồng hành cùng bạn mỗi ngày.

## ✨ Tính năng chính

*   **Quản lý Thói quen (Routines)**:
    *   Tạo và theo dõi thói quen hàng ngày.
    *   Chia theo buổi: Sáng, Chiều, Tối.
    *   Đánh dấu hoàn thành và xem tiến độ ngay lập tức.
*   **Mục tiêu (Goals)**:
    *   Đặt mục tiêu Ngắn hạn & Dài hạn.
    *   Theo dõi hạn chót (Deadline).
*   **Thống kê & Gamification**:
    *   **XP & Level**: Tích luỹ kinh nghiệm khi hoàn thành nhiệm vụ.
    *   **Heatmap**: Biểu đồ nhiệt hiển thị độ chăm chỉ trong năm (giống GitHub).
    *   **Thành tựu (Achievements)**: Mở khoá huy hiệu khi đạt chuỗi (Streak) hoặc mốc quan trọng.
*   **Nhắc nhở thông minh**:
    *   Thông báo chào buổi sáng/tổng kết tối.
    *   Nhắc nhở nhẹ nhàng nếu tiến độ trong ngày còn thấp.
    *   Quotes động lực mỗi giờ.
*   **Giao diện "Glassmorphism"**: Hiện đại, mượt mà và hỗ trợ Dark Mode (sắp có).

## 🛠 Cài đặt & Sử dụng

### Cách 1: Chạy từ file cài đặt (.dmg)
1.  Tải file `FixMyLife_Installer.dmg`.
2.  Kéo ứng dụng **FixMyLife** vào thư mục **Applications**.
3.  Mở ứng dụng lên.
    *   *Lưu ý*: Nếu macOS báo lỗi *"App is damaged..."* (do ứng dụng chưa được ký chứng chỉ Apple $99), hãy mở **Terminal** và chạy lệnh sau:
        ```bash
        xattr -cr /Applications/Fix\ My\ Life.app
        ```

### Cách 2: Tự Build từ Source Code
Yêu cầu: macOS, Xcode 15+.

1.  Clone project về máy.
2.  Mở file `RedoLife.xcodeproj`.
3.  Cấu hình Signing:
    *   Vào tab **Signing & Capabilities**.
    *   Chọn **Team**: None.
    *   Chọn **Signing Certificate**: Sign to Run Locally.
4.  Bấm **Cmd + R** để chạy thử hoặc dùng script đóng gói:
    ```bash
    ./package_dmg.sh
    ```

## 📂 Cấu trúc dữ liệu
Dữ liệu của bạn được lưu trữ an toàn trong máy (Local Storage) bằng **SwiftData**.
*   Không cần kết nối mạng.
*   Update app thoải mái không mất dữ liệu (miễn là không đổi Bundle ID và thao tác trên cùng 1 máy).

## 👨‍💻 Tác giả
Developed by **@yun.khngn**.
Phiên bản hiện tại: **1.0.0**
