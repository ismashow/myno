import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'page_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
// MUDANÇA: Removemos o 'open_filex' que abre externamente
// import 'package:open_filex/open_filex.dart';
// MUDANÇA: Adicionamos a nossa nova tela de visualizador interno
import 'pdf_viewer_screen.dart';

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

  // Todo o seu código de _deleteTopic, _confirmDeleteTopic, _showAddOptions,
  // _showAddTextTopicDialog, e _addPdfTopic continua EXATAMENTE IGUAL.
  // Cole-o aqui ou use a versão completa abaixo.

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _deleteTopic(SubNotebook topic) async {
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
    widget.onDataChanged();
  }

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

  void _showAddOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D2D3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Adicionar ao Caderno',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.white),
                title: const Text('Novo Tópico de Texto',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddTextTopicDialog();
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
                title: const Text('Adicionar PDF do Computador',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _addPdfTopic();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                          type: TopicType.text,
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

  Future<void> _addPdfTopic() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final originalFile = File(result.files.single.path!);
      final originalFileName = result.files.single.name;

      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(appDir.path, 'myno_files'));

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final fileExtension = p.extension(originalFileName);
      final newFileName =
          '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final newPath = p.join(targetDir.path, newFileName);

      await originalFile.copy(newPath);

      setState(() {
        widget.notebook.topics.add(SubNotebook(
          id: DateTime.now().toString(),
          title: originalFileName,
          content: newPath,
          type: TopicType.pdf,
        ));
      });
      widget.onDataChanged();
    } catch (e) {
      print("Erro ao adicionar PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar o ficheiro PDF.')),
        );
      }
    }
  }

  // A única alteração é no `build`, na secção `onTap`
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: const Color(0xFF1E3A4B),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A4B), Color(0xFF1B2833)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
          itemCount: widget.notebook.topics.length,
          itemBuilder: (context, index) {
            final topic = widget.notebook.topics[index];
            return Card(
              color: Colors.white.withAlpha(20),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(
                  topic.type == TopicType.text
                      ? Icons.notes
                      : Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                ),
                title: Text(topic.title,
                    style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteTopic(topic),
                ),
                onTap: () async {
                  if (topic.type == TopicType.text) {
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
                    // --- MUDANÇA PRINCIPAL AQUI ---
                    // Em vez de usar OpenFilex, navegamos para a nossa nova tela
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          filePath: topic.content,
                        ),
                      ),
                    );
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
