import 'dart:ui';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_page.dart';
// user_firestore_helper not used here; shop/user creation handled inline
import '../../../../core/services/current_user_service.dart';
import '../../../../core/services/current_shop_service.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _role = 'admin'; // admin | staff | solo
  late final TextEditingController _shopCodeController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _loading = false;

  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _shopCodeController = TextEditingController();
  }

  /// Generate a unique shop code in the format GRC-XXXXX (5 alphanumeric chars).
  Future<String> _generateUniqueShopCode(FirebaseFirestore firestore) async {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = math.Random();
    for (var attempt = 0; attempt < 10; attempt++) {
      final part =
          List.generate(5, (_) => chars[rnd.nextInt(chars.length)]).join();
      final candidate = 'GRC-$part';
      final q = await firestore
          .collection('shops')
          .where('shopCode', isEqualTo: candidate)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return candidate;
    }
    // fallback to timestamp-derived code
    return 'GRC-${DateTime.now().millisecondsSinceEpoch % 100000}'
        .toUpperCase();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _shopCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    // read password from controller (validators use controller too)
    _password = _passwordController.text;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      // update display name if provided
      if ((_name).isNotEmpty) await cred.user?.updateDisplayName(_name);
      await cred.user?.sendEmailVerification();
      // Role-specific shop handling:
      try {
        final user = cred.user;
        if (user != null) {
          final firestore = FirebaseFirestore.instance;
          String shopId = '';

          if (_role == 'staff') {
            // Staff must provide a valid shop code
            final entered = _shopCodeController.text.trim();
            // ensure it matches expected prefix; if user omitted prefix, try to be forgiving
            var codeToCheck = entered;
            if (!codeToCheck.toUpperCase().startsWith('GRC-')) {
              codeToCheck = 'GRC-${codeToCheck.toUpperCase()}';
            }
            final q = await firestore
                .collection('shops')
                .where('shopCode', isEqualTo: codeToCheck)
                .limit(1)
                .get();
            if (q.docs.isEmpty) {
              // invalid shop code
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code Boutique tsy hita')));
              }
              setState(() => _loading = false);
              return;
            }
            shopId = q.docs.first.id;
            // Save user doc with role and shopId
            final foundShopCode =
                q.docs.first.data()['shopCode'] as String? ?? codeToCheck;
            await firestore.collection('users').doc(user.uid).set({
              'name': _name,
              'email': _email,
              'role': 'vendeur', // system role key for staff
              'shopId': shopId,
              'shopCode': foundShopCode,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            // Save shopCode locally as well
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('current_shop_code', foundShopCode);
            } catch (_) {}
          } else {
            // Admin or Solo -> generate unique shop code and create shop
            final code = await _generateUniqueShopCode(firestore);
            final shopData = {
              'shopCode': code,
              'shopName': _name.isNotEmpty ? _name : 'Ma Boutique',
              'ownerUid': user.uid,
              'logoUrl': null,
              'primaryColor': null,
              'subscriptionStatus': 'trial',
              'trialEndDate': Timestamp.fromDate(
                  DateTime.now().add(const Duration(days: 7))),
              'planType': 'trial',
              'createdAt': FieldValue.serverTimestamp(),
            };
            final doc = await firestore.collection('shops').add(shopData);
            shopId = doc.id;

            // save user doc (solo and admin map to admin role in system)
            await firestore.collection('users').doc(user.uid).set({
              'name': _name,
              'email': _email,
              'role': _role, // could be 'admin' or 'solo'
              'shopId': shopId,
              'shopCode': code,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            // Save shopCode locally
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('current_shop_code', code);
            } catch (_) {}
          }

          // Save to SharedPreferences locally
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_role', _role);
            await prefs.setString('current_shop_id', shopId);
          } catch (_) {}

          // For Admin & Solo, show shop code pop-up after signup
          String? createdShopCode;
          if (_role == 'staff') {
            // staff flow already saved shopCode earlier as foundShopCode
            // attempt to read it from the saved prefs
            try {
              final prefs = await SharedPreferences.getInstance();
              createdShopCode = prefs.getString('current_shop_code');
            } catch (_) {}
          } else {
            // admin/solo path saved 'shopCode' variable into prefs as 'current_shop_code'
            try {
              final prefs = await SharedPreferences.getInstance();
              createdShopCode = prefs.getString('current_shop_code');
            } catch (_) {}
          }

          if ((_role == 'admin' || _role == 'solo') &&
              createdShopCode != null) {
            // show dialog and wait for user action before navigating on
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('Faly miarahaba anao!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ity ny Code Boutique-nao:'),
                      const SizedBox(height: 8),
                      SelectableText(createdShopCode!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          if (createdShopCode != null) {
                            await Clipboard.setData(
                                ClipboardData(text: createdShopCode));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copié')));
                            }
                          }
                        },
                        child: const Text('Copy')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Continue')),
                  ],
                );
              },
            );
          }

          // Load current user and shop into memory
          await CurrentUserService.loadForUid(user.uid);
          // if staff we loaded shop by id; use new helper to load by id
          await CurrentShopService.loadForId(shopId);
        }
      } catch (e) {
        // swallow shop creation errors but notify
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
      if (!mounted) return;
      // Use page transition back to login/verification flow
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const EmailVerificationPage(),
          transitionsBuilder: (c, a1, a2, child) {
            final curve = CurvedAnimation(parent: a1, curve: Curves.easeInOut);
            return SlideTransition(
                position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(curve),
                child: FadeTransition(opacity: curve, child: child));
          }));
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Erreur lors de l\'inscription';
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Erreur inconnue')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _backToLogin() {
    final page = PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const LoginPage(),
        transitionsBuilder: (context, a1, a2, child) {
          final fade = CurvedAnimation(parent: a1, curve: Curves.easeInOut);
          return SlideTransition(
              position: Tween(begin: const Offset(-1, 0), end: Offset.zero)
                  .animate(fade),
              child: FadeTransition(opacity: fade, child: child));
        });
    Navigator.of(context).pushReplacement(page);
  }

  @override
  Widget build(BuildContext context) {
    final gold1 = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [gold1, const Color(0xFFB8860B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48)),
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                final dy = (math.sin(_logoController.value * 2 * math.pi) * 6);
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Center(
                  child: Image.asset('assets/grc_logo.png',
                      width: 96, height: 96)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold1.withOpacity(0.18)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Créer un compte',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Nom complet',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: gold1.withOpacity(0.6)),
                                      borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: gold1),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Veuillez entrer votre nom complet'
                                    : null,
                                onSaved: (v) => _name = v!.trim(),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: gold1.withOpacity(0.6)),
                                      borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: gold1),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Veuillez entrer un email'
                                    : null,
                                onSaved: (v) => _email = v!.trim(),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: gold1.withOpacity(0.6)),
                                      borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: gold1),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mot de passe (>=6 caractères)'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Confirmer le mot de passe',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: gold1.withOpacity(0.6)),
                                      borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: gold1),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null ||
                                        v != _passwordController.text)
                                    ? 'Les mots de passe ne correspondent pas'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              // Role selection
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Safidy andraikitra',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      activeColor: gold1,
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text(
                                          'Admin (Tompon\'ny fivarotana)',
                                          style:
                                              TextStyle(color: Colors.white70)),
                                      value: 'admin',
                                      groupValue: _role,
                                      onChanged: (v) =>
                                          setState(() => _role = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      activeColor: gold1,
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text('Staff (Caisier)',
                                          style:
                                              TextStyle(color: Colors.white70)),
                                      value: 'staff',
                                      groupValue: _role,
                                      onChanged: (v) =>
                                          setState(() => _role = v!),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              RadioListTile<String>(
                                activeColor: gold1,
                                title: const Text('Solo (Admin & Caisier)',
                                    style: TextStyle(color: Colors.white70)),
                                value: 'solo',
                                groupValue: _role,
                                onChanged: (v) => setState(() => _role = v!),
                              ),

                              // Conditional 'Code Boutique' for staff
                              if (_role == 'staff') ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _shopCodeController,
                                  decoration: InputDecoration(
                                    labelText: 'Code Boutique',
                                    labelStyle:
                                        const TextStyle(color: Colors.white70),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: gold1.withOpacity(0.6)),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: gold1),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  validator: (v) => (_role == 'staff' &&
                                          (v == null || v.isEmpty))
                                      ? 'Azafady ampidiro ny Code Boutique'
                                      : null,
                                ),
                              ],

                              const SizedBox(height: 18),
                              if (_loading)
                                const CircularProgressIndicator()
                              else
                                GoldGradientButton(
                                    onPressed: _submit,
                                    child: const Text("S’INSCRIRE",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Déjà un compte ?',
                                      style: TextStyle(color: Colors.white70)),
                                  TextButton(
                                      onPressed: _backToLogin,
                                      child: const Text('Se connecter',
                                          style:
                                              TextStyle(color: Colors.white70)))
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
