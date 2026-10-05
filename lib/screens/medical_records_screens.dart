import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/medical_record.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/medical_record_service.dart';

/// 26. MEDICAL RECORDS DASHBOARD (Phase 1G)
class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      'Longitudinal Health Portfolio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Access your structured prescriptions, diagnostic tests, consultations, clinical notes, and health documents.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A716E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Prescriptions Category Card
                    _RecordCategoryCard(
                      title: 'Prescriptions',
                      subtitle: 'View your prescriptions',
                      icon: Icons.medication_outlined,
                      accentColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrescriptionsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 2. Lab Reports Category Card
                    _RecordCategoryCard(
                      title: 'Lab Reports',
                      subtitle: 'View laboratory reports',
                      icon: Icons.biotech_outlined,
                      accentColor: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LabReportsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 3. Doctor Consultations Category Card
                    _RecordCategoryCard(
                      title: 'Doctor Consultations',
                      subtitle: 'View consultation records',
                      icon: Icons.event_note_outlined,
                      accentColor: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorConsultationsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 4. Clinical Notes Category Card
                    _RecordCategoryCard(
                      title: 'Clinical Notes',
                      subtitle: 'View clinical notes',
                      icon: Icons.description_outlined,
                      accentColor: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClinicalNotesScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 5. Documents Category Card
                    _RecordCategoryCard(
                      title: 'Documents',
                      subtitle: 'View medical documents',
                      icon: Icons.folder_outlined,
                      accentColor: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DocumentsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 6. My Medicines / Pharmacy Category Card (Phase 1J)
                    _RecordCategoryCard(
                      title: 'My Medicines',
                      subtitle: 'View pharmacy & medication dispensing records',
                      icon: Icons.local_pharmacy_outlined,
                      accentColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyMedicinesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _RecordCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2EEEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A716E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFF8C9E9A)),
          ],
        ),
      ),
    );
  }
}

