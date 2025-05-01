class MesaDTO {
  String? nombre;
  int? numeroAsientos;
  int? negocioId;

  MesaDTO({
    this.nombre,
    this.numeroAsientos,
    this.negocioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'numeroAsientos': numeroAsientos,
      'negocioId': negocioId,
    };
  }
}
