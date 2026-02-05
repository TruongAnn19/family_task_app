class SwapRequest {
  final String id;
  final String familyId;
  final String weekId;
  final String taskId;
  final String taskName;
  final String fromUser;
  final String toUser;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  SwapRequest({
    required this.id,
    required this.familyId,
    required this.weekId,
    required this.taskId,
    required this.taskName,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'familyId': familyId,
        'weekId': weekId,
        'taskId': taskId,
        'taskName': taskName,
        'fromUser': fromUser,
        'toUser': toUser,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SwapRequest.fromJson(Map<String, dynamic> json) {
    return SwapRequest(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      weekId: json['weekId'] ?? '',
      taskId: json['taskId'] ?? '',
      taskName: json['taskName'] ?? '',
      fromUser: json['fromUser'] ?? '',
      toUser: json['toUser'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
