import 'package:flutter/material.dart';
import '../models/pedido.dart';

class PedidoConfirmadoScreen extends StatelessWidget {
  const PedidoConfirmadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedido = ModalRoute.of(context)!.settings.arguments as Pedido;
    final valorFormatado =
        'R\$ ${(pedido.valorTotalCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 64),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Pedido Realizado!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pedido #${pedido.codigoPedido}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumo do Pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(height: 24),
                        ...pedido.itens.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantidade}x ${item.nomeProduto}'),
                              Text('R\$ ${(item.precoUnitario * item.quantidade / 100).toStringAsFixed(2).replaceAll('.', ',')}'),
                            ],
                          ),
                        )),
                        const Divider(height: 24),
                        _InfoRow(label: 'Cliente', value: pedido.cliente.nome),
                        _InfoRow(label: 'Modalidade', value: pedido.modalidade.label),
                        _InfoRow(label: 'Pagamento', value: pedido.formaPagamento.label),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(valorFormatado, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Acompanhe o status do seu pedido pelo número #${pedido.codigoPedido}',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Voltar ao Cardápio',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}