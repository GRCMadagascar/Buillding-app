import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/product/domain/entities/product.dart';

class ProductFirestoreService {
  static final _col = FirebaseFirestore.instance.collection('products');

  /// Add or update a product document under products collection.
  static Future<void> addProduct(Product p) async {
    final doc = _col.doc(p.id);
    await doc.set({
      'id': p.id,
      'name': p.name,
      'barcode': p.barcode,
      'price': p.price,
      'stock': p.stock,
      'imageUrl': p.imageUrl ?? '',
      'shopId': p.shopId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream the list of products for a shop (real-time).
  static Stream<List<Product>> getProductsStream(String shopId) {
    final q = _col.where('shopId', isEqualTo: shopId).orderBy('name');
    return q.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        return Product(
          id: data['id'] as String? ?? d.id,
          name: data['name'] as String? ?? '',
          barcode: data['barcode'] as String? ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          stock: (data['stock'] as num?)?.toInt() ?? 0,
          imageUrl: (data['imageUrl'] as String?) ?? '',
          shopId: (data['shopId'] as String?) ?? '',
        );
      }).toList();
    });
  }
}
