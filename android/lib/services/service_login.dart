import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:android/models/user.dart';

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
}
