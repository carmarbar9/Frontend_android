import 'package:android/pages/empleados/employee_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/proveedores/providers_page.dart';
import 'package:flutter/material.dart';
import 'inventario/inventory_page.dart';
import 'package:android/pages/planes/plans_page.dart';
import 'package:android/pages/ventas/sales_page.dart';
import 'package:android/pages/dashboard/dashboard_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/carta/carta_page.dart';



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
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 176, 20, 20)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      },
          ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserProfilePage()),
                        );
                      },
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

          // Botones de navegación con animación
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildAnimatedMenuButton(Icons.restaurant_menu, "Carta"),
                _buildAnimatedMenuButton(Icons.inventory, "Inventario"),
                _buildAnimatedMenuButton(Icons.attach_money, "Ventas"),
                _buildAnimatedMenuButton(Icons.dashboard, "Dashboard"),
                _buildAnimatedMenuButton(Icons.people, "Empleados"),
                _buildAnimatedMenuButton(Icons.local_shipping, "Proveedores"),
              ],
            ),
          ),

          // Botón inferior "Planes"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 129, 43, 43),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlansPage()),
                );
              },
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

  Widget _buildAnimatedMenuButton(IconData icon, String text) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => scale = 1.1),
          onExit: (_) => setState(() => scale = 1.0),
          child: Transform.scale(
            scale: scale,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 129, 43, 43),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color.fromARGB(255, 129, 43, 43), width: 2),
                ),
                elevation: 5,
              ),
              onPressed: () {
                if (text == "Inventario") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InventoryPage()),
                  );
                }
                if (text == "Empleados") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmployeesPage()),
                  );
                }
                if (text == "Ventas") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesPage()),
                  );
                }
                if (text == "Carta") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartaPage()),
                  );
                }

                if (text == "Dashboard") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
                }

                if (text == "Proveedores") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProvidersPage()),
                  );
                }
              }, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 60, color: const Color.fromARGB(255, 129, 43, 43)),
                  const SizedBox(height: 10),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'TitanOne'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
