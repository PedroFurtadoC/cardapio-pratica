import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/produto_list.dart';
import '../models/pedido.dart';
import '../providers/carrinho_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'TODOS';

  final List<Map<String, String>> categories = [
    {'id': 'TODOS', 'label': 'Todos'},
    {'id': 'MARMITAS', 'label': 'Marmitas'},
    {'id': 'SALGADOS', 'label': 'Salgados'},
    {'id': 'BEBIDAS', 'label': 'Bebidas'},
    {'id': 'SOBREMESAS', 'label': 'Sobremesas'},
    {'id': 'PRATOS PRONTOS', 'label': 'Pratos Prontos'},
  ];

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );

    if (confirmar != true) return;
    await FirebaseAuth.instance.signOut();
    // A AppBar reage ao logout (StreamBuilder) e volta a exibir "Entrar".
  }

  /// O cardápio é aberto, mas finalizar o pedido exige uma conta. Se o
  /// cliente ainda não estiver autenticado, pedimos o login antes do checkout.
  Future<void> _irParaCheckout() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await Navigator.pushNamed(context, '/login');
    }
    if (!mounted) return;
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushNamed(context, '/checkout');
    }
  }

  /// Área de conta na AppBar: "Entrar" quando deslogado, saudação + sair
  /// quando há um cliente autenticado.
  Widget _contaAppBar() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Entrar'),
          );
        }

        final nomeCompleto = user.displayName?.trim();
        final nome = (nomeCompleto != null && nomeCompleto.isNotEmpty)
            ? nomeCompleto.split(' ').first
            : (user.email ?? '').split('@').first;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                'Olá, $nome',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(icon: const Icon(Icons.logout), tooltip: 'Sair', onPressed: _sair),
          ],
        );
      },
    );
  }

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
                            Text(precoItem, style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                carrinho.remover(index);
                                if (carrinho.isEmpty) Navigator.pop(context);
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
                      Text(
                        carrinho.valorTotalFormatado,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: carrinho.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context); // Fecha o resumo do pedido
                            _irParaCheckout();
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
    final carrinho = context.watch<CarrinhoProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 0,
        // Toque longo na logo abre o acesso restrito da administração.
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onLongPress: () => Navigator.pushNamed(context, '/admin/login'),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite, color: Colors.green),
            ),
          ),
        ),
        actions: [
          _contaAppBar(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre',
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Nosso Cardápio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat['id']!);
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ProdutoList(
              selectedCategory: _selectedCategory,
              onItemAdded: (ItemPedidoEmbutido item) {
                context.read<CarrinhoProvider>().adicionar(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.nomeProduto} adicionado ao pedido!'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Theme.of(context).primaryColor,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: carrinho.isEmpty
          ? null
          : SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                onPressed: () => _mostrarResumoPedido(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        const Icon(Icons.shopping_cart, size: 28),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${carrinho.quantidadeTotal}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ver Pedido', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(
                          carrinho.valorTotalFormatado,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
