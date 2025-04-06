import 'package:flutter/material.dart';
import 'package:android/models/notificacion.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/models/session_manager.dart';

class NotificacionPage extends StatelessWidget {
  final List<Notificacion> notificaciones;

  const NotificacionPage({super.key, required this.notificaciones});

  Icon _iconoPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.inventario:
        return const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40);
      case TipoNotificacion.proveedor:
        return const Icon(Icons.local_shipping, color: Colors.white, size: 40);
      case TipoNotificacion.empleado:
        return const Icon(Icons.people, color: Colors.white, size: 40);
      default:
        return const Icon(Icons.notifications, color: Colors.white, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // CABECERA gourmet
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
                      icon: const Icon(Icons.person, color: Colors.black, size: 48),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserProfilePage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black, size: 48),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 10),
            child: Text(
              'NOTIFICACIONES',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'PermanentMarker',
                color: Colors.black,
              ),
            ),
          ),

          Expanded(
            child: notificaciones.isEmpty
                ? const Center(
                    child: Text(
                      'No hay notificaciones activas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9B1D42),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: notificaciones.length,
                    itemBuilder: (context, index) {
                      final noti = notificaciones[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: _iconoPorTipo(noti.tipo),
                              title: Text(
                                noti.titulo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'TitanOne',
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  noti.descripcion,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              trailing: Text(
                                '${noti.fecha.day}/${noti.fecha.month} ${noti.fecha.hour}:${noti.fecha.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF9B1D42),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                onPressed: () {
                                  // Aquí deberías implementar la lógica de añadir al carrito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Producto añadido al carrito (por implementar)'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF9B1D42)),
                                label: const Text(
                                  'Añadir al carrito',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'TitanOne',
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
