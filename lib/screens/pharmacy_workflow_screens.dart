import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medical_record.dart';
import '../services/medical_record_service.dart';
import '../widgets/system_state_widgets.dart';

/// 1. PHARMACY DISCOVERY SCREEN (Phase 1O)
class PharmacyDiscoveryScreen extends StatefulWidget {
  final MedicalRecordService? recordService;

  const PharmacyDiscoveryScreen({super.key, this.recordService});

  @override
  State<PharmacyDiscoveryScreen> createState() =>
      _PharmacyDiscoveryScreenState();
}

class _PharmacyDiscoveryScreenState extends State<PharmacyDiscoveryScreen> {
  late final MedicalRecordService _recordService;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _recordService = widget.recordService ?? MedicalRecordService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Pharmacies',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search pharmacy',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xFF0B7A6E)),
                filled: true,
                fillColor: const Color(0xFFF8FCFA),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Pharmacy Stream
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _recordService.streamAvailablePharmacies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(
                    message: 'Searching available pharmacies...',
                  );
                }

                if (snapshot.hasError) {
                  return AppErrorState(
                    title: 'Unable to load pharmacies.',
                    message: 'Please check your connection and try again.',
                    onRetry: () => setState(() {}),
                  );
                }

                final allPharmacies = snapshot.data ?? [];
                final filtered = allPharmacies.where((p) {
                  final name = (p['name'] ?? p['pharmacyName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final address = (p['address'] ?? '').toString().toLowerCase();
                  return _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase()) ||
                      address.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.local_pharmacy_outlined,
                    title: 'Pharmacy discovery is currently unavailable.',
                    message:
                        'Available partner pharmacies will appear here when registered on the MediSimbio provider network.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return _PharmacyCardTile(
                      pharmacyData: p,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PharmacyDiscoveryDetailsScreen(pharmacyData: p),
                          ),
                        );
                      },
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
}

class _PharmacyCardTile extends StatelessWidget {
  final Map<String, dynamic> pharmacyData;
  final VoidCallback onTap;

