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
  final String email;
  @override
  @HiveField(3)
  final String phoneNumber;
  @override
  @HiveField(4)
  final String upiId;
  @override
  @HiveField(5)
  final String footerText;
  @HiveField(6)
  @JsonKey(name: 'mvolaNumber')
  final String? _mvolaNumber;
  @override
  String get mvolaNumber => _mvolaNumber ?? '';
  @HiveField(7)
  @JsonKey(name: 'orangeMoneyNumber')
  final String? _orangeMoneyNumber;
  @override
  String get orangeMoneyNumber => _orangeMoneyNumber ?? '';
  @HiveField(8)
  @JsonKey(name: 'airtelMoneyNumber')
  final String? _airtelMoneyNumber;
  @override
  String get airtelMoneyNumber => _airtelMoneyNumber ?? '';

  const ShopModel({
    this.name = '',
    this.addressLine1 = '',
    this.email = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
    String? mvolaNumber,
    String? orangeMoneyNumber,
    String? airtelMoneyNumber,
  })  : _mvolaNumber = mvolaNumber,
        _orangeMoneyNumber = orangeMoneyNumber,
        _airtelMoneyNumber = airtelMoneyNumber,
        super(
          name: name,
          addressLine1: addressLine1,
          email: email,
          phoneNumber: phoneNumber,
          upiId: upiId,
          footerText: footerText,
          mvolaNumber: mvolaNumber ?? '',
          orangeMoneyNumber: orangeMoneyNumber ?? '',
          airtelMoneyNumber: airtelMoneyNumber ?? '',
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      email: shop.email,
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
