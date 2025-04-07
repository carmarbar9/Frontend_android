// lib/models/session_manager.dart
import 'package:android/models/user.dart';

class SessionManager {
  static String? token;
  static String? negocioId; 
  static String? negocioNombre;
  static String? ciudad;
  static String? userId;
  static String? username;
  static User? currentUser;
  static int? duenoId;
  
  static void clear() {
    token = null;
    negocioId = null;
    negocioNombre = null;
    ciudad = null;
    userId = null;
    username = null;
    currentUser = null;
    duenoId = null;
  }
}
