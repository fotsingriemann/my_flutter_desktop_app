import 'dart:io';
import 'package:flutter/material.dart';

class RFIDDialog extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const RFIDDialog({
    super.key,
    required this.name,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(50), // Rayon des bords arrondis
              child: Image.file(
                File(imageUrl!), // Charger l'image locale
                width: 100,
                height: 100,
                fit: BoxFit.cover, // S'assurer que l'image s'ajuste correctement
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error), // Affiche une icône en cas d'erreur
              ),
            ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
