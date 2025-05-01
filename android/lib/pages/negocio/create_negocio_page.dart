// lib/pages/negocio/create_negocio_page.dart
import 'package:flutter/material.dart';
import 'package:android/models/negocio.dart';
import 'package:android/models/dueno.dart';
import 'package:android/services/service_negocio.dart';
import 'package:android/models/session_manager.dart';
import 'dart:math';

class CreateNegocioPage extends StatefulWidget {
  const CreateNegocioPage({Key? key}) : super(key: key);

  @override
  _CreateNegocioPageState createState() => _CreateNegocioPageState();
}

class _CreateNegocioPageState extends State<CreateNegocioPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _direccion;
  String? _codigoPostal;
  String? _ciudad;
  String? _pais;

  bool _isLoading = false;

  Future<void> _crear() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        // Generar un token aleatorio solo para cumplir el DTO
        int token = Random().nextInt(900000000) + 100000000; // 9 dígitos random

        Negocio nuevoNegocio = Negocio(
          name: _name,
          tokenNegocio: token, // random
          direccion: _direccion,
          codigoPostal: _codigoPostal,
          ciudad: _ciudad,
          pais: _pais,
          idDueno: SessionManager.duenoId, // lo coges del usuario logueado
        );

        Negocio creado = await NegocioService.createNegocio(nuevoNegocio);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Negocio creado correctamente")),
        );
        Navigator.pop(context, creado);
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $error")));
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
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
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
        validator:
            (value) =>
                (value == null || value.isEmpty) ? 'Campo requerido' : null,
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
          'Crear Nuevo Negocio',
          style: TextStyle(
            fontSize: 24,
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
            const Icon(Icons.store, size: 80, color: Color(0xFF9B1D42)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    icon: Icons.store,
                    label: "Nombre del Negocio",
                    onSaved: (val) => _name = val,
                  ),
                  _buildTextField(
                    icon: Icons.location_on,
                    label: "Dirección",
                    onSaved: (val) => _direccion = val,
                  ),
                  _buildTextField(
                    icon: Icons.location_city,
                    label: "Ciudad",
                    onSaved: (val) => _ciudad = val,
                  ),
                  _buildTextField(
                    icon: Icons.markunread_mailbox,
                    label: "Código Postal",
                    inputType: TextInputType.number,
                    onSaved: (val) => _codigoPostal = val,
                  ),
                  _buildTextField(
                    icon: Icons.flag,
                    label: "País",
                    onSaved: (val) => _pais = val,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B1D42),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _crear,
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 36,
                          ),
                          label: const Text(
                            "Crear Negocio",
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
