import 'package:flutter/material.dart';
import 'package:android/models/reabastecimiento.dart';
import 'package:android/models/lineaCarrito.dart';
import 'package:android/services/service_lineaCarrito.dart';

class DetalleReabastecimientoPage extends StatefulWidget {
  final Reabastecimiento reabastecimiento;

  const DetalleReabastecimientoPage({super.key, required this.reabastecimiento});

  @override
  State<DetalleReabastecimientoPage> createState() => _DetalleReabastecimientoPageState();
}

class _DetalleReabastecimientoPageState extends State<DetalleReabastecimientoPage> {
  late Future<List<LineaDeCarrito>> _futureLineas;

  @override
  void initState() {
    super.initState();
    _futureLineas = ApiLineaCarritoService.getLineasByCarrito(widget.reabastecimiento.id!);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reabastecimiento;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Reabastecimiento"),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo("Referencia", r.referencia),
            _buildInfo("Fecha", _formatFecha(r.fecha)),
            _buildInfo("Precio total", "${r.precioTotal.toStringAsFixed(2)} €"),
            const SizedBox(height: 20),
            const Text("Productos incluidos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<LineaDeCarrito>>(
                future: _futureLineas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Este reabastecimiento no tiene productos.");
                  } else {
                    final lineas = snapshot.data!;
                    return ListView.builder(
                      itemCount: lineas.length,
                      itemBuilder: (context, index) {
                        final linea = lineas[index];
                        return Card(
                          child: ListTile(
                            title: Text(linea.producto.name),
                            subtitle: Text("Cantidad: ${linea.cantidad} • Precio Total: ${linea.precioLinea.toStringAsFixed(2)} €"),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }
}
