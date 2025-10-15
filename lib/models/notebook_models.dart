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

class SubNotebook {
  final String id;
  final String title;
  String content;

  SubNotebook({
    required this.id,
    required this.title,
    this.content = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
      };

  factory SubNotebook.fromJson(Map<String, dynamic> json) => SubNotebook(
        id: json['id'],
        title: json['title'],
        content: json['content'],
      );
}
