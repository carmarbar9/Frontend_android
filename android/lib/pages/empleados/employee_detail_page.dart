import 'package:flutter/material.dart';
import 'package:android/models/empleados.dart';
import 'package:android/services/service_empleados.dart';

class EmployeeDetailPage extends StatelessWidget {
  final int employeeId;

  const EmployeeDetailPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con fondo blanco y estilo acorde
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
        future: EmpleadoService.getEmpleadoById(employeeId),
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
                ],
              ),
            ),
          );
        },
      ),
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
}
