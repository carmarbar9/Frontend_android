// lib/models/session_manager.dart
import 'package:android/models/user.dart';

class SessionManager {
  static String? negocioId; 
  static String? negocioNombre;
  static String? ciudad;
  static String? duenoId;
  static String? username;
  static User? currentUser;

  static void clear() {
    negocioId = null;
    negocioNombre = null;
    ciudad = null;
    duenoId = null;
    username = null;
    currentUser = null;
  }
}
