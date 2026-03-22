import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sobre o Projeto'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Objetivo',
              'Desenvolver um aplicativo multiplataforma que funcione como um cardápio digital, '
              'permitindo que clientes visualizem produtos disponíveis e realizem pedidos de forma intuitiva.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Equipe de Desenvolvimento',
              '• Pedro Furtado Cunha\n• André Fernando Machado\n• Felipe de Sousa Pegoraro',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Informações Acadêmicas',
              'Disciplina: Prática Extensionista VIII\n'
              'Curso: Engenharia da Computação\n'
              'Instituição: UNAERP - Universidade de Ribeirão Preto\n'
              'Professor: Prof. Dr. Rodrigo de Oliveira Plotze',
            ),
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'Versão 0.1.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
      ],
    );
  }
}
