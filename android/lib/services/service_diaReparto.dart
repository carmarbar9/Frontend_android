import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/session_manager.dart';

class DiaRepartoService {
  static const String baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/diasReparto';

  static Future<String?> getPrimerDiaRepartoDelProveedor(int proveedorId) async {
    final url = Uri.parse('$baseUrl/proveedor/$proveedorId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) return null;
      return data[0]['diaSemana']; // Ejemplo: 'SATURDAY'
    } else {
      return null;
    }
  }
}
