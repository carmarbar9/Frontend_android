import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/dueno.dart';

class DuenoService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/duenos'; 

  static Future<Dueno?> fetchDuenoByUserId(int userId, String token) async {
    final url = Uri.parse('$baseUrl/user/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Dueno.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }
}
