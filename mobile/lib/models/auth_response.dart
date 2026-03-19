// lib/models/auth_response.dart
import 'usuario.dart';

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final Usuario user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: Usuario.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
