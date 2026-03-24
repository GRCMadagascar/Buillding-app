import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String salesKey = 'sales_history';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName); // Generic box for simple key-value
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  /// Adds a sale represented as a Map to the settingsBox sales history and
  /// ensures only the latest [maxEntries] are kept.
  static Future<void> addSaleMap(Map<String, dynamic> saleMap,
      {int maxEntries = 30}) async {
    final box = settingsBox;
    final List existing = box.get(salesKey, defaultValue: <dynamic>[]) as List;
    // Prepend newest sale
    final List updated = [saleMap, ...existing];
    // Trim to maxEntries
    if (updated.length > maxEntries) {
      updated.removeRange(maxEntries, updated.length);
    }
    await box.put(salesKey, updated);
  }

  static List<Map<String, dynamic>> getSalesMaps() {
    final box = settingsBox;
    final List existing = box.get(salesKey, defaultValue: <dynamic>[]) as List;
    return existing.cast<Map<String, dynamic>>();
  }
}
