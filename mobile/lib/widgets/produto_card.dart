// lib/widgets/produto_card.dart
import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/pedido.dart';

class ProdutoCard extends StatefulWidget {
  final Produto produto;
  final Function(ItemPedidoEmbutido) onAdd;

  const ProdutoCard({super.key, required this.produto, required this.onAdd});

  @override
  State<ProdutoCard> createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<ProdutoCard> {
  int quantidade = 1; 

  void _incrementar() {
    setState(() {
      quantidade++;
    });
  }

  void _decrementar() {
    if (quantidade > 1) {
      setState(() {
        quantidade--;
      });
    }
  }

  void _adicionarAoCarrinho() {
    final item = ItemPedidoEmbutido(
      nomeProduto: widget.produto.nome,
      quantidade: quantidade,
      precoUnitario: widget.produto.precoCentavos,
    );
    widget.onAdd(item);
    setState(() {
      quantidade = 1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.produto.nome} adicionado ao pedido!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final precoFormatado = 'R\$ ${(widget.produto.precoCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.produto.imagemUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.produto.nome,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.produto.descricao,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        precoFormatado,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(), // Linha separadora
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: _decrementar,
                    ),
                    Text(
                      '$quantidade',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: _incrementar,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _adicionarAoCarrinho,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}