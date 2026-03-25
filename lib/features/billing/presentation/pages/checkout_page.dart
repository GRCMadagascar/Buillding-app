import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../../core/data/hive_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/sale_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/billing_bloc.dart';
import 'dart:math' as math;
// Removed localization dependency: texts are hardcoded in French.
// snackbar_helper removed; use ScaffoldMessenger or central helper when needed.

enum Operator { mvola, orange, airtel }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  Operator? _pressedOperator;
  // Operator selection for Mobile Money
  Operator? _selectedOperator;
  late final TextEditingController _amountReceivedController;
  double _amountReceived = 0.0;
  double _change = 0.0;

  String _operatorPhone(ShopState shopState) {
    if (shopState is ShopLoaded) {
      switch (_selectedOperator) {
        case Operator.mvola:
          return shopState.shop.mvolaNumber;
        case Operator.orange:
          return shopState.shop.orangeMoneyNumber;
        case Operator.airtel:
          return shopState.shop.airtelMoneyNumber;
        default:
          return '';
      }
    }
    return '';
  }

  Color _operatorColor() {
    switch (_selectedOperator) {
      case Operator.mvola:
        return const Color(0xFF002855); // Dark Blue
      case Operator.orange:
        return const Color.fromARGB(255, 255, 123, 0); // Orange
      case Operator.airtel:
        return const Color(0xFFD32F2F); // Red
      default:
        return const Color(0xFFE5E5EA);
    }
  }

  String _operatorCode() {
    switch (_selectedOperator) {
      case Operator.mvola:
        // Mvola transfer prefix
        return '*111*1*2*';
      case Operator.orange:
        // Orange Money transfer prefix
        return '*144*';
      case Operator.airtel:
        // Airtel Money transfer prefix
        return '*333*';
      default:
        return '*123*';
    }
  }

  String _buildQrData(String phone, double amount) {
    if (phone.isEmpty || _selectedOperator == null) return '';
    final code = _operatorCode();
    String ussd;
    switch (_selectedOperator) {
      case Operator.mvola:
        // *111*1*2*RECIPIENT_NUMBER*AMOUNT*#
        ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
        break;
      case Operator.orange:
        // *144*AMOUNT*RECIPIENT_NUMBER*#
        ussd = '$code${amount.toStringAsFixed(0)}*$phone#';
        break;
      case Operator.airtel:
        // *333*RECIPIENT_NUMBER*AMOUNT*# (assumed similar to Mvola)
        ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
        break;
      default:
        ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
    }

    final encoded = ussd.replaceAll('#', '%23');
    return 'tel:$encoded';
  }

  /// Build a human-readable USSD string (with #) for display/instructions.
  String _buildUssdString(String phone, double amount) {
    if (phone.isEmpty || _selectedOperator == null) return '';
    final code = _operatorCode();
    String ussd;
    switch (_selectedOperator) {
      case Operator.mvola:
        ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
        break;
      case Operator.orange:
        ussd = '$code${amount.toStringAsFixed(0)}*$phone#';
        break;
      case Operator.airtel:
        ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
        break;
      default:
        ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
    }
    return ussd;
  }

  // USSD/dialer helper removed — dialing should not be triggered from
  // the Checkout print flow. If you need a separate payment action that
  // launches the dialer, implement it as its own user action and call the
  // appropriate platform APIs from there.

  @override
  void initState() {
    super.initState();
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _amountReceivedController = TextEditingController(text: '');
    _amountReceivedController.addListener(_updateChange);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _amountReceivedController.removeListener(_updateChange);
    _amountReceivedController.dispose();
    super.dispose();
  }

  void _updateChange() {
    final raw =
        _amountReceivedController.text.replaceAll(RegExp('[^0-9.]'), '');
    final parsed = double.tryParse(raw);
    setState(() {
      _amountReceived = parsed ?? 0.0;
      _change =
          (_amountReceived - (context.read<BillingBloc>().state.totalAmount));
    });
  }

  double _phaseForOperator(Operator op) {
    switch (op) {
      case Operator.mvola:
        return 0.0;
      case Operator.orange:
        return 2 * math.pi / 3;
      case Operator.airtel:
        return 4 * math.pi / 3;
    }
  }

  Widget _operatorButton(Operator op, String label) {
    final selected = _selectedOperator == op;
    final phase = _phaseForOperator(op);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedOperator = op),
      onTapUp: (_) {
        setState(() {
          _pressedOperator = null;
          _selectedOperator = op;
        });
      },
      onTapCancel: () => setState(() => _pressedOperator = null),
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final dy =
              math.sin((_floatController.value * 2 * math.pi) + phase) * 4;
          final isPressed = _pressedOperator == op;
          final scale = isPressed ? 0.92 : (selected ? 0.98 : 1.0);
          return Transform.translate(
            offset: Offset(0, dy),
            child: Column(
              children: [
                AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: selected ? _operatorColor() : Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? _operatorColor() : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: _operatorColor().withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          op == Operator.mvola
                              ? 'assets/mvola_logo.png'
                              : op == Operator.orange
                                  ? 'assets/orange_logo.png'
                                  : 'assets/airtel_logo.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E5EA);

    return PopScope(
        // allow normal back navigation; do NOT clear the cart when returning
        // to the previous screen so the user's selections remain intact.
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          // no-op: we intentionally avoid clearing the cart here
          return;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Ajouter plus',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  // Return to product selection without clearing the cart
                  context.pop();
                },
              ),
              IconButton(
                tooltip: 'Vider le panier',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // Clear the cart for a new customer
                  context.read<BillingBloc>().add(ClearCartEvent());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Panier vidé'),
                    duration: Duration(seconds: 2),
                  ));
                },
              ),
            ],
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                // Persist the sale before clearing the cart. Build a sale map
                // from current billing state and page-local context (amounts).
                try {
                  final id = const Uuid().v4();
                  final uid =
                      FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

                  final sale = SaleModel.fromCart(
                    id: id,
                    date: DateTime.now(),
                    cartItems: state.cartItems,
                    total: state.totalAmount,
                    paymentMethod: _selectedOperator?.toString() ?? 'Espèces',
                    amountReceived: _amountReceived,
                    change: _change,
                    uid: uid,
                  );

                  HiveDatabase.addSaleMap(sale.toMap());
                } catch (_) {}
                // Show a modern success sheet with a small bounce animation.
                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) {
                    return Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              builder: (context, val, child) {
                                return Transform.scale(
                                  scale: val,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 56),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text('Transaction réussie',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                );

                // Close the sheet after a short delay and clear the cart for a
                // new customer.
                Future.delayed(const Duration(milliseconds: 1400), () {
                  try {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  } catch (_) {}
                  if (!mounted) return;
                  context.read<BillingBloc>().add(ClearCartEvent());
                });
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                // shopState may provide shop details (phone numbers, logo, etc.)

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Table or empty cart state
                            if (billingState.cartItems.isEmpty)
                              Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_cart_outlined,
                                          size: 72,
                                          color: Theme.of(context).hintColor),
                                      const SizedBox(height: 12),
                                      const Text('Votre panier est vide',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            context.push('/products'),
                                        icon:
                                            const Icon(Icons.add_shopping_cart),
                                        label:
                                            const Text('Ajouter des produits'),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Table(
                                    border: TableBorder(
                                      horizontalInside:
                                          BorderSide(color: borderColor),
                                      bottom: BorderSide(color: borderColor),
                                    ),
                                    children: [
                                      // Header row
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF2A2A2A)
                                              : const Color(0xFFF8FAFC),
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: borderColor)),
                                        ),
                                        children: [
                                          _buildHeaderCell(
                                              'Nom du produit', TextAlign.left),
                                          _buildHeaderCell(
                                              'Prix', TextAlign.right),
                                          _buildHeaderCell(
                                              'Total', TextAlign.right),
                                        ],
                                      ),
                                      // Items rows
                                      ...billingState.cartItems.map((item) {
                                        return TableRow(
                                          children: [
                                            _buildDataCell(
                                                '${item.quantity} x ${item.product.name}',
                                                TextAlign.left),
                                            _buildDataCell(
                                                '${formatMGA(item.product.price)} Ar',
                                                TextAlign.right,
                                                isSubtitle: true),
                                            _buildDataCell(
                                                '${formatMGA(item.total)} Ar',
                                                TextAlign.right,
                                                isBold: true),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            const SizedBox(
                                height: 120), // padding for bottom fixed bar
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(context)
                                .cardColor
                                .withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                            right: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Choisir un mode de paiement',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Operator selection buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _operatorButton(
                                            Operator.mvola, 'MVola'),
                                        const SizedBox(width: 12),
                                        _operatorButton(
                                            Operator.orange, 'Orange'),
                                        const SizedBox(width: 12),
                                        _operatorButton(
                                            Operator.airtel, 'Airtel'),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Show QR, merchant number and USSD instructions when operator selected
                                    if (_selectedOperator != null)
                                      Column(
                                        children: [
                                          const Text('Scanner le QR Code',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          const SizedBox(height: 8),
                                          // Larger, premium-styled QR area. The QR encodes a
                                          // tel: USSD string so scanning opens the dialer
                                          // with the complete transfer code.
                                          Container(
                                            width: 260,
                                            height: 260,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              color: isDark
                                                  ? const Color(0xFF0B0D0F)
                                                  : Colors.white,
                                              border: Border.all(
                                                color: _operatorColor(),
                                                width: 6,
                                              ),
                                              boxShadow: [
                                                if (isDark)
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  )
                                              ],
                                            ),
                                            child: Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Constrain the QR rendering to fill the
                                                  // available space; PrettyQrView will
                                                  // encode the tel: string so scanners
                                                  // open the phone dialer.
                                                  SizedBox.expand(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: PrettyQrView.data(
                                                        data: _buildQrData(
                                                            _operatorPhone(
                                                                shopState),
                                                            billingState
                                                                .totalAmount),
                                                      ),
                                                    ),
                                                  ),
                                                  // overlay shop (Diary Fashion) logo at center if available
                                                  Builder(builder: (ctx) {
                                                    final settings =
                                                        HiveDatabase
                                                            .settingsBox;
                                                    final logoPath = settings
                                                            .get('shop_logo')
                                                        as String?;
                                                    if (logoPath != null &&
                                                        logoPath.isNotEmpty) {
                                                      final f = File(logoPath);
                                                      if (f.existsSync()) {
                                                        return Container(
                                                          width: 64,
                                                          height: 64,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isDark
                                                                ? Colors.black
                                                                : Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Image.file(
                                                            f,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    // Try a bundled Diary Fashion logo as fallback
                                                    try {
                                                      return Container(
                                                        width: 64,
                                                        height: 64,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isDark
                                                              ? Colors.black
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Image.asset(
                                                          'assets/diary_fashion_logo.png',
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (ctx, err, st) =>
                                                                  const SizedBox
                                                                      .shrink(),
                                                        ),
                                                      );
                                                    } catch (_) {
                                                      return const SizedBox
                                                          .shrink();
                                                    }
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Merchant number and USSD instructions
                                          if ((_operatorPhone(shopState))
                                              .isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 6),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Numéro du commerçant : ${_operatorPhone(shopState)}',
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  SelectableText(
                                                    'USSD: ${_buildUssdString(_operatorPhone(shopState), billingState.totalAmount)}',
                                                    style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      )
                                    else
                                      Column(
                                        children: const [
                                          SizedBox(height: 8),
                                          Text('Aucun mode sélectionné',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          SizedBox(height: 6),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Amount received input
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 8),
                                  child: TextFormField(
                                    controller: _amountReceivedController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    textAlign: TextAlign.end,
                                    decoration: InputDecoration(
                                      hintText: 'Montant reçu',
                                      suffixText: 'Ar',
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ),

                                // Change display
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Rendu',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        '${_change < 0 ? '-' : ''}${formatMGA(_change.abs())} Ar',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _change < 0
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .primaryColor),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'GRAND TOTAL',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      '${formatMGA(billingState.totalAmount)} Ariary',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Builder(builder: (ctx) {
                            final ShopLoaded? shopLoaded =
                                shopState is ShopLoaded ? shopState : null;
                            // Printing should be possible once an operator is selected
                            // and shop information is available. The user will use
                            // the USSD instructions to perform payment; we no longer
                            // require entering amountReceived before printing.
                            final canPrint =
                                _selectedOperator != null && shopLoaded != null;
                            return PrimaryButton(
                              onPressed: canPrint
                                  ? () async {
                                      // Print only when shop state available and amounts ok
                                      context.read<BillingBloc>().add(
                                            PrintReceiptEvent(
                                              shopName: shopLoaded.shop.name,
                                              address1:
                                                  shopLoaded.shop.addressLine1,
                                              email: shopLoaded.shop.email,
                                              phone:
                                                  shopLoaded.shop.phoneNumber,
                                              amountReceived: _amountReceived,
                                              change: _change,
                                              footer:
                                                  shopLoaded.shop.footerText,
                                            ),
                                          );
                                    }
                                  : null,
                              label: 'Imprimer le reçu',
                              icon: Icons.print,
                              isLoading: billingState.isPrinting,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey[300] : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[500];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? subtitleColor : normalColor,
        ),
      ),
    );
  }
}
