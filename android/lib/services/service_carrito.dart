import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/carrito.dart';
import '../models/session_manager.dart';

class ApiCarritoService {
  static const baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/carritos';

  static Future<Carrito> crearCarrito({
    required int proveedorId,
    required double precioTotal,
    required DateTime diaEntrega,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "proveedor": {"id": proveedorId},
        "precioTotal": precioTotal,
        "diaEntrega": diaEntrega.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return Carrito.fromJson(json.decode(response.body));
    } else {
      print('ERROR al crear carrito: ${response.statusCode} - ${response.body}');
      throw Exception('Error al crear el carrito');
    }
  }

  static Future<List<Carrito>> getCarritosByProveedor(int proveedorId) async {
    final url = Uri.parse('$baseUrl/proveedor/$proveedorId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${SessionManager.token}',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((json) => Carrito.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener carritos: ${response.body}");
    }
  }

  static Future<void> deleteCarrito(int carritoId) async {
    final url = Uri.parse('$baseUrl/$carritoId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      print('Error al eliminar carrito: ${response.statusCode} - ${response.body}');
      throw Exception('Error al eliminar el carrito');
    } else {
      print('Carrito $carritoId eliminado correctamente');
    }
  }


}
