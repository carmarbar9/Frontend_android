class DiaReparto {
  int id;
  String diaSemana;
  String? descripcion;
  int proveedorId;
  int negocioId;

  DiaReparto({
    required this.id,
    required this.diaSemana,
    this.descripcion,
    required this.proveedorId,
    required this.negocioId,
  });

  factory DiaReparto.fromJson(Map<String, dynamic> json) {
    return DiaReparto(
      id: json['id'],
      diaSemana: json['diaSemana'],
      descripcion: json['descripcion'],
      proveedorId: json['proveedor']['id'],
      negocioId: json['negocio']['id'],
    );
  }
}