  const _PharmacyCardTile({
    required this.pharmacyData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (pharmacyData['name'] ?? pharmacyData['pharmacyName'] ?? 'Pharmacy')
        .toString();
    final address = (pharmacyData['address'] ?? 'Authorized Location').toString();
    final distance = pharmacyData['distance']?.toString();
    final type = (pharmacyData['type'] ?? 'Retail Pharmacy').toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_pharmacy_outlined,
                    color: Colors.deepOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173330),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0B7A6E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (distance != null && distance.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              address,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.storefront_rounded, size: 16),
                label: const Text(
                  'View Pharmacy',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2. PHARMACY DETAILS SCREEN (Phase 1O)
class PharmacyDiscoveryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pharmacyData;

  const PharmacyDiscoveryDetailsScreen({
    super.key,
    required this.pharmacyData,
  });

  @override
  Widget build(BuildContext context) {
    final name = (pharmacyData['name'] ?? pharmacyData['pharmacyName'] ?? 'Pharmacy')
        .toString();
    final address = (pharmacyData['address'] ?? 'Authorized Location').toString();
    final phone = pharmacyData['phone']?.toString();
    final operatingHours = pharmacyData['operatingHours']?.toString();
    final status = (pharmacyData['status'] ?? 'OPEN').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_pharmacy_outlined,
                          color: Colors.deepOrange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173330),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: $status',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0B7A6E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: address),
                  if (phone != null && phone.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.phone_outlined, label: 'Contact', value: phone),
                  ],
                  if (operatingHours != null && operatingHours.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.access_time_rounded, label: 'Operating Hours', value: operatingHours),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectPrescriptionScreen(
                        pharmacyData: pharmacyData,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Send Prescription',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. SELECT PRESCRIPTION SCREEN (Phase 1O)
class SelectPrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacyData;
  final MedicalRecordService? recordService;

  const SelectPrescriptionScreen({
    super.key,
    required this.pharmacyData,
    this.recordService,
  });

  @override
  State<SelectPrescriptionScreen> createState() =>
      _SelectPrescriptionScreenState();
}

class _SelectPrescriptionScreenState extends State<SelectPrescriptionScreen> {
  late final MedicalRecordService _recordService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _recordService = widget.recordService ?? MedicalRecordService();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Select Prescription',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: _currentUserId.isEmpty
          ? const AppEmptyState(
              icon: Icons.lock_outline,
              title: 'Authentication required.',
              message: 'Please log in to access your prescriptions.',
            )
          : StreamBuilder<List<PrescriptionRecord>>(
              stream: _recordService.streamPrescriptions(_currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(
                    message: 'Loading doctor-issued prescriptions...',
                  );
                }

                if (snapshot.hasError) {
                  return AppErrorState(
                    title: 'Unable to load prescriptions.',
                    message: 'Please check your connection and try again.',
                    onRetry: () => setState(() {}),
                  );
                }

                final prescriptions = snapshot.data ?? [];
                // Eligibility filtering (Section 7): Only non-dispensed active prescriptions belonging to patient
                final eligible = prescriptions.where((p) {
                  final status = (p.status ?? 'ACTIVE').toUpperCase();
                  return status != 'DISPENSED' && status != 'EXPIRED';
                }).toList();

                if (eligible.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.assignment_late_outlined,
                    title: 'No prescriptions available to send.',
                    message:
                        'You have no active doctor-issued prescriptions eligible for pharmacy submission.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: eligible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final prescription = eligible[index];
                    return _PrescriptionSelectionCard(
                      prescription: prescription,
                      onSelect: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConfirmSendPrescriptionScreen(
                              pharmacyData: widget.pharmacyData,
                              prescription: prescription,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _PrescriptionSelectionCard extends StatelessWidget {
  final PrescriptionRecord prescription;
  final VoidCallback onSelect;

  const _PrescriptionSelectionCard({
    required this.prescription,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final doctor = prescription.doctorName ?? 'Authorized Doctor';
    final dateStr = prescription.prescriptionDate != null
        ? '${prescription.prescriptionDate!.day}/${prescription.prescriptionDate!.month}/${prescription.prescriptionDate!.year}'
        : 'Recent Prescription';
    final medicineName = prescription.medicineName;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B7A6E).withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
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
                        doctor,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173330),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Medicine: $medicineName',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Select Prescription',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. CONFIRM SEND PRESCRIPTION SCREEN (Phase 1O)
class ConfirmSendPrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacyData;
  final PrescriptionRecord prescription;
  final MedicalRecordService? recordService;

  const ConfirmSendPrescriptionScreen({
    super.key,
    required this.pharmacyData,
    required this.prescription,
    this.recordService,
  });

  @override
  State<ConfirmSendPrescriptionScreen> createState() =>
      _ConfirmSendPrescriptionScreenState();
}

class _ConfirmSendPrescriptionScreenState
    extends State<ConfirmSendPrescriptionScreen> {
  late final MedicalRecordService _recordService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _recordService = widget.recordService ?? MedicalRecordService();
  }

  Future<void> _handleConfirmSend() async {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    setState(() => _isSubmitting = true);

    final pharmacyName = (widget.pharmacyData['name'] ??
            widget.pharmacyData['pharmacyName'] ??
            'Partner Pharmacy')
        .toString();
    final pharmacyId = widget.pharmacyData['id']?.toString();

    final now = DateTime.now();

    final recordToSubmit = PharmacyRecord(
      id: '',
      userId: userId,
      prescriptionId: widget.prescription.id,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      doctorName: widget.prescription.doctorName,
      status: 'PENDING',
      medicines: widget.prescription.medicines,
      orderDate: now,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final newDocId =
          await _recordService.createPharmacyRecord(userId, recordToSubmit);

      final createdRecord = PharmacyRecord(
        id: newDocId,
        userId: userId,
        prescriptionId: widget.prescription.id,
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        doctorName: widget.prescription.doctorName,
        status: 'PENDING',
        medicines: widget.prescription.medicines,
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionSentScreen(pharmacyRecord: createdRecord),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to send the prescription. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyName = (widget.pharmacyData['name'] ??
            widget.pharmacyData['pharmacyName'] ??
            'Partner Pharmacy')
        .toString();
    final doctor = widget.prescription.doctorName ?? 'Authorized Doctor';
    final medicineName = widget.prescription.medicineName;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Confirm Submission',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Prescription to Pharmacy?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please confirm details before submitting to the pharmacy network.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.storefront_rounded,
                    label: 'Target Pharmacy',
                    value: pharmacyName,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Prescribing Doctor',
                    value: doctor,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.medication_rounded,
                    label: 'Prescribed Medicine',
                    value: medicineName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF9CA3AF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleConfirmSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B7A6E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send Prescription',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. PRESCRIPTION SENT SCREEN (Phase 1O)
class PrescriptionSentScreen extends StatelessWidget {
  final PharmacyRecord pharmacyRecord;

  const PrescriptionSentScreen({
    super.key,
    required this.pharmacyRecord,
  });

  @override
  Widget build(BuildContext context) {
    final pharmacyName =
        pharmacyRecord.pharmacyName ?? 'Authorized Pharmacy';
    final refId = pharmacyRecord.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Prescription Sent',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 54,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prescription Sent',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your prescription has been sent to:\n$pharmacyName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _MetadataRow(label: 'Reference ID', value: refId),
                  const SizedBox(height: 8),
                  const _MetadataRow(label: 'Status', value: 'PENDING'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PharmacyStatusScreen(record: pharmacyRecord),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.timeline_rounded, size: 18),
                label: const Text(
                  'View Status',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0B7A6E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Color(0xFF0B7A6E),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

/// 6. PHARMACY STATUS SCREEN (Phase 1O)
class PharmacyStatusScreen extends StatelessWidget {
  final PharmacyRecord record;

  const PharmacyStatusScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final pharmacyName = record.pharmacyName ?? 'Authorized Pharmacy';
    final status = record.status.toUpperCase();
    final doctor = record.doctorName ?? 'Prescribing Doctor';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Pharmacy Status',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prescribed by $doctor',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text(
                        'Current Status: ',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusTextColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Dispensing Lifecycle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _TimelineStep(
                    title: 'Prescription Sent',
                    subtitle: record.orderDate != null
                        ? 'Submitted on ${_formatDate(record.orderDate!)}'
                        : 'Submitted to pharmacy network',
                    isCompleted: true,
                    isCurrent: status == 'PENDING',
                  ),
                  const Divider(height: 24),
                  _TimelineStep(
                    title: 'Verification',
                    subtitle: record.verificationDate != null
                        ? 'Verified on ${_formatDate(record.verificationDate!)}'
                        : 'Pharmacy verifying prescription & inventory',
                    isCompleted: status == 'VERIFIED' || status == 'DISPENSED',
                    isCurrent: status == 'VERIFIED',
                  ),
                  const Divider(height: 24),
                  _TimelineStep(
                    title: 'Dispensing',
                    subtitle: record.dispensedDate != null
                        ? 'Dispensed on ${_formatDate(record.dispensedDate!)}'
                        : 'Medication ready or handed over',
                    isCompleted: status == 'DISPENSED',
                    isCurrent: status == 'DISPENSED',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'DISPENSED':
        return const Color(0xFFD1FAE5);
      case 'VERIFIED':
        return const Color(0xFFE0F2FE);
      case 'PENDING':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'DISPENSED':
        return const Color(0xFF065F46);
      case 'VERIFIED':
        return const Color(0xFF0369A1);
      case 'PENDING':
      default:
        return const Color(0xFFB45309);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0B7A6E)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF173330),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173330),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isCompleted
              ? Icons.check_circle_rounded
              : (isCurrent
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded),
          color: isCompleted || isCurrent
              ? const Color(0xFF0B7A6E)
              : const Color(0xFFD1D5DB),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCompleted || isCurrent
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isCompleted || isCurrent
                      ? const Color(0xFF173330)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
