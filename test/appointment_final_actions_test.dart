import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/appointment.dart';

void main() {
  group('Phase 1P — Appointment Final Actions Unit Tests', () {
    test('AppointmentStatus constants are correctly defined', () {
      expect(AppointmentStatus.pending, equals('PENDING'));
      expect(AppointmentStatus.confirmed, equals('CONFIRMED'));
      expect(AppointmentStatus.rescheduled, equals('RESCHEDULED'));
      expect(AppointmentStatus.cancelled, equals('CANCELLED'));
      expect(AppointmentStatus.completed, equals('COMPLETED'));
    });

    test('Appointment cancellation status update logic', () {
      final appt = Appointment(
        id: 'APPT-100',
        uid: 'USER-100',
        doctorId: 'DOC-1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City General Hospital',
        dateTime: 'Tomorrow, 10:30 AM',
        status: AppointmentStatus.confirmed,
      );

      final json = appt.toJson();
      json['status'] = AppointmentStatus.cancelled;

      final cancelledAppt = Appointment.fromJson(json);
      expect(cancelledAppt.status, equals('CANCELLED'));
      expect(cancelledAppt.id, equals('APPT-100'));
    });

    test('Appointment reschedule status and dateTime update logic', () {
      final appt = Appointment(
        id: 'APPT-200',
        uid: 'USER-200',
        doctorId: 'DOC-2',
        doctorName: 'Dr. Michael Chen',
        specialty: 'Dermatology',
        hospitalName: 'HealthCare Clinic',
        dateTime: 'Today, 02:00 PM',
        status: AppointmentStatus.confirmed,
      );

      final json = appt.toJson();
      json['dateTime'] = 'Oct 10, 11:00 AM';
      json['status'] = AppointmentStatus.rescheduled;

      final rescheduledAppt = Appointment.fromJson(json);
      expect(rescheduledAppt.status, equals('RESCHEDULED'));
      expect(rescheduledAppt.dateTime, equals('Oct 10, 11:00 AM'));
    });

    test('Cancellation eligibility evaluation rule', () {
      bool canCancel(String status) {
        final st = status.toUpperCase();
        return st != AppointmentStatus.cancelled &&
            st != AppointmentStatus.completed;
      }

      expect(canCancel('CONFIRMED'), isTrue);
      expect(canCancel('Upcoming'), isTrue);
      expect(canCancel('RESCHEDULED'), isTrue);
      expect(canCancel('CANCELLED'), isFalse);
      expect(canCancel('COMPLETED'), isFalse);
    });

    test('Reschedule eligibility evaluation rule', () {
      bool canReschedule(String status) {
        final st = status.toUpperCase();
        return st != AppointmentStatus.cancelled &&
            st != AppointmentStatus.completed;
      }

      expect(canReschedule('CONFIRMED'), isTrue);
      expect(canReschedule('Upcoming'), isTrue);
      expect(canReschedule('CANCELLED'), isFalse);
      expect(canReschedule('COMPLETED'), isFalse);
    });
  });
}
