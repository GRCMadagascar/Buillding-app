// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get settings => 'Fikirakirana';

  @override
  String get language => 'Fiteny';

  @override
  String get malagasyLabel => '🇲🇬  Malagasy (MGA / Ar)';

  @override
  String get frenchLabel => '🇫🇷  Français (EUR / €)';

  @override
  String get englishLabel => '🇬🇧  English (USD / \$)';

  @override
  String get management => 'Fitantanana';

  @override
  String get products => 'Vokatra';

  @override
  String get manageStockAndBarcodes => 'Mitantana tahiry sy barcodes';

  @override
  String get shopDetails => 'Antsipirian\'ny fivarotana';

  @override
  String get editBusinessInfoAndAddress => 'Hanova ny mombamomba ny orinasanao sy adiresy';

  @override
  String get hardware => 'Fitaovana';

  @override
  String get connectedToPrinter => 'Mifandray amin\'ny mpanonta';

  @override
  String get printerConnected => 'Mpanonta mifandray';

  @override
  String get noPrinterConnected => 'Tsy misy mpanonta mifandray';

  @override
  String get connected => 'MIFANDRAY';

  @override
  String get connectDeviceInstructions => 'Hametraka fitaovana vaovao, tsindrio ny kisary Settings mba hampifandray ao amin\'ny Bluetooth an-telefaona, avy eo miverena ary tsindrio Refresh.';

  @override
  String get appearance => 'Bika aman\'endrika';

  @override
  String get darkMode => 'Maody maizina';

  @override
  String get enabled => 'Alefa';

  @override
  String get disabled => 'Vonja';

  @override
  String get selectProductsTitle => 'Misafidiana vokatra';

  @override
  String get searchProductNameHint => 'Mitadiava vokatra...';

  @override
  String get reviewOrder => 'Jereo ny baikon\'ny mpanjifa';

  @override
  String get cameraOffTitle => 'Tapaka ny fakantsary';

  @override
  String get cameraOffInstructions => 'Alefaso ny fakantsary mba hanombohana mamantatra ny barcode sy ny entana ho azy.';

  @override
  String get turnOnCameraButton => 'Alefaso ny fakantsary';

  @override
  String get scannedItems => 'Entana voaskena';

  @override
  String get scannedItemsHelp => 'Hiseho eto ireo entana voaskena rehefa manao skanina ianao eo ambony fakantsary.';

  @override
  String get printReceipt => 'Manonta ny faktiora';

  @override
  String get totalInAriary => 'TOTAL EN ARIARY';

  @override
  String get listIsEmpty => 'Banga ny lisitra';

  @override
  String get openScannerHint => 'Tsindrio ny kisary mba hanokatra ny scanner ny fakantsary';

  @override
  String get scannerNotImplemented => 'Tsy mbola misy ny scanner';

  @override
  String get pleaseEnterBarcode => 'Azafady ampidiro ny barcode';

  @override
  String get pleaseEnterName => 'Azafady ampidiro ny anarana';

  @override
  String get pleaseEnterPrice => 'Azafady ampidiro ny vidiny mety';

  @override
  String get addProduct => 'Ampidiro vokatra';

  @override
  String get addProductButton => 'Ampidiro';

  @override
  String productBarcodeExists(Object barcode) {
    return 'Efa misy vokatra manana barcode \"$barcode\"!';
  }

  @override
  String get noProductsFound => 'Tsy misy vokatra. Ampidiro tsara!';

  @override
  String get noProductsMatch => 'Tsy misy vokatra mifanaraka amin\'ny fikarohana.';

  @override
  String get deleteProductTitle => 'Hamafa vokatra';

  @override
  String deleteProductConfirm(Object name) {
    return 'Ianao ve azo antoka fa hamafa $name?';
  }

  @override
  String get productDeletedSuccess => 'Vokatra voafafa soa aman-tsara';

  @override
  String get productAddedSuccess => 'Vokatra nampiana soa aman-tsara';

  @override
  String get productUpdatedSuccess => 'Vokatra nohavaozina soa aman-tsara';

  @override
  String get cameraPermissionRequired => 'Ilaina ny fahazoan-dàlana fakantsary mba hanaovana skanina.';

  @override
  String get openAppSettings => 'Sokafy ny fikirakiran\'ny fampiharana';

  @override
  String get retry => 'Miezaka indray';

  @override
  String get cancel => 'Atsaharo';

  @override
  String get checkout => 'Fandoavana';

  @override
  String get errorOccurred => 'Nisy olana';

  @override
  String get editProduct => 'Hanova vokatra';

  @override
  String get editBarcode => 'Hanova barcode';

  @override
  String get save => 'Tehirizo';

  @override
  String get saveChanges => 'Tehirizo ny fanovana';

  @override
  String get productName => 'Anaran\'ny vokatra';

  @override
  String get priceLabel => 'Vidiny';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get paymentSettings => 'Fikirakirana fandoavam-bola';

  @override
  String get paymentSettingsSubtitle => 'Nomerao Mobile Money ampiasaina mandritra ny fandoavana';

  @override
  String get mvolaNumberLabel => 'Nomerao MVola';

  @override
  String get orangeNumberLabel => 'Nomerao Orange Money';

  @override
  String get airtelNumberLabel => 'Nomerao Airtel Money';
}
