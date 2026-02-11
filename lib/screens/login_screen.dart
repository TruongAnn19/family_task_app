import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/household_model.dart';
import '../screens/dashboard_screen.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  final Function(String familyId, Member member)? onLoginSuccess;

  LoginScreen({Key? key, this.authService, this.onLoginSuccess}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _familyIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthService _authService;

  bool _isLoading = false;
  bool _isFamilyFound = false;
  List<Member> _members = [];
  Member? _selectedMember;
  bool _awaitingPassword = false; // nếu username là admin thì yêu cầu password

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _familyIdController.addListener(() {
      // rebuild so UI can react to family id input (e.g., hide register)
      setState(() {});
    });
  }



  @override
  void dispose() {
    // removeListener not required because disposing controller removes listeners
    _familyIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Bước 1: Kiểm tra Family ID
  Future<void> _checkFamilyId() async {
    setState(() => _isLoading = true);
    String id = _familyIdController.text.trim();

    bool exists = await _authService.checkFamilyExists(id);

    if (exists) {
      // Nếu nhà đã có -> Lấy danh sách thành viên về
      List<Member> members = await _authService.getFamilyMembers(id);
      setState(() {
        _isFamilyFound = true;
        _members = members;
      });
    } else {
      // Nếu nhà chưa có -> Chuyển sang chế độ đăng ký
      setState(() {
        _isFamilyFound = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mã nhà chưa tồn tại. Hãy đăng ký mới!")),
      );
    }
    setState(() => _isLoading = false);
  }

  // Khi người dùng nhập username sau khi đã nhập Family ID
  Future<void> _handleUsernameContinue() async {
    setState(() => _isLoading = true);
    String username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập username")),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Tìm user trong danh sách members đã load
    Member? found;
    try {
      found = _members.firstWhere((m) => m.name.toLowerCase() == username.toLowerCase());
    } catch (e) {
      found = null;
    }

    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy thành viên. Bạn có thể đăng ký.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Nếu là admin -> yêu cầu mật khẩu
    if (found.isAdmin) {
      setState(() {
        _selectedMember = found;
        _awaitingPassword = true;
      });
    } else {
      setState(() {
        _selectedMember = found;
      });
      // Thành viên bình thường -> vào thẳng
      await _handleLogin();
    }

    setState(() => _isLoading = false);
  }

  // Hiện dialog đăng ký (ID nhà, username, pass)
  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController _dFamilyController = TextEditingController(text: _familyIdController.text);
        final TextEditingController _dUserController = TextEditingController();
        final TextEditingController _dPassController = TextEditingController();
        bool _dialogLoading = false;

        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Icon(Icons.person_add, size: 50, color: Colors.teal),
                SizedBox(height: 10),
                Text('Đăng ký tài khoản', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _dFamilyController,
                    decoration: InputDecoration(
                        labelText: 'ID nhà (Family ID)',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100]
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _dUserController,
                    decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100]
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _dPassController,
                    decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(Icons.lock),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100]
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Huỷ', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _dialogLoading
                    ? null
                    : () async {
                        setStateDialog(() => _dialogLoading = true);
                        String fid = _dFamilyController.text.trim();
                        String uname = _dUserController.text.trim();
                        String pass = _dPassController.text;
                        if (fid.isEmpty || uname.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Vui lòng điền đủ thông tin')));
                          setStateDialog(() => _dialogLoading = false);
                          return;
                        }

                        bool exists = await _authService.checkFamilyExists(fid);
                        if (exists) {
                          // Nếu nhà đã có -> kiểm tra xem user có đang cố tạo nhà mới không (nhập pass)
                          if (pass.isNotEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ID Nhà đã tồn tại! Để tham gia, vui lòng để trống mật khẩu Admin.')));
                             setStateDialog(() => _dialogLoading = false);
                             return;
                          }

                          // Thêm thành viên (chỉ khi không nhập pass)
                          await _authService.addMember(fid, uname);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đăng ký thành viên thành công. Bạn có thể đăng nhập.')),
                          );
                        } else {
                          // Tạo nhà mới (cần mật khẩu)
                          if (pass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Nhà chưa tồn tại, vui lòng nhập mật khẩu để tạo nhà mới.')));
                            setStateDialog(() => _dialogLoading = false);
                            return;
                          }
                          await _authService.registerHousehold(familyId: fid, adminUser: uname, password: pass);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tạo nhà và tài khoản admin thành công.')),
                          );
                        }

                        Navigator.of(ctx).pop();
                        // Nếu user vừa thao tác đúng family hiện tại thì refresh
                        if (_familyIdController.text.trim() == fid) _checkFamilyId();
                        setStateDialog(() => _dialogLoading = false);
                      },
                child: Text('Đăng ký'),
              ),
            ],
          );
        });
      },
    );
  }

  // Hủy trạng thái nhập: xóa tất cả ô và trở về màn hình ban đầu
  void _cancelEntry() {
    setState(() {
      _isFamilyFound = false;
      _familyIdController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _members = [];
      _selectedMember = null;
      _awaitingPassword = false;
      _isLoading = false;
    });
  }

  // Bước 2A: Xử lý Đăng nhập
  Future<void> _handleLogin() async {
    if (_selectedMember == null) return;

    if (_selectedMember!.isAdmin) {
      // Nếu chọn tên Admin -> Phải nhập pass
      bool isPassCorrect = await _authService.verifyAdmin(
        _familyIdController.text,
        _passwordController.text,
      );
      if (!isPassCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sai mật khẩu!")));
        return;
      }
    }

    // Test Hook: bypass full login flow if testing
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!(_familyIdController.text, _selectedMember!);
      return;
    }

    // Lưu thông tin vào bộ nhớ máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('familyId', _familyIdController.text);
    await prefs.setString('username', _selectedMember!.name);
    await prefs.setBool('isAdmin', _selectedMember!.isAdmin);

    await NotificationService.init();
    String? token = await NotificationService.getDeviceToken();
    if (token != null) {
      await _authService.updateMemberToken(
        _familyIdController.text,
        _selectedMember!.name,
        token,
      );
    }
    await NotificationService.subscribeToFamilyTopic(_familyIdController.text);
    await NotificationService.scheduleSaturdayReminder();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          familyId: _familyIdController.text,
          currentUser: _selectedMember!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFamilyTyped = _familyIdController.text.trim().isNotEmpty;

    return Scaffold(
      // Remove AppBar for full screen design
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.teal.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // New Icon
                    Icon(
                      Icons.family_restroom, 
                      size: 100, 
                      color: Colors.white
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Quản Lý Việc Nhà',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)]
                      ),
                    ),
                    SizedBox(height: 40),

                    // Login Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 16,
                      shadowColor: Colors.black45,
                      child: Stack(
                        children: [
                          if (_isFamilyFound)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.grey),
                                onPressed: _cancelEntry,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _isFamilyFound ? "Xin chào!" : "Chào mừng trở lại",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                
                                // Family ID Input
                                TextField(
                                  controller: _familyIdController,
                                  decoration: InputDecoration(
                                    labelText: "ID Nhà (Family ID)",
                                    prefixIcon: Icon(Icons.home, color: Colors.teal),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.search, color: Colors.teal),
                                      onPressed: _isLoading ? null : _checkFamilyId,
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  enabled: !_isFamilyFound && !_isLoading,
                                ),

                                SizedBox(height: 16),

                                 // Register Button (if family not found)
                                if (!_isFamilyFound) ...[
                                  TextButton(
                                    onPressed: _isLoading ? null : _showRegisterDialog,
                                    child: Text('Bạn chưa có tài khoản? Đăng ký ngay', 
                                        style: TextStyle(color: Colors.teal.shade600, fontWeight: FontWeight.bold)),
                                  ),
                                ],

                                // Username Input (if family found)
                                if (_isFamilyFound) ...[
                                  Text('Tài khoản của bạn', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      prefixIcon: Icon(Icons.person, color: Colors.teal),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    enabled: !_awaitingPassword, 
                                  ),
                                  
                                  // Chỉ hiện nút Tiếp tục nếu CHƯA chờ pass
                                  if (!_awaitingPassword) ...[
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _handleUsernameContinue,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade600,
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 4,
                                      ),
                                      child: Text(
                                        _isLoading ? 'Đang xử lý...' : 'Tiếp tục',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],

                                  if (_awaitingPassword) ...[
                                    SizedBox(height: 16),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Mật khẩu Admin',
                                        prefixIcon: Icon(Icons.lock, color: Colors.orange),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _handleLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange.shade700,
                                              padding: EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 4,
                                            ),
                                            child: Text(
                                              _isLoading ? 'Đang xử lý...' : 'Vào Nhà',
                                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        OutlinedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _awaitingPassword = false;
                                                    _passwordController.clear();
                                                    _selectedMember = null;
                                                  });
                                                },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.grey),
                                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: Icon(Icons.arrow_back, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],

                                  SizedBox(height: 12),
                                  if (!hasFamilyTyped)
                                    Center(
                                      child: TextButton(
                                        onPressed: _isLoading ? null : _showRegisterDialog,
                                        child: Text('Đăng ký tài khoản khác?', style: TextStyle(color: Colors.teal.shade600)),
                                      ),
                                    ),

                                  Center(
                                    child: TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              setState(() {
                                                _isFamilyFound = false;
                                                _familyIdController.clear();
                                                _members = [];
                                                _selectedMember = null;
                                                _awaitingPassword = false;
                                                _usernameController.clear();
                                                _passwordController.clear();
                                              });
                                            },
                                      child: Text('Đổi Mã Nhà', style: TextStyle(color: Colors.grey[600])),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
