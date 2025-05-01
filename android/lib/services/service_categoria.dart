import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/categoria.dart';
import 'package:android/models/session_manager.dart';

class CategoryApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/categorias';

  static Future<List<Categoria>> getCategoriesByNegocioId(
    String negocioId,
  ) async {
    final url = Uri.parse('$_baseUrl/negocio/$negocioId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final filteredList =
          jsonList.where((json) => json['pertenece'] == "INVENTARIO").toList();
      return filteredList.map((json) => Categoria.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      // No hay categorías aún
      return [];
    } else {
      throw Exception('Error al obtener las categorías: ${response.body}');
    }
  }

  static Future<List<Categoria>> getCategoriesByNegocioIdVenta(
    String negocioId,
  ) async {
    final url = Uri.parse('$_baseUrl/negocio/$negocioId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final filteredList =
          jsonList.where((json) => json['pertenece'] == "VENTA").toList();
      return filteredList.map((json) => Categoria.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      // No hay categorías aún
      return [];
    } else {
      throw Exception('Error al obtener las categorías: ${response.body}');
    }
  }

  static Future<Categoria> createCategory(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/dto');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    try {
      return Categoria.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Error al crear la categoría: ${response.body}');
    }
  }

  static Future<void> deleteCategory(String id) async {
    final url = Uri.parse('$_baseUrl/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar categoría: ${response.body}');
    }
  }

  static Future<List<Categoria>> getCategoriesByName(String name) async {
    final url = Uri.parse('$_baseUrl/nombre/$name');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final filteredList =
          jsonList.where((json) => json['pertenece'] == "INVENTARIO").toList();
      return filteredList.map((json) => Categoria.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
        'Error al obtener las categorías de inventario por nombre: ${response.body}',
      );
    }
  }

  static Future<List<Categoria>> getCategoriesByNameCarta(String name) async {
    final url = Uri.parse('$_baseUrl/nombre/$name');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final filteredList =
          jsonList.where((json) => json['pertenece'] == "VENTA").toList();
      return filteredList.map((json) => Categoria.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
        'Error al obtener las categorías de carta por nombre: ${response.body}',
      );
    }
  }

  static Future<Categoria> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/dto/$id');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Categoria.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Categoría no encontrada');
    } else {
      throw Exception('Error al actualizar la categoría: ${response.body}');
    }
  }
}
