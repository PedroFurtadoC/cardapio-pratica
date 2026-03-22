// Consumo de dados de produtos e categorias

import '../models/produto.dart';
import 'api_client.dart';

class ProdutoService {
  final ApiClient _client = ApiClient();

  Future<List<Produto>> listarProdutos() async {
    final response = await _client.get('/produtos');
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Produto.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Produto> criarProduto(Produto produto) async {
    final response = await _client.post('/produtos', data: produto.toJson());
    return Produto.fromJson(response as Map<String, dynamic>);
  }

  Future<Produto> atualizarProduto(String id, Map<String, dynamic> atualizacoes) async {
    final response = await _client.put('/produtos/$id', data: atualizacoes);
    return Produto.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deletarProduto(String id) async {
    await _client.delete('/produtos/$id');
  }
}
