import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/notebook_models.dart';
import 'ui/area_view.dart';
import 'ui/lock_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Função para navegar para a tela principal
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Função que será chamada para validar a senha digitada
  Future<bool> _handlePasswordValidation(String enteredPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('user_password');
    final isValid = savedPassword == enteredPassword;
    if (isValid) {
      _navigateToHome(); // Navega se a senha for válida
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Verifica se já existe uma senha salva
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.containsKey('user_password')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final hasPassword = snapshot.data ?? false;

        // Sempre mostra a LockScreen, mas configura de acordo com a necessidade
        return LockScreen(
          isCreatingPassword: !hasPassword, // Se não tem senha, está a criar
          onPasswordCreated: _navigateToHome, // Após criar, navega para home
          onPasswordValidated:
              _handlePasswordValidation, // Para validar, usa esta função
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  List<Area> _areas = []; // A lista de áreas agora começa vazia
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // viewportFraction menor dá mais visibilidade às páginas laterais
    _pageController = PageController(viewportFraction: 0.85);
    _loadData(); // Carrega os dados ao iniciar
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Função para carregar os dados
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? areasJson = prefs.getString('app_data');

    List<Area> loadedAreas = [];
    if (areasJson != null) {
      try {
        final List<dynamic> decodedJson = jsonDecode(areasJson);
        loadedAreas = decodedJson.map((json) => Area.fromJson(json)).toList();
      } catch (e) {
        print("Erro ao carregar dados: $e. A iniciar com dados padrão.");
        // Se houver erro na leitura, inicia com a estrutura padrão
        loadedAreas = _getDefaultAreas();
      }
    } else {
      // Se não houver dados salvos, inicia com a estrutura padrão
      loadedAreas = _getDefaultAreas();
    }

    // Garante que as novas áreas são adicionadas se não existirem nos dados carregados
    final defaultAreas = _getDefaultAreas();
    for (var defaultArea in defaultAreas) {
      if (!loadedAreas.any((loadedArea) => loadedArea.id == defaultArea.id)) {
        loadedAreas.add(defaultArea);
      }
    }

    setState(() {
      _areas = loadedAreas;
      _isLoading = false;
    });
  }

  // Função que retorna a lista de áreas padrão
  List<Area> _getDefaultAreas() {
    return [
      Area(id: '1', title: 'Projetos Pessoais', notebooks: []),
      Area(id: '2', title: 'Trabalho', notebooks: []),
      Area(id: '3', title: 'Faculdade', notebooks: []),
      Area(id: '4', title: 'Estudos', notebooks: []),
    ];
  }

  // Função para guardar os dados
  Future<void> _saveData() async {
    // Garante que só guardamos dados válidos
    if (_areas.isEmpty && !_isLoading) {
      print("Aviso: A tentar guardar uma lista de áreas vazia.");
      // Poderia recarregar os padrões aqui se necessário
      // _areas = _getDefaultAreas();
    }
    final prefs = await SharedPreferences.getInstance();
    final String areasJson =
        jsonEncode(_areas.map((area) => area.toJson()).toList());
    await prefs.setString('app_data', areasJson);
    print("Dados guardados."); // Mensagem de confirmação
  }

  // Função para adicionar um novo caderno
  void _addNotebook(int areaIndex, String title) {
    // Verifica se o índice da área é válido
    if (areaIndex < 0 || areaIndex >= _areas.length) {
      print("Erro: Índice de área inválido ao adicionar caderno.");
      return;
    }

    setState(() {
      final newNotebook = Notebook(
        id: DateTime.now().toString(),
        title: title,
        topics: [],
        creationYear: DateTime.now().year,
        statusTag: StatusTag.caixaDeIdeias,
      );
      _areas[areaIndex].notebooks.add(newNotebook);
    });
    _saveData(); // Guarda após adicionar
  }

  // Função para apagar um caderno
  void _deleteNotebook(int areaIndex, Notebook notebook) {
    // Verifica se o índice da área é válido
    if (areaIndex < 0 || areaIndex >= _areas.length) {
      print("Erro: Índice de área inválido ao apagar caderno.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D2D3A),
        title: const Text('Excluir Caderno',
            style: TextStyle(color: Colors.white)),
        content: Text('Você tem certeza que quer excluir "${notebook.title}"?',
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
                _areas[areaIndex].notebooks.remove(notebook);
              });
              _saveData(); // Guarda após apagar
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NOVA FUNÇÃO: Mostra o diálogo para escolher a Área de destino ---
  void _showMoveNotebookDialog(Notebook notebookToMove) {
    // Encontra a área atual do caderno a ser movido
    Area? currentArea = _areas.firstWhere(
      (area) => area.notebooks.any(
          (nb) => nb.id == notebookToMove.id), // Compara por ID para segurança
      orElse: () {
        print(
            "Erro: Não foi possível encontrar a área atual do caderno a ser movido.");
        return _areas.first; // Retorna a primeira como fallback
      },
    );

    // Se por algum motivo a área atual não foi encontrada (improvável)
    if (currentArea == null) return;

    // Cria a lista de áreas de destino possíveis (todas exceto a atual)
    final destinationAreas =
        _areas.where((area) => area.id != currentArea.id).toList();

    // Se só existir uma área no total, não há para onde mover
    if (destinationAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não existem outras Áreas para mover o caderno.')),
      );
      return;
    }

    Area? selectedDestination =
        destinationAreas.first; // Pré-seleciona a primeira área de destino

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Usa StatefulBuilder para permitir atualizar a seleção dentro do diálogo
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1D2D3A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text('Mover "${notebookToMove.title}" para:',
                  style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                // Permite rolar se houver muitas áreas
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: destinationAreas.map((area) {
                    // Cria uma opção de rádio para cada área de destino
                    return RadioListTile<Area>(
                      title: Text(area.title,
                          style: const TextStyle(color: Colors.white)),
                      value: area, // O valor desta opção é a própria Área
                      groupValue:
                          selectedDestination, // A área atualmente selecionada
                      onChanged: (Area? value) {
                        // Quando uma opção é selecionada, atualiza o estado do diálogo
                        if (value != null) {
                          setDialogState(() {
                            selectedDestination = value;
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
                  onPressed: () =>
                      Navigator.of(context).pop(), // Fecha o diálogo
                ),
                ElevatedButton(
                  child: const Text('Mover'),
                  onPressed: () {
                    // Se uma área de destino foi selecionada, chama a função para mover
                    if (selectedDestination != null) {
                      _moveNotebook(
                          notebookToMove, currentArea, selectedDestination!);
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

  // --- NOVA FUNÇÃO: Realiza a movimentação do caderno entre as listas ---
  void _moveNotebook(
      Notebook notebook, Area currentArea, Area destinationArea) {
    setState(() {
      // Remove o caderno da lista da área atual
      currentArea.notebooks
          .removeWhere((nb) => nb.id == notebook.id); // Remove por ID
      // Adiciona o caderno à lista da área de destino
      destinationArea.notebooks.add(notebook);
    });
    _saveData(); // Guarda a alteração nos dados permanentes
  }

  // Widget para os pontinhos do indicador de página
  Widget _buildPageIndicator() {
    final numPages = _areas.isNotEmpty
        ? _areas.length
        : 1; // Evita erro se a lista estiver vazia
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numPages, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A4B), Color(0xFF1B2833)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator()) // Mostra loading
              : Column(
                  // Layout principal
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bem-vindo(a) de volta!',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 18)),
                          Text('Seus Cadernos',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Carrossel de Áreas
                    Expanded(
                      child: _areas.isEmpty
                          ? const Center(
                              child: Text(
                              "Nenhuma área encontrada.",
                              style: TextStyle(color: Colors.white54),
                            ))
                          : PageView.builder(
                              controller: _pageController,
                              itemCount: _areas.length,
                              onPageChanged: (index) =>
                                  setState(() => _currentPage = index),
                              itemBuilder: (context, index) {
                                // Adiciona padding para o efeito de carrossel
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: AreaView(
                                    area: _areas[index],
                                    onAddNotebook: (title) =>
                                        _addNotebook(index, title),
                                    onDeleteNotebook: (notebook) =>
                                        _deleteNotebook(index, notebook),
                                    onDataChanged: _saveData,
                                    // --- PASSAMOS A NOVA FUNÇÃO PARA O AREA VIEW ---
                                    onNotebookMoveRequested:
                                        _showMoveNotebookDialog,
                                  ),
                                );
                              },
                            ),
                    ),
                    // Indicador de Página
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                      child: _buildPageIndicator(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
