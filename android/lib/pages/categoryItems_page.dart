import 'package:android/pages/itemsDetails_page.dart';
import 'package:android/pages/notifications_page.dart';
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

  // Lista de productos de ejemplo por categoría
  final Map<String, List<String>> categoryItems = {
    'Verduras': ['Lechuga', 'Tomate', 'Zanahoria', 'Cebolla', 'Pimiento'],
    'Carnes': ['Pollo', 'Ternera', 'Cerdo', 'Cordero', 'Jamón'],
    'Pescados': ['Atún', 'Salmón', 'Merluza', 'Bacalao', 'Sardina'],
    'Especias': ['Pimienta', 'Sal', 'Orégano', 'Curry', 'Pimentón'],
    'Bebidas': ['Agua', 'Coca-Cola', 'Zumo de Piña', 'Cerveza', 'Vino'],
    'Frutas': ['Manzana', 'Plátano', 'Naranja', 'Pera', 'Melón'],
    'Lácteos': ['Leche', 'Queso', 'Yogur', 'Mantequilla', 'Nata'],
    'Otros': ['Aceite', 'Vinagre', 'Harina', 'Azúcar', 'Café'],
  };

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = categoryItems[widget.categoryName] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,  // Remover la sombra del AppBar
        leading: IconButton(
          icon: Container(
            height: 500,  // Aumentamos el tamaño del logo
            width: 500,  // Mantener el logo en proporción cuadrada
            child: Image.asset(
              'assets/logo.png', // Utilizamos la imagen del logo como ícono
              fit: BoxFit.contain,  // Asegura que el logo se mantenga dentro de los límites
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // Navegar atrás cuando se toca el logo
          },
        ),
        actions: [
          // Icono de notificaciones en la izquierda
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 176, 20, 20)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          // Icono de perfil en la izquierda
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
                TextField(
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
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 129, 43, 43),
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
                                items[index].toUpperCase(),
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
                                  builder:
                                      (context) => ItemDetailsPage(
                                        itemName: items[index],
                                        category: widget.categoryName,
                                      ),
                                ),
                              );
                            },

                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// En el futuro, aquí puedes reemplazar la lista 'categoryItems' con datos desde el backend.
// Ejemplo:
// void fetchCategoryItems(String categoryName) async {
//   final response = await http.get(Uri.parse('https://api.example.com/items?category=$categoryName'));
//   if (response.statusCode == 200) {
//     setState(() {
//       categoryItems[categoryName] = jsonDecode(response.body);
//     });
//   }
// }
