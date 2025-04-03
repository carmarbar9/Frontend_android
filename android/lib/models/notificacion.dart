enum TipoNotificacion {
  inventario,
  proveedor,
  empleado,
  otro,
}

class Notificacion {
  final String id;
  final TipoNotificacion tipo;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final Map<String, dynamic>? datosExtra;

  Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.datosExtra,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      tipo: TipoNotificacion.values.firstWhere(
        (e) => e.toString() == 'TipoNotificacion.${json['tipo']}',
        orElse: () => TipoNotificacion.otro,
      ),
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fecha: DateTime.parse(json['fecha']),
      datosExtra: json['datosExtra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.toString().split('.').last,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'datosExtra': datosExtra,
    };
  }
}
