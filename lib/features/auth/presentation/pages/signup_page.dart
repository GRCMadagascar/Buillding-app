import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_page.dart';
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
  }

  @override
  void dispose() {
    _logoController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold1.withValues(alpha: 0.18)),
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
                                          color: gold1.withValues(alpha: 0.6)),
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
                                          color: gold1.withValues(alpha: 0.6)),
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
                                          color: gold1.withValues(alpha: 0.6)),
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
                                          color: gold1.withValues(alpha: 0.6)),
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
                              const SizedBox(height: 24),
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
