import 'package:flutter/material.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/home_page_empleado.dart';
import 'package:android/services/service_login.dart';

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

  // Función de login: siempre navega a HomePage, independientemente del resultado.
  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        // Intentamos realizar el login (aunque el resultado no se utiliza)
        await ApiService.login(_username, _password);
      } catch (error) {
        // Puedes mostrar el error en un SnackBar, pero igualmente navegarás a HomePage.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } finally {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  // Navega a la pantalla de registro (puedes completarlo)
  void _navigateToRegister() {
    // Lógica para registro
  }
  
  // Navega a la pantalla de recuperación de contraseña (puedes completarlo)
  void _navigateToForgotPassword() {
    // Lógica para recuperación de contraseña
  }

  // Botón "Dueño": navega a HomePage
  void _goToHomePageDueno() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // Botón "Empleado": navega a HomePageEmpleado
  void _goToHomePageEmpleado() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePageEmpleado()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco y diseño limpio
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 20),
                // Título "GastroSTOCK" (con "STOCK" en negrita)
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Gastro',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                        ),
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
                // Subtítulo
                const Text(
                  'Iniciar Sesión con Correo y Contraseña',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                // Caja para el correo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      hintText: 'correo@correo.com',
                      border: InputBorder.none,
                      icon: Icon(Icons.email),
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
                // Caja para la contraseña
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                // Caja para el botón "Entrar"
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
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Entrar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 30),
                // Enlaces para recuperar contraseña y registrarse
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
                    '¿No tienes cuenta?\nREGISTRATE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Botones "Dueño" y "Empleado"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: _goToHomePageDueno,
                      child: const Text('Dueño'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: _goToHomePageEmpleado,
                      child: const Text('Empleado'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla básica de registro
class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: const Center(
        child: Text("Pantalla de registro"),
      ),
    );
  }
}

// Pantalla para recuperar la contraseña
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await Future.delayed(const Duration(seconds: 2));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Correo de recuperación enviado")),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 3,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: _buildInputDecoration("Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa tu correo" : null,
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD33E66),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.send, size: 30),
                      label: const Text("Enviar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
