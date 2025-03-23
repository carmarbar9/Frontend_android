class ProductoInventario {
  final int id;
  final String name;
  final String categoria; // O bien "categoriaInventario" para coincidir
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
    return ProductoInventario(
      id: json['id'],
      name: json['name'],
      // Aquí se asigna el campo correcto, por ejemplo, "categoriaInventario" si ese es el key del JSON
      categoria: json['categoriaInventario'],
      precioCompra: (json['precioCompra'] as num).toDouble(),
      cantidadDeseada: json['cantidadDeseada'],
      cantidadAviso: json['cantidadAviso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoriaInventario': categoria, // Usa el mismo key que en el JSON
      'precioCompra': precioCompra,
      'cantidadDeseada': cantidadDeseada,
      'cantidadAviso': cantidadAviso,
    };
  }
}
