// Tela de gestão de produtos (Listagem e Exclusão)
import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';

class AdminProdutosScreen extends StatefulWidget {
  const AdminProdutosScreen({super.key});

  @override
  State<AdminProdutosScreen> createState() => _AdminProdutosScreenState();
}

class _AdminProdutosScreenState extends State<AdminProdutosScreen> {
  final ProdutoService _produtoService = ProdutoService();
  late Future<List<Produto>> _futureProdutos;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _futureProdutos = _produtoService.listarProdutos();
    });
  }

  Future<void> _confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Tem certeza que deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _produtoService.deletarProduto(produto.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso!'), backgroundColor: Colors.green),
        );
        _carregarProdutos();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir produto.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Produto>>(
        future: _futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final produtos = snapshot.data ?? [];
          if (produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _carregarProdutos(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                final preco = 'R\$ ${(produto.precoCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        produto.imagemUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Container(
                          width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood),
                        ),
                      ),
                    ),
                    title: Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(produto.categoria.value, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                        Text(preco, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmarExclusao(produto),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/admin/add-produto');
          if (result == true) {
            _carregarProdutos();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
