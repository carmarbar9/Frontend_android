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
  Map<String, int> _order = {};
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    loadCategoriesAndProducts();
  }

  Future<void> loadCategoriesAndProducts() async {
    try {
      final String? negocioIdStr = SessionManager.negocioId;
      if (negocioIdStr == null) {
        throw Exception('No se encontró el negocioId en la sesión.');
      }

      List<Categoria> categorias =
          await CategoryApiService.getCategoriesByNegocioIdVenta(negocioIdStr);

      List<Map<String, dynamic>> loadedCategories = [];
      for (var cat in categorias) {
        final productoVentaService = ProductoVentaService();
        List<ProductoVenta> productos = await productoVentaService
            .getProductosByCategoriaNombre(cat.name);
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

  Map<String, ProductoVenta> _getProductMap() {
    Map<String, ProductoVenta> productMap = {};
    for (var cat in _categories) {
      for (ProductoVenta producto in cat['products']) {
        productMap[producto.name] = producto;
      }
    }
    return productMap;
  }

  Future<void> finalizeOrder() async {
    try {
      double precioTotal = 0;
      List<LineaDePedido> lineas = [];

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
              salioDeCocina: false,
              pedidoId: 0,
              productoId: productoEncontrado.id,
            ),
          );
        }
      });

      if (lineas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay productos en la orden.")),
        );
        return;
      }

      final String fechaIso = DateTime.now().toIso8601String();
      final int negocioId = int.parse(SessionManager.negocioId!);
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

      Pedido pedidoCreado = await PedidoService().createPedido(pedido);

      for (var linea in lineas) {
        linea.pedidoId = pedidoCreado.id!;
        await LineaDePedidoService().createLineaDePedido(linea);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pedido finalizado. Total: €${precioTotal.toStringAsFixed(2)}",
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
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mesa.name ?? "Mesa"),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B133C), Color(0xFF9B1D42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: const TabBar(
            unselectedLabelColor: Colors.white70,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [Tab(text: "Carta")],
          ),
        ),
        body: TabBarView(children: [_buildPedidosTab()]),
      ),
    );
  }

  Widget _buildPedidosTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text('Error: $_error'));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B133C), Color(0xFF9B1D42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9B1D42),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => OrderDetailPage(
                        order: _order,
                        products: _getProductMap(),
                        mesaId: widget.mesa.id!,
                      ),
                ),
              );

              // Fuerza redibujar los productos para reflejar las cantidades actualizadas
              setState(() {});
            },
            icon: const Icon(Icons.receipt_long, color: Color(0xFF9B1D42)),
            label: const Text("Comanda"),
          ),
          const SizedBox(height: 20),
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
                  height: 160,
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
    return GestureDetector(
      onTap: () {
        setState(() {
          int current = _order[product] ?? 0;
          _order[product] = current + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$product añadido. ¿Deshacer?"),
            duration: const Duration(milliseconds: 600),
            backgroundColor: const Color(0xFF9B1D42),
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
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                product,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B1D42),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
            if (quantity > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'x$quantity',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
