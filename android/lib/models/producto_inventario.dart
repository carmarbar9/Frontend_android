import 'categoria.dart';
import 'lote.dart';

class ProductoInventario {
  final int id;
  final String name;
  final Categoria categoria;
  final double precioCompra;
  final int cantidadDeseada;
  final int cantidadAviso;
  final int proveedorId; // Nuevo campo proveedorId

  ProductoInventario({
    required this.id,
    required this.name,
    required this.categoria,
    required this.precioCompra,
    required this.cantidadDeseada,
    required this.cantidadAviso,
    required this.proveedorId,
  });

  factory ProductoInventario.fromJson(Map<String, dynamic> json) {
    // Lógica para cargar la categoría
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
      proveedorId: json['proveedor'] is Map<String, dynamic>
          ? json['proveedor']['id']
          : json['proveedor'], // Adaptado para recibir objeto o id
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoriaId': int.parse(categoria.id), // Solo id de categoria
      'precioCompra': precioCompra,
      'cantidadDeseada': cantidadDeseada,
      'cantidadAviso': cantidadAviso,
      'proveedorId': proveedorId, // Nuevo proveedorId
    };
  }

  // Manteniendo tu función para calcular cantidad total de lotes
  int calcularCantidad(List<Lote> lotes) {
    return lotes.fold(0, (sum, lote) => sum + lote.cantidad);
  }
}
