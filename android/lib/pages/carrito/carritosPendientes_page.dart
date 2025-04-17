import 'package:flutter/material.dart';
import 'package:android/models/carrito.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/services/service_carrito.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/pages/carrito/carritoDetails_page.dart';

class CarritosPendientesPage extends StatefulWidget {
  final Proveedor proveedor;

  const CarritosPendientesPage({super.key, required this.proveedor});

  @override
  State<CarritosPendientesPage> createState() => _CarritosPendientesPageState();
}

class _CarritosPendientesPageState extends State<CarritosPendientesPage> {
  late Future<List<Carrito>> _futureCarritos;

  @override
  void initState() {
    super.initState();
    _futureCarritos = ApiCarritoService.getCarritosByProveedor(widget.proveedor.id!);
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pendientes - ${widget.proveedor.name}'),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: FutureBuilder<List<Carrito>>(
        future: _futureCarritos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay carritos pendientes."));
          }

          final carritos = snapshot.data!
              .where((c) => !c.diaEntrega.isBefore(hoy))
              .toList();

          if (carritos.isEmpty) {
            return const Center(child: Text("No hay carritos pendientes."));
          }

          return ListView.builder(
            itemCount: carritos.length,
            itemBuilder: (context, index) {
              final carrito = carritos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text("Entrega: ${NotificacionService().formatearFecha(carrito.diaEntrega)}"),
                  subtitle: Text("Total: €${carrito.precioTotal.toStringAsFixed(2)}"),
                  leading: const Icon(Icons.inventory, color: Color(0xFF9B1D42)),

                   onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarritoDetallePage(carrito: carrito),
                ),
                    );
                  },
                ),
              );
            },
          );
            
        },
      ),
    );
  }
}
