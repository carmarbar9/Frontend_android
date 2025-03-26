import 'package:android/models/producto_inventario.dart';
import 'package:android/models/categoria.dart';
import 'package:android/pages/inventario/itemsDetails_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_categoria.dart';
import 'package:flutter/material.dart';

class CategoryItemsPage extends StatefulWidget {
  final String categoryName;
  
  const CategoryItemsPage({super.key, required this.categoryName});

  @override
  _CategoryItemsPageState createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Future<List<ProductoInventario>>? _futureProducts;
  int? _categoryId; // Aquí guardamos el ID real de la categoría

  // Variable para búsqueda (opcional)
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    _loadProducts();
    _loadCategoryId();
  }

  void _loadProducts() {
    InventoryApiService.getProductosInventarioByCategoria(widget.categoryName)
        .then((productsList) {
      if (_searchQuery == null || _searchQuery!.isEmpty) {
        setState(() {
          _futureProducts = Future.value(productsList);
        });
      } else {
        final filtered = productsList.where((p) =>
            p.name.toLowerCase().contains(_searchQuery!.toLowerCase())).toList();
        setState(() {
          _futureProducts = Future.value(filtered);
        });
      }
    }).catchError((error) {
      setState(() {
        _futureProducts = Future.error(error);
      });
    });
  }

  void _loadCategoryId() async {
    try {
      // Suponemos que getCategoriesByName devuelve una lista de Categoria
      final catList = await CategoryApiService.getCategoriesByName(widget.categoryName);
      setState(() {
        // Convertimos el id a entero (ajusta según tu tipo)
        _categoryId = int.tryParse(catList[0].id);
      });
    } catch (e) {
      debugPrint("Error al obtener el ID de la categoría: $e");
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _loadProducts();
    });
  }

  void _showSearchDialog() async {
    String? query;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Buscar Producto",
            style: TextStyle(
                color: Color(0xFF9B1D42), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Nombre exacto o parcial",
              hintStyle:
                  TextStyle(color: const Color(0xFF9B1D42).withOpacity(0.6)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF9B1D42)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF9B1D42), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(
                color: Color(0xFF9B1D42), fontWeight: FontWeight.bold),
            onChanged: (value) {
              query = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar",
                  style: TextStyle(color: Color(0xFF9B1D42))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Buscar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    if ((query ?? '').isNotEmpty) {
      setState(() {
        _searchQuery = query;
      });
      _loadProducts();
    }
  }


  void _showAddProductDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _precioController = TextEditingController();
    final TextEditingController _cantidadDeseadaController =
        TextEditingController();
    final TextEditingController _cantidadAvisoController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir Producto"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: "Nombre del producto"),
                ),
                TextField(
                  controller: _precioController,
                  decoration:
                      const InputDecoration(labelText: "Precio Compra"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _cantidadDeseadaController,
                  decoration:
                      const InputDecoration(labelText: "Cantidad Deseada"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _cantidadAvisoController,
                  decoration:
                      const InputDecoration(labelText: "Cantidad Aviso"),
                  keyboardType: TextInputType.number,
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
                final name = _nameController.text.trim();
                final precio = double.tryParse(_precioController.text.trim());
                final cantidadDeseada =
                    int.tryParse(_cantidadDeseadaController.text.trim());
                final cantidadAviso =
                    int.tryParse(_cantidadAvisoController.text.trim());

                if (name.isEmpty ||
                    precio == null ||
                    cantidadDeseada == null ||
                    cantidadAviso == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Todos los campos son obligatorios")),
                  );
                  return;
                }

                if (_categoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No se pudo determinar la categoría")),
                  );
                  return;
                }

                final newProductData = {
                  "name": name,
                  "precioCompra": precio,
                  "cantidadDeseada": cantidadDeseada,
                  "cantidadAviso": cantidadAviso,
                  "categoria": {"id": _categoryId} // Usar el ID real de la categoría
                };

                try {
                  await InventoryApiService.createProductoInventario(newProductData);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Producto añadido exitosamente")),
                  );
                  setState(() {
                    _loadProducts();
                  });
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al añadir producto: $e")),
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Estilo del Chip para limpiar búsqueda
  Widget _buildSearchChip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Chip(
        backgroundColor: const Color(0xFF9B1D42).withOpacity(0.2),
        label: Text(
          "Búsqueda: $_searchQuery",
          style: const TextStyle(
              color: Color(0xFF9B1D42), fontWeight: FontWeight.bold),
        ),
        deleteIcon: const Icon(Icons.close, color: Color(0xFF9B1D42)),
        onDeleted: _clearSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Container(
            height: 500,
            width: 500,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.notifications,
                color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Botón Buscar con estilo personalizado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: _build3DActionButton(
                      icon: Icons.search,
                      label: "Buscar",
                      onPressed: _showSearchDialog,
                    ),
                  ),
                ),
                // Mostrar el Chip de búsqueda si existe
                if (_searchQuery != null && _searchQuery!.isNotEmpty)
                  _buildSearchChip(),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<ProductoInventario>>(
                    future: _futureProducts ?? Future.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final products = snapshot.data!;
                        if (products.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No hay productos para esta categoría'));
                        }
                        return ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final producto = products[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 167, 45, 77),
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
                                  title: Center(
                                    child: Text(
                                      producto.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ItemDetailsPage(
                                          itemName: producto.name,
                                          category: widget.categoryName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                            child: Text('No se encontraron productos'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Botón flotante "Añadir producto" en la esquina inferior derecha
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9B1D42),
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
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
}
