import 'package:android/services/service_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/models/session_manager.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, double> ingresos = {};
  List<MapEntry<ProductoVenta, int>> masVendidos = [];
  List<MapEntry<ProductoInventario, int>> menosCantidad = [];
  Map<int, int> volumenSemanal = {};
  bool isLoading = true;

  final List<String> orderedMonths = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  final List<String> monthLabels = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final negocioId = int.parse(SessionManager.negocioId!);
      ingresos = await DashboardService.fetchIngresosPorMes(negocioId);
      masVendidos = await DashboardService.fetchProductosMasVendidos(negocioId);
      menosCantidad = await DashboardService.fetchProductosConMenosCantidad(
        negocioId,
      );
      menosCantidad.sort((a, b) => a.value.compareTo(b.value));
      volumenSemanal = await DashboardService.fetchVolumenPorSemana(negocioId);
    } catch (e) {
      debugPrint('Error al cargar estadísticas: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
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
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificacionPage(),
                            ),
                          ),
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserProfilePage(),
                            ),
                          ),
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed:
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'DASHBOARD',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: _buildInfoCard(
                              'Ingresos totales del año',
                              _totalIngresos(),
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Comparativa mensual',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildBarChart(),
                          const SizedBox(height: 30),
                          const Text(
                            'Volumen de pedidos (por semana)',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildVolumenList(),
                          const SizedBox(height: 30),
                          const Text(
                            'Productos más vendidos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...masVendidos.map(
                            (entry) => _buildListTile(
                              entry.key.name,
                              '${entry.value} uds',
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Stock crítico',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B1D42),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...menosCantidad.map(
                            (entry) => _buildListTile(
                              entry.key.name,
                              '${entry.value} unidades',
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  String _totalIngresos() {
    final total = ingresos.values.fold(0.0, (sum, value) => sum + value);
    return "${total.toStringAsFixed(2)} €";
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.shopping_basket, color: Color(0xFF9B1D42)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = monthLabels[group.x.toInt()];
                final value = rod.toY.toStringAsFixed(2);
                return BarTooltipItem(
                  '$month\n$value €',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          maxY:
              ingresos.values.isNotEmpty
                  ? ingresos.values.reduce((a, b) => a > b ? a : b) + 10
                  : 100,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return index >= 0 && index < monthLabels.length
                      ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          monthLabels[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: List.generate(12, (i) {
            final mesClave = orderedMonths[i];
            final valor = ingresos[mesClave] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: valor,
                  width: 18,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD33E66), Color(0xFF9B1D42)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildVolumenList() {
    if (volumenSemanal.isEmpty) {
      return const Text('No hay datos de volumen.');
    }
    return Column(
      children:
          volumenSemanal.entries
              .map(
                (entry) => _buildListTile(
                  'Semana ${entry.key}',
                  '${entry.value} pedidos',
                ),
              )
              .toList(),
    );
  }
}
