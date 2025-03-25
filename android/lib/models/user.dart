// user.dart
import 'authority.dart';

class User {
  int? id;
  String? username;
  String? password;
  Authority? authority;

  User({this.id, this.username, this.password, this.authority});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      authority:
          json['authority'] != null ? Authority.fromJson(json['authority']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['password'] = password;
    if (authority != null) {
      data['authority'] = authority!.toJson();
    }
    return data;
  }
}
