// MUDANÇA: O tipo de tópico agora pode ser texto ou pdf.
enum TopicType { text, pdf }

class Area {
  final String id;
  final String title;
  final List<Notebook> notebooks;

  Area({required this.id, required this.title, required this.notebooks});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notebooks': notebooks.map((notebook) => notebook.toJson()).toList(),
      };

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        id: json['id'],
        title: json['title'],
        notebooks: (json['notebooks'] as List)
            .map((notebookJson) => Notebook.fromJson(notebookJson))
            .toList(),
      );
}

class Notebook {
  final String id;
  final String title;
  final List<SubNotebook> topics;

  Notebook({required this.id, required this.title, required this.topics});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'topics': topics.map((topic) => topic.toJson()).toList(),
      };

  factory Notebook.fromJson(Map<String, dynamic> json) => Notebook(
        id: json['id'],
        title: json['title'],
        topics: (json['topics'] as List)
            .map((topicJson) => SubNotebook.fromJson(topicJson))
            .toList(),
      );
}

// MUDANÇA PRINCIPAL AQUI EMBAIXO
class SubNotebook {
  final String id;
  final String title;
  String content; // Para texto OU para o CAMINHO do ficheiro PDF
  final TopicType type; // O novo campo que diz o que o 'content' é

  SubNotebook({
    required this.id,
    required this.title,
    this.content = '',
    this.type = TopicType.text, // O padrão é ser 'texto'
  });

  // Atualiza o 'toJson' para salvar o tipo
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type.toString(), // Salva 'TopicType.text' ou 'TopicType.pdf'
      };

  // Atualiza o 'fromJson' para ler o tipo
  factory SubNotebook.fromJson(Map<String, dynamic> json) {
    return SubNotebook(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      // Converte o texto 'TopicType.text' de volta para o tipo enum
      type: TopicType.values.firstWhere(
        (e) => e.toString() == json['type'],
        // ISTO SALVA AS SUAS ANOTAÇÕES ANTIGAS!
        // Se não encontrar um 'tipo', assume que é 'texto'.
        orElse: () => TopicType.text,
      ),
    );
  }
}
