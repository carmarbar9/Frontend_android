// lib/services/service_login.dart
import 'dart:convert';
import 'package:android/models/session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:android/models/user.dart';
import 'package:android/models/dueno.dart'; // Asegúrate de importar tu modelo Dueno

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<String?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['token'];
    } else {
      print("Error login: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  static Future<User?> fetchCurrentUser(String token) async {
    final url = Uri.parse('$_baseUrl/api/users/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      print("Error al obtener el usuario: ${response.statusCode} - ${response.body}");
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

  Future<void> fetchDuenoId(int userId) async {
  final response = await http.get(Uri.parse('$_baseUrl/api/duenos/user/$userId'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    SessionManager.duenoId = data['id'] as int; // suponiendo que id es el id del dueño
  } else {
    throw Exception('No se pudo obtener el duenoId');
  }
}


static Future<User?> fetchCurrentUserWithBasicAuth(String username, String password) async {
  final url = Uri.parse('$_baseUrl/api/users/me');
  // Codificar las credenciales: "username:password"
  final credentials = base64Encode(utf8.encode('$username:$password'));

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
    },
  );

  if (response.statusCode == 200) {
    return User.fromJson(json.decode(response.body));
  } else {
    print("Error al obtener el usuario: ${response.statusCode} - ${response.body}");
    return null;
  }
}

}