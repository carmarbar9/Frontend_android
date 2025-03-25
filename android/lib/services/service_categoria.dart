// services/category_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/categoria.dart';

class CategoryApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/categorias';

  static Future<List<Categoria>> getCategoriesByNegocioId(String negocioId) async {
    final url = Uri.parse('$_baseUrl/negocio/$negocioId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Categoria.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las categorías');
    }
  }
}
