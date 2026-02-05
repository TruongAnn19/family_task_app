import '../models/household_model.dart'; // Import file model ở trên

class RotationLogic {
  
  // 1. Hàm lấy số tuần hiện tại của năm
  static int getCurrentWeekNumber() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(firstDay).inDays;
    return (dayOfYear / 7).ceil(); 
  }

  // 2. Hàm tính toán người phụ trách (Core Algo)
  static String calculateAssignee({
    required List<Member> members,
    required TaskConfig task,
    required int weekNumber,
  }) {
    if (members.isEmpty) return "Chưa có người";
    int n = members.length;
    List<String> memberNames = members.map((m) => m.name).toList();

    // Kịch bản 2: Sống 1 mình -> Luôn là người đầu tiên (Admin)
    if (n == 1) return memberNames[0];

    int index = 0;
    switch (task.scenario) {
      case 3: // Kịch bản 3: Thầu khoán (1 người làm hết tuần)
        index = weekNumber % n;
        break;
      case 5: // Kịch bản 5: Theo lượt (Counter)
        index = task.counter % n; 
        break;
      case 1:
      case 4: // Kịch bản 1, 4: Xoay vòng chia đều
      default:
        index = (weekNumber + task.offset) % n;
    }
    return memberNames[index];
  }
}