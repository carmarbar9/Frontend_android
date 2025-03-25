import 'categoria.dart';

class ProductoInventario {
  final int id;
  final String name;
  final Categoria categoria;
  final double precioCompra;
  final int cantidadDeseada;
  final int cantidadAviso;

  ProductoInventario({
    required this.id,
    required this.name,
    required this.categoria,
    required this.precioCompra,
    required this.cantidadDeseada,
    required this.cantidadAviso,
  });

  factory ProductoInventario.fromJson(Map<String, dynamic> json) {
    // Verificamos el tipo de "categoria"
    Categoria categoria;
    if (json['categoria'] is Map<String, dynamic>) {
      categoria = Categoria.fromJson(json['categoria']);
    } else {
      // Si no es Map, asumimos que es un id (int o String)
      categoria = Categoria(
        id: json['categoria'].toString(),
        name: '', // Si se conoce otro valor por defecto, se puede asignar aquí.
      );
    }

    return ProductoInventario(
      id: json['id'],
      name: json['name'],
      categoria: categoria,
      precioCompra: (json['precioCompra'] as num).toDouble(),
      cantidadDeseada: json['cantidadDeseada'],
      cantidadAviso: json['cantidadAviso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoria': categoria.toJson(), // En update se enviará el objeto completo.
      'precioCompra': precioCompra,
      'cantidadDeseada': cantidadDeseada,
      'cantidadAviso': cantidadAviso,
    };
  }
}
