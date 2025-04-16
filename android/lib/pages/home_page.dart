  import 'dart:ui';
  import 'package:flutter/material.dart';
  import 'package:android/pages/empleados/employee_page.dart';
  import 'package:android/pages/notificaciones/notifications_page.dart';
  import 'package:android/pages/proveedores/providers_page.dart';
  import 'package:android/pages/login/login_page.dart';
  import 'package:android/models/session_manager.dart';
  import 'package:android/pages/inventario/inventory_page.dart';
  import 'package:android/pages/planes/plans_page.dart';
  import 'package:android/pages/ventas/sales_page.dart';
  import 'package:android/pages/dashboard/dashboard_page.dart';
  import 'package:android/pages/user/user_profile.dart';
  import 'package:android/pages/carta/carta_page.dart';
  import 'package:android/pages/login/elegirNegocio_page.dart';
  import 'package:android/services/service_notificacion.dart';
  import 'package:android/models/lote.dart';
  import 'package:android/models/producto_inventario.dart';
  import 'package:android/services/service_inventory.dart';
  import 'package:android/services/service_lote.dart';


  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    _HomePageState createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
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
                  Image.asset('assets/logo.png', height: 62),
                  Row(
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.notifications, color: Colors.black),
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
                                builder: (_) => NotificacionPage(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error cargando notificaciones: $e')),
                            );
                          }
                        },
                      ),

                      IconButton(
              iconSize: 48,
              icon: const Icon(Icons.business_center, color: Colors.black),
              tooltip: 'Cambiar negocio',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ElegirNegocioPage(
                      user: SessionManager.currentUser!,
                    ),
                  ),
                );
              },
            ),
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.person, color: Colors.black),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfilePage()));
                        },
                      ),
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.logout, color: Colors.black),
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  SessionManager.negocioNombre ?? "INICIO",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFamily: 'PermanentMarker',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _build3DButton(Icons.restaurant_menu, "Carta", CartaPage()),
                  _build3DButton(
                                  Icons.inventory,
                                  "Inventario",
                                  InventoryPage(negocioId: SessionManager.negocioId ?? '1'),
                                ),

                  _build3DButton(Icons.attach_money, "Ventas", SalesPage()),
                  _build3DButton(Icons.dashboard, "Dashboard", DashboardPage()),
                  _build3DButton(Icons.people, "Empleados", EmployeesPage()),
                  _build3DButton(Icons.local_shipping, "Proveedores", ProvidersPage()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _build3DButton(IconData icon, String text, Widget page) {
      return GestureDetector(
        onTapDown: (_) => setState(() {}), 
        onTapUp: (_) {
          setState(() {}); 
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(4, 4), 
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(-4, -4), 
              ),
            ],
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9B1D42),
                Color(0xFFB12A50),
                Color(0xFFD33E66),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              elevation: 0, 
            ),
            onPressed: null, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TitanOne',
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5), 
                        blurRadius: 3,
                        color: Colors.black26, 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

  }