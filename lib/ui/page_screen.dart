import 'package:flutter/material.dart';
import '../models/notebook_models.dart';

class PageScreen extends StatefulWidget {
  final SubNotebook topic;

  const PageScreen({super.key, required this.topic});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    // Inicia o controlador com o texto salvo do tópico.
    _textController = TextEditingController(text: widget.topic.content);
  }

  @override
  void dispose() {
    // SALVAMENTO AUTOMÁTICO: Ao sair da tela, o texto é salvo no tópico.
    widget.topic.content = _textController.text;
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2833), // Cor de fundo geral
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          // Permite rolar se o teclado aparecer
          padding: const EdgeInsets.all(24.0),
          child: AspectRatio(
            // Proporção de uma folha A4 (210mm / 297mm)
            aspectRatio: 210 / 297,
            child: Container(
              decoration: BoxDecoration(
                // A cor que você pediu: rgb(35, 38, 47)
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
                maxLines: null, // Permite infinitas linhas
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none, // Sem bordas
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
