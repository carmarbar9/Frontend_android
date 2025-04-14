import 'package:android/models/proveedor.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_proveedores.dart';
import 'package:flutter/material.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/pages/inventario/lote_detail_page.dart';
import 'package:android/services/service_notificacion.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemName;
  final String category;

  const ItemDetailsPage({
    super.key,
    required this.itemName,
    required this.category,
  });

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  Future<ProductoInventario?>? _futureProduct;
  Future<List<Lote>>? _futureLotes; // 👈 AÑADE ESTO
  List<Lote> _lotes = [];
  int _currentLoteIndex = 0;
  List<Proveedor> _proveedores = [];
  Proveedor? _proveedorProducto;

  final Map<String, IconData> categoryIcons = {
    'Verduras': FontAwesomeIcons.carrot,
    'Carnes': LineIcons.drumstickWithBiteTakenOut,
    'Pescados': LineIcons.fish,
    'Especias': FontAwesomeIcons.mortarPestle,
    'Bebidas': LineIcons.beer,
    'Frutas': LineIcons.fruitApple,
    'Lácteos': LineIcons.cheese,
    'Otros': LineIcons.box,
  };

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    _futureProduct = InventoryApiService.getProductoInventarioByName(
      widget.itemName,
    );

    _futureProduct!.then((producto) async {
      if (producto != null) {
        final futureLotes = LoteProductoService.getLotesByProductoId(
          producto.id,
        );
        final proveedores = await ApiService.getProveedoresByNegocio(
          int.parse(SessionManager.negocioId!),
        );

        setState(() {
          _futureLotes = futureLotes;
          _proveedores = proveedores;
          _proveedorProducto = proveedores.firstWhere(
            (prov) => prov.id == producto.proveedorId,
            orElse:
                () => Proveedor(
                  id: producto.proveedorId,
                  name: 'Proveedor desconocido',
                ),
          );
        });

        futureLotes.then((data) {
          setState(() {
            _lotes = data;
            _currentLoteIndex = 0;
          });
        });
      }
    });
  }

  Widget _build3DButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3)),
          BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-3, -3)),
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF9B1D42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF9B1D42), width: 2),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: const Color(0xFF9B1D42)),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'TitanOne',
            color: Color(0xFF9B1D42),
          ),
        ),
      ),
    );
  }

  Widget _buildEliminarButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3)),
          BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-3, -3)),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF9B1D42), Color(0xFF7B1533)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF9B1D42), width: 2),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.delete, size: 24, color: Colors.white),
        label: const Text(
          "Eliminar",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'TitanOne',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _editProduct(ProductoInventario producto) async {
    final nameController = TextEditingController(text: producto.name);
    final precioController = TextEditingController(
      text: producto.precioCompra.toString(),
    );
    final deseadaController = TextEditingController(
      text: producto.cantidadDeseada.toString(),
    );
    final avisoController = TextEditingController(
      text: producto.cantidadAviso.toString(),
    );

    // Obtenemos proveedores del negocio
    List<Proveedor> proveedores = await ApiService.getProveedoresByNegocio(
      int.parse(SessionManager.negocioId!),
    );

    // Seleccionamos el proveedor actual
    Proveedor? selectedProveedor = proveedores.firstWhere(
      (prov) => prov.id == producto.proveedorId,
      orElse: () => proveedores.first,
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar producto'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Compra',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: deseadaController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Deseada',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: avisoController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Aviso',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<Proveedor>(
                    value: selectedProveedor,
                    decoration: const InputDecoration(labelText: "Proveedor"),
                    items:
                        proveedores.map((prov) {
                          return DropdownMenuItem(
                            value: prov,
                            child: Text(prov.name!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedProveedor = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updated = ProductoInventario(
                    id: producto.id,
                    name: nameController.text,
                    categoria: producto.categoria,
                    precioCompra:
                        double.tryParse(precioController.text) ??
                        producto.precioCompra,
                    cantidadDeseada:
                        int.tryParse(deseadaController.text) ??
                        producto.cantidadDeseada,
                    cantidadAviso:
                        int.tryParse(avisoController.text) ??
                        producto.cantidadAviso,
                    proveedorId: selectedProveedor!.id!, // Este es el nuevo
                  );

                  try {
                    await InventoryApiService.updateProductoInventario(updated);
                    Navigator.pop(context);

                    await Future.delayed(const Duration(milliseconds: 300));

                    _loadProduct();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Producto actualizado correctamente',
                        ),
                        backgroundColor: Colors.green[700],
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar producto'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este producto?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await InventoryApiService.deleteProductoInventario(id);

      // Cerrar diálogo y salir de la pantalla
      Navigator.pop(context); // cierra diálogo

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
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
                                  (_) => NotificacionPage(
                                    notificaciones: notificaciones,
                                  ),
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
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserProfilePage(),
                            ),
                          ),
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed:
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'DETALLE PRODUCTO',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontFamily: 'PermanentMarker',
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<ProductoInventario?>(
              future: _futureProduct,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Producto no encontrado'));
                }
                final producto = snapshot.data!;
                final icon =
                    categoryIcons[producto.categoria.name] ?? Icons.inventory_2;
                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      minWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(icon, size: 60, color: const Color(0xFF9B1D42)),
                          const SizedBox(height: 20),
                          Text(
                            producto.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Categoría: ${producto.categoria.name}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          Text(
                            'Precio compra: €${producto.precioCompra.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          Text(
                            'Cantidad deseada: ${producto.cantidadDeseada}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          Text(
                            'Cantidad aviso: ${producto.cantidadAviso}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          Text(
                            'Proveedor: ${_proveedorProducto?.name ?? "Proveedor desconocido"}',
                            style: const TextStyle(fontSize: 22),
                          ),

                          const SizedBox(height: 30),
                          const Text(
                            "Lotes",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<Lote>>(
                            future: _futureLotes,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  "Error al cargar lotes: ${snapshot.error}",
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  "No hay lotes registrados para este producto",
                                );
                              }

                              final lotes = snapshot.data!;
                              final cantidadTotal = producto.calcularCantidad(
                                lotes,
                              );

                              // Control de índice por fuera
                              final lote = lotes[_currentLoteIndex];

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Cantidad total: $cantidadTotal",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9B1D42),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => LoteDetailPage(lote: lote),
                                        ),
                                      );

                                      // Cuando vuelve, recarga los lotes y ajusta el índice
                                      final nuevosLotes =
                                          await LoteProductoService.getLotesByProductoId(
                                            producto.id,
                                          );
                                      setState(() {
                                        _lotes = nuevosLotes;
                                        _futureLotes = Future.value(
                                          nuevosLotes,
                                        );
                                        if (_currentLoteIndex >=
                                            nuevosLotes.length) {
                                          _currentLoteIndex =
                                              nuevosLotes.isEmpty
                                                  ? 0
                                                  : nuevosLotes.length - 1;
                                        }
                                      });
                                    },

                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Cantidad: ${lote.cantidad}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            "Caduca: ${lote.fechaCaducidad.toLocal().toString().split(' ')[0]}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_left,
                                          size: 30,
                                        ),
                                        onPressed:
                                            _currentLoteIndex > 0
                                                ? () => setState(() {
                                                  _currentLoteIndex--;
                                                })
                                                : null,
                                      ),
                                      Text(
                                        "Lote ${_currentLoteIndex + 1} de ${lotes.length}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_right,
                                          size: 30,
                                        ),
                                        onPressed:
                                            _currentLoteIndex < lotes.length - 1
                                                ? () => setState(() {
                                                  _currentLoteIndex++;
                                                })
                                                : null,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _build3DButton(
                                label: "Editar",
                                icon: Icons.edit,
                                onPressed: () => _editProduct(producto),
                              ),
                              const SizedBox(width: 16),
                              _buildEliminarButton(
                                label: "Eliminar",
                                icon: Icons.delete,
                                onPressed: () => _deleteProduct(producto.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
