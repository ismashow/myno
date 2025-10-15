import 'package:flutter/material.dart';
import '../models/notebook_models.dart';

class PageScreen extends StatefulWidget {
  final SubNotebook topic;
  // CORREÇÃO: Adicionando o parâmetro 'onSave' que estava faltando.
  final VoidCallback onSave;

  const PageScreen({
    super.key,
    required this.topic,
    required this.onSave, // Tornando-o obrigatório no construtor.
  });

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.topic.content);
  }

  @override
  void dispose() {
    // Salva automaticamente ao sair se o texto foi alterado.
    if (widget.topic.content != _textController.text) {
      widget.topic.content = _textController.text;
      widget.onSave(); // Usa o parâmetro para acionar o salvamento.
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2833),
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AspectRatio(
            aspectRatio: 210 / 297,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(35, 38, 47, 1),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, height: 1.5),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Comece a escrever...',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