/// 1. PRESCRIPTIONS SCREEN
class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  Key _refreshKey = UniqueKey();

  void _refresh() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final recordService = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: user == null
              ? const _CategoryErrorView(
                  message: 'User authentication required.')
              : StreamBuilder<List<PrescriptionRecord>>(
                  key: _refreshKey,
                  stream: recordService.streamPrescriptions(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategoryLoadingView(
                        message: 'Loading prescriptions...',
                      );
                    }
                    if (snapshot.hasError) {
                      return _CategoryErrorView(
                        message: 'Unable to load prescriptions. Please try again.',
                        onRetry: _refresh,
                      );
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return const _CategoryEmptyView(
                        icon: Icons.medication_outlined,
                        title: 'No Prescriptions Available',
                        message:
                            'Prescriptions issued by your doctor or healthcare provider will appear here.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _PrescriptionCard(record: record);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final PrescriptionRecord record;

  const _PrescriptionCard({required this.record});

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionDetailsScreen(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = record.doctorName ?? record.prescribedBy;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBF3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medication_outlined,
                        color: Colors.blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName != null && doctorName.isNotEmpty
                              ? doctorName
                              : 'Authorized Provider Prescription',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        if (record.clinicName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            record.clinicName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A716E),
                            ),
                          ),
                        ],
                        if (record.prescriptionDate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Prescribed: ${record.prescriptionDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8C9E9A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (record.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        record.status!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 20),
              const Text(
                'Medicines',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A716E),
                ),
              ),
              const SizedBox(height: 6),
              if (record.medicines.isEmpty)
                Text(
                  record.medicineName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF173330),
                  ),
                )
              else
                ...record.medicines.take(3).map((med) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 6, color: Color(0xFF0B7A6E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              med.medicineName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF173330),
                              ),
                            ),
                          ),
                          if (med.frequency != null || med.dosage != null)
                            Text(
                              med.frequency ?? med.dosage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5A716E),
                              ),
                            ),
                        ],
                      ),
                    )),
              if (record.medicines.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    '+ ${record.medicines.length - 3} more medicine(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5A716E),
                    ),
                  ),
                ),
              if (record.duration != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Duration: ${record.duration!}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5A716E),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openDetails(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B7A6E),
                    side: const BorderSide(color: Color(0xFFE2EEEA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'View Prescription',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PRESCRIPTION DETAILS SCREEN (Phase 1H)
class PrescriptionDetailsScreen extends StatelessWidget {
  final PrescriptionRecord record;

  const PrescriptionDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final doctorName = record.doctorName ?? record.prescribedBy;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Prescription Details',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.medical_services_outlined,
                              color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName != null && doctorName.isNotEmpty
                                    ? doctorName
                                    : 'Provider Issued Prescription',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              if (record.clinicName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  record.clinicName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5A716E),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (record.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              record.status!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (record.prescriptionDate != null || record.duration != null) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          if (record.prescriptionDate != null)
                            Expanded(
                              child: _MiniDetail(
                                label: 'Prescription Date',
                                value: record.prescriptionDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                              ),
                            ),
                          if (record.duration != null)
                            Expanded(
                              child: _MiniDetail(
                                label: 'Overall Duration',
                                value: record.duration!,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Prescribed Medicines Section
              const Text(
                'Prescribed Medicines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),

              if (record.medicines.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: const Text(
                    'No structured medicine details provided.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
                  ),
                )
              else
                ...record.medicines.map((med) => _MedicineDetailCard(medicine: med)),

              // Provider Notes
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Provider Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Text(
                    record.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF173330),
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Metadata Section
              const Text(
                'Prescription Metadata',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _MetadataRow(label: 'Prescription ID', value: record.id),
                    if (record.doctorId != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(label: 'Provider ID', value: record.doctorId!),
                    ],
                    if (record.createdAt != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Issued Date',
                        value: record.createdAt!.toLocal().toString().split(' ')[0],
                      ),
                    ],
                    if (record.provenance != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(label: 'Source', value: record.provenance!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineDetailCard extends StatelessWidget {
  final PrescriptionMedicine medicine;

  const _MedicineDetailCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEBF3FF),
                child: Icon(Icons.medication_outlined, color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine.medicineName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              if (medicine.dosage != null)
                _MiniDetail(label: 'Dosage', value: medicine.dosage!),
              if (medicine.frequency != null)
                _MiniDetail(label: 'Frequency', value: medicine.frequency!),
              if (medicine.duration != null)
                _MiniDetail(label: 'Duration', value: medicine.duration!),
              if (medicine.timing != null)
                _MiniDetail(label: 'Timing', value: medicine.timing!),
            ],
          ),
          if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Instructions: ${medicine.notes!}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF5A716E),
              ),
            ),
          ],
        ],
      ),
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
          style: const TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
        ),
      ],
    );
  }
}

/// 2. LAB REPORTS SCREEN (Phase 1I)
class LabReportsScreen extends StatefulWidget {
  const LabReportsScreen({super.key});

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  Key _refreshKey = UniqueKey();

