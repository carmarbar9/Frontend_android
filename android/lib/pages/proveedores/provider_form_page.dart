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
    // Si se está editando, se cargan los valores existentes
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
        id: widget.proveedor?.id, // Si es edición, se mantiene el id
        name: nameController.text,
        email: emailController.text,
        telefono: telefonoController.text,
        direccion: direccionController.text,
      );
      try {
        if (widget.proveedor == null) {
          // Modo añadir
          await ApiService.createProveedor(proveedorData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Proveedor añadido exitosamente")),
          );
        } else {
          // Modo editar
          await ApiService.updateProveedor(proveedorData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Proveedor actualizado exitosamente")),
          );
        }
        Navigator.pop(context, true); // Regresa true para indicar cambio
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

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.proveedor != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Proveedor" : "Añadir Proveedor"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingresa el nombre" : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingresa el email" : null,
                ),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingresa el teléfono" : null,
                ),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(labelText: "Dirección"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingresa la dirección" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(isEditing ? "Actualizar" : "Guardar"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
