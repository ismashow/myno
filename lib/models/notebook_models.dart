class Area {
  final String id;
  final String title;
  final List<Notebook> notebooks;

  Area({required this.id, required this.title, required this.notebooks});
}

class Notebook {
  final String id;
  final String title;
  // MUDANÇA: Um caderno agora contém uma lista de "Tópicos" (SubNotebook).
  final List<SubNotebook> topics;

  Notebook({required this.id, required this.title, required this.topics});
}

// MUDANÇA: A antiga classe "Note" agora é "SubNotebook".
// Representa um tópico ou capítulo dentro de um caderno.
class SubNotebook {
  final String id;
  final String title;
  // O conteúdo da página de escrita A4.
  String content;

  SubNotebook({
    required this.id,
    required this.title,
    this.content = '', // Começa com o conteúdo vazio.
  });
}
