import 'package:android/models/user.dart';

class SessionManager {
  static String? token;
  static User? currentUser;
  static String? userId;
  static String? username;
  static String? authority; // <-- Añadimos esto
  static String? negocioId;
  static String? negocioNombre;
  static String? ciudad;
  static int? duenoId;
  static int? empleadoId;

  // Limpiar sesión
  static void clear() {
    token = null;
    currentUser = null;
    userId = null;
    username = null;
    authority = null;
    negocioId = null;
    negocioNombre = null;
    ciudad = null;
    duenoId = null;
    empleadoId = null;
  }

  // Guardar datos del usuario tras login y fetch de /me
  static void saveUserSession(User user, String newToken) {
    clear();
    token = newToken;
    currentUser = user;
    userId = user.id.toString();
    username = user.username;
    authority = user.authority.authority.toLowerCase(); // <-- Esto es clave
  }
}
