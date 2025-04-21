import 'package:flutter/material.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/models/carritoManager.dart';
import 'package:android/services/service_carrito.dart';
import 'package:android/services/service_diaReparto.dart';
import 'package:android/services/service_lineaCarrito.dart';
import 'package:android/models/lineaCarrito.dart';
import 'package:android/models/carrito.dart';

class CarritoProveedorPage extends StatefulWidget {
  final Proveedor proveedor;

  const CarritoProveedorPage({super.key, required this.proveedor});

  @override
  State<CarritoProveedorPage> createState() => _CarritoProveedorPageState();
}

class _CarritoProveedorPageState extends State<CarritoProveedorPage> {
  List<ProductoInventario> _productos = [];
  Map<int, int> _cantidades = {}; // productoId -> cantidad seleccionada

  @override
  void initState() {
    super.initState();
    _cargarProductosDelProveedor();
  }

  void _cargarProductosDelProveedor() async {
    final todos = await InventoryApiService.getAllProductosInventario();
    final asociados = todos.where((p) => p.proveedorId == widget.proveedor.id).toList();

    setState(() {
      _productos = asociados;
      _cantidades = {
        for (var producto in asociados)
          producto.id: CarritoManager
              .getProductosDelCarrito(widget.proveedor.id!)
              .firstWhere(
                (p) => p.producto.id == producto.id,
                orElse: () => ProductoCarrito(producto: producto, cantidad: 0),
              )
              .cantidad,
      };
    });
  }

  DateTime calcularProximaEntrega(String diaSemana) {
    final dias = {
      'MONDAY': DateTime.monday,
      'TUESDAY': DateTime.tuesday,
      'WEDNESDAY': DateTime.wednesday,
      'THURSDAY': DateTime.thursday,
      'FRIDAY': DateTime.friday,
      'SATURDAY': DateTime.saturday,
      'SUNDAY': DateTime.sunday,
    };

    final hoy = DateTime.now();
    final target = dias[diaSemana.toUpperCase()]!;
    int diasFaltan = (target - hoy.weekday + 7) % 7;
    if (diasFaltan == 0) diasFaltan = 7;

    return hoy.add(Duration(days: diasFaltan));
  }

  void _hacerPedido() async {
    final productos = CarritoManager.getProductosDelCarrito(widget.proveedor.id!);

    print('📦 Productos en carrito: ${productos.length}');
    for (var p in productos) {
      print('📦 -> ${p.producto.name} x${p.cantidad}');
    }

    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en el carrito')),
      );
      return;
    }

    final precioTotal = productos.fold<double>(
      0.0,
      (total, p) => total + (p.producto.precioCompra * p.cantidad),
    );

    final diaReparto = await DiaRepartoService.getPrimerDiaRepartoDelProveedor(widget.proveedor.id!);
    if (diaReparto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el día de reparto')),
      );
      return;
    }

    final diaEntrega = calcularProximaEntrega(diaReparto);
    Carrito? nuevoCarrito;

    try {
      print('🛒 Creando carrito...');
      nuevoCarrito = await ApiCarritoService.crearCarrito(
        proveedorId: widget.proveedor.id!,
        precioTotal: precioTotal,
        diaEntrega: diaEntrega,
      );

      print('✅ Carrito creado con ID: ${nuevoCarrito.id}');

      for (var item in productos) {
        print('➡️ Creando línea de carrito para producto: ${item.producto.name}, cantidad: ${item.cantidad}');
        await ApiLineaCarritoService.crearLineaDeCarrito(
          carritoId: nuevoCarrito.id!,
          productoId: item.producto.id,
          cantidad: item.cantidad,
          precioLinea: item.producto.precioCompra * item.cantidad,
        );
      }

      CarritoManager.vaciarCarrito(widget.proveedor.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido creado para el $diaEntrega')),
      );

      Navigator.pop(context);
    } catch (e, stacktrace) {
      print('❌ Error al hacer pedido: $e');
      print(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al hacer pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito - ${widget.proveedor.name}'),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: _productos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._productos.map((producto) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cantidad:'),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: _cantidades[producto.id].toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onChanged: (value) {
                                    final parsed = int.tryParse(value) ?? 0;
                                    final clamped = parsed.clamp(0, 999);
                                    setState(() {
                                      _cantidades[producto.id] = clamped;
                                      CarritoManager.anadirProducto(
                                        proveedorId: widget.proveedor.id!,
                                        producto: producto,
                                        cantidad: clamped,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Hacer pedido'),
                  onPressed: _hacerPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B1D42),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
