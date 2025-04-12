class LineaDePedido {
  int? id;
  int cantidad;
  double precioLinea;
  int pedidoId;
  int productoId;
  String? productoName; // Nuevo campo opcional

  LineaDePedido({
    this.id,
    required this.cantidad,
    required this.precioLinea,
    required this.pedidoId,
    required this.productoId,
    this.productoName,
  });

  factory LineaDePedido.fromJson(Map<String, dynamic> json) {
    return LineaDePedido(
      id: json['id'],
      cantidad: json['cantidad'],
      precioLinea: (json['precioLinea'] as num).toDouble(),
      pedidoId: json['pedido']['id'],
      productoId: json['producto']['id'],
      productoName: json['producto']['name'], // Se obtiene el nombre
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'precioLinea': precioLinea,
      'pedido': {'id': pedidoId},
      'producto': {
        'id': productoId,
        'name': productoName, // Se incluye el nombre en el JSON
      },
    };
  }
}
