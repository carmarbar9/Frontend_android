// lib/pages/negocio/edit_negocio_page.dart
import 'package:flutter/material.dart';
import 'package:android/models/negocio.dart';
import 'package:android/services/service_negocio.dart';

class EditNegocioPage extends StatefulWidget {
  final Negocio negocio;

  const EditNegocioPage({Key? key, required this.negocio}) : super(key: key);

  @override
  _EditNegocioPageState createState() => _EditNegocioPageState();
}

class _EditNegocioPageState extends State<EditNegocioPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _direccion;
  late String _ciudad;
  late String _codigoPostal;
  late String _pais;
  late String _tokenNegocio;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.negocio.name ?? "";
    _direccion = widget.negocio.direccion ?? "";
    _ciudad = widget.negocio.ciudad ?? "";
    _codigoPostal = widget.negocio.codigoPostal ?? "";
    _pais = widget.negocio.pais ?? "";
    _tokenNegocio = widget.negocio.tokenNegocio?.toString() ?? "";
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        int? token = _tokenNegocio.isNotEmpty ? int.tryParse(_tokenNegocio) : null;
        Negocio negocioActualizado = Negocio(
          id: widget.negocio.id,
          name: _name,
          tokenNegocio: token,
          direccion: _direccion,
          codigoPostal: _codigoPostal,
          ciudad: _ciudad,
          pais: _pais,
          dueno: widget.negocio.dueno,
        );
        Negocio actualizado = await NegocioService.updateNegocio(widget.negocio.id!, negocioActualizado);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Negocio actualizado correctamente")),
        );
        Navigator.pop(context, actualizado);
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
    String? initialValue,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        initialValue: initialValue,
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
          'Editar Negocio',
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
            const Icon(Icons.store, size: 80, color: Color(0xFF9B1D42)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    icon: Icons.store,
                    label: "Nombre del Negocio",
                    initialValue: _name,
                    onSaved: (val) => _name = val!,
                  ),
                  _buildTextField(
                    icon: Icons.vpn_key,
                    label: "Token Negocio",
                    inputType: TextInputType.number,
                    initialValue: _tokenNegocio,
                    onSaved: (val) => _tokenNegocio = val!,
                  ),
                  _buildTextField(
                    icon: Icons.location_on,
                    label: "Dirección",
                    initialValue: _direccion,
                    onSaved: (val) => _direccion = val!,
                  ),
                  _buildTextField(
                    icon: Icons.location_city,
                    label: "Ciudad",
                    initialValue: _ciudad,
                    onSaved: (val) => _ciudad = val!,
                  ),
                  _buildTextField(
                    icon: Icons.markunread_mailbox,
                    label: "Código Postal",
                    inputType: TextInputType.number,
                    initialValue: _codigoPostal,
                    onSaved: (val) => _codigoPostal = val!,
                  ),
                  _buildTextField(
                    icon: Icons.flag,
                    label: "País",
                    initialValue: _pais,
                    onSaved: (val) => _pais = val!,
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
                            onPressed: _guardar,
                            icon: const Icon(Icons.save),
                            label: const Text(
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
