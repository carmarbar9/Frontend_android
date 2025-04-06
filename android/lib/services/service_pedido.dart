import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';

class PedidoService {
  final String baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/pedidos';

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
