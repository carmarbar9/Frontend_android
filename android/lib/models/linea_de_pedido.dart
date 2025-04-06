class LineaDePedido {
  int? id;
  int cantidad;
  double precioLinea;
  int pedidoId;
  int productoId;

  LineaDePedido({
    this.id,
    required this.cantidad,
    required this.precioLinea,
    required this.pedidoId,
    required this.productoId,
  });

  factory LineaDePedido.fromJson(Map<String, dynamic> json) {
    return LineaDePedido(
      id: json['id'],
      cantidad: json['cantidad'],
      precioLinea: (json['precioLinea'] as num).toDouble(),
      pedidoId: json['pedido']['id'],
      productoId: json['producto']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'precioLinea': precioLinea,
      'pedido': {'id': pedidoId},
      'producto': {'id': productoId},
    };
  }
}
