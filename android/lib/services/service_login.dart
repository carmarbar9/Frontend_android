import 'package:http/http.dart' as http;

class ApiService {
  // Para Android Emulator, utiliza 10.0.2.2. Ajusta según tu entorno.
  static const String _baseUrl = 'http://10.0.2.2:8080';



   /// Método de login usando username y password (para app_user)
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
      return response.body; // Se espera el JWT
    } else {
      return null;
    }
  }

 
}
