import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  int? _pedidoActualId;
  List<Pedido> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _cargarPedidosYSetearActual();
  }

  Future<void> _cargarPedidosYSetearActual() async {
    final pedidos = await PedidoService().getPedidosByMesaId(widget.mesaId);
    if (pedidos.isNotEmpty) {
      setState(() {
        _pedidos = pedidos.reversed.toList();
        _pedidoActualId = _pedidos.first.id;
      });
    }
  }

void _updateOrder(String key, int newValue) {
  setState(() {
    if (newValue <= 0) {
      _order.remove(key); 
    } else {
      _order[key] = newValue;
    }
  });
}


  Future<void> crearNuevoPedido() async {
    try {
      final String fechaIso = DateTime.now().toUtc().toIso8601String();
      final int negocioId = int.parse(SessionManager.negocioId!);
      final int userId = int.parse(SessionManager.userId!);
      Empleado? empleado = await EmpleadoService.fetchEmpleadoByUserId(
        userId,
        SessionManager.token!,
      );

      if (empleado == null) throw Exception("Empleado no encontrado.");

      double precioTotal = 0;
      _order.forEach((nombreProducto, cantidad) {
        final producto = widget.products[nombreProducto];
        if (producto != null) {
          precioTotal += producto.precioVenta * cantidad;
        }
      });

      Pedido nuevoPedido = Pedido(
        fecha: fechaIso,
        precioTotal: precioTotal,
        mesaId: widget.mesaId,
        negocioId: negocioId,
        empleadoId: SessionManager.empleadoId!,
      );

      Pedido creado = await PedidoService().createPedidoConDto(nuevoPedido);
      setState(() {
        _pedidoActualId = creado.id!;
        _pedidos.insert(0, creado);
        _order.clear();
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nuevo pedido creado.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al crear nuevo pedido: $e")));
    }
  }

Future<void> finalizeOrder() async {
  try {
    // Si no hay pedido, lo creamos y seguimos
    if (_pedidoActualId == null) {
      final String fechaIso = DateTime.now().toUtc().toIso8601String();
      final int negocioId = int.parse(SessionManager.negocioId!);
      final int userId = int.parse(SessionManager.userId!);
      Empleado? empleado = await EmpleadoService.fetchEmpleadoByUserId(
        userId,
        SessionManager.token!,
      );

      if (empleado == null) {
        throw Exception("Empleado no encontrado.");
      }

      double precioTotal = 0;
      _order.forEach((nombreProducto, cantidad) {
        final producto = widget.products[nombreProducto];
        if (producto != null) {
          precioTotal += producto.precioVenta * cantidad;
        }
      });

      Pedido nuevoPedido = Pedido(
        fecha: fechaIso,
        precioTotal: precioTotal,
        mesaId: widget.mesaId,
        negocioId: negocioId,
        empleadoId: SessionManager.empleadoId!,
      );

      Pedido creado = await PedidoService().createPedidoConDto(nuevoPedido);

      setState(() {
        _pedidoActualId = creado.id!;
        _pedidos.insert(0, creado);
      });
    }

    if (_pedidoActualId == null || _order.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay productos en la orden.")),
      );
      return;
    }

    double precioTotal = 0;
    List<LineaDePedido> nuevasLineas = [];

    _order.forEach((nombreProducto, cantidad) {
      final producto = widget.products[nombreProducto];
      if (producto != null) {
        double precioUnitario = producto.precioVenta;
        precioTotal += precioUnitario * cantidad;
        nuevasLineas.add(LineaDePedido(
          cantidad: cantidad,
          precioUnitario: precioUnitario,
          salioDeCocina: false,
          pedidoId: _pedidoActualId!,
          productoId: producto.id,
        ));
      }
    });

    for (var linea in nuevasLineas) {
      await LineaDePedidoService().createLineaDePedido(linea);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Orden añadida al pedido actual. Total: \$${precioTotal.toStringAsFixed(2)}"),
      ),
    );

    setState(() => _order.clear());
Navigator.pop(context);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al finalizar la orden: $e")),
    );
  }
}


  String _formatFecha(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      final dias = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"];
      final meses = [
        "enero",
        "febrero",
        "marzo",
        "abril",
        "mayo",
        "junio",
        "julio",
        "agosto",
        "septiembre",
        "octubre",
        "noviembre",
        "diciembre"
      ];
      return "${dias[dateTime.weekday - 1].capitalize()}, ${dateTime.day} de ${meses[dateTime.month - 1]} de ${dateTime.year} – ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildCompletedOrderBox(Pedido pedido, int index) {
    final isActual = pedido.id == _pedidoActualId;
    return Card(
      color: isActual ? Colors.amber[100] : null,
      child: ListTile(
        title: Text("Pedido ${index + 1}" + (isActual ? " (actual)" : "")),
        subtitle: Text(
            "Fecha: ${_formatFecha(pedido.fecha)}"),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderInfoPage(pedido: pedido)),
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
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add),
            tooltip: "Nuevo pedido",
            onPressed: crearNuevoPedido,
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Productos en la orden:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._order.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (entry.value > 0) _updateOrder(entry.key, entry.value - 1);
                          },
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                        Text('${entry.value}', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          onPressed: () => _updateOrder(entry.key, entry.value + 1),
                          icon: const Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: finalizeOrder,
            icon: const Icon(Icons.check_circle, color: Colors.white,),
            

            label: const Text("Finalizar Orden"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B1D42),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const Text("Pedidos realizados:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._pedidos.asMap().entries.map((entry) => _buildCompletedOrderBox(entry.value, entry.key)).toList(),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
