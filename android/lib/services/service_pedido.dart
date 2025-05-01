import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';
import '../models/session_manager.dart';

class PedidoService {
  final String baseUrl = 'http://10.0.2.2:8080/api/pedidos';

  /// Crear un pedido
  Future<Pedido> createPedido(Pedido pedido) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(pedido.toJson()),
    );

    if (response.statusCode == 201) {
      return Pedido.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el pedido: ${response.body}');
    }
  }

  Future<Pedido> createPedidoConDto(Pedido pedido) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/dto',
      ), // Asegúrate de que tu baseUrl no termina con / ya
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(pedido.toJsonParaDto()),
    );

    if (response.statusCode == 201) {
      return Pedido.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el pedido DTO: ${response.body}');
    }
  }

  /// Obtener pedidos de una mesa por mesaId
  Future<List<Pedido>> getPedidosByMesaId(int mesaId) async {
    final url = Uri.parse('$baseUrl/mesa/$mesaId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pedido.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al obtener pedidos: ${response.body}');
    }
  }

  /// Actualizar un pedido
  Future<Pedido> updatePedido(int id, Pedido pedido) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
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

  /// Obtener un pedido por id
  Future<Pedido> getPedidoById(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Pedido.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Pedido no encontrado con id $id');
    } else {
      throw Exception('Error al obtener el pedido: ${response.body}');
    }
  }

  Future<List<Pedido>> loadPedidosByNegocioId(int negocioId) async {
    final url = Uri.parse('$baseUrl/dto/venta/$negocioId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pedido.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception(
        'Error al obtener los pedidos del negocio: ${response.body}',
      );
    }
  }
}
