import 'dart:convert';
import 'package:android/models/mesadto.dart';
import 'package:http/http.dart' as http;
import 'package:android/models/mesa.dart';
import 'package:android/models/session_manager.dart';

class MesaService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/mesas';

  static Future<List<Mesa>> getMesas() async {
    final int negocioId = int.parse(SessionManager.negocioId!);

    final url = Uri.parse('$_baseUrl/negocio/$negocioId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Mesa.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return []; // No hay mesas
    } else {
      throw Exception('Error al obtener las mesas: ${response.body}');
    }
  }

  /// Crear una nueva mesa
  static Future<Mesa> createMesa(Mesa mesa) async {
    final url = Uri.parse(
      _baseUrl + '/dto',
    ); // Asegúrate de que la URL apunte al endpoint correcto
    final mesaDTO = MesaDTO(
      nombre: mesa.name!,
      numeroAsientos: mesa.numeroAsientos!,
      negocioId: int.parse(SessionManager.negocioId!),
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(mesaDTO.toJson()), // Aquí usamos el toJson() del DTO
    );

    if (response.statusCode == 201) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Mesa.fromJson(
        jsonDecode(decodedBody),
      ); // Convertir la respuesta al objeto Mesa
    } else {
      throw Exception('Error al crear la mesa: ${response.body}');
    }
  }

  /// Eliminar una mesa por ID
  static Future<void> deleteMesaById(int id) async {
    final url = Uri.parse("$_baseUrl/$id");
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la mesa: ${response.body}');
    }
  }
}
