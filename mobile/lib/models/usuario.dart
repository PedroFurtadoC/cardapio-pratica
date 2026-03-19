// lib/models/usuario.dart
import 'enums.dart';

class Usuario {
  final String? id; // Mapeia o _id
  final String nome;
  final String email;
  final Role role;
  final String telefone;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.role,
    required this.telefone,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] as String?,
      nome: json['nome'] as String,
      email: json['email'] as String,
      role: Role.fromValue(json['role'] as String),
      telefone: json['telefone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nome': nome,
      'email': email,
      'role': role.value,
      'telefone': telefone,
    };
  }
}
