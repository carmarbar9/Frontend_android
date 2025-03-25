import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_empleados.dart';
import 'package:android/pages/empleados/employee_detail_page.dart';
import 'package:android/pages/empleados/add_employee_page.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({Key? key}) : super(key: key);

  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late Future<List<Empleado>> _empleadosFuture;

  @override
  void initState() {
    super.initState();
    _refreshEmployees();
  }

  void _refreshEmployees() {
    setState(() {
      _empleadosFuture = EmpleadoService.getAllEmpleados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0, // Sin sombra en el AppBar
        leading: IconButton(
          icon: Image.asset(
            'assets/logo.png', // Imagen del logo
            height: 180,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón de notificaciones
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.notifications,
                color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          // Botón de perfil
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Empleado>>(
        future: _empleadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final empleados = snapshot.data ?? [];
          return Column(
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
                child: empleados.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay empleados",
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        ),
                      )
                    : (empleados.length == 1
                        ? Center(child: _buildEmployeeCard(empleados.first))
                        : CardSwiper(
                            cardsCount: empleados.length,
                            onSwipe: (previousIndex, currentIndex, direction) {
                              debugPrint(
                                  "Swiped from index: $previousIndex to $currentIndex");
                              return true;
                            },
                            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                              return _buildEmployeeCard(empleados[index]);
                            },
                          )),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 167, 45, 77),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  // Navega a la página de añadir empleado
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEmployeePage()),
                  );
                  // Si se creó un empleado, refresca la lista
                  if (result != null) {
                    _refreshEmployees();
                  }
                },
                icon: const Icon(Icons.add, size: 30),
                label: const Text(
                  "Añadir",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Empleado employee) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        height: 400,
        width: 320,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 167, 45, 77),
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
            // Imagen del empleado (usa imagen por defecto)
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/employee1.png'),
            ),
            // Nombre completo (firstName y lastName)
            Text(
              '${employee.firstName ?? "Nombre"} ${employee.lastName ?? "Apellido"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // Descripción del empleado
            Text(
              employee.descripcion ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            // Botón para ver detalles
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // Navega a la página de detalle pasando el id del empleado y espera el resultado.
                if (employee.id != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeDetailPage(employeeId: employee.id!),
                    ),
                  );
                  // Si se regresa un valor (por ejemplo, true tras eliminar o actualizar), refresca la lista.
                  if (result == true) {
                    _refreshEmployees();
                  }
                }
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
