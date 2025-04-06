import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lote.dart';

class LoteProductoService {

  static const String baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/lotes';

  static Future<List<Lote>> getLotesByProductoId(int productoId) async {
    final url = Uri.parse(
      'https://ispp-2425-g2.ew.r.appspot.com/api/lotes/producto/$productoId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lote.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los lotes del producto');
    }
  }

  static Future<void> updateLote(Lote lote) async {
    final url = Uri.parse('$baseUrl/${lote.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(lote.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el lote: ${response.body}');
    }
  }

  /// Eliminar un lote por ID
  static Future<void> deleteLote(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el lote');
    }
  }

  static Future<Lote> createLote(Lote lote) async {
  final url = Uri.parse('https://ispp-2425-g2.ew.r.appspot.com/api/lotes');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(lote.toJson()),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return Lote.fromJson(data);
  } else {
    throw Exception('Error al crear el lote: ${response.body}');
  }
}

}
