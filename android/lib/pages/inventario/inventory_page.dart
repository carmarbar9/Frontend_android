import 'package:android/pages/inventario/categoryItems_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'COMIDA', 'icon': FontAwesomeIcons.carrot},
    {'name': 'Carnes', 'icon': LineIcons.drumstickWithBiteTakenOut},
    {'name': 'Pescados', 'icon': LineIcons.fish},
    {'name': 'Especias', 'icon': FontAwesomeIcons.mortarPestle},
    {'name': 'Bebidas', 'icon': LineIcons.beer},
    {'name': 'Frutas', 'icon': LineIcons.fruitApple},
    {'name': 'Lácteos', 'icon': LineIcons.cheese},
    {'name': 'Otros', 'icon': LineIcons.box},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0, // Remover la sombra del AppBar
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
          // Título "Inventario" sobre la barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
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
          // Barra de búsqueda con estilo personalizado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Container(
              width: double.infinity,
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
          ),
          Expanded(
            child: CardSwiper(
              cardsCount: categories.length,
              onSwipe: (previousIndex, currentIndex, direction) {
                debugPrint("Swiped from index: \$previousIndex to \$currentIndex");
                return true;
              },
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return _buildCategoryCard(categories[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 167, 45, 77),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              // Acción para agregar una nueva categoría o producto
            },
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
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
              category['icon'],
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
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
                // Navegar a la página de items filtrados por la categoría seleccionada
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryItemsPage(categoryName: category['name']),
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
