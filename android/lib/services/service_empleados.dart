import 'dart:convert';
import 'package:android/models/empleados.dart';
import 'package:http/http.dart' as http;
import 'package:android/models/session_manager.dart';

class EmpleadoService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/empleados';

  static Future<List<Empleado>> getAllEmpleados() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

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
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

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
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(empleado.toJson()),
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

  static Future<Empleado> updateEmpleado(int id, Empleado empleado) async {
    final url = Uri.parse('$_baseUrl/$id');

    if (empleado.password == null || empleado.password!.isEmpty) {
      empleado.password = null;
    }

    final body = jsonEncode(empleado.toJson());

    print("📤 Actualizando empleado $id con:");
    print(body);

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    print("📥 Código de respuesta: ${response.statusCode}");
    print("📥 Respuesta body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Empleado.fromJson(jsonDecode(decodedBody));
    } else if (response.statusCode == 409) {
      throw Exception('El nombre de usuario ya está en uso');
    } else {
      throw Exception(
        'Error al actualizar empleado\nCódigo: ${response.statusCode}\n${response.body}',
      );
    }
  }

  static Future<void> deleteEmpleado(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

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

  List<Empleado> empleadosFiltradosPorNombre(
    String nombre,
    List<Empleado> listaEmpleados,
  ) {
    return listaEmpleados
        .where(
          (empleado) =>
              empleado.firstName!.toLowerCase().contains(nombre.toLowerCase()),
        )
        .toList();
  }

  List<Empleado> empleadosFiltradosPorApellido(
    String apellido,
    List<Empleado> listaEmpleados,
  ) {
    return listaEmpleados
        .where(
          (empleado) =>
              empleado.lastName!.toLowerCase().contains(apellido.toLowerCase()),
        )
        .toList();
  }

  static Future<bool> validateToken(String token) async {
    final url = Uri.parse('$_baseUrl/validate?token=$token');
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  static Future<List<Empleado>> getEmpleadosByNegocio(int negocioId) async {
    final url = Uri.parse('$_baseUrl/negocio/$negocioId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Empleado.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al obtener empleados por negocio');
    }
  }

  static Future<Empleado?> fetchEmpleadoByUserId(
    int userId,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/user/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Empleado.fromJson(json.decode(response.body));
    } else {
      print("Error obteniendo empleado por userId: ${response.statusCode}");
      return null;
    }
  }
}
