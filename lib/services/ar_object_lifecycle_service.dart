import 'package:cloud_firestore/cloud_firestore.dart';

class ARObjectLifecycleService {
  final _db = FirebaseFirestore.instance;

  Future<void> activateObject(String objectId) async {
    await _db.collection('ar_objects').doc(objectId).update({
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> lockObject(String objectId) async {
    await _db.collection('ar_objects').doc(objectId).update({
      'status': 'locked',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hideObject(String objectId) async {
    await _db.collection('ar_objects').doc(objectId).update({
      'status': 'hidden',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDelete(String objectId) async {
    await _db.collection('ar_objects').doc(objectId).update({
      'status': 'deleted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setExpiration(
      String objectId, DateTime expiration) async {
    await _db.collection('ar_objects').doc(objectId).update({
      'expiresAt': expiration,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
