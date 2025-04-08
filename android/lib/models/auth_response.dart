// lib/models/auth_response.dart

class AuthResponse {
  final String token;
  // Puedes agregar otros campos según la respuesta de tu backend,
  // por ejemplo, información del usuario:
  final int userId;
  final String username;
  final String authority;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.username,
    required this.authority,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> data) {
    return AuthResponse(
      token: data['token'] as String,
      userId: data['userId'] as int,
      username: data['username'] as String,
      authority: data['authority'] as String,
    );
  }
}
