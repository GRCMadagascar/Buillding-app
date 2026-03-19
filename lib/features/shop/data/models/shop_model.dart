import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String name;
  @override
  @HiveField(1)
  final String addressLine1;
  @override
  @HiveField(2)
  final String addressLine2;
  @override
  @HiveField(3)
  final String phoneNumber;
  @override
  @HiveField(4)
  final String upiId;
  @override
  @HiveField(5)
  final String footerText;
  @override
  @HiveField(6)
  @JsonKey(name: 'mvolaNumber')
  final String mvolaNumber;
  @override
  @HiveField(7)
  @JsonKey(name: 'orangeMoneyNumber')
  final String orangeMoneyNumber;
  @override
  @HiveField(8)
  @JsonKey(name: 'airtelMoneyNumber')
  final String airtelMoneyNumber;

  const ShopModel({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.upiId,
    required this.footerText,
    required this.mvolaNumber,
    required this.orangeMoneyNumber,
    required this.airtelMoneyNumber,
  }) : super(
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          upiId: upiId,
          footerText: footerText,
          mvolaNumber: mvolaNumber,
          orangeMoneyNumber: orangeMoneyNumber,
          airtelMoneyNumber: airtelMoneyNumber,
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
      mvolaNumber: shop.mvolaNumber,
      orangeMoneyNumber: shop.orangeMoneyNumber,
      airtelMoneyNumber: shop.airtelMoneyNumber,
    );
  }

  // JSON (de)serialization helpers will be generated into shop_model.g.dart
  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopModelToJson(this);

  Shop toEntity() => this;
}
