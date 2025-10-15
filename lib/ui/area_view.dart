import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'add_notebook_card.dart';
import 'notebook_card.dart';

class AreaView extends StatelessWidget {
  final Area area;
  final Function(String) onAddNotebook;
  final Function(Notebook) onDeleteNotebook;
  final VoidCallback onDataChanged;

  const AreaView({
    super.key,
    required this.area,
    required this.onAddNotebook,
    required this.onDeleteNotebook,
    required this.onDataChanged,
  });

  void _showAddNotebookDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2D3A),
        title:
            const Text('Novo Caderno', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Título do caderno...',
            hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAddNotebook(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            area.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: area.notebooks.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return AddNotebookCard(
                  onTap: () => _showAddNotebookDialog(context),
                );
              }
              final notebook = area.notebooks[index - 1];
              return NotebookCard(
                notebook: notebook,
                onLongPress: () => onDeleteNotebook(notebook),
                onDataChanged: onDataChanged,
              );
            },
          ),
        ),
      ],
    );
  }
}
