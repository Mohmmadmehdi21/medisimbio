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
      // Return the first upcoming appointment or latest created appointment
      final upcoming = appointments.where((a) => a.status == 'Upcoming');
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
}
