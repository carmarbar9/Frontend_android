// lib/models/session_manager.dart
class SessionManager {
  static String? negocioId; 
  static String? negocioNombre;
  static String? ciudad;
  static String? duenoId;
  static String? username;  // Agregado para almacenar el username

  static void clear() {
    negocioId = null;
    negocioNombre = null;
    ciudad = null;
    duenoId = null;
    username = null;
  }
}
