import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper functions to resolve the current authenticated user's shop
/// document in Firestore.
class ShopFirestoreHelper {
  /// Returns a Map with keys 'id' and 'data' for the first shop doc
  /// where ownerUid == current user's uid. Returns null if none found.
  static Future<Map<String, dynamic>?> fetchCurrentUserShop() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final q = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      final doc = q.docs.first;
      final data = doc.data();
      return {'id': doc.id, 'data': data};
    } catch (e) {
      return null;
    }
  }
}
