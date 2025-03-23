import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/mesa.dart';
import 'package:flutter/foundation.dart';

class MesaService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/mesas';

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
