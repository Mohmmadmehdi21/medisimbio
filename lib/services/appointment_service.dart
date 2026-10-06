import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisimbio_ui/models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAppointment(Appointment appointment) async {
    await _firestore
        .collection('users')
        .doc(appointment.uid)
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toJson());
  }

  Stream<List<Appointment>> streamUserAppointments(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
      // Sort in memory by createdAt descending
      list.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  Stream<Appointment?> streamLatestAppointment(String uid) {
    return streamUserAppointments(uid).map((appointments) {
      if (appointments.isEmpty) return null;
      // Return the first upcoming or active appointment or latest created appointment
      final upcoming = appointments.where((a) =>
          a.status == 'Upcoming' ||
          a.status == 'CONFIRMED' ||
          a.status == 'PENDING');
      if (upcoming.isNotEmpty) {
        return upcoming.first;
      }
      return appointments.first;
    });
  }

  Future<Appointment?> getAppointmentById(
      String uid, String appointmentId) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Appointment.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<Appointment?> streamAppointmentById(
      String uid, String appointmentId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null
            ? Appointment.fromJson(doc.data()!)
            : null);
  }

  /// Cancels an existing appointment in Firestore.
  Future<void> cancelAppointment({
    required String uid,
    required String appointmentId,
    String? reason,
  }) async {
    if (uid.isEmpty || appointmentId.isEmpty) {
      throw Exception('Invalid user ID or appointment ID.');
    }

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Appointment document not found.');
    }

    final currentStatus = snapshot.data()?['status'] as String? ?? '';
    if (currentStatus == AppointmentStatus.cancelled) {
      throw Exception('Appointment is already cancelled.');
    }
    if (currentStatus == AppointmentStatus.completed) {
      throw Exception('Completed appointments cannot be cancelled.');
    }

    await docRef.update({
      'status': AppointmentStatus.cancelled,
      'cancelReason': reason ?? 'Cancelled by patient',
      'isLiveTrackingActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reschedules an existing appointment with a new date & time string in Firestore.
  Future<void> rescheduleAppointment({
    required String uid,
    required String appointmentId,
    required String newDateTime,
  }) async {
    if (uid.isEmpty || appointmentId.isEmpty || newDateTime.isEmpty) {
      throw Exception('Invalid parameters for rescheduling appointment.');
    }

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Appointment document not found.');
    }

    final currentStatus = snapshot.data()?['status'] as String? ?? '';
    if (currentStatus == AppointmentStatus.cancelled) {
      throw Exception('Cancelled appointments cannot be rescheduled.');
    }
    if (currentStatus == AppointmentStatus.completed) {
      throw Exception('Completed appointments cannot be rescheduled.');
    }

    await docRef.update({
      'dateTime': newDateTime,
      'status': AppointmentStatus.rescheduled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
