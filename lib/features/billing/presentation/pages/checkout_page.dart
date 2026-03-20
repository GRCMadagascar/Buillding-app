import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/billing_bloc.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:billing_app/core/utils/snackbar_helper.dart' as sbh;

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
        return const Color(0xFFFF8C00); // Orange
      case Operator.airtel:
        return const Color(0xFFD32F2F); // Red
      default:
        return const Color(0xFFE5E5EA);
    }
  }

  String _operatorCode() {
    switch (_selectedOperator) {
      case Operator.mvola:
        return '*111*';
      case Operator.orange:
        return '*130*';
      case Operator.airtel:
        return '*182*';
      default:
        return '*123*';
    }
  }

  String _buildQrData(String phone, double amount) {
    if (phone.isEmpty || _selectedOperator == null) return '';
    final code = _operatorCode();
    final ussd = '$code$phone*${amount.toStringAsFixed(0)}#';
    final encoded = ussd.replaceAll('#', '%23');
    return 'tel:$encoded';
  }

  @override
  void initState() {
    super.initState();
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
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

  void _onPayPressed(ShopState shopState, double amount) async {
    final phone = _operatorPhone(shopState);
    if (phone.isEmpty || _selectedOperator == null) {
      sbh.showAppSnackBar('Operator phone not configured', isError: true);
      return;
    }

    final code = _operatorCode();
    final ussd = '$code$phone*${amount.toStringAsFixed(0)}#';

    // Show a simple dialog with the generated USSD and option to copy
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('USSD Payment'),
        content: Text('Dial this code to pay:\n$ussd'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ussd));
              sbh.showAppSnackBar('USSD code copied', isError: false);
              Navigator.of(ctx).pop();
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                                color: _operatorColor().withOpacity(0.2),
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
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          context.read<BillingBloc>().add(ClearCartEvent());
          context.go('/');
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.read<BillingBloc>().add(ClearCartEvent());
                context.go('/');
              },
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Printed successfully'),
                    backgroundColor: Colors.green));
                // context.read<BillingBloc>().add(ClearCartEvent());
                // context.go('/');
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Shop';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Table
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside:
                                        BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    // Header row
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(
                                            bottom:
                                                BorderSide(color: borderColor)),
                                      ),
                                      children: [
                                        _buildHeaderCell(
                                            'Product Name', TextAlign.left),
                                        _buildHeaderCell(
                                            'Price', TextAlign.right),
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
                                            TextAlign.left,
                                          ),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                                upiId.isNotEmpty
                                    ? Column(
                                        children: [
                                          const Text(
                                            'Mobile money payment',
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
                                          // Show QR only when operator selected
                                          if (_selectedOperator != null)
                                            Column(
                                              children: [
                                                Container(
                                                  width: 190,
                                                  height: 190,
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: _operatorColor(),
                                                        width: 4),
                                                  ),
                                                  child: PrettyQrView.data(
                                                    data: _buildQrData(
                                                        _operatorPhone(
                                                            shopState),
                                                        billingState
                                                            .totalAmount),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Pay button triggers USSD generation
                                                PrimaryButton(
                                                  onPressed: () =>
                                                      _onPayPressed(
                                                          shopState,
                                                          billingState
                                                              .totalAmount),
                                                  label: 'Pay',
                                                  icon: Icons.payment,
                                                ),
                                              ],
                                            ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'GRAND TOTAL',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      '${formatMGA(billingState.totalAmount)} Ariary',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PrimaryButton(
                            onPressed: () {
                              if (shopState is ShopLoaded) {
                                context.read<BillingBloc>().add(
                                    PrintReceiptEvent(
                                        shopName: shopState.shop.name,
                                        address1: shopState.shop.addressLine1,
                                        address2: shopState.shop.addressLine2,
                                        phone: shopState.shop.phoneNumber,
                                        footer: shopState.shop.footerText));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Shop details not loaded'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            label: 'Print Receipt',
                            icon: Icons.print,
                            isLoading: billingState.isPrinting,
                          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}
