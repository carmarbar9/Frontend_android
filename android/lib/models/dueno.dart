class Dueno {
  int? id;
  String? name; // Si en Person tienes nombre, lo incluyes aquí
  String? tokenDueno; // Representa el tokenDueno del backend

  Dueno({
    this.id,
    this.name,
    this.tokenDueno,
  });

  /// Crea una instancia de Dueno a partir de un JSON.
  factory Dueno.fromJson(Map<String, dynamic> json) {
    return Dueno(
      id: json['id'],
      name: json['name'],
      tokenDueno: json['tokenDueno'] ?? json['tokenDueno'],
    );
  }

  /// Convierte la instancia a un mapa JSON para enviarlo al backend.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tokenDueno'] = tokenDueno;
    return data;
  }
}