import 'package:android/models/user.dart';
import 'package:flutter/material.dart';
import 'package:android/models/mesa.dart';
import 'package:android/models/negocio.dart';
import 'package:android/services/service_mesa.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/mesas/mesa_detail_page.dart';
import 'package:android/models/session_manager.dart';

class HomePageEmpleado extends StatefulWidget {
  const HomePageEmpleado({Key? key, required User user}) : super(key: key);

  @override
  _HomePageEmpleadoState createState() => _HomePageEmpleadoState();
}

class _HomePageEmpleadoState extends State<HomePageEmpleado> {
  late Future<List<Mesa>> _mesasFuture;
  List<Mesa> _allMesas = [];
  List<Mesa> _filteredMesas = [];
  final TextEditingController _searchController = TextEditingController();
  bool _modoEliminar = false;

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
        _filteredMesas =
            _allMesas.where((mesa) {
              final name = (mesa.name ?? '').toLowerCase();
              return name.contains(query);
            }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoCrearMesa() async {
    String nombreMesa = '';
    int numeroAsientos = 4;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title: const Text(
              'Crear nueva mesa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF9B1D42),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  cursorColor: Color(0xFF9B1D42),
                  decoration: InputDecoration(
                    labelText: 'Nombre de la mesa',
                    labelStyle: const TextStyle(color: Color(0xFF9B1D42)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF9B1D42),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => nombreMesa = value,
                ),
                const SizedBox(height: 15),
                TextField(
                  keyboardType: TextInputType.number,
                  cursorColor: Color(0xFF9B1D42),
                  decoration: InputDecoration(
                    labelText: 'Número de asientos',
                    labelStyle: const TextStyle(color: Color(0xFF9B1D42)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF9B1D42),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged:
                      (value) => numeroAsientos = int.tryParse(value) ?? 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B1D42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Crear',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (nombreMesa.trim().isEmpty) return;
                  Mesa nuevaMesa = Mesa(
                    name: nombreMesa.trim(),
                    numeroAsientos: numeroAsientos,
                    negocio: Negocio(id: int.parse(SessionManager.negocioId!)),
                  );
                  await MesaService.createMesa(nuevaMesa);
                  Navigator.pop(context);
                  setState(() {
                    _mesasFuture = MesaService.getMesas();
                  });
                },
              ),
            ],
          ),
    );
  }

  Future<void> _confirmarYEliminarMesa(Mesa mesa) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Eliminar mesa"),
            content: Text(
              "¿Estás seguro de que quieres eliminar la mesa '${mesa.name}'?",
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Eliminar"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      await MesaService.deleteMesaById(mesa.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mesa eliminada correctamente")),
      );
      setState(() {
        _mesasFuture = MesaService.getMesas();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'btn_add',
            onPressed: _mostrarDialogoCrearMesa,
            backgroundColor: const Color(0xFF9B1D42),
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Crear mesa',
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'btn_delete',
            onPressed: () {
              setState(() {
                _modoEliminar = !_modoEliminar;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _modoEliminar
                        ? "Modo eliminar activado. Pulsa una mesa para eliminarla."
                        : "Modo eliminar desactivado.",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            backgroundColor: const Color(0xFF9B1D42), // rojo burdeos
            child: Icon(
              _modoEliminar ? Icons.cancel : Icons.delete,
              color: Colors.white, // icono blanco
            ),
            tooltip: 'Eliminar mesas',
          ),
        ],
      ),
      body: Column(
        children: [
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/logo.png', height: 50),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
                const Text(
                  'TPV',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PermanentMarker',
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 20),
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
                        if (_modoEliminar) {
                          _confirmarYEliminarMesa(mesa);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MesaDetailPage(mesa: mesa),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF9B1D42),
                              Color(0xFFB12A50),
                              Color(0xFFD33E66),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                       child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.table_bar, size: 40, color: Color.fromARGB(255, 59, 3, 20)),
                            const SizedBox(height: 8),
                            Text(
                              mesa.name ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ],
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
