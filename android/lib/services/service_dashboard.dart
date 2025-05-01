import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_inventario.dart';
import '../models/producto_venta.dart';
import '../models/categoria.dart';
import '../models/session_manager.dart';

class DashboardService {
  static final String _baseUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api';

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${SessionManager.token}',
    };
  }

  static Future<List<MapEntry<ProductoInventario, int>>>
  fetchProductosConMenosCantidad(int negocioId) async {
    final url = Uri.parse(
      '$_baseUrl/productosInventario/menosCantidad/$negocioId',
    );
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> raw = jsonDecode(response.body);
      return raw.entries.map((entry) {
        final producto = ProductoInventario(
          id: 0,
          name: entry.key,
          categoria: Categoria(id: '', name: '', pertenece: '', negocioId: ''),
          precioCompra: 0.0,
          cantidadDeseada: 0,
          cantidadAviso: 0,
          proveedorId: 0,
          negocioId: 0,
        );
        return MapEntry(producto, entry.value as int);
      }).toList();
    } else {
      throw Exception('Error al cargar productos con menos cantidad');
    }
  }

  static Future<List<MapEntry<ProductoVenta, int>>> fetchProductosMasVendidos(
    int negocioId,
  ) async {
    final url = Uri.parse('$_baseUrl/productosVenta/masVendido/$negocioId');
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> raw = jsonDecode(response.body);
      return raw.entries.map((entry) {
        final producto = ProductoVenta(
          id: 0,
          name: entry.key,
          precioVenta: 0.0,
          categoria: Categoria(id: '', name: '', pertenece: '', negocioId: ''),
        );
        return MapEntry(producto, entry.value as int);
      }).toList();
    } else {
      throw Exception('Error al cargar productos más vendidos');
    }
  }

  static Future<Map<String, double>> fetchIngresosPorMes(int negocioId) async {
    final url = Uri.parse('$_baseUrl/pedidos/ingresos/$negocioId');
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } else {
      throw Exception('Error al cargar ingresos por mes');
    }
  }

  static Future<Map<int, int>> fetchVolumenPorSemana(int negocioId) async {
    final url = Uri.parse('$_baseUrl/pedidos/volumen/$negocioId');
    final response = await http.get(url, headers: getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data.map((key, value) => MapEntry(int.parse(key), value as int));
    } else {
      throw Exception('Error al cargar volumen de pedidos por semana');
    }
  }
}
