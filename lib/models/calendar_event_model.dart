import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String note;
  final DateTime date;
  final String familyId;
  final String createdBy; // User name or ID
  final bool hasReminder;
  final DateTime? reminderTime;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    required this.familyId,
    required this.createdBy,
    this.hasReminder = false,
    this.reminderTime,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': Timestamp.fromDate(date),
      'familyId': familyId,
      'createdBy': createdBy,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
    };
  }

  // Create from Firestore Document
  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      familyId: data['familyId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      hasReminder: data['hasReminder'] ?? false,
      reminderTime: data['reminderTime'] != null ? (data['reminderTime'] as Timestamp).toDate() : null,
    );
  }
}
