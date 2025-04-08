import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';

class PedidoService {
  final String baseUrl = 'http://10.0.2.2:8080/api/pedidos';

  Future<Pedido> createPedido(Pedido pedido) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pedido.toJson()),
    );
    if (response.statusCode == 201) {
      return Pedido.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el pedido: ${response.body}');
    }
  }
  
  // Obtiene los pedidos asociados a una mesa
  Future<List<Pedido>> getPedidosByMesaId(int mesaId) async {
    final url = Uri.parse('$baseUrl/mesa/$mesaId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pedido.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener pedidos: ${response.body}');
    }
  }


  Future<Pedido> updatePedido(int id, Pedido pedido) async {
  final url = Uri.parse('$baseUrl/$id');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(pedido.toJson()),
  );

  if (response.statusCode == 200) {
    return Pedido.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 404) {
    throw Exception('Pedido no encontrado con id $id');
  } else {
    throw Exception('Error al actualizar el pedido: ${response.body}');
  }
}
}
