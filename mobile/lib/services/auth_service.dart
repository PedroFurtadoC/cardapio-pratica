// lib/services/auth_service.dart
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
}
