// lib/models/user.dart

class Authority {
  final int id;
  final String authority;

  Authority({
    required this.id,
    required this.authority,
  });

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      id: json['id'],
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authority': authority,
    };
  }
}

class User {
  final int id;
  final String username;
  final String password;
  final Authority authority;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.authority,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      authority: Authority.fromJson(json['authority']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'authority': authority.toJson(),
    };
  }

  /// Permite crear una copia del objeto actual, reemplazando las propiedades que se indiquen.
  User copyWith({
    int? id,
    String? username,
    String? password,
    Authority? authority,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      authority: authority ?? this.authority,
    );
  }
}
