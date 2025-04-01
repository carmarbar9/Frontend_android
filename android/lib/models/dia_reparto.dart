class DiaReparto {
  int id;
  String diaSemana;
  String? descripcion;
  int? proveedorId;

  DiaReparto({
    required this.id,
    required this.diaSemana,
    this.descripcion,
    required this.proveedorId,
  });

  factory DiaReparto.fromJson(Map<String, dynamic> json) {
    return DiaReparto(
      id: json['id'],
      diaSemana: json['diaSemana'],
      descripcion: json['descripcion'],
      proveedorId: json['proveedor']['id'],
    );
  }
}
