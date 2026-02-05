# Family Task App

Ứng dụng quản lý công việc gia đình, giúp phân chia việc nhà và theo dõi tiến độ một cách minh bạch và vui vẻ.

## 🚀 Tính Năng Chính

### 1. Quản lý Công Việc (Tasks)
*   **Phân công**: Tự động hoặc thủ công phân chia việc nhà cho các thành viên.
*   **Danh sách công việc**: Hiển thị rõ ràng các đầu việc cần làm trong ngày và tuần.
*   **Trạng thái**: Đánh dấu hoàn thành, chờ xác nhận.
*   **Đổi việc (Swap)**: Tính năng cho phép các thành viên yêu cầu đổi việc cho nhau.
    *   Hỗ trợ cơ chế "Công bằng": Người nhờ làm giúp sẽ bị nợ 1 việc vào tuần sau.
    *   Yêu cầu phê duyệt từ người được nhờ.

### 2. Trang Chủ (Dashboard)
*   **Tổng quan**: Xem nhanh công việc hôm nay, tiến độ cá nhân.
*   **Lịch Vạn Niên**: Tích hợp lịch Âm/Dương, xem ngày tốt xấu.
    *   Hiển thị can chi, con giáp của năm (e.g., Năm Bính Ngọ 2026).
    *   Thêm sự kiện, ghi chú và nhắc nhở.
*   **Ngày Lễ**: Tự động hiển thị lời chúc vào các dịp lễ tết Việt Nam (Tết, Giỗ tổ, 30/4, v.v.).
*   **ID Nhà**: Hiển thị mã gia đình để dễ dàng mời thành viên mới.

### 3. Phân Quyền
*   **Admin (Bố mẹ)**: Quản lý thành viên, cài đặt hệ thống, phê duyệt các yêu cầu đặc biệt.
*   **Thành viên (Con cái)**: Xem và thực hiện công việc, gửi yêu cầu đổi việc.

### 4. Hệ Thống Thưởng Phạt
*   Theo dõi điểm số/vi phạm để có chế độ thưởng phạt phù hợp (Penalty Box).

## 🛠 Công Nghệ Sử Dụng
*   **Framework**: Flutter (Dart)
*   **Backend**: Firebase (Firestore, Auth)
*   **State Management**: Stateful Widgets (Simple)

## 📦 Cài Đặt
1.  Clone repository.
2.  Chạy `flutter pub get`.
3.  Cấu hình Firebase (thêm `google-services.json`).
4.  Chạy `flutter run`.

---
*Developed by [TruongAnn19]*
