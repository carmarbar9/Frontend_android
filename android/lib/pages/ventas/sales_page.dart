import 'package:android/models/lote.dart';
import 'package:android/pages/login/elegirNegocio_page.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/services/service_empleados.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:android/models/pedido.dart';
import 'package:android/services/service_pedido.dart';
import 'package:android/services/service_empleados.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/models/empleados.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final PedidoService pedidoService = PedidoService();
  List<Pedido> pedidos = [];
  Map<int, String> nombresEmpleados = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    try {
      final negocioId = int.parse(SessionManager.negocioId!);
      final results = await pedidoService.loadPedidosByNegocioId(negocioId);

      final Map<int, String> nombres = {};
      final futures =
          results.map((pedido) async {
            final id = pedido.empleadoId;
            if (id != null && !nombres.containsKey(id)) {
              try {
                final empleado = await EmpleadoService.getEmpleadoById(id);
                if (empleado != null) {
                  nombres[id] = "${empleado.firstName} ${empleado.lastName}";
                }
              } catch (e) {
                debugPrint("Error al obtener empleado $id: $e");
              }
            }
          }).toList();

      await Future.wait(futures);

      setState(() {
        pedidos = results;
        nombresEmpleados = nombres;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar pedidos: $e');
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
                  onTap: () => Navigator.pop(context),
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
                          final productos =
                              await InventoryApiService.getProductosInventario();

                          final Map<int, List<Lote>> lotesPorProducto = {};
                          for (var producto in productos) {
                            final lotes =
                                await LoteProductoService.getLotesByProductoId(
                                  producto.id,
                                );
                            lotesPorProducto[producto.id] = lotes;
                          }

                          final notificaciones = NotificacionService()
                              .generarNotificacionesInventario(
                                productos,
                                lotesPorProducto,
                              );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => NotificacionPage(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al cargar notificaciones: $e',
                              ),
                            ),
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
              'VENTAS',
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
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView.builder(
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];
                          return _buildSaleCard(context, pedido);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Pedido pedido) {
    final nombreEmpleado =
        nombresEmpleados[pedido.empleadoId] ?? "Empleado ${pedido.empleadoId}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF9B1D42),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "MESA ${pedido.mesaId}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'TitanOne',
                ),
              ),
              Text(
                "${pedido.precioTotal.toStringAsFixed(2)}€",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                pedido.fecha.split("T").first,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                nombreEmpleado,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(width: 80),
          const Icon(LineIcons.receipt, color: Colors.white, size: 70),
        ],
      ),
    );
  }
}
