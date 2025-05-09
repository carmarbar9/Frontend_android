import 'package:android/models/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_empleados.dart';
import 'package:bcrypt/bcrypt.dart';

class EmployeeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailPage({Key? key, required this.employeeId})
    : super(key: key);

  @override
  _EmployeeDetailPageState createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late Future<Empleado?> _employeeFuture;

  @override
  void initState() {
    super.initState();
    _employeeFuture = EmpleadoService.getEmpleadoById(widget.employeeId);
  }

  void _refreshEmployee() {
    setState(() {
      _employeeFuture = EmpleadoService.getEmpleadoById(widget.employeeId);
    });
  }

  void _deleteEmployee(Empleado employee) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Seguro que deseas eliminar este empleado?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await EmpleadoService.deleteEmpleado(employee.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Empleado eliminado correctamente")),
        );
        // Retorna true para indicar que se realizó la operación y se refresque la lista
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar el empleado: $e")),
        );
      }
    }
  }

  void _showEditDialog(Empleado employee) {
    // Controladores prellenados con los datos actuales
    final firstNameController = TextEditingController(text: employee.firstName);
    final lastNameController = TextEditingController(text: employee.lastName);
    final emailController = TextEditingController(text: employee.email);
    final telefonoController = TextEditingController(
      text: employee.numTelefono,
    );
    final descripcionController = TextEditingController(
      text: employee.descripcion,
    );

    // Necesarios para el EmpleadoDTO
    final usernameController = TextEditingController(text: employee.username);
    final passwordController = TextEditingController(); // Campo vacío siempre

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Editar Empleado",
            style: TextStyle(color: Color(0xFF9B1D42)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Apellido"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Usuario"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final passwordInput = passwordController.text.trim();

                if (passwordInput.isEmpty) {
                  // No cambia contraseña
                  employee.password = employee.password;
                } else {
                  // Encriptar con BCrypt en Flutter
                  employee.password = passwordInput;
                }

                employee.firstName = firstNameController.text;
                employee.lastName = lastNameController.text;
                employee.email = emailController.text;
                employee.numTelefono = telefonoController.text;
                employee.descripcion = descripcionController.text;
                employee.username = usernameController.text;
                employee.negocio =
                    employee.negocio ?? int.parse(SessionManager.negocioId!);

                try {
                  await EmpleadoService.updateEmpleado(employee.id!, employee);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Empleado actualizado correctamente"),
                    ),
                  );
                  Navigator.pop(dialogContext); // Cierra solo el AlertDialog
                  Navigator.pop(context, true); // Cierra pantalla detalle
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al actualizar: $e")),
                  );
                }
              },
              child: const Text("Actualizar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? "N/A",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'DETALLE',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PermanentMarker',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Empleado?>(
        future: _employeeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Empleado no encontrado'));
          }

          final employee = snapshot.data!;
          return Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9B1D42),
                    Color(0xFFB12A50),
                    Color(0xFFD33E66),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    width: 160, // ajusta este tamaño a tu gusto
                    height: 160,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/empleado.png',
                        fit:
                            BoxFit
                                .contain, // Usa 'cover' si quieres rellenar sin bordes blancos
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${employee.firstName ?? "N/A"} ${employee.lastName ?? ""}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'TitanOne',
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildDetailRow(Icons.email, "Email", employee.email),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    Icons.phone,
                    "Teléfono",
                    employee.numTelefono,
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    Icons.description,
                    "Descripción",
                    employee.descripcion,
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    Icons.store,
                    "Negocio",
                    employee.negocioNombre ?? "No asignado",
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFlatWhiteButton(
                        icon: Icons.edit,
                        label: "Editar",
                        onPressed: () => _showEditDialog(employee),
                      ),
                      _buildFlatWhiteButton(
                        icon: Icons.delete,
                        label: "Eliminar",
                        onPressed: () => _deleteEmployee(employee),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlatWhiteButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = const Color(0xFF9B1D42),
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 32),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'TitanOne',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    );
  }
}
