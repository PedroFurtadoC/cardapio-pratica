// lib/widgets/produto_list.dart
import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/pedido.dart';
import '../services/produto_service.dart';
import 'produto_card.dart';

class ProdutoList extends StatefulWidget {
  final Function(ItemPedidoEmbutido) onItemAdded;

  const ProdutoList({super.key, required this.onItemAdded});

  @override
  State<ProdutoList> createState() => _ProdutoListState();
}

class _ProdutoListState extends State<ProdutoList> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produto>>(
      future: _futureProdutos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar produtos.'));
        }
        final produtos = snapshot.data ?? [];
        if (produtos.isEmpty) {
          return const Center(child: Text('Nenhum produto disponível.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            _carregarProdutos();
            await _futureProdutos;
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8), 
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return ProdutoCard(
                produto: produto,
                onAdd: widget.onItemAdded,
              );
            },
          ),
        );
      },
    );
  }
}