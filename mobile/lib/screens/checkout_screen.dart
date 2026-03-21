import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../models/pedido.dart';
import '../providers/carrinho_provider.dart';
import '../services/pedido_service.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final PedidoService _pedidoService = PedidoService();

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();

  ModalidadeEntrega _modalidade = ModalidadeEntrega.retirada;
  FormaPagamento _formaPagamento = FormaPagamento.pix;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  bool get _precisaDeEndereco => _modalidade == ModalidadeEntrega.delivery;

  Future<void> _finalizarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final carrinho = context.read<CarrinhoProvider>();

    try {
      final pedidoData = {
        'cliente': {
          'nome': _nomeController.text.trim(),
          'telefone': _telefoneController.text.trim(),
          if (_cpfController.text.isNotEmpty)
            'cpf_nota': _cpfController.text.trim(),
        },
        'modalidade': _modalidade.value,
        if (_precisaDeEndereco)
          'entrega': {
            'logradouro': _logradouroController.text.trim(),
            'numero': _numeroController.text.trim(),
            'bairro': _bairroController.text.trim(),
          },
        'forma_pagamento': _formaPagamento.value,
        'itens': carrinho.itens.map((i) => i.toJson()).toList(),
      };

      final pedidoCriado = await _pedidoService.criarPedido(pedidoData);
      carrinho.limpar();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/pedido-confirmado',
        arguments: pedidoCriado,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = context.watch<CarrinhoProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Resumo do Pedido',
              icon: Icons.receipt_long,
              children: [
                ...carrinho.itens.map((item) {
                  final preco =
                      'R\$ ${((item.precoUnitario * item.quantidade) / 100).toStringAsFixed(2).replaceAll('.', ',')}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantidade}x ${item.nomeProduto}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(preco,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  );
                }),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      carrinho.valorTotalFormatado,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Seus Dados',
              icon: Icons.person_outline,
              children: [
                CustomInput(
                  controller: _nomeController,
                  hintText: 'Nome completo',
                  validator: (v) => v!.trim().isEmpty ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  controller: _telefoneController,
                  hintText: 'Telefone (ex: 16999998888)',
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Informe seu telefone' : null,
                ),
                const SizedBox(height: 12),
                CustomInput(
                  controller: _cpfController,
                  hintText: 'CPF para nota (opcional)',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Como deseja receber?',
              icon: Icons.delivery_dining_outlined,
              children: [
                ...ModalidadeEntrega.values.map(
                  (m) => RadioListTile<ModalidadeEntrega>(
                    value: m,
                    groupValue: _modalidade,
                    title: Text(_labelModalidade(m)),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _modalidade = v!),
                  ),
                ),

                if (_precisaDeEndereco) ...[
                  const Divider(height: 24),
                  const Text('Endereço de entrega',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: _logradouroController,
                    hintText: 'Rua / Avenida',
                    validator: (v) => _precisaDeEndereco && v!.trim().isEmpty
                        ? 'Informe o logradouro'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: CustomInput(
                          controller: _numeroController,
                          hintText: 'Nº',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              _precisaDeEndereco && v!.trim().isEmpty
                                  ? 'Obrigatório'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          controller: _bairroController,
                          hintText: 'Bairro',
                          validator: (v) =>
                              _precisaDeEndereco && v!.trim().isEmpty
                                  ? 'Informe o bairro'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Forma de Pagamento',
              icon: Icons.payment_outlined,
              children: [
                ...FormaPagamento.values.map(
                  (f) => RadioListTile<FormaPagamento>(
                    value: f,
                    groupValue: _formaPagamento,
                    title: Text(_labelPagamento(f)),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _formaPagamento = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: _isLoading ? 'Enviando pedido...' : 'Confirmar Pedido',
              isLoading: _isLoading,
              onPressed: carrinho.isEmpty ? null : _finalizarPedido,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _labelModalidade(ModalidadeEntrega m) {
    switch (m) {
      case ModalidadeEntrega.delivery:
        return '🛵 Delivery';
      case ModalidadeEntrega.retirada:
        return '🏃 Retirada no local';
      case ModalidadeEntrega.balcao:
        return '🪑 Consumir no balcão';
    }
  }

  String _labelPagamento(FormaPagamento f) {
    switch (f) {
      case FormaPagamento.pix:
        return '📱 PIX';
      case FormaPagamento.credito:
        return '💳 Cartão de Crédito';
      case FormaPagamento.debito:
        return '💳 Cartão de Débito';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}