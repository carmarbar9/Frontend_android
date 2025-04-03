import 'package:uuid/uuid.dart';
import '../models/notificacion.dart';
import '../models/producto_inventario.dart';
import '../models/lote.dart';

class NotificacionService {
  final _uuid = const Uuid();

  List<Notificacion> generarNotificacionesInventario(
    List<ProductoInventario> productos,
    Map<int, List<Lote>> lotesPorProducto,
  ) {
    List<Notificacion> notificaciones = [];

    for (var producto in productos) {
      final lotes = lotesPorProducto[producto.id] ?? [];
      final cantidadActual = producto.calcularCantidad(lotes); // 👈 Usamos la función del modelo

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
}
