import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../services/medical_record_service.dart';
import 'care_screens.dart';
import 'medical_records_screens.dart';
import 'privacy_consent_screens.dart';
import 'emergency_screens.dart';
import 'profile_sub_screens.dart';

/// Screen title: Notifications
/// Displays real notifications belonging to the authenticated patient.
class NotificationsScreen extends StatefulWidget {
  final NotificationService? notificationService;
  final MedicalRecordService? recordService;

  const NotificationsScreen({
    super.key,
    this.notificationService,
    this.recordService,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationService _notificationService;
  late final MedicalRecordService _recordService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _notificationService = widget.notificationService ?? NotificationService();
    _recordService = widget.recordService ?? MedicalRecordService();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF0B7A6E)),
            tooltip: 'Mark all as read',
            onPressed: () => _handleMarkAllAsRead(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Tabs
          _buildCategoryFilterRow(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Notifications Content Area
          Expanded(
            child: _currentUserId.isEmpty
                ? _buildEmptyState('No notifications yet')
                : StreamBuilder<List<AppNotification>>(
                    stream: _notificationService.streamNotifications(
                      _currentUserId,
                      category: _selectedCategory,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B7A6E),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState(context);
                      }

                      final notifications = snapshot.data ?? [];

                      if (notifications.isEmpty) {
                        return _buildEmptyState(
                          _selectedCategory == 'ALL'
                              ? 'No notifications yet'
                              : 'No ${NotificationCategory.toDisplayName(_selectedCategory)} notifications',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () =>
                                _handleNotificationTap(context, notification),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds category filter tab chips.
  Widget _buildCategoryFilterRow() {
    final categories = [
      {'key': 'ALL', 'label': 'All'},
      {'key': NotificationCategory.appointment, 'label': 'Appointment'},
      {'key': NotificationCategory.prescription, 'label': 'Prescription'},
      {'key': NotificationCategory.lab, 'label': 'Lab'},
      {'key': NotificationCategory.consent, 'label': 'Consent'},
      {'key': NotificationCategory.emergency, 'label': 'Emergency'},
      {'key': NotificationCategory.system, 'label': 'System'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                cat['label']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF0B7A6E)
                      : const Color(0xFF4B5563),
                ),
              ),
              selectedColor: const Color(0xFF0B7A6E).withAlpha(30),
              backgroundColor: Colors.white,
              checkmarkColor: const Color(0xFF0B7A6E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0B7A6E)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = cat['key']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Empty state UI widget.
  Widget _buildEmptyState(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B7A6E).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 48,
                color: Color(0xFF0B7A6E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Real notifications will appear here when medical or security events occur.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state UI widget.
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load notifications.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles marking all notifications as read.
  Future<void> _handleMarkAllAsRead(BuildContext context) async {
    if (_currentUserId.isEmpty) return;

    try {
      await _notificationService.markAllAsRead(_currentUserId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read.'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF0B7A6E),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update notifications.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Handles notification selection, marking as read, and deep-linking safely.
  Future<void> _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) async {
    // 1. Mark as read in backend
    if (!notification.isRead && _currentUserId.isNotEmpty) {
      try {
        await _notificationService.markAsRead(
          _currentUserId,
          notification.notificationId,
        );
      } catch (_) {
        // Fail silently on mark read network failure, continue to navigation safely
      }
    }

    if (!context.mounted) return;

    // 2. Perform deep-link navigation safely
    final category = notification.category.toUpperCase();
    final refId = notification.referenceId;

    try {
      switch (category) {
        case NotificationCategory.appointment:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyAppointmentsScreen(),
            ),
          );
          break;

        case NotificationCategory.prescription:
          if (refId != null && refId.isNotEmpty) {
            // Attempt to load prescription record reference safely
            final prescriptions = await _recordService
                .streamPrescriptions(_currentUserId)
                .first;
            final matched = prescriptions
                .where((p) => p.id == refId)
                .toList();

            if (context.mounted) {
              if (matched.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PrescriptionDetailsScreen(record: matched.first),
                  ),
                );
              } else {
                _showUnavailableMessage(context);
              }
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrescriptionsScreen(),
              ),
            );
          }
          break;

        case NotificationCategory.lab:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LabReportsScreen(),
            ),
          );
          break;

        case NotificationCategory.consent:
          if (refId != null && refId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DataAccessScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrivacyConsentScreen(),
              ),
            );
          }
          break;

        case NotificationCategory.emergency:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmergencyCareScreen(),
            ),
          );
          break;

        case NotificationCategory.system:
        default:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PreferencesScreen(),
            ),
          );
          break;
      }
    } catch (_) {
      if (context.mounted) {
        _showUnavailableMessage(context);
      }
    }
  }

  void _showUnavailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This information is no longer available.'),
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

/// Notification item card component.
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = notification.category.toUpperCase();
    final isUnread = !notification.isRead;

    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (category) {
      case NotificationCategory.appointment:
        iconData = Icons.calendar_today_rounded;
        iconColor = const Color(0xFF0B7A6E);
        bgColor = const Color(0xFFE6F4F1);
        break;

      case NotificationCategory.prescription:
        iconData = Icons.medication_rounded;
        iconColor = const Color(0xFF0284C7);
        bgColor = const Color(0xFFE0F2FE);
        break;

      case NotificationCategory.lab:
        iconData = Icons.science_rounded;
        iconColor = const Color(0xFF7C3AED);
        bgColor = const Color(0xFFF3E8FF);
        break;

      case NotificationCategory.consent:
        iconData = Icons.verified_user_rounded;
        iconColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFEF3C7);
        break;

      case NotificationCategory.emergency:
        iconData = Icons.emergency_rounded;
        iconColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEE2E2);
        break;

      case NotificationCategory.system:
      default:
        iconData = Icons.info_outline_rounded;
        iconColor = const Color(0xFF4B5563);
        bgColor = const Color(0xFFF3F4F6);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isUnread
            ? const Color(0xFFF0FDF9)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF0B7A6E).withAlpha(80)
              : const Color(0xFFE5E7EB),
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: const Color(0xFF173330),
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0B7A6E),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (notification.message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        notification.timeAgo(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
