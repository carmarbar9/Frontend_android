import 'package:android/models/categoria.dart';
import 'package:android/pages/inventario/categoryItems_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/services/service_categoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/services/service_inventory.dart';

class InventoryPage extends StatefulWidget {
  final String negocioId;
  const InventoryPage({super.key, required this.negocioId});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Future<List<Categoria>> _futureCategories;

  // Variable para guardar la cadena de búsqueda
  String? _searchQuery;

  final Map<String, IconData> categoryIcons = {
    'COMIDA': FontAwesomeIcons.carrot,
    'CARNES': LineIcons.drumstickWithBiteTakenOut,
    'PESCADOS': LineIcons.fish,
    'ESPECIAS': FontAwesomeIcons.mortarPestle,
    'BEBIDAS': LineIcons.beer,
    'FRUTAS': LineIcons.fruitApple,
    'LÁCTEOS': LineIcons.cheese,
    'OTROS': LineIcons.box,
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Carga las categorías; si _searchQuery está vacío, las del negocio;
  /// si no, filtradas por nombre exacto o parcial (dependiendo de tu implementación).
  void _loadCategories() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      _futureCategories = CategoryApiService.getCategoriesByNegocioId(
        widget.negocioId,
      );
    } else {
      // Aquí podrías llamar a getCategoriesByName(_searchQuery!)
      // o primero obtener todas y filtrar en memoria, según tu preferencia.
      _futureCategories = CategoryApiService.getCategoriesByNegocioId(
        widget.negocioId,
      ).then(
        (lista) =>
            lista
                .where(
                  (c) => c.name.toLowerCase().contains(
                    _searchQuery!.toLowerCase(),
                  ),
                )
                .toList(),
      );
    }
  }

  /// Limpia la búsqueda y recarga categorías
  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _loadCategories();
    });
  }

  void _showSearchDialog() async {
    String? query;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Buscar Categoría",
            style: TextStyle(
              color: Color(0xFF9B1D42),
              fontWeight: FontWeight.bold,
              fontFamily: 'TitanOne',
            ),
          ),
          content: TextField(
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
            style: const TextStyle(
              color: Color(0xFF9B1D42),
              fontWeight: FontWeight.bold,
            ),
            onChanged: (value) {
              query = value.trim();
            },
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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Buscar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    // Asignar la búsqueda y recargar
    if ((query ?? '').isNotEmpty) {
      setState(() {
        _searchQuery = query;
      });
      _loadCategories();
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController _categoryNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nueva Categoría"),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              hintText: "Nombre de la categoría",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName =
                    _categoryNameController.text.trim().toUpperCase();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre no puede estar vacío'),
                    ),
                  );
                  return;
                }

                // Agrega el campo "pertenece" con el valor que tu backend requiera:
                final newCategoryData = {
                  "name": newName,
                  "negocio": {"id": widget.negocioId},
                  "pertenece": "INVENTARIO",
                };

                try {
                  await CategoryApiService.createCategory(newCategoryData);
                  Navigator.pop(context);
                  setState(() {
                    _searchQuery = null; // Si quieres resetear la búsqueda
                    _loadCategories();
                  });
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al agregar: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Encabezado con logo y botones superiores
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
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
                          final productos =
                              await InventoryApiService.getProductosInventario();

                          final Map<int, List<Lote>> lotesPorProducto = {};
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
                            builder: (context) => const UserProfilePage(),
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
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
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

          // Si hay una búsqueda activa, mostramos el Chip para limpiarla
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

          const SizedBox(height: 10),

          // Contenido dinámico
          Expanded(
            child: FutureBuilder<List<Categoria>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron categorías',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9B1D42),
                      ),
                    ),
                  );
                } else {
                  final categories = snapshot.data!;
                  return CardSwiper(
                    cardsCount: categories.length,
                    numberOfCardsDisplayed:
                        categories.length >= 3 ? 3 : categories.length,
                    onSwipe: (prev, curr, dir) => true,
                    cardBuilder: (context, index, _, __) {
                      final categoria = categories[index];
                      return _buildCategoryCard(categoria);
                    },
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          // Botón "Añadir categoría"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: SizedBox(
              width: double.infinity,
              child: _build3DActionButton(
                icon: Icons.add,
                label: "Añadir categoría",
                onPressed: _showAddCategoryDialog,
              ),
            ),
          ),

          const SizedBox(height: 30),
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

  Widget _buildCategoryCard(Categoria categoria) {
    final iconData =
        categoryIcons[categoria.name.toUpperCase()] ?? Icons.category;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(20),
        height: 460,
        width: 380,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(iconData, size: 120, color: Colors.white),
            Text(
              categoria.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'TitanOne',
                color: Colors.white,
              ),
            ),

            // Botón Ver
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF9B1D42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategoryItemsPage(
                          categoryId: int.parse(categoria.id),
                        ), // Convertir a int
                  ),
                );
              },
              icon: const Icon(
                Icons.visibility,
                size: 28,
                color: Color(0xFF9B1D42),
              ),
              label: const Text(
                "Ver",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TitanOne',
                ),
              ),
            ),

            // Botones Editar y Eliminar (solo si es INVENTARIO)
            if (categoria.pertenece == "INVENTARIO")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF9B1D42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      size: 28,
                      color: Color(0xFF9B1D42),
                    ),
                    label: const Text(
                      "Editar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TitanOne',
                      ),
                    ),
                    onPressed: () {
                      _showEditCategoryDialog(categoria);
                    },
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF9B1D42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.delete,
                      size: 28,
                      color: Color(0xFF9B1D42),
                    ),
                    label: const Text(
                      "Eliminar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TitanOne',
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("¿Eliminar categoría?"),
                              content: const Text(
                                "Esta acción no se puede deshacer.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Eliminar"),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        try {
                          await CategoryApiService.deleteCategory(
                            categoria.id.toString(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Categoría eliminada"),
                            ),
                          );
                          _loadCategories();
                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al eliminar: $e")),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Categoria categoria) {
    final TextEditingController _controller = TextEditingController(
      text: categoria.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Categoría"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: "Nuevo nombre"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = _controller.text.trim().toUpperCase();
                if (newName.isEmpty) return;

                final data = {
                  "id": categoria.id,
                  "name": newName,
                  "negocio": {"id": widget.negocioId},
                  "pertenece": "INVENTARIO",
                };

                try {
                  await CategoryApiService.updateCategory(
                    categoria.id.toString(),
                    data,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Categoría actualizada")),
                  );
                  _loadCategories(); // esto actualiza el Future internamente
                  setState(() {}); // esto fuerza el redibujado
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al actualizar: $e")),
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
}
