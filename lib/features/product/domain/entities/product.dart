import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String
      id; // Using barcode as ID usually, but keeping separate ID is safer
  final String name;
  final String barcode;
  final double price;
  final int stock; // Optional implementation detail
  final String? imageUrl;
  final String shopId;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.stock = 0,
    this.imageUrl,
    this.shopId = '',
  });

  @override
  List<Object?> get props =>
      [id, name, barcode, price, stock, imageUrl, shopId];
}
