import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_venta.dart';
import '../models/session_manager.dart';

class ProductoVentaService {
  Future<List<ProductoVenta>> getProductosByCategoriaNombre(String categoriaNombre) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta/categoriaVenta/$categoriaNombre');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoVenta.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener productos: ${response.body}');
    }
  }

  Future<void> deleteProductoVenta(int id) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('No se pudo eliminar el producto: ${response.body}');
    }
  }

  Future<void> updateProductoVenta(ProductoVenta producto) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta/${producto.id}');
    
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar producto: ${response.body}');
    }
  }

  Future<ProductoVenta> createProductoVenta(ProductoVenta producto) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(producto.toJson(includeId: false)),
    );

    if (response.statusCode == 201) {
      return ProductoVenta.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear producto: ${response.body}');
    }
  }
  
}
