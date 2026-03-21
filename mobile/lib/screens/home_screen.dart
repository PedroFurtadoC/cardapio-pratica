import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/produto_list.dart';
import '../models/pedido.dart';
import '../providers/carrinho_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _mostrarResumoPedido(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<CarrinhoProvider>(
          builder: (context, carrinho, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Seu Pedido',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 32),

                  if (carrinho.isEmpty)
                    const Center(child: Text('Carrinho vazio.'))
                  else
                    ...carrinho.itens.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final precoItem =
                          'R\$ ${((item.precoUnitario * item.quantidade) / 100).toStringAsFixed(2).replaceAll('.', ',')}';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${item.quantidade}x ${item.nomeProduto}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(precoItem,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () {
                                carrinho.remover(index);
                                if (carrinho.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        carrinho.valorTotalFormatado,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: carrinho.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context); 
                            Navigator.pushNamed(context, '/checkout');
                          },
                    child: const Text('Avançar para Pagamento',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = context.watch<CarrinhoProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Nosso Cardápio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Acesso Restrito',
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
      body: ProdutoList(
        onItemAdded: (ItemPedidoEmbutido item) {
          context.read<CarrinhoProvider>().adicionar(item);
        },
      ),
      floatingActionButton: carrinho.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _mostrarResumoPedido(context),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${carrinho.quantidadeTotal} itens • ${carrinho.valorTotalFormatado}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}