import 'package:android/models/categoria.dart';
import 'package:android/pages/inventario/categoryItems_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/services/service_categoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class InventoryPage extends StatefulWidget {
  final String negocioId; // Id del negocio para filtrar las categorías

  const InventoryPage({super.key, required this.negocioId});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Future<List<Categoria>> _futureCategories;

  // Mapa de íconos para cada categoría (ajústalo según los valores que devuelve tu backend)
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
    // Consulta las categorías asociadas al negocio usando su id.
    _futureCategories = CategoryApiService.getCategoriesByNegocioId(widget.negocioId);
  }

  // Función para abrir el diálogo de "Añadir categoría"
  void _showAddCategoryDialog() {
    final TextEditingController _categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Categoría'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String newName = _categoryNameController.text.trim().toUpperCase();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre no puede estar vacío')),
                  );
                  return;
                }
                // Crea el Map con los datos de la nueva categoría, asignando el negocioId actual.
                final Map<String, dynamic> newCategoryData = {
                  "name": newName,
                  "negocio": {"id": widget.negocioId},
                };

                try {
                  await CategoryApiService.createCategory(newCategoryData);
                  Navigator.pop(context);
                  // Refresca la lista de categorías
                  setState(() {
                    _futureCategories = CategoryApiService.getCategoriesByNegocioId(widget.negocioId);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Categoría agregada exitosamente')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al agregar categoría: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Container(
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
      body: Column(
        children: [
          // Título "Inventario"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              'Inventario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.black,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),
          // Barra de búsqueda (puedes implementarla a futuro)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color.fromARGB(255, 150, 149, 149),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 71, 71, 71)!),
                ),
              ),
            ),
          ),
          // FutureBuilder para mostrar las categorías en un CardSwiper
          Expanded(
            child: FutureBuilder<List<Categoria>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay categorías para este negocio'));
                } else {
                  final categories = snapshot.data!;
                  return CardSwiper(
                    cardsCount: categories.length,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      debugPrint("Swiped from index: $previousIndex to $currentIndex");
                      return true;
                    },
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      final categoria = categories[index];
                      return _buildCategoryCard(categoria);
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // Botón "Añadir" para agregar una nueva categoría al negocio actual.
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 167, 45, 77),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add, size: 30),
            label: const Text(
              "Añadir",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          // Botones de "Pérdidas" y "Riesgos"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Acción para "Pérdidas"
                  },
                  icon: const Icon(Icons.warning, size: 30),
                  label: const Text(
                    "Pérdidas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Acción para "Riesgos"
                  },
                  icon: const Icon(Icons.error, size: 30),
                  label: const Text(
                    "Riesgos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Categoria categoria) {
    // Si el nombre en la base viene en mayúsculas, usamos toUpperCase para buscar el ícono.
    final iconData = categoryIcons[categoria.name.toUpperCase()] ?? Icons.category;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(20),
        height: 400,
        width: 320,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 167, 45, 77),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              categoria.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Navegar a la página de items filtrados por la categoría seleccionada.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryItemsPage(categoryName: categoria.name),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 30),
              label: const Text("Ver"),
            ),
          ],
        ),
      ),
    );
  }
}
