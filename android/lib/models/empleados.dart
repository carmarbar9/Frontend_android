// empleados.dart
import 'negocio.dart';
import 'user.dart';

class Empleado {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? numTelefono;
  String? tokenEmpleado;
  String? descripcion;
  User? user;
  Negocio? negocio;

  Empleado({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.numTelefono,
    this.tokenEmpleado,
    this.descripcion,
    this.user,
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
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      // Si negocio es un entero, se crea un Negocio solo con id; de lo contrario, se crea a partir del JSON
      negocio: json['negocio'] is int 
          ? Negocio(id: json['negocio'])
          : (json['negocio'] != null ? Negocio.fromJson(json['negocio']) : null),
    );
  }

  // Convierte la instancia a un mapa JSON para enviarlo al backend.
  // Se envían todos los datos (incluyendo id, user y negocio) para cumplir con la entidad completa.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Incluimos el id si está presente (por ejemplo, en un PUT)
    if (id != null) data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['numTelefono'] = numTelefono;
    data['tokenEmpleado'] = tokenEmpleado;
    data['descripcion'] = descripcion;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (negocio != null) {
      data['negocio'] = negocio!.toJson();
    }
    return data;
  }
}
