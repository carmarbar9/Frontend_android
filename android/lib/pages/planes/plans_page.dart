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
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final planActual = subscripcion?.planType;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'PLANES',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              title: 'BÁSICO',
              price: '0€/MES',
              features: [
                'Gestor del inventario',
                'Alertas personalizadas',
                'Estadísticas mínimas',
              ],
              isCurrent: planActual == SubscripcionType.FREE,
              detalles: planActual == SubscripcionType.FREE ? subscripcion : null,
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
              isCurrent: planActual == SubscripcionType.PREMIUM,
              detalles: planActual == SubscripcionType.PREMIUM ? subscripcion : null,
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
              isCurrent: planActual == SubscripcionType.PILOT,
              detalles: planActual == SubscripcionType.PILOT ? subscripcion : null,
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  const url = 'https://ispp-2425-g2.ew.r.appspot.com/masInformacion';
                  _abrirEnlaceWeb(url);
                },
                child: const Text(
                  'Ver más información',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[200],
      elevation: 0,
      leading: IconButton(
        icon: Image.asset('assets/logo.png', height: 60, width: 60),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionPage()),
            );
          },
        ),
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Future<void> _abrirEnlaceWeb(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
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
        color: isCurrent ? const Color.fromARGB(255, 45, 91, 167) : const Color.fromARGB(255, 167, 45, 77),
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  price,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                if (isCurrent && detalles != null) ...[
                  const Divider(color: Colors.white70),
                  Text('Estado: ${detalles.status.name}', style: const TextStyle(color: Colors.white)),
                  Text('Válido hasta: ${_formatearFecha(detalles.expirationDate)}', style: const TextStyle(color: Colors.white)),
                  Text('Próxima facturación: ${_formatearFecha(detalles.nextBillingDate)}', style: const TextStyle(color: Colors.white)),
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
                      child: Text(f, style: const TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: const Text('Tu plan actual', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}