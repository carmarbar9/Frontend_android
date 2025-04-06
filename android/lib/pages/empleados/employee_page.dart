import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_empleados.dart';
import 'package:android/pages/empleados/employee_detail_page.dart';
import 'package:android/pages/empleados/add_employee_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/models/lote.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({Key? key}) : super(key: key);

  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late Future<List<Empleado>> _empleadosFuture;

  String? _busquedaActiva;
  String? _tipoBusqueda;

  @override
  void initState() {
    super.initState();
    _refreshEmployees();
  }

  void _refreshEmployees() {
    setState(() {
      final negocioId = int.parse(SessionManager.negocioId!);

      _empleadosFuture = EmpleadoService.getEmpleadosByNegocio(negocioId);
    });
  }

  void _showSearchDialog() async {
    String query = '';
    String tipoBusqueda = 'Nombre';
    final opcionesBusqueda = ['Nombre', 'Apellido'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Buscar Empleado",
            style: TextStyle(
              color: Color(0xFF9B1D42),
              fontWeight: FontWeight.bold,
              fontFamily: 'TitanOne',
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tipoBusqueda,
                items:
                    opcionesBusqueda.map((String opcion) {
                      return DropdownMenuItem<String>(
                        value: opcion,
                        child: Text(opcion),
                      );
                    }).toList(),
                onChanged: (value) {
                  tipoBusqueda = value!;
                },
                decoration: const InputDecoration(
                  labelText: "Buscar por",
                  labelStyle: TextStyle(color: Color(0xFF9B1D42)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B1D42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B1D42), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  hintText: "Ingresa valor",
                  hintStyle: TextStyle(
                    color: const Color(0xFF9B1D42).withOpacity(0.6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF9B1D42)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF9B1D42),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF9B1D42),
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) => query = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFF9B1D42)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _buscarEmpleado(tipoBusqueda, query);
              },
              child: const Text(
                "Buscar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buscarEmpleado(String tipo, String query) async {
    try {
      _busquedaActiva = query;
      _tipoBusqueda = tipo;
      final negocioId = int.parse(SessionManager.negocioId!);

      Future<List<Empleado>> future;

      switch (tipo) {
        case 'Nombre':
          future = EmpleadoService.getEmpleadosByNombre(query);
          break;
        case 'Apellido':
          future = EmpleadoService.getEmpleadosByApellido(query);
          break;
        default:
          future = Future.value([]);
      }

      setState(() {
        _empleadosFuture = future.then(
          (lista) => lista.where((e) => e.negocio == negocioId).toList(),
        );
      });
    } catch (e) {
      print('Error al buscar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Image.asset('assets/logo.png', height: 62),
                ),
                Row(
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        try {
                          // 1. Obtener productos del inventario
                          List<ProductoInventario> productos = await InventoryApiService.getProductosInventario();

                          // 2. Obtener lotes por producto
                          Map<int, List<Lote>> lotesPorProducto = {};
                          for (var producto in productos) {
                            final lotes = await LoteProductoService.getLotesByProductoId(producto.id);
                            lotesPorProducto[producto.id] = lotes;
                          }

                          // 3. Generar notificaciones
                          final notificaciones = NotificacionService()
                              .generarNotificacionesInventario(productos, lotesPorProducto);

                          // 4. Navegar a la página de notificaciones
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificacionPage(notificaciones: notificaciones),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al cargar notificaciones: $e')),
                          );
                        }
                      },
                    ),

                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfilePage(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'EMPLEADOS',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Botón de buscar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: SizedBox(
              width: double.infinity,
              child: _build3DActionButton(
                icon: Icons.search,
                label: "Buscar",
                onPressed: _showSearchDialog,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Chip + Empleados
          Expanded(
            child: Column(
              children: [
                if (_busquedaActiva != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Chip(
                      backgroundColor: const Color(0xFF9B1D42).withOpacity(0.2),
                      label: Text(
                        'Búsqueda: $_busquedaActiva',
                        style: const TextStyle(
                          color: Color(0xFF9B1D42),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        color: Color(0xFF9B1D42),
                      ),
                      onDeleted: () {
                        setState(() {
                          _busquedaActiva = null;
                          _tipoBusqueda = null;
                          _refreshEmployees();
                        });
                      },
                    ),
                  ),

                Expanded(
                  child: FutureBuilder<List<Empleado>>(
                    future: _empleadosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final empleados = snapshot.data ?? [];
                      if (empleados.isEmpty) {
                        return const Center(
                          child: Text(
                            "No hay empleados",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      return empleados.length == 1
                          ? Center(child: _buildEmployeeCard(empleados.first))
                          : CardSwiper(
                            cardsCount: empleados.length,
                            onSwipe: (prev, curr, dir) => true,
                            cardBuilder: (context, index, _, __) {
                              return _buildEmployeeCard(empleados[index]);
                            },
                          );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Botón de añadir
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: _build3DActionButton(
                icon: Icons.add,
                label: "Añadir",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEmployeePage(),
                    ),
                  );
                  if (result != null) {
                    _refreshEmployees();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Empleado employee) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        height: 4000,
        width: 320,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/empleado.png'),
            ),
            Text(
              '${employee.firstName ?? "Nombre"} ${employee.lastName ?? "Apellido"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              employee.descripcion ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            DefaultTextStyle.merge(
              style: const TextStyle(color: Color(0xFF9B1D42), fontSize: 18),
              child: _buildFlatWhiteButton(
                icon: Icon(Icons.visibility, color: Color(0xFF9B1D42), size: 32),
                label: "Ver",
                onPressed: () async {
                  if (employee.id != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                EmployeeDetailPage(employeeId: employee.id!),
                      ),
                    );
                    if (result == true) {
                      _refreshEmployees();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatWhiteButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(
        label,
        style: const TextStyle(color: Color(0xFF9B1D42), fontSize: 22, fontFamily: 'TitanOne'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9B1D42),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    );
  }

  Widget _build3DActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 3)),
          BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-3, -3)),
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF9B1D42),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF9B1D42), width: 2),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28, color: const Color(0xFF9B1D42)),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            fontFamily: 'TitanOne',
            color: Color(0xFF9B1D42),
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
