import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'add_notebook_card.dart'; // Importa o widget do card de adicionar
import 'notebook_card.dart'; // Importa o widget do card de caderno

class AreaView extends StatelessWidget {
  final Area area;
  final Function(String) onAddNotebook;
  final Function(Notebook) onDeleteNotebook;

  const AreaView({
    super.key,
    required this.area,
    required this.onAddNotebook,
    required this.onDeleteNotebook,
  });

  // Função para mostrar a caixa de diálogo de criação de caderno
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
            // O total de itens é a lista de cadernos + 1 (para o botão de adicionar)
            itemCount: area.notebooks.length + 1,
            itemBuilder: (context, index) {
              // O primeiro item (índice 0) é sempre o botão de adicionar
              if (index == 0) {
                // CORREÇÃO: Usando a classe renomeada 'AddNotebookCard'
                return AddNotebookCard(
                  onTap: () => _showAddNotebookDialog(context),
                );
              }
              // Para os outros itens, pegamos o caderno correspondente na lista
              final notebook = area.notebooks[index - 1];
              // CORREÇÃO: Usando a classe 'NotebookCard' para exibir o caderno
              return NotebookCard(
                notebook: notebook,
                onLongPress: () => onDeleteNotebook(notebook),
              );
            },
          ),
        ),
      ],
    );
  }
}
