// lib/services/service_negocio.dart
import 'package:android/models/negocio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NegocioService {
  static const String _baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com';

  static Future<List<Negocio>> getNegociosByDuenoId(int userId) async {
    final url = Uri.parse('$_baseUrl/api/negocios/dueno/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Negocio.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron obtener los negocios');
    }
  }

  static Future<Negocio> createNegocio(Negocio negocio) async {
    final url = Uri.parse('$_baseUrl/api/negocios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(negocio.toJson()),
    );
    if (response.statusCode == 201) {
      return Negocio.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el negocio: ${response.statusCode}');
    }
  }

  static Future<Negocio> updateNegocio(int id, Negocio negocio) async {
    final url = Uri.parse('$_baseUrl/api/negocios/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(negocio.toJson()),
    );
    if (response.statusCode == 200) {
      return Negocio.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el negocio: ${response.statusCode}');
    }
  }

  static Future<bool> deleteNegocio(int id) async {
    final url = Uri.parse('$_baseUrl/api/negocios/$id');
    final response = await http.delete(url);
    return response.statusCode == 204;
  }
}
