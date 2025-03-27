import 'package:flutter/material.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_lote.dart';

class LoteDetailPage extends StatelessWidget {
  final Lote lote;

  const LoteDetailPage({super.key, required this.lote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        title: const Text(
          "DETALLE DEL LOTE",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontFamily: 'PermanentMarker',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.all_inbox, size: 80, color: Color(0xFF9B1D42)),
                const SizedBox(height: 20),
                Text(
                  "Cantidad: ${lote.cantidad}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9B1D42),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Caduca: ${lote.fechaCaducidad.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    // Botón Editar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(3, 3),
                          ),
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 4,
                            offset: Offset(-3, -3),
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFF5F5F5),
                            Color(0xFFE0E0E0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final cantidadController = TextEditingController(
                            text: lote.cantidad.toString(),
                          );
                          final fechaController = TextEditingController(
                            text:
                                lote.fechaCaducidad.toLocal().toString().split(
                                  ' ',
                                )[0],
                          );

                          final formKey = GlobalKey<FormState>();

                          await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Editar Lote'),
                                  content: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: cantidadController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: "Cantidad",
                                          ),
                                          validator:
                                              (value) =>
                                                  value == null || value.isEmpty
                                                      ? "Campo requerido"
                                                      : null,
                                        ),
                                        TextFormField(
                                          controller: fechaController,
                                          keyboardType: TextInputType.datetime,
                                          decoration: const InputDecoration(
                                            labelText:
                                                "Fecha de caducidad (YYYY-MM-DD)",
                                          ),
                                          validator:
                                              (value) =>
                                                  value == null || value.isEmpty
                                                      ? "Campo requerido"
                                                      : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          final updated = lote.copyWith(
                                            cantidad: int.parse(
                                              cantidadController.text,
                                            ),
                                            fechaCaducidad: DateTime.parse(
                                              fechaController.text,
                                            ),
                                          );

                                          await LoteProductoService.updateLote(
                                            updated,
                                          );
                                          Navigator.pop(context);
                                          Navigator.pop(
                                            context,
                                          ); // Vuelve atrás tras editar
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Lote actualizado"),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("Guardar"),
                                    ),
                                  ],
                                ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF9B1D42),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(0xFF9B1D42),
                              width: 2,
                            ),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.edit, color: Color(0xFF9B1D42)),
                        label: const Text(
                          "Editar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TitanOne',
                            color: Color(0xFF9B1D42),
                          ),
                        ),
                      ),
                    ),

                    // Botón Eliminar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(3, 3),
                          ),
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 4,
                            offset: Offset(-3, -3),
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9B1D42), Color(0xFF7B1533)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text("Eliminar Lote"),
                                  content: const Text(
                                    "¿Estás segura de que quieres eliminar este lote?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text("Eliminar"),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            await LoteProductoService.deleteLote(lote.id);
                            Navigator.pop(
                              context,
                            ); // Cierra la pantalla del detalle
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Lote eliminado")),
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(0xFF9B1D42),
                              width: 2,
                            ),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Eliminar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TitanOne',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
