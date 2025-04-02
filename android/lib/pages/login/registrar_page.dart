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
        Navigator.pop(context); // Volver a la pantalla anterior (LoginPage)
      }
    } catch (e) {
      // Muestra el error recibido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      appBar: AppBar(
        title: const Text('Registro de Dueño'),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de usuario
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de contraseña
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de nombre (firstName)
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de apellidos (lastName)
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tus apellidos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de correo electrónico
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu correo electrónico';
                  }
                  // Puedes agregar validación adicional para el email
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de número de teléfono
              TextFormField(
                controller: _numTelefonoController,
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu número de teléfono';
                  }
                  // Aquí puedes validar que tenga 9 dígitos si lo deseas
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo para tokenDueno
              TextFormField(
                controller: _tokenDuenoController,
                decoration: const InputDecoration(
                  labelText: 'Token de Dueño',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un token';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B1D42),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
