import 'package:flutter/material.dart';
import 'package:android/models/mesa.dart';
import 'package:android/services/service_mesa.dart'; 
import 'package:android/pages/login_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';

class HomePageEmpleado extends StatefulWidget {
  const HomePageEmpleado({Key? key}) : super(key: key);

  @override
  _HomePageEmpleadoState createState() => _HomePageEmpleadoState();
}

class _HomePageEmpleadoState extends State<HomePageEmpleado> {
  late Future<List<Mesa>> _mesasFuture;

  @override
  void initState() {
    super.initState();
    _mesasFuture = MesaService.getMesas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // AppBar similar al del dueño
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                Image.asset('assets/logo.png', height: 62),
                Row(
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.notifications, color: Colors.black),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserProfilePage()),
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Título de la página
          const Text(
            "TPV - Empleado",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontFamily: 'PermanentMarker',
            ),
          ),

          const SizedBox(height: 20),

          // Lista de mesas (GridView)
          Expanded(
            child: FutureBuilder<List<Mesa>>(
              future: _mesasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final mesas = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: mesas.length,
                  itemBuilder: (context, index) {
                    return _buildMesaCard(mesas[index]);
                  },
                );
              },
            ),
          ),

          // Botón para ver o finalizar el pedido
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Lógica para ver o finalizar el pedido
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Ver Pedido'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesaCard(Mesa mesa) {
    return GestureDetector(
      onTap: () {
        // Acción para ver detalles o asignar la mesa a un pedido
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mesa.name ?? '', // Se utiliza un valor por defecto vacío si es null
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Asientos: ${mesa.numeroAsientos ?? 0}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
