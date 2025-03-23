import 'negocio.dart';

class Mesa {
  int? id;
  String? name; // Heredado de NamedEntity en el backend
  int? numeroAsientos;
  Negocio? negocio;

  Mesa({
    this.id,
    this.name,
    this.numeroAsientos,
    this.negocio,
  });

  // Crea una instancia de Mesa a partir de un JSON
  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'],
      name: json['name'],
      numeroAsientos: json['numeroAsientos'],
      negocio: json['negocio'] != null ? Negocio.fromJson(json['negocio']) : null,
    );
  }

  // Convierte la instancia a un mapa JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['numeroAsientos'] = numeroAsientos;
    if (negocio != null) {
      data['negocio'] = negocio!.toJson();
    }
    return data;
  }
}
