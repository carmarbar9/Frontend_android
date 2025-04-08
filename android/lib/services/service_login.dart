// lib/services/service_login.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/login_dto.dart';
import 'package:android/models/auth_response.dart';
import 'package:android/models/user.dart';
import 'package:android/models/dueno.dart';

class ApiService {
  // Cambia esta URL por la de tu backend
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  /// Realiza una petición POST al endpoint de login del backend,
  /// enviando las credenciales en JSON y retornando una [AuthResponse].
  static Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final loginDto = LoginDto(username: username, password: password);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: loginDto.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return AuthResponse.fromMap(jsonResponse);
    } else {
      // Muestra el username y la password incorrectos
      throw Exception('Error en el login: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<User> findUserByUsername(String username) async {
    final url = Uri.parse('$baseUrl/users/username/$username');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      // Si necesitas enviar autenticación, agrega el token u otros headers necesarios
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error en la petición: ${response.statusCode}');
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
