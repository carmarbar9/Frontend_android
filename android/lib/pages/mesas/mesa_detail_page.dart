import 'package:flutter/material.dart';
import 'package:android/models/mesa.dart';
import 'package:android/models/categoria.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/models/pedido.dart';
import 'package:android/models/linea_de_pedido.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/pages/pedidos/order_detail_page.dart';
import 'package:android/services/service_categoria.dart';
import 'package:android/services/service_carta.dart';
import 'package:android/services/service_pedido.dart';
import 'package:android/services/service_lineaPedido.dart';
import 'package:android/services/service_empleados.dart';

class MesaDetailPage extends StatefulWidget {
  final Mesa mesa;
  const MesaDetailPage({Key? key, required this.mesa}) : super(key: key);

  @override
  _MesaDetailPageState createState() => _MesaDetailPageState();
}

class _MesaDetailPageState extends State<MesaDetailPage> {
  // La orden actual: clave = nombre del producto, valor = cantidad.
  Map<String, int> _order = {};

  // Categorías obtenidas (cada Map contiene 'category' y 'products').
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    loadCategoriesAndProducts();
  }

  /// Carga las categorías de tipo VENTA y sus productos asociados.
  Future<void> loadCategoriesAndProducts() async {
    try {
      final String? negocioIdStr = SessionManager.negocioId;
      if (negocioIdStr == null) {
        throw Exception('No se encontró el negocioId en la sesión.');
      }
      // Obtén las categorías de tipo VENTA.
      List<Categoria> categorias =
          await CategoryApiService.getCategoriesByNegocioIdVenta(negocioIdStr);

      List<Map<String, dynamic>> loadedCategories = [];
      for (var cat in categorias) {
        final productoVentaService = ProductoVentaService();
        List<ProductoVenta> productos = await productoVentaService
            .getProductosByCategoriaNombre(cat.name);
        // Filtra por negocioId (se asume que cada producto tiene la propiedad categoria.negocioId).
        productos =
            productos
                .where((prod) => prod.categoria.negocioId == negocioIdStr)
                .toList();
        loadedCategories.add({'category': cat.name, 'products': productos});
      }
      setState(() {
        _categories = loadedCategories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Retorna un mapa con todos los productos, usando el nombre como clave.
  Map<String, ProductoVenta> _getProductMap() {
    Map<String, ProductoVenta> productMap = {};
    for (var cat in _categories) {
      for (ProductoVenta producto in cat['products']) {
        productMap[producto.name] = producto;
      }
    }
    return productMap;
  }

  /// Finaliza el pedido actual:
  /// 1. Recorre la orden (_order) para obtener cada producto y calcular el precio total,
  ///    creando las líneas de pedido correspondientes.
  /// 2. Obtiene el empleado real mediante EmpleadoService.
  /// 3. Crea el objeto Pedido usando la fecha actual, el id de la mesa, el id del empleado y el negocio.
  /// 4. Asocia cada línea al pedido creado y las envía al backend.
  Future<void> finalizeOrder() async {
    try {
      double precioTotal = 0;
      List<LineaDePedido> lineas = [];

      // Recorre cada entrada en la orden y busca el producto correspondiente.
      _order.forEach((nombreProducto, cantidad) {
        ProductoVenta? productoEncontrado;
        for (var cat in _categories) {
          List<ProductoVenta> productos = cat['products'];
          try {
            productoEncontrado = productos.firstWhere(
              (p) => p.name == nombreProducto,
            );
          } catch (_) {
            productoEncontrado = null;
          }
          if (productoEncontrado != null) break;
        }
        if (productoEncontrado != null) {
          double precioUnitario = productoEncontrado.precioVenta;
          precioTotal += precioUnitario * cantidad;
          lineas.add(
            LineaDePedido(
              cantidad: cantidad,
              precioUnitario: precioUnitario,
              salioDeCocina: false, // por defecto
              pedidoId: 0, // se setea luego
              productoId: productoEncontrado.id,
            ),
          );
        }
      });

      // Si no hay productos en la orden, muestra un mensaje amigable.
      if (lineas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay productos en la orden.")),
        );
        return;
      }

      final String fechaIso = DateTime.now().toIso8601String();
      final int negocioId = int.parse(SessionManager.negocioId!);

      // Obtén el empleado asociado usando su userId.
      final int userId = int.parse(SessionManager.userId!);
      final empleado = await EmpleadoService.fetchEmpleadoByUserId(
        userId,
        SessionManager.token!,
      );
      if (empleado == null) {
        throw Exception("Empleado no encontrado para el userId: $userId");
      }
      final int empleadoId = empleado.id!;

      Pedido pedido = Pedido(
        fecha: fechaIso,
        precioTotal: precioTotal,
        mesaId: widget.mesa.id!,
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
          content: Text(
            "Pedido finalizado correctamente. Total: \$${precioTotal.toStringAsFixed(2)}",
          ),
        ),
      );
      setState(() {
        _order.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al finalizar el pedido: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Pedidos, Acciones, Cuenta.
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mesa.name ?? "Mesa"),
          backgroundColor: const Color.fromARGB(255, 155, 29, 66),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            unselectedLabelColor: Colors.white70,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [Tab(text: "Pedidos")],
          ),
        ),
        body: TabBarView(children: [_buildPedidosTab()]),
      ),
    );
  }

  Widget _buildPedidosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text('Error: $_error'));
    }
    return Container(
      color: const Color(0xFF9B1D42),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9B1D42),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final updatedOrder = await Navigator.push<Map<String, int>>(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => OrderDetailPage(
                        order: Map<String, int>.from(
                          _order,
                        ), // <<< IMPORTANTE: clonar para evitar referencias
                        products: _getProductMap(),
                        mesaId: widget.mesa.id!,
                      ),
                ),
              );

              if (updatedOrder != null) {
                setState(() {
                  _order = updatedOrder;
                });
              }
            },
            icon: const Icon(Icons.receipt_long, color: Color.fromARGB(255, 155, 29, 66),),
            label: const Text("Comanda"),
          ),
          const SizedBox(height: 20),
          // Listado de categorías y productos.
          ..._categories.map((cat) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['category'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (cat['products'] as List).length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      ProductoVenta product = (cat['products'] as List)[index];
                      int quantity = _order[product.name] ?? 0;
                      return _buildProductCard(product.name, quantity);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductCard(String product, int quantity) {
    return InkWell(
      onTap: () {
        setState(() {
          int current = _order[product] ?? 0;
          _order[product] = current + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$product añadido. ¿Deseas deshacer?"),
            duration: const Duration(milliseconds: 500),
            action: SnackBarAction(
              label: "Deshacer",
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  int current = _order[product] ?? 0;
                  if (current > 0) {
                    _order[product] = current - 1;
                  }
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              product,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B1D42),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
