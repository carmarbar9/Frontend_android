class Pedido {
  int? id;
  String fecha;
  double precioTotal;
  int mesaId;
  int negocioId;
  int? empleadoId; // 👈 ahora opcional

  Pedido({
    this.id,
    required this.fecha,
    required this.precioTotal,
    required this.mesaId,
    required this.negocioId,
    this.empleadoId, // 👈 ya no es required
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      fecha: json['fecha'],
      precioTotal: (json['precioTotal'] as num).toDouble(),
      mesaId: json['mesa']?['id'] ?? json['mesaId'],
      negocioId: json['negocio']?['id'] ?? json['negocioId'],
      empleadoId: json['empleado']?['id'] ?? json['empleadoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fecha': fecha,
      'precioTotal': precioTotal,
      'mesa': {'id': mesaId},
      'negocio': {'id': negocioId},
    };
  }

  Map<String, dynamic> toJsonParaDto() {
    return {
      if (id != null) 'id': id,
      'fecha': fecha,
      'precioTotal': precioTotal,
      'mesaId': mesaId,
      'negocioId': negocioId,
      'empleadoId': empleadoId,// ❌ No se incluye empleadoId: backend lo infiere del token
    };
  }
}
