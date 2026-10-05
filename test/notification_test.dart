import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/app_notification.dart';
import 'package:medisimbio_ui/services/notification_service.dart';

void main() {
  group('Phase 1M — Notification Model & Category Unit Tests', () {
    test('AppNotification constructor & fields serialization', () {
      final now = DateTime.now();
      final notification = AppNotification(
        notificationId: 'NOTIF-1001',
        patientId: 'patient_user_77',
        category: NotificationCategory.appointment,
        title: 'Appointment Confirmed',
        message: 'Your appointment has been scheduled.',
        createdAt: now,
        isRead: false,
        actionType: 'OPEN_APPOINTMENT',
        referenceId: 'APT-99001',
      );

      expect(notification.notificationId, equals('NOTIF-1001'));
      expect(notification.patientId, equals('patient_user_77'));
      expect(notification.category, equals('APPOINTMENT'));
      expect(notification.title, equals('Appointment Confirmed'));
      expect(notification.isRead, isFalse);
      expect(notification.referenceId, equals('APT-99001'));
      expect(notification.isExpired, isFalse);

      final map = notification.toMap();
      expect(map['notificationId'], equals('NOTIF-1001'));
      expect(map['patientId'], equals('patient_user_77'));
      expect(map['category'], equals('APPOINTMENT'));
      expect(map['isRead'], isFalse);

      final reconstructed = AppNotification.fromMap(map, 'NOTIF-1001');
      expect(reconstructed.notificationId, equals('NOTIF-1001'));
      expect(reconstructed.patientId, equals('patient_user_77'));
      expect(reconstructed.category, equals('APPOINTMENT'));
    });

    test('NotificationCategory enum values & display names', () {
      expect(NotificationCategory.values, containsAll([
        'APPOINTMENT',
        'PRESCRIPTION',
        'LAB',
        'CONSENT',
        'EMERGENCY',
        'SYSTEM',
      ]));

      expect(NotificationCategory.toDisplayName('APPOINTMENT'), equals('Appointment'));
      expect(NotificationCategory.toDisplayName('PRESCRIPTION'), equals('Prescription'));
      expect(NotificationCategory.toDisplayName('LAB'), equals('Lab'));
      expect(NotificationCategory.toDisplayName('CONSENT'), equals('Consent'));
      expect(NotificationCategory.toDisplayName('EMERGENCY'), equals('Emergency'));
      expect(NotificationCategory.toDisplayName('SYSTEM'), equals('System'));
      expect(NotificationCategory.toDisplayName('UNKNOWN'), equals('General'));
    });

    test('Relative timestamp formatting (timeAgo)', () {
      final now = DateTime.now();
      
      final justNowNotif = AppNotification(
        notificationId: 'N1',
        patientId: 'P1',
        category: NotificationCategory.system,
        title: 'Title',
        message: 'Msg',
        createdAt: now.subtract(const Duration(seconds: 15)),
      );
      expect(justNowNotif.timeAgo(), equals('Just now'));

      final minsAgoNotif = AppNotification(
        notificationId: 'N2',
        patientId: 'P1',
        category: NotificationCategory.prescription,
        title: 'Title',
        message: 'Msg',
        createdAt: now.subtract(const Duration(minutes: 12)),
      );
      expect(minsAgoNotif.timeAgo(), equals('12 min ago'));
    });

    test('Expiration evaluate isExpired', () {
      final pastExpiration = DateTime.now().subtract(const Duration(hours: 1));
      final notification = AppNotification(
        notificationId: 'N-EXP',
        patientId: 'P1',
        category: NotificationCategory.consent,
        title: 'Expired Access',
        message: 'Access request has expired.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: pastExpiration,
      );

      expect(notification.isExpired, isTrue);
    });

    test('NotificationService handles empty patient ID safely', () async {
      final service = NotificationService();
      
      final notificationsStream = service.streamNotifications('');
      final notifications = await notificationsStream.first;
      expect(notifications, isEmpty);

      final unreadCountStream = service.streamUnreadCount('');
      final count = await unreadCountStream.first;
      expect(count, equals(0));
    });
  });
}
