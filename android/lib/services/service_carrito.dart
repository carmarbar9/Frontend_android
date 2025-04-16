import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_manager.dart';

class ApiCarritoService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/carritos';

  static Future<void> crearCarrito({
    required int proveedorId,
    required double precioTotal,
    required DateTime diaEntrega,
  }) async {
    final url = Uri.parse(baseUrl);

    final body = jsonEncode({
      'proveedor': {'id': proveedorId},
      'precioTotal': precioTotal,
      'diaEntrega': diaEntrega.toIso8601String(),
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear el carrito: ${response.body}');
    }
  }
}
