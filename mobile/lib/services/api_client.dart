// lib/services/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiError implements Exception {
  final int status;
  final String message;
  final dynamic data;

  ApiError({required this.status, required this.message, this.data});

  @override
  String toString() => 'ApiError(status: $status, message: $message)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, if (headers != null) ...headers};

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(url, headers: mergedHeaders);
          break;
        case 'POST':
          response = await http.post(url, headers: mergedHeaders, body: data != null ? jsonEncode(data) : null);
          break;
        case 'PUT':
          response = await http.put(url, headers: mergedHeaders, body: data != null ? jsonEncode(data) : null);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: mergedHeaders, body: data != null ? jsonEncode(data) : null);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: mergedHeaders);
          break;
        default:
          throw Exception('Método HTTP não suportado: $method');
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(status: 0, message: 'Erro de conexão: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Erro desconhecido';
      dynamic errorData;

      try {
        errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        } else {
          errorMessage = response.reasonPhrase ?? errorMessage;
        }
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : response.reasonPhrase ?? errorMessage;
      }

      throw ApiError(
        status: response.statusCode,
        message: errorMessage,
        data: errorData,
      );
    }
  }

  // Métodos públicos
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) {
    return _request('GET', endpoint, headers: headers);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers}) {
    return _request('POST', endpoint, data: data, headers: headers);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers}) {
    return _request('PUT', endpoint, data: data, headers: headers);
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers}) {
    return _request('PATCH', endpoint, data: data, headers: headers);
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) {
    return _request('DELETE', endpoint, headers: headers);
  }
}
