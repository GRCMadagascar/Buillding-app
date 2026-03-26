import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentShopService {
  static String? shopId;
  static Map<String, dynamic>? shopData;

  /// Load the current user's shop by ownerUid; returns true if loaded.
  static Future<bool> loadForOwner(String ownerUid) async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerUid', isEqualTo: ownerUid)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return false;
      shopId = q.docs.first.id;
      shopData = q.docs.first.data();
      return true;
    } catch (_) {
      return false;
    }
  }

  static String get currentShopName =>
      (shopData != null && shopData!['shopName'] != null)
          ? shopData!['shopName'] as String
          : 'GRC POS';

  static String? get logoUrl =>
      shopData != null ? shopData!['logoUrl'] as String? : null;

  static int? get primaryColorValue =>
      shopData != null ? (shopData!['primaryColor'] as int?) : null;

  static String get subscriptionStatus =>
      (shopData != null && shopData!['subscriptionStatus'] != null)
          ? shopData!['subscriptionStatus'] as String
          : 'expired';

  static DateTime? get trialEndDate {
    if (shopData == null) return null;
    final v = shopData!['trialEndDate'];
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  /// Helper to get a stream of products for the current shop.
  static Stream<QuerySnapshot<Map<String, dynamic>>> productsStream() {
    final id = shopId ?? '';
    return FirebaseFirestore.instance
        .collection('products')
        .where('shopId', isEqualTo: id)
        .snapshots();
  }

  /// Helper to get a stream of sales for the current shop.
  static Stream<QuerySnapshot<Map<String, dynamic>>> salesStream() {
    final id = shopId ?? '';
    return FirebaseFirestore.instance
        .collection('sales')
        .where('shopId', isEqualTo: id)
        .snapshots();
  }

  /// Load the shop by document id and populate shopData/shopId.
  static Future<bool> loadForId(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('shops').doc(id).get();
      if (!doc.exists) return false;
      shopId = doc.id;
      shopData = doc.data();
      return true;
    } catch (_) {
      return false;
    }
  }
}
