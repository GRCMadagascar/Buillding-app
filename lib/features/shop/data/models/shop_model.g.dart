// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopModelAdapter extends TypeAdapter<ShopModel> {
  @override
  final int typeId = 1;

  @override
  ShopModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopModel(
      name: fields[0] as String,
      addressLine1: fields[1] as String,
      addressLine2: fields[2] as String,
      phoneNumber: fields[3] as String,
      upiId: fields[4] as String,
      footerText: fields[5] as String,
      mvolaNumber: fields[6] as String?,
      orangeMoneyNumber: fields[7] as String?,
      airtelMoneyNumber: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShopModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.upiId)
      ..writeByte(5)
      ..write(obj.footerText)
      ..writeByte(6)
      ..write(obj.mvolaNumber)
      ..writeByte(7)
      ..write(obj.orangeMoneyNumber)
      ..writeByte(8)
      ..write(obj.airtelMoneyNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopModel _$ShopModelFromJson(Map<String, dynamic> json) => ShopModel(
      name: json['name'] as String? ?? '',
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      upiId: json['upiId'] as String? ?? '',
      footerText: json['footerText'] as String? ?? '',
      mvolaNumber: json['mvolaNumber'] as String?,
      orangeMoneyNumber: json['orangeMoneyNumber'] as String?,
      airtelMoneyNumber: json['airtelMoneyNumber'] as String?,
    );

Map<String, dynamic> _$ShopModelToJson(ShopModel instance) => <String, dynamic>{
      'name': instance.name,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'phoneNumber': instance.phoneNumber,
      'upiId': instance.upiId,
      'footerText': instance.footerText,
      'mvolaNumber': instance.mvolaNumber,
      'orangeMoneyNumber': instance.orangeMoneyNumber,
      'airtelMoneyNumber': instance.airtelMoneyNumber,
    };
