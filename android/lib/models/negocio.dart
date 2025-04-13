// lib/models/negocio.dart
import 'dueno.dart';

class Negocio {
  int? id;
  String? name; // Campo proveniente de NamedEntity
  int? tokenNegocio;
  String? direccion;
  String? codigoPostal;
  String? ciudad;
  String? pais;
  int? idDueno;
  Dueno? dueno;


  Negocio({
    this.id,
    this.name,
    this.tokenNegocio,
    this.direccion,
    this.codigoPostal,
    this.ciudad,
    this.pais,
    this.idDueno,
    this.dueno
  });

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tokenNegocio'] = tokenNegocio;
    data['direccion'] = direccion;
    data['codigoPostal'] = codigoPostal;
    data['ciudad'] = ciudad;
    data['pais'] = pais;
    data['idDueno'] = idDueno;
    return data;
  }
}
