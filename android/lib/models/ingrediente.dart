import 'producto_inventario.dart';
import 'producto_venta.dart';
import 'package:android/models/categoria.dart';


class Ingrediente {
  final int id;
  final int cantidad;
  final ProductoInventario productoInventario;
  final ProductoVenta? productoVenta;

  Ingrediente({
    required this.id,
    required this.cantidad,
    required this.productoInventario,
    this.productoVenta,
  });

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    ProductoInventario inventario;

    // Detectamos si viene como objeto o como ID
    if (json['productoInventario'] is Map<String, dynamic>) {
      inventario = ProductoInventario.fromJson(json['productoInventario']);
    } else {
      inventario = ProductoInventario(
        id: json['productoInventario'],
        name: 'Desconocido', // Por si solo viene el ID
        categoria: Categoria(id: '0', name: ''),
        precioCompra: 0,
        cantidadDeseada: 0,
        cantidadAviso: 0,
      );
    }

    return Ingrediente(
      id: json['id'],
      cantidad: json['cantidad'],
      productoInventario: inventario,
      productoVenta: null, // opcional si no lo usas
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cantidad': cantidad,
      'productoInventario': productoInventario.toJson(),
      'productoVenta': productoVenta?.id,
    };
  }
}
