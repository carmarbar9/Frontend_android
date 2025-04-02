// lib/pages/login/register_page.dart
import 'package:flutter/material.dart';
import 'package:android/services/service_login.dart';
import 'package:android/models/dueno.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos requeridos
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numTelefonoController = TextEditingController();
  final TextEditingController _tokenDuenoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Creamos el Map con los datos que espera el backend
    final Map<String, dynamic> registrationData = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'numTelefono': _numTelefonoController.text.trim(),
      'tokenDueno': _tokenDuenoController.text.trim(),
    };

    try {
      final Dueno? dueno = await ApiService.registerDueno(registrationData);

      // Si el registro es exitoso, mostramos un mensaje y volvemos al login
      if (dueno != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso!')),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior (LoginPage)
      }
    } catch (e) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para construir cada campo de texto con el mismo estilo
  Widget _buildTextField({
    required IconData icon,
    required String label,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9B1D42)),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF9B1D42), fontSize: 16),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF9B1D42)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF9B1D42), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Campo requerido' : null,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _numTelefonoController.dispose();
    _tokenDuenoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'PermanentMarker',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person, size: 80, color: Color(0xFF9B1D42)),
              const SizedBox(height: 20),
              _buildTextField(
                icon: Icons.person,
                label: "Nombre de usuario",
                controller: _usernameController,
              ),
              _buildTextField(
                icon: Icons.lock,
                label: "Contraseña",
                controller: _passwordController,
                inputType: TextInputType.visiblePassword,
              ),
              _buildTextField(
                icon: Icons.account_circle,
                label: "Nombre",
                controller: _firstNameController,
              ),
              _buildTextField(
                icon: Icons.account_circle_outlined,
                label: "Apellidos",
                controller: _lastNameController,
              ),
              _buildTextField(
                icon: Icons.email,
                label: "Correo electrónico",
                controller: _emailController,
                inputType: TextInputType.emailAddress,
              ),
              _buildTextField(
                icon: Icons.phone,
                label: "Número de teléfono",
                controller: _numTelefonoController,
                inputType: TextInputType.phone,
              ),
              _buildTextField(
                icon: Icons.vpn_key,
                label: "Token de Dueño",
                controller: _tokenDuenoController,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B1D42),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Registrar",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TitanOne',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
