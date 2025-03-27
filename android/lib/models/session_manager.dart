class SessionManager {
  static String? negocioId; // Por defecto "1" en pruebas
  static String? negocioNombre;
  static String? ciudad;

  static void clear() {
    negocioId = null;
    negocioNombre = null;
    ciudad = null;
  }
}
