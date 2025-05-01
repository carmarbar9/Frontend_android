class LineaDePedido {
  int? id;
  int cantidad;
  double precioUnitario; // ✅ obligatorio
  bool salioDeCocina; // ✅ obligatorio
  int pedidoId;
  int productoId;
  String? productoName; // opcional para mostrar

  LineaDePedido({
    this.id,
    required this.cantidad,
    required this.precioUnitario,
    required this.salioDeCocina,
    required this.pedidoId,
    required this.productoId,
    this.productoName,
  });

factory LineaDePedido.fromJson(Map<String, dynamic> json) {
  return LineaDePedido(
    id: json['id'],
    cantidad: json['cantidad'],
    precioUnitario: (json['precioUnitario'] as num).toDouble(),
    salioDeCocina: json['salioDeCocina'].toString() == 'true', // ✅ renombrado y forzado a bool
    pedidoId: json['pedidoId'] ?? json['pedido']['id'],
    productoId: json['productoId'] ?? json['producto']['id'],
    productoName: json['nombreProducto'] ?? json['producto']?['name'],
  );
}


  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'salioDeCocina': salioDeCocina,
      'pedido': {'id': pedidoId},
      'producto': {'id': productoId},
    };
  }

Map<String, dynamic> toDtoJson() {
  return {
    if (id != null) 'id': id,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'salioDeCocina': salioDeCocina, // ✅ renombrado
    'pedidoId': pedidoId,
    'productoId': productoId,
  };
}

  
}
