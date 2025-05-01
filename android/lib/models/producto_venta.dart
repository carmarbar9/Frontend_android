import 'categoria.dart';

class ProductoVenta {
  final int id;
  final String name;
  final double precioVenta;
  final Categoria categoria;

  ProductoVenta({
    required this.id,
    required this.name,
    required this.precioVenta,
    required this.categoria,
  });

  factory ProductoVenta.fromJson(Map<String, dynamic> json) {
    final categoriaJson = json['categoria'];
    return ProductoVenta(
      id: json['id'],
      name: json['name'],
      precioVenta: (json['precioVenta'] as num).toDouble(),
      categoria:
          categoriaJson is Map<String, dynamic>
              ? Categoria.fromJson(categoriaJson)
              : Categoria(
                id: categoriaJson.toString(),
                name: '',
                pertenece: '',
                negocioId: '',
              ),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final json = {
      'name': name,
      'precioVenta': precioVenta,
      'categoriaId': int.parse(categoria.id), 
    };

    if (includeId) {
      json['id'] = id;
    }

    return json;
  }
}
