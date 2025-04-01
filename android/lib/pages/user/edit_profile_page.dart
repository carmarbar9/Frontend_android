// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:android/models/perfil.dart';
import 'package:android/services/service_perfil.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController numTelefonoController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.profile.firstName);
    lastNameController = TextEditingController(text: widget.profile.lastName);
    emailController = TextEditingController(text: widget.profile.email);
    // Se asume que el campo 'username' está en la propiedad 'user'
    usernameController = TextEditingController(text: widget.profile.user.username);
    numTelefonoController = TextEditingController(text: widget.profile.numTelefono);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    numTelefonoController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Construir el perfil actualizado (manteniendo token y otros datos que no se editan)
      final updatedProfile = UserProfile(
        id: widget.profile.id,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        numTelefono: numTelefonoController.text,
        tokenDueno: widget.profile.tokenDueno,
        user: widget.profile.user.copyWith(username: usernameController.text),
      );

      try {
        final updated = await UserProfileService()
            .updateUserProfile(widget.profile.id, updatedProfile);
        Navigator.pop(context, updated);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: numTelefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
