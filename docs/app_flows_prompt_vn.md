**Sơ đồ luồng:**
- Xem sơ đồ ASCII chi tiết tại `docs/flow_diagrams_vn.md`.
# Tài liệu Prompt — Luồng Ứng Dụng (Tiếng Việt)

Mục đích:
- Mô tả rõ ràng các luồng nghiệp vụ chính của ứng dụng "Family Task App" bằng tiếng Việt.
- Dùng làm tài liệu tham chiếu cho developer mới / agent tự động / tester.

Hướng dẫn chung:
- Mỗi luồng ghi theo thứ tự bước (step-by-step).
- Ghi rõ đầu vào (input), hành động (action), xử lý (logic), đầu ra (output) và các trường hợp lỗi (edge cases).
- Ghi các API/Service liên quan (hàm trong `lib/services/*`).

**1. Luồng Đăng Nhập (Login)**
- Mục tiêu: Cho phép người dùng vào dashboard dựa theo vai trò (Admin hoặc Member).
- Screens liên quan: `lib/screens/login_screen.dart`.

Bước thực hiện:
- B1: Người dùng nhập `Family ID` vào ô `Mã Nhà (Family ID)` và nhấn nút tìm (search).
  - Input: `familyId` (string).
  - Action: gọi `_authService.checkFamilyExists(familyId)`.
  - Nếu có: gọi `_authService.getFamilyMembers(familyId)` để load danh sách thành viên; hiển thị màn nhập `Username`.
  - Nếu không: hiển thị thông báo "Mã nhà chưa tồn tại. Hãy đăng ký mới!"; cho phép bấm `Đăng ký` để mở dialog đăng ký.

- B2: Người dùng nhập `Username` và nhấn `Tiếp tục`.
  - Input: `username`.
  - Action: tìm `Member` trong danh sách đã tải bằng tên (case-insensitive).
  - Nếu không tìm thấy: hiển thị thông báo "Không tìm thấy thành viên. Bạn có thể đăng ký." và dừng.
  - Nếu tìm thấy & member.isAdmin == false: tiến hành bước đăng nhập (B4).
  - Nếu tìm thấy & member.isAdmin == true: hiển thị trường `Mật khẩu Admin` (awaitingPassword = true).

- B3 (nếu Admin): Người dùng nhập `Mật khẩu Admin` và nhấn `Vào Nhà`.
  - Action: gọi `_authService.verifyAdmin(familyId, password)`.
  - Nếu sai: hiển thị "Sai mật khẩu!" và dừng.

- B4: Hoàn tất đăng nhập (cả Admin & Member sau khi xác thực):
  - Lưu `familyId`, `username`, `isAdmin` vào `SharedPreferences`.
  - Gọi `NotificationService.init()` và lấy device token `NotificationService.getDeviceToken()`.
  - Nếu có token: gọi `_authService.updateMemberToken(familyId, username, token)`.
  - Gọi `NotificationService.subscribeToFamilyTopic(familyId)` và `NotificationService.scheduleSaturdayReminder()`.
  - Điều hướng `Navigator.pushReplacement` tới `DashboardScreen(familyId, currentUser)`.

Edge cases / validation:
- Các ô không được để trống khi nhấn nút.
- Đảm bảo không dùng `BuildContext` sau gap async nếu widget có thể unmounted (xem cảnh báo `use_build_context_synchronously`).
- Username so sánh không phân biệt hoa thường.

**2. Luồng Đăng Ký (Register) — Popup**
- Mục tiêu: Cho phép tạo gia đình mới (Admin) hoặc thêm member vào nhà hiện có.
- Nút mở popup: `Bạn chưa có tài khoản? Đăng ký`.

Bước thực hiện (trong dialog):
- Input (theo thứ tự hiển thị): `Family ID`, `Username`, `Password`.
- B1: Nếu `Family ID` tồn tại (`_authService.checkFamilyExists(fid)`):
  - Thực hiện `_authService.addMember(fid, username)` (member.isAdmin=false).
  - Thông báo "Đăng ký thành viên thành công. Bạn có thể đăng nhập.".
  - Nếu dialog mở từ cùng `familyId` đang hiển thị ở màn chính => gọi `_checkFamilyId()` để reload members.
- B2: Nếu `Family ID` chưa tồn tại:
  - Nếu `Password` trống => yêu cầu user nhập password để tạo nhà (vì password sẽ là admin password).
  - Nếu có password => gọi `_authService.registerHousehold(familyId: fid, adminUser: uname, password: pass)` để tạo household + admin member.
  - Thông báo "Tạo nhà và tài khoản admin thành công." và đóng dialog. Sau đó có thể gọi `_checkFamilyId()`.

