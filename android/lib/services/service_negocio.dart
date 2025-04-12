// lib/services/service_negocio.dart
import 'package:android/models/negocio.dart';
import 'package:android/models/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NegocioService {
  static const String _baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com';

  /// Obtener negocios por duenoId
  static Future<List<Negocio>> getNegociosByDuenoId(int duenoId) async {
    final url = Uri.parse('$_baseUrl/api/negocios/dueno/$duenoId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Negocio.fromJson(json)).toList();
    } else {
      print('ERROR AL CARGAR NEGOCIOS');
      print('Código de error: ${response.statusCode}');
      print('Body: ${response.body}');
      print('Token usado: ${SessionManager.token}');
      print('DuenoID usado: $duenoId');
      throw Exception('Error al cargar negocios: ${response.body}');
    }
  }

  /// Obtener negocios propios (mejorado)
  static Future<List<Negocio>> getMisNegocios() async {
    final url = Uri.parse('$_baseUrl/api/negocios');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Negocio.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return []; 
    } else {
      throw Exception('Error al cargar negocios: ${response.body}');
    }
  }

  /// Obtener negocio por id
  static Future<Negocio?> fetchNegocioById(int id) async {
    final url = Uri.parse('$_baseUrl/api/negocios/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Negocio.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener el negocio: ${response.body}');
    }
  }

  /// Crear un negocio
  static Future<Negocio> createNegocio(Negocio negocio) async {
    final url = Uri.parse('$_baseUrl/api/negocios');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(negocio.toJson()),
    );

    if (response.statusCode == 201) {
      return Negocio.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el negocio: ${response.body}');
    }
  }

  /// Actualizar un negocio
  static Future<Negocio> updateNegocio(int id, Negocio negocio) async {
    final url = Uri.parse('$_baseUrl/api/negocios/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(negocio.toJson()),
    );

    if (response.statusCode == 200) {
      return Negocio.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el negocio: ${response.body}');
    }
  }

  /// Eliminar un negocio
  static Future<bool> deleteNegocio(int id) async {
    final url = Uri.parse('$_baseUrl/api/negocios/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 204;
  }
}
