import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String name;
  final String addressLine1;
  final String email;
  final String phoneNumber;
  final String upiId;
  final String footerText;
  final String mvolaNumber;
  final String orangeMoneyNumber;
  final String airtelMoneyNumber;

  const Shop({
    this.name = 'GRC POS',
    this.addressLine1 = '',
    this.email = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
    this.mvolaNumber = '',
    this.orangeMoneyNumber = '',
    this.airtelMoneyNumber = '',
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? email,
    String? phoneNumber,
    String? upiId,
    String? footerText,
    String? mvolaNumber,
    String? orangeMoneyNumber,
    String? airtelMoneyNumber,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
      mvolaNumber: mvolaNumber ?? this.mvolaNumber,
      orangeMoneyNumber: orangeMoneyNumber ?? this.orangeMoneyNumber,
      airtelMoneyNumber: airtelMoneyNumber ?? this.airtelMoneyNumber,
    );
  }

  @override
  List<Object?> get props => [
        name,
        addressLine1,
        email,
        phoneNumber,
        upiId,
        footerText,
        mvolaNumber,
        orangeMoneyNumber,
        airtelMoneyNumber,
      ];
}
