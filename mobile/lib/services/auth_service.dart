// Serviço responsável pela autenticação e controle de acesso
import '../models/auth_response.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    
    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<void> recuperarSenha(String email) async {
    await _client.post(
      '/auth/recuperar-senha',
      data: {'email': email},
    );
  }
}
