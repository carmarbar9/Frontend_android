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
    'Bebidas': ['Agua', 'Refresco', 'Zumo', 'Cerveza', 'Vino'],
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
        title: Text(
          widget.categoryName.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 129, 43, 43),
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
