import 'package:flutter/material.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_empleados.dart';

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
                style: TextButton.styleFrom(
                foregroundColor: Colors.red,),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
    final firstNameController =
        TextEditingController(text: employee.firstName);
    final lastNameController =
        TextEditingController(text: employee.lastName);
    final emailController = TextEditingController(text: employee.email);
    final telefonoController =
        TextEditingController(text: employee.numTelefono);
    final descripcionController =
        TextEditingController(text: employee.descripcion);

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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                foregroundColor: Colors.red),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                foregroundColor: Colors.white, 
              ),
              onPressed: () async {
                // Actualizamos el objeto con los nuevos valores
                employee.firstName = firstNameController.text;
                employee.lastName = lastNameController.text;
                employee.email = emailController.text;
                employee.numTelefono = telefonoController.text;
                employee.descripcion = descripcionController.text;
                try {
                  await EmpleadoService.updateEmpleado(employee);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Empleado actualizado correctamente")),
                  );
                  // Primero cerramos el diálogo
                  Navigator.pop(dialogContext);
                  // Luego, cerramos la página de detalle retornando true para refrescar la lista
                  Navigator.pop(context, true);
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

  Widget _buildDetailRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            value ?? "N/A",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Detalle del Empleado',
          style: TextStyle(color: Colors.black),
        ),
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
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                  Center(
                    child: Text(
                      '${employee.firstName ?? "N/A"} ${employee.lastName ?? ""}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'PermanentMarker',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Email", employee.email),
                  const SizedBox(height: 12),
                  _buildDetailRow("Teléfono", employee.numTelefono),
                  const SizedBox(height: 12),
                  _buildDetailRow("Descripción", employee.descripcion),
                  const SizedBox(height: 12),
                  _buildDetailRow("Negocio", employee.negocio?.name),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        _showEditDialog(employee);
                      },
                      icon: const Icon(Icons.edit, size: 24),
                      label: const Text("Editar"),
                    ),

                   ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white, // <-- aquí
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        _deleteEmployee(employee);
                      },
                      icon: const Icon(Icons.delete, size: 24),
                      label: const Text("Eliminar"),
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
}
