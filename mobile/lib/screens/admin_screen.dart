// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/enums.dart';
import '../services/pedido_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status do pedido #${pedido.codigoPedido} atualizado!'),
          backgroundColor: Colors.green,
        ),
      );
      _carregarPedidos(); 
    } catch (e) {
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
      case StatusPedido.recebido:
        return Colors.orange;
      case StatusPedido.emPreparo:
        return Colors.blue;
      case StatusPedido.pronto:
        return Colors.green;
      case StatusPedido.entregue:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Pedidos',
            onPressed: _carregarPedidos,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          )
        ],
      ),
      body: FutureBuilder<List<Pedido>>(
        future: _futurePedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar pedidos: ${snapshot.error}'),
                  TextButton(
                    onPressed: _carregarPedidos,
                    child: const Text('Tentar novamente'),
                  )
                ],
              ),
            );
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
                  elevation: 2,
                  child: ExpansionTile(
                    // Cabeçalho do Card (Sempre visível)
                    leading: CircleAvatar(
                      backgroundColor: _corDoStatus(pedido.status).withOpacity(0.2),
                      child: Icon(Icons.receipt_long, color: _corDoStatus(pedido.status)),
                    ),
                    title: Text(
                      'Pedido #${pedido.codigoPedido}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${pedido.cliente.nome} • $valorFormatado'),
                    
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Controle de Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<StatusPedido>(
                                  value: pedido.status,
                                  underline: Container(height: 2, color: _corDoStatus(pedido.status)),
                                  items: StatusPedido.values.map((StatusPedido status) {
                                    return DropdownMenuItem<StatusPedido>(
                                      value: status,
                                      child: Text(
                                        status.value, 
                                        style: TextStyle(color: _corDoStatus(status), fontWeight: FontWeight.bold)
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (StatusPedido? novoStatus) {
                                    if (novoStatus != null && novoStatus != pedido.status) {
                                      _atualizarStatus(pedido, novoStatus);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Informações do Cliente e Entrega
                            Text('Telefone: ${pedido.cliente.telefone}'),
                            Text('Modalidade: ${pedido.modalidade.value}'),
                            Text('Pagamento: ${pedido.formaPagamento.value}'),
                            if (pedido.entrega != null)
                              Text('Endereço: ${pedido.entrega!.logradouro}, ${pedido.entrega!.numero} - ${pedido.entrega!.bairro}'),
                            
                            const SizedBox(height: 16),
                            const Text('Itens do Pedido:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            
                            // Lista de Itens dentro do pedido
                            ...pedido.itens.map((item) {
                              final precoItem = 'R\$ ${((item.precoUnitario * item.quantidade) / 100).toStringAsFixed(2).replaceAll('.', ',')}';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.quantidade}x ${item.nomeProduto}'),
                                    Text(precoItem, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              );
                            }),
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
      ),
    );
  }
}