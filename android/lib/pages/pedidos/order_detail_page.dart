import 'dart:convert';

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
    _order = Map.from(widget.order);
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
      _order[key] = newValue;
    });
    if (widget.onOrderChanged != null) {
      widget.onOrderChanged!(_order);
    }
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

      print("📦 Enviando nuevo pedido al backend:");
      print(jsonEncode(nuevoPedido.toJson()));

      Pedido creado = await PedidoService().createPedidoConDto(nuevoPedido);
      setState(() {
        _pedidoActualId = creado.id!;
        _pedidos.insert(0, creado);
        _order.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nuevo pedido creado.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear nuevo pedido: $e")),
      );
    }
  }

  Future<void> finalizeOrder() async {
    try {
      double precioTotal = 0;
      List<LineaDePedido> nuevasLineas = [];

      // Generar líneas de pedido y calcular precio total antes
      _order.forEach((nombreProducto, cantidad) {
        final producto = widget.products[nombreProducto];
        if (producto != null) {
          double precioUnitario = producto.precioVenta;
          precioTotal += precioUnitario * cantidad;
          nuevasLineas.add(
            LineaDePedido(
              cantidad: cantidad,
              precioUnitario: precioUnitario,
              salioDeCocina: false,
              pedidoId: 0, // Lo actualizamos tras crear el pedido
              productoId: producto.id,
            ),
          );
        }
      });

      if (nuevasLineas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay productos en la orden.")),
        );
        return;
      }

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

      // Crear el pedido ya con el total correcto
      Pedido nuevoPedido = Pedido(
        fecha: fechaIso,
        precioTotal: precioTotal,
        mesaId: widget.mesaId,
        negocioId: negocioId,
        empleadoId: SessionManager.empleadoId!,
      );

      Pedido creado = await PedidoService().createPedidoConDto(nuevoPedido);
      _pedidoActualId = creado.id!;
      _pedidos.insert(0, creado);

      // Crear líneas con el ID real del pedido
      for (var linea in nuevasLineas) {
        linea.pedidoId = _pedidoActualId!;
        await LineaDePedidoService().createLineaDePedido(linea);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pedido creado. Total: \$${precioTotal.toStringAsFixed(2)}",
          ),
        ),
      );

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

  Widget _buildCompletedOrderBox(Pedido pedido, int index) {
    final isActual = pedido.id == _pedidoActualId;
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
        color: isActual ? Colors.amber[100] : null,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          title: Text("Pedido ${index + 1}" + (isActual ? " (actual)" : "")),
          subtitle: Text(
            "Fecha: ${pedido.fecha}\nTotal: \$${pedido.precioTotal.toStringAsFixed(2)}",
          ),
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
          ElevatedButton.icon(
            onPressed: crearNuevoPedido,
            icon: const Icon(Icons.add),
            label: const Text("Nuevo pedido"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B1D42),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._order.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: finalizeOrder,
              child: const Text(
                "Finalizar Orden",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
          Column(
            children: List.generate(
              _pedidos.length,
              (index) => _buildCompletedOrderBox(_pedidos[index], index),
            ),
          ),
        ],
      ),
    );
  }
  
}
