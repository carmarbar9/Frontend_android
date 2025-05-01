import 'package:android/models/authority.dart';
import 'package:android/models/subscripcion.dart';

class User {
  final int id;
  final String username;
  final String password;
  final Authority authority;
  final Subscripcion? subscripcion;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.authority,
    this.subscripcion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print("🧾 JSON recibido en User.fromJson: $json");
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      authority: Authority.fromJson(json['authority']),
      subscripcion:
          json['subscripcion'] != null
              ? Subscripcion.fromJson(json['subscripcion'])
              : null,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    Authority? authority,
    Subscripcion? subscripcion,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      authority: authority ?? this.authority,
      subscripcion: subscripcion ?? this.subscripcion,
    );
  }
}
