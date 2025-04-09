import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/mesa.dart';

class MesaService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/mesas';

  /// Obtener todas las mesas
  static Future<List<Mesa>> getMesas() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Mesa.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las mesas');
    }
  }

  /// Crear una nueva mesa
  static Future<Mesa> createMesa(Mesa mesa) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(mesa.toJson()),
    );

    if (response.statusCode == 201) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Mesa.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Error al crear la mesa');
    }
  }

  /// Eliminar una mesa por ID
  static Future<void> deleteMesaById(int id) async {
    final url = Uri.parse("$_baseUrl/$id");
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la mesa');
    }
  }
}
