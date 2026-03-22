// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get malagasyLabel => '🇲🇬  Malagasy (MGA / Ar)';

  @override
  String get frenchLabel => '🇫🇷  Français (EUR / €)';

  @override
  String get englishLabel => '🇬🇧  English (USD / \$)';

  @override
  String get management => 'Management';

  @override
  String get products => 'Products';

  @override
  String get manageStockAndBarcodes => 'Manage stock and barcodes';

  @override
  String get shopDetails => 'Shop Details';

  @override
  String get editBusinessInfoAndAddress => 'Edit business info & address';

  @override
  String get hardware => 'Hardware';

  @override
  String get connectedToPrinter => 'Connected to printer';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get noPrinterConnected => 'No printer connected';

  @override
  String get connected => 'CONNECTED';

  @override
  String get connectDeviceInstructions => 'To connect a new device, tap on the Settings gear to pair in phone\'s Bluetooth settings, then return and hit Refresh.';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get selectProductsTitle => 'Select Products';

  @override
  String get searchProductNameHint => 'Search product name...';

  @override
  String get reviewOrder => 'Review Order';

  @override
  String get cameraOffTitle => 'Camera is turned off';

  @override
  String get cameraOffInstructions => 'Turn on your camera to start scanning barcodes and items automatically.';

  @override
  String get turnOnCameraButton => 'Turn on Camera';

  @override
  String get scannedItems => 'Scanned Items';

  @override
  String get scannedItemsHelp => 'Scanned items will appear here as you scan them with the camera above.';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get totalInAriary => 'TOTAL IN ARIARY';

  @override
  String get listIsEmpty => 'List is empty';

  @override
  String get openScannerHint => 'Tap the icon to open camera scanner';

  @override
  String get scannerNotImplemented => 'Scanner not implemented';

  @override
  String get pleaseEnterBarcode => 'Please enter a barcode';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseEnterPrice => 'Please enter a valid price';

  @override
  String get addProduct => 'Add Product';

  @override
  String get addProductButton => 'Add Product';

  @override
  String productBarcodeExists(Object barcode) {
    return 'Product with barcode \"$barcode\" already exists!';
  }

  @override
  String get noProductsFound => 'No products found. Add some!';

  @override
  String get noProductsMatch => 'No products match your search.';

  @override
  String get deleteProductTitle => 'Delete Product';

  @override
  String deleteProductConfirm(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get productDeletedSuccess => 'Product deleted successfully';

  @override
  String get productAddedSuccess => 'Product added successfully';

  @override
  String get productUpdatedSuccess => 'Product updated successfully';

  @override
  String get cameraPermissionRequired => 'Camera permission is required to scan barcodes.';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get checkout => 'Checkout';

  @override
  String get errorOccurred => 'Error';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get editBarcode => 'Edit Barcode';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get productName => 'Product Name';

  @override
  String get priceLabel => 'Price';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get paymentSettings => 'Payment Settings';

  @override
  String get paymentSettingsSubtitle => 'Mobile money numbers used during checkout';

  @override
  String get mvolaNumberLabel => 'MVola Number';

  @override
  String get orangeNumberLabel => 'Orange Money Number';

  @override
  String get airtelNumberLabel => 'Airtel Money Number';
}
