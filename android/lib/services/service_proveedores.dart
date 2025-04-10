import 'dart:convert';
import 'package:android/models/dia_reparto.dart';
import 'package:http/http.dart' as http;
import 'package:android/models/proveedor.dart';
import 'package:android/models/session_manager.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${SessionManager.token}',
    'Content-Type': 'application/json',
  };

  static Future<List<Proveedor>> getProveedores() async {
    final url = Uri.parse('$_baseUrl/api/proveedores');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Proveedor.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener los proveedores');
    }
  }

  static Future<Proveedor> createProveedor(Proveedor proveedor) async {
    final url = Uri.parse('$_baseUrl/api/proveedores');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(proveedor.toJsonDTO()), // Usa el DTO
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Proveedor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el proveedor');
    }
  }

  static Future<void> deleteProveedor(int id) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/$id');
    final response = await http.delete(url, headers: _headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al borrar el proveedor');
    }
  }

  static Future<Proveedor?> getProveedorById(int id) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/$id');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      return Proveedor.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener el proveedor');
    }
  }

  static Future<List<Proveedor>> getProveedoresByFirstName(
    String firstName,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/api/proveedores/nombre?firstName=$firstName',
    );
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Proveedor.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener proveedores por nombre');
    }
  }

  static Future<Proveedor> updateProveedor(Proveedor proveedor) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/${proveedor.id}');
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode(proveedor.toJsonDTO()),
    );

    if (response.statusCode == 200) {
      return Proveedor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar el proveedor');
    }
  }

  static Future<List<Proveedor>> searchProveedorByName(String name) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/nombre/$name');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      return [Proveedor.fromJson(jsonDecode(response.body))];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al buscar el proveedor por nombre');
    }
  }

  static Future<List<Proveedor>> searchProveedorByTelefono(
    String telefono,
  ) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/telefono/$telefono');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      return [Proveedor.fromJson(jsonDecode(response.body))];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al buscar el proveedor por teléfono');
    }
  }

  static Future<List<DiaReparto>> getDiasRepartoByProveedor(
    int proveedorId,
  ) async {
    final url = Uri.parse('$_baseUrl/api/diasReparto/proveedor/$proveedorId');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => DiaReparto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar días de reparto del proveedor');
    }
  }

  static Future<DiaReparto> createDiaReparto(DiaReparto diaReparto) async {
    final url = Uri.parse('$_baseUrl/api/diasReparto');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "diaSemana": diaReparto.diaSemana,
        "descripcion": diaReparto.descripcion,
        "proveedor": {"id": diaReparto.proveedorId},
      }),
    );

    if (response.statusCode == 201) {
      return DiaReparto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear día de reparto');
    }
  }

  static Future<DiaReparto> updateDiaReparto(
    int id,
    DiaReparto diaReparto,
  ) async {
    final url = Uri.parse('$_baseUrl/api/diasReparto/$id');
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({
        "id": id,
        "diaSemana": diaReparto.diaSemana,
        "descripcion": diaReparto.descripcion,
        "proveedor": {"id": diaReparto.proveedorId},
      }),
    );

    if (response.statusCode == 200) {
      return DiaReparto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar día de reparto');
    }
  }

  static Future<void> deleteDiaReparto(int id) async {
    final url = Uri.parse('$_baseUrl/api/diasReparto/$id');
    final response = await http.delete(url, headers: _headers);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar día de reparto');
    }
  }

  static Future<List<Proveedor>> getProveedoresByNegocio(int negocioId) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/negocio/$negocioId');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Proveedor.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al obtener proveedores del negocio');
    }
  }
}
