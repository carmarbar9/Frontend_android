import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/producto_inventario.dart';
import 'package:android/models/session_manager.dart';

class InventoryApiService {
  static const String _baseUrl =
      'https://ispp-2425-g2.ew.r.appspot.com/api/productosInventario';

  /// Obtiene todos los productos de inventario
  static Future<List<ProductoInventario>> getProductosInventario() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoInventario.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener los productos de inventario: ${response.body}',
      );
    }
  }

  /// Obtiene un producto de inventario por ID
  static Future<ProductoInventario?> getProductoInventarioById(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ProductoInventario.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Error al obtener el producto de inventario: ${response.body}',
      );
    }
  }

  /// Obtiene un producto de inventario por nombre
  static Future<ProductoInventario?> getProductoInventarioByName(
    String name,
  ) async {
    final url = Uri.parse('$_baseUrl/name/$name');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ProductoInventario.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Error al obtener el producto de inventario por nombre: ${response.body}',
      );
    }
  }

  /// Obtiene productos de inventario por categoría
  static Future<List<ProductoInventario>> getProductosInventarioByCategoria(
    String categoria,
  ) async {
    final url = Uri.parse('$_baseUrl/categoria/$categoria');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoInventario.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener los productos por categoría: ${response.body}',
      );
    }
  }

  static Future<List<ProductoInventario>> getProductosInventarioByCategoriaId(
    int categoriaId, // Recibimos el ID de la categoría
  ) async {
    final url = Uri.parse('$_baseUrl/categoriaId/$categoriaId');
    print('URL de productos por categoría: $url'); // Verifica la URL aquí

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoInventario.fromJson(json)).toList();
    } else {
      print(
        'Error en la respuesta de productos: ${response.body}',
      ); // Imprime la respuesta para verificar
      throw Exception(
        'Error al obtener los productos de la categoría por ID: ${response.body}',
      );
    }
  }

  /// Crea un producto de inventario
  static Future<ProductoInventario> createProductoInventario(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return ProductoInventario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el producto: ${response.body}');
    }
  }

  /// Actualiza un producto de inventario
  static Future<void> updateProductoInventario(
    ProductoInventario producto,
  ) async {
    final url = Uri.parse('$_baseUrl/${producto.id}');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar el producto de inventario: ${response.body}',
      );
    }
  }

  /// Elimina un producto de inventario por ID
  static Future<void> deleteProductoInventario(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Error al eliminar el producto de inventario: ${response.body}',
      );
    }
  }

  /// Obtiene todos los productos de inventario (duplicada pero limpia)
  static Future<List<ProductoInventario>> getAllProductosInventario() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ProductoInventario.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar productos de inventario: ${response.body}',
      );
    }
  }
}
