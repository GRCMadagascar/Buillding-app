import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';

class UserFirestoreHelper {
  /// Create or update a user document in `users` collection with role and shopId.
  /// If [shopId] is null, it will be saved as empty string.
  static Future<void> createOrUpdateUserDoc({
    required User user,
    UserRole role = UserRole.vendeur,
    String? shopId,
  }) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await doc.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'role': role.name,
      'shopId': shopId ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Create a new shop document for a new admin user and grant a 7-day trial.
  /// Also updates the user document to reference the created shop and role admin.
  static Future<String?> createShopWithTrialForUser({
    required User user,
    required String shopName,
    int primaryColorValue = 0xFFFF1600,
    String planType = 'starter',
  }) async {
    try {
      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 7));
      final shopRef = await FirebaseFirestore.instance.collection('shops').add({
        'shopName': shopName,
        'logoUrl': '',
        'ownerUid': user.uid,
        'primaryColor': primaryColorValue,
        'subscriptionStatus': 'active',
        'trialEndDate': Timestamp.fromDate(trialEnd),
        'planType': planType,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Update user doc to be admin and point to this shop
      await createOrUpdateUserDoc(
          user: user, role: UserRole.admin, shopId: shopRef.id);
      return shopRef.id;
    } catch (e) {
      return null;
    }
  }
}
