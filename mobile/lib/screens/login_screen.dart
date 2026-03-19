// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Aqui a mágica acontece: navega para o painel admin e remove a tela de login da pilha
      Navigator.pushReplacementNamed(context, '/admin');

    } on ApiError catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais inválidas ou erro no servidor.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold com fundo cinza claro (bg-gray-100)
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // p-4
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0), // p-8
            decoration: BoxDecoration(
              color: Colors.white, // bg-white
              borderRadius: BorderRadius.circular(12), // rounded-xl
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12, // shadow-lg leve
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (Cadeado e Títulos)
                  Column(
                    children: [
                      Container(
                        height: 64, // h-16
                        width: 64, // w-16
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1), // bg-primary/10
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 32, // h-8 w-8
                          color: Theme.of(context).primaryColor, // text-primary
                        ),
                      ),
                      const SizedBox(height: 16), // mb-4
                      const Text(
                        'Área Restrita',
                        style: TextStyle(
                          fontSize: 24, // text-2xl
                          fontWeight: FontWeight.bold, // font-bold
                          color: Colors.black87, // text-gray-900
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Acesso exclusivo para administração',
                        style: TextStyle(
                          fontSize: 14, // text-sm
                          color: Colors.black54, // text-gray-500
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32), // mb-8 (espaço entre header e form)

                  // Campos do Formulário
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _emailController,
                    hintText: 'admin@restaurante.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Senha',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _passwordController,
                    hintText: '••••••',
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  
                  const SizedBox(height: 24), // space-y-4 compensado

                  // Botão Entrar
                  CustomButton(
                    text: _isLoading ? 'Entrando...' : 'Entrar',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
