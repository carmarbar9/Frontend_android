import 'package:android/models/lote.dart';
import 'categoria.dart';

class ProductoInventario {
  final int id;
  final String name;
  final Categoria categoria;
  final double precioCompra;
  final int cantidadDeseada;
  final int cantidadAviso;
  final String? negocioId; // 👈 Añadido

  ProductoInventario({
    required this.id,
    required this.name,
    required this.categoria,
    required this.precioCompra,
    required this.cantidadDeseada,
    required this.cantidadAviso,
    required this.negocioId, // 👈 Añadido
  });

  factory ProductoInventario.fromJson(Map<String, dynamic> json) {
    Categoria categoria;
    if (json['categoria'] is Map<String, dynamic>) {
      categoria = Categoria.fromJson(json['categoria']);
    } else {
      categoria = Categoria(
        id: json['categoria'].toString(),
        name: '',
        pertenece: '',
        negocioId: '',
      );
    }

    return ProductoInventario(
      id: json['id'],
      name: json['name'],
      categoria: categoria,
      precioCompra: (json['precioCompra'] as num).toDouble(),
      cantidadDeseada: json['cantidadDeseada'],
      cantidadAviso: json['cantidadAviso'],
      negocioId: json['negocioId'].toString(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoria': categoria.toJson(),
      'precioCompra': precioCompra,
      'cantidadDeseada': cantidadDeseada,
      'cantidadAviso': cantidadAviso,
      'negocioId': negocioId, // 👈 Añadido aquí también
    };
  }

  int calcularCantidad(List<Lote> lotes) {
    return lotes.fold(0, (sum, lote) => sum + lote.cantidad);
  }
}
