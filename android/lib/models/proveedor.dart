class Proveedor {
  int? id;
  String? name;
  String? email;
  String? telefono;
  String? direccion;
  int? negocioId;

  Proveedor({
    this.id,
    this.name,
    this.email,
    this.telefono,
    this.direccion,
    this.negocioId,
  });

  Proveedor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    telefono = json['telefono'];
    direccion = json['direccion'];
    negocioId = json['negocio']?['id']; // extrae id anidado
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['telefono'] = telefono;
    data['direccion'] = direccion;
    if (negocioId != null) {
      data['negocio'] = {'id': negocioId}; // lo empaqueta como objeto
    }
    return data;
  }
}
