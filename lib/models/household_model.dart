class TaskConfig {
  final String id;
  final String title;
  final int scenario; // 1: Round Robin, 2: Solo, 3: Bulk, 5: By Turn
  final int offset; // Dùng cho Round Robin
  final int counter; // Dùng cho By Turn (số lần đã làm)

  TaskConfig({
    required this.id,
    required this.title,
    required this.scenario,
    this.offset = 0,
    this.counter = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'scenario': scenario,
    'offset': offset,
    'counter': counter,
  };

  factory TaskConfig.fromJson(Map<String, dynamic> json) {
    return TaskConfig(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      scenario: json['scenario'] ?? 1,
      offset: json['offset'] ?? 0,
      counter: json['counter'] ?? 0,
    );
  }
}

class Member {
  final String name;
  final bool isAdmin;
  final String? deviceToken;

  Member({required this.name, this.isAdmin = false, this.deviceToken});

  Map<String, dynamic> toJson() => {
    'name': name,
    'isAdmin': isAdmin,
    'deviceToken': deviceToken,
  };

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      deviceToken: json['deviceToken'],
    );
  }
}

class Household {
  final String familyId;
  final String adminPassword; // Lưu dạng hash (thực tế), ở đây demo lưu string
  final List<Member> members;
  final List<TaskConfig> taskConfigs;

  Household({
    required this.familyId,
    required this.adminPassword,
    required this.members,
    required this.taskConfigs,
  });

  Map<String, dynamic> toJson() => {
    'family_id': familyId,
    'admin_password': adminPassword,
    'members': members.map((e) => e.toJson()).toList(),
    'task_configs': taskConfigs.map((e) => e.toJson()).toList(),
  };

  // Hàm này giúp convert dữ liệu từ Firestore về Object Dart
  factory Household.fromFirestore(Map<String, dynamic> data) {
    return Household(
      familyId: data['family_id'] ?? '',
      adminPassword: data['admin_password'] ?? '',
      members:
          (data['members'] as List<dynamic>?)
              ?.map((e) => Member.fromJson(e))
              .toList() ??
          [],
      taskConfigs:
          (data['task_configs'] as List<dynamic>?)
              ?.map((e) => TaskConfig.fromJson(e))
              .toList() ??
          [],
    );
  }
}
