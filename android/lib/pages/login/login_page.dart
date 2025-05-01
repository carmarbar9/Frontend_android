// lib/pages/login/login_page.dart
import 'package:android/services/service_dueno.dart';
import 'package:flutter/material.dart';
import 'package:android/pages/home_page_empleado.dart';
import 'package:android/pages/login/elegirNegocio_page.dart';
import 'package:android/services/service_login.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/models/user.dart';
import 'package:android/services/service_empleados.dart'; // Importamos el servicio para obtener el empleado
import 'package:android/pages/login/registrar_page.dart';
import 'package:android/models/auth_response.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final apiService = ApiService();

        // 1. Login: obtenemos el token
        final authResponse = await apiService.login(_username, _password);

        // Limpiamos sesión previa y guardamos el token
        SessionManager.clear();
        SessionManager.token = authResponse.token;

        // 2. Obtenemos el usuario actual (/me)
        final user = await apiService.fetchCurrentUser();

        // 3. Guardamos datos del usuario en SessionManager
        SessionManager.saveUserSession(user, authResponse.token);

        // 4. Comprobamos authority
        if (SessionManager.authority == 'dueno') {
          final dueno = await DuenoService.fetchDuenoByUserId(
            user.id,
            SessionManager.token!,
          );

          if (dueno == null) throw 'No se encontró el dueño';

          SessionManager.duenoId = dueno.id;

          print("➡️ Suscripción del usuario:");
          print("Tipo: ${SessionManager.user?.subscripcion?.planType}");
          print(
            "¿Es premium?: ${SessionManager.user?.subscripcion?.isPremium}",
          );
          print(
            "¿Está activa?: ${SessionManager.user?.subscripcion?.isActive}",
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ElegirNegocioPage(user: user),
            ),
          );
        } else if (SessionManager.authority == 'empleado') {
          final empleado = await EmpleadoService.fetchEmpleadoByUserId(
            user.id,
            SessionManager.token!,
          );

          if (empleado == null) throw 'No se encontró el empleado';
          if (empleado.negocio == null) throw 'Empleado sin negocio asignado';

          SessionManager.negocioId = empleado.negocio.toString();
          SessionManager.empleadoId = empleado.id!;

          print(
            'Empleado logueado correctamente. ID: ${SessionManager.empleadoId}',
          );
          print(
            'Negocio logueado correctamente. ID: ${SessionManager.negocioId}',
          );
          print('Authority: ${SessionManager.authority}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageEmpleado(user: user),
            ),
          );
        } else {
          throw 'Rol no reconocido';
        }
      } catch (e) {
        final errorMessage = 'Este usuario no existe';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 20),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Gastro',
                        style: TextStyle(color: Colors.black, fontSize: 28),
                      ),
                      TextSpan(
                        text: 'STOCK',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Iniciar Sesión con Usuario y Contraseña',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      hintText: 'Usuario',
                      border: InputBorder.none,
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      return null;
                    },
                    onSaved: (value) => _username = value!,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      hintText: '****',
                      border: InputBorder.none,
                      icon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9B1D42),
                        Color(0xFFB12A50),
                        Color(0xFFD33E66),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : const Text(
                              'Entrar',
                              style: TextStyle(fontSize: 18),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _navigateToRegister,
                  child: const Text(
                    '¿No tienes cuenta?\nREGÍSTRATE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
