import 'package:android/models/producto_inventario.dart';

class CarritoManager {
  // Estructura: proveedorId -> Lista de productos con cantidad
  static final Map<int, List<ProductoCarrito>> _carritos = {};

  /// Añadir o actualizar producto en el carrito del proveedor
  static void anadirProducto({
    required int proveedorId,
    required ProductoInventario producto,
    required int cantidad,
  }) {
    _carritos.putIfAbsent(proveedorId, () => []);
    final productos = _carritos[proveedorId]!;

    final index = productos.indexWhere((p) => p.producto.id == producto.id);

    if (index >= 0) {
      productos[index].cantidad = cantidad;
    } else {
      productos.add(ProductoCarrito(producto: producto, cantidad: cantidad));
    }
  }

  /// Obtener lista de productos de un carrito por proveedor
  static List<ProductoCarrito> getProductosDelCarrito(int proveedorId) {
    return _carritos[proveedorId] ?? [];
  }

  /// Obtener la cantidad total de productos añadidos al carrito
  static int getCantidadTotal(int proveedorId) {
    return getProductosDelCarrito(proveedorId).fold(0, (total, item) => total + item.cantidad);
  }

  /// Calcular precio total del carrito de un proveedor
  static double calcularPrecioTotal(int proveedorId) {
    return getProductosDelCarrito(proveedorId)
        .map((item) => item.producto.precioCompra * item.cantidad)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  /// Eliminar producto del carrito
  static void eliminarProducto(int proveedorId, int productoId) {
    _carritos[proveedorId]?.removeWhere((p) => p.producto.id == productoId);
  }

  /// Vaciar carrito
  static void vaciarCarrito(int proveedorId) {
    _carritos[proveedorId]?.clear();
  }

  /// Obtener todo el mapa (útil para guardar todos los carritos)
  static Map<int, List<ProductoCarrito>> getTodosLosCarritos() {
    return _carritos;
  }
}

class ProductoCarrito {
  final ProductoInventario producto;
  int cantidad;

  ProductoCarrito({
    required this.producto,
    required this.cantidad,
  });
}
