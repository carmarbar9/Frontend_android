import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:android/models/carrito.dart';
import 'package:android/models/lineaCarrito.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_lineaCarrito.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_carrito.dart';

class CarritoDetallePage extends StatefulWidget {
  final Carrito carrito;
  final VoidCallback? onPedidoConfirmado;

  const CarritoDetallePage({super.key, required this.carrito, this.onPedidoConfirmado});

  @override
  State<CarritoDetallePage> createState() => _CarritoDetallePageState();
}

class _CarritoDetallePageState extends State<CarritoDetallePage> {
  late Future<List<LineaDeCarrito>> _futureLineas;

  @override
  void initState() {
    super.initState();
    _futureLineas = ApiLineaCarritoService.getLineasByCarrito(widget.carrito.id!);
    imprimirPayloadDelToken();
  }

  void imprimirPayloadDelToken() {
    final token = SessionManager.token;

    if (token == null || token.isEmpty) {
      print("No hay token disponible");
      return;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print("El token no tiene un formato válido.");
        return;
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      print("Payload del token: $payload");
    } catch (e) {
      print("Error al decodificar el token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carrito del ${widget.carrito.diaEntrega.day}/${widget.carrito.diaEntrega.month}"),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: FutureBuilder<List<LineaDeCarrito>>(
        future: _futureLineas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error al cargar líneas del carrito: ${snapshot.error}");
            return const Center(child: Text("Error al cargar las líneas."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("No se encontraron líneas para el carrito con ID: ${widget.carrito.id}");
            return const Center(child: Text("Este carrito no tiene productos."));
          }

          final lineas = snapshot.data!;
          print("Líneas recibidas para carrito ${widget.carrito.id}:");
          for (var linea in lineas) {
            print("Producto: ${linea.producto.name}, Cantidad: ${linea.cantidad}");
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...lineas.map((linea) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(linea.producto.name),
                    subtitle: Text("Cantidad: ${linea.cantidad}"),
                    trailing: Text("€${linea.precioLinea.toStringAsFixed(2)}"),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Total: €${widget.carrito.precioTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9B1D42),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar recepción anticipada'),
                onPressed: () async {
                  final lineas = await ApiLineaCarritoService.getLineasByCarrito(widget.carrito.id!);

                  final Map<int, DateTime?> fechasPorProducto = {};

                  for (final linea in lineas) {
                    final fechaSeleccionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      helpText: 'Fecha de caducidad para ${linea.producto.name}',
                    );

                    if (fechaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cancelado: Faltan fechas')),
                      );
                      return;
                    }

                    fechasPorProducto[linea.producto.id] = fechaSeleccionada;
                  }

                  try {
                    for (final linea in lineas) {
                      final fecha = fechasPorProducto[linea.producto.id]!;
                      final nuevoLote = Lote(
                        id: 0,
                        cantidad: linea.cantidad,
                        fechaCaducidad: fecha,
                        productoId: linea.producto.id,
                        reabastecimientoId: 1,
                      );

                      await LoteProductoService.createLote(nuevoLote);
                      print("Lote creado para ${linea.producto.name} con caducidad: $fecha");
                    }

                    await ApiCarritoService.deleteCarrito(widget.carrito.id!);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recepción confirmada y lotes creados')),
                    );

                    if (widget.onPedidoConfirmado != null) {
                      widget.onPedidoConfirmado!();
                    }

                    Navigator.pop(context);
                  } catch (e) {
                    print("Error al confirmar recepción: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B1D42),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
