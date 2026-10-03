import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisimbio_ui/models/ai_intake.dart';

class AiHealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveIntakeRecord(AiIntakeRecord record) async {
    await _firestore
        .collection('users')
        .doc(record.uid)
        .collection('healthIntakes')
        .doc(record.id)
        .set(record.toJson());
  }

  Stream<List<AiIntakeRecord>> streamUserIntakes(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('healthIntakes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AiIntakeRecord.fromJson(doc.data()))
          .toList();
    });
  }
}
