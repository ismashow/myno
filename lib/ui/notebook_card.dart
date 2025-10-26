import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'notebook_detail_screen.dart';
import 'dart:ui';

class NotebookCard extends StatelessWidget {
  final Notebook notebook;
  final VoidCallback? onLongPress; // Para apagar
  final VoidCallback onDataChanged; // Para salvar após mudar tag ou mover
  final Function(Notebook) onTagChangeRequested; // Para mudar tag
  // NOVA FUNÇÃO: Chamada quando o botão MOVER é clicado
  final Function(Notebook) onMoveRequested;

  const NotebookCard({
    super.key,
    required this.notebook,
    this.onLongPress,
    required this.onDataChanged,
    required this.onTagChangeRequested,
    required this.onMoveRequested, // Torna obrigatório
  });

  @override
  Widget build(BuildContext context) {
    Color tagColor = _getTagColor(notebook.statusTag);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Conteúdo principal (clicável para abrir)
              GestureDetector(
                onTap: () {
                  /* Navega para NotebookScreen */
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotebookScreen(
                        notebook: notebook,
                        onDataChanged: onDataChanged,
                      ),
                    ),
                  );
                },
                onLongPress: onLongPress, // Mantém apagar com toque longo
                child: Container(
                  color:
                      Colors.transparent, // Garante que toda a área é clicável
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book_rounded,
                          color: Colors.white70, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        notebook.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusTagToString(notebook.statusTag),
                        style: TextStyle(
                            color: tagColor.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              // Botões no topo
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  // Row para colocar botões lado a lado
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão Mover (NOVO)
                    IconButton(
                      icon: Icon(Icons.open_with,
                          color: Colors.blueGrey.shade200,
                          size: 20), // Ícone de mover
                      tooltip: 'Mover Caderno para outra Área',
                      onPressed: () => onMoveRequested(notebook),
                    ),
                    // Botão Alterar Tag
                    IconButton(
                      icon:
                          Icon(Icons.sell_outlined, color: tagColor, size: 20),
                      tooltip: 'Alterar Tag de Estado',
                      onPressed: () => onTagChangeRequested(notebook),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função auxiliar para cor da tag (igual a antes)
  Color _getTagColor(StatusTag tag) {
    switch (tag) {
      case StatusTag.caixaDeIdeias:
        return Colors.lightBlueAccent.shade100;
      case StatusTag.emAndamento:
        return Colors.orangeAccent.shade100;
      case StatusTag.emTeste:
        return Colors.purpleAccent.shade100;
      case StatusTag.concluido:
        return Colors.greenAccent.shade400;
      case StatusTag.nenhum:
      default:
        return Colors.grey.shade400;
    }
  }
}
