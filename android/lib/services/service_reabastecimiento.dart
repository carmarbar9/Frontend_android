import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reabastecimiento.dart';
import '../models/session_manager.dart';


class ReabastecimientoService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/reabastecimientos';

  static Future<Reabastecimiento> crearReabastecimiento(Reabastecimiento reabastecimiento) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reabastecimiento.toJson()),
    );

    if (response.statusCode == 201) {
      return Reabastecimiento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear reabastecimiento: ${response.body}");
    }
  }

  static Future<List<Reabastecimiento>> getByNegocio(int negocioId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/negocio/$negocioId'),
    headers: {
      'Authorization': 'Bearer ${SessionManager.token}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Reabastecimiento.fromJson(json)).toList();
  } else {
    throw Exception("Error al obtener reabastecimientos: ${response.body}");
  }
}



}
