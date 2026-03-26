import 'package:flutter/material.dart';

class NoAccessPage extends StatelessWidget {
  final String message;
  const NoAccessPage({this.message = 'Accès refusé', super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accès')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 72, color: Colors.red),
            const SizedBox(height: 12),
            Text(message,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Vous n\'avez pas les autorisations nécessaires pour accéder à cette page.'),
          ],
        ),
      ),
    );
  }
}
