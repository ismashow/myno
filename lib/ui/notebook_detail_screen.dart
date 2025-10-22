import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'page_screen.dart';
import 'package:file_picker/file_picker.dart'; // Importa a ferramenta para escolher ficheiros
import 'package:path_provider/path_provider.dart'; // Importa a ferramenta para encontrar pastas
import 'package:path/path.dart'
    as p; // Importa a ferramenta para manipular caminhos
import 'package:open_filex/open_filex.dart'; // Importa a ferramenta para abrir ficheiros
import 'dart:io'; // Importa as ferramentas de operações de ficheiros

class NotebookScreen extends StatefulWidget {
  final Notebook notebook;
  final VoidCallback onDataChanged;

  const NotebookScreen({
    super.key,
    required this.notebook,
    required this.onDataChanged,
  });

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  // Lógica para apagar um tópico
  void _deleteTopic(SubNotebook topic) async {
    // Se o tópico for um PDF, apaga o ficheiro guardado no computador
    if (topic.type == TopicType.pdf) {
      try {
        final file = File(topic.content);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print("Erro ao apagar ficheiro: $e");
      }
    }

    setState(() {
      widget.notebook.topics.remove(topic);
    });
    widget.onDataChanged(); // Salva a lista de tópicos atualizada
  }

  // Mostra a caixa de diálogo para confirmar a exclusão
  void _confirmDeleteTopic(SubNotebook topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2D3A),
        title:
            const Text('Excluir Tópico', style: TextStyle(color: Colors.white)),
        content: Text('Você tem certeza que quer excluir "${topic.title}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteTopic(topic);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // NOVO: Mostra as opções de "Texto" ou "PDF"
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D2D3A),
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.white),
              title: const Text('Novo Tópico de Texto',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddTextTopicDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
              title: const Text('Adicionar PDF do Computador',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _addPdfTopic();
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog para adicionar tópico de texto (código antigo)
  void _showAddTextTopicDialog() {
    _topicController.clear();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1D2D3A),
              title: const Text('Novo Tópico',
                  style: TextStyle(color: Colors.white)),
              content: TextField(
                controller: _topicController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration:
                    const InputDecoration(hintText: "Título do novo tópico..."),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_topicController.text.isNotEmpty) {
                      setState(() {
                        widget.notebook.topics.add(SubNotebook(
                          id: DateTime.now().toString(),
                          title: _topicController.text,
                          type: TopicType.text, // Define o tipo como texto
                        ));
                      });
                      widget.onDataChanged();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Criar'),
                )
              ],
            ));
  }

  // NOVA FUNÇÃO: Lógica para adicionar um PDF local
  Future<void> _addPdfTopic() async {
    try {
      // 1. Pedir ao utilizador para escolher um PDF
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        return; // O utilizador cancelou
      }

      final originalFile = File(result.files.single.path!);
      final originalFileName = result.files.single.name;

      // 2. Encontrar a pasta segura da aplicação
      final appDir = await getApplicationDocumentsDirectory();
      // Cria uma subpasta 'myno_files' para organizar
      final targetDir = Directory(p.join(appDir.path, 'myno_files'));

      // 3. Criar a pasta se ela não existir
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 4. Criar um caminho de destino único para evitar conflitos
      final fileExtension = p.extension(originalFileName);
      final newFileName =
          '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final newPath = p.join(targetDir.path, newFileName);

      // 5. Copiar o ficheiro para a pasta segura
      await originalFile.copy(newPath);

      // 6. Adicionar o tópico à lista e salvar
      setState(() {
        widget.notebook.topics.add(SubNotebook(
          id: DateTime.now().toString(),
          title: originalFileName, // Guarda o nome original para exibição
          content: newPath, // Guarda o NOVO caminho da cópia segura
          type: TopicType.pdf, // Define o tipo como PDF
        ));
      });
      widget.onDataChanged(); // Salva a alteração
    } catch (e) {
      print("Erro ao adicionar PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar o ficheiro PDF.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: const Color(0xFF1E3A4B),
        elevation: 0,
      ),
      // MUDANÇA: O botão de "+" agora chama as novas opções
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A4B), Color(0xFF1B2833)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // MUDANÇA: Não tem mais a coluna nem o _buildTopicInput() aqui
        child: ListView.builder(
          padding:
              const EdgeInsets.fromLTRB(8, 8, 8, 80), // Espaço para o botão
          itemCount: widget.notebook.topics.length,
          itemBuilder: (context, index) {
            final topic = widget.notebook.topics[index];
            return Card(
              color: Colors.white.withAlpha(20),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                // MUDANÇA: O ícone muda de acordo com o tipo
                leading: Icon(
                  topic.type == TopicType.text
                      ? Icons.notes // Ícone de texto
                      : Icons.picture_as_pdf_rounded, // Ícone de PDF
                  color: Colors.white,
                ),
                title: Text(topic.title,
                    style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () =>
                      _confirmDeleteTopic(topic), // Chama a confirmação
                ),
                onTap: () async {
                  // MUDANÇA: A ação de clique muda de acordo com o tipo
                  if (topic.type == TopicType.text) {
                    // Se for texto, abre a tela de escrita
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PageScreen(
                          topic: topic,
                          onSave: widget.onDataChanged,
                        ),
                      ),
                    );
                  } else if (topic.type == TopicType.pdf) {
                    // Se for PDF, pede ao Windows para abrir
                    try {
                      await OpenFilex.open(topic.content);
                    } catch (e) {
                      print("Erro ao abrir ficheiro: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Não foi possível abrir o ficheiro. Pode ter sido movido ou apagado.')),
                      );
                    }
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
