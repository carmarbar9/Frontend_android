import 'package:android/models/lote.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android/models/subscripcion.dart';
import 'package:android/services/service_subscription.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/models/session_manager.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  Subscripcion? subscripcion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    subscripcion = SessionManager.user?.subscripcion;
    isLoading = false;
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
              'PLANES',
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: [
                        _buildPlanCard(
                          title: 'BÁSICO',
                          price: '0€/MES',
                          features: [
                            'Gestor del inventario',
                            'Alertas personalizadas',
                            'Estadísticas mínimas',
                          ],
                          isCurrent:
                              subscripcion?.planType == SubscripcionType.FREE,
                          detalles: subscripcion,
                        ),
                        _buildPlanCard(
                          title: 'PREMIUM',
                          price: '25€/MES',
                          features: [
                            'Todas las funciones del plan Free',
                            'IA personal para gestión optimizada',
                            'Análisis detallado y predictivo',
                            'Predicción de la oferta y la demanda',
                            'Gestor de proveedores',
                            'Gestor de restock y control de pérdidas',
                            'Alertas personalizadas avanzadas',
                            'Gestor del inventario automatizado',
                          ],
                          isCurrent: subscripcion?.planType ==
                              SubscripcionType.PREMIUM,
                          detalles: subscripcion,
                        ),
                        _buildPlanCard(
                          title: 'PILOTO',
                          price: '5€/MES (primer año)',
                          features: [
                            'Acceso gratuito durante los primeros 2 meses',
                            'Acceso a todas las funciones del plan Premium',
                            '5€/mes durante el primer año',
                            'Tras esto, 25€/mes',
                          ],
                          isCurrent:
                              subscripcion?.planType == SubscripcionType.PILOT,
                          detalles: subscripcion,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          '¿Quieres mejorar tu plan? Accede a nuestra web:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              const url =
                                  'https://ispp-2425-g2.ew.r.appspot.com/masInformacion';
                              _abrirEnlaceWeb(url);
                            },
                            child: const Text(
                              'Ver más información',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isCurrent,
    Subscripcion? detalles,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color.fromARGB(255, 45, 91, 167)
            : const Color.fromARGB(255, 167, 45, 77),
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  price,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                if (isCurrent && detalles != null) ...[
                  const Divider(color: Colors.white70),
                  Text('Estado: ${detalles.status.name}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Válido hasta: ${_formatearFecha(detalles.expirationDate)}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Próxima facturación: ${_formatearFecha(detalles.nextBillingDate)}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                ]
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          Text(f, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          if (isCurrent)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: const Text('Tu plan actual',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _abrirEnlaceWeb(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
