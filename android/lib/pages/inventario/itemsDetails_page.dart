import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class ItemDetailsPage extends StatelessWidget {
  final String itemName;
  final String category;

  ItemDetailsPage({super.key, required this.itemName, required this.category});

  final Map<String, dynamic> mockData = {
    'Coca-Cola': {
      'category': 'Bebidas',
      'quantity': 100,
      'stockAlert': 70,
      'expirationDates': [
        {'batch': '1', 'units': 100, 'date': '13/09/2026'},
      ],
    },
    'Leche': {
      'category': 'Lácteos',
      'quantity': 50,
      'stockAlert': 20,
      'expirationDates': [
        {'batch': '1', 'units': 50, 'date': '10/05/2025'},
      ],
    },
  };

  final Map<String, IconData> categoryIcons = {
    'Verduras': FontAwesomeIcons.carrot,
    'Carnes': LineIcons.drumstickWithBiteTakenOut,
    'Pescados': LineIcons.fish,
    'Especias': FontAwesomeIcons.mortarPestle,
    'Bebidas': LineIcons.beer,
    'Frutas': LineIcons.fruitApple,
    'Lácteos': LineIcons.cheese,
    'Otros': LineIcons.box,
  };

  @override
  Widget build(BuildContext context) {
    final itemData = mockData[itemName] ?? {};
    final expirationDates = itemData['expirationDates'] ?? [];
    final iconData = categoryIcons[category] ?? Icons.category;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,  // Remover la sombra del AppBar
        leading: IconButton(
          icon: Container(
            height: 120,  // Aumentamos el tamaño del logo
            width: 120,  // Mantener el logo en proporción cuadrada
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
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 10, 10, 10)),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 400),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 167, 45, 77),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    Text('Nombre: $itemName', style: _textStyle()),
                    Text('Categoría: ${itemData['category']}', style: _textStyle()),
                    Text('Cantidad: ${itemData['quantity']}', style: _textStyle()),
                    Text('Alerta Stock: ${itemData['stockAlert']}', style: _textStyle()),
                    const SizedBox(height: 20),
                    for (var batch in expirationDates)
                      Text('CAD ${batch['batch']}-${batch['units']}u.: ${batch['date']}', style: _textStyle()),
                  ],
                ),
              ),
              const SizedBox(height: 30, width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar"),
                  ),
                  const SizedBox(height: 30, width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                    label: const Text("Eliminar"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Volver"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 25,
      fontWeight: FontWeight.bold,
    );
  }
}

// En el futuro, aquí puedes reemplazar los datos simulados con una consulta al backend.
// Ejemplo:
// void fetchItemDetails(String itemName) async {
//   final response = await http.get(Uri.parse('https://api.example.com/item?name=$itemName'));
//   if (response.statusCode == 200) {
//     setState(() {
//       itemData = jsonDecode(response.body);
//     });
//   }
// }
