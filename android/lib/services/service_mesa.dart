import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/mesa.dart';

class MesaService {
  static const String _baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/mesas';

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
}
