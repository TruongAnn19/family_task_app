import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event_model.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Event
  Future<void> addEvent(CalendarEvent event) async {
    await _firestore
        .collection('Households')
        .doc(event.familyId)
        .collection('CalendarEvents')
        .doc(event.id)
        .set(event.toMap());
  }

  // Update Event
  Future<void> updateEvent(CalendarEvent event) async {
    await addEvent(event); // set() overwrites/updates
  }

  // Delete Event
  Future<void> deleteEvent(String familyId, String eventId) async {
    await _firestore
        .collection('Households')
        .doc(familyId)
        .collection('CalendarEvents')
        .doc(eventId)
        .delete();
  }

  // Stream Events for a specific month (optional optimization: query by range)
  // For simplicity, we can stream all events and filter on client or query by timerange
  Stream<List<CalendarEvent>> getEventsStream(String familyId) {
    return _firestore
        .collection('Households')
        .doc(familyId)
        .collection('CalendarEvents')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }
  
  // Get Events by specific month (more efficient)
  Future<List<CalendarEvent>> getEventsByMonth(String familyId, DateTime month) async {
    // Start of month
    DateTime start = DateTime(month.year, month.month, 1);
    // End of month
    DateTime end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('Households')
        .doc(familyId)
        .collection('CalendarEvents')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
  }
}
