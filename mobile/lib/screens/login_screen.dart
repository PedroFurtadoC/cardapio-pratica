// Tela de acesso restrito para administração
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
      
      // Navega para o painel administrativo e limpa o histórico de navegação
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
    // Estrutura principal com fundo em tom de cinza claro
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Espaçamento interno padrão
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0), // Preenchimento generoso para o formulário
            decoration: BoxDecoration(
              color: Colors.white, // Fundo branco sólido
              borderRadius: BorderRadius.circular(12), // Bordas arredondadas e modernas
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12, // Sombra suave para o efeito de elevação
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
                        height: 64, // Altura do círculo do ícone
                        width: 64, // Largura do círculo do ícone
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1), // Fundo suave com a cor primária
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 32, // h-8 w-8
                          color: Theme.of(context).primaryColor, // Cor oficial do ícone
                        ),
                      ),
                      const SizedBox(height: 16), // mb-4
                      const Text(
                        'Área Restrita',
                        style: TextStyle(
                          fontSize: 24, // Tamanho de destaque para o título
                          fontWeight: FontWeight.bold, // Texto em negrito
                          color: Colors.black87, // Tom de preto suave para legibilidade
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Acesso exclusivo para administração',
                        style: TextStyle(
                          fontSize: 14, // Fonte pequena para o subtítulo
                          color: Colors.black54, // Cinza escuro discreto
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32), // Espaçamento entre o cabeçalho e os campos

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
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo obrigatório';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) return 'Email inválido';
                      return null;
                    },
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
                  
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text('Esqueceu a senha?', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 16), // Espaço de segurança vertical

                  // Botão Entrar
                   CustomButton(
                    text: _isLoading ? 'Entrando...' : 'Entrar',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não tem uma conta?'),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Cadastre-se'),
                      ),
                    ],
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
