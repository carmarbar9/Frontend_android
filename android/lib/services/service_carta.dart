import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_venta.dart';

class ProductoVentaService {
  Future<List<ProductoVenta>> getProductosByCategoriaNombre(String categoriaNombre) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta/categoriaVenta/$categoriaNombre');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductoVenta.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener productos');
    }
  }

  Future<void> deleteProductoVenta(int id) async {
  final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta/$id');
  final response = await http.delete(url);

  if (response.statusCode != 204) {
    throw Exception('No se pudo eliminar el producto');
  }
}

Future<void> updateProductoVenta(ProductoVenta producto) async {
  final url = Uri.parse('http://10.0.2.2:8080/api/productosVenta/${producto.id}');
  
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(producto.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al actualizar producto');
  }
}
Future<ProductoVenta> createProductoVenta(ProductoVenta producto) async {
  final response = await http.post(
  Uri.parse('http://10.0.2.2:8080/api/productosVenta'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(producto.toJson(includeId: false)), // <--- aquí está la clave
);


  if (response.statusCode == 201) {
    return ProductoVenta.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error al crear producto: ${response.body}');
  }
}
}
