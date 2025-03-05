import 'package:android/pages/categoryItems_page.dart';
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
    {'name': 'Verduras', 'icon': FontAwesomeIcons.carrot},
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
        title: const Text(
          'Inventario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 129, 43, 43),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
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
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 129, 43, 43),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.add, size: 30),
            label: const Text(
              "Añadir",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        height: 250,
        width: 200,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 129, 43, 43),
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
          children: [
            Icon(
              category['icon'],
              size: 80,
              color: Colors.white,
            ),
            Text(
              category['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CategoryItemsPage(categoryName: category['name']),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text("Ver"),
            ),
          ],
        ),
      ),
    );
  }
}

// En el futuro, aquí puedes reemplazar la lista 'categories' con datos desde el backend.
// Ejemplo:
// void fetchCategories() async {
//   final response = await http.get(Uri.parse('https://api.example.com/categories'));
//   if (response.statusCode == 200) {
//     setState(() {
//       categories = jsonDecode(response.body);
//     });
//   }
// }
