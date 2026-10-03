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
class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

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
                  stream: recordService.streamPrescriptions(user.uid),
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
                        icon: Icons.medication_outlined,
                        title: 'No Prescriptions',
                        message: 'No prescriptions available yet.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                backgroundColor: Color(0xFFEBF3FF),
                child: Icon(Icons.medication_outlined,
                    color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.medicineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    if (record.prescribedBy != null)
                      Text(
                        'Prescribed by: ${record.prescribedBy}',
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
            children: [
              if (record.dosage != null)
                Expanded(
                  child: _MiniDetail(label: 'Dosage', value: record.dosage!),
                ),
              if (record.frequency != null)
                Expanded(
                  child: _MiniDetail(
                      label: 'Frequency', value: record.frequency!),
                ),
              if (record.duration != null)
                Expanded(
                  child:
                      _MiniDetail(label: 'Duration', value: record.duration!),
                ),
            ],
          ),
          if (record.date != null || record.provenance != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (record.date != null)
                  Text(
                    'Date: ${record.date!.toLocal().toString().split(' ')[0]}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                if (record.provenance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B7A6E).withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      record.provenance!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B7A6E),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 2. LAB REPORTS SCREEN
class LabReportsScreen extends StatelessWidget {
  const LabReportsScreen({super.key});

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
                  stream: recordService.streamLabReports(user.uid),
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
                        icon: Icons.biotech_outlined,
                        title: 'No Lab Reports',
                        message: 'No lab reports available yet.',
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                backgroundColor: Color(0xFFE6F7F5),
                child: Icon(Icons.biotech_outlined,
                    color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.testName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    if (record.laboratory != null)
                      Text(
                        'Lab: ${record.laboratory}',
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
          if (record.summary != null) ...[
            const SizedBox(height: 10),
            Text(
              record.summary!,
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
              if (record.status != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    record.status!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
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
  const _CategoryLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF0B7A6E)),
          SizedBox(height: 16),
          Text(
            'Loading medical records...',
            style: TextStyle(
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

  const _CategoryErrorView({
    this.message = 'Unable to load medical records. Please try again.',
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
          ],
        ),
      ),
    );
  }
}
