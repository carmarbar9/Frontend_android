class Empleado {
  int? id;
  String? username;
  String? password;
  String? firstName;
  String? lastName;
  String? email;
  String? numTelefono;
  String? tokenEmpleado;
  String? descripcion;
  int? negocio; // ID del negocio
  String? negocioNombre; // Nombre del negocio

  Empleado({
    this.id,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.email,
    this.numTelefono,
    this.tokenEmpleado,
    this.descripcion,
    this.negocio,
    this.negocioNombre,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final negocioObj = json['negocio'];

    return Empleado(
      id: json['id'],
      username: user != null ? user['username'] : null,
      password: user != null ? user['password'] : null,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      numTelefono: json['numTelefono'],
      tokenEmpleado: json['tokenEmpleado'],
      descripcion: json['descripcion'],
      negocio:
          negocioObj is int
              ? negocioObj
              : (negocioObj != null ? negocioObj['id'] : null),
      negocioNombre: negocioObj != null ? negocioObj['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (email != null) data['email'] = email;
    if (numTelefono != null) data['numTelefono'] = numTelefono;
    if (descripcion != null) data['descripcion'] = descripcion;
    if (negocio != null) data['negocio'] = negocio; // 👈 debe llamarse así
    return data;
  }
}
