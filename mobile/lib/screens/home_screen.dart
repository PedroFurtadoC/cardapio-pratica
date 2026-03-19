// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/produto_list.dart';
import '../models/pedido.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ItemPedidoEmbutido> _carrinho = [];

  void _adicionarAoCarrinho(ItemPedidoEmbutido novoItem) {
    setState(() {
      final indexExistente = _carrinho.indexWhere(
        (item) => item.nomeProduto == novoItem.nomeProduto,
      );

      if (indexExistente != -1) {
        final itemAtual = _carrinho[indexExistente];
        _carrinho[indexExistente] = ItemPedidoEmbutido(
          nomeProduto: itemAtual.nomeProduto,
          precoUnitario: itemAtual.precoUnitario,
          quantidade: itemAtual.quantidade + novoItem.quantidade,
          selecoes: itemAtual.selecoes,
        );
      } else {
        _carrinho.add(novoItem);
      }
    });
  }

  // Calcula a quantidade total de itens (ex: 2 cocas + 1 marmita = 3 itens)
  int get _quantidadeTotal {
    return _carrinho.fold(0, (total, item) => total + item.quantidade);
  }

  // Calcula o valor total do carrinho em centavos
  int get _valorTotalCentavos {
    return _carrinho.fold(0, (total, item) => total + (item.precoUnitario * item.quantidade));
  }

  // Função para limpar um item do carrinho
  void _removerDoCarrinho(int index) {
    setState(() {
      _carrinho.removeAt(index);
    });
  }

  // Exibe o resumo do pedido num BottomSheet
  void _mostrarResumoPedido() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final valorFormatado = 'R\$ ${(_valorTotalCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';

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
                  
                  if (_carrinho.isEmpty)
                    const Center(child: Text('Carrinho vazio.'))
                  else
                    ..._carrinho.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final precoItem = 'R\$ ${((item.precoUnitario * item.quantidade) / 100).toStringAsFixed(2).replaceAll('.', ',')}';
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${item.quantidade}x ${item.nomeProduto}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(precoItem, style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  _removerDoCarrinho(index);
                                });
                                // Se esvaziou o carrinho, fecha o modal
                                if (_carrinho.isEmpty) {
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
                      const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(valorFormatado, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão para prosseguir
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _carrinho.isEmpty ? null : () {
                      Navigator.pop(context); // Fecha o BottomSheet
                      // TODO: Navegar para a tela de Checkout (onde pede endereço, nome, etc)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Indo para o pagamento...')),
                      );
                    },
                    child: const Text('Avançar para Pagamento', style: TextStyle(fontSize: 16)),
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Nosso Cardápio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Acesso Restrito',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ProdutoList(onItemAdded: _adicionarAoCarrinho),
      floatingActionButton: _carrinho.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _mostrarResumoPedido,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '$_quantidadeTotal itens • R\$ ${(_valorTotalCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}