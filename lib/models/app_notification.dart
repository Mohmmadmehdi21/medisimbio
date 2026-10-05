import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification categories as defined in Phase 1M specifications.
class NotificationCategory {
  static const String appointment = 'APPOINTMENT';
  static const String prescription = 'PRESCRIPTION';
  static const String lab = 'LAB';
  static const String consent = 'CONSENT';
  static const String emergency = 'EMERGENCY';
  static const String system = 'SYSTEM';

  static const List<String> values = [
    appointment,
    prescription,
    lab,
    consent,
    emergency,
    system,
  ];

  /// Display string for category UI badge/chip.
  static String toDisplayName(String category) {
    switch (category.toUpperCase()) {
      case appointment:
        return 'Appointment';
      case prescription:
        return 'Prescription';
      case lab:
        return 'Lab';
      case consent:
        return 'Consent';
      case emergency:
        return 'Emergency';
      case system:
        return 'System';
      default:
        return 'General';
    }
  }
}

/// Data model representing a notification event belonging to an authenticated patient.
class AppNotification {
  final String notificationId;
  final String patientId;
  final String category;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? actionType;
  final String? referenceId;
  final String? deepLink;
  final Map<String, dynamic>? metadata;
  final DateTime? expiresAt;

  AppNotification({
    required this.notificationId,
    required this.patientId,
    required this.category,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.actionType,
    this.referenceId,
    this.deepLink,
    this.metadata,
    this.expiresAt,
  });

  /// Factory constructor to deserialize Firestore DocumentSnapshot safely.
  factory AppNotification.fromFirestoreDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification.fromMap(data, doc.id);
  }

  /// Factory constructor to deserialize Map safely.
  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    final createdAtRaw = map['createdAt'];
    DateTime createdAtDate;
    if (createdAtRaw is Timestamp) {
      createdAtDate = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAtDate = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAtDate = DateTime.now();
    }

    final readAtRaw = map['readAt'];
    DateTime? readAtDate;
    if (readAtRaw is Timestamp) {
      readAtDate = readAtRaw.toDate();
    } else if (readAtRaw is String) {
      readAtDate = DateTime.tryParse(readAtRaw);
    }

    final expiresAtRaw = map['expiresAt'];
    DateTime? expiresAtDate;
    if (expiresAtRaw is Timestamp) {
      expiresAtDate = expiresAtRaw.toDate();
    } else if (expiresAtRaw is String) {
      expiresAtDate = DateTime.tryParse(expiresAtRaw);
    }

    return AppNotification(
      notificationId: id,
      patientId: (map['patientId'] as String?) ?? '',
      category:
          ((map['category'] as String?) ?? NotificationCategory.system)
              .toUpperCase(),
      title: (map['title'] as String?) ?? 'Notification',
      message: (map['message'] as String?) ?? '',
      createdAt: createdAtDate,
      isRead: (map['isRead'] as bool?) ?? (readAtDate != null),
      readAt: readAtDate,
      actionType: map['actionType'] as String?,
      referenceId: map['referenceId'] as String?,
      deepLink: map['deepLink'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      expiresAt: expiresAtDate,
    );
  }

  /// Map representation for Firestore persistence.
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'patientId': patientId,
      'category': category,
      'title': title,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'actionType': actionType,
      'referenceId': referenceId,
      'deepLink': deepLink,
      'metadata': metadata,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  /// Check whether the notification has expired.
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Human readable relative timestamp.
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min ago';
    } else if (difference.inHours < 24 && now.day == createdAt.day) {
      final hour = createdAt.hour > 12
          ? createdAt.hour - 12
          : (createdAt.hour == 0 ? 12 : createdAt.hour);
      final amPm = createdAt.hour >= 12 ? 'PM' : 'AM';
      final minStr = createdAt.minute.toString().padLeft(2, '0');
      return 'Today, $hour:$minStr $amPm';
    } else if (difference.inDays < 2) {
      final hour = createdAt.hour > 12
          ? createdAt.hour - 12
          : (createdAt.hour == 0 ? 12 : createdAt.hour);
      final amPm = createdAt.hour >= 12 ? 'PM' : 'AM';
      final minStr = createdAt.minute.toString().padLeft(2, '0');
      return 'Yesterday, $hour:$minStr $amPm';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final monthStr = months[createdAt.month - 1];
      final hour = createdAt.hour > 12
          ? createdAt.hour - 12
          : (createdAt.hour == 0 ? 12 : createdAt.hour);
      final amPm = createdAt.hour >= 12 ? 'PM' : 'AM';
      final minStr = createdAt.minute.toString().padLeft(2, '0');
      return '${createdAt.day} $monthStr, $hour:$minStr $amPm';
    }
  }
}
