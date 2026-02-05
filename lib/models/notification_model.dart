import 'package:cloud_firestore/cloud_firestore.dart';

class PenaltyNotice {
  final String id;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  PenaltyNotice({
    required this.id, 
    required this.content, 
    required this.createdAt, 
    this.isRead = false
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'created_at': Timestamp.fromDate(createdAt),
    'is_read': isRead,
  };

  factory PenaltyNotice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PenaltyNotice(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      isRead: data['is_read'] ?? false,
    );
  }
}