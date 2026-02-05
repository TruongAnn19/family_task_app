class TaskAssignment {
  final String taskId;
  final String taskName;
  final String assignedTo; // Tên thành viên
  final bool isDone;
  final String? proofImage; // Url ảnh (nếu có)

  TaskAssignment({
    required this.taskId,
    required this.taskName,
    required this.assignedTo,
    this.isDone = false,
    this.proofImage,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskName': taskName,
        'assignedTo': assignedTo,
        'isDone': isDone,
        'proofImage': proofImage,
      };

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      taskId: json['taskId'] ?? '',
      taskName: json['taskName'] ?? '',
      assignedTo: json['assignedTo'] ?? 'Chưa gán',
      isDone: json['isDone'] ?? false,
      proofImage: json['proofImage'],
    );
  }
}

class WeeklySchedule {
  final String weekId; // Format: 2026_W06
  final List<TaskAssignment> assignments;

  WeeklySchedule({required this.weekId, required this.assignments});

  factory WeeklySchedule.fromFirestore(Map<String, dynamic> data, String id) {
    return WeeklySchedule(
      weekId: id,
      assignments: (data['assignments'] as List<dynamic>?)
              ?.map((e) => TaskAssignment.fromJson(e))
              .toList() ?? [],
    );
  }
}