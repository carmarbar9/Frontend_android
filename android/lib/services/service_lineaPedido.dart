import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/linea_de_pedido.dart';

class LineaDePedidoService {
  final String baseUrl = 'http://10.0.2.2:8080/api/lineasDePedido';

  Future<LineaDePedido> createLineaDePedido(LineaDePedido linea) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(linea.toJson()),
    );
    if (response.statusCode == 201) {
      return LineaDePedido.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la línea de pedido: ${response.body}');
    }
  }
}
