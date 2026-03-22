import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('mg')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @malagasyLabel.
  ///
  /// In en, this message translates to:
  /// **'🇲🇬  Malagasy (MGA / Ar)'**
  String get malagasyLabel;

  /// No description provided for @frenchLabel.
  ///
  /// In en, this message translates to:
  /// **'🇫🇷  Français (EUR / €)'**
  String get frenchLabel;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'🇬🇧  English (USD / \$)'**
  String get englishLabel;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @manageStockAndBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Manage stock and barcodes'**
  String get manageStockAndBarcodes;

  /// No description provided for @shopDetails.
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get shopDetails;

  /// No description provided for @editBusinessInfoAndAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit business info & address'**
  String get editBusinessInfoAndAddress;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get hardware;

  /// No description provided for @connectedToPrinter.
  ///
  /// In en, this message translates to:
  /// **'Connected to printer'**
  String get connectedToPrinter;

  /// No description provided for @printerConnected.
  ///
  /// In en, this message translates to:
  /// **'Printer connected'**
  String get printerConnected;

  /// No description provided for @noPrinterConnected.
  ///
  /// In en, this message translates to:
  /// **'No printer connected'**
  String get noPrinterConnected;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get connected;

  /// No description provided for @connectDeviceInstructions.
  ///
  /// In en, this message translates to:
  /// **'To connect a new device, tap on the Settings gear to pair in phone\'s Bluetooth settings, then return and hit Refresh.'**
  String get connectDeviceInstructions;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @selectProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Products'**
  String get selectProductsTitle;

  /// No description provided for @searchProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'Search product name...'**
  String get searchProductNameHint;

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get reviewOrder;

  /// No description provided for @cameraOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera is turned off'**
  String get cameraOffTitle;

  /// No description provided for @cameraOffInstructions.
  ///
  /// In en, this message translates to:
  /// **'Turn on your camera to start scanning barcodes and items automatically.'**
  String get cameraOffInstructions;

  /// No description provided for @turnOnCameraButton.
  ///
  /// In en, this message translates to:
  /// **'Turn on Camera'**
  String get turnOnCameraButton;

  /// No description provided for @scannedItems.
  ///
  /// In en, this message translates to:
  /// **'Scanned Items'**
  String get scannedItems;

  /// No description provided for @scannedItemsHelp.
  ///
  /// In en, this message translates to:
  /// **'Scanned items will appear here as you scan them with the camera above.'**
  String get scannedItemsHelp;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @totalInAriary.
  ///
  /// In en, this message translates to:
  /// **'TOTAL IN ARIARY'**
  String get totalInAriary;

  /// No description provided for @listIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'List is empty'**
  String get listIsEmpty;

  /// No description provided for @openScannerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to open camera scanner'**
  String get openScannerHint;

  /// No description provided for @scannerNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Scanner not implemented'**
  String get scannerNotImplemented;

  /// No description provided for @pleaseEnterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a barcode'**
  String get pleaseEnterBarcode;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterPrice;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @addProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductButton;

  /// No description provided for @productBarcodeExists.
  ///
  /// In en, this message translates to:
  /// **'Product with barcode \"{barcode}\" already exists!'**
  String productBarcodeExists(Object barcode);

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found. Add some!'**
  String get noProductsFound;

  /// No description provided for @noProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get noProductsMatch;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteProductConfirm(Object name);

  /// No description provided for @productDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccess;

  /// No description provided for @productAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccess;

  /// No description provided for @productUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccess;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan barcodes.'**
  String get cameraPermissionRequired;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorOccurred;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @editBarcode.
  ///
  /// In en, this message translates to:
  /// **'Edit Barcode'**
  String get editBarcode;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcodeLabel;

  /// No description provided for @paymentSettings.
  ///
  /// In en, this message translates to:
  /// **'Payment Settings'**
  String get paymentSettings;

  /// No description provided for @paymentSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile money numbers used during checkout'**
  String get paymentSettingsSubtitle;

  /// No description provided for @mvolaNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'MVola Number'**
  String get mvolaNumberLabel;

  /// No description provided for @orangeNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Orange Money Number'**
  String get orangeNumberLabel;

  /// No description provided for @airtelNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Airtel Money Number'**
  String get airtelNumberLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'mg': return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
