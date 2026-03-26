import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_verification_page.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/widgets/gold_gradient_button.dart';
import 'signup_page.dart';
import '../../../../core/services/current_user_service.dart';
import '../../../../core/services/current_shop_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _remember = false;
  bool _loading = false;

  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _loadRemember();
  }

  Future<void> _loadRemember() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    setState(() => _remember = remember);

    // If user asked to be remembered and there's a current Firebase user
    // which is already verified, navigate to home automatically.
    final user = FirebaseAuth.instance.currentUser;
    if (remember && user != null && user.emailVerified) {
      if (!mounted) return;
      // delay to allow the page to finish building
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      final user = cred.user;
      if (user == null)
        throw FirebaseAuthException(
            code: 'no-user', message: 'Utilisateur introuvable');

      if (!user.emailVerified) {
        // Save remember flag even if not verified so we can auto-redirect after verification
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', _remember);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Veuillez vérifier votre e-mail avant de vous connecter')));
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmailVerificationPage()));
        }
        return;
      }

      // Persist remember flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _remember);

      // Load current user role and shop into memory for RBAC and branding
      try {
        await CurrentUserService.loadForUid(user.uid);
        await CurrentShopService.loadForOwner(user.uid);
      } catch (_) {}

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      String msg = 'Erreur de connexion';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found')
          msg = 'Utilisateur non trouvé';
        else if (e.code == 'wrong-password')
          msg = 'Mot de passe incorrect';
        else
          msg = e.message ?? msg;
      }
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToSignUp() {
    final page = PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const SignUpPage(),
        transitionsBuilder: (context, a1, a2, child) {
          final fade = CurvedAnimation(parent: a1, curve: Curves.easeInOut);
          return SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(fade),
              child: FadeTransition(opacity: fade, child: child));
        });
    Navigator.of(context).push(page);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null)
        throw FirebaseAuthException(
            code: 'no-user', message: 'Utilisateur introuvable');

      // Google accounts are verified by default
      // Persist remember flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _remember);

      // Save minimal profile into Hive settings for app usage
      try {
        final box = HiveDatabase.settingsBox;
        await box.put('user_profile', {
          'uid': user.uid,
          'name': user.displayName ?? googleUser.displayName ?? '',
          'email': user.email ?? googleUser.email,
          'photoUrl': user.photoURL ?? googleUser.photoUrl
        });
      } catch (_) {}

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      var msg = 'Erreur lors de la connexion Google';
      if (e is FirebaseAuthException) msg = e.message ?? msg;
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold1 = const Color(0xFFD4AF37);
    final gold2 = const Color(0xFFF9F06B);
    final gold3 = const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top gold wave background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [gold1, gold3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48)),
              ),
            ),
          ),

          // Floating logo
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
                child:
                    Image.asset('assets/grc_logo.png', width: 96, height: 96),
              ),
            ),
          ),

          // Main glass card
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
                        const Text('Connexion',
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
                                style: const TextStyle(color: Colors.white),
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
                                      borderSide: BorderSide(color: gold2),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Veuillez entrer un email'
                                    : null,
                                onSaved: (v) => _email = v!.trim(),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
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
                                      borderSide: BorderSide(color: gold2),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mot de passe (>=6 caractères)'
                                    : null,
                                onSaved: (v) => _password = v!,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                          value: _remember,
                                          onChanged: (v) =>
                                              setState(() => _remember = v!)),
                                      const Text('Se souvenir de moi',
                                          style:
                                              TextStyle(color: Colors.white70))
                                    ],
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        /* TODO: forgot password */
                                      },
                                      child: const Text('Mot de passe oublié ?',
                                          style:
                                              TextStyle(color: Colors.white70)))
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_loading)
                                const CircularProgressIndicator()
                              else
                                GoldGradientButton(
                                  onPressed: _submit,
                                  child: const Text('SE CONNECTER',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(height: 12),

                              // OR divider
                              Row(
                                children: const [
                                  Expanded(
                                      child: Divider(color: Colors.white24)),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('OU',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ),
                                  Expanded(
                                      child: Divider(color: Colors.white24)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Google Sign-In button
                              GestureDetector(
                                onTap: _signInWithGoogle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/google_logo.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (ctx, err, st) =>
                                              const Icon(Icons.g_mobiledata,
                                                  color: Colors.red)),
                                      const SizedBox(width: 12),
                                      const Text('Continuer avec Google',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 32, 32, 32),
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Pas de compte ?',
                                      style: TextStyle(color: Colors.white70)),
                                  TextButton(
                                      onPressed: _goToSignUp,
                                      child: const Text("S’inscrire",
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
