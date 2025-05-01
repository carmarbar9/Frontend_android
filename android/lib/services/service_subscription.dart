import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscripcion.dart';
import '../models/session_manager.dart';


  class SubscripcionService {
  static Future<Subscripcion?> getDetallesSubscripcion() async {
    final token = await SessionManager.token;
    final response = await http.get(
      Uri.parse('https://ispp-2425-g2.ew.r.appspot.com/api/subscriptions/status'),
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


