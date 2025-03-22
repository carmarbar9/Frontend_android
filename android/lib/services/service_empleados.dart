import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/empleados.dart';

class EmpleadoService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/v1/empleados';

  static Future<List<Empleado>> getAllEmpleados() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Empleado.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los empleados');
    }
  }

  static Future<Empleado?> getEmpleadoById(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Empleado.fromJson(jsonDecode(decodedBody));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener el empleado');
    }
  }

  static Future<Empleado> createEmpleado(Empleado empleado) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(empleado.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Empleado.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Error al crear el empleado');
    }
  }

  static Future<void> deleteEmpleado(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el empleado');
    }
  }

  static Future<String?> login(String tokenEmpleado) async {
    final url = Uri.parse('$_baseUrl/login?tokenEmpleado=$tokenEmpleado');
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return decodedBody;
    } else {
      return null;
    }
  }

  static Future<bool> validateToken(String token) async {
    final url = Uri.parse('$_baseUrl/validate?token=$token');
    final response = await http.get(url);
    return response.statusCode == 200;
  }
}
