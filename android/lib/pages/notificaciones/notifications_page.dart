import 'package:flutter/material.dart';
import 'package:android/models/notificacion.dart';

class NotificacionPage extends StatelessWidget {
  final List<Notificacion> notificaciones;

  const NotificacionPage({super.key, required this.notificaciones});

  Icon _iconoPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.inventario:
        return const Icon(Icons.inventory, color: Colors.orange);
      case TipoNotificacion.proveedor:
        return const Icon(Icons.local_shipping, color: Colors.blueAccent);
      case TipoNotificacion.empleado:
        return const Icon(Icons.people, color: Colors.green);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: notificaciones.isEmpty
          ? const Center(child: Text('No hay notificaciones activas'))
          : ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final noti = notificaciones[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: _iconoPorTipo(noti.tipo),
                    title: Text(noti.titulo),
                    subtitle: Text(noti.descripcion),
                    trailing: Text(
                      '${noti.fecha.day}/${noti.fecha.month} ${noti.fecha.hour}:${noti.fecha.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      // Aquí puedes hacer navegación a más detalles si lo necesitas
                    },
                  ),
                );
              },
            ),
    );
  }
}
