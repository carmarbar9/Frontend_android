// lib/services/service_login.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/login_dto.dart';
import 'package:android/models/auth_response.dart';
import 'package:android/models/user.dart';
import 'package:android/models/dueno.dart';
import 'package:android/models/session_manager.dart';

class ApiService {
  // Cambia esta URL por la de tu backend
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return AuthResponse.fromMap(jsonBody);
    } else {
      throw Exception('Login fallido: ${response.body}');
    }
  }


  Future<User> fetchCurrentUser() async {
    final token = SessionManager.token;

    if (token == null) {
      throw Exception('Token no disponible');
    }

    print('📡 GET /users/me con token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🔁 Status: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return User.fromJson(jsonBody);
    } else {
      throw Exception('Error al obtener usuario actual: ${response.statusCode}');
    }
  }


   static Future<Dueno?> registerDueno(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/duenos');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return Dueno.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('El nombre de usuario ya existe');
    } else {
      throw Exception('Error al registrar usuario: ${response.statusCode}');
    }
  }

}
