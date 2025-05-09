import 'package:android/models/categoria.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_proveedores.dart';
import 'package:flutter/material.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_categoria.dart';
import 'package:android/pages/inventario/itemsDetails_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_lote.dart';

class CategoryItemsPage extends StatefulWidget {
  final int categoryId; // Recibe un entero en lugar de un String

  const CategoryItemsPage({
    super.key,
    required this.categoryId,
  }); // Cambiar para recibir categoryId

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  Future<List<ProductoInventario>>? _futureProducts;
  List<ProductoInventario> _allProducts = [];
  int? _categoryId;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    print("Iniciando carga de productos...");

    // Asignamos el categoryId recibido al _categoryId
    _categoryId = widget.categoryId; // Usa el categoryId recibido

    // Llamar al servicio para obtener productos por categoriaId
    final productos =
        await InventoryApiService.getProductosInventarioByCategoriaId(
          _categoryId!,
        );

    print(
      'Productos obtenidos: $productos',
    ); // Verifica los productos obtenidos

    setState(() {
      _allProducts = productos; // Asignamos los productos obtenidos
      _applyFilter(); // Mostrar filtrados
    });
  }

  void _applyFilter() {
    List<ProductoInventario> filtrados;

    if (_searchQuery == null || _searchQuery!.isEmpty) {
      filtrados = _allProducts;
    } else {
      filtrados =
          _allProducts.where((p) {
            return p.name.toLowerCase().contains(_searchQuery!.toLowerCase());
          }).toList();
    }

    setState(() {
      _futureProducts = Future.value(filtrados);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _applyFilter();
    });
  }

  void _showSearchDialog() async {
    final searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Buscar Producto",
            style: TextStyle(
              color: Color(0xFF9B1D42),
              fontWeight: FontWeight.bold,
              fontFamily: 'TitanOne',
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Nombre exacto o parcial",
              hintStyle: TextStyle(
                color: const Color(0xFF9B1D42).withOpacity(0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF9B1D42)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF9B1D42),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(color: Color(0xFF9B1D42)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFF9B1D42)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Buscar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    final query = searchController.text.trim();
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  void _showAddProductDialog() async {
    final nameController = TextEditingController();
    final precioController = TextEditingController();
    final cantidadDeseadaController = TextEditingController();
    final cantidadAvisoController = TextEditingController();

    final negocioId = int.parse(SessionManager.negocioId!);

    List<Proveedor> proveedores = await ApiService.getProveedoresByNegocio(
      negocioId,
    );
    Proveedor? selectedProveedor;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Añadir Producto"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  TextField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Precio compra",
                    ),
                  ),
                  TextField(
                    controller: cantidadDeseadaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Cantidad deseada",
                    ),
                  ),
                  TextField(
                    controller: cantidadAvisoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Cantidad aviso",
                    ),
                  ),
                  DropdownButtonFormField<Proveedor>(
                    decoration: const InputDecoration(labelText: "Proveedor"),
                    items:
                        proveedores.map((proveedor) {
                          return DropdownMenuItem(
                            value: proveedor,
                            child: Text(proveedor.name!),
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
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final precio = double.tryParse(precioController.text.trim());
                  final deseada = int.tryParse(
                    cantidadDeseadaController.text.trim(),
                  );
                  final aviso = int.tryParse(
                    cantidadAvisoController.text.trim(),
                  );

                  if (name.isEmpty ||
                      precio == null ||
                      deseada == null ||
                      aviso == null ||
                      _categoryId == null ||
                      selectedProveedor == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Completa todos los campos correctamente.",
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await InventoryApiService.createProductoInventario({
                      "name": name,
                      "precioCompra": precio,
                      "cantidadDeseada": deseada,
                      "cantidadAviso": aviso,
                      "categoriaId": widget.categoryId,
                      "proveedorId": selectedProveedor!.id,
                    });

                    Navigator.pop(context);
                    _initData();
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al crear producto: $e')),
                    );
                  }

                  Navigator.pop(context);
                  _initData();
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
    );
  }

  Widget _build3DActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 3)),
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
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF9B1D42), width: 2),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 30, color: const Color(0xFF9B1D42)),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'TitanOne',
            color: Color(0xFF9B1D42),
          ),
        ),
      ),
    );
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
                  onTap: () {
                    Navigator.pop(context);
                  },
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
                              builder: (_) => NotificacionPage(),
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

          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'INVENTARIO',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),

          // Botón Buscar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: _build3DActionButton(
                icon: Icons.search,
                label: "Buscar",
                onPressed: _showSearchDialog,
              ),
            ),
          ),

          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Chip(
                backgroundColor: const Color(0xFF9B1D42).withOpacity(0.2),
                label: Text(
                  "Búsqueda: $_searchQuery",
                  style: const TextStyle(
                    color: Color(0xFF9B1D42),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                deleteIcon: const Icon(Icons.close, color: Color(0xFF9B1D42)),
                onDeleted: _clearSearch,
              ),
            ),

          // Productos
          Expanded(
            child: FutureBuilder<List<ProductoInventario>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final productos = snapshot.data!;
                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        child: Container(
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
                          child: ListTile(
                            leading: const Icon(
                              Icons.inventory_2,
                              color: Color(0xFF9B1D42),
                              size: 32,
                            ),
                            title: Text(
                              producto.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'TitanOne',
                                fontSize: 24,
                                color: Color(0xFF9B1D42),
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ItemDetailsPage(
                                        itemName: producto.name,
                                        category: widget.categoryId.toString(),
                                      ),
                                ),
                              );
                              _initData(); // 👈 Esto recarga los productos al volver
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No hay productos en esta categoría",
                      style: TextStyle(color: Color(0xFF9B1D42)),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          // Botón "Añadir producto"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: SizedBox(
              width: double.infinity,
              child: _build3DActionButton(
                icon: Icons.add,
                label: "Añadir producto",
                onPressed: _showAddProductDialog,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
