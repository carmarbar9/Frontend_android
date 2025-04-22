class Pedido {
  int? id;
  String fecha; // En formato ISO
  double precioTotal;
  int mesaId;
  int empleadoId;
  int negocioId;

  Pedido({
    this.id,
    required this.fecha,
    required this.precioTotal,
    required this.mesaId,
    required this.empleadoId,
    required this.negocioId,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      fecha: json['fecha'],
      precioTotal: (json['precioTotal'] as num).toDouble(),
      mesaId: json['mesaId'],
      empleadoId: json['empleadoId'],
      negocioId: json['negocioId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'precioTotal': precioTotal,
      'mesaId': mesaId,
      'empleadoId': empleadoId,
      'negocioId': negocioId,
    };
  }
}
