import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'notebook_detail_screen.dart';
import 'dart:ui';

class NotebookCard extends StatelessWidget {
  final Notebook notebook;
  final VoidCallback? onLongPress; // Para apagar
  final VoidCallback onDataChanged; // Para salvar após mudar tag
  // NOVA FUNÇÃO: Chamada quando o botão de tag é clicado
  final Function(Notebook) onTagChangeRequested;

  const NotebookCard({
    super.key,
    required this.notebook,
    this.onLongPress,
    required this.onDataChanged,
    required this.onTagChangeRequested, // Torna obrigatório
  });

  @override
  Widget build(BuildContext context) {
    // Cor baseada na tag (opcional, para visualização)
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
            // Usamos Stack para posicionar o botão de tag
            children: [
              // Conteúdo principal do card (ícone e título)
              GestureDetector(
                onTap: () {
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
                onLongPress: onLongPress, // Mantém a função de apagar
                child: Container(
                  // Container extra para garantir que o GestureDetector ocupe a área
                  color: Colors
                      .transparent, // Transparente para não afetar o visual
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_rounded,
                        color: Colors.white
                            .withOpacity(0.8), // Levemente transparente
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
                      // Mostra a tag atual (opcional)
                      const SizedBox(height: 8),
                      Text(
                        statusTagToString(notebook.statusTag),
                        style: TextStyle(
                          color: tagColor.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // NOVO: Botão para alterar a tag posicionado no canto superior direito
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(Icons.sell_outlined,
                      color: tagColor), // Ícone de etiqueta
                  tooltip:
                      'Alterar Tag de Estado', // Texto ao passar o rato por cima
                  onPressed: () => onTagChangeRequested(notebook),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função auxiliar para dar uma cor a cada tag (opcional)
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
