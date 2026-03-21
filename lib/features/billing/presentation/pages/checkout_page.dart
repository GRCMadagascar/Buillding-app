import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../../core/data/hive_database.dart';
import 'dart:io';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/billing_bloc.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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
        ussd = '${code}${phone}*${amount.toStringAsFixed(0)}#';
        break;
      case Operator.orange:
        // *144*AMOUNT*RECIPIENT_NUMBER*#
        ussd = '${code}${amount.toStringAsFixed(0)}*${phone}#';
        break;
      case Operator.airtel:
        // *333*RECIPIENT_NUMBER*AMOUNT*# (assumed similar to Mvola)
        ussd = '${code}${phone}*${amount.toStringAsFixed(0)}#';
        break;
      default:
        ussd = '${code}${phone}*${amount.toStringAsFixed(0)}#';
    }

    final encoded = ussd.replaceAll('#', '%23');
    return 'tel:$encoded';
  }

  Future<void> _launchUSSD(ShopState shopState, double amount) async {
    final phone = _operatorPhone(shopState);
    if (phone.isEmpty || _selectedOperator == null) {
      sbh.showAppSnackBar('Operator phone not configured', isError: true);
      return;
    }

    final uriString = _buildQrData(phone, amount);
    if (uriString.isEmpty) {
      sbh.showAppSnackBar('Unable to build USSD', isError: true);
      return;
    }

    final uri = Uri.parse(uriString);
    try {
      if (!await launchUrl(uri)) {
        sbh.showAppSnackBar('Could not open dialer', isError: true);
      }
    } catch (e) {
      sbh.showAppSnackBar('Failed to launch dialer: ${e.toString()}',
          isError: true);
    }
  }

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
        _amountReceivedController.text.replaceAll(RegExp('[^0-9\.]'), '');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E5EA);

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

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
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
                                color: isDark
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
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
                            ? Theme.of(context).cardColor.withOpacity(0.95)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                            right: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                                          Text(
                                            'Mobile money payment',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.grey[200]
                                                  : Colors.black87,
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
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: _operatorColor(),
                                                        width: 6),
                                                  ),
                                                  child: Center(
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        PrettyQrView.data(
                                                          data: _buildQrData(
                                                              _operatorPhone(
                                                                  shopState),
                                                              billingState
                                                                  .totalAmount),
                                                        ),
                                                        // overlay processed logo at center if available
                                                        Builder(builder: (ctx) {
                                                          final settings =
                                                              HiveDatabase
                                                                  .settingsBox;
                                                          final logoPath =
                                                              settings.get(
                                                                      'shop_logo')
                                                                  as String?;
                                                          if (logoPath !=
                                                                  null &&
                                                              logoPath
                                                                  .isNotEmpty) {
                                                            final f =
                                                                File(logoPath);
                                                            if (f
                                                                .existsSync()) {
                                                              return Container(
                                                                width: 48,
                                                                height: 48,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                color: Colors
                                                                    .white,
                                                                child:
                                                                    Image.file(
                                                                  f,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          return const SizedBox
                                                              .shrink();
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // small spacer to separate QR from surrounding elements
                                                const SizedBox(height: 6),
                                              ],
                                            ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
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
                                      hintText: 'Vola nomena',
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
                                      const Text('Fameriny',
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
                          PrimaryButton(
                            onPressed: () async {
                              if (shopState is ShopLoaded) {
                                if (_amountReceived <
                                    billingState.totalAmount) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Amount received is less than total'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                // If an operator is selected, initiate USSD dial before printing
                                if (_selectedOperator != null) {
                                  await _launchUSSD(
                                      shopState, billingState.totalAmount);
                                }

                                context.read<BillingBloc>().add(
                                      PrintReceiptEvent(
                                        shopName: shopState.shop.name,
                                        address1: shopState.shop.addressLine1,
                                        address2: shopState.shop.addressLine2,
                                        phone: shopState.shop.phoneNumber,
                                        amountReceived: _amountReceived,
                                        change: _change,
                                        footer: shopState.shop.footerText,
                                      ),
                                    );
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
