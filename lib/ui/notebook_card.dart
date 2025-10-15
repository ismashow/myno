import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'notebook_detail_screen.dart';
import 'dart:ui';

class NotebookCard extends StatelessWidget {
  final Notebook notebook;
  final VoidCallback? onLongPress;

  const NotebookCard({
    super.key,
    required this.notebook,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotebookScreen(notebook: notebook),
              ),
            );
          },
          onLongPress: onLongPress,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.book_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  notebook.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
