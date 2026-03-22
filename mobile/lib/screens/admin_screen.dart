// Painel administrativo com abas para Pedidos e Cardápio
import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/enums.dart';
import '../services/pedido_service.dart';
import 'admin_produtos_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Painel Administrativo', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Cardápio'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            )
          ],
        ),
        body: const TabBarView(
          children: [
            _PedidosTab(),
            AdminProdutosScreen(),
          ],
        ),
      ),
    );
  }
}

class _PedidosTab extends StatefulWidget {
  const _PedidosTab();

  @override
  State<_PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<_PedidosTab> {
  final PedidoService _pedidoService = PedidoService();
  late Future<List<Pedido>> _futurePedidos;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  void _carregarPedidos() {
    setState(() {
      _futurePedidos = _pedidoService.listarPedidos();
    });
  }

  Future<void> _atualizarStatus(Pedido pedido, StatusPedido novoStatus) async {
    try {
      await _pedidoService.atualizarStatus(pedido.id!, novoStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status do pedido #${pedido.codigoPedido} atualizado!'),
          backgroundColor: Colors.green,
        ),
      );
      _carregarPedidos(); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar status.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Color _corDoStatus(StatusPedido status) {
    switch (status) {
      case StatusPedido.recebido: return Colors.orange;
      case StatusPedido.emPreparo: return Colors.blue;
      case StatusPedido.pronto: return Colors.green;
      case StatusPedido.entregue: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pedido>>(
      future: _futurePedidos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final pedidos = snapshot.data ?? [];
        if (pedidos.isEmpty) {
          return const Center(child: Text('Nenhum pedido recebido ainda.'));
        }

        pedidos.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

        return RefreshIndicator(
          onRefresh: () async => _carregarPedidos(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final valorFormatado = 'R\$ ${(pedido.valorTotalCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _corDoStatus(pedido.status).withValues(alpha: 0.1),
                    child: Icon(Icons.receipt_long, color: _corDoStatus(pedido.status)),
                  ),
                  title: Text('Pedido #${pedido.codigoPedido}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${pedido.cliente.nome} • $valorFormatado'),
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButton<StatusPedido>(
                                value: pedido.status,
                                items: StatusPedido.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                                onChanged: (novo) {
                                  if (novo != null && novo != pedido.status) _atualizarStatus(pedido, novo);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Telefone: ${pedido.cliente.telefone}'),
                          Text('Modalidade: ${pedido.modalidade.label}'),
                          if (pedido.entrega != null)
                            Text('Endereço: ${pedido.entrega!.logradouro}, ${pedido.entrega!.numero}'),
                          const SizedBox(height: 16),
                          ...pedido.itens.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.quantidade}x ${item.nomeProduto}'),
                                Text('R\$ ${(item.precoUnitario * item.quantidade / 100).toStringAsFixed(2).replaceAll('.', ',')}'),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}