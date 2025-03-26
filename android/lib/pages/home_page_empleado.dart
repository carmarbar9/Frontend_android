import 'package:flutter/material.dart';
import 'package:android/models/mesa.dart';
import 'package:android/services/service_mesa.dart';
import 'package:android/pages/login_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/mesas/mesa_detail_page.dart'; // Asegúrate de que la ruta es correcta

class HomePageEmpleado extends StatefulWidget {
  const HomePageEmpleado({Key? key}) : super(key: key);

  @override
  _HomePageEmpleadoState createState() => _HomePageEmpleadoState();
}

class _HomePageEmpleadoState extends State<HomePageEmpleado> {
  late Future<List<Mesa>> _mesasFuture;
  List<Mesa> _allMesas = [];
  List<Mesa> _filteredMesas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mesasFuture = MesaService.getMesas();
    _searchController.addListener(_filterMesas);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMesas);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMesas() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMesas = List.from(_allMesas);
      } else {
        _filteredMesas = _allMesas.where((mesa) {
          final name = (mesa.name ?? '').toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // AppBar personalizado
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
            "TPV",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontFamily: 'PermanentMarker',
            ),
          ),

          const SizedBox(height: 20),

          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar mesa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lista de mesas mostradas como círculos
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
                _allMesas = snapshot.data!;
                if (_searchController.text.trim().isEmpty) {
                  _filteredMesas = List.from(_allMesas);
                }
                if (_filteredMesas.isEmpty) {
                  return const Center(child: Text("No se encontraron mesas"));
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _filteredMesas.length,
                  itemBuilder: (context, index) {
                    final mesa = _filteredMesas[index];
                    return GestureDetector(
                      onTap: () {
                        // Navega a la pantalla de detalle de la mesa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MesaDetailPage(mesa: mesa),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF9B1D42),
                        child: Text(
                          mesa.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
