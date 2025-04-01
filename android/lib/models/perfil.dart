// lib/models/perfil.dart
import 'user.dart';

class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String numTelefono;
  final User user;
  final String tokenDueno;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.numTelefono,
    required this.user,
    required this.tokenDueno,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      numTelefono: json['numTelefono'],
      user: User.fromJson(json['user']),
      tokenDueno: json['tokenDueno'],
    );
  }

  /// Devuelve un mapa con las claves que espera el backend (DuenoDTO)
  Map<String, dynamic> toJson() {
    return {
      'username': user.username,
      'password': user.password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'numTelefono': numTelefono,
      'tokenDueno': tokenDueno,
    };
  }
}
