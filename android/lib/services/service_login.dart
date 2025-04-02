// lib/services/service_login.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/user.dart';
import 'package:android/models/dueno.dart'; // Asegúrate de importar tu modelo Dueno

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<String?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  static Future<User?> fetchUser(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/users/usernameAndPassword/$username/$password');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  // Método para registrar un nuevo Dueno
  static Future<Dueno?> registerDueno(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/duenos');
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