Edge cases:
- Kiểm tra điều kiện input (fid & username không rỗng).
- Không cho phép tạo house với password trống.

**3. Dashboard & Sau Đăng Nhập**
- Màn hình chính: `lib/screens/dashboard_screen.dart`.
- Dashboard sử dụng `familyId` và `currentUser` (Member) để hiển thị thông tin, task, lịch, thông báo.
- Có phân quyền hiển thị tab/điều khiển admin nếu `isAdmin == true`.

Các hành động thường gặp:
- Admin: quản lý task (addTaskConfig, removeTaskConfig), xem members, reset rotation.
- Member: xem tasks, mark complete, gửi yêu cầu đổi ca (swap request).

**4. Notification & Device Token**
- Khi đăng nhập, app gọi `NotificationService.init()` và `getDeviceToken()`.
- Nếu token khác null: cập nhật token cho member trong Firestore thông qua `_authService.updateMemberToken` (transaction: get -> update array members).
- Subscribe topic: `NotificationService.subscribeToFamilyTopic(familyId)` để nhận thông báo chung cho gia đình.

**5. Dữ liệu và Service chính**
- Firestore collection: `Households` (doc id = familyId)
  - Fields: `family_id`, `admin_password`, `members` (array of member JSONs), `task_configs` (array)
- `AuthService` (file: `lib/services/auth_service.dart`) — hàm quan trọng:
  - `checkFamilyExists(familyId)`
  - `registerHousehold(familyId, adminUser, password)`
  - `getFamilyMembers(familyId)`
  - `verifyAdmin(familyId, password)`
  - `addMember(familyId, newName)`
  - `updateMemberToken(familyId, memberName, token)`

**6. Giao diện (UI) & UX notes**
- Luồng login hiện tại: nhập `Family ID` -> nhấn tìm -> nhập `Username` -> (nếu admin: nhập password) -> vào Dashboard.
- Nút `Đăng ký` hiển thị trên màn nhập `Family ID` (khi family chưa được xác nhận) và cũng trên màn nhập username nếu phù hợp.
- UX nhỏ: có overlay loading khi `_isLoading == true` để chặn thao tác khi backend đang xử lý.

**7. Kiểm thử (Test Cases)**
- Test A: Family tồn tại, login với member bình thường
  - Steps: nhập `familyId` (existing) -> nhập username (existing non-admin) -> app vào Dashboard.
- Test B: Family tồn tại, login với admin (mật khẩu đúng)
  - Steps: nhập `familyId` -> nhập admin username -> nhập mật khẩu đúng -> app vào Dashboard với quyền admin.
- Test C: Family chưa tồn tại, đăng ký tạo nhà mới
  - Steps: mở dialog đăng ký -> nhập new `familyId` + username + password -> xác nhận house created và admin created.
- Test D: Family tồn tại, đăng ký thêm member
  - Steps: mở dialog -> nhập existing `familyId` + new username -> member thêm thành công -> reload members.
- Test E: Token cập nhật
  - Steps: sau login, device token được lấy; verify `_authService.updateMemberToken` cập nhật đúng member trong Firestore.

**8. Lập trình viên / Agent Prompts (mẫu để dùng sau này)**
- "Hãy mô tả luồng Đăng nhập từ `LoginScreen` tới `DashboardScreen`, liệt kê các hàm service được gọi và các trường hợp lỗi có thể xảy ra."
- "Kiểm tra code `AuthService.registerHousehold` và đảm bảo mật khẩu admin được hash trước khi lưu (hiện đang lưu plain string)." 
- "Viết unit test widget cho `LoginScreen` kiểm tra: (1) hiển thị nút Đăng ký khi familyId rỗng; (2) hiển thị ô mật khẩu khi username là admin; (3) redirect tới Dashboard khi login thành công."

**9. Ghi chú bảo trì**
- Cân nhắc: Hash mật khẩu admin thay vì lưu plain string (bảo mật).
- Xử lý đồng bộ mảng `members` trong Firestore cẩn thận (tránh race condition) — hiện đang dùng transaction trong `updateMemberToken`.
- Sửa các cảnh báo linter: thêm `key` cho widget công khai, tránh dùng context sau async gap hoặc kiểm tra `mounted` trước khi gọi `Navigator`.

---

