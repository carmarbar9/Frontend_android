import 'package:flutter/material.dart';
import 'package:android/models/reabastecimiento.dart';
import 'package:android/services/service_reabastecimiento.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/services/service_proveedores.dart';
import 'package:android/models/session_manager.dart';

class ReabastecimientosPage extends StatefulWidget {
  const ReabastecimientosPage({super.key});

  @override
  State<ReabastecimientosPage> createState() => _ReabastecimientosPageState();
}

class _ReabastecimientosPageState extends State<ReabastecimientosPage> {
  late Future<List<Reabastecimiento>> _futureReabastecimientos;

  @override
  void initState() {
    super.initState();
    _futureReabastecimientos = _cargarReabastecimientos();
  }

  Future<List<Reabastecimiento>> _cargarReabastecimientos() async {
    final negocioId = int.parse(SessionManager.negocioId!);
    final todos = await ReabastecimientoService.getByNegocio(negocioId);
    return todos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reabastecimientos"),
      backgroundColor: const Color(0xFF9B1D42),
      ),
      body: FutureBuilder<List<Reabastecimiento>>(
        future: _futureReabastecimientos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay reabastecimientos"));
          } else {
            final lista = snapshot.data!;
            return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final r = lista[index];
                return FutureBuilder<Proveedor?>(
                  future: ApiService.getProveedorById(r.proveedorId),
                  builder: (context, snapshotProveedor) {
                    final proveedorNombre = snapshotProveedor.data?.name ?? "Proveedor desconocido";
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text("Ref: ${r.referencia}"),
                        subtitle: Text(
                          "Proveedor: $proveedorNombre\nFecha: ${_formatFecha(r.fecha)}\nTotal: ${r.precioTotal.toStringAsFixed(2)} €",
                        ),
                        leading: const Icon(Icons.inventory_2),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }
}
