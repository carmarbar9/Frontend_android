import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:android/models/lote.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/models/categoria.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/carta/productosCategoria_page.dart';
import 'package:android/services/service_categoria.dart';

class CartaPage extends StatefulWidget {
  final String negocioId;
  const CartaPage({super.key, required this.negocioId});

  @override
  State<CartaPage> createState() => _CartaPageState();
}

class _CartaPageState extends State<CartaPage> {
  late Future<List<Categoria>> _categorias;
  final String negocioId = SessionManager.negocioId!;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _categorias = CategoryApiService.getCategoriesByNegocioIdVenta(negocioId);
  }

  void _mostrarDialogoCrearCategoria() {
    final TextEditingController _nombreController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir nueva categoría"),
          content: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: "Nombre de la categoría",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = _nombreController.text.trim().toUpperCase();
                if (nombre.isEmpty) return;

                try {
                  await CategoryApiService.createCategory({
                    "nombre": nombre,
                    "negocioId": int.parse(
                    widget.negocioId,
                  ),
                    "pertenece": "VENTA",
                  });

                  Navigator.pop(context);
                  setState(() {
                    _categorias =
                        CategoryApiService.getCategoriesByNegocioIdVenta(
                          negocioId,
                        );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Categoría creada correctamente"),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al crear categoría: $e")),
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

  void _mostrarDialogoEditarCategoria(Categoria categoria) {
    final TextEditingController _nombreController = TextEditingController(
      text: categoria.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar categoría"),
          content: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: "Nuevo nombre"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevoNombre = _nombreController.text.trim().toUpperCase();
                if (nuevoNombre.isEmpty || nuevoNombre == categoria.name)
                  return;

                try {
                  await CategoryApiService.updateCategory(categoria.id, {
                    "id": categoria.id,
                    "nombre": nuevoNombre,
                    "negocioId": int.parse(
                    widget.negocioId,
                  ),
                    "pertenece": categoria.pertenece,
                  });

                  Navigator.pop(context);
                  setState(() {
                    _categorias =
                        CategoryApiService.getCategoriesByNegocioIdVenta(
                          negocioId,
                        );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Categoría actualizada correctamente"),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error al actualizar categoría: $e"),
                    ),
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

  Future<void> _eliminarCategoria(Categoria categoria) async {
    try {
      setState(() {
        _categorias = Future.value([]);
      });

      await CategoryApiService.deleteCategory(categoria.id.toString());

      setState(() {
        _categorias = CategoryApiService.getCategoriesByNegocioIdVenta(
          negocioId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Categoría '${categoria.name}' eliminada")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar categoría: $e")),
      );
    }
  }

  IconData _iconoPorCategoria(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'entrantes':
        return Icons.fastfood;
      case 'carnes':
        return Icons.lunch_dining;
      case 'pescados':
        return Icons.set_meal;
      case 'postres':
        return Icons.icecream;
      case 'bebidas':
        return Icons.local_bar;
      case 'tapas':
        return Icons.ramen_dining;
      case 'ensaladas':
        return Icons.grass;
      case 'sopas':
        return Icons.soup_kitchen;
      default:
        return Icons.menu_book;
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
                              builder: (_) => NotificacionPage(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al cargar notificaciones: $e',
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
              'CARTA',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF9B1D42),
                      side: const BorderSide(
                        color: Color(0xFF9B1D42),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final TextEditingController _searchController =
                          TextEditingController();

                      final confirm = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              "Buscar categoría",
                              style: TextStyle(
                                color: Color(0xFF9B1D42),
                                fontFamily: 'TitanOne',
                              ),
                            ),
                            content: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: "Nombre",
                                hintText: "Ej: carnes, postres...",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9B1D42),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    _searchController.text.trim(),
                                  );
                                },
                                child: const Text("Buscar"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != null && confirm.isNotEmpty) {
                        setState(() {
                          _searchQuery = confirm;
                          _categorias =
                              CategoryApiService.getCategoriesByNameCarta(
                                confirm,
                              ).then(
                                (list) =>
                                    list
                                        .where(
                                          (cat) => cat.negocioId == negocioId,
                                        )
                                        .toList(),
                              );
                        });
                      }
                    },

                    icon: const Icon(
                      Icons.search,
                      size: 30,
                      color: Color(0xFF9B1D42),
                    ),
                    label: const Text(
                      'Buscar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TitanOne',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF9B1D42),
                      side: const BorderSide(
                        color: Color(0xFF9B1D42),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: _mostrarDialogoCrearCategoria,
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                      color: Color(0xFF9B1D42),
                    ),
                    label: const Text(
                      'Añadir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TitanOne',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Center(
                child: Chip(
                  label: Text(
                    'Filtrado por: $_searchQuery',
                    style: const TextStyle(
                      color: Color(0xFF9B1D42),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFF9B1D42).withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, color: Color(0xFF9B1D42)),
                  onDeleted: () {
                    setState(() {
                      _searchQuery = null;
                      _categorias =
                          CategoryApiService.getCategoriesByNegocioIdVenta(
                            negocioId,
                          );
                    });
                  },
                ),
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Categoria>>(
              future: _categorias,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  debugPrint("❌ Error al cargar categorías: $error");

                  return const Center(
                    child: Text("No se pudieron cargar las categorías"),
                  );
                }

                final categorias = snapshot.data ?? [];

                if (categorias.isEmpty) {
                  return const Center(
                    child: Text("No hay categorías disponibles"),
                  );
                }

                return ListView.builder(
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final cat = categorias[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
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
                          borderRadius: BorderRadius.circular(30),
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
                          ),
                          leading: Icon(
                            _iconoPorCategoria(cat.name),
                            color: Colors.white,
                            size: 36,
                          ),
                          title: Text(
                            cat.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'TitanOne',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductosPorCategoriaPage(
                                      categoria: cat,
                                    ),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    () => _mostrarDialogoEditarCategoria(cat),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          "¿Eliminar categoría?",
                                        ),
                                        content: Text(
                                          "¿Estás seguro de que quieres eliminar '${cat.name}'? Esta acción no se puede deshacer.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Cancelar"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF9B1D42,
                                              ),
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Eliminar"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    _eliminarCategoria(cat);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
