import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billing_app/core/models/user_role.dart';

class CurrentUserService {
  static String? uid;
  static UserRole? role;
  static String? shopId;
  static Map<String, dynamic>? userData;

  static Future<bool> loadForUid(String userUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();
      if (!doc.exists) return false;
      userData = doc.data();
      uid = userUid;
      final r = userData?['role'] as String? ?? 'vendeur';
      // Treat 'solo' as admin as well (solo = owner + cashier)
      role = (r == 'admin' || r == 'solo') ? UserRole.admin : UserRole.vendeur;
      shopId = userData?['shopId'] as String?;
      return true;
    } catch (_) {
      return false;
    }
  }
}
