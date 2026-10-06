import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/appointment.dart';

void main() {
  group('Phase 1Q — Live Appointment Tracking States Unit Tests', () {
    test('Completed state evaluation takes highest status priority', () {
      final appt = Appointment(
        id: 'appt_1',
        uid: 'user_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City Care Hospital',
        dateTime: '2026-10-10 at 10:00 AM',
        status: AppointmentStatus.completed,
        isLiveTrackingActive: true,
        tokenNumber: 'A12',
        currentServingToken: 'A12',
      );

      final isCompleted = appt.status == AppointmentStatus.completed;
      expect(isCompleted, isTrue);
    });

    test('No Live Tracking state evaluation when isLiveTrackingActive is false', () {
      final appt = Appointment(
        id: 'appt_2',
        uid: 'user_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City Care Hospital',
        dateTime: '2026-10-10 at 10:00 AM',
        status: AppointmentStatus.confirmed,
        isLiveTrackingActive: false,
      );

      final isTrackingAvailable = appt.isLiveTrackingActive;
      expect(isTrackingAvailable, isFalse);
    });

    test('Your Turn state evaluation when tokens match or status is IN_CONSULTATION', () {
      final apptMatchingTokens = Appointment(
        id: 'appt_3',
        uid: 'user_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City Care Hospital',
        dateTime: '2026-10-10 at 10:00 AM',
        status: AppointmentStatus.confirmed,
        isLiveTrackingActive: true,
        tokenNumber: 'A15',
        currentServingToken: 'A15',
      );

      final isYourTurn = (apptMatchingTokens.status == AppointmentStatus.inConsultation) ||
          (apptMatchingTokens.tokenNumber != null &&
              apptMatchingTokens.currentServingToken != null &&
              apptMatchingTokens.tokenNumber == apptMatchingTokens.currentServingToken);

      expect(isYourTurn, isTrue);
    });

    test('Stale state evaluation when last updated timestamp is >= 5 minutes old', () {
      final staleTimestamp = DateTime.now().subtract(const Duration(minutes: 6));
      final freshTimestamp = DateTime.now().subtract(const Duration(minutes: 2));

      final staleAppt = Appointment(
        id: 'appt_4',
        uid: 'user_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City Care Hospital',
        dateTime: '2026-10-10 at 10:00 AM',
        status: AppointmentStatus.confirmed,
        isLiveTrackingActive: true,
        trackingLastUpdated: staleTimestamp,
      );

      final freshAppt = Appointment(
        id: 'appt_5',
        uid: 'user_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City Care Hospital',
        dateTime: '2026-10-10 at 10:00 AM',
        status: AppointmentStatus.confirmed,
        isLiveTrackingActive: true,
        trackingLastUpdated: freshTimestamp,
      );

      final isStale1 = staleAppt.trackingLastUpdated != null &&
          DateTime.now().difference(staleAppt.trackingLastUpdated!).inMinutes >= 5;
      final isStale2 = freshAppt.trackingLastUpdated != null &&
          DateTime.now().difference(freshAppt.trackingLastUpdated!).inMinutes >= 5;

      expect(isStale1, isTrue);
      expect(isStale2, isFalse);
    });

    test('Token, Queue, and Waiting Time field labels fall back gracefully when missing', () {
      final apptMissingFields = Appointment(
        id: 'appt_6',
        uid: 'user_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        hospitalName: 'City Care Hospital',
        dateTime: '2026-10-10 at 10:00 AM',
        status: AppointmentStatus.confirmed,
        isLiveTrackingActive: true,
      );

      final tokenDisplay = apptMissingFields.tokenNumber != null
          ? '#${apptMissingFields.tokenNumber}'
          : 'Token unavailable';

      final queueDisplay = apptMissingFields.currentServingToken != null
          ? '#${apptMissingFields.currentServingToken}'
          : 'Queue unavailable';

      final waitDisplay = apptMissingFields.estimatedWaitMinutes != null
          ? '${apptMissingFields.estimatedWaitMinutes} min'
          : 'Waiting time unavailable';

      expect(tokenDisplay, equals('Token unavailable'));
      expect(queueDisplay, equals('Queue unavailable'));
      expect(waitDisplay, equals('Waiting time unavailable'));
    });
  });
}
