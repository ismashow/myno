import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockScreen extends StatefulWidget {
  final bool isCreatingPassword;
  // Função chamada após a senha ser criada com sucesso
  final VoidCallback onPasswordCreated;
  // Função chamada para validar a senha digitada
  final Future<bool> Function(String) onPasswordValidated;

  const LockScreen({
    super.key,
    required this.isCreatingPassword,
    required this.onPasswordCreated,
    required this.onPasswordValidated,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  String? _firstPassword;
  String? _errorMessage;

  Future<void> _handlePasswordSubmit() async {
    final enteredPassword = _passwordController.text;

    // Limpa a mensagem de erro anterior
    setState(() => _errorMessage = null);

    if (enteredPassword.isEmpty) {
      setState(() => _errorMessage = 'A senha não pode estar em branco.');
      return;
    }

    // Lógica para CRIAR uma nova senha
    if (widget.isCreatingPassword) {
      if (_firstPassword == null) {
        // Primeiro passo: guarda a primeira senha digitada
        setState(() {
          _firstPassword = enteredPassword;
          _passwordController.clear();
        });
      } else {
        // Segundo passo: compara a confirmação com a primeira senha
        if (_firstPassword == enteredPassword) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_password', enteredPassword);
          widget.onPasswordCreated(); // Sucesso! Chama a função.
        } else {
          setState(() {
            _errorMessage = 'As senhas não coincidem. Tente novamente.';
            _firstPassword = null;
            _passwordController.clear();
          });
        }
      }
    } else {
      // Lógica para VALIDAR uma senha existente
      final success = await widget.onPasswordValidated(enteredPassword);
      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Senha incorreta.';
          _passwordController.clear();
        });
      }
    }
  }

  String _getTitle() {
    if (widget.isCreatingPassword) {
      return _firstPassword == null ? 'Crie sua Senha' : 'Confirme sua Senha';
    }
    return 'Digite sua Senha';
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withAlpha(30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _errorMessage,
                  ),
                  onSubmitted: (_) => _handlePasswordSubmit(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handlePasswordSubmit,
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
