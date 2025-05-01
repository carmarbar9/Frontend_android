import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscripcion.dart';
import '../models/session_manager.dart';


  class SubscripcionService {
  static Future<Subscripcion?> getDetallesSubscripcion() async {
    final token = await SessionManager.token;
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/subscriptions/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return Subscripcion.fromJson(jsonBody);
    } else {
      return null;
    }
  }
}


