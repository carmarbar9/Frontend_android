import 'package:flutter/material.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_empleados.dart';
import 'package:android/models/session_manager.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({Key? key}) : super(key: key);

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  String? _firstName;
  String? _lastName;
  String? _email;
  String? _numTelefono;
  String? _tokenEmpleado;
  String? _descripcion;
  String? _username;
  String? _password;

  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final negocioId = int.parse(SessionManager.negocioId!);

      Empleado newEmployee = Empleado(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        numTelefono: _numTelefono,
        tokenEmpleado: _tokenEmpleado,
        descripcion: _descripcion,
        username: _username,
        password: _password,
        negocio: negocioId,
      );

      setState(() => _isLoading = true);

      try {
        Empleado created = await EmpleadoService.createEmpleado(newEmployee);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Empleado creado correctamente")),
        );
        Navigator.pop(context, created);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        keyboardType: inputType,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF9B1D42)),
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
        validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
        onSaved: onSaved,
      ),
    );
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
          'EMPLEADOS',
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
            const Icon(Icons.people, size: 80, color: Color(0xFF9B1D42)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(icon: Icons.person, label: "Nombre", onSaved: (val) => _firstName = val),
                  _buildTextField(icon: Icons.person_outline, label: "Apellido", onSaved: (val) => _lastName = val),
                  _buildTextField(icon: Icons.email, label: "Email", inputType: TextInputType.emailAddress, onSaved: (val) => _email = val),
                  _buildTextField(icon: Icons.phone, label: "Teléfono", inputType: TextInputType.phone, onSaved: (val) => _numTelefono = val),
                  _buildTextField(icon: Icons.vpn_key, label: "Token Empleado", onSaved: (val) => _tokenEmpleado = val),
                  _buildTextField(icon: Icons.description, label: "Descripción", maxLines: 3, onSaved: (val) => _descripcion = val),
                  _buildTextField(icon: Icons.person_pin, label: "Usuario", onSaved: (val) => _username = val),
                  _buildTextField(icon: Icons.lock, label: "Contraseña", obscureText: true, onSaved: (val) => _password = val),
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
                              "Añadir Empleado",
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
