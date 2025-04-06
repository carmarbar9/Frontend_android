import 'package:flutter/material.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/models/pedido.dart';
import 'package:android/models/linea_de_pedido.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_pedido.dart';
import 'package:android/services/service_lineaPedido.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, int> order;
  // Mapa de productos disponibles, con nombre como clave y el objeto ProductoVenta como valor.
  final Map<String, ProductoVenta> products;
  // Id de la mesa para asociarlo al pedido.
  final int mesaId;
  final Function(Map<String, int>)? onOrderChanged; // Callback opcional

  const OrderDetailPage({
    Key? key,
    required this.order,
    required this.products,
    required this.mesaId,
    this.onOrderChanged,
  }) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Map<String, int> _order;

  @override
  void initState() {
    super.initState();
    // Clonamos la orden para editarla localmente.
    _order = Map.from(widget.order);
  }

  // Función auxiliar para actualizar la orden y notificar el cambio.
  void _updateOrder(String key, int newValue) {
    setState(() {
      _order[key] = newValue;
    });
    if (widget.onOrderChanged != null) {
      widget.onOrderChanged!(_order);
    }
  }

  /// Finaliza la orden:
  /// 1. Recorre cada entrada en _order, utilizando widget.products para obtener el objeto ProductoVenta.
  /// 2. Calcula el precio total y crea las líneas de pedido.
  /// 3. Crea el objeto Pedido utilizando el id de la mesa, empleado (desde SessionManager.userId) y negocio (SessionManager.negocioId).
  /// 4. Asocia cada línea al pedido creado y las envía al backend.
  Future<void> finalizeOrder() async {
    try {
      double precioTotal = 0;
      List<LineaDePedido> lineas = [];

      // Recorre cada producto en la orden.
      _order.forEach((nombreProducto, cantidad) {
        final producto = widget.products[nombreProducto];
        if (producto != null) {
          double precioUnitario = producto.precioVenta;
          precioTotal += precioUnitario * cantidad;
          lineas.add(LineaDePedido(
            cantidad: cantidad,
            precioLinea: precioUnitario * cantidad,
            pedidoId: 0, // Se actualizará tras crear el Pedido.
            productoId: producto.id,
          ));
        }
      });

      final String fechaIso = DateTime.now().toIso8601String();
      final int negocioId = int.parse(SessionManager.negocioId!);
      final int empleadoId = 2; // poner el id del empleado logueado.

      Pedido pedido = Pedido(
        fecha: fechaIso,
        precioTotal: precioTotal,
        mesaId: widget.mesaId,
        empleadoId: empleadoId,
        negocioId: negocioId,
      );

      // Crea el pedido en el backend.
      Pedido pedidoCreado = await PedidoService().createPedido(pedido);

      // Asocia el id del pedido a cada línea y créalas en el backend.
      for (var linea in lineas) {
        linea.pedidoId = pedidoCreado.id!;
        await LineaDePedidoService().createLineaDePedido(linea);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pedido finalizado correctamente. Total: \$${precioTotal.toStringAsFixed(2)}"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al finalizar el pedido: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Comanda"),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Por cada entrada de la orden, se crea una Card bonita.
          ..._order.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (entry.value > 0) {
                              _updateOrder(entry.key, entry.value - 1);
                            }
                          },
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        IconButton(
                          onPressed: () {
                            _updateOrder(entry.key, entry.value + 1);
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          // Botón para finalizar la orden y crear el pedido.
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: finalizeOrder,
              child: const Text(
                "Finalizar Orden",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
