import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,  // Remover la sombra del AppBar
        leading: IconButton(
          icon: Container(
            height: 120,  // Aumentamos el tamaño del logo
            width: 120,  // Mantener el logo en proporción cuadrada
            child: Image.asset(
              'assets/logo.png', // Utilizamos la imagen del logo como ícono
              fit: BoxFit.contain,  // Asegura que el logo se mantenga dentro de los límites
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // Navegar atrás cuando se toca el logo
          },
        ),
        actions: [
          // Icono de notificaciones en la izquierda
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          // Icono de perfil en la izquierda
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 55, vertical: 10),
            child: Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 3,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ),
          _buildNotificationCard('VENTAS', 'Volumen semanal por encima de lo esperado', '17/03/2025'),
          _buildNotificationCard('RIESGO', 'Atún caduca en 10 días', '15/03/2025'),
          _buildNotificationCard('STOCK', 'Lechuga en alerta de stock', '13/03/2025'),
        ],
      ),
    );
  }

  // Función que asigna un icono basado en el tipo de notificación
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'VENTAS':
        return Icons.trending_up;  // Icono para ventas
      case 'RIESGO':
        return Icons.warning;      // Icono para riesgo
      case 'STOCK':
        return LineIcons.box;      // Icono para stock
      default:
        return Icons.notifications;  // Icono predeterminado
    }
  }

  Widget _buildNotificationCard(String title, String description, String date) {
    // Usamos la función _getNotificationIcon para obtener el icono según el tipo
    IconData icon = _getNotificationIcon(title);

    return Card(
      color: const Color.fromARGB(255, 167, 45, 77),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          // Icono de fondo
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                icon, 
                color: const Color.fromARGB(255, 14, 13, 13).withOpacity(0.5), // Color del icono en el fondo
                size: 100,
              ),
            ),
          ),
          // Contenido de la notificación
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                if (title != 'VENTAS') // Condición para ocultar el botón en notificaciones de ventas
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Acción para añadir al carrito u otra funcionalidad
                    },
                    label: const Text("Añadir AL"),
                    icon: const Icon(Icons.add_shopping_cart, size: 40), // Icono a la derecha
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
