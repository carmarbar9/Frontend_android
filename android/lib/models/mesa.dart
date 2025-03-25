import 'negocio.dart';

class Mesa {
  int? id;
  String? name;
  int? numeroAsientos;
  Negocio? negocio;

  Mesa({
    this.id,
    this.name,
    this.numeroAsientos,
    this.negocio,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'],
      name: json['name'],
      numeroAsientos: json['numeroAsientos'],
      negocio: json['negocio'] is Map
          ? Negocio.fromJson(json['negocio'])
          : (json['negocio'] != null ? Negocio(id: json['negocio']) : null),
    );
  }

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
