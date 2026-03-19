// lib/services/pedido_service.dart
import '../models/pedido.dart';
import '../models/enums.dart';
import 'api_client.dart';

class PedidoService {
  final ApiClient _client = ApiClient();

  Future<List<Pedido>> listarPedidos() async {
    final response = await _client.get('/pedidos');
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Pedido.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Pedido> verPedido(String id) async {
    final response = await _client.get('/pedidos/$id');
    return Pedido.fromJson(response as Map<String, dynamic>);
  }

  Future<Pedido> criarPedido(Map<String, dynamic> pedidoCreateData) async {
    final response = await _client.post('/pedidos', data: pedidoCreateData);
    return Pedido.fromJson(response as Map<String, dynamic>);
  }

  Future<Pedido> atualizarStatus(String id, StatusPedido novoStatus) async {
    final response = await _client.patch(
      '/pedidos/$id/status',
      data: {'status': novoStatus.value},
    );
    return Pedido.fromJson(response as Map<String, dynamic>);
  }
}