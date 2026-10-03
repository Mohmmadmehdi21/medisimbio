import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisimbio_ui/models/medical_record.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PrescriptionRecord>> streamPrescriptions(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('prescriptions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionRecord.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<LabReportRecord>> streamLabReports(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('labReports')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LabReportRecord.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ConsultationRecord>> streamConsultations(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('consultations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConsultationRecord.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ClinicalNoteRecord>> streamClinicalNotes(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('clinicalNotes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClinicalNoteRecord.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<DocumentRecord>> streamDocuments(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentRecord.fromJson(doc.data(), doc.id))
          .toList();
    });
  }
}
