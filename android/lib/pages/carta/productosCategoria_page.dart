import 'package:android/models/lote.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:flutter/material.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/services/service_carta.dart';
import 'package:android/pages/carta/editProductoVenta_page.dart';
import 'package:android/models/categoria.dart';
import 'package:android/models/session_manager.dart';

class ProductosPorCategoriaPage extends StatefulWidget {
  final Categoria categoria;

  const ProductosPorCategoriaPage({super.key, required this.categoria});

  @override
  State<ProductosPorCategoriaPage> createState() =>
      _ProductosPorCategoriaPageState();
}

class _ProductosPorCategoriaPageState extends State<ProductosPorCategoriaPage> {
  late Future<List<ProductoVenta>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _cargarProductosFiltrados();
  }

  void _cargarProductosFiltrados() {
    final categoriaId = widget.categoria.id;

    _futureProductos = ProductoVentaService()
        .getProductosByCategoriaNombre(widget.categoria.name)
        .then((productos) {
          return productos
              .where((p) => p.categoria.id.toString() == categoriaId.toString())
              .toList();
        });
  }

  void _refrescar() {
    setState(() {
      _cargarProductosFiltrados();
    });
  }

  void _borrarProducto(int id) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "¿Eliminar producto?",
          style: TextStyle(color: Color(0xFF9B1D42), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B1D42),
              foregroundColor: Colors.white,
            ),
            child: const Text("Eliminar"),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    try {
      await ProductoVentaService().deleteProductoVenta(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado con éxito')),
      );
      _refrescar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }
}


  void _editarProducto(ProductoVenta producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductoVentaPage(producto: producto),
      ),
    );

    if (result == true) {
      _refrescar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // CABECERA gourmet con navegación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset('assets/logo.png', height: 62),
                ),
                Row(
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        try {
                          List<ProductoInventario> productos =
                              await InventoryApiService.getProductosInventario();

                          Map<int, List<Lote>> lotesPorProducto = {};
                          for (var producto in productos) {
                            final lotes =
                                await LoteProductoService.getLotesByProductoId(
                                  producto.id,
                                );
                            lotesPorProducto[producto.id] = lotes;
                          }

                          final notificaciones = NotificacionService()
                              .generarNotificacionesInventario(
                                productos,
                                lotesPorProducto,
                              );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => NotificacionPage(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error cargando notificaciones: $e',
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserProfilePage(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              widget.categoria.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LISTA DE PLATOS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<ProductoVenta>>(
                future: _futureProductos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay productos en esta categoría",
                        style: TextStyle(
                          color: Color(0xFF9B1D42),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  final productos = snapshot.data!;
                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final p = productos[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF9B1D42),
                              Color(0xFFB12A50),
                              Color(0xFFD33E66),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          title: Text(
                            p.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              fontFamily: 'TitanOne',
                            ),
                          ),
                          subtitle: Text(
                            "${p.precioVenta.toStringAsFixed(2)} €",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () => _editarProducto(p),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                onPressed: () => _borrarProducto(p.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botón "Crear nuevo plato"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFF9B1D42),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFF9B1D42), width: 2),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final nuevoProducto = ProductoVenta(
                    id: 0,
                    name: '',
                    precioVenta: 0.0,
                    categoria: widget.categoria,
                  );

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditProductoVentaPage(
                            producto: nuevoProducto,
                            isCreating: true,
                          ),
                    ),
                  );

                  if (result == true) _refrescar();
                },
                icon: const Icon(Icons.add, size: 30, color: Color(0xFF9B1D42)),
                label: const Text(
                  'Crear nuevo plato',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TitanOne',
                    color: Color(0xFF9B1D42),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
