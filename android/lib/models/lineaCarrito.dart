import 'producto_inventario.dart';

class LineaDeCarrito {
  final int id;
  final int cantidad;
  final double precioLinea;
  final ProductoInventario producto;

  LineaDeCarrito({
    required this.id,
    required this.cantidad,
    required this.precioLinea,
    required this.producto,
  });

  factory LineaDeCarrito.fromJson(Map<String, dynamic> json) {
    return LineaDeCarrito(
      id: json['id'],
      cantidad: json['cantidad'],
      precioLinea: json['precioLinea'],
      producto: ProductoInventario.fromJson(json['producto']),
    );
  }
}
