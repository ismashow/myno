import 'package:flutter/material.dart';
import '../models/notebook_models.dart';
import 'add_notebook_card.dart';
import 'notebook_card.dart';
import 'dart:collection'; // Para usar SplayTreeSet para anos ordenados

class AreaView extends StatefulWidget {
  final Area area;
  final Function(String) onAddNotebook; // Função para adicionar novo caderno
  final Function(Notebook) onDeleteNotebook; // Função para apagar caderno
  final VoidCallback
      onDataChanged; // Função para guardar alterações (ex: mudar tag)
  // NOVA FUNÇÃO: Recebe a instrução para iniciar a movimentação do caderno
  final Function(Notebook) onNotebookMoveRequested;

  const AreaView({
    super.key,
    required this.area,
    required this.onAddNotebook,
    required this.onDeleteNotebook,
    required this.onDataChanged,
    required this.onNotebookMoveRequested, // Torna obrigatório receber esta função
  });

  @override
  State<AreaView> createState() => _AreaViewState();
}

class _AreaViewState extends State<AreaView> {
  StatusTag _selectedFilter = StatusTag.nenhum; // Filtro de tag ativo
  int? _selectedYear; // Filtro de ano ativo (null = todos os anos)

  // Função que mostra o diálogo para escolher a nova tag
  void _showChangeTagDialog(Notebook notebook) {
    StatusTag? tempSelectedTag =
        notebook.statusTag; // Guarda a tag selecionada no diálogo

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Usamos um StatefulBuilder para permitir atualizar o estado *dentro* do diálogo
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1D2D3A), // Cor de fundo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Cantos arredondados
              ),
              title: const Text('Alterar Tag de Estado',
                  style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                // Para o caso de muitas tags
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Cria uma opção de rádio para cada tag possível
                  children: StatusTag.values.map((tag) {
                    return RadioListTile<StatusTag>(
                      title:
                          Text(statusTagToString(tag), // Mostra o nome da tag
                              style: const TextStyle(color: Colors.white)),
                      value: tag, // O valor desta opção
                      groupValue:
                          tempSelectedTag, // A opção atualmente selecionada
                      onChanged: (StatusTag? value) {
                        if (value != null) {
                          // Atualiza a seleção temporária dentro do diálogo
                          setDialogState(() {
                            tempSelectedTag = value;
                          });
                        }
                      },
                      activeColor:
                          Colors.tealAccent, // Cor da bolinha selecionada
                      controlAffinity:
                          ListTileControlAffinity.trailing, // Bolinha à direita
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white70)),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha sem fazer nada
                  },
                ),
                ElevatedButton(
                  child: const Text('Confirmar'),
                  onPressed: () {
                    // Só atualiza e guarda se a tag realmente mudou
                    if (tempSelectedTag != null &&
                        tempSelectedTag != notebook.statusTag) {
                      // Atualiza o estado da aplicação E guarda
                      setState(() {
                        notebook.statusTag = tempSelectedTag!;
                      });
                      widget
                          .onDataChanged(); // Chama a função para guardar os dados
                    }
                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Função para mostrar o diálogo de criação de caderno
  void _showAddNotebookDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2D3A),
        title:
            const Text('Novo Caderno', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Título do caderno...',
            hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Chama a função passada pelo HomeScreen para adicionar
                widget.onAddNotebook(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  // Função que aplica os filtros de ano e tag
  List<Notebook> _getFilteredNotebooks() {
    return widget.area.notebooks.where((notebook) {
      // Verifica o filtro de ano
      final yearMatch =
          _selectedYear == null || notebook.creationYear == _selectedYear;
      // Verifica o filtro de tag
      final tagMatch = _selectedFilter == StatusTag.nenhum ||
          notebook.statusTag == _selectedFilter;
      // O caderno só passa se ambos os filtros corresponderem
      return yearMatch && tagMatch;
    }).toList();
  }

  // Widget Dropdown para selecionar o ano
  Widget _buildYearSelector() {
    // Obtém todos os anos únicos dos cadernos e ordena-os
    final years = SplayTreeSet<int>.from(
      widget.area.notebooks.map((nb) => nb.creationYear),
    );
    // Cria os itens do dropdown, adicionando "Todos os Anos" no início
    final items = [
      const DropdownMenuItem<int?>(
        value: null, // Valor nulo representa "todos"
        child: Text("Todos os Anos", style: TextStyle(color: Colors.white70)),
      ),
      ...years.map((year) => DropdownMenuItem<int?>(
            value: year,
            child: Text(year.toString(),
                style: const TextStyle(color: Colors.white)),
          )),
    ];

    // Garante que o valor selecionado existe na lista (evita erro se filtrar e depois remover cadernos)
    final currentSelectedYear =
        years.contains(_selectedYear) ? _selectedYear : null;

    return DropdownButton<int?>(
      value: currentSelectedYear,
      items: items,
      onChanged: (int? newValue) {
        setState(() {
          _selectedYear = newValue;
        });
      },
      // Estilo do dropdown
      dropdownColor: const Color(0xFF1D2D3A),
      underline: Container(), // Remove a linha de baixo padrão
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      style: const TextStyle(color: Colors.white),
    );
  }

  // Widget Dropdown para selecionar a tag
  Widget _buildTagFilter() {
    // Lista de todas as tags possíveis, incluindo "Todas as Tags"
    final tags = [
      StatusTag.nenhum,
      ...StatusTag.values.where((t) => t != StatusTag.nenhum)
    ];
    final items = tags.map((tag) {
      return DropdownMenuItem<StatusTag>(
        value: tag,
        child: Text(
          tag == StatusTag.nenhum ? 'Todas as Tags' : statusTagToString(tag),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }).toList();

    return DropdownButton<StatusTag>(
      value: _selectedFilter,
      items: items,
      onChanged: (StatusTag? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedFilter = newValue;
          });
        }
      },
      dropdownColor: const Color(0xFF1D2D3A),
      underline: Container(),
      icon: const Icon(Icons.filter_list, color: Colors.white70),
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a lista filtrada no início do build
    final filteredNotebooks = _getFilteredNotebooks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha com Título e Filtros
        Padding(
          padding: const EdgeInsets.only(
              left: 24.0, right: 16.0, top: 8.0, bottom: 0),
          child: Row(
            children: [
              // Título da Área
              Text(
                widget.area.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8), // Pequeno espaço
              // Seletor de Ano
              _buildYearSelector(),
              const Spacer(), // Empurra o filtro de tag para a direita
              // Filtro de Tag
              _buildTagFilter(),
            ],
          ),
        ),
        // Grelha de Cadernos
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1, // Mantém a proporção quadrada
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount:
                filteredNotebooks.length + 1, // +1 para o botão adicionar
            itemBuilder: (context, index) {
              // O primeiro item é sempre o botão de adicionar
              if (index == 0) {
                return AddNotebookCard(
                  onTap: () => _showAddNotebookDialog(context),
                );
              }
              // Os restantes itens são os cadernos filtrados
              final notebook = filteredNotebooks[index - 1];
              // Passa todas as funções necessárias para o NotebookCard
              return NotebookCard(
                notebook: notebook,
                onLongPress: () => widget.onDeleteNotebook(notebook), // Apagar
                onDataChanged: widget.onDataChanged, // Guardar (após mudar tag)
                onTagChangeRequested: _showChangeTagDialog, // Mudar tag
                onMoveRequested:
                    widget.onNotebookMoveRequested, // Mover caderno
              );
            },
          ),
        ),
      ],
    );
  }
}
