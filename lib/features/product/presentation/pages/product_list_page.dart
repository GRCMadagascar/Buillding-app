import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/currency_formatter.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scanQR(List<Product> products) {
    // Placeholder: open scanner route or show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanner non implémenté')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Scannez ou entrez le code-barres',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                ),
                              ),
                              validator: AppValidators.required(
                                  'Veuillez saisir un code-barres'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.qr_code_scanner,
                                  color: AppTheme.primaryColor),
                              onPressed: () => _scanQR(state.products),
                              padding: const EdgeInsets.all(15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text("Appuyez sur l'icône pour ouvrir le scanner",
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF4C669A))),
                    ],
                  );
                },
              ),
            ),

            // Expandable list fills remaining space
            Expanded(
              child: BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state.message != null) {
                    String message = state.message!;
                    if (message == 'productAddedSuccess') {
                      message = 'Produit ajouté avec succès';
                    } else if (message == 'productUpdatedSuccess') {
                      message = 'Produit mis à jour avec succès';
                    } else if (message == 'productDeletedSuccess') {
                      message = 'Produit supprimé avec succès';
                    } else if (state.status == ProductStatus.error) {
                      message = 'Erreur survenue: ${state.message}';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: state.status == ProductStatus.error
                            ? Colors.red
                            : Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == ProductStatus.loading &&
                      state.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.products.isEmpty) {
                    if (state.status == ProductStatus.error) {
                      return Center(
                          child: Text('Erreur survenue: ${state.message}'));
                    }
                    return const Center(
                        child: Text("Aucun produit trouvé. Ajoutez-en !"));
                  }

                  final filteredProducts = state.products
                      .where((product) =>
                          product.name.toLowerCase().contains(_searchQuery) ||
                          product.barcode.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                        child: Text(
                            "Aucun produit ne correspond à votre recherche."));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 100),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Leading avatar + product info (avatar wrapped in Hero for smooth transition)
                            Row(
                              children: [
                                Hero(
                                  tag: product.id,
                                  child: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    child: Text(product.name.isNotEmpty
                                        ? product.name[0].toUpperCase()
                                        : '?'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('${formatMGA(product.price)} Ar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_rounded,
                                        color: AppTheme.primaryColor, size: 20),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () {
                                      context.push(
                                          '/products/edit/${product.id}',
                                          extra: product);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 20),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () =>
                                        _confirmDelete(context, product),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 12),
              Text('Supprimer le produit',
                  style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 8),
              Text('Êtes-vous sûr de vouloir supprimer ${product.name}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProductBloc>()
                          .add(DeleteProduct(product.id));
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700]),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
