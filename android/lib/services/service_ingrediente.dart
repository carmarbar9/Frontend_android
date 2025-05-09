import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/ingrediente.dart';
import 'package:android/models/session_manager.dart';

class IngredienteService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/ingredientes';

  /// Obtener ingredientes por productoVenta.id
  static Future<List<Ingrediente>> getIngredientesByProductoVenta(
    int productoVentaId,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/productoVenta/$productoVentaId'),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Ingrediente.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar ingredientes del producto de venta: ${response.body}',
      );
    }
  }

  /// Añadir nuevo ingrediente a un producto de venta
  static Future<void> addIngrediente({
    required int cantidad,
    required int productoInventarioId,
    required int productoVentaId,
    required int categoriaId, // Este es el parámetro que se pasa a la función
    required int negocioId,
  }) async {
    // Aquí no es necesario redefinir categoriaId, porque ya lo tienes como parámetro
    final negocioId = int.parse(SessionManager.negocioId!);

    final body = {
      'cantidad': cantidad,
      'productoInventario': {
        'id': productoInventarioId,
        'categoria': {
          'id': categoriaId, // Usa el categoriaId pasado como parámetro
          'negocio': {'id': negocioId},
        },
      },
      'productoVenta': {'id': productoVentaId},
    };

    print("📤 Enviando ingrediente: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print("📥 Status: ${response.statusCode}");
    print("📥 Body: ${response.body}");

    if (response.statusCode != 201) {
      throw Exception('Error al añadir ingrediente: ${response.body}');
    }
  }

  /// Eliminar ingrediente por su ID
  static Future<void> deleteIngrediente(int ingredienteId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$ingredienteId'),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar ingrediente: ${response.body}');
    }
  }

  /// Actualizar ingrediente existente
  static Future<void> updateIngrediente({
    required int id,
    required int cantidad,
    required int productoInventarioId,
    required int productoVentaId,
  }) async {
    final Map<String, dynamic> body = {
      'cantidad': cantidad,
      'productoInventario': {'id': productoInventarioId},
      'productoVenta': {'id': productoVentaId},
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar ingrediente: ${response.body}');
    }
  }
}
