import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/linea_de_pedido.dart';
import '../models/session_manager.dart';

class LineaDePedidoService {
  final String baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/lineasDePedido';

  Future<LineaDePedido> createLineaDePedido(LineaDePedido linea) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(linea.toJson()),
    );

    if (response.statusCode == 201) {
      return LineaDePedido.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la línea de pedido: ${response.body}');
    }
  }

  Future<List<LineaDePedido>> getLineasByPedidoId(int pedidoId) async {
    final url = Uri.parse('$baseUrl/pedido/$pedidoId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => LineaDePedido.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener líneas de pedido: ${response.body}');
    }
  }

  Future<void> updateLineaDePedido(LineaDePedido linea) async {
    final url = Uri.parse('$baseUrl/${linea.id}');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(linea.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la línea: ${response.body}');
    }
  }

  Future<void> deleteLineaDePedido(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la línea: ${response.body}');
    }
  }
}
