import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/producto_inventario.dart';


class InventoryApiService {
  // Asegúrate de usar la IP adecuada para tu entorno
  static const String _baseUrl = 'http://10.0.2.2:8080/api/productosInventario';

  /// Obtiene todos los productos de inventario
  static Future<List<ProductoInventario>> getProductosInventario() async {
    final url = Uri.parse('$_baseUrl');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoInventario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los productos de inventario');
    }
  }

  /// Obtiene un producto de inventario por ID
  static Future<ProductoInventario?> getProductoInventarioById(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ProductoInventario.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener el producto de inventario');
    }
  }

  /// Obtiene un producto de inventario por nombre
  static Future<ProductoInventario?> getProductoInventarioByName(String name) async {
    final url = Uri.parse('$_baseUrl/name/$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ProductoInventario.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener el producto de inventario por nombre');
    }
  }

  /// Obtiene productos de inventario por categoría
  static Future<List<ProductoInventario>> getProductosInventarioByCategoria(String categoria) async {
    final url = Uri.parse('$_baseUrl/categoria/$categoria');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoInventario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los productos por categoría');
    }
  }

  /// Crea un producto de inventario
  static Future<ProductoInventario> createProductoInventario(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return ProductoInventario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el producto: ${response.body}');
    }
  }


  /// Actualiza un producto de inventario
  static Future<void> updateProductoInventario(ProductoInventario producto) async {
    // Asegúrate de que el id no sea nulo y sea consistente
    final url = Uri.parse('$_baseUrl/${producto.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode != 204) { // Según el controller devuelve NO_CONTENT
      throw Exception('Error al actualizar el producto de inventario');
    }
  }

  /// Elimina un producto de inventario por ID
  static Future<void> deleteProductoInventario(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el producto de inventario');
    }
  }

  static Future<List<ProductoInventario>> getAllProductosInventario() async {
  final url = Uri.parse('http://10.0.2.2:8080/api/productosInventario');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ProductoInventario.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos de inventario');
  }
}

}