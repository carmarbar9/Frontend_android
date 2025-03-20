class Proveedor {
  int? id;
  String? name;
  String? email;
  String? telefono;
  String? direccion;

  Proveedor({this.id, this.name, this.email, this.telefono, this.direccion});

  // Crea una instancia de Proveedor a partir de un JSON
  Proveedor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    telefono = json['telefono'];
    direccion = json['direccion'];
  }

  // Convierte la instancia a un mapa JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['telefono'] = telefono;
    data['direccion'] = direccion;
    return data;
  }
}
