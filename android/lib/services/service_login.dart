// lib/services/service_login.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/login_dto.dart';
import 'package:android/models/auth_response.dart';
import 'package:android/models/user.dart';
import 'package:android/models/dueno.dart';
import 'package:android/models/session_manager.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  /// LOGIN
  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return AuthResponse.fromMap(jsonBody);
    } else {
      throw Exception('Login fallido: ${response.body}');
    }
  }

  /// OBTENER USUARIO ACTUAL
  Future<User> fetchCurrentUser() async {
    final url = Uri.parse('$baseUrl/users/me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return User.fromJson(jsonBody);
    } else {
      throw Exception('Error al obtener el usuario actual: ${response.body}');
    }
  }

  /// REGISTRO DE DUEÑO
  static Future<bool> registerDueno(Map<String, dynamic> registerData) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(registerData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al registrar usuario: ${response.statusCode}');
    }
  }
}
