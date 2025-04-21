import 'dart:convert';
import 'dart:math';
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

}
