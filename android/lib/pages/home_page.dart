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
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Encabezado con logo y botones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png', // Asegúrate de tener este archivo en assets
                  height: 90,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.black),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Título "INICIO"
          const Text(
            "INICIO",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Botones de navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                _buildMenuButton(Icons.people, "EMPLEADOS"),
                _buildMenuButton(Icons.inventory, "INVENTARIO"),
                _buildMenuButton(Icons.restaurant_menu, "CARTA"),
                _buildMenuButton(Icons.dashboard, "DASHBOARD"),
                _buildMenuButton(Icons.attach_money, "VENTAS"),
                _buildMenuButton(Icons.local_shipping, "PROVEEDORES"),
              ],
            ),
          ),

          // Botón inferior "Planes"
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.card_membership),
              label: const Text("Planes"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon, size: 30),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
