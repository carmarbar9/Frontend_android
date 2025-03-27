class Lote {
  final int id;
  final int cantidad;
  final DateTime fechaCaducidad;
  final int productoId;          // Id del productoInventario
  final int reabastecimientoId;  // Por ahora puedes dejarlo con un valor dummy

  Lote({
    required this.id,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.productoId,
    required this.reabastecimientoId,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'],
      cantidad: json['cantidad'],
      fechaCaducidad: DateTime.parse(json['fechaCaducidad']),
      productoId: json['producto']['id'],
      reabastecimientoId: json['reabastecimiento']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cantidad': cantidad,
      'fechaCaducidad': fechaCaducidad.toIso8601String(),
      'producto': {'id': productoId},
      'reabastecimiento': {'id': reabastecimientoId},
    };
  }

  Lote copyWith({
    int? id,
    int? cantidad,
    DateTime? fechaCaducidad,
    int? productoId,
    int? reabastecimientoId,
  }) {
    return Lote(
      id: id ?? this.id,
      cantidad: cantidad ?? this.cantidad,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      productoId: productoId ?? this.productoId,
      reabastecimientoId: reabastecimientoId ?? this.reabastecimientoId,
    );
  }
}
