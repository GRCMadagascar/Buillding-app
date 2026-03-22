// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get malagasyLabel => '🇲🇬  Malagasy (MGA / Ar)';

  @override
  String get frenchLabel => '🇫🇷  Français (EUR / €)';

  @override
  String get englishLabel => '🇬🇧  English (USD / \$)';

  @override
  String get management => 'Gestion';

  @override
  String get products => 'Produits';

  @override
  String get manageStockAndBarcodes => 'Gérer le stock et les codes-barres';

  @override
  String get shopDetails => 'Détails de la boutique';

  @override
  String get editBusinessInfoAndAddress => 'Modifier les informations et l\'adresse de l\'entreprise';

  @override
  String get hardware => 'Matériel';

  @override
  String get connectedToPrinter => 'Connecté à l\'imprimante';

  @override
  String get printerConnected => 'Imprimante connectée';

  @override
  String get noPrinterConnected => 'Aucune imprimante connectée';

  @override
  String get connected => 'CONNECTÉ';

  @override
  String get connectDeviceInstructions => 'Pour connecter un nouvel appareil, appuyez sur l\'icône Paramètres pour appairer dans les paramètres Bluetooth du téléphone, puis revenez et appuyez sur Actualiser.';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get selectProductsTitle => 'Sélectionner les produits';

  @override
  String get searchProductNameHint => 'Rechercher le nom du produit...';

  @override
  String get reviewOrder => 'Vérifier la commande';

  @override
  String get cameraOffTitle => 'La caméra est désactivée';

  @override
  String get cameraOffInstructions => 'Activez votre caméra pour commencer à scanner les codes-barres et les articles automatiquement.';

  @override
  String get turnOnCameraButton => 'Activer la caméra';

  @override
  String get scannedItems => 'Articles scannés';

  @override
  String get scannedItemsHelp => 'Les articles scannés apparaîtront ici au fur et à mesure que vous les scannez avec la caméra ci-dessus.';

  @override
  String get printReceipt => 'Imprimer le reçu';

  @override
  String get totalInAriary => 'TOTAL EN ARIARY';

  @override
  String get listIsEmpty => 'La liste est vide';

  @override
  String get openScannerHint => 'Appuyez sur l\'icône pour ouvrir le scanner de la caméra';

  @override
  String get scannerNotImplemented => 'Scanner non implémenté';

  @override
  String get pleaseEnterBarcode => 'Veuillez entrer un code-barres';

  @override
  String get pleaseEnterName => 'Veuillez entrer un nom';

  @override
  String get pleaseEnterPrice => 'Veuillez entrer un prix valide';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get addProductButton => 'Ajouter';

  @override
  String productBarcodeExists(Object barcode) {
    return 'Ce code barre $barcode existe déjà';
  }

  @override
  String get noProductsFound => 'Aucun produit trouvé. Ajoutez-en!';

  @override
  String get noProductsMatch => 'Aucun produit ne correspond à votre recherche.';

  @override
  String get deleteProductTitle => 'Supprimer le produit';

  @override
  String deleteProductConfirm(Object name) {
    return 'Voulez-vous vraiment supprimer $name ?';
  }

  @override
  String get productDeletedSuccess => 'Produit supprimé avec succès';

  @override
  String get productAddedSuccess => 'Produit ajouté avec succès';

  @override
  String get productUpdatedSuccess => 'Produit mis à jour avec succès';

  @override
  String get cameraPermissionRequired => 'L\'autorisation de la caméra est requise pour scanner les codes-barres.';

  @override
  String get openAppSettings => 'Ouvrir les paramètres de l\'application';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get checkout => 'Paiement';

  @override
  String get errorOccurred => 'Erreur';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get editBarcode => 'Modifier le code-barres';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get productName => 'Nom du produit';

  @override
  String get priceLabel => 'Prix';

  @override
  String get barcodeLabel => 'Code-barres';

  @override
  String get paymentSettings => 'Paramètres de paiement';

  @override
  String get paymentSettingsSubtitle => 'Numéros Mobile Money utilisés lors du paiement';

  @override
  String get mvolaNumberLabel => 'Numéro MVola';

  @override
  String get orangeNumberLabel => 'Numéro Orange Money';

  @override
  String get airtelNumberLabel => 'Numéro Airtel Money';
}
