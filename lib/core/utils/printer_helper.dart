import 'dart:io';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/hive_database.dart' as hd;

/// Minimal, single-file printer helper for thermal ESC/POS-like printing.
///
/// Provides:
/// - permission and pairing helpers
/// - connect/disconnect helpers
/// - a single `printReceipt(...)` method that prints items + Total, Amount Received and Change

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final ok =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = ok;
      return ok;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final ok = await PrintBluetoothThermal.disconnect;
      _isConnected = !ok;
      return ok;
    } catch (e) {
      return false;
    }
  }

  Future<void> printText(String text) async {
    if (!_isConnected) return;
    final connected = await PrintBluetoothThermal.connectionStatus;
    if (!connected) return;
    await PrintBluetoothThermal.writeBytes(text.codeUnits);
  }

  /// Print a receipt with items, total, amountReceived and change.
  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String email,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    double amountReceived = 0.0,
    double change = 0.0,
    required String footer,
  }) async {
    if (!_isConnected) return;
    final nf = NumberFormat('#,##0', 'en_US');

    final settings = hd.HiveDatabase.settingsBox;
    // Invoice counter (auto increment)
    int counter = (settings.get('invoice_counter') ?? 0) as int;
    counter += 1;
    settings.put('invoice_counter', counter);
    final invoiceNo = counter.toString().padLeft(6, '0');

    final logoPath = settings.get('shop_logo') as String?;
    final facebook = settings.get('shop_facebook') ?? '';
    final instagram = settings.get('shop_instagram') ?? '';
    final tiktok = settings.get('shop_tiktok') ?? '';
    final whatsapp = settings.get('shop_whatsapp') ?? '';
    final admin = settings.get('shop_admin') ?? '';

    List<int> bytes = [];
    bytes += EscPos.init;

    // Header: logo (if available as filename), shop name, phone, email(email), address
    bytes += EscPos.alignCenter;
    if (logoPath != null && logoPath.isNotEmpty) {
      // We can't reliably print images across all printers here; print logo filename as placeholder
      final logoLabel = 'Logo: ${logoPath.split(Platform.pathSeparator).last}';
      bytes += _textToBytes(logoLabel);
      bytes += EscPos.lineFeed;
    }
    bytes += EscPos.boldOn;
    bytes += EscPos.textLarge;
    bytes += _textToBytes(shopName.toUpperCase());
    bytes += EscPos.lineFeed;
    bytes += EscPos.boldOff;

    if (phone.isNotEmpty) {
      bytes += _textToBytes('Tel: $phone');
      bytes += EscPos.lineFeed;
    }
    if (email.isNotEmpty) {
      bytes += _textToBytes('Email: $email');
      bytes += EscPos.lineFeed;
    }
    if (address1.isNotEmpty) {
      bytes += _textToBytes(address1);
      bytes += EscPos.lineFeed;
    }

    // Social icons row (textual)
    final socialRow =
        'FB:$facebook  IG:$instagram  TT:$tiktok  WA:$whatsapp';
    bytes += _textToBytes(socialRow);
    bytes += EscPos.lineFeed;

    // Served by admin
    if ((admin as String).isNotEmpty) {
      bytes += _textToBytes('Served by $admin');
      bytes += EscPos.lineFeed;
    }

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Invoice info
    bytes += _textToBytes('Facture n\u00B0 $invoiceNo');
    bytes += EscPos.lineFeed;
    bytes +=
        _textToBytes(DateFormat('dd-MM-yyyy | HH:mm').format(DateTime.now()));
    bytes += EscPos.lineFeed;
    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Table header
    bytes += EscPos.alignLeft;
    bytes += _textToBytes('Produit          Price         Total');
    bytes += EscPos.lineFeed;
    bytes += _textToBytes('------------------------------------');
    bytes += EscPos.lineFeed;

    // Items
    for (final item in items) {
      final name = item['name'].toString();
      final qty = item['qty'].toString();
      final priceVal = double.tryParse(item['price'].toString()) ?? 0.0;
      final totalVal = double.tryParse(item['total'].toString()) ?? 0.0;
      final price = nf.format(priceVal);
      final totalItem = nf.format(totalVal);

      String prefix = '${qty}x $name';
      if (prefix.length > 14) prefix = prefix.substring(0, 14);
      final line =
          prefix.padRight(16) + price.padLeft(8) + totalItem.padLeft(8);
      bytes += _textToBytes(line);
      bytes += EscPos.lineFeed;
    }

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Calculations: TOTAL / PAYER / ECHANGE
    bytes += EscPos.alignRight;
    bytes += EscPos.boldOn;
    bytes += _textToBytes('TOTAL: ${nf.format(total)} Ar');
    bytes += EscPos.lineFeed;
    bytes += EscPos.boldOff;

    bytes += _textToBytes('PAYER: ${nf.format(amountReceived)} Ar');
    bytes += EscPos.lineFeed;
    bytes += _textToBytes('ECHANGE: ${nf.format(change)} Ar');
    bytes += EscPos.lineFeed;

    bytes += _textToBytes('................................');
    bytes += EscPos.lineFeed;

    // Footer
    bytes += EscPos.alignCenter;
    bytes += _textToBytes(footer);
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  List<int> _textToBytes(String text) => List<int>.from(text.codeUnits);
}
