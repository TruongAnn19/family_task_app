import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/household_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Kiểm tra FamilyID có tồn tại không
  Future<bool> checkFamilyExists(String familyId) async {
    final doc = await _db.collection('Households').doc(familyId).get();
    return doc.exists;
  }

  // Đăng ký hộ gia đình mới (Admin)
  Future<void> registerHousehold({
    required String familyId,
    required String adminUser,
    required String password,
  }) async {
    // Tạo cấu trúc dữ liệu ban đầu
    Household newHouse = Household(
      familyId: familyId,
      adminPassword: _hashPassword(password), // Hash password
      members: [Member(name: adminUser, isAdmin: true)],
      taskConfigs: [],
    );

    await _db.collection('Households').doc(familyId).set(newHouse.toJson());
  }

  // Lấy danh sách thành viên để Login
  Future<List<Member>> getFamilyMembers(String familyId) async {
    final doc = await _db.collection('Households').doc(familyId).get();
    if (doc.exists) {
      Household house = Household.fromFirestore(doc.data()!);
      return house.members;
    }
    return [];
  }

  // Xác thực mật khẩu Admin
  Future<bool> verifyAdmin(String familyId, String password) async {
    final doc = await _db.collection('Households').doc(familyId).get();
    if (!doc.exists) return false;
    
    String storedPassword = doc.data()?['admin_password'];
    String hashedPassword = _hashPassword(password);
    
    // Check hash match OR fallback match (plain text) to avoid full block
    return storedPassword == hashedPassword || storedPassword == password;
  }

  // Hàm thêm thành viên mới
  Future<void> addMember(String familyId, String newName) async {
    Member newMember = Member(name: newName, isAdmin: false);
    await _db.collection('Households').doc(familyId).update({
      'members': FieldValue.arrayUnion([newMember.toJson()]),
    });
  }

  // Hàm xóa thành viên
  Future<void> removeMember(String familyId, Member member) async {
    await _db.collection('Households').doc(familyId).update({
      'members': FieldValue.arrayRemove([member.toJson()]),
    });
  }

  // Hàm thêm công việc mới (Task Config)
  Future<void> addTaskConfig(
    String familyId,
    String title,
    int scenario,
    int offset,
  ) async {
    var uuid = Uuid();
    TaskConfig newTask = TaskConfig(
      id: uuid.v4(), // Tạo ID duy nhất ngẫu nhiên
      title: title,
      scenario: scenario,
      offset: offset,
      counter: 0, // Mặc định chưa làm lần nào
    );

    await _db.collection('Households').doc(familyId).update({
      'task_configs': FieldValue.arrayUnion([newTask.toJson()]),
    });
  }

  // Hàm xóa công việc
  Future<void> removeTaskConfig(String familyId, TaskConfig task) async {
    await _db.collection('Households').doc(familyId).update({
      'task_configs': FieldValue.arrayRemove([task.toJson()]),
    });
  }

  // Lấy danh sách Config hiện tại (để Admin xem)
  Future<List<TaskConfig>> getTaskConfigs(String familyId) async {
    final doc = await _db.collection('Households').doc(familyId).get();
    if (doc.exists) {
      Household house = Household.fromFirestore(doc.data()!);
      return house.taskConfigs;
    }
    return [];
  }

  // Cập nhật Device Token cho thành viên
  Future<void> updateMemberToken(String familyId, String memberName, String token) async {
    final docRef = _db.collection('Households').doc(familyId);
    
    // Firestore hơi khó update 1 phần tử trong mảng. 
    // Cách an toàn: Lấy về -> Sửa -> Lưu đè.
    _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      Household house = Household.fromFirestore(snapshot.data() as Map<String, dynamic>);
      
      // Tìm và update token
      List<Member> updatedMembers = house.members.map((m) {
        if (m.name == memberName) {
          return Member(name: m.name, isAdmin: m.isAdmin, deviceToken: token);
        }
        return m;
      }).toList();

      transaction.update(docRef, {
        'members': updatedMembers.map((e) => e.toJson()).toList()
      });
    });
  }
}
