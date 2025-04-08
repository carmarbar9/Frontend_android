import 'package:flutter/material.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/models/pedido.dart';
import 'package:android/models/linea_de_pedido.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_pedido.dart';
import 'package:android/services/service_lineaPedido.dart';
import 'package:android/services/service_empleados.dart';
import 'order_info_page.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, int> order;
  final Map<String, ProductoVenta> products;
  final int mesaId;
  final Function(Map<String, int>)? onOrderChanged;

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
    _order = Map.from(widget.order);
  }

  void _updateOrder(String key, int newValue) {
    setState(() {
      _order[key] = newValue;
    });
    if (widget.onOrderChanged != null) {
      widget.onOrderChanged!(_order);
    }
  }

  Future<void> finalizeOrder() async {
    try {
      double precioTotal = 0;
      List<LineaDePedido> nuevasLineas = [];

      _order.forEach((nombreProducto, cantidad) {
        final producto = widget.products[nombreProducto];
        if (producto != null) {
          double precioUnitario = producto.precioVenta;
          precioTotal += precioUnitario * cantidad;
          nuevasLineas.add(LineaDePedido(
            cantidad: cantidad,
            precioLinea: precioUnitario * cantidad,
            pedidoId: 0,
            productoId: producto.id,
          ));
        }
      });

      if (nuevasLineas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay productos en la orden.")),
        );
        return;
      }

      final int userId = int.parse(SessionManager.userId!);
      final int negocioId = int.parse(SessionManager.negocioId!);
      Empleado? empleado = await EmpleadoService.fetchEmpleadoByUserId(userId);

      if (empleado == null) {
        throw Exception("Empleado no encontrado.");
      }

      final int empleadoId = empleado.id!;
      final pedidos = await PedidoService().getPedidosByMesaId(widget.mesaId);

      if (pedidos.isEmpty) {
        // Crear pedido nuevo
        final String fechaIso = DateTime.now().toIso8601String();

        Pedido nuevoPedido = Pedido(
          fecha: fechaIso,
          precioTotal: precioTotal,
          mesaId: widget.mesaId,
          empleadoId: empleadoId,
          negocioId: negocioId,
        );

        Pedido pedidoCreado = await PedidoService().createPedido(nuevoPedido);

        for (var linea in nuevasLineas) {
          linea.pedidoId = pedidoCreado.id!;
          await LineaDePedidoService().createLineaDePedido(linea);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pedido creado correctamente. Total: \$${precioTotal.toStringAsFixed(2)}"),
          ),
        );
      } else {
        // Actualizar pedido existente
        final pedidoExistente = pedidos.first;
        final int pedidoId = pedidoExistente.id!;
        final double nuevoTotal = pedidoExistente.precioTotal + precioTotal;

        for (var linea in nuevasLineas) {
          linea.pedidoId = pedidoId;
          await LineaDePedidoService().createLineaDePedido(linea);
        }

        Pedido pedidoActualizado = Pedido(
          id: pedidoId,
          fecha: pedidoExistente.fecha,
          mesaId: pedidoExistente.mesaId,
          empleadoId: pedidoExistente.empleadoId,
          negocioId: pedidoExistente.negocioId,
          precioTotal: nuevoTotal,
        );

        await PedidoService().updatePedido(pedidoId, pedidoActualizado);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pedido actualizado. Nuevo total: \$${nuevoTotal.toStringAsFixed(2)}"),
          ),
        );
      }

      setState(() {
        _order.clear();

      });
Navigator.pop(context, <String, int>{});

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al finalizar el pedido: $e")),
      );
    }
  }

  Future<List<Pedido>> _loadCompletedOrders() async {
    return await PedidoService().getPedidosByMesaId(widget.mesaId);
  }

  Widget _buildCompletedOrderBox(Pedido pedido, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderInfoPage(pedido: pedido),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          title: Text("Pedido ${index + 1}"),
          subtitle: Text("Fecha: ${pedido.fecha}\nTotal: \$${pedido.precioTotal.toStringAsFixed(2)}"),
        ),
      ),
    );
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
          const SizedBox(height: 30),
          const Divider(),
          const Text(
            "Pedidos realizados:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Pedido>>(
            future: _loadCompletedOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("No hay pedidos realizados.");
              } else {
                final pedidos = snapshot.data!;
                return Column(
                  children: List.generate(
                    pedidos.length,
                    (index) => _buildCompletedOrderBox(pedidos[index], index),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
