import 'package:flutter/material.dart';
import '../../models/household_model.dart';
import '../../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  final String familyId;
  const AdminScreen({Key? key, required this.familyId}) : super(key: key);
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<Member> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  // Tải danh sách thành viên mới nhất
  void _loadMembers() async {
    setState(() => _isLoading = true);
    List<Member> list = await _authService.getFamilyMembers(widget.familyId);
    setState(() {
      _members = list;
      _isLoading = false;
    });
  }

  // Hiển thị Popup nhập tên
  void _showAddMemberDialog() {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.teal),
            SizedBox(width: 10),
            Text("Thêm thành viên", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Tên thành viên",
            hintText: "Ví dụ: Bình",
            prefixIcon: Icon(Icons.account_circle, color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Hủy
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              String name = _nameController.text.trim();
              if (name.isNotEmpty) {
                // Gọi service thêm vào DB
                await _authService.addMember(widget.familyId, name);
                
                Navigator.pop(context); // Đóng popup
                _loadMembers(); // Tải lại danh sách để hiện tên mới
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã thêm $name vào nhà!")),
                );
              }
            },
            child: Text("Thêm"),
          ),
        ],
      ),
    );
  }

  // Xử lý xóa thành viên
  void _deleteMember(Member member) async {
    if (member.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể xóa Admin!")),
      );
      return;
    }

    // Hiện popup xác nhận
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text("Xác nhận xóa", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Bạn có chắc muốn xóa ${member.name} khỏi nhà không?", style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Hủy", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.removeMember(widget.familyId, member);
              _loadMembers(); // Reload list
            },
            child: Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.fromLTRB(24, 50, 24, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade400],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Thành Viên",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: member.isAdmin ? Colors.orange.shade100 : Colors.teal.shade50,
                            radius: 24,
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: TextStyle(
                                color: member.isAdmin ? Colors.orange.shade800 : Colors.teal.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            member.isAdmin ? "Chủ hộ (Admin)" : "Thành viên",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: member.isAdmin
                              ? Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(Icons.star, color: Colors.orange, size: 20)
                                )
                              : IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                                  onPressed: () => _deleteMember(member),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        icon: Icon(Icons.person_add),
        label: Text("Thêm Thành Viên"),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
    );
  }
}