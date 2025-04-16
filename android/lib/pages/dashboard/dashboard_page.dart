import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/models/lote.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png', height: 70),
          ),
        ),
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 167, 45, 77), size: 36),
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
                    builder: (_) => const NotificacionPage(),
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
            icon: const Icon(Icons.person, color: Colors.black, size: 36),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {},
              icon: const Icon(Icons.download, size: 24),
              label: const Text('Exportar', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 25),
            _buildInfoCard('Volumen (€) actual:', '25.000€'),
            _buildInfoCard('Volumen (€) esperado al mes:', '25.000€'),
            _buildInfoCard('Volumen (€) esperado próximo mes:', '25.000€'),
            const SizedBox(height: 25),
            const Text(
              'COMPARACIÓN MESES',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: [
            _buildBarData(0, 4),
            _buildBarData(1, 5),
            _buildBarData(2, 6),
            _buildBarData(3, 7),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL'];
                  return Text(months[value.toInt()], style: const TextStyle(fontSize: 14));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: Colors.red, width: 20, borderRadius: BorderRadius.circular(5)),
      ],
    );
  }
}