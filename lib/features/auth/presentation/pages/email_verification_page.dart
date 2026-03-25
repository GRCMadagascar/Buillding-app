import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/gold_gradient_button.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _checking = false;

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final verified = user?.emailVerified ?? false;
      if (verified) {
        if (!mounted) return;
        // Navigate to home
        context.go('/');
      } else {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Email non vérifié')));
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la vérification')));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérifiez votre boîte mail')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  'Un email de vérification a été envoyé. Veuillez vérifier votre boîte mail et cliquer sur le lien.'),
              const SizedBox(height: 24),
              if (_checking)
                const CircularProgressIndicator()
              else
                GoldGradientButton(
                  onPressed: _checkVerified,
                  child: const Text('J\'ai vérifié mon email',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.currentUser
                        ?.sendEmailVerification();
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Email de vérification renvoyé')));
                  } catch (_) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Impossible de renvoyer l\'email')));
                  }
                },
                child: const Text('Renvoyer l\'email'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