  void _refresh() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final recordService = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Lab Reports',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: user == null
              ? const _CategoryErrorView(
                  message: 'User authentication required.')
              : StreamBuilder<List<LabReportRecord>>(
                  key: _refreshKey,
                  stream: recordService.streamLabReports(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategoryLoadingView(
                        message: 'Loading lab reports...',
                      );
                    }
                    if (snapshot.hasError) {
                      return _CategoryErrorView(
                        message: 'Unable to load lab reports. Please try again.',
                        onRetry: _refresh,
                      );
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return const _CategoryEmptyView(
                        icon: Icons.biotech_outlined,
                        title: 'No Lab Reports Available',
                        message:
                            'Lab reports from your healthcare providers will appear here.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _LabReportCard(record: record);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _LabReportCard extends StatelessWidget {
  final LabReportRecord record;

  const _LabReportCard({required this.record});

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _formatLabStatus(record.status);
    final statusColor = _getLabStatusColor(record.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.biotech_outlined,
                        color: Colors.teal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.testName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        if (record.laboratory != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Lab: ${record.laboratory}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A716E),
                            ),
                          ),
                        ],
                        if (record.orderingProvider != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Ordered by: ${record.orderingProvider}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8C9E9A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  if (record.orderDate != null || record.date != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Order Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5A716E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (record.orderDate ?? record.date!)
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF173330),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openDetails(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B7A6E),
                    side: const BorderSide(color: Color(0xFFE2EEEA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'View Report',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// REPORT DETAILS SCREEN (Phase 1I)
class ReportDetailsScreen extends StatelessWidget {
  final LabReportRecord record;

  const ReportDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _formatLabStatus(record.status);
    final statusColor = _getLabStatusColor(record.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Report Details',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.biotech_outlined,
                              color: Colors.teal, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.testName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              if (record.testCode != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Test Code: ${record.testCode}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5A716E),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Column(
                      children: [
                        if (record.laboratory != null)
                          _MetadataRow(
                              label: 'Laboratory', value: record.laboratory!),
                        if (record.orderingProvider != null) ...[
                          const SizedBox(height: 8),
                          _MetadataRow(
                              label: 'Ordering Provider',
                              value: record.orderingProvider!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Timeline & Dates
              const Text(
                'Report Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    if (record.orderDate != null || record.date != null)
                      _MetadataRow(
                        label: 'Order Date',
                        value: (record.orderDate ?? record.date!)
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    if (record.sampleCollectionDate != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Sample Collection Date',
                        value: record.sampleCollectionDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                    if (record.processingDate != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Processing Date',
                        value: record.processingDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                    if (record.reportAvailableDate != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Report Available Date',
                        value: record.reportAvailableDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                  ],
                ),
              ),

              if (record.summary != null && record.summary!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Lab Summary & Observations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Text(
                    record.summary!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF173330),
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Report Document / PDF Section
              const Text(
                'Report Document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: record.reportUrl != null && record.reportUrl!.isNotEmpty
                    ? Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Lab Report Document Reference',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF173330),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text('View Report Document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B7A6E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Report document is not available yet.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5A716E),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Metadata Section
              const Text(
                'Report Metadata',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _MetadataRow(label: 'Report ID', value: record.id),
                    if (record.provenance != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(label: 'Source', value: record.provenance!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatLabStatus(String? status) {
  if (status == null || status.isEmpty) return 'Pending';
  switch (status.toUpperCase()) {
    case 'ORDERED':
      return 'Ordered';
    case 'SAMPLE PENDING':
    case 'SAMPLE_PENDING':
      return 'Sample Pending';
    case 'SAMPLE COLLECTED':
    case 'SAMPLE_COLLECTED':
      return 'Sample Collected';
    case 'PROCESSING':
      return 'Processing';
    case 'REPORT AVAILABLE':
    case 'REPORT_AVAILABLE':
      return 'Report Available';
    default:
      return status;
  }
}

Color _getLabStatusColor(String? status) {
  if (status == null || status.isEmpty) return Colors.grey;
  switch (status.toUpperCase()) {
    case 'ORDERED':
      return Colors.blue;
    case 'SAMPLE PENDING':
    case 'SAMPLE_PENDING':
      return Colors.orange;
    case 'SAMPLE COLLECTED':
    case 'SAMPLE_COLLECTED':
      return Colors.amber;
    case 'PROCESSING':
      return Colors.purple;
    case 'REPORT AVAILABLE':
    case 'REPORT_AVAILABLE':
      return Colors.teal;
    default:
      return Colors.teal;
  }
}

/// 3. DOCTOR CONSULTATIONS SCREEN
class DoctorConsultationsScreen extends StatelessWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final recordService = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Doctor Consultations',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: user == null
              ? const _CategoryErrorView(
                  message: 'User authentication required.')
              : StreamBuilder<List<ConsultationRecord>>(
                  stream: recordService.streamConsultations(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategoryLoadingView();
                    }
                    if (snapshot.hasError) {
                      return const _CategoryErrorView();
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return const _CategoryEmptyView(
                        icon: Icons.event_note_outlined,
                        title: 'No Consultations',
                        message: 'No consultation records available yet.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _ConsultationCard(record: record);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationRecord record;

  const _ConsultationCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEEF2FF),
                child: Icon(Icons.event_note_outlined,
                    color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.doctorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    if (record.specialization != null)
                      Text(
                        record.specialization!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (record.facility != null) ...[
            const SizedBox(height: 8),
            Text(
              'Facility: ${record.facility}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (record.consultationDate != null)
                Text(
                  'Date: ${record.consultationDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              if (record.status != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    record.status!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 4. CLINICAL NOTES SCREEN
class ClinicalNotesScreen extends StatelessWidget {
  const ClinicalNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final recordService = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Clinical Notes',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: user == null
              ? const _CategoryErrorView(
                  message: 'User authentication required.')
              : StreamBuilder<List<ClinicalNoteRecord>>(
                  stream: recordService.streamClinicalNotes(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategoryLoadingView();
                    }
                    if (snapshot.hasError) {
                      return const _CategoryErrorView();
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return const _CategoryEmptyView(
                        icon: Icons.description_outlined,
                        title: 'No Clinical Notes',
                        message: 'No clinical notes available yet.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _ClinicalNoteCard(record: record);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _ClinicalNoteCard extends StatelessWidget {
  final ClinicalNoteRecord record;

  const _ClinicalNoteCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFFBEB),
                child: Icon(Icons.description_outlined,
                    color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    if (record.author != null)
                      Text(
                        'Author: ${record.author}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (record.noteText != null) ...[
            const SizedBox(height: 10),
            Text(
              record.noteText!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (record.date != null)
                Text(
                  'Date: ${record.date!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              if (record.provenance != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    record.provenance!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 5. DOCUMENTS SCREEN
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final recordService = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Medical Documents',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: user == null
              ? const _CategoryErrorView(
                  message: 'User authentication required.')
              : StreamBuilder<List<DocumentRecord>>(
                  stream: recordService.streamDocuments(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategoryLoadingView();
                    }
                    if (snapshot.hasError) {
                      return const _CategoryErrorView();
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return const _CategoryEmptyView(
                        icon: Icons.folder_outlined,
                        title: 'No Documents',
                        message: 'No medical documents available yet.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _DocumentCard(record: record);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentRecord record;

  const _DocumentCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFF2EC),
                child: Icon(Icons.picture_as_pdf_outlined,
                    color: Colors.deepOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.documentName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    if (record.category != null)
                      Text(
                        'Category: ${record.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (record.uploadDate != null)
                Text(
                  'Uploaded: ${record.uploadDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              if (record.provenance != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    record.provenance!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// SHARED UTILITY UI COMPONENTS
class _MiniDetail extends StatelessWidget {
  final String label;
  final String value;

  const _MiniDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF5A716E)),
        ),
        const SizedBox(height: 2),
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

class _CategoryLoadingView extends StatelessWidget {
  final String message;

  const _CategoryLoadingView({
    this.message = 'Loading medical records...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0B7A6E)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF5A716E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _CategoryEmptyView({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0B7A6E).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: const Color(0xFF0B7A6E)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
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

class _CategoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _CategoryErrorView({
    this.message = 'Unable to load medical records. Please try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: 56, color: Colors.red),
            ),
            const SizedBox(height: 20),
            const Text(
              'Error Loading Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5A716E),
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B7A6E),
                  side: const BorderSide(color: Color(0xFF0B7A6E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 6. MY MEDICINES / PHARMACY SCREEN (Phase 1J)
class MyMedicinesScreen extends StatefulWidget {
  const MyMedicinesScreen({super.key});

  @override
  State<MyMedicinesScreen> createState() => _MyMedicinesScreenState();
}

// Alias for PharmacyScreen
typedef PharmacyScreen = MyMedicinesScreen;

class _MyMedicinesScreenState extends State<MyMedicinesScreen> {
  Key _refreshKey = UniqueKey();

  void _refresh() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final recordService = MedicalRecordService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'My Medicines',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: user == null
              ? const _CategoryErrorView(
                  message: 'User authentication required.')
              : StreamBuilder<List<PharmacyRecord>>(
                  key: _refreshKey,
                  stream: recordService.streamPharmacyRecords(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategoryLoadingView(
                        message: 'Loading pharmacy records...',
                      );
                    }
                    if (snapshot.hasError) {
                      return _CategoryErrorView(
                        message: 'Unable to load pharmacy records. Please try again.',
                        onRetry: _refresh,
                      );
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return const _CategoryEmptyView(
                        icon: Icons.local_pharmacy_outlined,
                        title: 'No Pharmacy Records Available',
                        message:
                            'Prescriptions processed by your pharmacy will appear here.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _PharmacyRecordCard(record: record);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PharmacyRecordCard extends StatelessWidget {
  final PharmacyRecord record;

  const _PharmacyRecordCard({required this.record});

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PharmacyDetailsScreen(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _formatPharmacyStatus(record.status);
    final statusColor = _getPharmacyStatusColor(record.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_pharmacy_outlined,
                        color: Colors.purple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.pharmacyName ?? 'Authorized Pharmacy',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Prescription #${record.prescriptionId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A716E),
                          ),
                        ),
                        if (record.doctorName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Prescribed by: ${record.doctorName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8C9E9A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (record.medicines.isNotEmpty) ...[
                const Text(
                  'Medications',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A716E),
                  ),
                ),
                const SizedBox(height: 6),
                ...record.medicines.take(3).map((med) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 6, color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              med.medicineName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF173330),
                              ),
                            ),
                          ),
                          if (med.dosage != null)
                            Text(
                              med.dosage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5A716E),
                              ),
                            ),
                        ],
                      ),
                    )),
                if (record.medicines.length > 3)
                  Text(
                    '+ ${record.medicines.length - 3} more medication(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5A716E),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: $statusLabel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (record.orderDate != null)
                    Text(
                      'Date: ${record.orderDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8C9E9A),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openDetails(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B7A6E),
                    side: const BorderSide(color: Color(0xFFE2EEEA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PHARMACY DETAILS SCREEN (Phase 1J)
class PharmacyDetailsScreen extends StatelessWidget {
  final PharmacyRecord record;

  const PharmacyDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _formatPharmacyStatus(record.status);
    final statusColor = _getPharmacyStatusColor(record.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Medication Details',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_pharmacy_outlined,
                              color: Colors.purple, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.pharmacyName ?? 'Authorized Pharmacy',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Prescription ID: #${record.prescriptionId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5A716E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (record.doctorName != null) ...[
                      const Divider(height: 24),
                      _MetadataRow(
                        label: 'Prescribing Doctor',
                        value: record.doctorName!,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Processing Timeline
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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _MetadataRow(
                      label: 'Current Status',
                      value: statusLabel,
                    ),
                    if (record.orderDate != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Prescription Submitted Date',
                        value: record.orderDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                    if (record.verificationDate != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Pharmacy Verification Date',
                        value: record.verificationDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                    if (record.dispensedDate != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        label: 'Medication Dispensed Date',
                        value: record.dispensedDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Prescribed Medicines Section
              const Text(
                'Prescribed Medications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),

              if (record.medicines.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: const Text(
                    'No structured medication items provided.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
                  ),
                )
              else
                ...record.medicines.map((med) => _MedicineDetailCard(medicine: med)),

              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Pharmacy Instructions & Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Text(
                    record.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF173330),
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Metadata Section
              const Text(
                'Pharmacy Record Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _MetadataRow(label: 'Record ID', value: record.id),
                    if (record.pharmacyId != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(label: 'Pharmacy ID', value: record.pharmacyId!),
                    ],
                    if (record.provenance != null) ...[
                      const Divider(height: 16),
                      _MetadataRow(label: 'Source', value: record.provenance!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatPharmacyStatus(String? status) {
  if (status == null || status.isEmpty) return 'Pending';
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'Pending';
    case 'VERIFIED':
      return 'Verified';
    case 'DISPENSED':
      return 'Dispensed';
    default:
      return status;
  }
}

Color _getPharmacyStatusColor(String? status) {
  if (status == null || status.isEmpty) return Colors.orange;
  switch (status.toUpperCase()) {
    case 'PENDING':
      return Colors.orange;
    case 'VERIFIED':
      return Colors.blue;
    case 'DISPENSED':
      return Colors.teal;
    default:
      return Colors.purple;
  }
}
