// lib/services/service_perfil.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/perfil.dart';

class UserProfileService {
  // Endpoint base para Dueno (update y delete)
  final String duenoApiUrl = 'http://10.0.2.2:8080/api/duenos/';

  /// Método existente para obtener perfil a partir del username.
  /// Se obtiene primero el usuario y luego el dueño.
  final String userApiUrl = 'http://10.0.2.2:8080/api/users/username/';
  Future<UserProfile> fetchUserProfileByUsername(String username) async {
    // Paso 1: Obtener el usuario por username
    final userResponse = await http.get(Uri.parse('$userApiUrl$username'));
    if (userResponse.statusCode != 200) {
      throw Exception('Error al cargar datos del usuario: ${userResponse.statusCode}');
    }
    final userJson = json.decode(userResponse.body);
    final int userId = userJson['id'];
    
    // Paso 2: Obtener el dueño usando el id del usuario
    final duenoResponse = await http.get(Uri.parse('${duenoApiUrl}user/$userId'));
    if (duenoResponse.statusCode != 200) {
      throw Exception('Error al cargar datos del dueño: ${duenoResponse.statusCode}');
    }
    return UserProfile.fromJson(json.decode(duenoResponse.body));
  }

  /// Actualiza el perfil (PUT /api/duenos/{id})
  Future<UserProfile> updateUserProfile(int id, UserProfile updatedProfile) async {
    final url = Uri.parse('$duenoApiUrl$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedProfile.toJson()),
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar perfil: ${response.statusCode}');
    }
  }

  Future<bool> deleteUserProfile(int duenoId) async {
    final url = 'http://10.0.2.2:8080/api/users/$duenoId';
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200 || response.statusCode == 204;
  }



}
