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
      mesaId: json['mesa']['id'],
      empleadoId: json['empleado']['id'],
      negocioId: json['negocio']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'precioTotal': precioTotal,
      'mesa': {'id': mesaId},
      'empleado': {'id': empleadoId},
      'negocio': {'id': negocioId},
    };
  }
}
