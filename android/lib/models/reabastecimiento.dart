import 'package:android/models/session_manager.dart';

class Reabastecimiento {
  final int? id; // <<-- Aquí que sea nullable
  final DateTime fecha;
  final double precioTotal;
  final String referencia;
  final int proveedorId;
  final int negocioId;

  Reabastecimiento({
    required this.id,
    required this.fecha,
    required this.precioTotal,
    required this.referencia,
    required this.proveedorId,
    required this.negocioId,
  });

Map<String, dynamic> toJson() => {
  'fecha': fecha.toIso8601String().split('T')[0],
  'precioTotal': precioTotal,
  'referencia': referencia,
  'proveedor': {'id': proveedorId},
  'negocio': {'id': negocioId}, // 🔥 SOLO EL ID
};

  factory Reabastecimiento.fromJson(Map<String, dynamic> json) => Reabastecimiento(
    id: json['id'],
    fecha: DateTime.parse(json['fecha']),
    precioTotal: json['precioTotal'],
    referencia: json['referencia'],
    proveedorId: json['proveedor']['id'],
    negocioId: json['negocio']['id'],
  );
}
