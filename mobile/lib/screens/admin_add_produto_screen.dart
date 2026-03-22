import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/enums.dart';
import '../services/produto_service.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class AdminAddProdutoScreen extends StatefulWidget {
  const AdminAddProdutoScreen({super.key});

  @override
  State<AdminAddProdutoScreen> createState() => _AdminAddProdutoScreenState();
}

class _AdminAddProdutoScreenState extends State<AdminAddProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _produtoService = ProdutoService();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _imagemController = TextEditingController();

  CategoriaProduto _categoria = CategoriaProduto.marmitas;
  TipoProduto _tipo = TipoProduto.simples;
  bool _ativo = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Limpar e converter preço (Ex: "15,90" -> 1590)
      final precoLimpo = _precoController.text.replaceAll('.', '').replaceAll(',', '.');
      final precoCentavos = (double.parse(precoLimpo) * 100).toInt();

      final novoProduto = Produto(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        precoCentavos: precoCentavos,
        imagemUrl: _imagemController.text.trim(),
        categoria: _categoria,
        ativo: _ativo,
        tipo: _tipo,
      );

      await _produtoService.criarProduto(novoProduto);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Retorna true para indicar que houve alteração
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInput(
                controller: _nomeController,
                hintText: 'Nome do Prato (Ex: Feijoada Especial)',
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _descricaoController,
                hintText: 'Descrição (Ingredientes, tamanho...)',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: _precoController,
                      hintText: 'Preço (Ex: 25,90)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        try {
                           double.parse(v.replaceAll(',', '.'));
                           return null;
                        } catch (_) {
                          return 'Valor inválido';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<CategoriaProduto>(
                      value: _categoria,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: CategoriaProduto.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _categoria = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _imagemController,
                hintText: 'URL da Imagem',
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                onChanged: (v) => setState(() {}),
              ),
              if (_imagemController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imagemController.text,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: Text('URL da imagem inválida')),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text('Configurações Técnicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              DropdownButtonFormField<TipoProduto>(
                value: _tipo,
                decoration: InputDecoration(
                  labelText: 'Tipo de Produto',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: TipoProduto.values.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.label));
                }).toList(),
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Produto Ativo no Cardápio'),
                subtitle: const Text('Se desativado, não aparecerá para os clientes'),
                value: _ativo,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (v) => setState(() => _ativo = v),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _isLoading ? 'Salvando...' : 'Cadastrar Produto',
                isLoading: _isLoading,
                onPressed: _salvar,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
