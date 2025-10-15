import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'page_screen.dart';

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
  late final TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _addTopic() {
    if (_topicController.text.isNotEmpty) {
      setState(() {
        final newTopic = SubNotebook(
          id: DateTime.now().toString(),
          title: _topicController.text,
        );
        widget.notebook.topics.add(newTopic);
        _topicController.clear();
      });
      widget.onDataChanged();
    }
  }

  void _deleteTopic(SubNotebook topic) {
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
              setState(() {
                widget.notebook.topics.remove(topic);
              });
              widget.onDataChanged();
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: const Color(0xFF1E3A4B),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A4B), Color(0xFF1B2833)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: widget.notebook.topics.length,
                itemBuilder: (context, index) {
                  final topic = widget.notebook.topics[index];
                  return Card(
                    color: Colors.white.withAlpha(20),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(topic.title,
                          style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () => _deleteTopic(topic),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageScreen(
                              topic: topic,
                              onSave: widget.onDataChanged,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            _buildTopicInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicInput() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.black.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome do novo tópico...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
                filled: true,
                fillColor: Colors.white.withAlpha(30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addTopic,
          ),
        ],
      ),
    );
  }
}
