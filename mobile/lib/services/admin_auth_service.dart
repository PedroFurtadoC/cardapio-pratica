// Autenticação de administradores via API REST, o mesmo mecanismo do
// painel web (POST /auth/login). É separada do login de clientes, que usa o Firebase.
import 'api_client.dart';

class AdminAuthService {
  final ApiClient _client = ApiClient();

  /// Autentica pelo endpoint /auth/login e indica se o usuário é ADMIN.
  /// Lança [ApiError] quando as credenciais são inválidas.
  Future<bool> login(String email, String senha) async {
    final resposta = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': senha},
    );

    final dados = resposta as Map<String, dynamic>;
    final usuario = dados['user'] as Map<String, dynamic>?;
    final role = usuario?['role'] as String?;
    return role == 'ADMIN';
  }
}
