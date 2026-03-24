import 'package:flutter/material.dart';
import '../../../../core/data/hive_database.dart';
import 'package:intl/intl.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  late List<Map<String, dynamic>> _sales;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    _sales = HiveDatabase.getSalesMaps();
    setState(() {});
  }

  String _fmtDate(String iso) {
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Ventes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _sales.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 64, color: Theme.of(context).hintColor),
                    const SizedBox(height: 12),
                    const Text('Aucune vente enregistrée',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: _sales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final s = _sales[i];
                  return Card(
                    child: ListTile(
                      title: Text(_fmtDate(s['date'])),
                      subtitle: Text(
                          '${(s['total'] as num).toDouble().toStringAsFixed(0)} Ariary'),
                      trailing: TextButton(
                        child: const Text('Voir Détails'),
                        onPressed: () => _showDetails(s),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> s) {
    final items = (s['items'] as List).cast<Map<String, dynamic>>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Reçu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Date: ${_fmtDate(s['date'])}'),
              const SizedBox(height: 8),
              ...items.map((it) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${it['quantity']} x ${it['name']}'),
                      Text(
                          '${(it['price'] as num).toDouble().toStringAsFixed(0)} Ar')
                    ],
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${(s['total'] as num).toDouble().toStringAsFixed(0)} Ar')
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Montant reçu'),
                  Text(
                      '${(s['amountReceived'] as num).toDouble().toStringAsFixed(0)} Ar')
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rendu'),
                  Text(
                      '${(s['change'] as num).toDouble().toStringAsFixed(0)} Ar')
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fermer'),
              )
            ],
          ),
        );
      },
    );
  }
}
