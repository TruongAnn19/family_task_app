import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/household_model.dart';
import '../models/weekly_schedule_model.dart';
import '../utils/rotation_logic.dart';
import '../models/notification_model.dart';
import '../models/swap_request_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hàm quan trọng nhất: Lấy lịch tuần. Nếu chưa có thì TỰ TẠO.
  Future<WeeklySchedule> getOrGenerateWeeklySchedule(String familyId) async {
    int currentWeek = RotationLogic.getCurrentWeekNumber();
    int currentYear = DateTime.now().year;
    String weekId = "${currentYear}_W$currentWeek";
    String lastWeekId = "${currentYear}_W${currentWeek - 1}";
    // Lấy cấu hình mới nhất của Nhà (để biết có bao nhiêu việc)
    DocumentSnapshot houseDoc = await _db
        .collection('Households')
        .doc(familyId)
        .get();
    if (!houseDoc.exists) throw Exception("Nhà không tồn tại");

    Household household = Household.fromFirestore(
      houseDoc.data() as Map<String, dynamic>,
    );
    // Kiểm tra xem tuần này đã có lịch trong DB chưa
    DocumentReference scheduleRef = _db
        .collection('Households')
        .doc(familyId)
        .collection('WeeklySchedules')
        .doc(weekId);

    DocumentSnapshot scheduleSnapshot = await scheduleRef.get();
    if (scheduleSnapshot.exists && scheduleSnapshot.data() != null) {
      Map<String, dynamic> data =
          scheduleSnapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('assignments')) {
        return await _generateNewSchedule(
          scheduleRef,
          household,
          currentWeek,
          weekId,
        );
      }
      WeeklySchedule currentSchedule = WeeklySchedule.fromFirestore(
        data,
        weekId,
      );
      return await _syncMissingTasks(
        scheduleRef,
        currentSchedule,
        household,
        currentWeek,
      );
    } else {
      await _checkAndPunishLastWeek(familyId, lastWeekId);
      return await _generateNewSchedule(
        scheduleRef,
        household,
        currentWeek,
        weekId,
      );
    }
  }

  Future<void> _checkAndPunishLastWeek(String familyId, String lastWeekId) async {
    // Lấy dữ liệu tuần trước
    var lastWeekDoc = await _db
        .collection('Households')
        .doc(familyId)
        .collection('WeeklySchedules')
        .doc(lastWeekId)
        .get();

    if (!lastWeekDoc.exists) return; // Tuần trước không có lịch thì thôi

    WeeklySchedule lastSchedule = WeeklySchedule.fromFirestore(lastWeekDoc.data()!, lastWeekId);
    
    // Tìm những kẻ lười biếng (chưa Done)
    List<String> lazyPeople = [];
    for (var task in lastSchedule.assignments) {
      if (!task.isDone) {
        lazyPeople.add("${task.assignedTo} chưa làm '${task.taskName}'");
      }
    }

    // Nếu có người lười -> Ghi vào bảng Notifications
    if (lazyPeople.isNotEmpty) {
      String punishmentContent = "⚠️ BIÊN BẢN TUẦN $lastWeekId:\n" + lazyPeople.join("\n");
      
      await _db
          .collection('Households')
          .doc(familyId)
          .collection('Notifications') // Collection mới
          .add(PenaltyNotice(
            id: '', 
            content: punishmentContent, 
            createdAt: DateTime.now()
          ).toJson());
          
      print("Đã ghi nhận phạt cho tuần cũ!");
    }
  }

  // Hàm nội bộ: Tính toán người làm dựa trên Config và lưu vào DB
  Future<WeeklySchedule> _generateNewSchedule(
    DocumentReference ref,
    Household household,
    int weekNumber,
    String weekId,
  ) async {
    List<TaskAssignment> newAssignments = [];

    for (var taskConfig in household.taskConfigs) {
      String assigneeName = RotationLogic.calculateAssignee(
        members: household.members,
        task: taskConfig,
        weekNumber: weekNumber,
      );

      newAssignments.add(
        TaskAssignment(
          taskId: taskConfig.id,
          taskName: taskConfig.title,
          assignedTo: assigneeName,
          isDone: false,
        ),
      );
    }

    // --- FAIRNESS LOGIC ADDITION ---
    // Trước khi lưu xuống DB, kiểm tra nợ nần và gán lại việc
    newAssignments = await _applyFairnessLogic(household.familyId, newAssignments);
    // -------------------------------

    await ref.set({
      'assignments': newAssignments.map((e) => e.toJson()).toList(),
    });
    return WeeklySchedule(weekId: weekId, assignments: newAssignments);
  }

  Future<WeeklySchedule> _syncMissingTasks(
    DocumentReference ref,
    WeeklySchedule currentSchedule,
    Household household,
    int weekNumber,
  ) async {
    List<TaskAssignment> finalAssignments = List.from(
      currentSchedule.assignments,
    );
    bool hasChanges = false;

    // Duyệt qua tất cả các việc trong Config
    for (var config in household.taskConfigs) {
      // Kiểm tra xem việc này đã có trong lịch tuần chưa?
      bool exists = currentSchedule.assignments.any(
        (a) => a.taskId == config.id,
      );

      if (!exists) {
        // Nếu chưa có (Việc mới thêm) -> Tính toán người làm và thêm vào
        String assigneeName = RotationLogic.calculateAssignee(
          members: household.members,
          task: config,
          weekNumber: weekNumber,
        );

        finalAssignments.add(
          TaskAssignment(
            taskId: config.id,
            taskName: config.title,
            assignedTo: assigneeName,
            isDone: false, // Việc mới thêm mặc định chưa xong
          ),
        );

        hasChanges = true;
      }
    }

    // Nếu có sự thay đổi, cập nhật lại Firestore
    if (hasChanges) {
      await ref.update({
        'assignments': finalAssignments.map((e) => e.toJson()).toList(),
      });
    }

    // Trả về danh sách đầy đủ (Cũ + Mới)
    return WeeklySchedule(
      weekId: currentSchedule.weekId,
      assignments: finalAssignments,
    );
  }

  // Hàm đánh dấu hoàn thành công việc
  Future<void> toggleTaskStatus(
    String familyId,
    String weekId,
    List<TaskAssignment> currentList,
    int index,
  ) async {
    // Đảo ngược trạng thái isDone
    bool newStatus = !currentList[index].isDone;

    // Cập nhật list local
    // Lưu ý: Để đơn giản, ta update cả mảng assignments đè lên.
    // Thực tế nên update từng phần tử nếu mảng quá lớn.
    List<Map<String, dynamic>> updatedListJson = currentList.map((e) {
      if (e == currentList[index]) {
        return TaskAssignment(
          taskId: e.taskId,
          taskName: e.taskName,
          assignedTo: e.assignedTo,
          isDone: newStatus,
        ).toJson();
      }
      return e.toJson();
    }).toList();

    await _db
        .collection('Households')
        .doc(familyId)
        .collection('WeeklySchedules')
        .doc(weekId)
        .update({'assignments': updatedListJson});
  }
  // --- SWAP REQUEST FEATURES ---

  // 1. Gửi yêu cầu đổi việc
  Future<void> sendSwapRequest(SwapRequest req) async {
    await _db
        .collection('Households')
        .doc(req.familyId)
        .collection('SwapRequests')
        .doc(req.id)
        .set(req.toJson());
  }

  // 2. Lấy stream các yêu cầu đang chờ xử lý của user
  Stream<List<SwapRequest>> getSwapRequestsStream(String familyId, String username) {
    return _db
        .collection('Households')
        .doc(familyId)
        .collection('SwapRequests')
        .where('toUser', isEqualTo: username)
        .where('status', isEqualTo: 'pending')
        // .orderBy('createdAt', descending: true) // REMOVED to avoid Index Requirement
        .snapshots()
        .map((snapshot) {
            var list = snapshot.docs.map((doc) => SwapRequest.fromJson(doc.data())).toList();
            // Client-side Sort
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
        });
  }

  // 3. Phản hồi yêu cầu (Accept/Reject)
  Future<void> respondToSwapRequest(SwapRequest req, bool isAccepted) async {
    String newStatus = isAccepted ? 'accepted' : 'rejected';

    // Update status request
    await _db
        .collection('Households')
        .doc(req.familyId)
        .collection('SwapRequests')
        .doc(req.id)
        .update({'status': newStatus});

    // Nếu Accepted -> Thực hiện đổi việc trong WeeklySchedule
    if (isAccepted) {
      await _processSwap(req);
      // Ghi nợ: req.fromUser (người nhờ) NỢ req.toUser (người làm hộ) 1 việc
      await _recordSwapDebt(req.familyId, req.fromUser, req.toUser);
    }
  }

  // 6. Ghi nợ Swap (Fairness Logic)
  Future<void> _recordSwapDebt(String familyId, String debtor, String creditor) async {
    // debtor: Người nhờ (A) - Nợ 1 việc
    // creditor: Người làm hộ (B)
    
    CollectionReference debtRef = _db.collection('Households').doc(familyId).collection('SwapDebts');
    
    // Tìm xem đã có nợ chưa
    QuerySnapshot existing = await debtRef
        .where('debtor', isEqualTo: debtor)
        .where('creditor', isEqualTo: creditor)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
        // Update count
        await debtRef.doc(existing.docs.first.id).update({
            'count': FieldValue.increment(1)
        });
    } else {
        // Create new debt
        await debtRef.add({
            'debtor': debtor,
            'creditor': creditor,
            'count': 1
        });
    }
  }

  // 7. Xử lý trả nợ khi tạo lịch mới
  Future<List<TaskAssignment>> _applyFairnessLogic(String familyId, List<TaskAssignment> assignments) async {
      CollectionReference debtRef = _db.collection('Households').doc(familyId).collection('SwapDebts');
      QuerySnapshot debts = await debtRef.where('count', isGreaterThan: 0).get();

      if (debts.docs.isEmpty) return assignments;

      List<TaskAssignment> updatedAssignments = List.from(assignments);

      for (var doc in debts.docs) {
          Map<String, dynamic> debt = doc.data() as Map<String, dynamic>;
          String debtor = debt['debtor']; // A (người nợ)
          String creditor = debt['creditor']; // B (người chủ nợ)
          int count = debt['count'];

          // Tìm việc của B (creditor) để gán cho A (debtor)
          // Ưu tiên việc chưa Done (logic tạo mới thì tất cả chưa Done)
          List<int> creditorTaskIndices = [];
          for (int i = 0; i < updatedAssignments.length; i++) {
              if (updatedAssignments[i].assignedTo == creditor) {
                  creditorTaskIndices.add(i);
              }
          }

          // Trả nợ tối đa số lượng tasks B có hoặc số lượng nợ
          for (int i = 0; i < count && creditorTaskIndices.isNotEmpty; i++) {
              int taskIndex = creditorTaskIndices.removeLast(); // Lấy việc cuối cùng của B
              
              // Gán lại cho A
              var originalTask = updatedAssignments[taskIndex];
              updatedAssignments[taskIndex] = TaskAssignment(
                  taskId: originalTask.taskId,
                  taskName: originalTask.taskName,
                  assignedTo: debtor, // A PHẢI LÀM
                  isDone: false,
                  proofImage: originalTask.proofImage
              );

              // Giảm nợ
              await debtRef.doc(doc.id).update({
                  'count': FieldValue.increment(-1)
              });
          }
      }
      return updatedAssignments;
  }


  // Internal: Thực hiện đổi người trong Schedule
  Future<void> _processSwap(SwapRequest req) async {
    DocumentReference scheduleRef = _db
        .collection('Households')
        .doc(req.familyId)
        .collection('WeeklySchedules')
        .doc(req.weekId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(scheduleRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      WeeklySchedule schedule = WeeklySchedule.fromFirestore(data, req.weekId);

      // Tìm công việc cần đổi
      List<TaskAssignment> updatedAssignments = schedule.assignments.map((task) {
        if (task.taskId == req.taskId && task.assignedTo == req.fromUser) {
           // Swap: fromUser -> toUser
           return TaskAssignment(
               taskId: task.taskId,
               taskName: task.taskName,
               assignedTo: req.toUser, // Change to new user
               isDone: task.isDone,
               proofImage: task.proofImage
           );
        }
        return task;
      }).toList();

      transaction.update(scheduleRef, {
        'assignments': updatedAssignments.map((e) => e.toJson()).toList()
      });
    });
  }

  // 4. Lấy stream các yêu cầu mà user đã GỬI đi (để update UI bên gửi)
  Stream<List<SwapRequest>> getSentSwapRequestsStream(String familyId, String username) {
    return _db
        .collection('Households')
        .doc(familyId)
        .collection('SwapRequests')
        .where('fromUser', isEqualTo: username)
        .snapshots() // Lấy hết để check status
        .map((snapshot) =>
            snapshot.docs.map((doc) => SwapRequest.fromJson(doc.data())).toList());
  }

  // 5. Hủy yêu cầu (Bên gửi)
  Future<void> cancelSwapRequest(String familyId, String requestId) async {
    await _db
        .collection('Households')
        .doc(familyId)
        .collection('SwapRequests')
        .doc(requestId)
        .delete();
  }
}
