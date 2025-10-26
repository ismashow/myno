// Enum para os tipos de tópico (texto ou pdf)
enum TopicType { text, pdf }

// NOVO: Enum para as tags de estado do caderno
enum StatusTag {
  caixaDeIdeias,
  emAndamento,
  emTeste,
  concluido,
  nenhum // Um estado padrão ou para quando não se aplica
}

// Função auxiliar para obter o texto da tag (ex: "Caixa de Ideias")
String statusTagToString(StatusTag tag) {
  switch (tag) {
    case StatusTag.caixaDeIdeias:
      return 'Caixa de Ideias';
    case StatusTag.emAndamento:
      return 'Em Andamento';
    case StatusTag.emTeste:
      return 'Em Teste';
    case StatusTag.concluido:
      return 'Concluído';
    case StatusTag.nenhum:
      // Pode ajustar este texto se preferir algo diferente para "sem tag"
      return 'Sem Tag';
  }
}

// Função auxiliar para obter a tag a partir do texto guardado (para carregar dados)
StatusTag statusTagFromString(String? tagString) {
  return StatusTag.values.firstWhere(
    (e) =>
        e.toString() ==
        tagString, // Compara o texto guardado com os valores do enum
    orElse: () => StatusTag
        .nenhum, // Se não encontrar (dados antigos), define como 'nenhum'
  );
}

class Area {
  final String id;
  final String title;
  final List<Notebook> notebooks;

  Area({required this.id, required this.title, required this.notebooks});

  // Converte um objeto Area para um formato de mapa (JSON) para guardar
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notebooks': notebooks.map((notebook) => notebook.toJson()).toList(),
      };

  // Cria um objeto Area a partir de um mapa (JSON) carregado
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
  // NOVOS CAMPOS ADICIONADOS
  final int creationYear; // Guarda o ano de criação
  StatusTag statusTag; // Guarda a tag de estado (permite ser alterada)

  Notebook({
    required this.id,
    required this.title,
    required this.topics,
    required this.creationYear,
    // Define um valor padrão para a tag ao criar um novo caderno
    this.statusTag = StatusTag.caixaDeIdeias,
  });

  // Atualiza toJson para guardar os novos campos
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'topics': topics.map((topic) => topic.toJson()).toList(),
        'creationYear': creationYear, // Guarda o ano
        'statusTag': statusTag
            .toString(), // Guarda a tag como texto (ex: 'StatusTag.emAndamento')
      };

  // Atualiza fromJson para carregar os novos campos (com segurança para dados antigos)
  factory Notebook.fromJson(Map<String, dynamic> json) => Notebook(
        id: json['id'],
        title: json['title'],
        topics: (json['topics'] as List)
            .map((topicJson) => SubNotebook.fromJson(topicJson))
            .toList(),
        // Se 'creationYear' não existir (dados antigos), usa o ano atual como padrão
        creationYear: json['creationYear'] ?? DateTime.now().year,
        // Usa a função auxiliar para carregar a tag a partir do texto guardado
        statusTag: statusTagFromString(json['statusTag']),
      );
}

class SubNotebook {
  final String id;
  final String title;
  String content; // Para texto ou para o caminho do ficheiro PDF
  final TopicType type;

  SubNotebook({
    required this.id,
    required this.title,
    this.content = '',
    this.type = TopicType.text,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type.toString(),
      };

  factory SubNotebook.fromJson(Map<String, dynamic> json) {
    return SubNotebook(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '', // Garante que o conteúdo nunca seja nulo
      // Carrega o tipo, com fallback para 'texto' se for inválido ou ausente
      type: TopicType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TopicType.text,
      ),
    );
  }
}
