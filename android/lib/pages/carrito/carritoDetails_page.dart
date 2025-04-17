import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:android/models/carrito.dart';
import 'package:android/models/lineaCarrito.dart';
import 'package:android/services/service_lineaCarrito.dart';
import 'package:android/models/session_manager.dart';

class CarritoDetallePage extends StatefulWidget {
  final Carrito carrito;

  const CarritoDetallePage({super.key, required this.carrito});

  @override
  State<CarritoDetallePage> createState() => _CarritoDetallePageState();
}

class _CarritoDetallePageState extends State<CarritoDetallePage> {
  late Future<List<LineaDeCarrito>> _futureLineas;

  @override
  void initState() {
    super.initState();
    _futureLineas = ApiLineaCarritoService.getLineasByCarrito(widget.carrito.id!);
    imprimirPayloadDelToken(); // 👈 Añadido aquí
  }

 void imprimirPayloadDelToken() {
  final token = SessionManager.token;

  if (token == null || token.isEmpty) {
    print("⚠️ No hay token disponible");
    return;
  }

  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      print("❌ El token no tiene un formato válido.");
      return;
    }

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    print("🧠 Payload del token: $payload");
  } catch (e) {
    print("❌ Error al decodificar el token: $e");
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
            print("❌ Error al cargar líneas del carrito: ${snapshot.error}");
            return const Center(child: Text("Error al cargar las líneas."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("⚠️ No se encontraron líneas para el carrito con ID: ${widget.carrito.id}");
            return const Center(child: Text("Este carrito no tiene productos."));
          }

          final lineas = snapshot.data!;
          print("✅ Líneas recibidas para carrito ${widget.carrito.id}:");
          for (var linea in lineas) {
            print("🧾 Producto: ${linea.producto.name}, Cantidad: ${linea.cantidad}");
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
              )
            ],
          );
        },
      ),
    );
  }
}
