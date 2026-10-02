import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(PatientProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(
          profile.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> saveMedId(String uid, String medId) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'medId': medId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setProfileCompleted(String uid, {bool completed = true}) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'profileCompleted': completed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<PatientProfile?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return PatientProfile.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<PatientProfile?> streamProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return PatientProfile.fromJson(doc.data()!);
      }
      return null;
    });
  }
}
