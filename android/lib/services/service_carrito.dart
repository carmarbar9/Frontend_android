import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/carrito.dart';
import '../models/session_manager.dart';

class ApiCarritoService {
  static const baseUrl = 'http://10.0.2.2:8080/api/carritos';

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

}
