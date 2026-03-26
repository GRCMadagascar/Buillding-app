import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/current_shop_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A widget that verifies the current shop's subscription and either
/// shows the child (app content) or an 'Abonnement Expiré' screen.
class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  const SubscriptionGuard({required this.child, super.key});

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  bool _loading = true;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isActive = false;
          _loading = false;
        });
        return;
      }

      final loaded = await CurrentShopService.loadForOwner(user.uid);
      if (!loaded) {
        // No shop yet -> treat as active during trial creation flows
        setState(() {
          _isActive = true;
          _loading = false;
        });
        return;
      }

      final status = CurrentShopService.subscriptionStatus;
      final trialEnd = CurrentShopService.trialEndDate;
      final now = DateTime.now();
      final active =
          (status == 'active') || (trialEnd != null && trialEnd.isAfter(now));
      setState(() {
        _isActive = active;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _isActive = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isActive) return widget.child;

    // Abonnement Expiré screen
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Abonnement Expiré')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 72, color: primary),
              const SizedBox(height: 12),
              const Text('Votre abonnement a expiré',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Veuillez contacter le support ou renouveler via MVola.'),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                onPressed: () {
                  // Launch dialer USSD to merchant or payment flow (owner number in shop profile)
                  // As a simple fallback we open a mailto: to support
                  final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'support@grcmadagascar.mg',
                      queryParameters: {
                        'subject': 'Renouvellement abonnement'
                      });
                  // ignore: prefer_void_to_null
                  launchUrl(emailUri);
                },
                child: const Text('Contacter le support'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  // Placeholder: open payment instructions / USSD flow
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: const Text('Paiement via MVola'),
                            content: const Text(
                                'Veuillez suivre les instructions pour payer via MVola.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Fermer'))
                            ],
                          ));
                },
                child: const Text('Payer via MVola'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Minimal launchUrl to avoid adding url_launcher dependency in this patch.
void launchUrl(Uri uri) {
  // For the purpose of this patch, we can't reliably open external apps
  // from the editing environment. In production, replace this with
  // `url_launcher` package: launchUrl(uri)
  // ignore: avoid_print
  print('Open URL: $uri');
}
