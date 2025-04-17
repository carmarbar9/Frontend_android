class Carrito {
  final int id;
  final double precioTotal;
  final DateTime diaEntrega;
  final int proveedorId;

  Carrito({
    required this.id,
    required this.precioTotal,
    required this.diaEntrega,
    required this.proveedorId,
  });

  factory Carrito.fromJson(Map<String, dynamic> json) {
    return Carrito(
      id: json['id'],
      precioTotal: json['precioTotal'],
      diaEntrega: DateTime.parse(json['diaEntrega']),
      proveedorId: json['proveedor']['id'],
    );
  }

}
