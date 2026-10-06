import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/medical_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1O — Pharmacy Workflow Unit Tests', () {
    test('PharmacyRecord creation and serialization for pharmacy submission', () {
      final now = DateTime.now();
      final record = PharmacyRecord(
        id: 'PHARM-ORD-9001',
        userId: 'patient_user_88',
        prescriptionId: 'PRES-1001',
        pharmacyId: 'PHARM-CENTRAL-01',
        pharmacyName: 'Central Health Pharmacy',
        doctorName: 'Dr. Sarah Ahmed',
        status: 'PENDING',
        medicines: [
          PrescriptionMedicine(
            medicineName: 'Amoxicillin 500mg',
            dosage: '500mg',
            frequency: '3 times daily',
            duration: '7 days',
          ),
        ],
        orderDate: now,
        createdAt: now,
      );

      expect(record.id, equals('PHARM-ORD-9001'));
      expect(record.userId, equals('patient_user_88'));
      expect(record.prescriptionId, equals('PRES-1001'));
      expect(record.pharmacyId, equals('PHARM-CENTRAL-01'));
      expect(record.pharmacyName, equals('Central Health Pharmacy'));
      expect(record.status, equals('PENDING'));
      expect(record.medicines.length, equals(1));
      expect(record.medicines.first.medicineName, equals('Amoxicillin 500mg'));

      final json = record.toJson();
      expect(json['userId'], equals('patient_user_88'));
      expect(json['prescriptionId'], equals('PRES-1001'));
      expect(json['pharmacyName'], equals('Central Health Pharmacy'));
      expect(json['status'], equals('PENDING'));

      final reconstructed = PharmacyRecord.fromJson(json, 'PHARM-ORD-9001');
      expect(reconstructed.id, equals('PHARM-ORD-9001'));
      expect(reconstructed.pharmacyName, equals('Central Health Pharmacy'));
      expect(reconstructed.status, equals('PENDING'));
    });

    test('Prescription eligibility filtering rule for pharmacy submission', () {
      final activePrescription = PrescriptionRecord(
        id: 'PRES-ACTIVE',
        userId: 'user_123',
        status: 'ACTIVE',
        medicines: [
          PrescriptionMedicine(medicineName: 'Paracetamol 500mg'),
        ],
      );

      final dispensedPrescription = PrescriptionRecord(
        id: 'PRES-DISPENSED',
        userId: 'user_123',
        status: 'DISPENSED',
        medicines: [
          PrescriptionMedicine(medicineName: 'Ibuprofen 400mg'),
        ],
      );

      final expiredPrescription = PrescriptionRecord(
        id: 'PRES-EXPIRED',
        userId: 'user_123',
        status: 'EXPIRED',
        medicines: [
          PrescriptionMedicine(medicineName: 'Cetirizine 10mg'),
        ],
      );

      final prescriptions = [
        activePrescription,
        dispensedPrescription,
        expiredPrescription,
      ];

      final eligible = prescriptions.where((p) {
        final status = (p.status ?? 'ACTIVE').toUpperCase();
        return status != 'DISPENSED' && status != 'EXPIRED';
      }).toList();

      expect(eligible.length, equals(1));
      expect(eligible.first.id, equals('PRES-ACTIVE'));
    });

    test('Pharmacy status string format evaluation', () {
      const pendingStatus = 'PENDING';
      const verifiedStatus = 'VERIFIED';
      const dispensedStatus = 'DISPENSED';

      expect(pendingStatus.toUpperCase(), equals('PENDING'));
      expect(verifiedStatus.toUpperCase(), equals('VERIFIED'));
      expect(dispensedStatus.toUpperCase(), equals('DISPENSED'));
    });
  });
}
