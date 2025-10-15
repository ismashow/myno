import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          isCreatingPassword: !hasPassword, // Se não tem senha, está criando
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

  final List<Area> _areas = [
    Area(id: '1', title: 'Projetos Pessoais', notebooks: []),
    Area(id: '2', title: 'Trabalho', notebooks: []),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addNotebook(int areaIndex, String title) {
    setState(() {
      final newNotebook = Notebook(
        id: DateTime.now().toString(),
        title: title,
        // MUDANÇA PRINCIPAL: Um novo caderno agora começa com uma lista de 'topics' vazia.
        topics: [],
      );
      _areas[areaIndex].notebooks.add(newNotebook);
    });
  }

  void _deleteNotebook(int areaIndex, Notebook notebook) {
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
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_areas.length, (index) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bem-vindo(a) de volta!',
                        style: TextStyle(color: Colors.white70, fontSize: 18)),
                    Text('Seus Cadernos',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _areas.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return AreaView(
                      area: _areas[index],
                      onAddNotebook: (title) => _addNotebook(index, title),
                      onDeleteNotebook: (notebook) =>
                          _deleteNotebook(index, notebook),
                    );
                  },
                ),
              ),
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
