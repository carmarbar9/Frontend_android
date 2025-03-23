import 'package:flutter/material.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/services/service_proveedores.dart';

class ProviderFormPage extends StatefulWidget {
  final Proveedor? proveedor; // Si es nulo, es modo "añadir". Si no, modo "editar".

  const ProviderFormPage({Key? key, this.proveedor}) : super(key: key);

  @override
  State<ProviderFormPage> createState() => _ProviderFormPageState();
}

class _ProviderFormPageState extends State<ProviderFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController telefonoController;
  late TextEditingController direccionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.proveedor?.name ?? '');
    emailController = TextEditingController(text: widget.proveedor?.email ?? '');
    telefonoController = TextEditingController(text: widget.proveedor?.telefono ?? '');
    direccionController = TextEditingController(text: widget.proveedor?.direccion ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final Proveedor proveedorData = Proveedor(
        id: widget.proveedor?.id,
        name: nameController.text,
        email: emailController.text,
        telefono: telefonoController.text,
        direccion: direccionController.text,
      );
      try {
        if (widget.proveedor == null) {
          await ApiService.createProveedor(proveedorData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Proveedor añadido exitosamente")),
          );
        } else {
          await ApiService.updateProveedor(proveedorData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Proveedor actualizado exitosamente")),
          );
        }
        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar proveedor: $error")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'TitanOne',
        fontWeight: FontWeight.bold,
        color: Color(0xFF9B1D42),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF9B1D42)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF9B1D42), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFB12A50), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.proveedor != null;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text(
          isEditing ? "EDITAR PROVEEDOR" : "AÑADIR PROVEEDOR",
          style: const TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 28,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Ícono local_shipping más grande
            Icon(
              Icons.local_shipping,
              size: 120,
              color: const Color(0xFF9B1D42),
            ),
            const SizedBox(height: 20),
            // Formulario
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration("Nombre", Icons.person),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Ingresa el nombre" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      decoration: _inputDecoration("Email", Icons.email),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Ingresa el email" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: telefonoController,
                      decoration: _inputDecoration("Teléfono", Icons.phone),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Ingresa el teléfono" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: direccionController,
                      decoration: _inputDecoration("Dirección", Icons.location_on),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Ingresa la dirección" : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF9B1D42),
                                Color(0xFFB12A50),
                                Color(0xFFD33E66),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: const BoxConstraints(minHeight: 50),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    isEditing ? "Actualizar" : "Guardar",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'TitanOne',
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
