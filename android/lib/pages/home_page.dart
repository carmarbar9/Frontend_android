import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Encabezado con logo y botones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                ),
                Row(
                  children: [
                    IconButton(iconSize: 48,
                      icon: const Icon(Icons.notifications, color: Colors.black),
                      onPressed: () {},
                    ),
                    IconButton(iconSize: 48,
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Título "Inicio"
          const Text(
            "INICIO",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontFamily: 'PermanentMarker',
            ),
          ),

          const SizedBox(height: 20),

          // Botones de navegación
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenuButton(Icons.restaurant_menu, "Carta"),
                _buildMenuButton(Icons.inventory, "Inventario"),
                _buildMenuButton(Icons.attach_money, "Ventas"),
                _buildMenuButton(Icons.dashboard, "Dashboard"),
                _buildMenuButton(Icons.people, "Empleados"),
                _buildMenuButton(Icons.local_shipping, "Proveedores"),
              ],
            ),
          ),

          // Botón inferior "Planes"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.card_membership, size: 30),
              label: const Text(
                "Planes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'TitanOne'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        elevation: 5,
      ),
      onPressed: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.deepPurple),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'TitanOne'),
          ),
        ],
      ),
    );
  }
}
