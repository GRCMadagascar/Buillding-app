import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/current_shop_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/hive_database.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFFF1600);
    const gold = Color(0xFFD4AF37);

    final todayStart = _startOfDay(DateTime.now());

    final shopId = CurrentShopService.shopId ?? '';
    final salesQuery = FirebaseFirestore.instance
        .collection('sales')
        .where('shopId', isEqualTo: shopId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: salesQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            // Total sales today
            double totalToday = 0;
            final Map<String, int> productCounts = {};

            for (final d in docs) {
              final data = d.data();
              final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
              totalToday += total;

              final items = data['itemsList'] as List<dynamic>? ?? [];
              for (final it in items) {
                final name = it['name'] as String? ?? 'Unknown';
                final qty = (it['quantity'] as num?)?.toInt() ?? 0;
                productCounts[name] = (productCounts[name] ?? 0) + qty;
              }
            }

            // Sort top products
            final topProducts = productCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // Resolve images from local product box when possible
            final productBox = HiveDatabase.productBox;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total card
                  Card(
                    color: Colors.transparent,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            red.withOpacity(0.12),
                            gold.withOpacity(0.06)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total des ventes aujourd\'hui',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(
                                NumberFormat.currency(
                                        locale: 'fr',
                                        symbol: 'Ar',
                                        decimalDigits: 0)
                                    .format(totalToday),
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: gold,
                            child: Icon(Icons.show_chart,
                                color: Colors.black, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Produits les plus vendus',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topProducts.length,
                    itemBuilder: (context, index) {
                      final entry = topProducts[index];
                      final name = entry.key;
                      final qty = entry.value;

                      // Try to find product in Hive by name
                      final productIterable =
                          productBox.values.where((p) => p.name == name);
                      final product = productIterable.isNotEmpty
                          ? productIterable.first
                          : null;

                      String? imageUrl = product?.imageUrl;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              imageUrl != null && imageUrl.isNotEmpty
                                  ? (imageUrl.startsWith('http')
                                      ? NetworkImage(imageUrl)
                                      : AssetImage(imageUrl) as ImageProvider)
                                  : const AssetImage('assets/grc_logo.png'),
                        ),
                        title: Text(name),
                        trailing: Text('$qty',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
