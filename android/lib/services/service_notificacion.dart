import 'package:uuid/uuid.dart';
import '../models/notificacion.dart';
import '../models/producto_inventario.dart';
import '../models/lote.dart';

class NotificacionService {
  final _uuid = const Uuid();

  /// Genera notificaciones de inventario con stock bajo
  List<Notificacion> generarNotificacionesInventario(
    List<ProductoInventario> productos,
    Map<int, List<Lote>> lotesPorProducto,
  ) {
    List<Notificacion> notificaciones = [];

    for (var producto in productos) {
      final lotes = lotesPorProducto[producto.id] ?? [];
      final cantidadActual = producto.calcularCantidad(lotes);

      if (cantidadActual <= producto.cantidadAviso) {
        notificaciones.add(
          Notificacion(
            id: _uuid.v4(),
            tipo: TipoNotificacion.inventario,
            titulo: 'Stock bajo: ${producto.name}',
            descripcion:
                'Cantidad actual: $cantidadActual (Aviso: ${producto.cantidadAviso})',
            fecha: DateTime.now(),
            datosExtra: {
              'productoId': producto.id,
              'cantidadActual': cantidadActual,
            },
          ),
        );
      }
    }

    return notificaciones;
  }

  List<Notificacion> generarNotificacionesCaducidad(
    List<ProductoInventario> productos,
    Map<int, List<Lote>> lotesPorProducto,
  ) {
    List<Notificacion> notificaciones = [];
    final hoy = DateTime.now();

    for (var producto in productos) {
      final lotes = lotesPorProducto[producto.id] ?? [];
      for (var lote in lotes) {
        final diasRestantes = lote.fechaCaducidad.difference(hoy).inDays;

        if (diasRestantes <= 7 && diasRestantes >= 0) {
          notificaciones.add(
            Notificacion(
              id: _uuid.v4(),
              tipo: TipoNotificacion.caducidad,
              titulo: 'Caduca pronto: ${producto.name}',
              descripcion:
                  'Caduca en $diasRestantes días (${_formatearFecha(lote.fechaCaducidad)})',
              fecha: DateTime.now(),
              datosExtra: {
                'productoId': producto.id,
                'fechaCaducidad': lote.fechaCaducidad.toIso8601String(),
              },
            ),
          );
        }
      }
    }

    return notificaciones;
  }


  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

}
