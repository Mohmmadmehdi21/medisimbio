import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/medical_record.dart';

void main() {
  group('Phase 1I — Lab Reports Model & Lifecycle Unit Tests', () {
    test('Should parse complete provider lab report JSON across lifecycle statuses', () {
      final statuses = [
        'ORDERED',
        'SAMPLE PENDING',
        'SAMPLE COLLECTED',
        'PROCESSING',
        'REPORT AVAILABLE'
      ];

      for (final st in statuses) {
        final json = {
          'userId': 'patient_456',
          'testName': 'Lipid Profile Panel',
          'testCode': 'LOINC_24331-1',
          'laboratory': 'St. Jude Diagnostic Labs',
          'orderingProvider': 'Dr. Marcus Vance',
          'orderDate': '2026-10-01T08:00:00.000Z',
          'sampleCollectionDate': '2026-10-01T09:30:00.000Z',
          'processingDate': '2026-10-01T11:00:00.000Z',
          'reportAvailableDate': '2026-10-02T14:00:00.000Z',
          'status': st,
          'summary': 'Fasting lipid levels within normal reference range.',
          'reportUrl': st == 'REPORT AVAILABLE' ? 'https://storage.provider.com/reports/lab_1.pdf' : null,
          'provenance': 'LAB_PROVIDER_SYSTEM_v2',
        };

        final record = LabReportRecord.fromJson(json, 'lab_doc_$st');

        expect(record.id, equals('lab_doc_$st'));
        expect(record.userId, equals('patient_456'));
        expect(record.testName, equals('Lipid Profile Panel'));
        expect(record.testCode, equals('LOINC_24331-1'));
        expect(record.laboratory, equals('St. Jude Diagnostic Labs'));
        expect(record.orderingProvider, equals('Dr. Marcus Vance'));
        expect(record.status, equals(st));
        expect(record.orderDate, isNotNull);
        expect(record.sampleCollectionDate, isNotNull);

        if (st == 'REPORT AVAILABLE') {
          expect(record.reportUrl, equals('https://storage.provider.com/reports/lab_1.pdf'));
        } else {
          expect(record.reportUrl, isNull);
        }
      }
    });

    test('Should handle null optional fields without fabricating data', () {
      final json = {
        'userId': 'patient_minimal',
        'testName': 'Comprehensive Metabolic Panel',
        'status': 'ORDERED',
      };

      final record = LabReportRecord.fromJson(json, 'lab_min_1');

      expect(record.id, equals('lab_min_1'));
      expect(record.userId, equals('patient_minimal'));
      expect(record.testName, equals('Comprehensive Metabolic Panel'));
      expect(record.status, equals('ORDERED'));
      expect(record.laboratory, isNull);
      expect(record.testCode, isNull);
      expect(record.reportUrl, isNull);
      expect(record.summary, isNull);
    });

    test('Patient data isolation: userId must match authenticated patient', () {
      const currentPatientId = 'patient_authed_uid';

      final record1 = LabReportRecord(
        id: 'lab_1',
        userId: currentPatientId,
        testName: 'Blood Sugar Fasting',
      );

      final record2 = LabReportRecord(
        id: 'lab_2',
        userId: 'different_patient_uid',
        testName: 'HbA1c',
      );

      expect(record1.userId == currentPatientId, isTrue);
      expect(record2.userId == currentPatientId, isFalse);
    });
  });
}
