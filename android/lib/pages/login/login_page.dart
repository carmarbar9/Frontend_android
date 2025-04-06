// lib/pages/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:android/pages/home_page_empleado.dart';
import 'package:android/pages/login/elegirNegocio_page.dart';
import 'package:android/services/service_login.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/models/user.dart';
import 'package:android/services/service_empleados.dart'; // Importamos el servicio para obtener el empleado
import 'package:android/pages/login/registrar_page.dart';

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
        // Se intenta obtener el usuario
        final User? user = await ApiService.fetchUser(_username, _password);
        if (user == null) {
          throw 'Usuario o contraseña incorrectos';
        }

        // Debug
        print('Usuario logueado: ${user.username}');
        print('Authority cruda: ${user.authority.authority}');

        final rawAuthority = user.authority.authority.toLowerCase();
        final String authority =
            (rawAuthority == 'dueno') ? 'dueno' : rawAuthority;

        print('Authority corregida: $authority');

        // Limpiar la sesión actual y asignar el usuario actual
        SessionManager.clear();
        SessionManager.currentUser = user;
        SessionManager.userId = user.id.toString();
        SessionManager.username = user.username;


        if (authority == 'dueno') {
          // Para dueños, navegamos a la pantalla para elegir el negocio.
          await ApiService().fetchDuenoId(user.id);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ElegirNegocioPage(user: user),
            ),
          );
        } else if (authority == 'empleado') {
          // Para empleados, se obtiene el empleado para recuperar el negocio asociado.
          final empleado = await EmpleadoService.fetchEmpleadoByUserId(
            user.id!,
          );
          if (empleado == null) {
            throw 'No se encontró un empleado para este usuario';
          }
          if (empleado.negocio == null) {
            throw 'Este empleado no tiene un negocio asignado.';
          }

          SessionManager.negocioId = empleado.negocio.toString();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageEmpleado(user: user),
            ),
          );
        } else {
          throw 'Rol no reconocido';
        }
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
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

  void _navigateToForgotPassword() {
    // Lógica para recuperación de contraseña
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
                      hintText: '********',
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
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _navigateToForgotPassword,
                  child: const Text(
                    '¿Has olvidado la contraseña?\nRECUPERAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
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
