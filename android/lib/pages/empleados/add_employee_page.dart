import 'package:flutter/material.dart';
import 'package:android/models/empleados.dart';
import 'package:android/models/negocio.dart';
import 'package:android/services/service_empleados.dart';

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
  int? _userId;
  int? _negocioId;

  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Crea el objeto Empleado usando el negocioId y userId
      Empleado newEmployee = Empleado(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        numTelefono: _numTelefono,
        tokenEmpleado: _tokenEmpleado,
        descripcion: _descripcion,
        userId: _userId,
        // Solo se necesita el id para enviar el negocio_id
        negocio: _negocioId != null ? Negocio(id: _negocioId) : null,
      );

      setState(() {
        _isLoading = true;
      });

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
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('Añadir Empleado'),
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
              // Nombre
              TextFormField(
                decoration: _buildInputDecoration("Nombre"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa el nombre" : null,
                onSaved: (value) => _firstName = value,
              ),
              const SizedBox(height: 16),
              // Apellido
              TextFormField(
                decoration: _buildInputDecoration("Apellido"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa el apellido" : null,
                onSaved: (value) => _lastName = value,
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                decoration: _buildInputDecoration("Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa el email" : null,
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 16),
              // Teléfono
              TextFormField(
                decoration: _buildInputDecoration("Teléfono"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa el teléfono" : null,
                onSaved: (value) => _numTelefono = value,
              ),
              const SizedBox(height: 16),
              // Token Empleado
              TextFormField(
                decoration: _buildInputDecoration("Token Empleado"),
                validator: (value) => value == null || value.isEmpty
                    ? "Ingresa el token del empleado"
                    : null,
                onSaved: (value) => _tokenEmpleado = value,
              ),
              const SizedBox(height: 16),
              // Descripción
              TextFormField(
                decoration: _buildInputDecoration("Descripción"),
                maxLines: 3,
                onSaved: (value) => _descripcion = value,
              ),
              const SizedBox(height: 16),
              // User ID
              TextFormField(
                decoration: _buildInputDecoration("User ID"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa el User ID" : null,
                onSaved: (value) => _userId = int.tryParse(value!),
              ),
              const SizedBox(height: 16),
              // Negocio ID
              TextFormField(
                decoration: _buildInputDecoration("Negocio ID"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingresa el Negocio ID" : null,
                onSaved: (value) => _negocioId = int.tryParse(value!),
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
                      icon: const Icon(Icons.save, size: 30),
                      label: const Text("Guardar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
