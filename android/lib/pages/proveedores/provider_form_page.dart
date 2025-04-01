import 'package:flutter/material.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/models/dia_reparto.dart';
import 'package:android/services/service_proveedores.dart';
import 'package:android/models/session_manager.dart';

class ProviderFormPage extends StatefulWidget {
  final Proveedor? proveedor;

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

  List<DiaReparto> _diasReparto = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.proveedor?.name ?? '');
    emailController = TextEditingController(
      text: widget.proveedor?.email ?? '',
    );
    telefonoController = TextEditingController(
      text: widget.proveedor?.telefono ?? '',
    );
    direccionController = TextEditingController(
      text: widget.proveedor?.direccion ?? '',
    );

    if (widget.proveedor != null) {
      ApiService.getDiasRepartoByProveedor(widget.proveedor!.id!).then((dias) {
        setState(() {
          _diasReparto = dias;
        });
      });
    }
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

      final proveedorData = Proveedor(
        id: widget.proveedor?.id,
        name: nameController.text,
        email: emailController.text,
        telefono: telefonoController.text,
        direccion: direccionController.text,
        negocioId: int.tryParse(SessionManager.negocioId ?? ''),
      );

      try {
        Proveedor proveedorFinal;
        if (widget.proveedor == null) {
          proveedorFinal = await ApiService.createProveedor(proveedorData);
        } else {
          proveedorFinal = await ApiService.updateProveedor(proveedorData);
        }

        for (var dia in _diasReparto) {
          final nuevoDia = DiaReparto(
            id: dia.id,
            diaSemana: dia.diaSemana,
            descripcion: dia.descripcion,
            proveedorId: proveedorFinal.id!,
          );

          if (dia.id == 0) {
            await ApiService.createDiaReparto(nuevoDia);
          } else {
            await ApiService.updateDiaReparto(dia.id, nuevoDia);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.proveedor == null
                  ? 'Proveedor creado'
                  : 'Proveedor actualizado',
            ),
          ),
        );

        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarDialogoDiaReparto({DiaReparto? diaExistente}) {
    String? diaSemana = diaExistente?.diaSemana;
    TextEditingController descController = TextEditingController(
      text: diaExistente?.descripcion ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            diaExistente == null
                ? "Añadir Día de Reparto"
                : "Editar Día de Reparto",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: diaSemana,
                decoration: const InputDecoration(
                  labelText: "Día de la semana",
                ),
                items:
                    [
                          'MONDAY',
                          'TUESDAY',
                          'WEDNESDAY',
                          'THURSDAY',
                          'FRIDAY',
                          'SATURDAY',
                          'SUNDAY',
                        ]
                        .map(
                          (dia) =>
                              DropdownMenuItem(value: dia, child: Text(dia)),
                        )
                        .toList(),
                onChanged: (value) {
                  diaSemana = value;
                },
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (diaSemana != null) {
                  setState(() {
                    if (diaExistente != null) {
                      diaExistente.diaSemana = diaSemana!;
                      diaExistente.descripcion = descController.text;
                    } else {
                      _diasReparto.add(
                        DiaReparto(
                          id: 0,
                          diaSemana: diaSemana!,
                          descripcion: descController.text,
                          proveedorId: widget.proveedor?.id,
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiaRepartoList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Días de Reparto",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'TitanOne',
            color: Color(0xFF9B1D42),
          ),
        ),
        const SizedBox(height: 12),
        ..._diasReparto.map(
          (dia) => Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Color(0xFF9B1D42),
              ),
              title: Text(
                dia.diaSemana,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B1D42),
                ),
              ),
              subtitle:
                  dia.descripcion != null
                      ? Text(
                        dia.descripcion!,
                        style: const TextStyle(color: Colors.black87),
                      )
                      : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF9B1D42)),
                    onPressed:
                        () => _mostrarDialogoDiaReparto(diaExistente: dia),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFF9B1D42)),
                    onPressed: () async {
                      setState(() {
                        _diasReparto.remove(dia);
                      });
                      if (dia.id != 0) {
                        await ApiService.deleteDiaReparto(dia.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child:
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoDiaReparto(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Añadir día de reparto",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TitanOne',
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (_) => Colors.transparent,
                  ),
                ),
              ).applyGradient(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF9B1D42)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.proveedor != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          isEditing ? "EDITAR PROVEEDOR" : "AÑADIR PROVEEDOR",
          style: const TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 28,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF9B1D42)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 40,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Ícono local_shipping más grande
            const Icon(
              Icons.local_shipping,
              size: 100,
              color: Color(0xFF9B1D42),
            ),
            const SizedBox(height: 20),

            // Contenedor del formulario con fondo blanco y sombra
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
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
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? "Campo obligatorio"
                                  : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      decoration: _inputDecoration("Email", Icons.email),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? "Campo obligatorio"
                                  : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: telefonoController,
                      decoration: _inputDecoration("Teléfono", Icons.phone),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? "Campo obligatorio"
                                  : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: direccionController,
                      decoration: _inputDecoration(
                        "Dirección",
                        Icons.location_on,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? "Campo obligatorio"
                                  : null,
                    ),
                    const SizedBox(height: 25),

                    _buildDiaRepartoList(),
                    const SizedBox(height: 25),

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
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      isEditing
                                          ? "Actualizar proveedor"
                                          : "Guardar proveedor",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'TitanOne',
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
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

// Extensión para aplicar gradiente bonito a botones
extension GradientButton on Widget {
  Widget applyGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: this,
    );
  }
}
