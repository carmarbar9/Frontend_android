import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/lineaCarrito.dart';
import 'package:android/models/session_manager.dart';

class ApiLineaCarritoService {
  static const baseUrl = 'http://10.0.2.2:8080/api/lineasDeCarrito';

  static Future<List<LineaDeCarrito>> getLineasByCarrito(int carritoId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/carrito/$carritoId'),
    headers: {
      'Authorization': 'Bearer ${SessionManager.token}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
    return body.map((json) => LineaDeCarrito.fromJson(json)).toList();
  } else {
    print('❌ Error al obtener líneas de carrito: ${response.statusCode}');
    print('🔁 Body: ${response.body}');
    throw Exception('Error al cargar líneas del carrito');
  }
}


  static Future<void> crearLineaDeCarrito({
    required int carritoId,
    required int productoId,
    required int cantidad,
    required double precioLinea,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'carrito': {'id': carritoId},
        'producto': {'id': productoId},
        'cantidad': cantidad,
        'precioLinea': precioLinea,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la línea de carrito: ${response.body}');
    }
  }

}
