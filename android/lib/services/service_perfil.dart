// lib/services/service_perfil.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android/models/perfil.dart';
import 'package:android/models/session_manager.dart';

class UserProfileService {
  final String duenoApiUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/duenos/';
  final String userApiUrl = 'https://ispp-2425-g2.ew.r.appspot.com/api/users/username/';

  /// Obtener perfil a partir del username
  Future<UserProfile> fetchUserProfileByUsername(String username) async {
    // Paso 1: Obtener usuario por username
    final userResponse = await http.get(
      Uri.parse('$userApiUrl$username'),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (userResponse.statusCode != 200) {
      throw Exception(
        'Error al cargar datos del usuario: ${userResponse.statusCode}',
      );
    }

    final userJson = json.decode(userResponse.body);
    final int userId = userJson['id'];

    // Paso 2: Obtener dueño por userId
    final duenoResponse = await http.get(
      Uri.parse('${duenoApiUrl}user/$userId'),
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    if (duenoResponse.statusCode != 200) {
      throw Exception(
        'Error al cargar datos del dueño: ${duenoResponse.statusCode}',
      );
    }

    return UserProfile.fromJson(json.decode(duenoResponse.body));
  }

  Future<UserProfile> fetchUserProfileByUserId(int userId) async {
  final response = await http.get(
    Uri.parse('https://ispp-2425-g2.ew.r.appspot.com/api/duenos/user/$userId'),
    headers: {
      'Authorization': 'Bearer ${SessionManager.token}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return UserProfile.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al cargar datos del perfil: ${response.statusCode}');
  }
}


  /// Actualizar perfil
  Future<UserProfile> updateUserProfile(
    int id,
    UserProfile updatedProfile,
  ) async {
    final url = Uri.parse('$duenoApiUrl$id');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedProfile.toJson()),
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar perfil: ${response.statusCode}');
    }
  }

  /// Eliminar perfil
  Future<bool> deleteUserProfile(int duenoId) async {
    final url = Uri.parse('https://ispp-2425-g2.ew.r.appspot.com/api/users/$duenoId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${SessionManager.token}',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
