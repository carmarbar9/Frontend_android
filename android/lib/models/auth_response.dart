// lib/models/auth_response.dart

class AuthResponse {
  final String token;
  

  AuthResponse({
    required this.token
  });

  factory AuthResponse.fromMap(Map<String, dynamic> json) {
    return AuthResponse(token: json['token'] ?? '');
  }
}
