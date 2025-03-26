import 'package:flutter/material.dart';
import 'package:android/models/categoria.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/carta/productosCategoria_page.dart';
import 'package:android/services/service_categoria.dart';

class CartaPage extends StatefulWidget {
  const CartaPage({super.key});

  @override
  State<CartaPage> createState() => _CartaPageState();
}

class _CartaPageState extends State<CartaPage> {
  late Future<List<Categoria>> _categorias;
  final String negocioId = "1";

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
            decoration: const InputDecoration(labelText: "Nombre de la categoría"),
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
                    "name": nombre,
                    "negocio": {"id": negocioId},
                    "pertenece": "VENTA"
                  });

                  Navigator.pop(context);
                  setState(() {
                    _categorias = CategoryApiService.getCategoriesByNegocioIdVenta(negocioId);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Categoría creada correctamente")),
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

  Future<void> _eliminarCategoria(Categoria categoria) async {
  try {
  setState(() {
    _categorias = Future.value([]); // Limpia la lista temporalmente
  });

  await CategoryApiService.deleteCategory(categoria.id.toString());

      setState(() {
        _categorias = CategoryApiService.getCategoriesByNegocioIdVenta(negocioId); 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: SizedBox(
            height: 120,
            width: 120,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const Text(
              'CARTA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.black,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 150, 149, 149),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 71, 71, 71)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 167, 45, 77),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _mostrarDialogoCrearCategoria,
                  icon: const Icon(Icons.add, size: 30),
                  label: const Text(
                    'Añadir',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Categoria>>(
                future: _categorias,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error al cargar categorías: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay categorías disponibles"));
                  }

                  final categorias = snapshot.data!;
                  return ListView.builder(
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final cat = categorias[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 85,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 167, 45, 77),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductosPorCategoriaPage(
                                    categoria: cat,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                               Image.asset(
                                'assets/icons/${cat.name.toLowerCase()}.png',
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/logo.png', // 👈 icono por defecto
                                    height: 40,
                                  );
                                },
                              ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    cat.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _eliminarCategoria(cat),
                                )
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
      ),
    );
  }
}