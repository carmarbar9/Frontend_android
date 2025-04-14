// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:android/models/perfil.dart';
import 'package:android/services/service_perfil.dart';
import 'package:android/models/user.dart';
import 'package:bcrypt/bcrypt.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? _firstName;
  String? _lastName;
  String? _email;
  String? _username;
  String? _numTelefono;

  // Controladores para los campos de contraseña
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Widget _buildTextField({
    required IconData icon,
    required String label,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    required FormFieldSetter<String> onSaved,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: inputType,
        maxLines: maxLines,
        obscureText: obscureText,
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
        validator:
            (value) =>
                (value == null || value.isEmpty) ? 'Campo requerido' : null,
        onSaved: onSaved,
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Si el campo de password está vacío → mantener la actual
      String finalPassword = widget.profile.user.password;

      // Si el usuario escribió algo → se enviará en texto plano para que el backend la encripte
      if (_passwordController.text.isNotEmpty) {
        final passwordInput = _passwordController.text.trim();
        finalPassword = BCrypt.hashpw(passwordInput, BCrypt.gensalt());
      }

      UserProfile updatedProfile = UserProfile(
        id: widget.profile.id,
        firstName: _firstName ?? widget.profile.firstName,
        lastName: _lastName ?? widget.profile.lastName,
        email: _email ?? widget.profile.email,
        numTelefono: _numTelefono ?? widget.profile.numTelefono,
        tokenDueno: widget.profile.tokenDueno,
        user: widget.profile.user.copyWith(
          username: _username ?? widget.profile.user.username,
          password: finalPassword,
        ),
      );

      setState(() {
        _isLoading = true;
      });

      try {
        UserProfile updated = await UserProfileService().updateUserProfile(
          widget.profile.id,
          updatedProfile,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado correctamente")),
        );
        Navigator.pop(context, updated);
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al actualizar: $error")));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _firstName = widget.profile.firstName;
    _lastName = widget.profile.lastName;
    _email = widget.profile.email;
    _username = widget.profile.user.username;
    _numTelefono = widget.profile.numTelefono;
    // Campos de contraseña vacíos por defecto
    _passwordController.text = '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'EDITAR DUEÑO',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'PermanentMarker',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person, size: 80, color: Color(0xFF9B1D42)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    icon: Icons.person,
                    label: "Nombre",
                    initialValue: widget.profile.firstName,
                    onSaved: (val) => _firstName = val,
                  ),
                  _buildTextField(
                    icon: Icons.person_outline,
                    label: "Apellido",
                    initialValue: widget.profile.lastName,
                    onSaved: (val) => _lastName = val,
                  ),
                  _buildTextField(
                    icon: Icons.email,
                    label: "Email",
                    inputType: TextInputType.emailAddress,
                    initialValue: widget.profile.email,
                    onSaved: (val) => _email = val,
                  ),
                  _buildTextField(
                    icon: Icons.person,
                    label: "Usuario",
                    initialValue: widget.profile.user.username,
                    onSaved: (val) => _username = val,
                  ),
                  // Campo para nueva contraseña
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.vpn_key,
                          color: Color(0xFF9B1D42),
                        ),
                        labelText: "Nueva Contraseña",
                        labelStyle: const TextStyle(
                          color: Color(0xFF9B1D42),
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF9B1D42),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF9B1D42),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        // Es opcional, si se deja igual se conserva la contraseña actual.
                        return null;
                      },
                    ),
                  ),
                  // Campo para repetir la nueva contraseña
                  _buildTextField(
                    icon: Icons.phone,
                    label: "Teléfono",
                    inputType: TextInputType.phone,
                    initialValue: widget.profile.numTelefono,
                    onSaved: (val) => _numTelefono = val,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B1D42),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text(
                            "Guardar Cambios",
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
          ],
        ),
      ),
    );
  }
}
