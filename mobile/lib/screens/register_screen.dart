import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/api_client.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _usuarioService.criarUsuario({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'senha': _passwordController.text,
        'role': 'CLIENTE',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso! Faça login.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);

    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão.'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Criar Conta'), backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Nome', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _nomeController,
                    hintText: 'João Silva',
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _emailController,
                    hintText: 'joao@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(v)) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Telefone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _telefoneController,
                    hintText: '16999998888',
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Senha', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _passwordController,
                    hintText: '••••••',
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Confirmar Senha', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _confirmPasswordController,
                    hintText: '••••••',
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      if (v != _passwordController.text) return 'As senhas não coincidem';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _isLoading ? 'Cadastrando...' : 'Cadastrar',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
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
