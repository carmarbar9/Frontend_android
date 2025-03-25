import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/proveedor.dart';

class ApiService {
  // Para Android Emulator, utiliza 10.0.2.2. Ajusta según tu entorno.
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // Obtiene la lista de todos los proveedores
  static Future<List<Proveedor>> getProveedores() async {
    final url = Uri.parse('$_baseUrl/api/proveedores');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Proveedor.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los proveedores');
    }
  }

  /// Método para crear un proveedor
  static Future<Proveedor> createProveedor(Proveedor proveedor) async {
    final url = Uri.parse('$_baseUrl/api/proveedores');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(proveedor.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Proveedor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el proveedor');
    }
  }

  /// Método para borrar un proveedor por id
  static Future<void> deleteProveedor(int id) async {
  final url = Uri.parse('$_baseUrl/api/proveedores/$id');
  final response = await http.delete(url);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Error al borrar el proveedor');
  }
}

  /// Método para obtener un proveedor por id
  static Future<Proveedor?> getProveedorById(int id) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Proveedor.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener el proveedor');
    }
  }

  /// Método para obtener proveedores filtrados por nombre
  static Future<List<Proveedor>> getProveedoresByFirstName(String firstName) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/nombre?firstName=$firstName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Proveedor.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener proveedores por nombre');
    }
  }
  
  /// Método para actualizar un proveedor
  static Future<Proveedor> updateProveedor(Proveedor proveedor) async {
    final url = Uri.parse('$_baseUrl/api/proveedores/${proveedor.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(proveedor.toJson()),
    );

    if (response.statusCode == 200) {
      return Proveedor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar el proveedor');
    }
  }


  /// Otros métodos de ejemplo para items (se mantienen sin cambios)
  static Future<dynamic> createItem(Map<String, dynamic> item) async {
    final url = Uri.parse('$_baseUrl/api/items');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear el item');
    }
  }

  static Future<dynamic> updateItem(int id, Map<String, dynamic> item) async {
    final url = Uri.parse('$_baseUrl/api/items/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar el item');
    }
  }

  

  static Future<bool> deleteItem(int id) async {
    final url = Uri.parse('$_baseUrl/api/items/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
