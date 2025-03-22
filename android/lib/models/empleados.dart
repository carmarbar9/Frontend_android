import 'negocio.dart';

class Empleado {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? numTelefono;
  String? tokenEmpleado;
  String? descripcion;
  int? userId; // Para enviar el user_id
  Negocio? negocio; // Se enviará solo el id como negocio_id

  Empleado({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.numTelefono,
    this.tokenEmpleado,
    this.descripcion,
    this.userId,
    this.negocio,
  });

  // Crea una instancia de Empleado a partir de un JSON recibido
  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      numTelefono: json['numTelefono'],
      tokenEmpleado: json['tokenEmpleado'],
      descripcion: json['descripcion'],
      // Extraemos el id del usuario si está disponible
      userId: json['user'] != null ? json['user']['id'] : null,
      negocio: json['negocio'] != null ? Negocio.fromJson(json['negocio']) : null,
    );
  }

  // Convierte la instancia a un mapa JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // No incluimos el id en la creación, ya que suele ser autogenerado
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['num_telefono'] = numTelefono;
    data['token_empleado'] = tokenEmpleado;
    data['descripcion'] = descripcion;
    data['user_id'] = userId;
    if (negocio != null) {
      data['negocio_id'] = negocio!.id;
    }
    return data;
  }
}
