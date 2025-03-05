import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class EmployeesPage extends StatelessWidget {
  EmployeesPage({super.key});

  final List<Map<String, dynamic>> employees = [
    {'name': 'María Ruiz', 'phone': '680 56 54 67', 'position': 'Encargada', 'image': 'assets/employee1.png'},
    {'name': 'Juan Pérez', 'phone': '685 12 34 56', 'position': 'Camarero', 'image': 'assets/employee2.png'},
    {'name': 'Ana Gómez', 'phone': '680 78 90 12', 'position': 'Cocinera', 'image': 'assets/employee3.png'},
    {'name': 'Carlos Rodríguez', 'phone': '650 34 56 78', 'position': 'Repartidor', 'image': 'assets/employee4.png'},
    {'name': 'Laura Martínez', 'phone': '640 12 34 56', 'position': 'Asistente de cocina', 'image': 'assets/employee5.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Empleados',
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
              cardsCount: employees.length,
              onSwipe: (previousIndex, currentIndex, direction) {
                debugPrint("Swiped from index: \$previousIndex to \$currentIndex");
                return true;
              },
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return _buildEmployeeCard(employees[index]);
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

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        height: 400,
        width: 320,
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
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(employee['image']),
            ),
            Text(
              employee['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              employee['position'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Acción de ver detalles del empleado
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

