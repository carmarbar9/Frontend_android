import 'dart:convert';
import 'package:android/models/empleados.dart';
import 'package:http/http.dart' as http;

class EmpleadoService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/empleados';

  static Future<List<Empleado>> getAllEmpleados() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Empleado.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener empleados');
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
      body: jsonEncode(empleado.toJson()), // ya actualizado al nuevo formato
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Empleado.fromJson(jsonDecode(decodedBody));
    } else if (response.statusCode == 409) {
      throw Exception('El nombre de usuario ya está en uso');
    } else {
      throw Exception('Error al crear el empleado');
    }
  }

  static Future<Empleado> updateEmpleado(Empleado empleado) async {
    if (empleado.id == null) {
      throw Exception('El ID del empleado no puede ser nulo para actualizar');
    }
    final url = Uri.parse('$_baseUrl/${empleado.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(empleado.toJson()),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Empleado.fromJson(jsonDecode(decodedBody));
    } else if (response.statusCode == 409) {
      throw Exception('El nombre de usuario ya está en uso');
    } else {
      throw Exception('Error al actualizar el empleado');
    }
  }

  static Future<void> deleteEmpleado(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200 && response.statusCode != 204) {
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

  static Future<List<Empleado>> getEmpleadosByNombre(String nombre) async {
    final url = Uri.parse('$_baseUrl/nombre/$nombre');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Empleado.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<List<Empleado>> getEmpleadosByApellido(String apellido) async {
    final url = Uri.parse('$_baseUrl/apellido/$apellido');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Empleado.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<bool> validateToken(String token) async {
    final url = Uri.parse('$_baseUrl/validate?token=$token');
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  static Future<List<Empleado>> getEmpleadosByNegocio(int negocioId) async {
    final url = Uri.parse('$_baseUrl/negocio/$negocioId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Empleado.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // Si el negocio no tiene empleados
    } else {
      throw Exception('Error al obtener empleados por negocio');
    }
  }
  
  static Future<Empleado?> fetchEmpleadoByUserId(int userId, String token) async {
    final url = Uri.parse('$_baseUrl/user/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Empleado.fromJson(data);
    } else {
      print('❌ Error en fetchEmpleadoByUserId: ${response.statusCode} - ${response.body}');
      return null;
    }
  }


}

