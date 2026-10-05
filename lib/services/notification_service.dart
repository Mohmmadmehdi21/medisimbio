import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_notification.dart';

/// Service managing patient notification records and state in Firestore.
class NotificationService {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  NotificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  /// Gets authenticated patient UID safely.
  String? get currentPatientId {
    if (_customAuth == null && FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    return _auth.currentUser?.uid;
  }

  /// Helper to reference patient notifications subcollection in Firestore.
  CollectionReference<Map<String, dynamic>> _notificationsCollection(
      String patientId) {
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('notifications');
  }

  /// Streams notifications for the authenticated patient with optional category filter.
  Stream<List<AppNotification>> streamNotifications(
    String patientId, {
    String? category,
  }) {
    if (patientId.isEmpty) return Stream.value([]);

    Query<Map<String, dynamic>> query = _notificationsCollection(patientId);

    if (category != null &&
        category.isNotEmpty &&
        category.toUpperCase() != 'ALL') {
      query = query.where('category', isEqualTo: category.toUpperCase());
    }

    return query.snapshots().map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestoreDoc(doc))
          .toList();

      // Sort newest notifications first using actual createdAt timestamp
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  /// Streams the unread notification count for the authenticated patient.
  Stream<int> streamUnreadCount(String patientId) {
    if (patientId.isEmpty) return Stream.value(0);

    return _notificationsCollection(patientId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Marks a specific notification as read in Firestore.
  Future<void> markAsRead(String patientId, String notificationId) async {
    if (patientId.isEmpty || notificationId.isEmpty) return;

    try {
      await _notificationsCollection(patientId).doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Unable to update notification read status.');
    }
  }

  /// Marks all unread notifications for the patient as read in Firestore.
  Future<void> markAllAsRead(String patientId) async {
    if (patientId.isEmpty) return;

    try {
      final unreadSnapshot = await _notificationsCollection(patientId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadSnapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      final nowTimestamp = FieldValue.serverTimestamp();

      for (final doc in unreadSnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': nowTimestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Unable to update all notifications as read.');
    }
  }
}
