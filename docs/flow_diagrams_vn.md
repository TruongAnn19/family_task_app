# Sơ đồ Luồng Ứng Dụng (Tiếng Việt)

Tài liệu này chứa các sơ đồ luồng chính ở dạng ASCII để dễ đọc nhanh và dùng làm tài liệu cho developer/agent.

---

**1) Luồng Đăng Nhập (Login Flow)**

User                                          App / Services
 |                                               |
 |-- nhập Family ID ---------------------------->|
 |                                               |  _authService.checkFamilyExists(familyId)
 |                                               |-- có? --> _authService.getFamilyMembers(familyId)
 |                                               |           trả về members
 |                                               |-- không? --> show "Mã nhà chưa tồn tại" (cho nút Đăng ký)
 |<-- hiển thị: danh sách member + input username --|
 |-- nhập Username ------------------------------>|
 |                                               | find member trong members (case-insensitive)
 |                                               |-- không tìm thấy -> show "Không tìm thấy thành viên"
 |                                               |-- tìm thấy && member.isAdmin == false -> login trực tiếp
 |                                               |-- tìm thấy && member.isAdmin == true -> show input mật khẩu
 |-- (nếu admin) nhập password ------------------>|
 |                                               | _authService.verifyAdmin(familyId, password)
 |                                               |-- success -> tiếp tục
 |                                               |-- fail -> show "Sai mật khẩu"
 |-- (login thành công) lưu prefs, đăng ký token ->| _NotificationService.init()/getDeviceToken()
 |                                               | _authService.updateMemberToken(familyId, username, token)
 |                                               | subscribe topic, schedule reminders
 |<-- điều hướng tới Dashboard -------------------|

---

**2) Luồng Đăng Ký (Popup Register Flow)**n
User                                          App / Services
 |                                               |
 |-- click "Đăng ký" (ở màn nhập Family ID) ---->| show Dialog(Family ID, Username, Password)
 |-- nhập fid, username, (password) -------------| 
 |-- submit ------------------------------------->| _authService.checkFamilyExists(fid)
 |                                               |-- nếu exists: _authService.addMember(fid, username)
 |                                               |             show 'Đăng ký thành viên thành công'
 |                                               |-- nếu not exists:
 |                                               |     - nếu password rỗng -> show 'Nhập mật khẩu để tạo nhà'
 |                                               |     - else -> _authService.registerHousehold(fid, adminUser, password)
 |                                               |             show 'Tạo nhà và admin thành công'
 |-- dialog đóng -------------------------------->|
 |-- nếu dialog fid == màn hiện tại -> gọi _checkFamilyId() để reload members

---

**3) Dashboard (Tương tác sau đăng nhập)**

- Input: familyId, currentUser (Member)
- Dashboard hiển thị tasks, lịch, thành viên, cài đặt.
- Nếu currentUser.isAdmin == true: hiển thị tab Admin (quản lý task, members, cấu hình)
- Actions:
  - Thêm/ sửa/ xóa task -> _authService.addTaskConfig / removeTaskConfig
  - Thêm/ xóa member -> _authService.addMember / removeMember
  - Các thao tác gửi notification hoặc swap request -> gọi các service tương ứng

ASCII (rất ngắn):

User -> DashboardScreen -> (Admin?) show AdminTab -> call AuthService -> update Firestore

---

**4) Notification flow (khi login)**

Login success -> NotificationService.init() -> getDeviceToken() -> if token: _authService.updateMemberToken(familyId, username, token) -> subscribe to family topic

---

Ghi chú:
- Các sơ đồ trên là bản tóm tắt nhanh; tham khảo chi tiết trong `docs/app_flows_prompt_vn.md` để biết logic và các hàm gọi chính xác.
- Nếu cần, tôi có thể chuyển các sơ đồ này sang định dạng hình ảnh (PNG/SVG) hoặc thêm sơ đồ tuần tự (sequence diagram) bằng PlantUML.
