import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/consent_record.dart';
import 'package:medisimbio_ui/services/consent_service.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';

/// Formats DateTime into readable string (e.g. "5 Oct 2026, 4:30 PM")
String _formatDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final monthStr = months[dt.month - 1];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '${dt.day} $monthStr ${dt.year}, $hour:$minute $period';
}

/// Entry Screen: Privacy & Consent
class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ConsentService _consentService = ConsentService();

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Privacy & Consent',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: user == null
          ? const Center(child: Text('No authenticated user session found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER BANNER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0B7A6E),
                          const Color(0xFF0B7A6E).withAlpha(216),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B7A6E).withAlpha(50),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Access Control',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You control who can access your healthcare information.',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(230),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Consent Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // OPTIONS LIST
                  StreamBuilder<List<ConsentRecord>>(
                    stream: _consentService.streamPendingRequests(user.uid),
                    builder: (context, pendingSnapshot) {
                      final pendingCount = pendingSnapshot.data?.length ?? 0;

                      return StreamBuilder<List<ConsentRecord>>(
                        stream: _consentService.streamActiveConsents(user.uid),
                        builder: (context, activeSnapshot) {
                          final activeCount = activeSnapshot.data?.length ?? 0;

                          return Column(
                            children: [
                              _MenuOptionTile(
                                icon: Icons.mark_email_unread_outlined,
                                iconColor: Colors.amber.shade800,
                                title: 'Access Requests',
                                subtitle:
                                    'Review and decide on incoming provider access requests',
                                badgeCount: pendingCount,
                                badgeColor: Colors.amber.shade700,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DataAccessScreen(
                                        initialTabIndex: 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _MenuOptionTile(
                                icon: Icons.verified_user_outlined,
                                iconColor: const Color(0xFF0B7A6E),
                                title: 'Active Access',
                                subtitle:
                                    'View and manage permissions currently granted to providers',
                                badgeCount: activeCount,
                                badgeColor: const Color(0xFF0B7A6E),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DataAccessScreen(
                                        initialTabIndex: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _MenuOptionTile(
                                icon: Icons.history_toggle_off,
                                iconColor: Colors.blueGrey,
                                title: 'Expired Access',
                                subtitle:
                                    'Review past consent grants whose duration has elapsed',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DataAccessScreen(
                                        initialTabIndex: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _MenuOptionTile(
                                icon: Icons.manage_history_outlined,
                                iconColor: Colors.indigo,
                                title: 'Access History',
                                subtitle:
                                    'Complete audit log of requested, allowed, denied, and revoked access',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DataAccessScreen(
                                        initialTabIndex: 3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // PRIVACY ASSURANCE CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EEEA)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Color(0xFF0B7A6E),
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explicit Patient Authority',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'No clinic or doctor can access your health records without your explicit approval. You can revoke access at any time.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5A716E),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MenuOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int badgeCount;
  final Color badgeColor;
  final VoidCallback onTap;

  const _MenuOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeCount = 0,
    this.badgeColor = const Color(0xFF0B7A6E),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EEEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                      ),
                      if (badgeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A716E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: Color(0xFF8C9E9A),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data Access Tabbed Screen: Access Requests, Active Access, Expired Access, Access History
class DataAccessScreen extends StatefulWidget {
  final int initialTabIndex;

  const DataAccessScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<DataAccessScreen> createState() => _DataAccessScreenState();
}

class _DataAccessScreenState extends State<DataAccessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();
  final ConsentService _consentService = ConsentService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Data Access',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0B7A6E),
          unselectedLabelColor: const Color(0xFF5A716E),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorColor: const Color(0xFF0B7A6E),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('No authenticated user found.'))
          : TabBarView(
              controller: _tabController,
              children: [
                _AccessRequestsTab(patientId: user.uid, consentService: _consentService),
                _ActiveAccessTab(patientId: user.uid, consentService: _consentService),
                _ExpiredAccessTab(patientId: user.uid, consentService: _consentService),
                _AccessHistoryTab(patientId: user.uid, consentService: _consentService),
              ],
            ),
    );
  }
}

/// Tab 1: Pending Access Requests
class _AccessRequestsTab extends StatelessWidget {
  final String patientId;
  final ConsentService consentService;

  const _AccessRequestsTab({
    required this.patientId,
    required this.consentService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConsentRecord>>(
      stream: consentService.streamPendingRequests(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
          );
        }

        if (snapshot.hasError) {
          return const _ErrorStateWidget(
            message: 'Unable to load access requests.',
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.mark_email_read_outlined,
            title: 'No Access Requests',
            message:
                'Healthcare providers requesting access to your medical records will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final record = requests[index];
            return _ConsentRequestCard(
              record: record,
              consentService: consentService,
            );
          },
        );
      },
    );
  }
}

/// Tab 2: Active Access Grants
class _ActiveAccessTab extends StatelessWidget {
  final String patientId;
  final ConsentService consentService;

  const _ActiveAccessTab({
    required this.patientId,
    required this.consentService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConsentRecord>>(
      stream: consentService.streamActiveConsents(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
          );
        }

        if (snapshot.hasError) {
          return const _ErrorStateWidget(
            message: 'Unable to load active access permissions.',
          );
        }

        final activeRecords = snapshot.data ?? [];

        if (activeRecords.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.verified_user_outlined,
            title: 'No Active Access',
            message:
                'You have not granted active data access to any provider or clinic.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: activeRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final record = activeRecords[index];
            return _ActiveConsentCard(
              record: record,
              consentService: consentService,
            );
          },
        );
      },
    );
  }
}

/// Tab 3: Expired Access Grants
class _ExpiredAccessTab extends StatelessWidget {
  final String patientId;
  final ConsentService consentService;

  const _ExpiredAccessTab({
    required this.patientId,
    required this.consentService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConsentRecord>>(
      stream: consentService.streamExpiredConsents(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
          );
        }

        if (snapshot.hasError) {
          return const _ErrorStateWidget(
            message: 'Unable to load expired access records.',
          );
        }

        final expiredRecords = snapshot.data ?? [];

        if (expiredRecords.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.history_toggle_off,
            title: 'No Expired Access',
            message: 'There are no expired access permissions.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: expiredRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final record = expiredRecords[index];
            return _ExpiredConsentCard(record: record);
          },
        );
      },
    );
  }
}

/// Tab 4: Access History / Audit Log
class _AccessHistoryTab extends StatelessWidget {
  final String patientId;
  final ConsentService consentService;

  const _AccessHistoryTab({
    required this.patientId,
    required this.consentService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConsentRecord>>(
      stream: consentService.streamConsentHistory(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
          );
        }

        if (snapshot.hasError) {
          return const _ErrorStateWidget(
            message: 'Unable to load access history.',
          );
        }

        final historyRecords = snapshot.data ?? [];

        if (historyRecords.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.manage_history_outlined,
            title: 'No Access History',
            message: 'Your consent activity history will be recorded here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: historyRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = historyRecords[index];
            return _HistoryConsentTile(record: record);
          },
        );
      },
    );
  }
}

/// Card for Pending Request with Allow/Deny Actions
class _ConsentRequestCard extends StatefulWidget {
  final ConsentRecord record;
  final ConsentService consentService;

  const _ConsentRequestCard({
    required this.record,
    required this.consentService,
  });

  @override
  State<_ConsentRequestCard> createState() => _ConsentRequestCardState();
}

class _ConsentRequestCardState extends State<_ConsentRequestCard> {
  bool _isProcessing = false;

  Future<void> _handleAllow() async {
    setState(() => _isProcessing = true);
    try {
      await widget.consentService.allowConsent(
        patientId: widget.record.patientId,
        accessRequestId: widget.record.accessRequestId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Access granted to ${widget.record.requesterName} successfully.',
          ),
          backgroundColor: const Color(0xFF0B7A6E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to grant access. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _confirmAndDeny() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Deny Access?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173330)),
        ),
        content: Text(
          '${widget.record.requesterName} will not be able to access the requested information.',
          style: const TextStyle(color: Color(0xFF5A716E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF5A716E))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Deny Access'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await widget.consentService.denyConsent(
        patientId: widget.record.patientId,
        accessRequestId: widget.record.accessRequestId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access request denied.'),
          backgroundColor: Color(0xFF5A716E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to deny access. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final orgName = record.organizationName ?? record.requesterName;
    final durationText = record.durationHours != null
        ? '${record.durationHours} Hours'
        : 'Session Access';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.shade700.withAlpha(75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // REQUESTER TITLE & BADGE
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.amber.shade800.withAlpha(30),
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: Colors.amber.shade800,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    if (record.organizationName != null &&
                        record.requesterName != record.organizationName)
                      Text(
                        'Requested by: ${record.requesterName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                  ],
                ),
              ),
              const _StatusBadge(status: ConsentStatus.pending),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2EEEA)),
          const SizedBox(height: 14),

          // REQUESTED SCOPES
          const Text(
            'Requested Access:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: record.requestedScopes.map((scope) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF0B7A6E),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ConsentScope.getLabel(scope),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF173330),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // DURATION & TIME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration: $durationText',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B7A6E),
                ),
              ),
              Text(
                _formatDateTime(record.requestedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5A716E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : _confirmAndDeny,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Deny', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Allow', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card for Active Consent with Revoke Action & Details
class _ActiveConsentCard extends StatefulWidget {
  final ConsentRecord record;
  final ConsentService consentService;

  const _ActiveConsentCard({
    required this.record,
    required this.consentService,
  });

  @override
  State<_ActiveConsentCard> createState() => _ActiveConsentCardState();
}

class _ActiveConsentCardState extends State<_ActiveConsentCard> {
  bool _isRevoking = false;

  Future<void> _confirmAndRevoke() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Revoke Access?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173330)),
        ),
        content: Text(
          '${widget.record.requesterName} will no longer have access to the selected information.',
          style: const TextStyle(color: Color(0xFF5A716E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF5A716E))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRevoking = true);
    try {
      await widget.consentService.revokeConsent(
        patientId: widget.record.patientId,
        accessRequestId: widget.record.accessRequestId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data access revoked successfully.'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to revoke access. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRevoking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final orgName = record.organizationName ?? record.requesterName;
    final scopes = record.grantedScopes.isNotEmpty
        ? record.grantedScopes
        : record.requestedScopes;

    final expiryText = record.expiresAt != null
        ? _formatDateTime(record.expiresAt!)
        : 'No Expiry Set';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0B7A6E).withAlpha(75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0B7A6E).withAlpha(30),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF0B7A6E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    Text(
                      'Granted: ${record.grantedAt != null ? _formatDateTime(record.grantedAt!) : 'Active'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A716E),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: record.effectiveStatus),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2EEEA)),
          const SizedBox(height: 14),

          // SCOPES
          const Text(
            'Access Granted For:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: scopes.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B7A6E).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ConsentScope.getLabel(s),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B7A6E),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // EXPIRY DATE
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF5A716E)),
              const SizedBox(width: 6),
              Text(
                'Expires: $expiryText',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF173330),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DataAccessDetailsScreen(
                          record: record,
                          consentService: widget.consentService,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF173330),
                    side: const BorderSide(color: Color(0xFFD9E4E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRevoking ? null : _confirmAndRevoke,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isRevoking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Revoke Access', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card for Expired Consent Grant
class _ExpiredConsentCard extends StatelessWidget {
  final ConsentRecord record;

  const _ExpiredConsentCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final orgName = record.organizationName ?? record.requesterName;
    final scopes = record.grantedScopes.isNotEmpty
        ? record.grantedScopes
        : record.requestedScopes;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey.withAlpha(30),
                child: const Icon(
                  Icons.history_toggle_off,
                  color: Colors.blueGrey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    Text(
                      'Expired: ${record.expiresAt != null ? _formatDateTime(record.expiresAt!) : 'Past Expiry'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A716E),
                      ),
                    ),
                  ],
                ),
              ),
              const _StatusBadge(status: ConsentStatus.expired),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: scopes.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ConsentScope.getLabel(s),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// History Audit Log Tile
class _HistoryConsentTile extends StatelessWidget {
  final ConsentRecord record;

  const _HistoryConsentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final orgName = record.organizationName ?? record.requesterName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Row(
        children: [
          _StatusIconCircle(status: record.effectiveStatus),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orgName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.requestedScopes.map(ConsentScope.getLabel).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A716E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(record.updatedAt ?? record.requestedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8C9E9A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(status: record.effectiveStatus),
        ],
      ),
    );
  }
}

/// Full Details Screen for a Data Access Consent Record
class DataAccessDetailsScreen extends StatefulWidget {
  final ConsentRecord record;
  final ConsentService consentService;

  const DataAccessDetailsScreen({
    super.key,
    required this.record,
    required this.consentService,
  });

  @override
  State<DataAccessDetailsScreen> createState() => _DataAccessDetailsScreenState();
}

class _DataAccessDetailsScreenState extends State<DataAccessDetailsScreen> {
  bool _isActionInProgress = false;

  Future<void> _handleRevoke() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Revoke Access?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173330)),
        ),
        content: Text(
          '${widget.record.requesterName} will no longer have access to your healthcare data.',
          style: const TextStyle(color: Color(0xFF5A716E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF5A716E))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionInProgress = true);
    try {
      await widget.consentService.revokeConsent(
        patientId: widget.record.patientId,
        accessRequestId: widget.record.accessRequestId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access revoked successfully.'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to revoke access. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final status = record.effectiveStatus;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Data Access Details',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROVIDER INFORMATION CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2EEEA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF0B7A6E).withAlpha(30),
                        child: const Icon(
                          Icons.local_hospital_outlined,
                          color: Color(0xFF0B7A6E),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.organizationName ?? record.requesterName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173330),
                              ),
                            ),
                            Text(
                              'Type: ${record.requesterType}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5A716E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Status:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF173330),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // REQUESTED SCOPES CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2EEEA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Categories (Scopes)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...record.requestedScopes.map((scope) {
                    final isGranted = record.grantedScopes.contains(scope) ||
                        (record.grantedScopes.isEmpty &&
                            status == ConsentStatus.granted);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            isGranted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isGranted
                                ? const Color(0xFF0B7A6E)
                                : const Color(0xFF8C9E9A),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            ConsentScope.getLabel(scope),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isGranted
                                  ? const Color(0xFF173330)
                                  : const Color(0xFF8C9E9A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TIMESTAMPS & LIFECYCLE DETAILS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2EEEA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consent Lifecycle Timestamps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Requested At',
                    value: _formatDateTime(record.requestedAt),
                  ),
                  if (record.durationHours != null)
                    _DetailRow(
                      label: 'Requested Duration',
                      value: '${record.durationHours} Hours',
                    ),
                  if (record.grantedAt != null)
                    _DetailRow(
                      label: 'Granted At',
                      value: _formatDateTime(record.grantedAt!),
                    ),
                  if (record.expiresAt != null)
                    _DetailRow(
                      label: 'Expires At',
                      value: _formatDateTime(record.expiresAt!),
                    ),
                  if (record.deniedAt != null)
                    _DetailRow(
                      label: 'Denied At',
                      value: _formatDateTime(record.deniedAt!),
                    ),
                  if (record.revokedAt != null)
                    _DetailRow(
                      label: 'Revoked At',
                      value: _formatDateTime(record.revokedAt!),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // REVOKE ACTION BUTTON (IF ACTIVE)
            if (status == ConsentStatus.granted)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isActionInProgress ? null : _handleRevoke,
                  icon: const Icon(Icons.block, color: Colors.white),
                  label: _isActionInProgress
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Revoke Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173330),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label = status;

    switch (status) {
      case ConsentStatus.granted:
        bg = const Color(0xFFE6F4F1);
        fg = const Color(0xFF0B7A6E);
        icon = Icons.check_circle_outline;
        label = 'Active';
        break;
      case ConsentStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = Colors.amber.shade800;
        icon = Icons.hourglass_top_outlined;
        label = 'Pending';
        break;
      case ConsentStatus.denied:
        bg = const Color(0xFFFEE2E2);
        fg = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Denied';
        break;
      case ConsentStatus.revoked:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        icon = Icons.block_outlined;
        label = 'Revoked';
        break;
      case ConsentStatus.expired:
      default:
        bg = const Color(0xFFF1F5F9);
        fg = Colors.blueGrey;
        icon = Icons.history_toggle_off;
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIconCircle extends StatelessWidget {
  final String status;

  const _StatusIconCircle({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case ConsentStatus.granted:
        color = const Color(0xFF0B7A6E);
        icon = Icons.check_circle_outline;
        break;
      case ConsentStatus.pending:
        color = Colors.amber.shade800;
        icon = Icons.hourglass_top_outlined;
        break;
      case ConsentStatus.denied:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case ConsentStatus.revoked:
        color = const Color(0xFFC2410C);
        icon = Icons.block_outlined;
        break;
      case ConsentStatus.expired:
      default:
        color = Colors.blueGrey;
        icon = Icons.history_toggle_off;
        break;
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withAlpha(30),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B7A6E).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF0B7A6E),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5A716E),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;

  const _ErrorStateWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
