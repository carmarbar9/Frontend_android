import 'package:android/models/negocio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class NegocioService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

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
}