import 'package:flutter/material.dart';
import 'dart:ui';

// CORREÇÃO: O nome da classe agora é único.
class AddNotebookCard extends StatelessWidget {
  // A função onTap agora é um parâmetro obrigatório.
  final VoidCallback onTap;

  const AddNotebookCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap, // Usando a função onTap recebida
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withAlpha(100),
                width: 1.5,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  'Novo Caderno',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
