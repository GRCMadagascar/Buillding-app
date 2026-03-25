import 'package:billing_app/features/product/domain/entities/product.dart';

class SaleItem {
  final String name;
  final double price;
  final int quantity;

  SaleItem({required this.name, required this.price, required this.quantity});

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory SaleItem.fromMap(Map<String, dynamic> m) => SaleItem(
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        quantity: (m['quantity'] as num).toInt(),
      );
}

class SaleModel {
  final String id;
  final DateTime date;
  final List<SaleItem> items;
  final double total;
  final String paymentMethod;
  final double amountReceived;
  final double change;
  final String uid;

  SaleModel({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.amountReceived,
    required this.change,
    required this.uid,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        'amountReceived': amountReceived,
        'change': change,
        'uid': uid,
      };

  factory SaleModel.fromMap(Map<String, dynamic> m) => SaleModel(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        items: (m['items'] as List)
            .map((e) => SaleItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        total: (m['total'] as num).toDouble(),
        paymentMethod: m['paymentMethod'] as String,
        amountReceived: (m['amountReceived'] as num).toDouble(),
        change: (m['change'] as num).toDouble(),
        uid: m['uid'] as String? ?? 'unknown',
      );

  /// Convenience: construct from Billing cart items
  static SaleModel fromCart({
    required String id,
    required DateTime date,
    required List cartItems,
    required double total,
    required String paymentMethod,
    required double amountReceived,
    required double change,
    required String uid,
  }) {
    final items = cartItems.map((ci) {
      // Expecting CartItem shape: has product and quantity
      final product = ci.product as Product;
      final qty = ci.quantity as int;
      return SaleItem(name: product.name, price: product.price, quantity: qty);
    }).toList();

    return SaleModel(
      id: id,
      date: date,
      items: items,
      total: total,
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
      change: change,
      uid: uid,
    );
  }
}
