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
}
