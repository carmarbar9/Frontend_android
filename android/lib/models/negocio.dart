import 'dueno.dart';


class Negocio {
  int? id;
  String? name; // Campo proveniente de NamedEntity
  int? tokenNegocio;
  String? direccion;
  String? codigoPostal;
  String? ciudad;
  String? pais;
  Dueno? dueno;

  Negocio({
    this.id,
    this.name,
    this.tokenNegocio,
    this.direccion,
    this.codigoPostal,
    this.ciudad,
    this.pais,
    this.dueno,
  });

  // Crea una instancia de Negocio a partir de un JSON
  factory Negocio.fromJson(Map<String, dynamic> json) {
    return Negocio(
      id: json['id'],
      name: json['name'],
      tokenNegocio: json['tokenNegocio'],
      direccion: json['direccion'],
      codigoPostal: json['codigoPostal'],
      ciudad: json['ciudad'],
      pais: json['pais'],
      dueno: json['dueno'] != null ? Dueno.fromJson(json['dueno']) : null,
    );
  }

  // Convierte la instancia a un mapa JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tokenNegocio'] = tokenNegocio;
    data['direccion'] = direccion;
    data['codigoPostal'] = codigoPostal;
    data['ciudad'] = ciudad;
    data['pais'] = pais;
    if (dueno != null) {
      data['dueno'] = dueno!.toJson();
    }
    return data;
  }
}
