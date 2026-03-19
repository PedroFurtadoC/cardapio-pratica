// lib/services/usuario_service.dart
import '../models/usuario.dart';
import 'api_client.dart';

class UsuarioService {
  final ApiClient _client = ApiClient();

  Future<List<Usuario>> listarUsuarios() async {
    final response = await _client.get('/usuarios');
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Usuario.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Usuario> criarUsuario(Map<String, dynamic> usuarioCreateData) async {
    final response = await _client.post('/usuarios', data: usuarioCreateData);
    return Usuario.fromJson(response as Map<String, dynamic>);
  }

  Future<Usuario> atualizarUsuario(String id, Map<String, dynamic> atualizacoes) async {
    final response = await _client.put('/usuarios/$id', data: atualizacoes);
    return Usuario.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deletarUsuario(String id) async {
    await _client.delete('/usuarios/$id');
  }
}
