# Test Cases cho Ứng dụng Quản lý Việc Nhà

Dưới đây là danh sách các trường hợp kiểm thử (Test Cases) sẽ được thực hiện tự động:

## 1. Luồng Đăng nhập Admin (Admin Login Flow)
**Mục tiêu:** Xác minh tính năng bảo mật và đăng nhập của Admin.
*   **Bước 1:** Khởi động ứng dụng.
*   **Bước 2:** Nhập ID Nhà (Family ID) là `test_family`.
*   **Bước 3:** Nhấn tìm kiếm.
*   **Bước 4:** Chọn/Nhập thành viên `AdminUser`.
*   **Bước 5:** Hệ thống hiển thị ô nhập mật khẩu.
*   **Bước 6:** Nhập mật khẩu đúng `1234`.
*   **Bước 7:** Nhấn "Vào Nhà".
*   **Kết quả mong đợi:** Chuyển hướng thành công vào màn hình Dashboard.

## 2. Luồng Đăng xuất (Logout Flow)
**Mục tiêu:** Xác minh người dùng có thể thoát tài khoản.
*   **Bước 1:** Từ Dashboard, nhấn nút "Đăng xuất" (Icon Logout).
*   **Kết quả mong đợi:** Quay trở lại màn hình Đăng nhập.

## 3. Luồng Đăng nhập Thành viên (Member Login Flow)
**Mục tiêu:** Xác minh tính năng đăng nhập nhanh cho thành viên thường.
*   **Bước 1:** Nhập ID Nhà `test_family`.
*   **Bước 2:** Chọn/Nhập thành viên `RegularUser`.
*   **Bước 3:** Nhấn "Tiếp tục".
*   **Kết quả mong đợi:** Vào thẳng Dashboard **KHÔNG** cần mật khẩu.

## 4. Kiểm tra Giao diện Dashboard (Dashboard UI Check)
**Mục tiêu:** Xác minh hiển thị đúng thông tin.
*   **Bước 1:** Kiểm tra Header có hiển thị:
    *   Tên thành viên (`AdminUser` hoặc `RegularUser`).
    *   ID Nhà (`test_family`).
*   **Bước 2:** Kiểm tra danh sách công việc hiển thị (ít nhất là tiêu đề "Công việc trong tuần").
